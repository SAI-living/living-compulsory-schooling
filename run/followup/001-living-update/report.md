# AK91 living-version follow-up

**Paper.** Angrist & Krueger (1991), *Does Compulsory School Attendance Affect
Schooling and Earnings?* (QJE 106:4). The paper uses quarter of birth (QOB) —
via school-entry-age rules × compulsory-attendance laws — as an instrument for
years of schooling in a log-weekly-wage equation for US men, on 1970/1980 Census
microdata (cohorts born 1920–1949). Its headline finding (C3): TSLS ≈ OLS, so
OLS return to schooling has little ability bias.

## Question

Produce an honest "living version" of AK91 along three fully-automatable lanes:
**(A)** trace the OLS return to schooling for men 40–49 — the paper's C4
benchmark — from 1969/1979 (package data) to 2024 (ACS PUMS); **(B)** re-estimate
the IV claims per birth cohort on the *original* data with modern weak-IV-robust
inference (first-stage F, LIML, Anderson–Rubin sets) plus the first-stage
attenuation path; **(C)** show the death of the instrument — enrollment of
16–17-year-olds from the paper's Table II extended with the ACS — which explains
*why* Lane B cannot continue past the 1949 birth cohort. QOB is not in public
census microdata after 1980, so no modern-cohort IV is possible; that constraint
was accepted up-front.

## Approach

**Reused from the replication** (`/workspace/eval/replication/codebase/`):
- The ported data-prep (`qob_common.R`) rename map and cohort/dummy construction
  — I re-implemented the identical variable construction in Python from the same
  `QOB Table V.do` block and verified it reproduces the replication numbers.
- The already-computed package estimates: Lane A's two anchor OLS points and Lane
  B's col-6 TSLS come straight from the replication's `outputs/table4.json`,
  `table5.json`, `table6.json` (I recomputed them as a cross-check; they agree to
  the 4th decimal).
- The Table-I detrended-Q1 method from `table1_qob_education.R` (for the
  attenuation path).

**New work**
- **Lane A (`acs_process.py`)**: downloaded ACS 1-Year PUMS for every year
  2005–2024 (~500–630 MB each), stream-processed both CSV members reading only
  needed columns, built years-of-schooling from `SCHL`, weekly wage from
  `WAGP·ADJ/weeks`, and ran PWGTP-weighted HC1 OLS for two specs (i: educ+age;
  ii: +black+married+region). Downloads were process-and-deleted for disk hygiene.
- **Lane B (`lane_b.py`)**: on the three NEW7080 subsamples, FWL-residualized on
  the included exogenous regressors once per cohort, then computed OLS (HC1),
  2SLS, LIML (k-class, κ = smallest eigenvalue), the first-stage partial F on the
  30 excluded instruments, and an Anderson–Rubin 95% confidence set by grid
  inversion. Plus the detrended MA(+2,−2) Q1 education deficit for all three
  decades (incl. the 1920s, a backward extension).
- **Lane C**: from the same ACS files, weighted enrollment share of 16- and
  17-year-olds (`SCH∈{2,3}`), combined with the printed Table II age-16 rates.
- Outputs: `results/estimates_by_window.csv` (74 rows, tidy), `results/ak91_living.png/.pdf`
  (3-panel flagship figure), `results/findings.md`.

## Results

### Lane A — the OLS return to schooling, 1969 → 2024
The two package anchor points reproduce the paper exactly: **1969 = 0.0701**
(target 0.0701), **1979 = 0.0632** (target 0.0632). The ACS series then rises to
a peak of ≈0.12 around 2010–2013 and eases back, ending at **0.092 (controls) /
0.100 (bivariate) in 2024**. The OLS return to schooling has **roughly doubled**
since 1979 (0.063 → ~0.09–0.12) — the familiar rise in the schooling premium.
(2005–2007 returns 0.108–0.111 after the WKW fix below; 2020 is absent — see
deviations.)

### Lane B — modern re-analysis of the IV (original data)

| Cohort | OLS | TSLS | LIML | first-stage F | AR 95% set | Q1 educ deficit |
|---|---|---|---|---|---|---|
| 1920–29 @1970 | 0.0701 | 0.0669 | 0.0658 | **4.55** | [0.010, 0.122] | −0.167 (0.020) |
| 1930–39 @1980 | 0.0632 | 0.0806 | 0.0838 | **4.75** | [−0.002, 0.178] | −0.119 (0.017) |
| 1940–49 @1980 | 0.0520 | 0.0393 | 0.0286 | **6.85** | **∅ (rejected)** | −0.084 (0.013) |

