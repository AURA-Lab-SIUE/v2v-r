#' Deploy a student portfolio to GitHub Pages
#'
#' Runs a three-step pre-flight checklist before publishing: verifies that the
#' `renv` library is synchronized, that there are no uncommitted changes in the
#' project folder, and that a `_quarto.yml` file exists in the project root. If
#' all checks pass, the function renders the Quarto project and publishes it to
#' GitHub Pages with the Quarto command line tool (`quarto publish gh-pages`).
#'
#' This function is designed to be called from the root of a student Quarto
#' portfolio project (the directory that contains `_quarto.yml`), or with
#' `path` pointing at it. The project may sit inside a larger git repository,
#' such as the course workspace: the site is published to the `gh-pages`
#' branch of that repository's `origin` remote.
#'
#' The uncommitted-changes check covers the project folder only, and skips the
#' rendered output folder (`output-dir` in `_quarto.yml`, `docs` by default),
#' because every render rewrites it.
#'
#' On the first publish the `origin` remote has no `gh-pages` branch, and
#' `quarto publish` will not create one without asking. This function creates
#' an empty one first, without touching the files in the working folder.
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

  # -- Check 1: renv sync ------------------------------------------------------
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
    cli::cli_alert_info("No renv.lock found - skipping renv check")
  }

  # -- Check 2: No uncommitted git changes -------------------------------------
  # Only the project folder counts, and not its rendered output: every render
  # rewrites the output folder (the PDF differs on each one), so counting it
  # failed this check on every run after the first.
  output_dir <- portfolio_output_dir(path)
  git_result <- git_run(path, c(
    "status", "--porcelain", "--", ".",
    shQuote(paste0(":(exclude)", output_dir))
  ))

  if (is.null(git_result)) {
    cli::cli_alert_warning("git not available - skipping uncommitted-changes check")
  } else if (!git_result$ok) {
    cli::cli_alert_warning("not inside a git repository - skipping uncommitted-changes check")
  } else if (length(git_result$out) == 0) {
    cli::cli_alert_success("no uncommitted changes")
  } else {
    cli::cli_alert_danger("uncommitted changes detected")
    cli::cli_inform(c(
      "i" = "Commit or stash your changes before deploying.",
      " " = paste(git_result$out, collapse = "\n")
    ))
    ok <- FALSE
  }

  # -- Check 3: _quarto.yml exists ---------------------------------------------
  quarto_yml <- file.path(path, "_quarto.yml")
  # This check only looks for the file; it does not validate it, so the message says "found".
  if (file.exists(quarto_yml)) {
    cli::cli_alert_success("_quarto.yml found in {.path {path}}")
  } else {
    cli::cli_alert_danger("_quarto.yml not found in {.path {path}}")
    # A student running this from the course workspace's top folder usually has the project one
    # folder down (new_portfolio() makes it there), so name that folder instead of the jargon
    # "project root".
    subdirs <- list.dirs(path, recursive = FALSE)
    projects <- basename(subdirs[file.exists(file.path(subdirs, "_quarto.yml"))])
    if (length(projects) == 1) {
      cli::cli_inform(c(
        "i" = "Your project looks like the {.path {projects}} folder. Run {.code v2v::deploy_portfolio(\"{projects}\")}."
      ))
    } else {
      cli::cli_inform(c(
        "i" = "Give the folder {.fn v2v::new_portfolio} made, the one that holds _quarto.yml, for example {.code v2v::deploy_portfolio(\"v2v-whitepaper\")}."
      ))
    }
    ok <- FALSE
  }

  if (!ok) {
    cli::cli_alert_danger(
      "Deploy cancelled: fix the issues above, then re-run {.fn v2v::deploy_portfolio}."
    )
    return(invisible(FALSE))
  }

  cli::cli_rule()

  # -- Render -------------------------------------------------------------------
  if (render) {
    n_qmds <- length(list.files(path, pattern = "\\.qmd$", recursive = TRUE))
    cli::cli_progress_step("Rendering {n_qmds} page{?s}")
    result <- tryCatch(
      quarto::quarto_render(input = path),
      error = function(e) e
    )
    if (inherits(result, "error")) {
      cli::cli_progress_done(result = "failed")
      # The quarto package's own message can carry raw LaTeX log text; its
      # first line is the part a student needs.
      first_line <- strsplit(conditionMessage(result), "\n", fixed = TRUE)[[1]][1]
      cli::cli_alert_danger("Render failed: {first_line}")
      cli::cli_inform(c(
        "i" = "If the output above says {.strong No TeX installation was detected},
               the PDF needs TinyTeX. In the terminal, run {.code quarto install tinytex},
               then quit R, open it again, and re-run {.fn v2v::deploy_portfolio}."
      ))
      return(invisible(FALSE))
    }
    cli::cli_progress_done()
  }

  # -- Confirm before publish ---------------------------------------------------
  if (ask) {
    answer <- readline("Publish to GitHub Pages? [y/N] ")
    if (!tolower(trimws(answer)) %in% c("y", "yes")) {
      cli::cli_alert_info("Publish cancelled.")
      return(invisible(FALSE))
    }
  }

  # -- Publish ------------------------------------------------------------------
  # quarto::quarto_publish_site() publishes to Posit Connect through rsconnect;
  # it has no GitHub Pages route, so this calls the Quarto CLI directly.
  cli::cli_progress_step("Publishing to GitHub Pages")
  # The step belongs to this function's frame. Called from inside failed(), a bare
  # cli_progress_done() looked in failed()'s own frame, found no step, and did nothing, so the
  # step closed itself with a success tick when deploy_portfolio() returned: students saw
  # "Publish failed" followed by a green "Publishing to GitHub Pages".
  deploy_env <- environment()
  failed <- function(msg) {
    cli::cli_progress_done(result = "failed", .envir = deploy_env)
    cli::cli_alert_danger("Publish failed: {msg}")
    invisible(FALSE)
  }

  quarto_bin <- quarto_cli_path()
  if (!nzchar(quarto_bin)) {
    return(failed("the Quarto CLI was not found. Run v2v::setup() for the fix."))
  }

  branch_msg <- ensure_gh_pages(path)
  if (!is.null(branch_msg)) return(failed(branch_msg))

  # quarto publish reads the git remote from its working directory, not from
  # the path it is given, so it runs from inside the project.
  old_wd <- setwd(path)
  on.exit(setwd(old_wd), add = TRUE)
  pub <- suppressWarnings(tryCatch(
    system2(quarto_bin,
            args = c("publish", "gh-pages", "--no-prompt", "--no-render"),
            stdout = TRUE, stderr = TRUE),
    error = function(e) structure(conditionMessage(e), status = 1L)
  ))
  setwd(old_wd)
  pub_status <- attr(pub, "status")
  if (!is.null(pub_status) && pub_status != 0) {
    return(failed(paste(cli::ansi_strip(pub), collapse = "\n")))
  }
  cli::cli_progress_done()

  published <- grep("Published to", cli::ansi_strip(pub), value = TRUE)
  if (length(published) > 0) {
    cli::cli_alert_info(trimws(sub(".*Published to", "Published to", published[1])))
  }
  cli::cli_alert_success("Portfolio live on GitHub Pages.")

  invisible(TRUE)
}

