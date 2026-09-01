# Living-version followup spec: Angrist & Krueger (1991), "Does Compulsory School Attendance Affect Schooling and Earnings?" (QJE 106:4)

You are the followup agent. You are seeded from the completed veritas replication of AK91 and
you keep its ported codebase and the original data package at:

    PKG = /path/to/package   (in this workspace: the AK91 package dir containing
                              NEW7080/NEW7080.dta, QOB/QOB_raw.txt, asciiqob/asciiqob.txt,
                              "Descriptive Statistics QOB.txt", QOB Table IV/V/VI.do)

Locate it with `find / -name NEW7080.dta 2>/dev/null` if the path differs. Everything below was
**verified on 2026-08-23** with live probes (HTTP codes and a working end-to-end sample regression);
exact URLs and fallbacks are given per step and in `sources.json`.

---

## 0. The paper's main claims (what we are updating)

The paper uses quarter of birth (QOB) — via school-entry-age rules interacted with compulsory
attendance laws — as an instrument for years of schooling in a log-weekly-wage equation for
US men. Samples: 1970 Census 1% (men born 1920-29, aged 40-49, n=247,199) and 1980 Census 5%
(men born 1930-39, aged 40-49, n=329,509; and born 1940-49, aged 30-39, n=486,926).

- **C1 (first stage).** Men born in Q1 complete ~0.1 fewer years of schooling than men born in Q4
  (Table I: Q1 effect −0.124 (se 0.017) for the 1930-39 cohort, −0.085 (0.012) for 1940-49;
  detrended with an MA(+2,−2) of surrounding cohorts; effect visibly attenuating for later cohorts).
- **C2 (laws bind).** DiD on enrollment at exact age 16 by state school-leaving age
  (Table II: +4.0 pp effect of a leaving-age-17/18 law in 1960, +2.0 in 1970, +0.5 in 1980 —
  already fading inside the paper).
- **C3 (headline IV).** TSLS return to a year of schooling using QOB×year-of-birth dummies as
  instruments ≈ the OLS return ⇒ little ability bias in OLS. Headline numbers:
  1970 Census (born 1920-29): OLS 0.0701 (0.0004), TSLS 0.0669 (0.0151) [Table IV col 5-6];
  1980 Census (born 1930-39): OLS 0.0632 (0.0003), TSLS 0.0806 (0.0164) [Table V col 5-6];
  with QOB×state instruments: TSLS 0.083 (0.010) vs OLS 0.063 [Table VII col 6];
  Wald (Q1 vs rest): 0.0715 (1970), 0.1020 (1980) [Table III].
- **C4 (OLS return itself).** The OLS return to schooling for prime-age men, ~0.063-0.080 in
  1969/1979 earnings, is the benchmark the IV is compared to.

## 1. Feasibility verdict — read this before coding

**The QOB instrument cannot be extended past cohorts born 1930-49.** Quarter of birth was last
released in public-use census microdata in the 1980 Census; the ACS and post-1990 PUMS contain
no birth quarter/month, and our IPUMS access is pending anyway. Moreover the instrument is dead
economically: enrollment of 16-year-olds was ~95% in 1980 (Table II) and is ~98-99% today, so
compulsory-schooling laws no longer move completed schooling. Do NOT try to find modern QOB
microdata; it does not exist publicly.

The honest living version therefore has three lanes:

- **Lane A (flagship, fully automatable):** trace the OLS return to schooling for men 40-49 —
  the paper's C4 benchmark and the quantity its "no ability bias" conclusion certifies —
  from 1969 to 2024: package data for 1969/1979, ACS PUMS 2005-2024 annually.
- **Lane B (fully automatable, local data only):** the IV claims re-estimated per birth cohort
  on the original package data with modern weak-IV-robust inference (first-stage F, LIML,
  Anderson-Rubin confidence sets) — the post-Bound-Jaeger-Baker (1995) verdict on C3, and the
  first-stage attenuation path (C1) across the 1920s/1930s/1940s cohorts.
- **Lane C (fully automatable):** the death of the instrument (C2): enrollment of 16-17-year-olds
  from the paper's Table II (1960/1970/1980) extended with ACS 2005-2024 — this explains *why*
  Lane B cannot continue past 1949 birth cohorts.

## 2. Data sources (all verified 2026-08-23)

