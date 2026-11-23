// "In this series" panel for multi-part tutorials (built by assets/lua/series.lua).
// On wide screens it moves into the empty right-hand margin column, where it
// stays in view while the page scrolls, and the series box under the title is
// hidden. On narrow screens (no margin column) the panel stays hidden and the
// box does the job instead. Without JavaScript, the box is always shown.
(function () {
  const panel = document.querySelector("nav.series-panel");
  const margin = document.getElementById("quarto-margin-sidebar");
  if (!panel || !margin) return;

  function place() {
    const style = getComputedStyle(margin);
    const wide = style.display !== "none" && margin.getBoundingClientRect().width > 150;
    if (wide) {
      if (panel.parentElement !== margin) margin.appendChild(panel);
      panel.hidden = false;
      document.body.classList.add("series-panel-shown");
    } else {
      panel.hidden = true;
      document.body.classList.remove("series-panel-shown");
    }
  }

  place();
  window.addEventListener("resize", place);
})();
