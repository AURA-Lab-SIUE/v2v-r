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
#' **Cause:** R was already open when Quarto was installed. R reads the
#' `PATH` once, when it starts, so a session opened before the install
#' cannot see Quarto. (Before v2v 0.3.1, `setup()` also misreported the CLI
#' as missing whenever the `quarto` R package was absent; that is fixed.)
#'
#' **Fix:** Quit R, open it again, and run `setup()` once more. If the red x
#' stays, reinstall Quarto from <https://quarto.org/docs/get-started/>. The
#' `quarto` R package is a separate, optional wrapper: installing it does not
#' install the CLI.
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
#' **Fix:** `library(v2v)` and try again. If still failing, reinstall from
#' GitHub (v2v is not on CRAN, so `install.packages("v2v")` cannot find it):
#' `remotes::install_github("AURA-Lab-SIUE/v2v-r", upgrade = "never", force = TRUE)`.
#'
#' @section VS Code says R is not attached, or the connection to the server closed:
#' **Symptom:** The status bar in VS Code reads `R: (not attached)` and the
#' Workspace panel stays empty, or VS Code says `Connection to server got
#' closed. Server will not be restarted` or `read ECONNRESET`. Your code still
#' runs.
#'
#' **Cause:** Two helpers run beside R in VS Code: the R extension's session
#' watcher, which fills the Workspace panel, and the `languageserver` package,
#' which powers code completion. The R extension before version 3.0.0 cannot
#' connect to R 4.6 or later; a `languageserver` that failed to install stops
#' the second helper.
#'
#' **Fix:** With the AURA Lab R Companion, run **AURA: Explain an R error** on
#' the message and select **Update the R extension**. Without it: update R by
#' REditorSupport in the Extensions view to 3.0.0 or newer, quit VS Code, run
#' `install.packages("languageserver")` in R on its own (answer No if asked to
#' compile from source), then open VS Code again and allow it to install
#' `sess` if it asks.
#'
#' @section Stray `[200~` and `[201~` characters around code you run:
#' **Symptom:** Code sent from a script to the R terminal arrives wrapped in
#' `[200~` and `[201~`, and R waits with a `+` prompt.
#'
#' **Cause:** The workspace setting `r.bracketedPaste` is on. It sends code in a
#' format meant for a different R console. Copies of the course workspace made
#' before September 2026 still carry it.
#'
#' **Fix:** With the R Companion, run **AURA: Explain an R error** on the
#' message and select **Turn off bracketed paste for this folder**. Without it:
#' open Settings, choose the Workspace tab, search for `bracketed`, untick
#' **R: Bracketed Paste**, and close the R terminal.
#'
#' @section `file is in use` or `cannot remove prior installation` on Windows:
#' **Symptom:** Installing or updating a package prints `file is in use`,
#' `cannot remove prior installation of package`, or `Warning: restored`.
#'
#' **Cause:** An open R session has the package loaded, and Windows will not
#' replace an open file, so R puts the old version back.
#'
#' **Fix:** With the R Companion, run **AURA: Explain an R error** on the
#' message and select **Close R terminals and install again**. Without it: quit
#' VS Code completely, open R on its own, and install again there.
#'
#' @name common_errors
NULL
