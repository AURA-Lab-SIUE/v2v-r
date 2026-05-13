test_that("sample_messages() returns balanced per-channel rows", {
  chat <- twitch_chat()
  s <- sample_messages(chat, n_per_channel = 30)
  counts <- table(s$channel)
  # Channels with fewer than n_per_channel messages will contribute all
  # available rows. Most channels will hit the cap exactly.
  expect_true(all(counts <= 30))
  # At least the 8 anchor channels comfortably exceed 30 messages.
  expect_gte(sum(counts == 30), 8L)
  expect_lte(length(counts), 50L)
})

test_that("sample_messages() is deterministic for a fixed seed", {
  chat <- twitch_chat()
  s1 <- sample_messages(chat, n_per_channel = 20, seed = 42)
  s2 <- sample_messages(chat, n_per_channel = 20, seed = 42)
  expect_equal(s1$id, s2$id)
})

test_that("sample_messages() requires a channel column", {
  expect_error(sample_messages(data.frame(x = 1:5)), "channel")
})
