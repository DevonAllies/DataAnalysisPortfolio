"""Refresh _data/publications.json from ORCID, Crossref and Medium.

ORCID lists the works on the profile; Crossref fills in authors, journal,
volume, pages and citation counts from each DOI. Medium's public RSS feed
lists the articles. None of these need a login.

Run from the project root, then re-render publications.qmd:
    uv run python scripts/fetch_publications.py
"""

import html
import json
import re
import urllib.request
import xml.etree.ElementTree as ET
from email.utils import parsedate_to_datetime
from pathlib import Path
from urllib.parse import quote

ORCID_ID = "0000-0001-8928-4334"
MEDIUM_FEED = "https://medium.com/feed/@alliesdl"
EXCERPT_WORDS = 45
OUT = Path("_data/publications.json")
HEADERS = {"Accept": "application/json", "User-Agent": "portfolio-publications-script/1.0"}

# Corrections where an ORCID record is wrong, keyed by lower-case DOI.
OVERRIDES = {
    # ORCID says "Lancet"; the S1473-3099 DOI prefix is The Lancet Infectious Diseases.
    "10.1016/s1473-3099(22)00222-5": {"journal": "The Lancet Infectious Diseases"},
}


def get_json(url):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


def fetch_articles():
    req = urllib.request.Request(MEDIUM_FEED, headers={"User-Agent": HEADERS["User-Agent"]})
    with urllib.request.urlopen(req, timeout=30) as r:
        root = ET.fromstring(r.read())
    ns = {"content": "http://purl.org/rss/1.0/modules/content/"}
    articles = []
    for item in root.findall("./channel/item"):
        body = item.findtext("content:encoded", default="", namespaces=ns)
        # First paragraph(s) as plain text, skipping a repeated title heading.
        paras = [
            re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", p))).strip()
            for p in re.findall(r"<p>(.*?)</p>", body, re.S)
        ]
        text = " ".join(p for p in paras if p)
        words = text.split()
        excerpt = " ".join(words[:EXCERPT_WORDS]) + ("…" if len(words) > EXCERPT_WORDS else "")
        published = parsedate_to_datetime(item.findtext("pubDate"))
        articles.append(
            {
                "title": item.findtext("title"),
                "date": published.date().isoformat(),
                "url": item.findtext("link").split("?")[0],
                "tags": [c.text for c in item.findall("category")],
                "excerpt": excerpt,
                "minutes": max(1, round(len(re.sub(r"<[^>]+>", " ", body).split()) / 230)),
            }
        )
    articles.sort(key=lambda a: a["date"], reverse=True)
    return articles


def main():
    works = get_json(f"https://pub.orcid.org/v3.0/{ORCID_ID}/works")
    pubs = []
    for group in works.get("group", []):
        s = group["work-summary"][0]
        ids = {
            e["external-id-type"]: e["external-id-value"]
            for e in (s.get("external-ids") or {}).get("external-id", [])
        }
        doi = ids.get("doi", "").lower()
        pub = {
            "title": s["title"]["title"]["value"].rstrip("."),
            "year": int((s.get("publication-date") or {}).get("year", {}).get("value", 0)),
            "journal": (s.get("journal-title") or {}).get("value"),
            "doi": doi or None,
            "pmid": ids.get("pmid"),
            "pmcid": ids.get("pmc"),
        }
        if doi:
            m = get_json(f"https://api.crossref.org/works/{quote(doi)}")["message"]
            authors = [
                f"{a.get('family', '')} {''.join(p[0] for p in a.get('given', '').replace('-', ' ').split())}".strip()
                for a in m.get("author", [])
                if a.get("family")
            ]
            pub.update(
                authors=authors,
                journal=(m.get("container-title") or [pub["journal"]])[0],
                volume=m.get("volume"),
                issue=m.get("issue"),
                pages=m.get("page") or m.get("article-number"),
                cited_by=m.get("is-referenced-by-count"),
            )
        pub.update(OVERRIDES.get(doi, {}))
        pubs.append(pub)

    pubs.sort(key=lambda p: p["year"], reverse=True)
    articles = fetch_articles()
    OUT.write_text(
        json.dumps({"orcid": ORCID_ID, "publications": pubs, "articles": articles}, indent=2, ensure_ascii=False)
        + "\n"
    )
    for p in pubs:
        print(f"{p['year']}  {p['journal']}  authors={len(p.get('authors', []))}  cited_by={p.get('cited_by')}")
    for a in articles:
        print(f"{a['date']}  {a['minutes']} min  {a['title']}")


if __name__ == "__main__":
    main()
