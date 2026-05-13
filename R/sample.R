#' Draw a stratified sample of chat messages by channel
#'
#' Returns a balanced sample with `n_per_channel` rows from each distinct
#' value of `chat$channel`. Channels with fewer than `n_per_channel` rows
#' contribute all of their rows. Chapter 10 introduces this function as
#' the pedagogically correct alternative to a naive
#' `dplyr::slice_sample(n)`, which produces biased coverage when channels
#' have unequal volume.
#'
#' @param chat A tibble with a `channel` column (typically the output of
#'   [twitch_chat()]).
#' @param n_per_channel Integer number of rows to draw per channel.
#'   Default `100` is calibrated for in-class coding exercises.
#' @param seed Integer RNG seed. Default `20261113` matches the seed used
#'   to build the shipped fixture, so the same call returns the same
#'   sample across runs.
#' @return A tibble with the same columns as `chat`, with up to
#'   `n_per_channel * dplyr::n_distinct(chat$channel)` rows.
#' @examples
#' library(v2v)
#'
#' # Default: 100 messages from each of the 8 focal channels
#' sample_messages(twitch_chat())
#'
#' # Larger per-channel draw for a reliability exercise
#' sample_messages(twitch_chat(), n_per_channel = 250)
#' @export
sample_messages <- function(chat, n_per_channel = 100, seed = 20261113) {
  if (!"channel" %in% names(chat)) {
    cli::cli_abort("{.arg chat} must have a {.field channel} column.")
  }
  if (!is.numeric(n_per_channel) || length(n_per_channel) != 1L || n_per_channel < 1) {
    cli::cli_abort("{.arg n_per_channel} must be a single positive integer.")
  }
  set.seed(seed)
  chat |>
    dplyr::group_by(.data$channel) |>
    dplyr::slice_sample(n = as.integer(n_per_channel)) |>
    dplyr::ungroup()
}
