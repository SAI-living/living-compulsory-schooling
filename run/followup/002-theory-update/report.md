# Follow-up 002 — Calibrated theory update for AK91

## Question

Angrist & Krueger (1991) is an IV paper whose implicit theory is the Mincer
human-capital earnings function (`ln W = X'β + ρ·E + ε`) plus compulsory-schooling
× quarter-of-birth as the source of exogenous variation in schooling E. Follow-up
001 found that on data through 2024 the OLS return roughly doubled, the QOB first
stage attenuated to unusable (F≈5, empty AR set for the youngest cohort), and the
laws no longer bind (enrollment ≈0.97). This follow-up takes the next step: produce
the **calibrated, updated theory a 2026 version of the paper would carry** — not
"did the claims hold" but "what model best organizes the original findings *plus*
the new evidence, with parameters calibrated to the latest data" — including a
calibrated account of *why* the return rose, a validated model amendment, and the
modern econometric restatement of the design.

## Approach

**Reused (no recompute):** from `followup/001-living-update/results/` — the annual
return series ρ_t (`acs_ols_by_year.csv`), the weak-IV objects F/LIML/AR/Q1
deficits (`lane_b_results.json`), and enrollment shares. From the replication —
`NEW7080.dta` (paper-era schooling distribution) and the col-5 return benchmarks.
I re-read the paper's model section directly (Tables I, III–VI) from the PDF.

**New compute (modest):** nine benchmark ACS 1-year re-extractions
(2005/08/11/14/17/19/21/23/24) computing the **schooling-supply** moments — mean
years, college share, Var(educ), Var(ln wage) — of the *identical* men-40-49 wage
sample 001 used. These moments are not in 001's outputs, so they had to be built;
I reused 001's exact `acs_process.py` sample logic (`acs_moments.py`), and every
year's internal return check reproduces 001's `acs_ols_by_year.csv` to 4 decimals,
so the supply moments sit on a validated sample. Paper-era supply came free from
`NEW7080.dta`.

