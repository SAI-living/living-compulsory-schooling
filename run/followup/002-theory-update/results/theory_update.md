# AK91, Theory Updated to 2026

### The human-capital return as a supply–demand skill price, and what a modern quarter-of-birth design would require

*A "living theory" section for Angrist & Krueger (1991), "Does Compulsory School
Attendance Affect Schooling and Earnings?" (QJE 106:4). Built on the completed
veritas replication and on follow-up 001 (`followup/001-living-update`). Every
claim is tagged **[ESTIMATED]** (computed from data), **[CALIBRATED]** (a
parameter set to match a moment), or **[PROPOSED]** (a theoretical suggestion
consistent with the evidence but not itself tested here).*

---

## 1. The original model, briefly

AK91 has no explicit growth model; its theory is the **Mincer human-capital
earnings function** plus a **natural-experiment identification argument**. For a
man *i*,

> **Earnings function:**  ln W_i = X_i′β + **ρ**·E_i + ε_i   (paper Tables IV–VI, col. 5/6)

with E_i years of completed schooling, X_i a vector of controls (year-of-birth
dummies, race, marital status, SMSA, region, and in some columns a quadratic in
age). The single structural parameter of interest is **ρ, the causal return to a
year of schooling.** OLS is feasible but suspect because unobserved ability
enters ε_i and is correlated with E_i (ability bias).

The identifying theory (paper §I) is that **compulsory-attendance laws combined
with school-entry-age rules** make the *quarter of birth* (QOB) an exogenous
shifter of E: children born early in the calendar year reach the legal dropout
age (16) at a lower completed grade and, if constrained, leave with less
schooling. The **first stage** is

> E_i = X_i′π + Σ_c Σ_q δ_cq (QOB_q × YOB_c) + ν_i   (30 excluded instruments)

and the reduced-form "bite" is summarized by the detrended first-quarter
education deficit δ_Q1 (paper Table I) and the Wald ratio (Table III). AK91's
**headline result (verified claim C3):** TSLS ≈ OLS (≈ 0.07–0.10), so the OLS
return has *little* ability bias — schooling is priced, not proxying ability.

The whole edifice rests on two empirical pillars, both of which 001 revisited:
**(P1)** the instrument is relevant (δ_Q1 < 0, laws bind); **(P2)** ρ is a stable
structural constant that OLS recovers.

---

## 2. What the new evidence demands

Follow-up 001 re-estimated the pillars on data through 2024. Three facts break
the original model as literally written (all values read from
`followup/001-living-update/results/` and re-derived here):

1. **ρ is not constant — it roughly doubled and is now falling. [ESTIMATED]**
   The col-5/controls return went 0.0632 (1980 census, 1930–39 cohort) →
   **peak ≈ 0.120 (2012)** → **0.0923 (2024 ACS)**. A constant-ρ Mincer model is
   rejected across eras: it cannot generate either the rise *or* the post-2012
   decline (see §5, held-out test).

2. **The instrument died. [ESTIMATED]** The first-stage Q1 deficit attenuated
   −0.167 → −0.119 → −0.084 across the 1920s/30s/40s cohorts (001), the partial
   F on the 30 QOB×YOB instruments is only **4.6–6.9** (weak by any modern
   standard), and enrollment of 16–17-year-olds is now ≈ 0.97/0.95, so
   compulsory-schooling laws no longer move completed schooling. Pillar P1 is
   gone for cohorts born after ~1949, and QOB has not appeared in public census
   microdata since 1980.

3. **Point identification was always fragile. [ESTIMATED]** Under weak-IV-robust
   inference (001), the Anderson–Rubin 95% set for the headline 1930–39 cohort is
   **[−0.002, 0.178]** — it contains AK's estimate but is very wide — and for the
   1940–49 cohort the AR set is **empty** (the over-identifying restrictions are
   rejected). TSLS ≈ OLS survives as a *point* comparison, not as sharp
   identification.

A 2026 version of the paper therefore needs (a) a model in which the return is a
**time-varying price** with a law of motion that reconciles the 1980 level, the
2012 peak, and the 2024 decline; and (b) an honest restatement of what the QOB
design can and cannot deliver, plus what instrument would replace it.

