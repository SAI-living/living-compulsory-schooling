# AK91 living update — findings

**Angrist & Krueger (1991), "Does Compulsory School Attendance Affect Schooling
and Earnings?"** Follow-up on the completed veritas replication. Data: original
NEW7080 package (local) + ACS 1-Year PUMS 2005–2024.

## Three headline sentences

1. **Did C3's "IV ≈ OLS ⇒ no ability bias" conclusion survive modern inference?**
   As *point estimates* yes — on the original data TSLS (0.0669, 0.0806, 0.0393)
   sits next to OLS (0.0701, 0.0632, 0.0520) — but the first-stage partial F on the
   30 QOB×YOB instruments is only **4.6 / 4.8 / 6.9** (textbook weak instruments,
   the Bound–Jaeger–Baker 1995 critique), so the weak-IV-robust Anderson–Rubin 95%
   sets are very wide (**[0.010, 0.122]** for 1920s, **[−0.002, 0.178]** for 1930s)
   and for the **1940–49 cohort the AR set is empty** (over-ID rejected: min AR
   3.11 > crit 1.46) — the conclusion survives as a point estimate but *not* as
   sharp identification by modern standards.
2. **What happened to the OLS benchmark (C4) 1979 → 2024?** It roughly **doubled**:
   from 0.063 (1979 package, col-5 spec) to ≈0.09–0.12 in the ACS (peak ≈0.12
   around 2010–2013, easing to **0.092** with controls / 0.100 bivariate by 2024) —
   the well-known rise in the schooling/skill premium.
3. **Why can the natural experiment not recur?** Enrollment of 16- and 17-year-olds
   is now ≈**97% / 95%** (ACS 2005–2024) and the Table-II DiD law effect faded from
   +4.0pp (1960) → +2.0pp (1970) → +0.5pp (1980) → ~0 today; compulsory-schooling
   laws no longer move completed schooling, and quarter of birth has not appeared in
   public census microdata since the 1980 Census — so the instrument is both
   economically dead and empirically unavailable for cohorts born ≥ 1950.

## Sanity-check hits vs paper / replication

| Quantity | Paper | Replication (outputs/*.json) | This follow-up |
|---|---|---|---|
| 1969 OLS return, col-5 (1920–29) | 0.0701 | 0.07012 (table4.json) | 0.0701 |
| 1979 OLS return, col-5 (1930–39) | 0.0632 | 0.06325 (table5.json) | 0.0632 |
| 1969 TSLS, col-6 | 0.0669 | 0.06685 (table4.json) | 0.0669 |
| 1979 TSLS, col-6 | 0.0806 | 0.08055 (table5.json) | 0.0806 |
| 1940s TSLS, col-6 | 0.0393 | 0.03927 (table6.json) | 0.0393 |
| Q1 educ deficit, 1930s | ≈ −0.124 | −0.1194 (table1.json) | −0.1194 |
| Q1 educ deficit, 1940s | ≈ −0.085 | −0.0844 (table1.json) | −0.0844 |

All targets in §3.1/§4 were hit within tolerance; my re-computed OLS/TSLS match the
replication to the 4th decimal, so the new estimators (first-stage F, LIML, AR)
are built on a validated pipeline.

### New quantities (not in the original replication)

| Cohort | First-stage F | LIML (se) | AR 95% set | Q1 deficit (se) |
|---|---|---|---|---|
| 1920–29 @1970 | 4.55 | 0.0658 (0.0174) | [0.010, 0.122] | −0.167 (0.020) |
| 1930–39 @1980 | 4.75 | 0.0838 (0.0179) | [−0.002, 0.178] | −0.119 (0.017) |
| 1940–49 @1980 | 6.85 | 0.0286 (0.0197) | ∅ (rejected) | −0.084 (0.013) |

The 1920–29 Q1 deficit (−0.167) is a genuine extension backward (the paper's
Table I covers only 1930–49); the deficit attenuates monotonically
−0.167 → −0.119 → −0.084 across the three decades.

## Equivalence caveats (§6)

- **Education variable changed**: census 1970/80 record highest grade
  completed (continuous 0–20); ACS records categorical attainment, mapped to
  years (Jaeger-1997 style). The mapped variable compresses within-category
  variation; the ACS coefficient is a "per mapped year" return.
- **Weekly wage**: census = annual wage/salary ÷ weeks; ACS mirrors this.
  2008–2018 use the 6-category `WKW` interval midpoints (flag); **2005–2007 `WKW`
  is continuous weeks 1–52** (not intervals — see deviation) and 2019+ use `WKWN`.
- **No SMSA control in ACS**. Bridge check on package data (1980, 1930–39):
  dropping SMSA moves the col-5 OLS return from 0.06325 to 0.06584, **+0.0026 <
  0.005** — the ACS "no-SMSA" analog is comparable.
- **Population/earnings concept**: all samples restricted to positive wage and
  positive weeks, which mostly harmonizes census vs ACS.
- **The IV series necessarily stops at the 1940–49 cohort** (no public QOB
  microdata after 1980; enrollment at 16 now ≈97%).

## Deviations

1. **2005–2007 `WKW` is continuous weeks (1–52), not the 6-category interval the
   spec assumed** (that coding began in 2008). Verified in the data; used WKW
   directly for those 3 years. With the wrong (interval) map these years retained
   only ~2,200 records; corrected they retain ~181,000 and slot smoothly into the
   series.
2. **2020 ACS 1-Year PUMS does not exist** — the Census Bureau did not release a
   standard 2020 1-year file (COVID data-collection disruption; only experimental
   estimates). The modern series is 2005–2019 + 2021–2024 (2024 is the "now"
   endpoint, as required).
3. **REGION absent in 2005–2006** (only state FIPS `ST`); Census region derived
   from `ST`.
4. **Panel B x-axis** is year-of-birth (1917–1958), not the shared calendar-year
   axis, because the first-stage deficit is a function of birth cohort (1920–1949),
   which predates the 1960–2025 calendar axis used by Panels A and C.
5. **CPS ASEC cross-check (§3.3) not run** — optional; Lanes A/B/C completed in full.
6. LIML, first-stage F, and Anderson–Rubin sets were computed by hand (closed-form
   FWL residualization), validated by exact agreement of OLS/TSLS with the
   replication.
