# Packages that pages load via `lapply(packages, library, character.only = TRUE)`.
# renv's static scan can't see those, so they're declared here for renv::snapshot().
# Never sourced; Quarto ignores files starting with "_".
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)
library(broom)
library(factoextra)
library(corrplot)
library(ggrepel)
library(ballgown)   # Bioconductor
library(genefilter) # Bioconductor
