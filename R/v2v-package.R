#' v2v: Companion Package for 'From Vibes to Variables'
#'
#' The `v2v` package ships the Twitch dataset used throughout the open
#' educational resource *From Vibes to Variables: A Field Guide to Open
#' Media Science* and a small set of pedagogical helpers that the book
#' introduces chapter by chapter.
#'
#' @section Bundled data:
#' [twitch_chat_sample] and [twitch_streams_sample] are the canonical
#' shipped datasets. They are stratified subsets of a 22-million-row
#' November 2018 dump of public Twitch IRC chat and concurrent stream
#' metadata. See `vignette("data-dictionary", package = "v2v")` for the
#' full schema and provenance.
#'
#' @section Pedagogical helpers:
#'  - [setup()] validates the student toolchain (Chapter 2)
#'  - [new_portfolio()] scaffolds a portfolio project (Chapter 2)
#'  - [twitch_chat()] / [twitch_streams()] load the bundled data (Chapter 9)
#'  - [sample_messages()] draws a stratified sample by channel (Chapter 10)
#'  - [reliability()] wraps Cohen's kappa and Krippendorff's alpha (Chapter 10)
#'  - [clean_dates()] converts the bigint millisecond timestamps to POSIXct (Chapter 11)
#'  - [join_chat_streams()] asof-joins chat to stream snapshots (Chapter 11)
#'
#' @section Citation:
#' Leith, A. P. (2026). *From Vibes to Variables: A Field Guide to Open
#' Media Science* (3rd ed.). SIUE SIM Lab.
#' <https://sim-lab-siue.github.io/vibes-to-variables/>
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data
## usethis namespace: end
NULL
