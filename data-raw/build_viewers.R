# data-raw/build_viewers.R
#
# Build twitch_viewers_sample, the six-hour viewer totals by game category that
# twitch_viewers_over_time() returns. Run from the package root:
#   Rscript data-raw/build_viewers.R
#
# This script is the pipeline the Chapter 12 line-chart slide used to show
# (owner 2026-11-03: student-facing code stays at one function or a short
# pipe). The judgment calls live here: six-hour blocks, and the top five
# categories with the rest lumped into "Other".

library(dplyr)
library(tibble)
library(usethis)
devtools::load_all(".", quiet = TRUE)

e <- new.env()
load("data/twitch_streams_sample.rda", envir = e)
streams <- as_tibble(e$twitch_streams_sample)

twitch_viewers_sample <- streams %>%
  filter(!is.na(game)) %>%
  mutate(
    ts       = clean_dates(date),
    six_hour = lubridate::floor_date(ts, "6 hours"),
    category = forcats::fct_lump_n(game, n = 5)
  ) %>%
  group_by(six_hour, category) %>%
  summarize(total_viewers = sum(viewers), .groups = "drop")

stopifnot(nlevels(twitch_viewers_sample$category) == 6)
use_data(twitch_viewers_sample, overwrite = TRUE, compress = "xz")
