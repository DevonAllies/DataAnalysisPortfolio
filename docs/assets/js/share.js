// Share buttons for articles and tutorials: Email, X, WhatsApp, LinkedIn and Copy link.
// Added to pages by `include-after-body` in writing/_metadata.yml and
// tutorials/_metadata.yml. One bar goes under the title, one at the end.
//
// Links always point to the live site (devonallies.co.za + this page's path),
// so sharing from a local preview still gives readers a working address.
(function () {
  const SITE = "https://devonallies.co.za";
  const header = document.getElementById("title-block-header");
  const main = document.querySelector("main.content") || document.querySelector("main");
  if (!header || !main) return;

  const path = location.pathname.replace(/index\.html$/, "");
  const url = SITE + path;
  const h1 = header.querySelector("h1.title");
  const title = (h1 ? h1.textContent : document.title).trim();
  const enc = encodeURIComponent;

  const targets = [
    { name: "Email", icon: "bi-envelope",
      href: `mailto:?subject=${enc(title)}&body=${enc(title + "\n\n" + url)}` },
    { name: "X", icon: "bi-twitter-x",
      href: `https://x.com/intent/tweet?text=${enc(title)}&url=${enc(url)}` },
    { name: "WhatsApp", icon: "bi-whatsapp",
      href: `https://wa.me/?text=${enc(title + " " + url)}` },
    { name: "LinkedIn", icon: "bi-linkedin",
      href: `https://www.linkedin.com/sharing/share-offsite/?url=${enc(url)}` },
  ];

  async function copy(button) {
    let ok = false;
    try {
      await navigator.clipboard.writeText(url);
      ok = true;
    } catch (e) {
      // Fallback for browsers without the Clipboard API
      const box = document.createElement("textarea");
      box.value = url;
      box.setAttribute("readonly", "");
      box.style.position = "absolute";
      box.style.left = "-9999px";
      document.body.appendChild(box);
      box.select();
      try { ok = document.execCommand("copy"); } catch (e2) { ok = false; }
      box.remove();
    }
    const label = button.querySelector(".share-label");
    const icon = button.querySelector("i");
    const before = [label.textContent, icon.className];
    label.textContent = ok ? "Link copied" : "Copy failed";
    icon.className = ok ? "bi bi-check2" : "bi bi-x";
    button.setAttribute("aria-live", "polite");
    setTimeout(() => { label.textContent = before[0]; icon.className = before[1]; }, 2000);
  }

  function bar(position) {
    const nav = document.createElement("nav");
    nav.className = "share-bar share-bar-" + position;
    nav.setAttribute("aria-label", "Share this page");
    const lead = document.createElement("span");
    lead.className = "share-lead";
    lead.textContent = position === "end" ? "Found this useful? Share it:" : "Share:";
    nav.appendChild(lead);
    for (const t of targets) {
      const a = document.createElement("a");
      a.className = "share-button";
      a.href = t.href;
      if (!t.href.startsWith("mailto:")) { a.target = "_blank"; a.rel = "noopener"; }
      a.title = "Share by " + t.name;
      a.innerHTML = `<i class="bi ${t.icon}" aria-hidden="true"></i><span class="share-label">${t.name}</span>`;
      nav.appendChild(a);
    }
    const b = document.createElement("button");
    b.type = "button";
    b.className = "share-button";
    b.title = "Copy the link to this page";
    b.innerHTML = '<i class="bi bi-link-45deg" aria-hidden="true"></i><span class="share-label">Copy link</span>';
    b.addEventListener("click", () => copy(b));
    nav.appendChild(b);
    return nav;
  }

  header.appendChild(bar("top"));
  // End of the page: before the references if there are any, otherwise last
  const refs = main.querySelector("#refs");
  const refsSection = refs ? refs.closest("section") || refs : null;
  if (refsSection && refsSection.parentElement) refsSection.parentElement.insertBefore(bar("end"), refsSection);
  else main.appendChild(bar("end"));
})();
