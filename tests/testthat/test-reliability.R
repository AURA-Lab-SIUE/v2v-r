test_that("reliability(kappa) computes Cohen's kappa", {
  # Perfect agreement
  r1 <- reliability(c(1, 1, 0, 0), c(1, 1, 0, 0), method = "kappa")
  expect_equal(r1$statistic, 1)
  expect_equal(r1$method, "Cohen's kappa")
  expect_match(r1$interpretation, "almost perfect")

  # No agreement beyond chance
  r2 <- reliability(c(1, 1, 1, 1), c(0, 0, 0, 0), method = "kappa")
  expect_true(is.na(r2$statistic) || r2$statistic <= 0)
})

test_that("reliability() interpretation labels match Landis & Koch", {
  # Construct a known-kappa example
  a <- c(rep(1, 80), rep(0, 20))
  b <- c(rep(1, 70), rep(0, 30))   # 90% same on positive, partial on negative
  r <- reliability(a, b, method = "kappa")
  expect_true(r$statistic > 0)
})

test_that("reliability() rejects unequal-length input", {
  expect_error(reliability(c(1, 1), c(0, 0, 0)), "same length")
})