**Model + validation (`calibrate.py`):** promoted the scalar return ρ to a
time-varying skill price ρ_t governed by one added equation — the Katz–Murphy /
Tinbergen CES relative-demand condition `ρ_t = (1/σ)(D_t − s_t)` (the "race between
education and technology"). Decomposed the observed Δρ into demand (SBTC) vs supply
(education expansion) contributions; ran a held-out out-of-sample test; and did a
price×quantity inequality decomposition. Figure via `plot.py`.

## Results

**The updated model.** Keep AK91's earnings function exactly; make ρ time-varying
via the supply–demand price equation (★). This nests the original (stationary race
⇒ constant ρ) and adds exactly one economic force. The rejected alternative — a
pure composition/selection (heterogeneous-returns) story — fails because the rise
appears in prime-age cross-sections whose schooling was fixed decades earlier and
reverses when supply catches up (details in `theory_update.md` §3).

**Why the return rose then fell (demand vs supply), σ=2 [ESTIMATED accounting]:**

| Era | Δρ observed | Demand push | Supply drag | Reading |
|---|---|---|---|---|
| 1980→2005 | +0.045 | +0.214 | −0.169 | demand winning |
| 2005→2012 | +0.012 | +0.078 | −0.066 | demand ahead; peak |
| 2012→2024 | −0.028 | +0.134 | −0.162 | supply overtakes; ρ falls |
| 1980→2024 | +0.029 | +0.426 | −0.397 | demand narrowly wins net |

Signs and the 2012 turning point are invariant for σ∈{1.5,2,2.5}.

**Out-of-sample held-out validation (train 2005–2014, predict 2015–2024):**

| Model | Held-out RMSE | Predicts |
|---|---|---|
| **Updated supply–demand (★)** | **0.0049** | the observed decline ✓ (2024: 0.090 vs 0.092) |
| Persistence (last value) | 0.0155 | flat 0.115 ✗ |
| Naïve trend extrapolation | 0.0259 | keeps rising to 0.130 ✗ (wrong sign) |
| Original AK91 constant ρ=0.063 | 0.0398 | flat ✗ (worst) |

The updated model, trained on a *rising* premium, predicts the entire post-2014
reversal from realized (predetermined) education supply; the naïve extrapolation
gets the direction wrong. This is the episode the original model cannot explain
(the post-2012 / 2021–2024 compression; 2020 ACS absent — Census COVID gap).

**Modern econometric restatement.** AK's design now yields an *identified set, not
a point*: the weak-IV-robust AR 95% set for the headline 1930–39 cohort is
[−0.002, 0.178] (from 001), with first-stage F≈4.75 — the point estimate lives,
sharp identification does not. A 2026 paper would need an instrument at the
*college* margin (aid/tuition/admission discontinuities, or the state 16→18
dropout-age changes) strong enough to clear F≫10; QOB is exhausted because its
16-year-old compliance population is gone (enrollment 0.97). [PROPOSED design.]

### Comparison to the original replication / 001

| Quantity | Original value | This follow-up | Source file (original) | Note |
|---|---|---|---|---|
| Return ρ, paper-era (1930–39, col-5) | 0.0632 | 0.0632 (anchor) | 001 estimates_by_window.csv / table5.json | reused |
| Return ρ, 2024 (controls) | 0.0923 | 0.0923 (used as ρ_2024) | 001 acs_ols_by_year.csv | reused |
| Return ρ, modern peak | — | 0.120 (2012) | 001 acs_ols_by_year.csv | identified as peak |
| College share, men 40–49, 1980 | — | 0.234 | NEW7080.dta (new extract) | paper-era supply |
| College share, men 40–49, 2024 | — | 0.404 | ACS 2024 (new extract) | modern supply |
| First-stage F (1930–39) | 4.75 | 4.75 (reused) | 001 lane_b_results.json | weak-IV context |
| AR 95% set (1930–39) | [−0.002, 0.178] | reused | 001 lane_b_results.json | now "identified set" |
| σ (CES elasticity) | — | 2.0 [CALIBRATED] | literature; OOS-optimal | new |
| Demand vs supply of Δρ 1980→2024 | — | +0.426 / −0.397 | this study | new decomposition |
| Held-out RMSE, updated model | — | 0.0049 | this study (validation.json) | new validation |

## Deviations & limitations

1. **σ is calibrated, not structurally estimated.** A ~20-point annual series with
   a narrow-sample supply proxy cannot pin the CES elasticity; I fix σ=2 (Katz–
   Murphy/AKK range, also held-out-optimal) and show σ∈{1.5,2.5} leaves every sign
   unchanged. The demand index D is a residual/identity — only its *trend* and the
   decomposition *signs* carry weight, and those are σ-robust. Labeled CALIBRATED
   throughout.
2. **Supply proxy is the men-40-49 sample's own college log-odds,** not the
   economy-wide college-equivalent series of Autor–Katz–Krueger. Internally
   consistent (same population the return is priced on) but not a structural
   aggregate; the exact demand trend is therefore illustrative, the race
   qualitative conclusion robust. Cite-level (PROPOSED) for the aggregate SBTC
   narrative, as the instruction directs.
3. **2020 ACS 1-year PUMS does not exist** (Census COVID gap, per 001); the
   post-peak episode uses 2021–2024. Does not affect the trend.
4. **No new instrument was estimated** — the 2026 design is a PROPOSED design
   sketch, as scoped; QOB is unavailable in post-1980 public microdata.
5. **Modest re-download:** nine ACS years re-fetched (process-and-delete) only for
   the schooling-supply moments absent from 001; no original computation was
   re-run. Return checks confirm sample identity with 001.

## Artifacts

- `results/theory_update.md` — the written "Theory, updated to 2026" section (the main deliverable).
- `results/calibration_table.csv` — paper-era vs 2026 parameters with sources and epistemic labels.
- `results/fig1_skill_price_race.png/.pdf` — flagship 2-panel figure (skill price + race decomposition).
- `results/annual_series.csv`, `results/validation.json`, `results/inequality_decomp.csv` — supporting series and the OOS/decomposition numbers.
- `results/acs_supply_moments.csv` — the nine new benchmark ACS schooling-supply moments.
- `workspace/` — `acs_moments.py`, `calibrate.py`, `plot.py`, `package_moments.json`.
