# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Quarto website (data science / bioinformatics portfolio) published via GitHub Pages from the committed `docs/` folder (`.nojekyll` present). There is no build system beyond Quarto and no test suite.

## Environments

- **R: renv** (`renv.lock`, `renv/`). `.Rprofile` activates it automatically. Restore with `Rscript -e 'renv::restore()'`. Includes Bioconductor packages (`ballgown`, `genefilter`).
- **Python: uv** (`pyproject.toml`, `uv.lock`). Create the env with `uv sync`; add packages with `uv add <pkg>`.
- `.Rprofile` sets `RETICULATE_PYTHON` to `<project root>/.venv/bin/python`, so `{python}` chunks run under knitr+reticulate use the uv env. Quarto starts R from the project root (so `.Rprofile` loads) even for pages in subfolders.
- Several pages load packages via `lapply(packages, library, character.only = TRUE)`, which renv's dependency scan can't see. When adding a package that way, also add a `library()` line to `_dependencies.R`, then run `renv::snapshot()`.

## Commands

```bash
quarto render                                   # render whole site into docs/
quarto render projects/covid/covid19_eda.qmd    # render a single page
quarto preview                                  # live-reload local server
```

Rendered output in `docs/` is committed and is what gets deployed, so re-render and commit `docs/` alongside any `.qmd` change.

## Structure

- `_quarto.yml` — site config: `output-dir: docs`, cosmo + brand theme, navbar (Home / Projects / Tutorials / About), and the site-wide `acronyms` filter.
- `index.qmd` — home page. Its "Featured projects" grid lists specific project files by hand (`listing.contents`); update it when featuring different work.
- `projects.qmd` — a grid listing over `projects/`, sorted by `date desc`. Each project page's front matter (`title`, `date`, `description`, `image`, `categories`) drives its listing card, so new projects need these set and the `image` file must exist.
- `tutorials.qmd` — listing over a `tutorials/` folder that does not exist yet.
- `projects/<name>/` — one folder per portfolio piece, each self-contained: the `.qmd`, its own `references.bib` and `harvard-anglia-ruskin-university.csl`, and images. Pages often override site format options (theme, toc, `self-contained`, `engine: knitr`, and in `rnaseq_analysis` an extra PDF output).
- `_extensions/rchaput/acronyms/` — vendored Lua filter. Shared acronyms live in `acronyms.yml`; pages can add their own under `acronyms.keys` in front matter (see `tb_diagnosis`). Use `{{< acr KEY >}}` in text.

## Execution notes

- Pages mix R and Python. Python chunks run through `reticulate` under the knitr engine, so R must be available even for mostly-Python pages.
- Most projects have no `date` field and `rnaseq_analysis` uses `date: today`, so the `date desc` sort on the projects listing is unreliable.
- Data files are gitignored (`*.csv`, `data/`), so many pages read inputs that exist only locally (e.g. `data/raw/...csv`, `data/geuvadis_phenodata.csv`). `projects/retractions` connects to a MySQL database via `RMySQL`. A fresh checkout cannot re-render these pages; avoid re-rendering pages you didn't change.
- Some pages (Databricks pipelines, credit risk) are write-ups only: the actual code lives in separate GitHub repos linked from the page.
