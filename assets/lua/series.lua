-- Series navigation for multi-part tutorials (and articles).
--
-- An article joins a series with two front-matter fields:
--   series: command-line      (a key from SERIES below)
--   series-part: 2            (its place in the series)
-- and `filters: [../../assets/lua/series.lua]`.
--
-- The filter finds every <dir>/*/index.qmd in the same series (dir comes
-- from SERIES below) and adds
-- a box under the title listing the parts, plus previous/next links at the
-- end. Parts dated in the future are drafts: they're listed as "coming
-- soon" without a link, matching how the article listings treat them.

local SERIES = {
  ["command-line"] = { name = "Bioinformatics on the command line", dir = "tutorials/command-line" },
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

function Pandoc(doc)
  local key = doc.meta.series and pandoc.utils.stringify(doc.meta.series)
  local this_part = doc.meta["series-part"] and tonumber(pandoc.utils.stringify(doc.meta["series-part"]))
  if not key or not this_part then return doc end
  local series_name = SERIES[key] and SERIES[key].name or key

  local writing = quarto.project.directory .. "/" .. (SERIES[key] and SERIES[key].dir or "writing")
  local today = os.date("%Y-%m-%d")
  local parts = {}
  for _, slug in ipairs(list_dir(writing)) do
    local m = front_matter(writing .. "/" .. slug .. "/index.qmd")
    if m and m.series == key and m.part then
      m.slug = slug
      m.published = (m.date or "9999") <= today
      table.insert(parts, m)
    end
  end
  table.sort(parts, function(a, b) return a.part < b.part end)

  -- Box under the title: the whole series, this part in bold
  -- Parts must come out in order: warn if one is dated before the part above it
  for i = 2, #parts do
    if (parts[i].date or "") < (parts[i - 1].date or "") then
      quarto.log.warning("Series '" .. key .. "': part " .. parts[i].part .. " (" .. parts[i].date
        .. ") is dated before part " .. parts[i - 1].part .. " (" .. parts[i - 1].date .. ")")
    end
  end

  local items = {}
  local prev, nxt
  for i, p in ipairs(parts) do
    local label = "Part " .. p.part .. ": "
    local entry
    if p.part == this_part then
      entry = label .. "**" .. p.title .. "** (this article)"
      prev = parts[i - 1]
      nxt = parts[i + 1]
    elseif p.published then
      entry = label .. "[" .. p.title .. "](../" .. p.slug .. "/index.qmd)"
    else
      entry = label .. p.title .. " *(coming soon)*"
    end
    table.insert(items, "- " .. entry)
  end
  local box_md = '::: {.callout-note .series-nav appearance="simple" collapse="true" title="Part '
    .. this_part .. " of the series: " .. series_name .. '"}\n'
    .. table.concat(items, "\n") .. "\n:::\n"
  local box = pandoc.read(box_md, "markdown").blocks

  -- Previous / next links at the end, before the references
  local links = {}
  if prev and prev.published then
    table.insert(links, "[← Part " .. prev.part .. ": " .. prev.title .. "](../" .. prev.slug .. "/index.qmd)")
  end
  if nxt then
    if nxt.published then
      table.insert(links, "[Part " .. nxt.part .. ": " .. nxt.title .. " →](../" .. nxt.slug .. "/index.qmd)")
    else
      table.insert(links, "Next: Part " .. nxt.part .. ", " .. nxt.title .. " *(coming soon)*")
    end
  end
  local footer = {}
  if #links > 0 then
    footer = pandoc.read("::: {.series-pager}\n" .. table.concat(links, "\n\n") .. "\n:::\n", "markdown").blocks
  end

  -- Insert the box at the top and the pager before a "References" heading (or at the end)
  local blocks = pandoc.List()
  blocks:extend(box)
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
