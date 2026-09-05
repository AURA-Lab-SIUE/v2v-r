#' Validate the V2V student toolchain
#'
#' Verifies that the R packages and command-line tools the textbook expects
#' are installed and reachable. Run at the end of Chapter 2 to confirm the
#' install before any code chapters begin. Prints a checklist of green
#' checks for what is present and red x marks for what is missing, followed
#' by copy-paste instructions for anything that is not.
#'
#' Checked items:
#' - Required packages, the ones installed alongside `v2v`: `cli`, `dplyr`,
#'   `ggplot2`, `irr`, `knitr`, `rlang`, `tibble`, `usethis`.
#' - Suggested package: `quarto`, the R wrapper used by [deploy_portfolio()].
#' - Quarto CLI, found on the `PATH` or through [quarto::quarto_path()].
#' - Git on `PATH` (via `Sys.which("git")`).
#'
#' The Quarto CLI and the `quarto` R package are two different things. The
#' CLI is the program that renders `.qmd` files, downloaded from
#' <https://quarto.org>; the R package is a thin wrapper that calls it.
#' `install.packages("quarto")` installs the wrapper and does **not** install
#' the CLI, so this check reports them on separate lines.
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
  # These are the package's own Imports, so they arrive with v2v. Listing them
  # is reassurance rather than diagnosis, but a partial or interrupted install
  # does show up here.
  required_pkgs  <- c("cli", "dplyr", "ggplot2", "irr", "knitr", "rlang",
                      "tibble", "usethis")
  # `quarto` is the only genuine Suggests a student needs. `lubridate` used to
  # be listed here and was never used by the package nor declared in
  # DESCRIPTION, so every student was told to install something for nothing.
  suggested_pkgs <- c("quarto")

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

  # Look for the CLI on the PATH FIRST, independently of the R wrapper.
  # This check used to read
  #   requireNamespace("quarto") && !is.null(quarto::quarto_path())
  # which short-circuits: with the wrapper missing it reported "Quarto CLI not
  # found on PATH" WITHOUT EVER LOOKING FOR THE CLI. Students who had installed
  # Quarto correctly were told they had not, and the install hint then pointed
  # them at install.packages("quarto"), which cannot fix a missing CLI.
  quarto_cli <- unname(Sys.which("quarto"))
  have_wrapper <- requireNamespace("quarto", quietly = TRUE)
  if (!nzchar(quarto_cli) && have_wrapper) {
    # The wrapper can find installs that are not on the PATH of this session.
    quarto_cli <- tryCatch(quarto::quarto_path(), error = function(e) NULL)
    quarto_cli <- if (is.null(quarto_cli)) "" else unname(quarto_cli)
  }
  quarto_ok <- nzchar(quarto_cli)
  if (quarto_ok) {
    cli::cli_alert_success("Quarto CLI ({.path {quarto_cli}})")
  } else {
    cli::cli_alert_danger("Quarto CLI not found")
  }

  git_path <- unname(Sys.which("git"))
  if (nzchar(git_path)) {
    cli::cli_alert_success("Git on PATH ({.path {git_path}})")
  } else {
    cli::cli_alert_danger("Git not found on PATH")
  }

  # Two kinds of fix, kept apart on purpose. Anything install.packages() can
  # solve goes in the first block; anything it CANNOT goes in the second, so a
  # student never runs install.packages on quarto expecting to get the CLI.
  #
  # The cli markup here is deliberately plain. Nested quotes inside a {.code }
  # span and empty cli_text() calls are the fragile constructs, and this file
  # ships to a whole class at once, so anything clever that fails at runtime
  # breaks setup() for everybody. Bare strings and one inline class per line.
  pkg_missing <- c(required_missing, suggested_missing)
  anything_missing <- length(pkg_missing) > 0 || !quarto_ok || !nzchar(git_path)

  if (anything_missing) {
    cli::cli_h2("What to do next")
  }

  if (length(pkg_missing) > 0) {
    cli::cli_text("Install the missing R packages:")
    cli::cli_code(sprintf("install.packages(c(%s))",
                          paste0('"', pkg_missing, '"', collapse = ", ")))
  }

  if (!quarto_ok) {
    cli::cli_text(" ")
    cli::cli_text("The Quarto CLI is a separate program, not an R package.")
    cli::cli_text("Installing the quarto R package will NOT install it.")
    cli::cli_ul(c(
      "Download it from https://quarto.org/docs/get-started/",
      "Run the installer and accept the defaults",
      "Quit R and open it again, then run setup() once more"
    ))
    cli::cli_text(" ")
    cli::cli_text(paste(
      "The restart matters. R reads the PATH once, when it starts, so a session",
      "opened before the install cannot see Quarto however many times you check."
    ))
  }

  if (!nzchar(git_path)) {
    cli::cli_text(" ")
    cli::cli_text("Git is also a separate program, not an R package.")
    cli::cli_ul(c(
      "Download it from https://git-scm.com/downloads",
      "Quit R and open it again afterwards"
    ))
  }

  ok <- length(required_missing) == 0L && quarto_ok && nzchar(git_path)
  if (ok) {
    cli::cli_h2("Result")
    cli::cli_alert_success("Everything the course needs is installed.")
  }

  invisible(ok)
}
