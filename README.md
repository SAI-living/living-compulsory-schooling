# Does Compulsory School Attendance Affect Schooling and Earnings? (Angrist and Krueger, QJE 1991)

This repository holds the working directory of an automated replication and
extension of the paper, produced by [SAI](https://sai.science) agents. It is
the same file tree a signed-in user can browse in the run's workspace, and it
backs the public living-paper page:

**https://sai.science/econ/living-compulsory-schooling**

## What is here

- `run/` — the replication working directory: `analyze/` (extracted claims),
  `replication/` (the ported and executed codebase), `verify/` (per-claim
  verdicts and the replication score), `report/` (the run's own report), and
  `followup/` (the extension studies: a re-estimation of the paper's main
  claims on data through 2024-2026, and a refit of the paper's model to the
  combined evidence, each with its report, result card, and figures).
- `referee_report.md` — the referee-style report synthesized from the run.
- Some large input data files are omitted; where that happened,
  `run/LARGE_FILES_OMITTED.md` lists them.

## The paper

Angrist, J. D., and Krueger, A. B. (1991). Does Compulsory School Attendance Affect Schooling and Earnings? Quarterly Journal of Economics 106(4), 979-1014.

Replication materials from the Angrist Data Archive. Files under `run/replication/codebase/` derive from those materials
(possibly modified by the replication agent) and remain under their original
authors' terms. Everything else in this repository is generated output from
the SAI pipeline.

## Caveats

Replication scores measure whether claims reproduce under our agents' effort,
not whether authors did anything wrong. Read the referee report's Notes and
the per-claim verdicts in `run/verify/verdicts.json` before quoting any
number.

## Data sources for the extension studies

The extension studies pulled fresh public data on August 23 and 24, 2026. In full:

- U.S. Census Bureau, American Community Survey 1-Year Public Use Microdata Sample (PUMS), person records, 2005 to 2019 and 2021 to 2024, downloaded from census.gov (there is no standard 2020 1-Year PUMS). The living update used all 19 years; the theory update re-extracted nine benchmark years.
- Angrist and Krueger's quarter-of-birth census extracts (NEW7080.dta, the 1970 and 1980 Census samples, archive file dated 2008), from the Angrist Data Archive at MIT Economics, reused for the modern weak-instrument re-analysis.
- Printed values from the published paper (Tables I to III and the enrollment rates for 1960 to 1980) anchor the historical points.
