-- Series navigation for multi-part tutorials (and articles).
--
-- A page joins a series with two front-matter fields:
--   series: command-line      (a key from SERIES below)
--   series-part: 2            (its place in the series)
-- and `filters: [<path to>/assets/lua/series.lua]`.
--
-- The filter finds every <dir>/*/*.qmd in the same series (dir comes from
-- SERIES below) and adds three things:
--   1. a collapsible box (<details class="series-box">) under the title listing
--      the parts (shown on narrow screens; hidden on wide ones, where the side
--      panel takes its place),
--   2. a side panel, "In this series", that assets/js/series-panel.js moves into
--      the right-hand margin on wide screens, with previous/next links,
--   3. previous/next links before the References heading.
-- Parts dated in the future are drafts: they're listed as "coming soon"
-- without a link, matching how the listings treat them.

local SERIES = {
  ["command-line"] = { name = "Bioinformatics on the command line", dir = "tutorials/command-line", label = "Part" },
  ["data-science"] = { name = "Data science", dir = "tutorials", label = "Tutorial" },
}

local function front_matter(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local text = f:read("*a")
  f:close()
  local yaml = text:match("^%-%-%-\n(.-)\n%-%-%-")
  if not yaml then return nil end
  local function field(name)
    local v = yaml:match("\n" .. name:gsub("%-", "%%-") .. ":%s*([^\n]+)")
           or yaml:match("^" .. name:gsub("%-", "%%-") .. ":%s*([^\n]+)")
    if v then v = v:gsub("%s+#.*$", ""):gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1") end
    return v
  end
  return {
    title = field("title"),
    date = field("date"),
    series = field("series"),
    part = tonumber(field("series-part") or ""),
  }
end

local function list_dir(dir)
  local names = {}
  local p = io.popen('ls -1 "' .. dir .. '" 2>/dev/null')
  if p then
    for name in p:lines() do table.insert(names, name) end
    p:close()
  end
  return names
end

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

function Pandoc(doc)
  local key = doc.meta.series and pandoc.utils.stringify(doc.meta.series)
  local this_part = doc.meta["series-part"] and tonumber(pandoc.utils.stringify(doc.meta["series-part"]))
  if not key or not this_part then return doc end
  local cfg = SERIES[key] or { name = key, dir = "writing", label = "Part" }
  local label = cfg.label or "Part"

  -- Every .qmd one level down from the series folder that belongs to this series
  local root = quarto.project.directory .. "/" .. cfg.dir
  local today = os.date("%Y-%m-%d")
  local parts = {}
  for _, folder in ipairs(list_dir(root)) do
    for _, file in ipairs(list_dir(root .. "/" .. folder)) do
      if file:match("%.qmd$") then
        local m = front_matter(root .. "/" .. folder .. "/" .. file)
        if m and m.series == key and m.part then
          m.href = "../" .. folder .. "/" .. file      -- relative to a sibling part
          m.published = (m.date or "9999") <= today
          table.insert(parts, m)
        end
      end
    end
  end
  table.sort(parts, function(a, b) return a.part < b.part end)

  -- Parts must come out in order: warn if one is dated before the part above it
  for i = 2, #parts do
    if (parts[i].date or "") < (parts[i - 1].date or "") then
      quarto.log.warning("Series '" .. key .. "': part " .. parts[i].part .. " (" .. parts[i].date
        .. ") is dated before part " .. parts[i - 1].part .. " (" .. parts[i - 1].date .. ")")
    end
  end

  local prev, nxt
  for i, p in ipairs(parts) do
    if p.part == this_part then prev = parts[i - 1]; nxt = parts[i + 1] end
  end

  -- 1. Box under the title (narrow screens): a collapsible <details>, built as
  --    raw HTML so it doesn't depend on Quarto's callout processing
  local items = {}
  for _, p in ipairs(parts) do
    local lead = label .. " " .. p.part .. ": "
    local entry
    if p.part == this_part then
      entry = lead .. "<strong>" .. esc(p.title) .. "</strong> (this one)"
    elseif p.published then
      entry = lead .. '<a href="' .. p.href .. '">' .. esc(p.title) .. "</a>"
    else
      entry = lead .. esc(p.title) .. " <em>(coming soon)</em>"
    end
    table.insert(items, "<li>" .. entry .. "</li>")
  end
  local box_html = '<details class="series-box"><summary>' .. label .. " " .. this_part
    .. " of the series: " .. esc(cfg.name) .. "</summary><ul>" .. table.concat(items) .. "</ul></details>"
  local box = { pandoc.RawBlock("html", box_html) }

  -- 2. Side panel (wide screens). Links are written as .qmd and resolved by Quarto.
  local li = {}
  for _, p in ipairs(parts) do
    local num = '<span class="series-panel-num">' .. p.part .. '</span>'
    if p.part == this_part then
      table.insert(li, '<li class="current" aria-current="page">' .. num .. '<span>' .. esc(p.title) .. '</span></li>')
    elseif p.published then
      table.insert(li, '<li><a href="' .. p.href .. '">' .. num .. '<span>' .. esc(p.title) .. '</span></a></li>')
    else
      table.insert(li, '<li class="upcoming">' .. num .. '<span>' .. esc(p.title) .. ' <em>(coming soon)</em></span></li>')
    end
  end
  local pn = {}
  if prev and prev.published then
    table.insert(pn, '<a class="series-panel-prev" href="' .. prev.href .. '">← Previous</a>')
  end
  if nxt and nxt.published then
    table.insert(pn, '<a class="series-panel-next" href="' .. nxt.href .. '">Next →</a>')
  end
  local panel_html = '<nav class="series-panel" aria-label="In this series" hidden>'
    .. '<p class="series-panel-title">In this series</p>'
    .. '<p class="series-panel-name">' .. esc(cfg.name) .. '</p>'
    .. '<ol class="series-panel-list">' .. table.concat(li) .. '</ol>'
    .. (#pn > 0 and ('<div class="series-panel-pager">' .. table.concat(pn) .. '</div>') or '')
    .. '</nav>'
  local panel = { pandoc.RawBlock("html", panel_html) }

  -- 3. Previous / next links at the end, before the references
  local links = {}
  if prev and prev.published then
    table.insert(links, "[← " .. label .. " " .. prev.part .. ": " .. prev.title .. "](" .. prev.href .. ")")
  end
  if nxt then
    if nxt.published then
      table.insert(links, "[" .. label .. " " .. nxt.part .. ": " .. nxt.title .. " →](" .. nxt.href .. ")")
    else
      table.insert(links, "Next: " .. label .. " " .. nxt.part .. ", " .. nxt.title .. " *(coming soon)*")
    end
  end
  local footer = {}
  if #links > 0 then
    footer = pandoc.read("::: {.series-pager}\n" .. table.concat(links, "\n\n") .. "\n:::\n", "markdown").blocks
  end

  local blocks = pandoc.List()
  blocks:extend(box)
  blocks:extend(panel)
  local placed = false
  for _, b in ipairs(doc.blocks) do
    if not placed and b.t == "Header" and b.level == 2 and pandoc.utils.stringify(b) == "References" then
      blocks:extend(footer)
      placed = true
    end
    blocks:insert(b)
  end
  if not placed then blocks:extend(footer) end
  doc.blocks = blocks
  return doc
end