| # | Source | URL pattern | Verified |
|---|--------|-------------|----------|
| S1 | AK91 package (local) | `$PKG/NEW7080/NEW7080.dta` — 1,063,634 obs, 27 vars `v1..v27` | local; obs count = 247,199+329,509+486,926 exactly the three paper samples |
| S2 | ACS 1-Year PUMS person files, 2005-2024 | 2005-2006: `https://www2.census.gov/programs-surveys/acs/data/pums/{Y}/csv_pus.zip` ; 2007-2024: `https://www2.census.gov/programs-surveys/acs/data/pums/{Y}/1-Year/csv_pus.zip` | HTTP 200 for 2005 (505 MB), 2006, 2007, 2010, 2015 (623 MB), 2023, 2024 (603 MB); RI test file downloaded, parsed, regression run (see §3.2) |
| S3 | CPS ASEC public-use CSV, 2019-2025 (optional cross-check) | `https://www2.census.gov/programs-surveys/cps/datasets/{Y}/march/asecpub{yy}csv.zip` | HTTP 200 for 2019-2025 (~147 MB each); 2018 and earlier = 404 in this format |
| S4 | FRED CPI (context only) | keyless: `https://fred.stlouisfed.org/graph/fredgraph.csv?id=CPIAUCSL` (or API with `$FRED_API_KEY`) | HTTP 200, data through 2026-07 |
| S5 | Census 1990 5% PUMS (optional stretch) | `https://www2.census.gov/census_1990/1990_PUMS_A/PUMSAX{ST}.zip` + `DOCUMENT/` layouts | dir listing verified |
| S6 | Census 2000 1% PUMS (optional stretch) | `https://www2.census.gov/census_2000/datasets/PUMS/OnePercent/{StateName}/revisedpums1_{fips}.txt` + `0_README` | dir listing verified (Alabama shown) |

**IMPORTANT — Census API is NOT usable:** `api.census.gov` now 302-redirects keyless requests to
`missing_key.html` (verified). We have no CENSUS_API_KEY. Use the bulk file URLs above only.
IPUMS is also unavailable (application pending). If S2 ever 404s, re-derive the path from the
directory listing `https://www2.census.gov/programs-surveys/acs/data/pums/` (it exists and lists
all vintages).

## 3. Lane A — flagship: the OLS return to schooling, 1969 → 2024

### 3.1 Original points (package data, no download)

Read `$PKG/NEW7080/NEW7080.dta` (Stata 114 format; pandas.read_stata handles it). Variables are
named `v1..v27`; rename per `Descriptive Statistics QOB.txt` / the Table V .do file:

    v1 AGE, v2 AGEQ, v4 EDUC, v5 ENOCENT, v6 ESOCENT, v9 LWKLYWGE, v10 MARRIED,
    v11 MIDATL, v12 MT, v13 NEWENG, v16 CENSUS, v18 QOB, v19 RACE, v20 SMSA,
    v21 SOATL, v24 WNOCENT, v25 WSOCENT, v27 YOB

(The remaining v's are the other region dummies etc. — consult `QOB Table V.do` in the package,
which contains the full rename block; use it verbatim.) Subsamples: `CENSUS==70 & YOB in 1920-29`
(earnings year 1969) and `CENSUS==80 & YOB in 1930-39` (earnings year 1979). Note YOB may be coded
as 2-digit (20-29, 30-39) — inspect and handle.

For each subsample estimate the paper's column-(5) spec:

    LWKLYWGE ~ EDUC + YOB dummies + RACE + SMSA + MARRIED + 8 region dummies

Record OLS coefficient on EDUC + robust SE. Targets to hit (sanity check, ±0.002):
**0.0701** (1970 sample), **0.0632** (1980 sample). If you are off by more, your rename mapping
is wrong — fix before proceeding.

### 3.2 Modern points (ACS 2005-2024, annual)

Proven end-to-end on the 2023 Rhode Island file (csv_pri.zip, 2.1 MB → psam_p44.csv,
n=447 wage-earning men 40-49, weighted OLS return = 0.092 (se 0.035)) — the same code scales
to the national files.

For each year Y in 2005..2024:
1. Download `csv_pus.zip` (path rule in S2; ~500-630 MB each, ~11 GB total). Stream-process:
   open with `zipfile`, iterate the CSV members (2005-2016: `ss{yy}pusa.csv`/`ss{yy}pusb.csv`;
   2017+: `psam_pusa.csv`/`psam_pusb.csv` — just take all `*.csv` members), read in chunks with
   only the needed columns, then DELETE the zip before the next year (disk hygiene).
2. Columns: `AGEP, SEX, SCHL, WAGP, PWGTP, SCH, MAR, RAC1P, REGION`, plus
   weeks worked: `WKW` (2005-2018, intervals) or `WKWN` (2019+, continuous), plus
   income adjustment: `ADJUST` (2005-2007) or `ADJINC` (2008+). Both verified: 2005 RI file has
   `ADJUST`+`WKW`; 2023 file has `ADJINC`+`WKWN`.
