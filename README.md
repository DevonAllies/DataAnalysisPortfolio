# Devon Allies

**Live site: <https://devonallies.co.za/>**

The personal website and data portfolio of a bioinformatician and computational biologist, currently a Data Analyst at Stellenbosch University. I've worked in biomedical science for over 15 years, including 10 in immunology and tuberculosis research, from the lab bench to clinical study coordination and data pipelines.

The site has five sections:

- **[Projects](https://devonallies.co.za/projects.html):** data analyses and pipelines in R and Python
- **[Tutorials](https://devonallies.co.za/tutorials.html):** a practical series on a simulated TB dataset
- **[Publications & Writing](https://devonallies.co.za/publications.html):** peer-reviewed papers and articles on reproducible science
- **[About](https://devonallies.co.za/about.html):** background and skills
- **[Contact](https://devonallies.co.za/contact.html):** a contact form, plus other ways to get in touch

## Projects

| Project | Year | Focus | Tools | Code |
|---|---|---|---|---|
| [Credit Risk Pipeline on Databricks](https://devonallies.co.za/projects/credit-risk-pipeline/) | 2026 | Bronze/silver/gold lakehouse and default prediction for a simulated lender | Databricks, PySpark, MLflow, scikit-learn | [repo](https://github.com/DevonAllies/credit-pipeline-databricks) |
| [Databricks Data Pipeline: Simulated BAL Study](https://devonallies.co.za/projects/bal-databricks-pipeline/) | 2026 | Delta table pipeline and MLflow-tracked models on simulated clinical data | Databricks, PySpark, MLflow | [repo](https://github.com/DevonAllies/MLops_bal_pipeline) |
| [Compartmental TB Diagnostics: A Simulated BAL Cytokine Cohort](https://devonallies.co.za/projects/tb-bal-cytokines/) | 2026 | Cytokine profiles for TB diagnosis in a simulated BAL cohort | R, gtsummary, factoextra | in this repo |
| [Differential Expression Analysis of Chromosome X RNA-seq Data](https://devonallies.co.za/projects/chrx-rnaseq/) | 2026 | Sex-based differential expression on chromosome X | Nextflow, HISAT2, StringTie, R (Ballgown) | [pipeline](https://github.com/DevonAllies/rnaseq_pipeline); analysis in this repo |
| [Global Tuberculosis Trends, 2000–2024](https://devonallies.co.za/projects/tb-global-trends/) | 2026 | Exploratory analysis and forecasting of global TB indicators | Python, pandas, scikit-learn, statsmodels | in this repo |
| [Using R and Python Together in Data Science](https://devonallies.co.za/projects/r-python-workflow/) | 2026 | A cross-language PCA workflow on gene expression data | R, Python, reticulate, scikit-learn | in this repo |
| [COVID-19 Blood Counts and Patient Outcomes](https://devonallies.co.za/projects/covid19-blood-counts/) | 2026 | Exploratory analysis of blood count data and patient outcomes | Python, R | in this repo |
| [A Nextflow Pipeline for Whole-Genome Variant Calling](https://devonallies.co.za/projects/wgs-variant-calling-pipeline/) | 2024 | Modular WGS pipeline from raw reads to joint-called, VQSR-filtered variants on an HPC cluster (BSc Honours) | Nextflow, BWA-MEM, SAMtools, GATK4, PBS | [code](https://github.com/DevonAllies/DataAnalysisPortfolio/tree/main/projects/wgs-variant-calling-pipeline/pipeline) |

On the site, the Projects page lists these newest first and can be filtered by tag (area, method or tool) or searched. The older projects are kept as originally written to show how my work has developed, each with a short "Looking back" note on what I'd do differently today; the About page's "My journey" timeline ties them together. Both timelines on the About page (My journey and Education) list the most recent entry first.

## Tutorials

A numbered, hands-on series built on one small extract of a simulated TB study (BAL participant metadata and cell counts per visit; every participant is fictional, and the raw files are deliberately messy like real study data). The [Tutorials page](https://devonallies.co.za/tutorials.html) introduces the series, offers the three data files for download, and lists what you need: R and RStudio, plus Python from Tutorial 2. The data is in [`tutorials/data/`](tutorials/data/).

1. [Importing data into RStudio with R](https://devonallies.co.za/tutorials/01-import-data-in-r/import-data-in-r.html): CSV and Excel files, multiple sheets, missing-value codes and numbers stored as text.
2. [Using one dataset in both R and Python](https://devonallies.co.za/tutorials/02-r-and-python/r-and-python-dataframes.html): passing data frames between R and pandas with reticulate, and the conversions that quietly corrupt data.
3. [Cleaning data in R](https://devonallies.co.za/tutorials/03-clean-data-in-r/clean-data-in-r.html): consistent categories with `tolower()` and `case_when()`, missing-value codes that are really an answer, mixed date formats, impossible measurements, rows flagged for review, and a log of every cleaning decision.

4. [Choosing and running statistical tests in R](https://devonallies.co.za/tutorials/04-statistical-tests-in-r/statistical-tests-in-r.html): what each common test does and when to use it, checking assumptions, t-tests, Wilcoxon tests, ANOVA, Kruskal-Wallis, paired tests, chi-square, Fisher's exact test and correlation, then effect size and power. Each test points to free textbooks for further reading.

The cleaned data is in `tutorials/data/` too: `bal_metadata_clean.csv` (one row per participant) and `bal_cell_counts_clean.csv` (one row per visit), built by `scripts/build_clean_data.R` with the same rules as Tutorial 3. Tutorial 4 onwards starts from these files.

**Guide:** [Choosing the right statistical test](https://devonallies.co.za/guides/choosing-a-statistical-test/choosing-a-statistical-test.pdf), a two-page PDF that goes with Tutorial 4 (source in [`guides/choosing-a-statistical-test/`](guides/choosing-a-statistical-test/)).

**Coming next**, using the same data:

5. Specialised tests: post hoc comparisons, multiple testing and regression, with an interactive [Shinylive](https://posit-dev.github.io/r-shinylive/) app that runs in the browser
6. Machine learning: building and evaluating a predictive model in Python

## Publications & Writing

- **Peer-reviewed papers:** three papers in TB diagnostics, BAL research and a phase 2 vaccine trial (*Scientific Reports*, *BMC Infectious Diseases*, *The Lancet Infectious Diseases*), cited 100+ times. ORCID: [0000-0001-8928-4334](https://orcid.org/0000-0001-8928-4334)
- **On this site:** [Choosing the right statistics for cytokine data](https://devonallies.co.za/writing/choosing-statistics-for-cytokine-data/), on values below the detection limit, skewed concentrations and multiple testing, worked through on simulated plasma data (`tutorials/data/bal_plasma_cytokines.xlsx`, built by `scripts/simulate_plasma_cytokines.py`). Source in [`writing/`](writing/).
- **Articles:** a series on [Medium](https://medium.com/@alliesdl) about reproducible research and scientific writing with Quarto.

The papers and Medium articles come from `_data/publications.json`, which a script builds from ORCID, Crossref and the Medium RSS feed (see below).

## How the site is built

The site is a [Quarto](https://quarto.org) website. `quarto render` writes the static site to `docs/`, and GitHub Pages serves it from `docs/` on the `main` branch at the custom domain [devonallies.co.za](https://devonallies.co.za/). The `CNAME` file in the project root holds the domain; `_quarto.yml` lists it under `project.resources` so every render copies it into `docs/`, and `site-url` sets the address used in the sitemap and link previews. The old address (`devonallies.github.io/DataAnalysisPortfolio/`) redirects to the new one.

```
_quarto.yml            site configuration (navbar, theme, layout, search/SEO)
CNAME                  custom domain for GitHub Pages (copied into docs/)
index.qmd              home page, with hand-picked featured projects
about.qmd              About page
projects.qmd           project listing: newest first, with tag filters and search
tutorials.qmd          tutorial series page: banner, data downloads, numbered list (by each tutorial's `order` field), roadmap
publications.qmd       Publications & Writing page
contact.qmd            Contact page: form sent by FormSubmit (formsubmit.co) to my inbox
projects/<name>/       one folder per project, all with the same layout:
    index.qmd            the page (URL: /projects/<name>/)
    references.bib       its bibliography
    images/              thumbnail and figures
    data/                input data (committed only when small and public)
    pipeline/            (WGS project only) the Nextflow pipeline code
tutorials/             numbered tutorials, their dataset in tutorials/data/ and the series banner in tutorials/images/
assets/                shared files: css/ (theme.scss, theme-dark.scss for dark mode, styles.css),
                         images/ (me.jpeg About photo, og-card.jpg link-preview card), csl/ (citation style)
writing/               articles on this site, one folder each (index.qmd + references.bib); listed on Publications & Writing
guides/                printable PDF guides (Quarto + Typst), e.g. choosing-a-statistical-test/; not website pages
scripts/               helper scripts: refresh publications, rebuild tutorial data, build the cleaned tutorial data,
                         simulate the plasma cytokine data
_data/                 publications.json, built by scripts/fetch_publications.py
docs/                  rendered site (committed; served by GitHub Pages)
```

## Running it locally

You need [Quarto](https://quarto.org/docs/get-started/), R and [uv](https://docs.astral.sh/uv/).

```bash
# R packages (pinned in renv.lock)
Rscript -e 'renv::restore()'

# Python packages (pinned in uv.lock), used from R via reticulate
uv sync

# Preview the already-rendered site, reloading as pages change
quarto preview --no-render

# Render a single page after editing it
quarto render projects/covid19-blood-counts/index.qmd

# Rebuild the cleaned tutorial data after changing the cleaning rules
Rscript scripts/build_clean_data.R

# Rebuild the simulated plasma cytokine data used by the cytokine article
uv run python scripts/simulate_plasma_cytokines.py

# Refresh publications and articles from ORCID, Crossref and Medium
uv run python scripts/fetch_publications.py
quarto render publications.qmd
```

**Which pages render from a fresh clone:** the home, listing, About, Contact and Publications pages, all four tutorials, the PDF guide, the cytokine article, and the COVID-19, TB trends, credit risk, BAL Databricks and WGS pipeline projects render from the repo alone. *Using R and Python Together* downloads its data from Kaggle. The chrX RNA-seq and TB BAL cytokine projects read local data that isn't in the repo (`data/` is gitignored), so render pages one at a time with `quarto render projects/<name>/index.qmd` and preview with `quarto preview --no-render`. The rendered versions in `docs/` are always current.

## Contact

- Contact form: [devonallies.co.za/contact.html](https://devonallies.co.za/contact.html)
- LinkedIn: [devonallies](https://www.linkedin.com/in/devonallies/)
- GitHub: [DevonAllies](https://github.com/DevonAllies)
- ORCID: [0000-0001-8928-4334](https://orcid.org/0000-0001-8928-4334)
- Medium: [@alliesdl](https://medium.com/@alliesdl)
- Discord: [Devon Allies](https://discord.com/users/492592734805164044)
