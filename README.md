# Data Science Portfolio

**Live site: <https://devonallies.github.io/DataAnalysisPortfolio/>**

This is my portfolio of data science and bioinformatics projects. I've worked in immunology and tuberculosis research for over 10 years. The projects here cover public health data, transcriptomics, clinical biomarkers and end-to-end data pipelines, written in R and Python.

## Projects

| Project | Focus | Tools |
|---|---|---|
| [Credit Risk Pipeline on Databricks](https://devonallies.github.io/DataAnalysisPortfolio/projects/credit-lending-pipeline/credit-risk-pipeline.html) | Bronze/silver/gold lakehouse and default prediction for a simulated lender | Databricks, PySpark, MLflow, scikit-learn |
| [Databricks data pipeline: simulated BAL study](https://devonallies.github.io/DataAnalysisPortfolio/projects/databricks_mlflow/bal_pipeline.html) | Delta table pipeline and MLflow-tracked models on simulated clinical data | Databricks, PySpark, MLflow |
| [Differential Expression of Chromosome X RNA-seq Data](https://devonallies.github.io/DataAnalysisPortfolio/projects/rnaseq_analysis/rna_seq_analysis.html) | Sex-based differential expression on chrX | R, Bioconductor (ballgown) |
| [Compartmental TB Diagnostics](https://devonallies.github.io/DataAnalysisPortfolio/projects/tb_diagnosis/tb_diagnostics.html) | Simulated BAL cytokine cohort for TB diagnosis | R, gtsummary, factoextra |
| [TB Trends](https://devonallies.github.io/DataAnalysisPortfolio/projects/tbTrends/TBTrendsEDA.html) | Exploratory analysis of global TB indicators, 2000–2024 | Python, pandas, statsmodels |
| [Covid-19 CBC Dataset](https://devonallies.github.io/DataAnalysisPortfolio/projects/covid/covid19_eda.html) | Exploratory analysis of blood count data and patient outcomes | Python, R |
| [Global Retractions of Scientific Publications](https://devonallies.github.io/DataAnalysisPortfolio/projects/retractions/retraction.html) | Trends in retracted publications | R, SQL (MySQL) |
| [The use of R & Python in data science](https://devonallies.github.io/DataAnalysisPortfolio/projects/R%20%26%20Python/R%20%26%20Python.html) | A cross-language PCA workflow on gene expression data | R, Python, reticulate, scikit-learn |

## Tutorials

Short, practical guides using a small extract of a simulated TB study (BAL cell counts and participant metadata). The data is in [`tutorials/data/`](tutorials/data/).

1. [Importing data into RStudio with R](https://devonallies.github.io/DataAnalysisPortfolio/tutorials/01-import-data-in-r/import-data-in-r.html): CSV and Excel files, multiple sheets, missing-value codes and numbers stored as text.
2. [Using one dataset in both R and Python](https://devonallies.github.io/DataAnalysisPortfolio/tutorials/02-r-and-python/r-and-python-dataframes.html): passing data frames between R and pandas with reticulate, and the conversions that quietly corrupt data.

## How the site is built

The site is a [Quarto](https://quarto.org) website. Each project is a `.qmd` file in `projects/<name>/`, and `quarto render` writes the static site to `docs/`. GitHub Pages serves the site from `docs/` on the `main` branch.

```
_quarto.yml        site configuration (navbar, theme, filters)
index.qmd          home page
projects.qmd       project listing
projects/<name>/   one folder per project: .qmd, references, images
tutorials/         numbered tutorials, plus the small dataset they use in tutorials/data/
docs/              rendered site (committed; served by GitHub Pages)
```

## Running it locally

You need [Quarto](https://quarto.org/docs/get-started/), R and [uv](https://docs.astral.sh/uv/).

```bash
# R packages (pinned in renv.lock)
Rscript -e 'renv::restore()'

# Python packages (pinned in uv.lock), used from R via reticulate
uv sync

# Preview or render
quarto preview
quarto render projects/covid/covid19_eda.qmd   # a single page
```

The tutorials render from a fresh clone, because their data is committed. Most project pages read data files that aren't in the repo (`*.csv` and `data/` are gitignored), and the retractions page queries a MySQL database. So on a fresh clone, most analysis pages won't re-render without the source data. The rendered versions in `docs/` are always current.

## Contact

- LinkedIn: [devonallies](https://www.linkedin.com/in/devonallies/)
- GitHub: [DevonAllies](https://github.com/DevonAllies)
