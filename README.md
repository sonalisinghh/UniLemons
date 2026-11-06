# UniLemons

Difference-in-differences: the effect of the NIRF ranking (launched September
2015; 2014 is the base year) on patent filing by Indian higher-education
institutions, against domestic firms as the control group.

## Data

Raw inputs are three IP India search exports (published applications, granted
applications, granted applications with e-register and status fields; 1960 to
August 2025). They are too large for git and live as gzipped assets on the
GitHub release `data-v1`. `data-raw/download.R` fetches them on first run; the
analysis notebooks source it, so nothing has to be done by hand.

## Run order

1. `analysis/01_clean_classify_panel.Rmd`: stack and deduplicate applications,
   parse dates, normalise applicant names, classify applicants (private,
   elite public, state/central, other education, government lab, firm,
   individual), collapse names to institutions, write the review tables and
   the balanced institution-year panel with the treatment dummies
   (`data/panel_inst_year.rds`).
2. `analysis/02_did_nirf.Rmd`: TWFE in four cuts (all; central / state /
   private; elite / non-elite; interaction), full sample and pre-2015 filers,
   clustered and bootstrap SEs; event study with pass/fail pre-trend tests;
   synthetic DiD and trajectory balancing with a coefficient plot; Honest DiD
   (Rambachan-Roth) for the significant groups; counterfactual plots for
   groups that are significant and pass pre-trends; robustness; placebo-in-time
   and placebo-in-space permutation tests; quality-adjusted counts. Tables in
   `output/tables/`, figures in `output/figures/`. Set `n_boot: 20` in the
   YAML for a quick run; 200 for the paper.
3. `analysis/03_tjbal.Rmd`: trajectory balancing for the same cuts, filings
   and granted, with balance tables and weight loadings. Slow; run it once and
   02 picks up its results (`t8b_tjbal.csv`, `t8d_tjbal_series.csv`) on the
   next knit. Order for a full build: 01, 03, 02.

`CLAUDE.md` records the design rules for anyone (or any agent) editing the code.

## Hand verification

`output/review/` holds the tables to check after every knit of notebook 01.
Corrections go in `R/institution_overrides.csv` (one row per applicant name:
`entity`, `inst_id`, `class_override`, `note`); re-knit and they are applied.
`output/review/validation_sample.csv` is a stratified sample for estimating
the classification error rate (fill in `true_class`).

## Packages

`here`, `data.table`, `stringr`, `lubridate`, `knitr`, `rmarkdown`, `fixest`,
`ggplot2`, `HonestDiD` (CRAN), and from GitHub:
`remotes::install_github("synth-inference/synthdid")` and
`remotes::install_github("xuyiqing/tjbal")`. Notebook 02 skips an estimator
whose package is missing and says so at the top of its output.
