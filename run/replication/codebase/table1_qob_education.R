#!/usr/bin/env Rscript
# Step 6: Table I -- quarter-of-birth effects on educational outcomes (1980 Census)
# MA(+2,-2) detrend of cohort-by-quarter mean series, then regress detrended
# individual outcome on QTR1-QTR3 dummies (QTR4 omitted) + joint F-test.
source("qob_common.R")
library(jsonlite)

d <- load_qob()
d80 <- d[CENSUS == 80]

# Outcome definitions per the paper's footnote 8
outcomes <- list(
  total_education         = list(fn = function(D) D$EDUC,                     subset = function(D) rep(TRUE, nrow(D))),
  high_school_graduate    = list(fn = function(D) as.integer(D$EDUC >= 12),   subset = function(D) rep(TRUE, nrow(D))),
  educ_for_hs_graduates   = list(fn = function(D) D$EDUC,                     subset = function(D) D$EDUC >= 12),
  college_graduate        = list(fn = function(D) as.integer(D$EDUC >= 16),   subset = function(D) rep(TRUE, nrow(D))),
  masters_degree          = list(fn = function(D) as.integer(D$EDUC >= 18),   subset = function(D) rep(TRUE, nrow(D))),
  doctoral_degree         = list(fn = function(D) as.integer(D$EDUC >= 20),   subset = function(D) rep(TRUE, nrow(D)))
)

# MA(+2,-2): trend at t = mean(E[t-2], E[t-1], E[t+1], E[t+2]); NA at the 2 ends
ma2 <- function(E) {
  n <- length(E); out <- rep(NA_real_, n)
  for (t in seq_len(n)) {
    if (t > 2 && t <= n - 2) out[t] <- (E[t-2] + E[t-1] + E[t+1] + E[t+2]) / 4
  }
  out
}

run_block <- function(D, yob_lo, yob_hi, oname, odef) {
  sub <- D[YOB >= yob_lo & YOB <= yob_hi]
  keep <- odef$subset(sub)
  sub <- sub[keep]
  sub[, yval := odef$fn(sub)]

  # chronological index (year, quarter); cohort years are 2-digit here
  sub[, tidx := (YOB - yob_lo) * 4 + QOB]
  cell <- sub[, .(E = mean(yval), .N), by = .(YOB, QOB, tidx)][order(tidx)]
  cell[, trend := ma2(E)]

  cohort_mean <- mean(sub$yval)

  # map trend back to individuals; drop first-2 / last-2 quarter cells (trend NA)
  sub <- merge(sub, cell[, .(tidx, trend)], by = "tidx")
  sub <- sub[!is.na(trend)]
  sub[, detr := yval - trend]

  m <- lm(detr ~ QTR1 + QTR2 + QTR3, data = sub)
  co <- summary(m)$coefficients
  lh <- linearHypothesis(m, c("QTR1 = 0", "QTR2 = 0", "QTR3 = 0"))

  list(
    outcome = oname,
    cohort  = sprintf("19%02d-19%02d", yob_lo, yob_hi),
    n = nrow(sub),
    cohort_mean = cohort_mean,
    coef_I   = list(est = co["QTR1","Estimate"], se = co["QTR1","Std. Error"]),
    coef_II  = list(est = co["QTR2","Estimate"], se = co["QTR2","Std. Error"]),
    coef_III = list(est = co["QTR3","Estimate"], se = co["QTR3","Std. Error"]),
    F = lh$F[2], F_df1 = abs(lh$Df[2]), F_df2 = m$df.residual, F_p = lh$`Pr(>F)`[2]
  )
}

results <- list()
for (oname in names(outcomes)) {
  for (coh in list(c(30,39), c(40,49))) {
    b <- run_block(d80, coh[1], coh[2], oname, outcomes[[oname]])
    key <- paste0(oname, "__", b$cohort)
    results[[key]] <- b
    cat(sprintf("%-22s %s  mean=%.4f  I=%+.5f(%.5f) II=%+.5f(%.5f) III=%+.5f(%.5f)  F=%.3f p=%.3g  N=%d\n",
                oname, b$cohort, b$cohort_mean,
                b$coef_I$est, b$coef_I$se, b$coef_II$est, b$coef_II$se,
                b$coef_III$est, b$coef_III$se, b$F, b$F_p, b$n))
  }
}

write_json(list(table = "I", census = 1980, note = "positive-earnings extract; Table I magnitudes approximate",
                blocks = results),
           "outputs/table1.json", auto_unbox = TRUE, pretty = TRUE, digits = 8)
cat("\nWrote outputs/table1.json\n")
