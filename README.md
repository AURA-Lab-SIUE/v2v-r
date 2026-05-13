# v2v

<!-- badges: start -->
[![R-CMD-check](https://github.com/SIM-Lab-SIUE/v2v/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/SIM-Lab-SIUE/v2v/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Companion R package for the open educational resource [*From Vibes to Variables: A Field Guide to Open Media Science*](https://sim-lab-siue.github.io/vibes-to-variables/) by Alex P. Leith. Used in SIUE MC-451 (Research Methods) and MC-501 (Graduate).

## What this package ships

- **`twitch_chat_sample`**: ~35,000 Twitch IRC chat messages from 50 channels active in the November 18-24, 2018 collection window. Eight anchor channels (`xqcow`, `forsen`, `sodapoppin`, `asmongold`, `loltyler1`, `disguisedtoast`, `giantwaffle`, `bobross`) are referenced repeatedly throughout the textbook. The other 42 are a stratified random sample by chat-volume decile from the broader population of 1,690 joinable channels, drawn so that Chapter 10's stratified-sampling lesson works against a real sample frame.
- **`twitch_streams_sample`**: ~32,000 stream snapshots for the same 50 channels and the same collection window.
- A small set of pedagogical helpers the textbook introduces chapter by chapter.

All source data was collected by the package author from public Twitch IRC and the public Twitch API in November 2018. Three published manuscripts have analyzed adjacent slices of this data infrastructure under an exempt-by-design IRB determination based on the public-channel basis.

## Install

```r
# install.packages("remotes")
remotes::install_github("SIM-Lab-SIUE/v2v")
```

## Quick start

```r
library(v2v)

# Load the bundled data
chat    <- twitch_chat()
streams <- twitch_streams()

# Convert the bigint-millisecond timestamps
library(dplyr)
chat    <- chat    |> mutate(ts = clean_dates(date))
streams <- streams |> mutate(ts = clean_dates(date))

# Asof-join each chat message to the nearest prior stream snapshot
joined <- join_chat_streams(chat, streams)

# Stratified sample for a coding exercise
sample_messages(chat, n_per_channel = 50)

# Compute intercoder reliability
reliability(coder_a, coder_b, method = "kappa")
```

## Function reference

| Function | Chapter | Purpose |
|---|---|---|
| `setup()` | 2 | Validate the student toolchain (R packages, Quarto CLI, Git) |
| `new_portfolio()` | 2 | Scaffold a Quarto portfolio project with the canonical folder layout |
| `twitch_chat()` | 9 | Load `twitch_chat_sample`, optionally filtered |
| `twitch_streams()` | 9 | Load `twitch_streams_sample`, optionally filtered |
| `sample_messages()` | 10 | Stratified random sample by channel |
| `reliability()` | 10 | Cohen's kappa or Krippendorff's alpha, with Landis & Koch labels |
| `clean_dates()` | 11 | Convert bigint-millisecond timestamps to POSIXct |
| `join_chat_streams()` | 11 | Asof-join chat to nearest-prior stream snapshot |

## The data in 90 seconds

The `twitch_chat_sample` and `twitch_streams_sample` tibbles are stratified subsets of a 22-million-row November 2018 dump of public Twitch IRC chat and concurrent stream metadata. The collection window is narrow: 2018-11-18 to 2018-11-24, about 5.85 days. The full data report (provenance, schema, EDA, focal-channel rationale, chapter-keyed worked examples) is at `inst/extdata/v2v-data-report.md` once the package is installed, or in the SIM Lab research tree at `D:/hub/academic/research/sim-lab/v2v/data/report/v2v-data-report.md`.

Two data-quality moments drive Chapter 11:

1. **`chat_log.channel` is prefixed with `#`** (IRC convention); `stream_log.channel` is not. In the shipped fixture the prefix has been stripped so joins work; recovering the IRC representation is an exercise.
2. **`date` is bigint Unix epoch in milliseconds**, not seconds. Without dividing by 1000, students get timestamps in the year 50,888. `clean_dates()` does the divide so the failure mode cannot happen by accident.

## License

CC BY 4.0. Free to use, adapt, and redistribute with attribution. See `LICENSE.md`.

## Citation

> Leith, A. P. (2026). *From Vibes to Variables: A Field Guide to Open Media Science* (3rd ed.). SIUE SIM Lab. <https://sim-lab-siue.github.io/vibes-to-variables/>
