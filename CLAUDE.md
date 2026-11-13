# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Quarto website (Devon Allies' personal site and data portfolio) published via GitHub Pages from the committed `docs/` folder (`.nojekyll` present) at https://devonallies.github.io/DataAnalysisPortfolio/. There is no build system beyond Quarto and no test suite.

## Environments

- **R: renv** (`renv.lock`, `renv/`). `.Rprofile` activates it automatically. Restore with `Rscript -e 'renv::restore()'`. Includes Bioconductor packages (`ballgown`, `genefilter`).
- **Python: uv** (`pyproject.toml`, `uv.lock`). Create the env with `uv sync`; add packages with `uv add <pkg>`.
- `.Rprofile` sets `RETICULATE_PYTHON` to `<project root>/.venv/bin/python`, so `{python}` chunks run under knitr+reticulate use the uv env. Quarto starts R from the project root (so `.Rprofile` loads) even for pages in subfolders, while each chunk's working directory is the page's own folder.
- Several pages load packages via `lapply(packages, library, character.only = TRUE)`, which renv's dependency scan can't see. When adding a package that way, also add a `library()` line to `scripts/r_dependencies.R`, then run `renv::snapshot()`.

## Commands

```bash
quarto render projects/<name>/index.qmd   # render one page (preferred; see below)
quarto preview --no-render                # serve docs/ locally with live reload
uv run python scripts/fetch_publications.py   # refresh _data/publications.json
uv run python scripts/build_tutorial_data.py  # rebuild tutorials/data/ from local full data
```

Prefer rendering pages one at a time over a bare `quarto render`: `chrx-rnaseq` and `tb-bal-cytokines` need local-only data, and `r-python-workflow` downloads from Kaggle, so a full render fails anywhere that data is missing. Rendered output in `docs/` is what gets deployed, so re-render and commit `docs/` alongside any `.qmd` change.

## Structure

- `_quarto.yml` — site config: `output-dir: docs`, cosmo + brand theme, `grid.body-width: 960px`, navbar (Home / Projects / Tutorials / Publications & Writing / About Me), site-wide `acronyms` filter, `site-url` (sitemap) and `open-graph` (link previews; Twitter cards deliberately off).
- `projects/<name>/` — one folder per project, all with the same layout: `index.qmd` (URL `/projects/<name>/`), `references.bib`, `images/` (thumbnail + figures), `data/` (inputs). Chunks run from the page's folder, so code reads `data/...` relative paths. Every project uses the shared citation style `../../assets/csl/harvard-anglia-ruskin-university.csl`. Each page lists its pre-2026-11-13 address under `aliases:`, which makes Quarto write a redirect page there; keep these so old links and Google's index keep working.
- Project data: only `covid19-blood-counts/data/` and `tb-global-trends/data/` are committed (explicit `!` exceptions in `.gitignore`); every other `data/` is local-only. `chrx-rnaseq` and `tb-bal-cytokines` need their local data to render.
- `index.qmd` — home page. Its "Featured projects" grid lists specific project files by hand (`listing.contents`). It also carries the Google Search Console verification meta tag (`include-in-header`); don't remove it.
- `projects.qmd` — grid listing over `projects/`, sorted by `date desc`. Front matter (`title`, `date`, `description`, `image`, `categories`) drives each card, so new projects need these set and the `image` must exist.
- `tutorials.qmd` — listing over `tutorials/`, sorted by each tutorial's `order` field. Tutorials live in numbered folders; `tutorials/_metadata.yml` sets shared options.
- `tutorials/data/` — small simulated BAL dataset, committed on purpose (`!tutorials/data/` and `!docs/tutorials/data/` exceptions) and copied into `docs/` via `project.resources` for the download buttons. Built by `scripts/build_tutorial_data.py` from the local, gitignored full study in `data/bal/bal-project/data/` (drops names/birth dates; `Age` comes from the cleaned baseline table). The raw Excel files are deliberately messy and the tutorial text describes those quirks, so regenerate with care.
- `publications.qmd` ("Publications & Writing") — renders `_data/publications.json` (no network at render time). `scripts/fetch_publications.py` builds it from ORCID (0000-0001-8928-4334), Crossref and the Medium RSS feed (@alliesdl); `OVERRIDES` corrects bad ORCID metadata. The page matches the user by surname (`Allies D` / `Allies DL`).
- `assets/` — shared `css/theme.scss` (site colours: deep teal `#0F4C5C` with orange accent `#E36414`; Bootstrap variables plus navbar, banner and heading rules), `css/styles.css` (component styles: cards, timeline, publications), `images/me.jpeg` (About photo, home link preview), `csl/`. The bright orange fails text contrast on white (3.4:1), so use it only for decoration; use `$orange-dark` `#B34A0C` for orange text. No page should set its own `theme:`, so every page shares the palette.
- `scripts/` — helper scripts (not rendered). `data/` (root) — local-only full datasets and `data/archive/`; gitignored. `linkedin/` — local resumes; gitignored, never commit.
- `_extensions/rchaput/acronyms/` — vendored Lua filter. Shared acronyms live in `acronyms.yml`; pages can add their own under `acronyms.keys` (see `tb-bal-cytokines`). Use `{{< acr KEY >}}` in text.

## Rendering caveats

- The navbar and stylesheet links are baked into every page's HTML, so changing `website:` or `format:` in `_quarto.yml` means re-rendering every page.
- Each render with changed theme/layout settings writes a new hashed `docs/site_libs/bootstrap/bootstrap-*.min.css`; delete ones no `docs/**/*.html` references.
- Every page should have a `description`. On the main pages it's hidden visually via `body-classes: hide-description` (CSS in `assets/css/styles.css`) and used only for search and previews.
- **Older projects show progression on purpose.** The February 2026 projects (`covid19-blood-counts`, `tb-global-trends`, `r-python-workflow`) are kept as originally written, so the site shows how the user's work has grown. Each has a "Looking back (November 2026)" callout at the top (`.looking-back`) noting what they'd do differently. Don't polish their analysis, code or writing style; only fix things that look broken (typos, mislabelled elements). `tb-bal-cytokines` is unfinished and carries a "Work in progress" callout (`.in-progress`); remove it when the classifier is added. The About page's "My journey" timeline links each stage to its project; add new projects there too.
- Most projects have no `date` field and `chrx-rnaseq` uses `date: today`, so the `date desc` sort on the projects listing is unreliable.
- Some pages (Databricks pipelines, credit risk) are write-ups only: the code lives in separate GitHub repos linked from the page.
