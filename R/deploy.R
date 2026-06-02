#' Deploy a student portfolio to GitHub Pages
#'
#' Runs a three-step pre-flight checklist before publishing: verifies that the
#' `renv` library is synchronized, that there are no uncommitted changes in the
#' working tree, and that a `_quarto.yml` file exists in the project root. If
#' all checks pass, the function renders the Quarto project and publishes it to
#' GitHub Pages using `quarto publish`.
#'
#' This function is designed to be called from the root of a student Quarto
#' portfolio project (the directory that contains `_quarto.yml`).
#'
#' @param path Path to the Quarto project root. Defaults to the current working
#'   directory.
#' @param render Logical. If `TRUE` (default), run `quarto render` before
#'   publishing. Set to `FALSE` to publish a previously rendered site without
#'   re-rendering.
#' @param ask Logical. If `TRUE` (default in interactive sessions), prompt for
#'   confirmation before publishing. Set to `FALSE` for non-interactive use.
#'
#' @return Invisibly returns `TRUE` if the deploy succeeded, `FALSE` if a
#'   pre-flight check failed (no error is thrown; the specific failure is
#'   reported to the console).
#'
#' @examples
#' \dontrun{
#' # From your portfolio project root:
#' v2v::deploy_portfolio()
#' }
#'
#' @export
deploy_portfolio <- function(path = ".", render = TRUE, ask = interactive()) {
  path <- normalizePath(path, mustWork = TRUE)

  cli::cli_h1("Pre-flight checks")

  ok <- TRUE

  # ── Check 1: renv sync ──────────────────────────────────────────────────────
  renv_lock <- file.path(path, "renv.lock")
  if (file.exists(renv_lock)) {
    renv_ok <- tryCatch({
      status <- renv::status(project = path)
      length(status$library$missing) == 0 && length(status$library$changed) == 0
    }, error = function(e) NA)

    if (isTRUE(renv_ok)) {
      cli::cli_alert_success("renv library in sync")
    } else if (is.na(renv_ok)) {
      cli::cli_alert_warning("renv library status could not be checked (skipping)")
    } else {
      cli::cli_alert_danger("renv library out of sync")
      cli::cli_inform(c("i" = "Run {.code renv::restore()} to resolve."))
      ok <- FALSE
    }
  } else {
    cli::cli_alert_info("No renv.lock found — skipping renv check")
  }

  # ── Check 2: No uncommitted git changes ─────────────────────────────────────
  git_result <- tryCatch(
    system2("git", args = c("-C", shQuote(path), "status", "--porcelain"),
            stdout = TRUE, stderr = FALSE),
    error = function(e) NULL
  )

  if (is.null(git_result)) {
    cli::cli_alert_warning("git not available — skipping uncommitted-changes check")
  } else if (length(git_result) == 0) {
    cli::cli_alert_success("no uncommitted changes")
  } else {
    cli::cli_alert_danger("uncommitted changes detected")
    cli::cli_inform(c(
      "i" = "Commit or stash your changes before deploying.",
      " " = paste(git_result, collapse = "\n")
    ))
    ok <- FALSE
  }

  # ── Check 3: _quarto.yml exists ─────────────────────────────────────────────
  quarto_yml <- file.path(path, "_quarto.yml")
  if (file.exists(quarto_yml)) {
    cli::cli_alert_success("_quarto.yml valid")
  } else {
    cli::cli_alert_danger("_quarto.yml not found in {.path {path}}")
    cli::cli_inform(c("i" = "Run this function from your Quarto project root."))
    ok <- FALSE
  }

  if (!ok) {
    cli::cli_alert_danger(
      "Deploy cancelled: fix the issues above, then re-run {.fn v2v::deploy_portfolio}."
    )
    return(invisible(FALSE))
  }

  cli::cli_rule()

  # ── Render ───────────────────────────────────────────────────────────────────
  if (render) {
    n_qmds <- length(list.files(path, pattern = "\\.qmd$", recursive = TRUE))
    cli::cli_progress_step("Rendering {n_qmds} page{?s}")
    result <- tryCatch(
      quarto::quarto_render(input = path),
      error = function(e) e
    )
    if (inherits(result, "error")) {
      cli::cli_alert_danger("Render failed: {result$message}")
      return(invisible(FALSE))
    }
    cli::cli_progress_done()
  }

  # ── Confirm before publish ───────────────────────────────────────────────────
  if (ask) {
    answer <- readline("Publish to GitHub Pages? [y/N] ")
    if (!tolower(trimws(answer)) %in% c("y", "yes")) {
      cli::cli_alert_info("Publish cancelled.")
      return(invisible(FALSE))
    }
  }

  # ── Publish ──────────────────────────────────────────────────────────────────
  cli::cli_progress_step("Publishing to GitHub Pages")
  pub_result <- tryCatch(
    quarto::quarto_publish_site(input = path, server = "gh-pages", prompt = FALSE),
    error = function(e) e
  )
  if (inherits(pub_result, "error")) {
    cli::cli_alert_danger("Publish failed: {pub_result$message}")
    return(invisible(FALSE))
  }
  cli::cli_progress_done()
  cli::cli_alert_success("Portfolio live on GitHub Pages.")

  invisible(TRUE)
}