3. Sample: men (SEX==1), AGEP 40-49, positive wage income and weeks.
4. Construct:
   - `educ` (years of schooling) from SCHL.
     2008+ coding (1-24): {1:0, 2:0, 3:1, 4:2, 5:3, 6:4, 7:5, 8:6, 9:7, 10:8, 11:9, 12:10,
     13:11, 14:11, 15:11, 16:12, 17:12, 18:12.5, 19:13, 20:14, 21:16, 22:18, 23:18, 24:20}
     (14/15 = 12th grade no diploma / GED handled as shown; 16=diploma, 17=GED).
     2005-2007 coding (1-16): {1:0, 2:2.5, 3:5.5, 4:7.5, 5:9, 6:10, 7:11, 8:11.5, 9:12,
     10:12.5, 11:13, 12:14, 13:16, 14:18, 15:18, 16:20}.
   - `wkly_wage = WAGP * (ADJINC or ADJUST)/1e6 / weeks`, where weeks = WKWN if present, else
     WKW interval midpoints {1:51, 2:48.5, 3:43.5, 4:33, 5:20, 6:7}.
   - `lww = log(wkly_wage)`.
5. Estimate, weighted by PWGTP with HC1 robust SEs, two specs:
   - (i) `lww ~ educ + age dummies` (analog of paper col 1/3);
   - (ii) `lww ~ educ + age dummies + black (RAC1P==2) + married (MAR==1) + REGION dummies`
     (analog of col 5; note: no SMSA control exists in ACS PUMS — caveat, see §6).
6. Append one row per year × spec to the tidy CSV (§7).

Budget guard: the 20 national downloads + chunked parsing is the big cost (~2-4 h). If you are
running out of time or disk, fall back to odd years 2005, 2007, ..., 2023 plus 2024; the figure
tolerates a 2-year grid. Never silently drop 2024 — it is the "now" endpoint.

### 3.3 Optional cross-check lane (CPS ASEC 2019-2025)

Only if Lane A/B/C are done and time remains. For survey year Y in 2019..2025 download S3, use
`pppub{yy}.csv`: men A_AGE 40-49, `educ` from A_HGA {31:0, 32:2.5, 33:5.5, 34:7.5, 35:9, 36:10,
37:11, 38:11.5, 39:12, 40:13, 41:14, 42:14, 43:16, 44:18, 45:18, 46:20}, weekly wage =
WSAL_VAL/WKSWORK (positive both), weight MARSUPWT. Earnings year = Y−1. Same regressions; plot
as hollow markers. If the zip's member names differ, list the archive and match `pppub*`.

## 4. Lane B — modern re-analysis of the IV on the original samples

On the three NEW7080 subsamples (1920-29@1970, 1930-39@1980, 1940-49@1980):

1. **TSLS, paper col-(6) spec:** instruments = 30 QOB×YOB interaction dummies (Q1-Q3 × 10 birth
   years); second stage controls = YOB dummies + RACE + SMSA + MARRIED + 8 region dummies.
   Use `linearmodels.iv.IV2SLS` (pip-install if missing) or hand-rolled 2SLS. Targets:
   0.0669 (0.0151), 0.0806 (0.0164), 0.0393 (0.0145) respectively.
2. **First-stage diagnostics:** report the first-stage partial F on the 30 excluded instruments
   for each cohort (expect roughly single-digit-to-low-double-digit F — the famous weak-IV example).
3. **Weak-IV-robust inference:** LIML estimate and an Anderson-Rubin 95% confidence set for the
   education coefficient (grid-invert AR over rho in [-0.1, 0.3] step 0.002; or use the python
   `ivmodels` package / R `ivmodel` if installable — R 4.x is in the container).
4. **First-stage attenuation path (C1):** per birth year 1920-1949, the detrended Q1 effect on
   EDUC (Table I spec: subtract the MA(+2,−2) across adjacent quarter cohorts, regress on Q1-Q3
   dummies, keep the Q1 coefficient), then aggregate per decade cohort. Expect ≈ −0.124 (1930s),
   ≈ −0.085 (1940s).

Compute note: 30-490k rows × ~45 regressors is trivial; the AR grid is ~200 TSLS-style solves
per cohort — precompute annihilator matrices once per cohort.

## 5. Lane C — why the experiment cannot recur (C2 proxy)

From the ACS files already downloaded in Lane A (no extra download), for each year 2005-2024
compute the weighted share of 16-year-olds (and separately 17-year-olds) enrolled in school
(`SCH in {2,3}`), both sexes. Combine with the paper's printed Table II enrollment rates for
April 1960/1970/1980 (age-16 rows: 87.6/91.0 in 1960 by law regime, 94.2/95.8 in 1970,
95.0/96.2 in 1980 — plot the pooled implication ~0.876-0.91, 0.942-0.958, 0.95-0.962 as ranges)
into a 1960-2024 series. Caveat in the note: Table II is enrollment at an exact-birthday cutoff
in census week; ACS `SCH` is enrollment in the last 3 months for single year of age — close but
not identical constructs.

