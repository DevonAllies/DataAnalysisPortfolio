# Choosing the right statistical test

A two-page guide to choosing a statistical test for biomedical data, with the R function for each test.

**[Download the PDF](choosing-a-statistical-test.pdf)** · also on the website at [devonallies.co.za/guides/choosing-a-statistical-test/choosing-a-statistical-test.pdf](https://devonallies.co.za/guides/choosing-a-statistical-test/choosing-a-statistical-test.pdf)

It covers:

1. Four questions to ask about your data
2. A decision table: t-tests, Wilcoxon tests, ANOVA, Kruskal-Wallis, paired tests, correlation, chi-square and Fisher's exact test, with their R functions
3. Checking the assumptions: independence, normality, equal spread and expected counts
4. Parametric or non-parametric: the trade-offs
5. After the test: reading p-values, effect size and power, multiple comparisons and reporting a result

Worked examples of every test, in R on a simulated TB study, are in [Tutorial 4](https://devonallies.co.za/tutorials.html) of the tutorial series on [devonallies.co.za](https://devonallies.co.za/).

## Sources

- Vu, J. and Harrington, D. (2020) *Introductory Statistics for the Life and Biomedical Sciences*. OpenIntro. <https://www.openintro.org/book/biostat/>
- Çetinkaya-Rundel, M. and Hardin, J. (2024) *Introduction to Modern Statistics*, 2nd edn. OpenIntro. <https://openintrostat.github.io/ims/>
- Childs, D.Z., Hindle, B.J. and Warren, P.H. (2021) *APS 240: Data Analysis and Statistics with R*. <https://dzchilds.github.io/stats-for-bio/>
- Cohen, J. (1988) *Statistical Power Analysis for the Behavioral Sciences*, 2nd edn. Lawrence Erlbaum Associates.
- R Core Team (2026) *R: A Language and Environment for Statistical Computing*. R Foundation for Statistical Computing. <https://www.R-project.org/>

## Building the PDF

The guide is written in [Quarto](https://quarto.org) and rendered with its built-in Typst engine (no LaTeX needed). From the repository root:

```bash
quarto render guides/choosing-a-statistical-test/choosing-a-statistical-test.qmd
```

The PDF is written next to the source and copied into the website's `docs/` folder on the next site render (`project.resources` in `_quarto.yml`). The citation style is the site's shared Harvard (Anglia Ruskin University) style in `assets/csl/`.
