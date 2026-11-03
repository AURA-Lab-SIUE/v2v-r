test_that("twitch_channels() is one row per channel with the documented shape", {
  ch <- twitch_channels()
  expect_equal(nrow(ch), 50)
  expect_equal(names(ch), c("channel", "main_game", "is_gaming", "channel_type",
                            "median_viewers", "viewer_band"))
  expect_equal(dplyr::n_distinct(ch$channel), 50)
  expect_equal(levels(ch$channel_type), c("gaming", "non-gaming"))
  expect_equal(levels(ch$viewer_band), c("small", "medium", "large"))
  expect_equal(as.integer(table(ch$viewer_band)), c(41L, 7L, 2L))
  expect_equal(sum(is.na(ch$is_gaming)), 2)
})

test_that("twitch_channels() joins onto the chat with the numbers the worksheet names", {
  chat <- twitch_chat()
  joined <- dplyr::left_join(chat, twitch_channels(), by = "channel")
  expect_equal(nrow(joined), nrow(chat))
  counts <- dplyr::count(joined, is_gaming)
  expect_equal(counts$n[is.na(counts$is_gaming)], 501L)
  expect_equal(counts$n[which(counts$is_gaming == FALSE)], 3457L)
  expect_equal(counts$n[which(counts$is_gaming == TRUE)], 31309L)
  bands <- dplyr::count(joined, viewer_band)
  expect_equal(bands$n, c(27766L, 5501L, 2000L))
})

test_that("write_coding_form() writes three columns once and never overwrites", {
  dir <- withr::local_tempdir()
  path <- file.path(dir, "data", "coding-form.csv")
  sample <- tibble::tibble(id = 1:3, channel = "a", message = c("x", "y", "z"),
                           date = 1, sender = "s")
  expect_message(write_coding_form(sample, path), "Wrote 3 messages")
  written <- readr::read_csv(path, show_col_types = FALSE)
  expect_equal(names(written), c("id", "channel", "message"))
  readr::write_csv(tibble::tibble(id = 1, channel = "a", message = "x", reaction_only = 1), path)
  expect_message(write_coding_form(sample, path), "left alone")
  expect_equal(nrow(readr::read_csv(path, show_col_types = FALSE)), 1)
})

test_that("write_coding_form() refuses a table without the three columns", {
  expect_error(write_coding_form(tibble::tibble(id = 1)), "missing columns")
})
