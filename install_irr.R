install.packages('irr', repos = 'https://cloud.r-project.org', quiet = TRUE)
if (requireNamespace('irr', quietly = TRUE)) {
  cat('irr installed successfully.\n')
} else {
  cat('FAILED to install irr.\n')
  quit(status = 1)
}
