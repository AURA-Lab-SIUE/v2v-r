#' Load the channel lookup table
#'
#' Returns [twitch_channels_sample]: one row per channel in the course data,
#' with the labels the Chapter 11 analysis joins onto every message. The
#' worksheet step is a single join:
#'
#' ```r
#' channels <- twitch_channels()
#'
#' analysis <- chat_streams %>%
#'   left_join(channels, by = "channel")
#' ```
#'
#' Two decisions sit inside this table, and a reviewer may challenge either:
#'
#' * **Which categories are not games.** A channel is `is_gaming = TRUE` unless
#'   the category it streamed most often is one of: Art, ASMR, Beauty & Body
#'   Art, Creative, Food & Drink, IRL, Just Chatting, Makers & Crafting,
#'   Music, Music & Performing Arts, Science & Technology, Sports & Fitness,
#'   Talk Shows & Podcasts, Travel & Outdoors.
#' * **Where the audience bands are cut.** `viewer_band` is `small` below
#'   5,000 median viewers, `medium` from 5,000 to 20,000, and `large` above
#'   20,000.
#'
#' Two channels never recorded a category in any snapshot, so their
#' `main_game`, `is_gaming`, and `channel_type` are `NA`. After the join, the
#' 501 messages from those channels carry `NA` too. That is the honest answer,
#' not a bug.
#'
#' The table is built by `data-raw/build_channels.R` in the package source,
#' which shows the full dplyr pipeline (count the snapshots per channel and
#' category, keep each channel's most frequent one, take each channel's
#' median viewers, and cut the bands).
#'
#' @return A tibble with 50 rows and 6 columns: `channel`, `main_game`,
#'   `is_gaming`, `channel_type` (a factor: gaming, non-gaming),
#'   `median_viewers`, and `viewer_band` (a factor: small, medium, large).
#' @examples
#' library(v2v)
#'
#' channels <- twitch_channels()
#' channels
#' @export
twitch_channels <- function() {
  e <- new.env()
  utils::data("twitch_channels_sample", package = "v2v", envir = e)
  tibble::as_tibble(e$twitch_channels_sample)
}

#' Write a coding form, once
#'
#' Saves the messages you will hand-code as a CSV with three columns, `id`,
#' `channel`, and `message`, so you can add your code columns in a spreadsheet
#' or in the R Companion's data viewer. The file is written only if it does
#' not exist yet: re-running or rendering a worksheet never wipes out codes
#' you have typed. The folder is created if it is missing.
#'
#' The same step without v2v is `write_csv(select(sample, id, channel,
#' message), path)`, guarded by `file.exists()`.
#'
#' @param sample A tibble of messages, typically the output of
#'   [sample_messages()]. It must have `id`, `channel`, and `message` columns.
#' @param path Where to write the form. Default `"data/coding-form.csv"`.
#' @return The path, invisibly. Prints one line saying whether the file was
#'   written or left alone.
#' @examples
#' \dontrun{
#' coding_sample <- twitch_chat(channels = c("bobross", "giantwaffle")) %>%
#'   sample_messages(n_per_channel = 15)
#'
#' write_coding_form(coding_sample)
#' }
#' @export
write_coding_form <- function(sample, path = "data/coding-form.csv") {
  needed <- c("id", "channel", "message")
  missing_cols <- setdiff(needed, names(sample))
  if (length(missing_cols) > 0) {
    cli::cli_abort("{.arg sample} is missing columns: {.val {missing_cols}}.")
  }
  if (file.exists(path)) {
    cli::cli_inform("{.path {path}} already exists and was left alone, so your codes are safe.")
    return(invisible(path))
  }
  folder <- dirname(path)
  if (!dir.exists(folder)) dir.create(folder, recursive = TRUE)
  show_equivalent(
    "write_coding_form",
    "write_csv(select(sample, id, channel, message), path), unless the file exists"
  )
  readr::write_csv(dplyr::select(sample, dplyr::all_of(needed)), path)
  cli::cli_inform("Wrote {nrow(sample)} messages to {.path {path}}.")
  invisible(path)
}
