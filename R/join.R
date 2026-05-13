#' Join chat messages to the nearest-prior stream snapshot
#'
#' For each row in `chat`, finds the most recent row in `streams` for the
#' same channel where `streams$ts <= chat$ts` and attaches the snapshot's
#' `game`, `viewers`, and (when present) `is_gaming` columns. This is the
#' canonical Chapter 11 join pattern: students see that chat messages live
#' in continuous time but stream metadata lives in periodic snapshots, and
#' an asof join is the bridge.
#'
#' Both inputs must have a `ts` column of class POSIXct. Build it with
#' [clean_dates()] before calling.
#'
#' @param chat A tibble with at least `channel` and `ts` columns (and any
#'   other columns you want preserved through the join). Typically the
#'   output of [twitch_chat()] with `ts <- clean_dates(date)` applied.
#' @param streams A tibble with at least `channel`, `ts`, `game`, and
#'   `viewers` columns. An `is_gaming` column is included in the result if
#'   present in `streams`.
#' @return A tibble with the same rows as `chat`, plus the matched stream
#'   columns (`game`, `viewers`, and optionally `is_gaming`). Chat rows
#'   with no prior stream snapshot for their channel will have NA in the
#'   stream columns; on the focal corpus this is 0.06% of rows.
#' @examples
#' library(v2v)
#' library(dplyr)
#'
#' chat <- twitch_chat() |>
#'   mutate(ts = clean_dates(date))
#' streams <- twitch_streams() |>
#'   mutate(ts = clean_dates(date))
#'
#' joined <- join_chat_streams(chat, streams)
#' joined |> count(game, sort = TRUE) |> head(10)
#' @export
join_chat_streams <- function(chat, streams) {
  required_chat <- c("channel", "ts")
  required_streams <- c("channel", "ts", "game", "viewers")
  miss_c <- setdiff(required_chat, names(chat))
  miss_s <- setdiff(required_streams, names(streams))
  if (length(miss_c) > 0) {
    cli::cli_abort("{.arg chat} is missing columns: {.val {miss_c}}.")
  }
  if (length(miss_s) > 0) {
    cli::cli_abort("{.arg streams} is missing columns: {.val {miss_s}}.")
  }
  if (!inherits(chat$ts, "POSIXct") || !inherits(streams$ts, "POSIXct")) {
    cli::cli_abort(c(
      "Both {.field chat$ts} and {.field streams$ts} must be {.cls POSIXct}.",
      "i" = "Run {.code mutate(ts = clean_dates(date))} on both tables first."
    ))
  }

  cols <- c("channel", "ts", "game", "viewers")
  if ("is_gaming" %in% names(streams)) cols <- c(cols, "is_gaming")

  dplyr::left_join(
    dplyr::arrange(chat, .data$channel, .data$ts),
    dplyr::arrange(dplyr::select(streams, dplyr::all_of(cols)),
                   .data$channel, .data$ts),
    by = dplyr::join_by(channel, closest(ts >= ts))
  )
}
