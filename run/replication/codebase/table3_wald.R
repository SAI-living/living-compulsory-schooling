#!/usr/bin/env Rscript
# Step 5: Table III Wald estimates of the return to education
# Panel A: 1970 Census men born 1920-1929; Panel B: 1980 Census men born 1930-1939
source("qob_common.R")
library(jsonlite)

d <- load_qob()

# Mean difference and SE between two independent groups (unequal variances)
grp_diff <- function(x, g1, g0) {
  m1 <- mean(x[g1]); m0 <- mean(x[g0])
  n1 <- sum(g1);     n0 <- sum(g0)
  v1 <- var(x[g1]);  v0 <- var(x[g0])
  se <- sqrt(v1 / n1 + v0 / n0)
  list(m1 = m1, m0 = m0, diff = m1 - m0, se = se, n1 = n1, n0 = n0)
}

panel <- function(sub) {
  q1  <- sub$QOB == 1          # 1st quarter
  q24 <- sub$QOB %in% 2:4      # 2nd/3rd/4th quarters

  wage <- grp_diff(sub$LWKLYWGE, q1, q24)
  educ <- grp_diff(sub$EDUC,     q1, q24)

  # Wald estimate = (diff in ln wage) / (diff in education)
  wald <- wage$diff / educ$diff
  # SE of Wald ratio: numerator SE / |denominator diff| (denominator treated as first-stage);
  # this is the standard AK Wald SE = SE(reduced-form wage diff) / (education diff)
  wald_se <- wage$se / abs(educ$diff)

  # OLS bivariate return of LWKLYWGE on EDUC (classical SE)
  m <- lm(LWKLYWGE ~ EDUC, data = sub)
  ols <- summary(m)$coefficients["EDUC", ]

  list(
    n = nrow(sub),
    ln_wage = list(q1 = wage$m1, q24 = wage$m0, diff = wage$diff, se = wage$se),
    education = list(q1 = educ$m1, q24 = educ$m0, diff = educ$diff, se = educ$se),
    wald_return = list(estimate = wald, se = wald_se),
    ols_return  = list(estimate = unname(ols[1]), se = unname(ols[2])),
    n_q1 = wage$n1, n_q24 = wage$n0
  )
}

A <- panel(d[COHORT < 20.30])                        # 1970, 1920-29
B <- panel(d[COHORT > 30.00 & COHORT < 30.40])       # 1980, 1930-39

pr <- function(nm, p) {
  cat(sprintf("\n== Panel %s (N=%d) ==\n", nm, p$n))
  cat(sprintf("ln wage:  Q1=%.4f  Q2-4=%.4f  diff=%.5f (se %.5f)\n",
              p$ln_wage$q1, p$ln_wage$q24, p$ln_wage$diff, p$ln_wage$se))
  cat(sprintf("educ:     Q1=%.4f  Q2-4=%.4f  diff=%.5f (se %.5f)\n",
              p$education$q1, p$education$q24, p$education$diff, p$education$se))
  cat(sprintf("Wald return=%.5f (se %.5f)   OLS return=%.5f (se %.5f)\n",
              p$wald_return$estimate, p$wald_return$se, p$ols_return$estimate, p$ols_return$se))
}
pr("A", A); pr("B", B)

write_json(list(table = "III", panelA = c(census = 1970, cohort = "1920-1929", A),
                panelB = c(census = 1980, cohort = "1930-1939", B)),
           "outputs/table3.json", auto_unbox = TRUE, pretty = TRUE, digits = 8)
cat("\nWrote outputs/table3.json\n")