---

## 3. The updated model — one time-varying parameter, one added equation

**Minimal amendment.** Keep the Mincer earnings function exactly, but promote the
scalar ρ to a **time-varying skill price ρ_t** governed by a single added
relation: the canonical **Katz–Murphy / Tinbergen CES relative-demand condition**
(the "race between education and technology"). With aggregate output a CES
aggregate of skilled and unskilled labor with elasticity of substitution σ, the
marginal-product ratio gives

> **ρ_t = (1/σ)·[ D_t − s_t ]**    …(★)

where **s_t** is (log) relative supply of skilled labor and **D_t** is a
relative-demand index shifted by skill-biased technical change (SBTC). This is
the *smallest* structural change that fits both eras:

- it **nests the original** paper as the special case of a stationary race
  (D_t − s_t constant ⇒ ρ_t constant), which is a good local description of the
  narrow 1970–1980 window AK91 actually used; and
- it turns the *one* new time-varying object (ρ_t) into a function of *one* new
  economic force (the demand–supply gap), rather than an atheoretic trend.

**Why this and not the alternative.** The natural competing explanation is a
**pure composition / selection story** (Card-style heterogeneous returns): the
measured ρ rose only because the *marginal* schooling-getter changed as
enrollment went universal, mechanically reweighting a heterogeneous-MTE average.
I considered and **rejected it as the primary driver** because: (i) the rise
appears in *prime-age (40–49) cross-sections* whose schooling was completed
20–30 years earlier, so contemporaneous selection into schooling cannot move it;
(ii) the movement is a common price shift that tracks the aggregate
college-wage-premium series in the SBTC literature (Katz–Murphy 1992; Autor,
Katz & Krueger 1998; Goldin & Katz 2008; Autor 2019) **[PROPOSED]**; and (iii)
it **reverses after 2012 in lockstep with the education supply catching up**
(§4), which a one-directional selection story does not predict. A residual
composition role is retained as a second-order **[PROPOSED]** amendment (§6).

---

## 4. Why the return rose — and then fell: a calibrated demand/supply decomposition

Equation (★) lets us split the observed change in ρ into a **demand ("trend",
SBTC)** component and a **supply ("composition of the workforce", education
expansion)** component. Because (★) is an identity given σ, define the demand
index residually, D_t ≡ σρ_t + s_t, and decompose Δρ = (1/σ)(ΔD − Δs). I measure
the skill price ρ_t from 001's by-year ACS estimates **[ESTIMATED]**, the
relative supply s_t = log(p_coll/(1−p_coll)) from the college share of the same
men-40-49 sample — 1980 from the original NEW7080 package, 2005–2024 from nine
benchmark ACS re-extractions I ran with 001's exact sample code **[ESTIMATED]** —
and I set **σ = 2.0 [CALIBRATED]** (the Katz–Murphy/AKK consensus 1.5–2.5; also
the value that minimizes the held-out error in §5).

| Era | Δρ (observed) | Demand push +ΔD/σ | Supply drag −Δs/σ | Reading |
|---|---|---|---|---|
| 1980→2005 | **+0.045** | +0.214 | −0.169 | demand winning the race |
| 2005→2012 | **+0.012** | +0.078 | −0.066 | demand still ahead; premium peaks |
| 2012→2024 | **−0.028** | +0.134 | −0.162 | **supply overtakes; premium falls** |
| **1980→2024** | **+0.029** | **+0.426** | **−0.397** | demand narrowly wins on net |

*(σ=2.0; magnitudes scale ~1/σ but every sign — and the 2012 turning point — is
invariant for σ∈{1.5, 2.0, 2.5}. Source: `validation.json`, `annual_series.csv`.)*