## 6. Equivalence caveats (state these in the findings note)

- **Education variable changed:** 1970/1980 censuses record highest grade attended/completed
  (continuous 0-20); ACS/CPS record categorical attainment since 1992 ⇒ we map categories to
  years (Jaeger-1997-style, §3.2/3.3). The mapped variable compresses within-category variation;
  the OLS coefficient is a "per mapped year" return.
- **Weekly wage:** census = annual wage-and-salary income / weeks worked last year; ACS mirrors
  this (WKW intervals 2005-2018 use midpoints — flag those years); CPS uses WSAL_VAL/WKSWORK.
- **No SMSA control in ACS** (PUMS has no metro flag) — the col-(5) analog omits it; on package
  data, verify dropping SMSA moves the 1979 OLS coefficient by <0.005 and report that as the
  bridge check.
- **Population concept:** census 1970/1980 includes institutionalized men differently than ACS;
  restrict all samples to positive earnings, which mostly harmonizes.
- **The IV series necessarily stops at the 1940-49 cohort** — public microdata with quarter of
  birth ends with the 1980 census, and enrollment at 16 is now ~98%+ so the law-driven variation
  is gone. The living-version claim about C3 is therefore: "with modern (weak-IV-robust)
  inference, do the original IV conclusions survive on the original data, and did the OLS
  benchmark they certified stay stable afterward?"

## 7. Expected outputs (write all to an `outputs/` dir)

1. `estimates_by_window.csv` — tidy, one row per estimate:
   `lane, claim, estimator (ols|tsls|liml|wald|first_stage_q1|enrollment16), spec (bivariate|controls),
   data_source, cohort_or_earnings_year, n, coef, se, ci_lo, ci_hi, ar_ci_lo, ar_ci_hi (blank unless AR),
   first_stage_F (blank unless IV), notes`.
2. `ak91_living.png` (+ `.pdf`) — the flagship figure, three stacked panels sharing an x-axis
   of calendar year 1960-2025:
   - **Panel A (main):** OLS return to schooling for men 40-49 (y-axis, 0-0.16) vs earnings year;
     filled circles + 95% CI band for ACS 2005-2024 (spec ii; spec i as a light line); the two
     package points at 1969 and 1979; AK's original OLS marked with labeled horizontal ticks and
     the original sample period (1969 & 1979 points) shaded; overlay the TSLS point estimates
     at 1969/1979 as open diamonds with their 95% CIs and, as whisker extensions, the AR sets.
     One-line annotation: "IV ≈ OLS in 1969/79; OLS return roughly doubled since."
     (Expect the modern OLS return ≈ 0.10-0.13 — the well-known rise in the college premium.)
   - **Panel B:** first-stage detrended Q1 education deficit by birth decade (1920s, 30s, 40s)
     with CIs, x-positioned at decade midpoints, annotated "no public QOB data for cohorts
     born ≥1950" with a greyed region.
   - **Panel C:** share of 16-year-olds enrolled, 1960-2024 (paper Table II points + ACS series),
     annotated with the DiD law effects from Table II (+4.0pp 1960 → +0.5pp 1980) to show the
     instrument's bite going to zero.
3. `findings.md` — ≤2 pages: the three headline sentences (did C3's conclusion survive modern
   inference; what happened to the OLS benchmark 1979→2024; why the natural experiment is
   unrepeatable), the caveats of §6, and a table of the §3.1/§4 sanity-check hits vs paper values.

## 8. Failure playbook

- ACS zip 404 → re-derive path from the parent directory listing; person files also exist
  per-state (`csv_p{st}.zip`) — worst case, loop all 51 small files for that year.
- Download too slow/disk too small → odd-years fallback (§3.2); process-and-delete each zip.
- `pandas.read_stata` chokes on NEW7080.dta → fall back to `QOB/QOB_raw.txt` (whitespace-
  delimited, same v1..v27 columns, 1930-49 cohorts only; 1970-census point then comes from
  `asciiqob` no — asciiqob is 1930-39 only; instead parse the .dta with pyreadstat or R haven,
  both available/installable in the container).
- `linearmodels`/`ivmodels` pip install fails → 2SLS and AR by hand (closed forms; you have the
  formulas in any IV notes) or R `AER`/`ivmodel`.
- CPS lane failing → drop it; it is optional.
- FRED unreachable keyless → use `https://api.stlouisfed.org/fred/series/observations?series_id=CPIAUCSL&api_key=$FRED_API_KEY&file_type=json`.
- If a target number in §3.1/§4 cannot be matched within tolerance, do not tune the modern lane
  to compensate — document the discrepancy in findings.md and proceed.