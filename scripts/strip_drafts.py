"""Remove unpublished and redirect pages from docs/search.json and docs/sitemap.xml.

Rendering a draft (an article or tutorial dated in the future) adds it to the
site search and the sitemap, and so do the redirect pages Quarto writes for
`aliases:`. Neither should be findable on the live site. Run this after
rendering and before committing:

    uv run python scripts/strip_drafts.py

Drafts are found from the front matter of writing/*/index.qmd and
tutorials/**/*.qmd: any page whose `date` is later than today.
"""

import json
import re
from datetime import date
from pathlib import Path

DOCS = Path("docs")


def front_matter_date(qmd):
    text = qmd.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---", text, re.S)
    if not m:
        return None
    d = re.search(r"^date:\s*['\"]?(\d{4}-\d{2}-\d{2})", m.group(1), re.M)
    return date.fromisoformat(d.group(1)) if d else None


def unlisted_pages():
    """Rendered paths (relative to docs/) that shouldn't be indexed."""
    pages = set()
    today = date.today()
    for qmd in list(Path("writing").glob("*/index.qmd")) + list(Path("tutorials").rglob("*.qmd")):
        d = front_matter_date(qmd)
        if d and d > today:
            pages.add(qmd.with_suffix(".html").as_posix())
    # Redirect pages written for aliases
    for html in DOCS.rglob("*.html"):
        head = html.read_text(encoding="utf-8", errors="ignore")[:300]
        if "<title>Redirect</title>" in head:
            pages.add(html.relative_to(DOCS).as_posix())
    return pages


def main():
    pages = unlisted_pages()

    search = DOCS / "search.json"
    entries = json.loads(search.read_text(encoding="utf-8"))
    kept = [e for e in entries if e.get("href", "").split("#")[0] not in pages]
    search.write_text(json.dumps(kept, indent=2, ensure_ascii=False), encoding="utf-8")

    sitemap = DOCS / "sitemap.xml"
    xml = sitemap.read_text(encoding="utf-8")
    before = xml.count("<url>")
    for page in pages:
        xml = re.sub(r"\s*<url>\s*<loc>[^<]*/" + re.escape(page) + r"</loc>.*?</url>", "", xml, flags=re.S)
    sitemap.write_text(xml, encoding="utf-8")

    print(f"search.json: {len(entries)} -> {len(kept)} entries")
    print(f"sitemap.xml: {before} -> {xml.count('<url>')} pages")
    for page in sorted(pages):
        print("  unlisted:", page)


if __name__ == "__main__":
    main()
