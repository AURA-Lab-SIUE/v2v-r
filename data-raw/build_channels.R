# data-raw/build_channels.R
#
# Build twitch_channels_sample, the one-row-per-channel lookup table that
# twitch_channels() returns, from the shipped stream snapshots.
# Run from the package root:  Rscript data-raw/build_channels.R
#
# This script IS the long-form wrangling that the Chapter 11 worksheet used to
# ask students to type (owner 2026-11-03: student-facing code stays at one
# function or a short pipe). The judgment calls live here, in the open: which
# categories count as non-gaming, and where the viewer bands are cut.

library(dplyr)
library(tibble)
library(usethis)

e <- new.env()
load("data/twitch_streams_sample.rda", envir = e)
streams <- as_tibble(e$twitch_streams_sample)

# Which Twitch categories are NOT games. Everything else counts as gaming.
nongaming_categories <- c(
  "Art", "ASMR", "Beauty & Body Art", "Creative", "Food & Drink",
  "IRL", "Just Chatting", "Makers & Crafting", "Music",
  "Music & Performing Arts", "Science & Technology",
  "Sports & Fitness", "Talk Shows & Podcasts", "Travel & Outdoors"
)

# Each channel's most frequent category across its snapshots. A channel whose
# snapshots never recorded a category has no row here, so it stays NA below.
main_category <- streams %>%
  filter(!is.na(game)) %>%
  count(channel, game) %>%
  group_by(channel) %>%
  slice_max(n, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(is_gaming = !(game %in% nongaming_categories)) %>%
  select(channel, main_game = game, is_gaming)

# Each channel's typical audience, banded at 5,000 and 20,000 median viewers.
audience <- streams %>%
  group_by(channel) %>%
  summarize(median_viewers = median(viewers, na.rm = TRUE), .groups = "drop") %>%
  mutate(viewer_band = cut(median_viewers,
                           breaks = c(0, 5000, 20000, Inf),
                           labels = c("small", "medium", "large")))

twitch_channels_sample <- streams %>%
  distinct(channel) %>%
  left_join(main_category, by = "channel") %>%
  left_join(audience, by = "channel") %>%
  mutate(
    channel_type = case_when(
      is_gaming == TRUE  ~ "gaming",
      is_gaming == FALSE ~ "non-gaming",
      TRUE ~ NA_character_
    ),
    channel_type = factor(channel_type, levels = c("gaming", "non-gaming"))
  ) %>%
  select(channel, main_game, is_gaming, channel_type, median_viewers, viewer_band) %>%
  arrange(channel)

stopifnot(
  nrow(twitch_channels_sample) == 50,
  sum(is.na(twitch_channels_sample$main_game)) == 2,
  identical(as.integer(table(twitch_channels_sample$viewer_band)), c(41L, 7L, 2L)),
  !anyNA(twitch_channels_sample$viewer_band)
)

use_data(twitch_channels_sample, overwrite = TRUE, compress = "xz")
