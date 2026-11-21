// "On this page" for pages with collapsible groups (<details class="pub-group">),
// used by publications.qmd and resources.qmd.
//
// - Under each section's entry, lists the cards inside it (each card title is
//   a small heading: .pub-title or .resource-title). The sub-list shows while
//   that section's group is open, so the contents stay short.
// - Clicking a section's entry opens its group; clicking a card's entry opens
//   the group and scrolls to the card.
(function () {
  const toc = document.getElementById("TOC");
  if (!toc) return;

  const tocLinks = new Map();
  toc.querySelectorAll("a[href^='#']").forEach(a => tocLinks.set(decodeURIComponent(a.getAttribute("href").slice(1)), a));

  // A section's own groups (not those inside a deeper section)
  const groupsOf = section => Array.from(section.querySelectorAll("details.pub-group")).filter(d => d.closest("section") === section);

  // The section id that belongs to a card heading (Quarto wraps headings in <section id=...>)
  const idOf = h => (h.closest("section") && h.closest("section").id) || h.id || h.dataset.anchorId;

  function openFor(el) {
    const group = el.closest("details.pub-group");
    if (group) group.open = true;
    const section = el.closest("section");
    if (section) groupsOf(section).forEach(d => (d.open = true));
  }

  // Group card headings under the nearest enclosing section that has its own TOC entry
  const children = new Map();
  document.querySelectorAll("main h3.pub-title, main h4.pub-title, main h3.resource-title, main h4.resource-title").forEach(h => {
    const own = h.closest("section");
    let parent = own ? own.parentElement && own.parentElement.closest("section") : null;
    while (parent && !tocLinks.has(parent.id)) parent = parent.parentElement && parent.parentElement.closest("section");
    if (!parent) return;
    if (!children.has(parent.id)) children.set(parent.id, []);
    children.get(parent.id).push(h);
  });

  children.forEach((headings, parentId) => {
    const link = tocLinks.get(parentId);
    const li = link.closest("li");
    const ul = document.createElement("ul");
    ul.className = "toc-cards";
    headings.forEach(h => {
      const item = document.createElement("li");
      const a = document.createElement("a");
      a.href = "#" + idOf(h);
      a.className = "nav-link toc-card-link";
      a.textContent = h.textContent.trim();
      a.addEventListener("click", () => openFor(h));
      item.appendChild(a);
      ul.appendChild(item);
    });
    li.appendChild(ul);

    // Show the sub-list only while this section's group is open
    const section = document.getElementById(parentId);
    // its own groups, or the group it sits inside (e.g. "R" inside "Package documentation")
    const groups = section ? groupsOf(section) : [];
    const outer = section && section.closest("details.pub-group");
    if (outer) groups.push(outer);
    const sync = () => ul.classList.toggle("open", groups.some(d => d.open));
    groups.forEach(d => d.addEventListener("toggle", sync));
    sync();
  });

  // Section entries open their group
  tocLinks.forEach((a, id) => {
    const target = document.getElementById(id);
    if (target) a.addEventListener("click", () => openFor(target));
  });

  // Links arriving with #something (or changing it) open the right group
  const fromHash = () => {
    if (!location.hash) return;
    const target = document.getElementById(decodeURIComponent(location.hash.slice(1)));
    if (target) { openFor(target); target.scrollIntoView(); }
  };
  window.addEventListener("hashchange", fromHash);
  fromHash();
})();
