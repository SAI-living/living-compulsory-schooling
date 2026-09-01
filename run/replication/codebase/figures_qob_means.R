#!/usr/bin/env Rscript
# Step 7: descriptive season-of-birth series behind Figures I, II, IV, V (1980 Census)
# men born 1930-1949. Cell means of EDUC and LWKLYWGE by (YOB, QOB); MA(+2,-2) detrend.
source("qob_common.R")
library(jsonlite)

d <- load_qob()
d80 <- d[CENSUS == 80 & YOB >= 30 & YOB <= 49]

# (a) Figures I-II: mean EDUC by (YOB, QOB)
educ_cells <- d80[, .(mean_educ = mean(EDUC), .N), by = .(YOB, QOB)][order(YOB, QOB)]

# (b) Figure IV: detrended education series over the full 1930-1949 chronology
educ_ts <- copy(educ_cells)
educ_ts[, tidx := (YOB - 30) * 4 + QOB]
setorder(educ_ts, tidx)
E <- educ_ts$mean_educ; n <- nrow(educ_ts)
trend <- rep(NA_real_, n)
for (t in seq_len(n)) if (t > 2 && t <= n - 2) trend[t] <- (E[t-2]+E[t-1]+E[t+1]+E[t+2])/4
educ_ts[, ma_trend := trend]
educ_ts[, detrended := mean_educ - ma_trend]

# count of birth-years whose 1st-quarter mean lies below the MA(+2,-2) prediction
q1 <- educ_ts[QOB == 1 & !is.na(detrended)]
n_q1_below <- sum(q1$detrended < 0)
n_q1_total <- nrow(q1)
cat(sprintf("Figure IV: %d of %d birth-years have Q1 education below the MA(+2,-2) prediction\n",
            n_q1_below, n_q1_total))

# (c) Figure V: mean LWKLYWGE by (YOB, QOB)
wage_cells <- d80[, .(mean_lwklywge = mean(LWKLYWGE), .N), by = .(YOB, QOB)][order(YOB, QOB)]

# Age-earnings slope: regress cohort-year mean wage on YOB, per cohort group.
# 1940-49 are 30-39 yr olds (rising profile); 1930-39 are 40-49 yr olds (flatter).
wage_yr <- d80[, .(mean_lwklywge = mean(LWKLYWGE)), by = YOB][order(YOB)]
slope_young <- coef(lm(mean_lwklywge ~ YOB, data = wage_yr[YOB >= 40 & YOB <= 49]))[["YOB"]]
slope_old   <- coef(lm(mean_lwklywge ~ YOB, data = wage_yr[YOB >= 30 & YOB <= 39]))[["YOB"]]
cat(sprintf("Age-earnings slope (mean lnwage on YOB): 1940-49 (younger)=%.5f  1930-39 (older)=%.5f\n",
            slope_young, slope_old))

# Do 1st-quarter births earn slightly less than surrounding births? (pooled Q1 vs Q2-4)
w_q1  <- mean(d80[QOB == 1]$LWKLYWGE)
w_q24 <- mean(d80[QOB %in% 2:4]$LWKLYWGE)
cat(sprintf("Mean lnwage: Q1=%.5f  Q2-4=%.5f  (Q1 - Q2-4 = %+.5f)\n", w_q1, w_q24, w_q1 - w_q24))

out <- list(
  census = 1980, cohorts = "1930-1949",
  note = "Shipped extract spans only birth years 1930-1949; the 1950-1959 panels of Figures III/IV (secularly declining cohorts) are NOT reproducible from this extract.",
  fig1_2_mean_educ_by_yob_qob = educ_cells,
  fig4_detrended_education = educ_ts[, .(YOB, QOB, mean_educ, ma_trend, detrended)],
  fig4_q1_below_ma = list(count = n_q1_below, total = n_q1_total),
  fig5_mean_lwklywge_by_yob_qob = wage_cells,
  fig5_age_earnings_slope = list(younger_1940_49 = slope_young, older_1930_39 = slope_old),
  fig5_q1_vs_rest_wage = list(q1 = w_q1, q2_4 = w_q24, diff = w_q1 - w_q24)
)
write_json(out, "outputs/figures.json", auto_unbox = TRUE, pretty = TRUE, digits = 8)
cat("Wrote outputs/figures.json\n")

# Optional PNGs
ok <- tryCatch({
  png("outputs/figure1_2_education.png", width = 1000, height = 600)
  plot(NA, xlim = c(30, 50), ylim = range(educ_cells$mean_educ),
       xlab = "Year of birth", ylab = "Mean years of education",
       main = "Figures I-II: Mean education by year and quarter of birth (1980 Census)")
  cols <- c("black","red","green3","blue")
  for (q in 1:4) {
    cc <- educ_cells[QOB == q]
    lines(cc$YOB + (q-1)/4, cc$mean_educ, col = cols[q], type = "b", pch = as.character(q), cex = 0.7)
  }
  legend("bottomright", legend = paste("Q", 1:4), col = cols, pch = as.character(1:4), lty = 1)
  dev.off()

  png("outputs/figure4_detrended.png", width = 1000, height = 600)
  et <- educ_ts[!is.na(detrended)]
  plot(et$tidx, et$detrended, type = "b", pch = as.character(et$QOB),
       xlab = "Chronological (year-quarter) index", ylab = "Education deviation from MA(+2,-2)",
       main = "Figure IV: Detrended education, birth years 1930-1949")
  abline(h = 0, lty = 2)
  dev.off()

  png("outputs/figure5_wage.png", width = 1000, height = 600)
  plot(NA, xlim = c(30, 50), ylim = range(wage_cells$mean_lwklywge),
       xlab = "Year of birth", ylab = "Mean ln(weekly wage)",
       main = "Figure V: Mean ln weekly wage by year and quarter of birth (1980 Census)")
  for (q in 1:4) {
    cc <- wage_cells[QOB == q]
    lines(cc$YOB + (q-1)/4, cc$mean_lwklywge, col = cols[q], type = "b", pch = as.character(q), cex = 0.7)
  }
  legend("topright", legend = paste("Q", 1:4), col = cols, pch = as.character(1:4), lty = 1)
  dev.off()
  TRUE
}, error = function(e) { cat("PNG generation skipped:", conditionMessage(e), "\n"); FALSE })
if (ok) cat("Wrote figure PNGs to outputs/\n")
