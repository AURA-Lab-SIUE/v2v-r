# v2v

<!-- badges: start -->
[![R-CMD-check](https://github.com/AURA-Lab-SIUE/v2v-r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AURA-Lab-SIUE/v2v-r/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Companion R package for the open educational resource [*Vibes to Variables: A Methods Package for Students New to Research, Stats, and Code*](https://aura-lab.siue.edu/v2v/) by Alex P. Leith. Used in SIUE MC-451 (Research Methods) and MC-501 (Graduate).

## Part of From Vibes to Variables

[From Vibes to Variables (V2V)](https://aura-lab.siue.edu/v2v/) is the AURA Lab's open methods package for teaching media research at Southern Illinois University Edwardsville. Its parts are built to be used together:

- [Textbook](https://aura-lab.siue.edu/v2v/) ([source](https://github.com/AURA-Lab-SIUE/v2v)): the open textbook that carries the arc from research question to published report.
- [Course hub](https://aura-lab.siue.edu/v2v-hub/) ([source](https://github.com/AURA-Lab-SIUE/v2v-hub)): the course website for MC 451 and MC 501 that sequences the textbook, the labs, and the setup guides.
- [v2v R package](https://github.com/AURA-Lab-SIUE/v2v-r) (this repository): the companion package with the Twitch practice corpus and the helpers the textbook introduces chapter by chapter.
- [Course workspace](https://github.com/AURA-Lab-SIUE/v2v-workspace): the VS Code template students copy for journals, reading notes, and project work.
- [R Companion](https://github.com/AURA-Lab-SIUE/r-companion): the VS Code extension that checks each student's R setup, installs what is missing, and explains common R errors.

A sibling template, [mc427-codespace](https://github.com/AURA-Lab-SIUE/mc427-codespace), gives MC 427 Social Media Analytics the same VS Code and R toolchain in a GitHub Codespace; the R Companion serves MC 427 as well, and the v2v package is not used there.

## What this package ships

- **`twitch_chat_sample`**: ~35,000 Twitch IRC chat messages from 50 channels active in the November 18-24, 2018 collection window. Eight anchor channels (`xqcow`, `forsen`, `sodapoppin`, `asmongold`, `loltyler1`, `disguisedtoast`, `giantwaffle`, `bobross`) are referenced repeatedly throughout the textbook. The other 42 are a stratified random sample by chat-volume decile from the broader population of 1,690 joinable channels, drawn so that Chapter 10's stratified-sampling lesson works against a real sample frame.
- **`twitch_streams_sample`**: ~32,000 stream snapshots for the same 50 channels and the same collection window.
- A small set of pedagogical helpers the textbook introduces chapter by chapter.

All source data was collected by the package author from public Twitch IRC and the public Twitch API in November 2018. Three published manuscripts have analyzed adjacent slices of this data infrastructure under an exempt-by-design IRB determination based on the public-channel basis.

## Install

```r
# install.packages("remotes")
remotes::install_github("AURA-Lab-SIUE/v2v-r")
```

## Quick start

```r
library(v2v)

# Load the bundled data
chat    <- twitch_chat()
streams <- twitch_streams()

# Convert the bigint-millisecond timestamps
library(dplyr)
chat    <- chat    %>% mutate(ts = clean_dates(date))
streams <- streams %>% mutate(ts = clean_dates(date))

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

The `twitch_chat_sample` and `twitch_streams_sample` tibbles are stratified subsets of a 22-million-row November 2018 dump of public Twitch IRC chat and concurrent stream metadata. The collection window is narrow: 2018-11-18 to 2018-11-24, about 5.85 days.

Two data-quality moments drive Chapter 11:

1. **`chat_log.channel` is prefixed with `#`** (IRC convention); `stream_log.channel` is not. In the shipped fixture the prefix has been stripped so joins work; recovering the IRC representation is an exercise.
2. **`date` is bigint Unix epoch in milliseconds**, not seconds. Without dividing by 1000, students get timestamps in the year 50,888. `clean_dates()` does the divide so the failure mode cannot happen by accident.

## Adapting this for your course

The package is a teaching instrument, and the parts another course would change are deliberately few:

- **Swap the datasets.** The two shipped tibbles live in `data/` (`twitch_chat_sample.rda` and `twitch_streams_sample.rda`), with their build scripts in `data-raw/`. They are loaded through the functions in `R/loaders.R` (`twitch_chat()` and `twitch_streams()`), which filter by channel and draw random subsamples. Replace the `.rda` files with your own corpus and keep the loader signatures, and the sampling and wrangling exercises keep working.
- **Edit the setup checklist.** `R/setup.R` holds two character vectors, `required_pkgs` and `suggested_pkgs`, that `setup()` checks, alongside its Quarto CLI and Git checks. Change the lists to your course's toolchain; the printed checklist and the copy-paste install instructions follow from them.
- **Keep wrappers inspectable.** Helpers such as `clean_dates()` (`R/dates.R`) and `join_chat_streams()` (`R/join.R`) are thin wrappers over the plain calls they replace, kept short so `body(clean_dates)` shows students the real arithmetic. A helper you add should be a stepping stone to the plain call, not a replacement for learning it.
- **Rename for your course** in `DESCRIPTION` (package name, title, and version), update the `library()` calls in your course materials, and rebuild with `R CMD check` or `devtools::check()`.

## License

Code: MIT (see `LICENSE.md`). Data and documentation: CC BY 4.0 (see `LICENSE-DATA.md`).
The two Twitch datasets are free to use, adapt, and redistribute with attribution; the
underlying messages are public Twitch content and remain subject to Twitch's terms.

## Citation

> Leith, A. P. (2026). *Vibes to Variables: A Methods Package for Students New to Research, Stats, and Code* (3rd ed.). SIUE AURA Lab. <https://aura-lab.siue.edu/v2v/>