# The output folder named in _quarto.yml (`output-dir:`), "docs" when unset.
portfolio_output_dir <- function(path) {
  yml <- file.path(path, "_quarto.yml")
  if (!file.exists(yml)) return("docs")
  hit <- grep("^\\s*output-dir:", readLines(yml, warn = FALSE), value = TRUE)
  if (length(hit) == 0) return("docs")
  dir <- trimws(gsub("[\"']", "", sub("^\\s*output-dir:", "", hit[1])))
  if (nzchar(dir)) dir else "docs"
}

# Run git in `path`. Returns list(ok, out), or NULL when git cannot be run.
git_run <- function(path, args) {
  out <- suppressWarnings(tryCatch(
    system2("git", args = c("-C", shQuote(path), args), stdout = TRUE, stderr = TRUE),
    error = function(e) NULL
  ))
  if (is.null(out)) return(NULL)
  status <- attr(out, "status")
  list(ok = is.null(status) || status == 0, out = as.character(out))
}

quarto_cli_path <- function() {
  bin <- unname(Sys.which("quarto"))
  if (!nzchar(bin) && requireNamespace("quarto", quietly = TRUE)) {
    bin <- tryCatch(quarto::quarto_path(), error = function(e) NULL)
    if (is.null(bin)) bin <- ""
  }
  bin
}

# Make sure the origin remote has a gh-pages branch. Returns NULL when it does
# (or now does), otherwise a message saying what stopped it.
ensure_gh_pages <- function(path) {
  origin <- git_run(path, c("remote", "get-url", "origin"))
  if (is.null(origin)) return("git was not found. Run v2v::setup() for the fix.")
  if (!origin$ok) {
    return("this folder is not connected to a GitHub repository (git has no origin remote).")
  }

  heads <- git_run(path, c("ls-remote", "--heads", "origin", "gh-pages"))
  if (is.null(heads) || !heads$ok) {
    return(paste(c("could not reach the GitHub repository.", heads$out), collapse = "\n"))
  }
  if (any(grepl("refs/heads/gh-pages", heads$out, fixed = TRUE))) return(NULL)

  # First publish. Build an empty commit from the empty tree and push it as
  # gh-pages: the working folder and the current branch are never touched.
  empty <- tempfile()
  on.exit(unlink(empty), add = TRUE)
  file.create(empty)
  tree <- git_run(path, c("hash-object", "-w", "-t", "tree", shQuote(empty)))
  if (is.null(tree) || !tree$ok) return(paste(c("could not start the gh-pages branch.", tree$out), collapse = "\n"))
  commit <- git_run(path, c("commit-tree", tree$out[1], "-m", shQuote("Initializing gh-pages branch")))
  if (is.null(commit) || !commit$ok) return(paste(c("could not start the gh-pages branch.", commit$out), collapse = "\n"))
  push <- git_run(path, c("push", "origin", paste0(commit$out[1], ":refs/heads/gh-pages")))
  if (is.null(push) || !push$ok) return(paste(c("could not create the gh-pages branch on GitHub.", push$out), collapse = "\n"))
  NULL
}
