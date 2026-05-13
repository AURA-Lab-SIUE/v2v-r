#' Scaffold a new V2V student portfolio project
#'
#' Creates the canonical V2V portfolio folder structure introduced in
#' Chapter 2: weekly journals, a codebook directory, a data tree (with
#' `data/raw/` gitignored), a figures directory, a final-report directory,
#' a starter `index.qmd`, a `_quarto.yml` configured as a Quarto Book, and
#' a `.gitignore`. Wraps [usethis::create_project()] so the project is also
#' an RStudio-recognized project.
#'
#' This is the function students run once at the start of MC-451 to start
#' a new portfolio that will accumulate their journals, prospectus,
#' codebook, and final feature article over the semester.
#'
#' @param path Path at which to create the project. Defaults to
#'   `"v2v-portfolio"` in the current working directory.
#' @param open Logical. If `TRUE` (default `FALSE` here, override of
#'   `usethis::create_project()` default), open the new project in RStudio.
#' @return Invisibly returns the path created.
#' @examples
#' \dontrun{
#' library(v2v)
#' new_portfolio("~/Documents/mc451-portfolio")
#' }
#' @export
new_portfolio <- function(path = "v2v-portfolio", open = FALSE) {
  usethis::create_project(path = path, open = open)

  subdirs <- c("journals", "codebook", "data/raw", "data/derived",
               "figures", "report")
  for (d in subdirs) {
    dir.create(file.path(path, d), recursive = TRUE, showWarnings = FALSE)
  }

  writeLines(
    c(".Rhistory", ".RData", ".Ruserdata", ".Rproj.user/",
      "data/raw/", "*.csv", "!data/derived/*.csv",
      "_freeze/", "/.quarto/"),
    con = file.path(path, ".gitignore")
  )

  index_qmd <- c(
    "---",
    "title: \"V2V Portfolio\"",
    "subtitle: \"Student Name | Course Code | Semester\"",
    "format: html",
    "---",
    "",
    "# About this portfolio",
    "",
    "This is a starter portfolio created by `v2v::new_portfolio()`. Fill in",
    "your name, course code, and semester in the YAML above. Each weekly",
    "journal goes in `journals/`. Your codebook lives in `codebook/`. The",
    "final feature article lives in `report/`.",
    "",
    "## Project structure",
    "",
    "- `journals/`: weekly term-anchored reflections (Chapters 1 through 13).",
    "- `codebook/`: draft and final codebooks.",
    "- `data/raw/`: source data (gitignored).",
    "- `data/derived/`: cleaned, analysis-ready data.",
    "- `figures/`: exported plots.",
    "- `report/`: the feature article (`report/index.qmd`) and its",
    "  methodology appendix (`report/methods.qmd`)."
  )
  writeLines(index_qmd, con = file.path(path, "index.qmd"))

  quarto_yml <- c(
    "project:",
    "  type: book",
    "  output-dir: docs",
    "",
    "book:",
    "  title: \"V2V Portfolio\"",
    "  author: \"Student Name\"",
    "  chapters:",
    "    - index.qmd",
    "    - part: \"Journals\"",
    "      chapters:",
    "        - journals/week-01.qmd",
    "    - part: \"Codebook\"",
    "      chapters:",
    "        - codebook/codebook.qmd",
    "    - part: \"Feature Article\"",
    "      chapters:",
    "        - report/index.qmd",
    "        - report/methods.qmd",
    "",
    "format:",
    "  html:",
    "    theme: cosmo"
  )
  writeLines(quarto_yml, con = file.path(path, "_quarto.yml"))

  cli::cli_alert_success("V2V portfolio scaffolded at {.path {normalizePath(path)}}")
  cli::cli_alert_info("Edit {.file index.qmd} to set your name and course.")

  invisible(path)
}
