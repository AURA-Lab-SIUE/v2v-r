df <- data.frame(
  y = c(4, 5, 6, 5, 7, 8, 9, 8, 7, 9),
  g = rep(c("a", "b"), each = 5),
  x = c("p", "q", "p", "q", "p", "q", "q", "q", "p", "q")
)

test_that("run_t_test() matches t.test() and returns the group n and SD", {
  r <- suppressMessages(run_t_test(df, value = y, group = g))
  base <- t.test(y ~ g, data = df)
  expect_equal(r$t, unname(base$statistic))
  expect_equal(r$df, unname(base$parameter))
  expect_equal(r$p_value, base$p.value)
  expect_equal(c(r$n_a, r$n_b), c(5L, 5L))
  expect_equal(r$sd_a, sd(df$y[df$g == "a"]))
  expect_equal(r$levels, c("a", "b"))
})

test_that("run_t_test() prints each group's n and the call it wraps", {
  out <- cli::cli_fmt(run_t_test(df, value = y, group = g))
  expect_true(any(grepl("^  a +n = 5, mean = 5.40, SD = 1.14$", out)))
  expect_true(any(grepl("t.test(y ~ g, data = df)", out, fixed = TRUE)))
  expect_true(any(grepl("p-value +=? ?[.<]", out)))
})

test_that("run_chi_square() matches chisq.test() and reports the smallest expected count", {
  r <- suppressWarnings(suppressMessages(run_chi_square(df, x = g, y = x)))
  base <- suppressWarnings(chisq.test(table(df$g, df$x)))
  expect_equal(r$chi_sq, unname(base$statistic))
  expect_equal(r$n, 10L)
  expect_equal(r$min_expected, min(base$expected))
  out <- suppressWarnings(cli::cli_fmt(run_chi_square(df, x = g, y = x)))
  expect_true(any(grepl("below 5", out)))
  expect_true(any(grepl("chisq.test(xtabs(~ g + x, data = df))", out, fixed = TRUE)))
})

test_that("an exact p-value is printed without a leading zero", {
  out <- cli::cli_fmt(run_t_test(df, value = y, group = g))
  p <- t.test(y ~ g, data = df)$p.value
  expect_true(p >= .001)
  expect_true(any(grepl(sub("^0", "", formatC(p, digits = 3, format = "f")), out, fixed = TRUE)))
})
