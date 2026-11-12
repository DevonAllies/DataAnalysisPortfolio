# Devon Allies

**Live site: <https://devonallies.github.io/DataAnalysisPortfolio/>**

The personal website and data portfolio of a bioinformatician and computational biologist, currently a Data Analyst at Stellenbosch University. I've worked in immunology and tuberculosis research for over 10 years, from the lab bench to clinical study coordination and data pipelines.

The site has four sections:

- **[Projects](https://devonallies.github.io/DataAnalysisPortfolio/projects.html):** data analyses and pipelines in R and Python
- **[Tutorials](https://devonallies.github.io/DataAnalysisPortfolio/tutorials.html):** a practical series on a simulated TB dataset
- **[Publications & Writing](https://devonallies.github.io/DataAnalysisPortfolio/publications.html):** peer-reviewed papers and articles on reproducible science
- **[About](https://devonallies.github.io/DataAnalysisPortfolio/about.html):** background and skills

## Projects

| Project | Focus | Tools | Code |
|---|---|---|---|
| [Credit Risk Pipeline on Databricks](https://devonallies.github.io/DataAnalysisPortfolio/projects/credit-lending-pipeline/credit-risk-pipeline.html) | Bronze/silver/gold lakehouse and default prediction for a simulated lender | Databricks, PySpark, MLflow, scikit-learn | [repo](https://github.com/DevonAllies/credit-pipeline-databricks) |
| [Databricks data pipeline: simulated BAL study](https://devonallies.github.io/DataAnalysisPortfolio/projects/databricks_mlflow/bal_pipeline.html) | Delta table pipeline and MLflow-tracked models on simulated clinical data | Databricks, PySpark, MLflow | [repo](https://github.com/DevonAllies/MLops_bal_pipeline) |
| [Differential Expression of Chromosome X RNA-seq Data](https://devonallies.github.io/DataAnalysisPortfolio/projects/rnaseq_analysis/rna_seq_analysis.html) | Sex-based differential expression on chrX | R, Bioconductor (ballgown) | in this repo |
| [Compartmental TB Diagnostics](https://devonallies.github.io/DataAnalysisPortfolio/projects/tb_diagnosis/tb_diagnostics.html) | Simulated BAL cytokine cohort for TB diagnosis | R, gtsummary, factoextra | in this repo |
| [TB Trends](https://devonallies.github.io/DataAnalysisPortfolio/projects/tbTrends/TBTrendsEDA.html) | Exploratory analysis of global TB indicators, 2000–2024 | Python, pandas, statsmodels | in this repo |
| [Covid-19 CBC Dataset](https://devonallies.github.io/DataAnalysisPortfolio/projects/covid/covid19_eda.html) | Exploratory analysis of blood count data and patient outcomes | Python, R | in this repo |
| [Global Retractions of Scientific Publications](https://devonallies.github.io/DataAnalysisPortfolio/projects/retractions/retraction.html) | Trends in retracted publications | R, SQL (MySQL) | in this repo |
| [The use of R & Python in data science](https://devonallies.github.io/DataAnalysisPortfolio/projects/R%20%26%20Python/R%20%26%20Python.html) | A cross-language PCA workflow on gene expression data | R, Python, reticulate, scikit-learn | in this repo |

## Tutorials

A series built on one small extract of a simulated TB study (BAL cell counts and participant metadata; every participant is fictional). The data is in [`tutorials/data/`](tutorials/data/) and can be downloaded from each tutorial.

1. [Importing data into RStudio with R](https://devonallies.github.io/DataAnalysisPortfolio/tutorials/01-import-data-in-r/import-data-in-r.html): CSV and Excel files, multiple sheets, missing-value codes and numbers stored as text.
2. [Using one dataset in both R and Python](https://devonallies.github.io/DataAnalysisPortfolio/tutorials/02-r-and-python/r-and-python-dataframes.html): passing data frames between R and pandas with reticulate, and the conversions that quietly corrupt data.

Later tutorials will continue with the same data: cleaning, statistics and machine learning.

## Publications & Writing

- **Peer-reviewed papers:** three papers in TB diagnostics, BAL research and a phase 2 vaccine trial (*Scientific Reports*, *BMC Infectious Diseases*, *The Lancet Infectious Diseases*), cited 100+ times. ORCID: [0000-0001-8928-4334](https://orcid.org/0000-0001-8928-4334)
- **Articles:** a series on [Medium](https://medium.com/@alliesdl) about reproducible research and scientific writing with Quarto.

The page is generated from `_data/publications.json`, which a script builds from ORCID, Crossref and the Medium RSS feed (see below).

## How the site is built

The site is a [Quarto](https://quarto.org) website. `quarto render` writes the static site to `docs/`, and GitHub Pages serves it from `docs/` on the `main` branch.

```
_quarto.yml          site configuration (navbar, theme, layout, filters)
index.qmd            home page, with hand-picked featured projects
projects.qmd         project listing
projects/<name>/     one folder per project: .qmd, references, images
tutorials.qmd        tutorial listing, ordered by each tutorial's `order` field
tutorials/           numbered tutorials, plus their dataset in tutorials/data/
publications.qmd     Publications & Writing page
_data/               publications data and the script that refreshes it
about.qmd            About page
styles.css           site-wide custom styles (cards, home page, publications)
docs/                rendered site (committed; served by GitHub Pages)
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
quarto render projects/covid/covid19_eda.qmd

# Refresh publications and articles from ORCID, Crossref and Medium
uv run python _data/fetch_publications.py
quarto render publications.qmd
```

**Which pages render from a fresh clone:** the home, listing, About and Publications pages, both tutorials, and the Covid-19, TB Trends and Databricks projects all render from the repo alone. *The use of R & Python* downloads its data from Kaggle. Three pages need data that isn't in the repo: the RNA-seq and TB diagnostics projects read local files (`data/` is gitignored), and the retractions project queries a MySQL database. That's why the plain `quarto preview` (which re-renders everything first) fails without them; use `--no-render`. The rendered versions in `docs/` are always current.

## Contact

- LinkedIn: [devonallies](https://www.linkedin.com/in/devonallies/)
- GitHub: [DevonAllies](https://github.com/DevonAllies)
- ORCID: [0000-0001-8928-4334](https://orcid.org/0000-0001-8928-4334)
- Medium: [@alliesdl](https://medium.com/@alliesdl)
- Discord: [Devon Allies](https://discord.com/users/492592734805164044)
