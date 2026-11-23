// "In this series" panel for multi-part tutorials (built by assets/lua/series.lua).
// On wide screens it moves into the empty right-hand margin column, where it
// stays in view while the page scrolls, as quick navigation between parts. It's
// an extra: the series box under the title and the links at the end stay. On
// narrow screens (no margin column) the panel stays hidden.
(function () {
  const panel = document.querySelector("nav.series-panel");
  const margin = document.getElementById("quarto-margin-sidebar");
  if (!panel || !margin) return;

  function place() {
    const style = getComputedStyle(margin);
    const wide = style.display !== "none" && margin.getBoundingClientRect().width > 150;
    if (wide) {
      if (panel.parentElement !== margin) margin.appendChild(panel);
      // Quarto gives this column z-index -1 (zindex-bottom), which puts it under
      // the page and makes its links unclickable; lift it once it holds the panel
      margin.classList.remove("zindex-bottom");
      panel.hidden = false;
    } else {
      panel.hidden = true;
    }
  }

  place();
  window.addEventListener("resize", place);
})();
