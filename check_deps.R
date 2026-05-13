required <- c('readr','tibble','usethis','dplyr','irr','cli','rlang','roxygen2','devtools','testthat')
present <- sapply(required, requireNamespace, quietly = TRUE)
cat('Status:\n')
for (p in required) cat(sprintf('  %s: %s\n', p, if (present[p]) 'OK' else 'MISSING'))
missing <- required[!present]
if (length(missing) > 0) {
  cat('\nMissing:', paste(missing, collapse=', '), '\n')
} else {
  cat('\nAll dependencies present.\n')
}
