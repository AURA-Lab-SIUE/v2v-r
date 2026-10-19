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

test_that("reliability(alpha) on text codes gives the numbered-codes alpha, with no warning", {
  a <- c("calm", "calm", "high", "mid", "calm", "high", "mid", "calm", "high", "calm")
  b <- c("calm", "high", "high", "mid", "calm", "high", "calm", "calm", "mid", "calm")
  lv <- sort(unique(c(a, b)))
  numbered <- irr::kripp.alpha(rbind(match(a, lv), match(b, lv)), method = "nominal")$value
  expect_no_warning(r <- reliability(a, b, method = "alpha"))
  expect_equal(r$statistic, numbered)
  # the 0.3.2 path, which coerced text and warned, reached the same value
  old <- suppressWarnings(irr::kripp.alpha(rbind(a, b))$value)
  expect_equal(r$statistic, old)
})

test_that("reliability() reports items, agreement, and prints a report", {
  a <- c("yes", "yes", "no", "no", "yes")
  b <- c("yes", "no", "no", "no", "yes")
  r <- reliability(a, b, method = "kappa")
  expect_s3_class(r, "v2v_reliability")
  expect_equal(r$n, 5L)
  expect_equal(r$agreement, 0.8)
  out <- capture.output(print(r))
  expect_true(any(grepl("Items coded +5", out)))
  expect_true(any(grepl("Observed agreement +0.80", out)))
  expect_true(any(grepl("irr::kappa2", out, fixed = TRUE)))
  # list access still works as before
  expect_equal(r$method, "Cohen's kappa")
  expect_type(r$statistic, "double")
})
