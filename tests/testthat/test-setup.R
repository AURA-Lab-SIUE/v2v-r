test_that("setup() returns a logical carrying a checks table", {
  res <- setup(quiet = TRUE)
  expect_type(res, "logical")
  expect_length(res, 1)
  checks <- attr(res, "checks")
  expect_s3_class(checks, "tbl_df")
  expect_named(checks, c("item", "kind", "ok", "version", "minimum", "detail"))
  expect_true(all(c("R", "tidyverse", "rmarkdown", "remotes", "Quarto CLI", "Git") %in% checks$item))
})

test_that("setup(quiet = TRUE) prints nothing", {
  expect_silent(setup(quiet = TRUE))
})

test_that("setup() agrees with its own checks table", {
  res <- setup(quiet = TRUE)
  checks <- attr(res, "checks")
  expected <- all(checks$ok[checks$kind %in% c("r", "required", "course", "tool")])
  expect_identical(as.logical(res), expected)
})

test_that("setup(course) adds that course's packages", {
  base <- attr(setup(quiet = TRUE), "checks")
  mc501 <- attr(setup(course = "mc501", quiet = TRUE), "checks")
  expect_false(any(base$kind == "course"))
  expect_setequal(mc501$item[mc501$kind == "course"],
                  c("janitor", "effectsize", "lm.beta", "pwr", "renv"))
  expect_error(setup(course = "mc999", quiet = TRUE))
})

test_that("a missing suggested package does not fail setup()", {
  checks <- attr(setup(quiet = TRUE), "checks")
  expect_true(all(checks$kind[checks$item == "quarto"] == "suggested"))
})

test_that("the VS Code packages are reported but never fail setup()", {
  checks <- attr(setup(quiet = TRUE), "checks")
  expect_setequal(checks$item[checks$kind == "vscode"], c("languageserver", "httpgd"))
  # Only r, required, course, and tool rows decide the result
  expected <- all(checks$ok[checks$kind %in% c("r", "required", "course", "tool")])
  expect_identical(as.logical(setup(quiet = TRUE)), expected)
})

test_that("setup() prints a VS Code section", {
  out <- cli::cli_fmt(setup())
  expect_true(any(grepl("VS Code", out)))
})
