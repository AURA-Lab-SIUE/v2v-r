# Build pipeline: fixtures -> roxygen -> install -> tests
# Run from the v2v package root.

setwd("E:/Projects/SIM-Lab-SIUE/v2v")

cat("=== 1. Building .rda fixtures from CSVs\n")
source("data-raw/build_fixtures.R")

cat("\n=== 2. Regenerating man/ pages and NAMESPACE via roxygen2\n")
roxygen2::roxygenise(load_code = roxygen2::load_source)

cat("\n=== 3. devtools::check() (catches NAMESPACE issues, missing docs, R CMD check NOTEs)\n")
result <- devtools::check(
  document = FALSE,         # already done above
  quiet = FALSE,
  cran = FALSE,             # skip CRAN-only stricter checks
  error_on = "error",
  check_dir = tempdir()
)

cat("\n=== Check result summary\n")
cat("Errors:  ", length(result$errors),   "\n")
cat("Warnings:", length(result$warnings), "\n")
cat("Notes:   ", length(result$notes),    "\n")
if (length(result$errors) > 0)   {cat("\nERRORS:\n");   print(result$errors)}
if (length(result$warnings) > 0) {cat("\nWARNINGS:\n"); print(result$warnings)}
if (length(result$notes) > 0)    {cat("\nNOTES:\n");    print(result$notes)}
