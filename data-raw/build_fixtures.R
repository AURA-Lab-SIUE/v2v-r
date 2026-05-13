# data-raw/build_fixtures.R
#
# Build the .rda fixtures shipped with the v2v package from the source CSVs.
# Run from the package root:  Rscript data-raw/build_fixtures.R
# Or from R:                   source("data-raw/build_fixtures.R")
#
# The source CSVs in this directory were extracted from the 1.6 GB
# twitch_backup.sql pg_dump by the pipeline at
#   D:/hub/academic/research/sim-lab/v2v/data/
# (extract.py -> eda.py -> sample.py). Re-running that pipeline regenerates
# the CSVs deterministically (seed = 20261113).

library(readr)
library(tibble)
library(usethis)

twitch_chat_sample <- read_csv(
  "data-raw/twitch_chat_sample.csv",
  col_types = cols(
    id      = col_integer(),
    channel = col_character(),
    sender  = col_character(),
    message = col_character(),
    date    = col_double()   # bigint ms; stored as double to preserve precision
  )
)

twitch_streams_sample <- read_csv(
  "data-raw/twitch_streams_sample.csv",
  col_types = cols(
    id      = col_integer(),
    channel = col_character(),
    title   = col_character(),
    game    = col_character(),
    viewers = col_integer(),
    date    = col_double()
  )
)

stopifnot(
  length(unique(twitch_chat_sample$channel))    == 50L,
  length(unique(twitch_streams_sample$channel)) == 50L,
  nrow(twitch_chat_sample)    >= 30000L,
  nrow(twitch_chat_sample)    <= 50000L,
  nrow(twitch_streams_sample) >= 25000L
)

usethis::use_data(twitch_chat_sample,    overwrite = TRUE, compress = "xz")
usethis::use_data(twitch_streams_sample, overwrite = TRUE, compress = "xz")

message("Fixtures rebuilt:\n",
        "  data/twitch_chat_sample.rda    (", nrow(twitch_chat_sample),    " rows)\n",
        "  data/twitch_streams_sample.rda (", nrow(twitch_streams_sample), " rows)")