OLS and TSLS match the replication to 4 decimals (validated pipeline). The new
result is the **inference**: first-stage F ≈ 5 confirms these are weak
instruments, so the AR confidence sets are very wide, and for the 1940–49 cohort
the AR set is **empty even over [−0.5, 0.8]** (min AR 3.11 > crit 1.46) — the 30
instruments jointly reject the model, matching the replication's note that QOB is
significant in that cohort's *wage* equation. The Q1 education deficit attenuates
monotonically across decades (−0.167 → −0.119 → −0.084), extending the paper's
Table I one decade earlier.

### Lane C — why the experiment cannot recur
Age-16 enrollment rose from 0.876–0.910 (Table II, 1960) to 0.942–0.958 (1970) to
0.950–0.962 (1980) to **≈0.965–0.972 (ACS 2005–2024)**; age-17 ≈0.93–0.95. The
Table-II DiD law effect fades +4.0pp → +2.0pp → +0.5pp → ~0. Enrollment is now
near-universal, so compulsory-schooling laws no longer move completed schooling.

### Comparison to the original replication

| Quantity | Original (replication file) | Follow-up | Note |
|---|---|---|---|
| 1969 OLS return (col-5) | 0.07012 (`table4.json`) | 0.0701 | reused as Lane A 1969 anchor |
| 1979 OLS return (col-5) | 0.06325 (`table5.json`) | 0.0632 | reused as Lane A 1979 anchor |
| 1969 TSLS (col-6) | 0.06685 (`table4.json`) | 0.0669 | recomputed, matches |
| 1979 TSLS (col-6) | 0.08055 (`table5.json`) | 0.0806 | recomputed, matches |
| 1940s TSLS (col-6) | 0.03927 (`table6.json`) | 0.0393 | recomputed, matches |
| Q1 deficit 1930s | −0.11942 (`table1.json`) | −0.119 | recomputed, matches |
| Q1 deficit 1940s | −0.08441 (`table1.json`) | −0.084 | recomputed, matches |
| first-stage F | — (not computed) | 4.55/4.75/6.85 | **new** (weak-IV diagnostic) |
| AR 95% set | — | see table | **new** (weak-IV-robust) |
| Modern OLS return 2024 | — | 0.092 / 0.100 | **new** (ACS extension) |

## Deviations & limitations

1. **2005–2007 `WKW` is continuous weeks (1–52), not the 6-category interval the
   spec assumed** (interval coding began 2008). Verified empirically; used WKW
   directly for those years. This is the one substantive correction to the
   instruction — with the wrong map those years kept ~2,200 records; corrected,
   ~181,000, and they slot smoothly into the series.
2. **2020 ACS 1-Year PUMS does not exist** (Census released no standard 2020
   1-year file due to COVID collection disruption; only experimental estimates).
   The modern grid is 2005–2019 + 2021–2024 — full annual coverage except the
   unavoidable 2020 gap; 2024 (the "now" endpoint) is included.
3. **REGION absent in 2005–2006** (only `ST`); derived Census region from state
   FIPS.
4. **Panel B** uses a year-of-birth x-axis rather than the shared calendar-year
   axis, because first-stage deficits are inherently a function of birth cohort
   (1920–1949, i.e. before the 1960–2025 axis of Panels A/C).
5. **CPS ASEC cross-check (§3.3) not run** — explicitly optional; Lanes A/B/C are
   complete. LIML/AR/first-stage-F were hand-rolled (closed-form FWL), validated
   by exact OLS/TSLS agreement with the replication.
6. ACS points are placed at survey year Y; ACS wage income covers the "past 12
   months," so earnings straddle Y−1/Y. This does not affect the qualitative
   trend. The education-attainment→years mapping compresses within-category
   variation (a "per mapped year" return), and there is no SMSA control in the
   ACS (bridge check: omitting SMSA shifts the 1979 package return by only
   +0.0026 < 0.005).

**Bottom line.** The paper's OLS benchmark (C4) is stable in construction and has
roughly doubled in level since 1979; its headline IV≈OLS finding (C3) survives as
a point estimate but not as sharp inference once weak-IV-robust methods are
applied (F≈5; empty AR set for the youngest cohort); and the instrument itself
(C1/C2) is now economically dead (near-universal enrollment) and empirically
unavailable (no public QOB after 1980) — so AK91 cannot be extended to newer
cohorts, only re-examined on its original data.
