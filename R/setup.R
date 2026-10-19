#' Validate the V2V student toolchain
#'
#' Verifies that the R packages and command-line tools the course expects
#' are installed and reachable. Run at the end of Chapter 2 to confirm the
#' install before any code chapters begin. Prints a checklist of green
#' checks for what is present and red x marks for what is missing, followed
#' by copy-paste instructions for anything that is not.
#'
#' Checked items:
#' - R itself, at version 4.1 or later.
#' - Required packages: the ones installed alongside `v2v` (`cli`, `dplyr`,
#'   `ggplot2`, `irr`, `knitr`, `rlang`, `tibble`, `usethis`), plus the
#'   course packages every script loads or every render needs: `tidyverse`,
#'   `rmarkdown` (Quarto renders R chunks through it), and `remotes` (it
#'   reinstalls `v2v`). `dplyr` must be 1.1.0 or later, because
#'   [join_chat_streams()] uses `join_by()`.
#' - Course packages for the course named in `course`: `janitor` for both
#'   courses, and for MC 501 also `effectsize`, `lm.beta`, `pwr`, and `renv`.
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
#' @param course `NULL` (the default) for the packages every V2V course
#'   needs, or `"mc451"` or `"mc501"` to add that course's packages.
#' @param quiet If `TRUE`, print nothing and only return the result. Tools
#'   such as the AURA Lab R Companion use this to read the checks.
#' @return Invisibly returns a logical: `TRUE` if everything required is
#'   present, `FALSE` otherwise. It carries an attribute, `"checks"`, a
#'   tibble with one row per item checked and the columns `item`, `kind`
#'   (`"r"`, `"required"`, `"course"`, `"suggested"`, or `"tool"`), `ok`,
#'   `version`, `minimum`, and `detail`, so a tool can read the result
#'   without parsing the printed checklist.
#' @examples
#' \dontrun{
#' library(v2v)
#' setup()
#' setup(course = "mc501")
#'
#' # The checks as a table
#' attr(setup(quiet = TRUE), "checks")
#' }
#' @export
setup <- function(course = NULL, quiet = FALSE) {
  if (!is.null(course)) {
    course <- match.arg(course, c("mc451", "mc501"))
  }

  # The package's own Imports arrive with v2v, so listing them is reassurance
  # rather than diagnosis, but a partial or interrupted install does show up
  # here. The next three are not Imports and were never checked before 0.3.3,
  # so setup() could print "Everything the course needs is installed" on a
  # machine with no tidyverse, the first library() line of every course script.
  required_pkgs <- c("cli", "dplyr", "ggplot2", "irr", "knitr", "rlang",
                     "tibble", "usethis", "tidyverse", "rmarkdown", "remotes")
  course_pkgs <- switch(
    if (is.null(course)) "none" else course,
    none  = character(),
    mc451 = c("janitor"),
    mc501 = c("janitor", "effectsize", "lm.beta", "pwr", "renv")
  )
  # `quarto` is the only genuine Suggests a student needs. `lubridate` used to
  # be listed here and was never used by the package nor declared in
  # DESCRIPTION, so every student was told to install something for nothing.
  suggested_pkgs <- c("quarto")
  minimum <- c(dplyr = "1.1.0")

  checks <- list()
  add <- function(item, kind, ok, version = NA_character_,
                  minimum = NA_character_, detail = NA_character_) {
    checks[[length(checks) + 1L]] <<- tibble::tibble(
      item = item, kind = kind, ok = ok, version = version,
      minimum = minimum, detail = detail
    )
  }
  check_pkg <- function(p, kind) {
    have <- requireNamespace(p, quietly = TRUE)
    ver <- if (have) as.character(utils::packageVersion(p)) else NA_character_
    min_ver <- if (p %in% names(minimum)) minimum[[p]] else NA_character_
    new_enough <- !have || is.na(min_ver) ||
      utils::compareVersion(ver, min_ver) >= 0
    add(p, kind, have && new_enough, ver, min_ver,
        if (!have) "missing" else if (!new_enough) "too old" else NA_character_)
  }

  r_ver <- paste(R.version$major, R.version$minor, sep = ".")
  add("R", "r", utils::compareVersion(r_ver, "4.1.0") >= 0, r_ver, "4.1.0")
  for (p in required_pkgs) check_pkg(p, "required")
  for (p in course_pkgs) check_pkg(p, "course")
  for (p in suggested_pkgs) check_pkg(p, "suggested")

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
  add("Quarto CLI", "tool", nzchar(quarto_cli),
      detail = if (nzchar(quarto_cli)) quarto_cli else "not found")
  git_path <- unname(Sys.which("git"))
  add("Git", "tool", nzchar(git_path),
      detail = if (nzchar(git_path)) git_path else "not found")

  checks <- dplyr::bind_rows(checks)
  ok <- all(checks$ok[checks$kind %in% c("r", "required", "course", "tool")])

  if (!quiet) print_setup(checks, ok)

  attr(ok, "checks") <- checks
  invisible(ok)
}

