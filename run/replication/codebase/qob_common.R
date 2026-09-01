# Shared data prep for Angrist-Krueger (1991) QOB replication
# Ports the common variable-construction block of QOB Table IV/V/VI.do
suppressMessages({
  library(haven); library(data.table)
  library(AER); library(ivreg); library(sandwich); library(lmtest); library(car)
})

load_qob <- function(dta = "NEW7080/NEW7080.dta") {
  d <- as.data.table(read_dta(dta))
  setnames(d, "v1",  "AGE");    setnames(d, "v2",  "AGEQ")
  setnames(d, "v4",  "EDUC");   setnames(d, "v5",  "ENOCENT")
  setnames(d, "v6",  "ESOCENT");setnames(d, "v9",  "LWKLYWGE")
  setnames(d, "v10", "MARRIED");setnames(d, "v11", "MIDATL")
  setnames(d, "v12", "MT");     setnames(d, "v13", "NEWENG")
  setnames(d, "v16", "CENSUS"); setnames(d, "v17", "POB")
  setnames(d, "v18", "QOB");    setnames(d, "v19", "RACE")
  setnames(d, "v20", "SMSA");   setnames(d, "v21", "SOATL")
  setnames(d, "v24", "WNOCENT");setnames(d, "v25", "WSOCENT")
  setnames(d, "v27", "YOB")

  # COHORT indicator exactly as in the .do file
  d[, COHORT := 20.29]
  d[YOB <= 39 & YOB >= 30, COHORT := 30.39]
  d[YOB <= 49 & YOB >= 40, COHORT := 40.49]

  # AGEQ transform: subtract 1900 for the 1980 census, then square
  d[CENSUS == 80, AGEQ := AGEQ - 1900]
  d[, AGEQSQ := AGEQ * AGEQ]

  # YOB dummies YR20..YR29 : 1 if born in (1920+k) [4-digit, 1970 census]
  #                          or (30+k) or (40+k) [2-digit, 1980 census]
  for (k in 0:9) {
    yr <- 1920 + k
    col <- paste0("YR", 20 + k)
    d[, (col) := as.integer(YOB == yr | YOB == (30 + k) | YOB == (40 + k))]
  }

  # QOB dummies
  d[, QTR1 := as.integer(QOB == 1)]
  d[, QTR2 := as.integer(QOB == 2)]
  d[, QTR3 := as.integer(QOB == 3)]
  d[, QTR4 := as.integer(QOB == 4)]

  # 30 quarter-by-year interactions (QTR1,QTR2,QTR3 x YR20..YR29)
  for (q in 1:3) {
    for (k in 0:9) {
      inter <- paste0("QTR", q, 20 + k)
      d[, (inter) := get(paste0("QTR", q)) * get(paste0("YR", 20 + k))]
    }
  }
  d[]
}

# Variable-name vectors used across specifications
YR_DUMS   <- paste0("YR", 20:28)                       # YR20..YR28 (YR29 base)
COVARS    <- c("RACE","MARRIED","SMSA","NEWENG","MIDATL","ENOCENT",
               "WNOCENT","SOATL","ESOCENT","WSOCENT","MT")
INSTR     <- c(paste0("QTR1", 20:29), paste0("QTR2", 20:29), paste0("QTR3", 20:29))  # 30

# Fit one OLS spec, return coef/se/t on EDUC
fit_ols <- function(data, extra) {
  rhs <- c("EDUC", extra)
  f <- as.formula(paste("LWKLYWGE ~", paste(rhs, collapse = " + ")))
  m <- lm(f, data = data)
  s <- summary(m)$coefficients["EDUC", ]
  list(estimator = "OLS", coef = unname(s[1]), se = unname(s[2]),
       t = unname(s[3]), nobs = nobs(m))
}

# Fit one TSLS spec with EDUC instrumented by the 30 interactions
fit_tsls <- function(data, extra) {
  exog <- c(extra)                              # included exogenous (besides EDUC)
  rhs  <- paste(c("EDUC", exog), collapse = " + ")
  inst <- paste(c(exog, INSTR), collapse = " + ")
  f <- as.formula(paste("LWKLYWGE ~", rhs, "|", inst))
  m <- ivreg(f, data = data)
  s <- summary(m)$coefficients["EDUC", ]
  # Sargan overid test via diagnostics
  diag <- summary(m, diagnostics = TRUE)$diagnostics
  sargan <- diag["Sargan", ]
  list(estimator = "TSLS", coef = unname(s[1]), se = unname(s[2]),
       t = unname(s[3]), nobs = nobs(m),
       overid_stat = unname(sargan["statistic"]),
       overid_df   = unname(sargan["df1"]),
       overid_p    = unname(sargan["p.value"]))
}

# Column-5 OLS augmented with QTR1-QTR3 + joint F-test that they are zero
qob_ftest <- function(data) {
  extra <- c(COVARS, YR_DUMS, "QTR1", "QTR2", "QTR3")
  f <- as.formula(paste("LWKLYWGE ~ EDUC +", paste(extra, collapse = " + ")))
  m <- lm(f, data = data)
  lh <- linearHypothesis(m, c("QTR1 = 0", "QTR2 = 0", "QTR3 = 0"))
  list(F = lh$F[2], df1 = abs(lh$Df[2]), df2 = m$df.residual,
       p = lh$`Pr(>F)`[2])
}

# Run all 8 columns for a given subsample
run_table <- function(data) {
  specs_ols <- list(
    c1 = YR_DUMS,
    c3 = c(YR_DUMS, "AGEQ", "AGEQSQ"),
    c5 = c(COVARS, YR_DUMS),
    c7 = c(COVARS, YR_DUMS, "AGEQ", "AGEQSQ")
  )
  out <- list()
  out[["col1"]] <- c(fit_ols(data, specs_ols$c1), covset = "YOB dummies")
  out[["col2"]] <- c(fit_tsls(data, YR_DUMS),      covset = "YOB dummies")
  out[["col3"]] <- c(fit_ols(data, specs_ols$c3),  covset = "YOB + AGEQ + AGEQSQ")
  out[["col4"]] <- c(fit_tsls(data, c(YR_DUMS,"AGEQ","AGEQSQ")), covset = "YOB + AGEQ + AGEQSQ")
  out[["col5"]] <- c(fit_ols(data, specs_ols$c5),  covset = "YOB + covariates")
  out[["col6"]] <- c(fit_tsls(data, c(COVARS,YR_DUMS)), covset = "YOB + covariates")
  out[["col7"]] <- c(fit_ols(data, specs_ols$c7),  covset = "YOB + covariates + AGEQ + AGEQSQ")
  out[["col8"]] <- c(fit_tsls(data, c(COVARS,YR_DUMS,"AGEQ","AGEQSQ")), covset = "YOB + covariates + AGEQ + AGEQSQ")
  out
}
