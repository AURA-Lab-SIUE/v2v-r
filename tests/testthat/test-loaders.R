test_that("twitch_chat() returns the shipped fixture by default", {
  chat <- twitch_chat()
  expect_s3_class(chat, "tbl_df")
  # Fixture is ~35K rows; allow a window for future re-samples
  expect_gte(nrow(chat), 30000L)
  expect_lte(nrow(chat), 50000L)
  expect_setequal(
    names(chat),
    c("id", "channel", "sender", "message", "date")
  )
  expect_equal(length(unique(chat$channel)), 50L)
})

test_that("twitch_chat() includes all 8 anchor channels", {
  chat <- twitch_chat()
  anchors <- c("xqcow", "forsen", "sodapoppin", "asmongold",
               "loltyler1", "disguisedtoast", "giantwaffle", "bobross")
  expect_true(all(anchors %in% unique(chat$channel)))
})

test_that("twitch_chat(channels = ...) filters correctly", {
  chat <- twitch_chat(channels = c("bobross", "xqcow"))
  expect_setequal(unique(chat$channel), c("bobross", "xqcow"))
  # Each anchor channel gets up to 1,000 messages
  expect_lte(nrow(chat), 2000L)
  expect_gte(nrow(chat), 100L)
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

test_that("twitch_streams() returns the shipped fixture by default", {
  streams <- twitch_streams()
  expect_s3_class(streams, "tbl_df")
  expect_gte(nrow(streams), 25000L)
  expect_setequal(
    names(streams),
    c("id", "channel", "title", "game", "viewers", "date")
  )
  expect_equal(length(unique(streams$channel)), 50L)
})

test_that("twitch_streams(games = ...) filters and excludes NULL games", {
  art <- twitch_streams(games = "Art")
  expect_true(all(art$game == "Art"))
  expect_true(all(!is.na(art$game)))
})
