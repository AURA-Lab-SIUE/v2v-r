test_that("clean_dates() converts milliseconds correctly", {
  # 1542578125327 ms = 2018-11-18 21:55:25.327 UTC
  ts <- clean_dates(1542578125327)
  expect_s3_class(ts, "POSIXct")
  expect_equal(format(ts, "%Y-%m-%d %H:%M:%S", tz = "UTC"),
               "2018-11-18 21:55:25")
})

test_that("clean_dates() vectorizes", {
  x <- c(1542578125327, 1543083667610)
  ts <- clean_dates(x)
  expect_length(ts, 2L)
  expect_s3_class(ts, "POSIXct")
})

test_that("clean_dates() respects tz argument", {
  ts_utc <- clean_dates(1542578125327, tz = "UTC")
  ts_ct  <- clean_dates(1542578125327, tz = "America/Chicago")
  expect_equal(as.numeric(ts_utc), as.numeric(ts_ct))  # same instant
  expect_false(format(ts_utc, tz = "UTC") == format(ts_ct, tz = "America/Chicago"))
})

test_that("clean_dates() rejects non-numeric input", {
  expect_error(clean_dates("1542578125327"), "numeric")
})