# The checklist setup() prints. Kept apart from the checks so that setup(quiet
# = TRUE) and the printed version can never disagree about what was found.
print_setup <- function(checks, ok) {
  cli::cli_h1("V2V toolchain check")

  line <- function(row) {
    label <- if (is.na(row$version) || row$kind == "tool") row$item else
      paste0(row$item, " ", row$version)
    if (row$ok) {
      if (row$kind == "tool") {
        cli::cli_alert_success("{label} ({.path {row$detail}})")
      } else {
        cli::cli_alert_success("{.pkg {label}}")
      }
    } else if (row$kind == "suggested") {
      cli::cli_alert_warning("{.pkg {row$item}} (missing, recommended)")
    } else if (row$kind == "tool") {
      cli::cli_alert_danger("{row$item} not found")
    } else if (identical(row$detail, "too old")) {
      cli::cli_alert_danger("{.pkg {label}} (too old: {row$minimum} or later needed)")
    } else if (row$kind == "r") {
      cli::cli_alert_danger("R {row$version} (too old: {row$minimum} or later needed)")
    } else {
      cli::cli_alert_danger("{.pkg {row$item}} (missing)")
    }
  }
  section <- function(title, kinds) {
    rows <- checks[checks$kind %in% kinds, ]
    if (nrow(rows) == 0) return(invisible())
    cli::cli_h2(title)
    for (i in seq_len(nrow(rows))) line(rows[i, ])
  }
  section("R", "r")
  section("Required R packages", "required")
  section("Course R packages", "course")
  section("Suggested R packages", "suggested")
  section("Command-line tools", "tool")

  # Two kinds of fix, kept apart on purpose. Anything install.packages() can
  # solve goes in the first block; anything it CANNOT goes in the second, so a
  # student never runs install.packages on quarto expecting to get the CLI.
  #
  # The cli markup here is deliberately plain. Nested quotes inside a {.code }
  # span and empty cli_text() calls are the fragile constructs, and this file
  # ships to a whole class at once, so anything clever that fails at runtime
  # breaks setup() for everybody. Bare strings and one inline class per line.
  pkg_fix <- checks$item[checks$kind %in% c("required", "course", "suggested") & !checks$ok]
  r_old <- any(checks$kind == "r" & !checks$ok)
  quarto_ok <- checks$ok[checks$item == "Quarto CLI"]
  git_ok <- checks$ok[checks$item == "Git"]

  if (length(pkg_fix) > 0 || r_old || !quarto_ok || !git_ok) {
    cli::cli_h2("What to do next")
  }

  if (r_old) {
    cli::cli_text("Your R is too old for this course. Install the current R from https://cloud.r-project.org, then open VS Code again.")
  }

  if (length(pkg_fix) > 0) {
    cli::cli_text("Install the missing R packages:")
    cli::cli_code(sprintf("install.packages(c(%s), repos = \"https://cloud.r-project.org\")",
                          paste0('"', pkg_fix, '"', collapse = ", ")))
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

  if (!git_ok) {
    cli::cli_text(" ")
    cli::cli_text("Git is also a separate program, not an R package.")
    cli::cli_ul(c(
      "Download it from https://git-scm.com/downloads",
      "Quit R and open it again afterwards"
    ))
  }

  if (ok) {
    cli::cli_h2("Result")
    cli::cli_alert_success("Everything the course needs is installed.")
  }
  invisible()
}
