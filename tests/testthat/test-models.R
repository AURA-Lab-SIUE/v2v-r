set.seed(1)
df <- data.frame(
  y = c(rnorm(20, 10), rnorm(20, 12), rnorm(20, 15)),
  g = rep(c("a", "b", "c"), each = 20),
  x = 1:60
)

test_that("run_anova() matches aov() and eta squared from the sums of squares", {
  r <- suppressMessages(run_anova(df, value = y, group = g))
  fit <- aov(y ~ g, data = df)
  tab <- summary(fit)[[1]]
  expect_equal(r$f, tab[["F value"]][1])
  expect_equal(r$p_value, tab[["Pr(>F)"]][1])
  expect_equal(r$eta_squared, tab[["Sum Sq"]][1] / sum(tab[["Sum Sq"]]))
  expect_equal(r$n, 60L)
  expect_equal(nrow(r$tukey), 3)
  expect_equal(r$groups$n, c(20L, 20L, 20L))
  out <- cli::cli_fmt(run_anova(df, value = y, group = g))
  expect_true(any(grepl("fit <- aov(y ~ g, data = df)", out, fixed = TRUE)))
  expect_true(any(grepl("Tukey", out)))
})

test_that("run_anova() refuses fewer than three groups", {
  expect_error(run_anova(df[df$g != "c", ], value = y, group = g), "three or more")
})

test_that("run_regression() matches lm() and reports the standardized slope", {
  r <- suppressMessages(run_regression(df, outcome = y, predictor = x))
  fit <- lm(y ~ x, data = df)
  expect_equal(r$slope, unname(coef(fit)["x"]))
  expect_equal(r$r_squared, summary(fit)$r.squared)
  expect_equal(r$beta, unname(coef(fit)["x"]) * sd(df$x) / sd(df$y))
  expect_equal(r$n, 60L)
  out <- cli::cli_fmt(run_regression(df, outcome = y, predictor = x))
  expect_true(any(grepl("fit <- lm(y ~ x, data = df)", out, fixed = TRUE)))
  expect_true(any(grepl("R-squared", out)))
})

test_that("run_chi_square() prints expected counts and standardized residuals", {
  d2 <- data.frame(a = rep(c("p", "q"), each = 30), b = rep(c("u", "v", "u"), 20))
  r <- suppressWarnings(suppressMessages(run_chi_square(d2, x = a, y = b)))
  base <- suppressWarnings(chisq.test(table(d2$a, d2$b)))
  expect_equal(unname(r$expected), unname(base$expected))
  expect_equal(unname(r$stdres), unname(base$stdres))
  out <- suppressWarnings(cli::cli_fmt(run_chi_square(d2, x = a, y = b)))
  expect_true(any(grepl("Expected counts", out)))
  expect_true(any(grepl("Standardized residuals", out)))
})

test_that("crosstab() lays the counts out as a grid and the shares add to 1 per row", {
  d2 <- data.frame(a = rep(c("p", "q"), each = 30), b = rep(c("u", "v", "u"), 20))
  d2$b[1] <- NA
  r <- suppressMessages(crosstab(d2, a, b))
  expect_equal(r$n, 59L)
  expect_equal(names(r$counts), c("a", "u", "v"))
  expect_equal(sum(r$counts$u) + sum(r$counts$v), 59)
  expect_equal(rowSums(r$shares[, -1]), c(1, 1), ignore_attr = TRUE)
})

test_that("flag_outliers() returns the rows beyond the 1.5 IQR whiskers, per group", {
  d3 <- data.frame(g = rep(c("a", "b"), each = 10), v = c(1:9, 100, 1:9, 5))
  out <- suppressMessages(flag_outliers(d3, v, g))
  expect_equal(nrow(out), 1)
  expect_equal(out$v, 100)
  expect_equal(out$side, "high")
  expect_equal(names(out)[1:3], c("g", "v", "side"))
  all_one <- suppressMessages(flag_outliers(d3, v))
  expect_equal(all_one$v, 100)
})

test_that("twitch_viewers_over_time() has six categories and six-hour blocks", {
  v <- twitch_viewers_over_time()
  expect_equal(names(v), c("six_hour", "category", "total_viewers"))
  expect_equal(nlevels(v$category), 6)
  expect_true("Other" %in% levels(v$category))
  expect_true(all(as.integer(format(v$six_hour, "%H", tz = "UTC")) %% 6 == 0))
})
