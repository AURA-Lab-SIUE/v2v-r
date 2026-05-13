#' Common errors and their fixes
#'
#' A reference page (rendered into the package help system) that catalogs
#' the errors V2V students hit most often, with the canonical fix for each.
#' Linked from every code-bearing chapter starting with Chapter 9. Run
#' `?v2v::common_errors` to read it.
#'
#' @section Date arithmetic produces year-50,888 timestamps:
#' **Symptom:** `mutate(ts = as.POSIXct(date, origin = "1970-01-01"))`
#' produces timestamps in the year 50,888.
#'
#' **Cause:** The `date` column is bigint Unix epoch in *milliseconds*, not
#' seconds. R's `as.POSIXct()` expects seconds.
#'
#' **Fix:** Use [clean_dates()] or divide by 1000 manually:
#' `mutate(ts = clean_dates(date))`.
#'
#' @section Join produces zero matched rows between chat and streams:
#' **Symptom:** `inner_join(chat, streams, by = "channel")` returns zero
#' rows even though both tables have data for the same streamers.
#'
#' **Cause:** `chat$channel` is prefixed with `#` (IRC convention);
#' `streams$channel` is not.
#'
#' **Fix:** In the shipped [twitch_chat_sample], the prefix has been
#' stripped, so the join works as-is. If you are pulling raw data from the
#' source dump, normalize first:
#' `mutate(channel = sub("^#", "", channel))`.
#'
#' @section `setup()` reports Quarto missing but I have Quarto installed:
#' **Symptom:** `v2v::setup()` shows a red x on Quarto CLI even though you
#' can run Quarto from the terminal.
#'
#' **Cause:** The R `quarto` package is not installed. R looks up the CLI
#' through that wrapper.
#'
#' **Fix:** `install.packages("quarto")` and run `setup()` again.
#'
#' @section Cohen's kappa is much lower than I expected:
#' **Symptom:** Two coders who seem to agree most of the time still
#' produce a kappa near 0.20.
#'
#' **Cause:** Kappa corrects for chance agreement. If one code is rare,
#' two coders can agree 90% of the time on the *common* code (negative)
#' and still produce a low kappa because the agreement on the *rare* code
#' (positive) is the load-bearing signal.
#'
#' **Fix:** Two paths: (1) revise the codebook so the rare code is better
#' defined and shows up more often, or (2) report Krippendorff's alpha
#' (`method = "alpha"`) which handles imbalance more gracefully.
#'
#' @section `data(twitch_chat_sample)` returns NULL or "not found":
#' **Symptom:** `data(twitch_chat_sample)` throws "data set
#' 'twitch_chat_sample' not found".
#'
#' **Cause:** The package is not installed, or you are calling `data()`
#' without `library(v2v)` first.
#'
#' **Fix:** `library(v2v)` and try again. If still failing, reinstall:
#' `install.packages("v2v")` or
#' `remotes::install_github("SIM-Lab-SIUE/v2v")`.
#'
#' @name common_errors
NULL
