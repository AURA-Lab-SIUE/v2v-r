test_that("sample_messages() returns balanced per-channel rows", {
  chat <- twitch_chat()
  s <- sample_messages(chat, n_per_channel = 50)
  counts <- table(s$channel)
  expect_true(all(counts == 50))
  expect_equal(length(counts), 8L)
})

test_that("sample_messages() is deterministic for a fixed seed", {
  chat <- twitch_chat()
  s1 <- sample_messages(chat, n_per_channel = 30, seed = 42)
  s2 <- sample_messages(chat, n_per_channel = 30, seed = 42)
  expect_equal(s1$id, s2$id)
})

test_that("sample_messages() requires a channel column", {
  expect_error(sample_messages(data.frame(x = 1:5)), "channel")
})
