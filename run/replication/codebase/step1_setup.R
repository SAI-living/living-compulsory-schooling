#!/usr/bin/env Rscript
# Step 1: setup + data sanity cross-tab for Angrist-Krueger (1991) QOB replication
suppressMessages({
  library(haven); library(data.table)
  library(AER); library(ivreg); library(fixest); library(sandwich); library(lmtest)
})
cat("All packages loaded OK\n")

d <- as.data.table(read_dta("NEW7080/NEW7080.dta"))
cat("Raw dim:", dim(d)[1], "x", dim(d)[2], "\n")

# rename per the .do rename block
setnames(d, "v1",  "AGE")
setnames(d, "v2",  "AGEQ")
setnames(d, "v4",  "EDUC")
setnames(d, "v5",  "ENOCENT")
setnames(d, "v6",  "ESOCENT")
setnames(d, "v9",  "LWKLYWGE")
setnames(d, "v10", "MARRIED")
setnames(d, "v11", "MIDATL")
setnames(d, "v12", "MT")
setnames(d, "v13", "NEWENG")
setnames(d, "v16", "CENSUS")
setnames(d, "v17", "POB")       # state-of-birth
setnames(d, "v18", "QOB")
setnames(d, "v19", "RACE")
setnames(d, "v20", "SMSA")
setnames(d, "v21", "SOATL")
setnames(d, "v24", "WNOCENT")
setnames(d, "v25", "WSOCENT")
setnames(d, "v27", "YOB")

# Birth cohort bucket (2-digit for 1980 census, 4-digit for 1970 census)
d[, cohort := fifelse(YOB >= 1920 & YOB <= 1929, "1920-1929",
                fifelse(YOB >= 30 & YOB <= 39, "1930-1939",
                  fifelse(YOB >= 40 & YOB <= 49, "1940-1949", "other")))]

cat("\n=== Cross-tab: CENSUS x birth cohort ===\n")
ct <- d[, .N, by = .(CENSUS, cohort)][order(CENSUS, cohort)]
print(ct)

cat("\n=== Total by CENSUS ===\n")
print(d[, .N, by = CENSUS][order(CENSUS)])

cat("\n=== AGEQ ranges by CENSUS (pre-transform) ===\n")
print(d[, .(minAGEQ = min(AGEQ), maxAGEQ = max(AGEQ)), by = CENSUS])

cat("\n=== QOB distribution ===\n")
print(d[, .N, by = QOB][order(QOB)])

cat("\nStep 1 complete.\n")
