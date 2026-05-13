#' Convert Twitch millisecond timestamps to POSIXct
#'
#' The `date` column in both [twitch_chat_sample] and [twitch_streams_sample]
#' is stored as bigint Unix epoch in **milliseconds**, not seconds. A naive
#' `as.POSIXct(date, origin = "1970-01-01")` produces timestamps in the year
#' 50,888 and visibly nonsensical plots. This wrapper performs the divide-by-1000
#' step alongside the conversion so the failure mode cannot happen by accident.
#'
#' This is the headline conversion lesson of Chapter 11. The function exists
#' to be teachable, not to hide the arithmetic: see `body(clean_dates)`.
#'
#' @param x Numeric vector of Unix-epoch values in milliseconds.
#' @param tz Time zone for the returned POSIXct. Defaults to `"UTC"` because
#'   the source data is timezone-naive UTC. Pass `"America/Chicago"` (or
#'   another Olson name) to convert.
#' @return A POSIXct vector the same length as `x`.
#' @examples
#' library(v2v)
#'
#' chat <- twitch_chat(channels = "bobross", n = 5)
#' clean_dates(chat$date)
#' clean_dates(chat$date, tz = "America/Chicago")
#'
#' # The wrong way (do NOT do this):
#' as.POSIXct(chat$date, origin = "1970-01-01") # year 50,888
#' @export
clean_dates <- function(x, tz = "UTC") {
  if (!is.numeric(x)) {
    cli::cli_abort("{.arg x} must be a numeric vector of Unix epoch ms.")
  }
  as.POSIXct(x / 1000, origin = "1970-01-01", tz = tz)
}
