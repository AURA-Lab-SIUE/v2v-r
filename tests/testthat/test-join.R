chat <- tibble::tibble(
  channel = c("a", "a", "b"),
  ts = as.POSIXct(c("2018-11-18 10:05:00", "2018-11-18 10:20:00", "2018-11-18 10:01:00"), tz = "UTC"),
  message = c("hi", "gg", "yo")
)
streams <- tibble::tibble(
  channel = c("a", "a", "b"),
  ts = as.POSIXct(c("2018-11-18 10:00:00", "2018-11-18 10:15:00", "2018-11-18 10:02:00"), tz = "UTC"),
  game = c("Fortnite", "Art", "Music"),
  viewers = c(100L, 200L, 300L)
)

test_that("join_chat_streams() keeps the chat's ts and adds snapshot_ts", {
  out <- suppressMessages(join_chat_streams(chat, streams))
  expect_true(all(c("ts", "snapshot_ts", "game", "viewers") %in% names(out)))
  expect_false(any(c("ts.x", "ts.y") %in% names(out)))
  expect_equal(out$ts, chat$ts[order(chat$channel, chat$ts)])
})

test_that("join_chat_streams() matches the nearest snapshot at or before each message", {
  out <- suppressMessages(join_chat_streams(chat, streams))
  expect_equal(out$game, c("Fortnite", "Art", NA))
  expect_equal(out$viewers, c(100L, 200L, NA))
})

test_that("join_chat_streams() equals the dplyr join it names", {
  out <- suppressMessages(join_chat_streams(chat, streams))
  plain <- dplyr::left_join(
    dplyr::arrange(chat, channel, ts),
    dplyr::arrange(dplyr::rename(streams, snapshot_ts = ts), channel, snapshot_ts),
    by = dplyr::join_by(channel, closest(ts >= snapshot_ts))
  )
  expect_equal(out, plain)
})

test_that("the equivalent-call message can be turned off", {
  withr::local_options(v2v.show_equivalent = FALSE)
  expect_no_message(join_chat_streams(chat, streams))
})
