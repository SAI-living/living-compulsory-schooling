#!/usr/bin/env Rscript
# Step 2: Port of 'QOB Table V.do' — 1970 Census, men born 1920-1929
source("qob_common.R")
library(jsonlite)

d <- load_qob()
sub <- d[COHORT > 30.00 & COHORT < 30.40]                 # keep if COHORT<20.30  -> 1970 census, 1920-29
cat("Table V subsample N =", nrow(sub), "\n")

res <- run_table(sub)
for (nm in names(res)) {
  r <- res[[nm]]
  cat(sprintf("%-5s %-5s coef=%.5f se=%.5f t=%.2f N=%d\n",
              nm, r$estimator, r$coef, r$se, r$t, r$nobs))
}

ft <- qob_ftest(sub)
cat(sprintf("QOB joint F-test (col5 OLS + QTR1-3): F=%.4f df=(%d,%d) p=%.4g\n",
            ft$F, ft$df1, ft$df2, ft$p))

out <- list(table = "V", census = 1980, cohort = "1930-1939",
            n = nrow(sub), columns = res, qob_ftest_col5 = ft)
write_json(out, "outputs/table5.json", auto_unbox = TRUE, pretty = TRUE, digits = 8)
cat("Wrote outputs/table5.json\n")
