# data-raw/build_fixtures.R
#
# Build the .rda fixtures shipped with the v2v package from the source CSVs.
# Run from the package root:  Rscript data-raw/build_fixtures.R
#
# The source CSVs are produced by data/v2v-source/sample_v3.py from the raw
# chat_log.csv.gz / stream_log.csv.gz extracts of the dissertation pg_dump
# (One Touch: nonacademic/D_drive/Dissertation/Data/twitch_backup). Re-running
# that script regenerates them deterministically (seed = 20261113).
#
# v0.3.0 design: the non-gaming stratum is a census of all 113 non-gaming
# channels in the joinable population, the gaming stratum is matched at 113,
# and 2 channels that never recorded a stream category are retained because the
# wrangling chapter teaches the join against them. 228 channels in total, every
# one of the v0.2.0 fixture's 50 among them.
#
# Base R rather than readr: readr is not installed on the build host, and the
# column types are declared explicitly here anyway.

library(tibble)
library(usethis)

read_fixture <- function(path, classes) {
  df <- utils::read.csv(
    path,
    colClasses = classes,
    na.strings = "",          # an empty message is missing; the literal text "NA" is not
    encoding = "UTF-8",
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  tibble::as_tibble(df)
}

twitch_chat_sample <- read_fixture(
  "data-raw/twitch_chat_sample.csv",
  c(id = "integer", channel = "character", sender = "character",
    message = "character", date = "double")   # bigint ms, double preserves precision
)

twitch_streams_sample <- read_fixture(
  "data-raw/twitch_streams_sample.csv",
  c(id = "integer", channel = "character", title = "character",
    game = "character", viewers = "integer", date = "double")
)

n_chat_ch <- length(unique(twitch_chat_sample$channel))
n_str_ch  <- length(unique(twitch_streams_sample$channel))

stopifnot(
  n_chat_ch == 228L,
  n_str_ch  == 228L,
  nrow(twitch_chat_sample)    > 150000L,
  nrow(twitch_chat_sample)    < 170000L,
  nrow(twitch_streams_sample) > 80000L,
  # no channel may exceed the per-channel cap
  max(table(twitch_chat_sample$channel)) <= 1000L,
  # every v0.2.0 channel must survive, or a worked example in the book breaks
  all(c("dev1", "rdulive", "hitch", "tjsmith", "darksydephil", "xqcow", "forsen",
        "sodapoppin", "asmongold", "loltyler1", "disguisedtoast", "giantwaffle",
        "bobross", "uberhaxornova", "704cb1fgnty", "cudemcudem")
      %in% twitch_chat_sample$channel)
)

usethis::use_data(twitch_chat_sample,    overwrite = TRUE, compress = "xz")
usethis::use_data(twitch_streams_sample, overwrite = TRUE, compress = "xz")

message("Fixtures rebuilt:\n",
        "  data/twitch_chat_sample.rda    (", nrow(twitch_chat_sample),
        " rows, ", n_chat_ch, " channels, ",
        sum(is.na(twitch_chat_sample$message)), " missing messages)\n",
        "  data/twitch_streams_sample.rda (", nrow(twitch_streams_sample),
        " rows, ", n_str_ch, " channels)")