The economic content **[ESTIMATED for the accounting; PROPOSED for the labels]**:
demand for skill (SBTC) rose *throughout* 1980–2024, but its **growth
decelerated** while the college share of prime-age men kept climbing (0.234 →
0.404; mean schooling 12.77 → 13.88 years). Demand out-ran supply until ~2012
(ρ rises), then supply caught and passed decelerating demand (ρ falls). This is
exactly the "race" narrative, and it is the reason a naïve extrapolation of the
2000s premium fails (§5). The deceleration of skill demand after ~2000 is itself
documented outside this sample (Beaudry, Green & Sand 2016, "the great reversal
in the demand for skill") **[PROPOSED]**.

A complementary **price × quantity** view (`inequality_decomp.csv`): the share of
male wage variance attributable to schooling, ρ_t²·Var(E_t), rose from **0.093
(1980)** to a peak **0.169 (2011)** and eased to **0.121 (2024)** — it tracks the
*price* ρ, not the *quantity* Var(E) (which actually rose after 2011 as the
degree distribution re-widened). Rising education inequality is a price story,
confirming that the action is in ρ_t, the object we made time-varying.

---

## 5. Validation

**(a) Side-by-side calibration.** Full table in `calibration_table.csv`; the
structural spine:

| Parameter | Paper-era (1980) | 2026 (2024) | Label |
|---|---|---|---|
| Skill price ρ | 0.0632 | 0.0923 (peak 0.120 @2012) | ESTIMATED |
| College share p_coll (men 40–49) | 0.234 | 0.404 | ESTIMATED |
| Relative supply s = log-odds | −1.183 | −0.389 | ESTIMATED |
| Elasticity of substitution σ | 2.0 | 2.0 | CALIBRATED |
| Demand index D = σρ+s | −1.057 | −0.205 | CALIBRATED |
| First-stage Q1 deficit δ_Q1 | −0.119 | ≈0 (enroll 0.97) | ESTIMATED |
| First-stage F (30 instruments) | 4.75 | n/a (no QOB) | ESTIMATED |
| Weak-IV-robust AR 95% set | [−0.002, 0.178] | n/a | ESTIMATED |

**(b) Out-of-sample, held-out test.** Fit the demand trend D_t = γ₀+γ₁t on the
consistent-measurement window **2005–2014 only**, then forecast ρ for **2015–2024**
from (★) using realized supply s_t (which is essentially predetermined — the
40–49 workforce's schooling was fixed decades earlier). Held-out RMSE:

| Model | 2015–2024 RMSE | What it predicts |
|---|---|---|
| **Updated supply–demand (★), σ=2** | **0.0049** | the observed decline to 0.092 ✓ |
| Persistence (ρ stays at 2014 value) | 0.0155 | flat 0.115 ✗ |
| Naïve linear-trend extrapolation | 0.0259 | keeps *rising* to 0.130 ✗ (wrong sign) |
| Original AK91 (constant ρ = 0.063) | 0.0398 | flat 0.063 ✗ (worst) |

The updated model, trained on a *rising* premium and knowing nothing of the
post-2014 turn, **predicts the entire reversal** (2024: forecast 0.090 vs actual
0.092), because it "sees" the education supply continuing to rise. The naïve
trend gets the **direction wrong**; the original constant-return model is worst.
σ=2 is also the held-out-optimal calibration (RMSE 0.0124 at σ=1.5, 0.0054 at
σ=2.5).

**(c) The episode the original cannot explain.** AK91's constant-ρ model implies
a flat premium forever; it cannot rationalize either the 1980→2012 doubling or
the **post-2012 / COVID-era compression**. Because the standard 2020 ACS
1-year file does not exist (Census COVID gap; noted in 001), the visible episode
is **2021–2024**, when the return fell to ≈0.094 and *stayed* there. The
supply–demand model organizes this as supply finally winning the race; the
further flattening in 2021–2022 is consistent with the pandemic **lower-tail wage
compression** that mechanically shrinks the education premium (Autor, Dube &
McGrew 2023, "unexpected compression") **[PROPOSED]** — an amplifier the static
Mincer model has no room for.

---

## 6. The modern econometric restatement of the QOB design

**What AK-style estimates now imply.** Restated with weak-IV-robust inference,
AK91's identification delivers an **identified set, not a point**. For the
headline 1930–39 cohort the AR 95% set is **[−0.002, 0.178] [ESTIMATED]** — wide
enough that "the return is zero" is (barely) not rejected and "the return is
0.15" is comfortably inside. The first-stage F ≈ 4.75 places the design squarely
in the Bound–Jaeger–Baker (1995) weak-instrument regime; the LIML point (0.084,
001) and TSLS point (0.081) agree, but neither is sharply identified. The correct
2026 statement of C3 is: *"quarter of birth is consistent with a return near the
OLS value, but the compulsory-schooling instrument is too weak — and, for the
youngest usable cohort, too contaminated (over-ID rejected) — to certify the
no-ability-bias claim."* The point estimate lives; the inference does not.

**What instrument a 2026 paper would need [PROPOSED].** The QOB margin is dead
because it operated at the *dropout* age (16) where enrollment is now ≈0.97 —
there is almost no compliance population left. A modern design must find a
margin that (i) still binds for a non-trivial share, and (ii) is strong enough to
clear the weak-IV bar the 1991 design failed (target first-stage F ≫ 10, i.e. a
policy that moves schooling by ≥ 0.3–0.5 years for a sizeable group). Candidates,
in rough order of power:

- **College-access discontinuities** — admission-score/GPA thresholds, financial-
  aid formula kinks (Pell/EFC cliffs), tuition-free-community-college adoption,
  or distance-to-nearest-college — which shift *years* at the college margin,
  where the modern premium actually lives. RD or diff-in-diff around policy
  adoption.
- **Staggered state changes in the compulsory dropout age from 16 to 17/18**
  (many states, 2000s–2010s) — a direct descendant of AK91's own instrument, but
  operating where the constraint newly binds.
- **Draft-lottery-style or birth-timing shocks re-purposed** only if a first
  stage can be shown; QOB itself is exhausted.

Each should be reported with weak-IV-robust sets by default. The lesson of the
living update is methodological as much as substantive: *an instrument's economic
relevance decays as the constrained population shrinks*, so a design must be
re-validated, not inherited.

---

## 7. What the update implies going forward

1. **The return to schooling is a macro price, not a personal constant.** Its
   level is set by the education–technology race; forecasting it requires
   forecasting *relative supply* (largely predetermined and hence forecastable)
   and the *demand trend* (the genuinely uncertain part). On current supply
   momentum and decelerating demand, (★) implies the premium **plateaus near
   0.09–0.10** rather than reverting to the 1980 level or resuming its 2000s
   climb — a **[PROPOSED]** projection, not an estimate.
2. **Ability bias is now unfalsifiable on public data**, not shown to be zero.
   AK91's most-cited claim should be quoted with its 2026 caveat.
3. **Compulsory-schooling variation has been spent.** The frontier for causal
   returns has moved to the college and post-secondary margins; that is where the
   next instrument — and the next AK91 — will have to come from.

---

### Provenance & method notes

- **Reused from 001** (`followup/001-living-update/results/`): the annual return
  series ρ_t (`acs_ols_by_year.csv`), the weak-IV objects — F, LIML, AR sets, Q1
  deficits (`lane_b_results.json`), and enrollment shares. Reused from the
  replication: `NEW7080.dta` (paper-era schooling distribution) and the col-5
  benchmarks.
- **New compute (modest):** nine benchmark ACS 1-year re-extractions
  (2005/08/11/14/17/19/21/23/24) for the *schooling-supply* moments (mean years,
  college share, Var(E), Var(ln w)) of the identical men-40-49 wage sample — these
  are not in 001's outputs. Every extraction's internal return check reproduces
  001's `acs_ols_by_year.csv` to the 4th decimal, so the supply moments sit on a
  validated sample. Files: `acs_supply_moments.csv`, `annual_series.csv`,
  `validation.json`, `inequality_decomp.csv`, `calibration_table.csv`,
  `fig1_skill_price_race.png/.pdf`.
- **σ** is calibrated, not estimated: a short annual series with a narrow-sample
  supply proxy cannot pin down the CES elasticity structurally, so I fix σ to the
  literature range and report robustness. The demand-index *level* is a residual
  (identity); only its *trend* and the *decomposition signs* carry economic
  weight, and those are σ-robust.
- **Supply proxy caveat:** s_t is the men-40-49 sample's own college log-odds, an
  internally consistent within-sample supply index, not the economy-wide
  college-equivalent series of Autor–Katz–Krueger; the qualitative race is robust
  to this choice but the exact demand trend is not a structural aggregate.
