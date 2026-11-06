# UniLemons: instructions for any agent working in this repository

Read this before touching code. It records the research design decisions so
that analysis stays tied to the hypotheses and does not drift into
specifications nobody asked for.

## Question and theory
Does a count-based national ranking (NIRF, launched Sept 2015, patents scored
from the first edition) raise patent filing by Indian higher-education
institutions, which institutions respond, and do the extra filings become
patents? Theory (Akerlof lemons; Lamberova 2024 prize in a weakly screened
system): a reputational prize moves supply where the prize is worth most and
screening is weakest; established research institutions should respond less,
fee-funded private institutions more; quality of the marginal filing should
fall where screening is weak.

## Unit of analysis
University (institution), never the applicant name. Notebook 01 collapses
names to institutions (`inst_id`). Say "university" in text and tables.

## Groups
- Treated: all Indian HEIs in the patent universe. Cuts: ownership (central /
  state / private, from UGC list + pattern file + rules), capacity (elite =
  SCImago Institutions Ranking 2010 for India or INI family; non-elite), and
  their interaction.
- Control: domestic firms, startups removed. Government labs / PSUs are a
  placebo group, not a control.
- Samples: full (every ever-filer, extensive + intensive margin) and pre-2015
  filers (first filing before 2015). Report both; say which one a number is from.

## Design rules
- Base year 2014; post = 2015 onward; estimation window 2005-2020. The 2021
  fee cut is future work, not part of this design.
- Outcome in levels (filings per university-year). No PPML, no asinh.
- Estimators, each with its own assumption check: TWFE (event-study leads,
  pass/fail at 5%, Honest DiD relative magnitudes); synthetic DiD (unit and
  time weights); trajectory balancing (mean balancing, balance table, weight
  loadings; kernel balancing not run). Report all three for every hypothesis
  on one coefficient plot and one table with N treated, N control, pre-mean.
- Inference: bootstrap over institutions; clustered SE as a secondary column;
  placebo-in-time and placebo-in-space permutation p-values for the sector design.
- Quality: filings later granted (cohorts to the grant-safe year) with the same
  three estimators and its own pre-trend test.
- Do not add specifications that do not test a stated hypothesis. If a check
  is exploratory, label it so in the heading and the table.

## Files
- 01_clean_classify_panel.Rmd: data to panel. 02_did_nirf.Rmd: all estimation
  except tjbal. 03_tjbal.Rmd: trajectory balancing (slow; writes files 02 reads).
- Raw data: GitHub release data-v1 (data-raw/download.R). Never commit data/.
- Hand decisions live in R/institution_overrides.csv, R/institution_patterns.csv,
  R/ugc_match.csv; change those, not the regexes, when correcting one institution.
