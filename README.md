# Devon Allies

**Live site: <https://devonallies.github.io/DataAnalysisPortfolio/>**

The personal website and data portfolio of a bioinformatician and computational biologist, currently a Data Analyst at Stellenbosch University. I've worked in biomedical science for over 15 years, including 10 in immunology and tuberculosis research, from the lab bench to clinical study coordination and data pipelines.

The site has four sections:

- **[Projects](https://devonallies.github.io/DataAnalysisPortfolio/projects.html):** data analyses and pipelines in R and Python
- **[Tutorials](https://devonallies.github.io/DataAnalysisPortfolio/tutorials.html):** a practical series on a simulated TB dataset
- **[Publications & Writing](https://devonallies.github.io/DataAnalysisPortfolio/publications.html):** peer-reviewed papers and articles on reproducible science
- **[About](https://devonallies.github.io/DataAnalysisPortfolio/about.html):** background and skills

## Projects

| Project | Year | Focus | Tools | Code |
|---|---|---|---|---|
| [Credit Risk Pipeline on Databricks](https://devonallies.github.io/DataAnalysisPortfolio/projects/credit-risk-pipeline/) | 2026 | Bronze/silver/gold lakehouse and default prediction for a simulated lender | Databricks, PySpark, MLflow, scikit-learn | [repo](https://github.com/DevonAllies/credit-pipeline-databricks) |
| [Databricks Data Pipeline: Simulated BAL Study](https://devonallies.github.io/DataAnalysisPortfolio/projects/bal-databricks-pipeline/) | 2026 | Delta table pipeline and MLflow-tracked models on simulated clinical data | Databricks, PySpark, MLflow | [repo](https://github.com/DevonAllies/MLops_bal_pipeline) |
| [Compartmental TB Diagnostics: A Simulated BAL Cytokine Cohort](https://devonallies.github.io/DataAnalysisPortfolio/projects/tb-bal-cytokines/) | 2026 | Cytokine profiles for TB diagnosis in a simulated BAL cohort | R, gtsummary, factoextra | in this repo |
| [Differential Expression Analysis of Chromosome X RNA-seq Data](https://devonallies.github.io/DataAnalysisPortfolio/projects/chrx-rnaseq/) | 2026 | Sex-based differential expression on chromosome X | Nextflow, HISAT2, StringTie, R (Ballgown) | [pipeline](https://github.com/DevonAllies/rnaseq_pipeline); analysis in this repo |
| [Global Tuberculosis Trends, 2000–2024](https://devonallies.github.io/DataAnalysisPortfolio/projects/tb-global-trends/) | 2026 | Exploratory analysis and forecasting of global TB indicators | Python, pandas, scikit-learn, statsmodels | in this repo |
| [Using R and Python Together in Data Science](https://devonallies.github.io/DataAnalysisPortfolio/projects/r-python-workflow/) | 2026 | A cross-language PCA workflow on gene expression data | R, Python, reticulate, scikit-learn | in this repo |
| [COVID-19 Blood Counts and Patient Outcomes](https://devonallies.github.io/DataAnalysisPortfolio/projects/covid19-blood-counts/) | 2026 | Exploratory analysis of blood count data and patient outcomes | Python, R | in this repo |
| [A Nextflow Pipeline for Whole-Genome Variant Calling](https://devonallies.github.io/DataAnalysisPortfolio/projects/wgs-variant-calling-pipeline/) | 2024 | Modular WGS pipeline from raw reads to joint-called, VQSR-filtered variants on an HPC cluster (BSc Honours) | Nextflow, BWA-MEM, SAMtools, GATK4, PBS | [code](https://github.com/DevonAllies/DataAnalysisPortfolio/tree/main/projects/wgs-variant-calling-pipeline/pipeline) |

On the site, the Projects page lists these newest first and can be filtered by tag (area, method or tool) or searched. The older projects are kept as originally written to show how my work has developed, each with a short "Looking back" note on what I'd do differently today; the About page's "My journey" timeline ties them together.

## Tutorials

A numbered, hands-on series built on one small extract of a simulated TB study (BAL participant metadata and cell counts per visit; every participant is fictional, and the raw files are deliberately messy like real study data). The [Tutorials page](https://devonallies.github.io/DataAnalysisPortfolio/tutorials.html) introduces the series, offers the three data files for download, and lists what you need: R and RStudio, plus Python from Tutorial 2. The data is in [`tutorials/data/`](tutorials/data/).

1. [Importing data into RStudio with R](https://devonallies.github.io/DataAnalysisPortfolio/tutorials/01-import-data-in-r/import-data-in-r.html): CSV and Excel files, multiple sheets, missing-value codes and numbers stored as text.
2. [Using one dataset in both R and Python](https://devonallies.github.io/DataAnalysisPortfolio/tutorials/02-r-and-python/r-and-python-dataframes.html): passing data frames between R and pandas with reticulate, and the conversions that quietly corrupt data.

**Coming next**, using the same data:

3. Cleaning the data: fixing inconsistent categories, duplicates and missing values
4. Statistics: comparing groups and testing associations
5. Machine learning: building and evaluating a predictive model in Python

## Publications & Writing

- **Peer-reviewed papers:** three papers in TB diagnostics, BAL research and a phase 2 vaccine trial (*Scientific Reports*, *BMC Infectious Diseases*, *The Lancet Infectious Diseases*), cited 100+ times. ORCID: [0000-0001-8928-4334](https://orcid.org/0000-0001-8928-4334)
- **Articles:** a series on [Medium](https://medium.com/@alliesdl) about reproducible research and scientific writing with Quarto.

The page is generated from `_data/publications.json`, which a script builds from ORCID, Crossref and the Medium RSS feed (see below).

## How the site is built

The site is a [Quarto](https://quarto.org) website. `quarto render` writes the static site to `docs/`, and GitHub Pages serves it from `docs/` on the `main` branch.

```
_quarto.yml            site configuration (navbar, theme, layout, search/SEO)
index.qmd              home page, with hand-picked featured projects
about.qmd              About page
projects.qmd           project listing: newest first, with tag filters and search
tutorials.qmd          tutorial series page: banner, data downloads, numbered list (by each tutorial's `order` field), roadmap
publications.qmd       Publications & Writing page
projects/<name>/       one folder per project, all with the same layout:
    index.qmd            the page (URL: /projects/<name>/)
    references.bib       its bibliography
    images/              thumbnail and figures
    data/                input data (committed only when small and public)
    pipeline/            (WGS project only) the Nextflow pipeline code
tutorials/             numbered tutorials, their dataset in tutorials/data/ and the series banner in tutorials/images/
assets/                shared files: css/styles.css, images/, csl/ (citation style)
scripts/               helper scripts: refresh publications, rebuild tutorial data
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

# Refresh publications and articles from ORCID, Crossref and Medium
uv run python scripts/fetch_publications.py
quarto render publications.qmd
```

**Which pages render from a fresh clone:** the home, listing, About and Publications pages, both tutorials, and the COVID-19, TB trends, credit risk, BAL Databricks and WGS pipeline projects render from the repo alone. *Using R and Python Together* downloads its data from Kaggle. The chrX RNA-seq and TB BAL cytokine projects read local data that isn't in the repo (`data/` is gitignored), so render pages one at a time with `quarto render projects/<name>/index.qmd` and preview with `quarto preview --no-render`. The rendered versions in `docs/` are always current.

## Contact

- LinkedIn: [devonallies](https://www.linkedin.com/in/devonallies/)
- GitHub: [DevonAllies](https://github.com/DevonAllies)
- ORCID: [0000-0001-8928-4334](https://orcid.org/0000-0001-8928-4334)
- Medium: [@alliesdl](https://medium.com/@alliesdl)
- Discord: [Devon Allies](https://discord.com/users/492592734805164044)
