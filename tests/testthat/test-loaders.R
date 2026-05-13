test_that("twitch_chat() returns the full 48,000-row fixture by default", {
  chat <- twitch_chat()
  expect_s3_class(chat, "tbl_df")
  expect_equal(nrow(chat), 48000L)
  expect_setequal(
    names(chat),
    c("id", "channel", "sender", "message", "date")
  )
  expect_equal(length(unique(chat$channel)), 8L)
})

test_that("twitch_chat(channels = ...) filters correctly", {
  chat <- twitch_chat(channels = c("bobross", "xqcow"))
  expect_setequal(unique(chat$channel), c("bobross", "xqcow"))
  expect_equal(nrow(chat), 12000L)   # 6000 per channel
})

test_that("twitch_chat(n = ...) subsamples to the requested size", {
  set.seed(1)
  chat <- twitch_chat(channels = "forsen", n = 100)
  expect_equal(nrow(chat), 100L)
  expect_setequal(unique(chat$channel), "forsen")
})

test_that("twitch_chat() rejects invalid arguments", {
  expect_error(twitch_chat(channels = 1:3), "character vector")
  expect_error(twitch_chat(n = -5), "positive")
  expect_error(twitch_chat(n = c(10, 20)), "single positive")
})

test_that("twitch_streams() returns the full 17,892-row fixture by default", {
  streams <- twitch_streams()
  expect_s3_class(streams, "tbl_df")
  expect_equal(nrow(streams), 17892L)
  expect_setequal(
    names(streams),
    c("id", "channel", "title", "game", "viewers", "date")
  )
})

test_that("twitch_streams(games = ...) filters and excludes NULL games", {
  art <- twitch_streams(games = "Art")
  expect_true(all(art$game == "Art"))
  expect_true(all(!is.na(art$game)))
})
