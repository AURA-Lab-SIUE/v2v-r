#' Load Twitch chat messages
#'
#' Returns the bundled [twitch_chat_sample] tibble with optional filtering.
#' The Chapter 9 first-contact pattern is `chat <- v2v::twitch_chat()` with
#' no arguments. Filtering by channel or by random subsample is introduced
#' in Chapter 10.
#'
#' @param channels Optional character vector of channel names. If supplied,
#'   only messages from those channels are returned. Matching is exact and
#'   case-sensitive against the bare channel name (no `#` prefix).
#' @param n Optional integer. If supplied, a uniform random sample of `n`
#'   rows is drawn after the channel filter. Set the random seed with
#'   `set.seed()` before calling for reproducible draws.
#' @return A tibble with the same five columns as [twitch_chat_sample].
#' @examples
#' library(v2v)
#'
#' # Full sample
#' chat <- twitch_chat()
#'
#' # Two channels
#' chat <- twitch_chat(channels = c("bobross", "xqcow"))
#'
#' # Random subsample of 500 from one channel
#' set.seed(42)
#' chat <- twitch_chat(channels = "forsen", n = 500)
#' @export
twitch_chat <- function(channels = NULL, n = NULL) {
  e <- new.env()
  utils::data("twitch_chat_sample", package = "v2v", envir = e)
  result <- tibble::as_tibble(e$twitch_chat_sample)

  if (!is.null(channels)) {
    if (!is.character(channels)) {
      cli::cli_abort("{.arg channels} must be a character vector.")
    }
    result <- dplyr::filter(result, .data$channel %in% channels)
  }
  if (!is.null(n)) {
    if (!is.numeric(n) || length(n) != 1L || n < 1) {
      cli::cli_abort("{.arg n} must be a single positive number.")
    }
    n <- min(as.integer(n), nrow(result))
    result <- dplyr::slice_sample(result, n = n)
  }
  result
}

#' Load Twitch stream snapshots
#'
#' Returns the bundled [twitch_streams_sample] tibble with optional
#' filtering. Same usage shape as [twitch_chat()].
#'
#' @param channels Optional character vector of channel names. Exact,
#'   case-sensitive match against the bare channel name.
#' @param games Optional character vector of game (Twitch category)
#'   names. Exact, case-sensitive match. NULL games are excluded when
#'   `games` is non-NULL.
#' @return A tibble with the same six columns as [twitch_streams_sample].
#' @examples
#' library(v2v)
#'
#' # Full sample
#' streams <- twitch_streams()
#'
#' # Bob Ross's Art-category snapshots
#' streams <- twitch_streams(channels = "bobross", games = "Art")
#'
#' # All non-gaming snapshots across the focal set
#' streams <- twitch_streams(games = c("Just Chatting", "Art"))
#' @export
twitch_streams <- function(channels = NULL, games = NULL) {
  e <- new.env()
  utils::data("twitch_streams_sample", package = "v2v", envir = e)
  result <- tibble::as_tibble(e$twitch_streams_sample)

  if (!is.null(channels)) {
    if (!is.character(channels)) {
      cli::cli_abort("{.arg channels} must be a character vector.")
    }
    result <- dplyr::filter(result, .data$channel %in% channels)
  }
  if (!is.null(games)) {
    if (!is.character(games)) {
      cli::cli_abort("{.arg games} must be a character vector.")
    }
    result <- dplyr::filter(result, .data$game %in% games)
  }
  result
}
