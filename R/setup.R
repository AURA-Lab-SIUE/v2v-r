#' Validate the V2V student toolchain
#'
#' Verifies that the R packages and command-line tools the textbook expects
#' are installed and reachable. Run at the end of Chapter 2 to confirm the
#' install before any code chapters begin. Prints a checklist of green
#' checks for what is present and red x marks for what is missing, along
#' with a copy-paste install hint.
#'
#' Checked items:
#' - Required CRAN packages: `dplyr`, `irr`, `usethis`, `cli`, `tibble`, `rlang`.
#' - Suggested CRAN packages: `quarto` (R wrapper), `ggplot2`, `lubridate`.
#' - Quarto CLI on PATH (via [quarto::quarto_path()]).
#' - Git on PATH (via `Sys.which("git")`).
#'
#' @return Invisibly returns a logical: `TRUE` if everything required is
#'   present, `FALSE` otherwise. The function is run for its side-effect
#'   output, not its return value.
#' @examples
#' \dontrun{
#' library(v2v)
#' setup()
#' }
#' @export
setup <- function() {
  required_pkgs   <- c("dplyr", "irr", "usethis", "cli", "tibble", "rlang")
  suggested_pkgs  <- c("quarto", "ggplot2", "lubridate")

  cli::cli_h1("V2V toolchain check")

  required_missing <- character()
  cli::cli_h2("Required R packages")
  for (p in required_pkgs) {
    if (requireNamespace(p, quietly = TRUE)) {
      cli::cli_alert_success("{.pkg {p}}")
    } else {
      cli::cli_alert_danger("{.pkg {p}} (missing)")
      required_missing <- c(required_missing, p)
    }
  }

  suggested_missing <- character()
  cli::cli_h2("Suggested R packages")
  for (p in suggested_pkgs) {
    if (requireNamespace(p, quietly = TRUE)) {
      cli::cli_alert_success("{.pkg {p}}")
    } else {
      cli::cli_alert_warning("{.pkg {p}} (missing, recommended)")
      suggested_missing <- c(suggested_missing, p)
    }
  }

  cli::cli_h2("Command-line tools")
  quarto_ok <- requireNamespace("quarto", quietly = TRUE) &&
               !is.null(tryCatch(quarto::quarto_path(), error = function(e) NULL))
  if (quarto_ok) {
    cli::cli_alert_success("Quarto CLI on PATH")
  } else {
    cli::cli_alert_danger("Quarto CLI not found on PATH (install from https://quarto.org)")
  }
  git_path <- Sys.which("git")
  if (nzchar(git_path)) {
    cli::cli_alert_success("Git on PATH ({.path {git_path}})")
  } else {
    cli::cli_alert_danger("Git not found on PATH (install from https://git-scm.com)")
  }

  all_missing <- c(required_missing, suggested_missing)
  if (length(all_missing) > 0) {
    cli::cli_h2("Install hint")
    cli::cli_code(sprintf("install.packages(c(%s))",
                          paste0('"', all_missing, '"', collapse = ", ")))
  }

  ok <- length(required_missing) == 0L && quarto_ok && nzchar(git_path)
  invisible(ok)
}
