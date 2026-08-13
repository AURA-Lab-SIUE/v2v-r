#' Scaffold a new V2V White Paper project
#'
#' Creates the project structure the White Paper is graded against: the IMRaD
#' sections as separate `.qmd` files, an abstract, a reflection, a references
#' stub, plus the working directories that feed them (weekly journals, the
#' codebook, a data tree with `data/raw/` gitignored, and a figures directory).
#' Also writes a `_quarto.yml` configured as a Quarto Book. Wraps
#' [usethis::create_project()] so the project is also an RStudio-recognized
#' project.
#'
#' This is the function students run once, at the start of MC 451 or MC 501, to
#' start the project that accumulates their journals, codebook, and White Paper
#' over the semester. Every file it creates is referenced by `_quarto.yml`, so
#' `quarto render` succeeds on a freshly scaffolded project before a single word
#' has been written.
#'
#' @param path Path at which to create the project. Defaults to
#'   `"v2v-whitepaper"` in the current working directory.
#' @param open Logical. If `TRUE` (default `FALSE` here, override of
#'   `usethis::create_project()` default), open the new project in RStudio.
#' @return Invisibly returns the path created.
#' @examples
#' \dontrun{
#' library(v2v)
#' new_portfolio("~/Documents/mc451-whitepaper")
#' }
#' @export
new_portfolio <- function(path = "v2v-whitepaper", open = FALSE) {
  usethis::create_project(path = path, open = open)

  subdirs <- c("journals", "codebook", "data/raw", "data/derived", "figures")
  for (d in subdirs) {
    dir.create(file.path(path, d), recursive = TRUE, showWarnings = FALSE)
  }

  writeLines(
    c(".Rhistory", ".RData", ".Ruserdata", ".Rproj.user/",
      "data/raw/", "*.csv", "!data/derived/*.csv",
      "_freeze/", "/.quarto/"),
    con = file.path(path, ".gitignore")
  )

  # A stub for every file _quarto.yml names. A scaffold whose book config
  # points at files it never created fails to render on the first try, which
  # is the worst possible moment for a student's first Quarto error.
  section <- function(title, guidance) {
    c("---", paste0("title: \"", title, "\""), "---", "", guidance, "")
  }

  stubs <- list(
    "index.qmd" = c(
      "---",
      "title: \"White Paper\"",
      "subtitle: \"Student Name | Course Code | Semester\"",
      "---",
      "",
      "# Abstract",
      "",
      "Write this LAST. About 150 words summarising all four IMRaD sections:",
      "what you studied, how you studied it, what you found, and why it",
      "matters. Fill in your name, course code, and semester in the YAML above.",
      ""
    ),
    "01-introduction.qmd" = section(
      "Introduction",
      c("State the question and why it is worth asking. Introduce the",
        "theoretical lens and make it do work rather than decoration, then",
        "list your research questions. Draws on your Project Prospectus and",
        "your Topic Selection and Research Questions assignment.")
    ),
    "02-methods.qmd" = section(
      "Methods",
      c("Say exactly what was done, in enough detail that another researcher",
        "could repeat it: data provenance, the sampling procedure, the",
        "variable definitions from your codebook, the reliability check, and",
        "the wrangling steps.")
    ),
    "03-results.qmd" = section(
      "Results",
      c("Report what was found, plainly and without interpretation:",
        "distributions, group comparisons, and the test statistic with its",
        "degrees of freedom, its p-value, and its effect size. Label and",
        "caption every figure. Use inline R for every number in the prose so",
        "nothing goes stale when the data changes.")
    ),
    "04-discussion.qmd" = section(
      "Discussion",
      c("Say what the results mean, answer the question the Introduction",
        "asked, characterise the effect size accurately rather than inflating",
        "it, and state the study's limits honestly.")
    ),
    "05-reflection.qmd" = section(
      "Reflection",
      c("One specific paragraph: what proved harder than expected, where a",
        "rule was ambiguous in practice, what the data could not answer, and",
        "what a second attempt would change. Graded on candour and precision,",
        "not on whether the study went well.")
    ),
    "references.qmd" = c(
      "---",
      "title: \"References\"",
      "---",
      "",
      "::: {#refs}",
      ":::",
      ""
    ),
    "journals/week-01.qmd" = section(
      "Week 1 Journal",
      "One entry per teaching week. Copy this file for each new week."
    ),
    "codebook/codebook.qmd" = section(
      "Codebook",
      c("Every variable, with its conceptual definition, its operational",
        "definition, and its coding rules.")
    )
  )

  for (f in names(stubs)) {
    writeLines(stubs[[f]], con = file.path(path, f))
  }

  writeLines(character(0), con = file.path(path, "references.bib"))

  quarto_yml <- c(
    "project:",
    "  type: book",
    "  output-dir: docs",
    "",
    "book:",
    "  title: \"White Paper\"",
    "  author: \"Student Name\"",
    "  chapters:",
    "    - index.qmd",
    "    - 01-introduction.qmd",
    "    - 02-methods.qmd",
    "    - 03-results.qmd",
    "    - 04-discussion.qmd",
    "    - 05-reflection.qmd",
    "    - references.qmd",
    "    - part: \"Appendices\"",
    "      chapters:",
    "        - codebook/codebook.qmd",
    "        - journals/week-01.qmd",
    "",
    "bibliography: references.bib",
    "csl: https://www.zotero.org/styles/apa",
    "",
    "format:",
    "  html:",
    "    theme: cosmo",
    "  pdf:",
    "    documentclass: scrreprt"
  )
  writeLines(quarto_yml, con = file.path(path, "_quarto.yml"))

  cli::cli_alert_success("V2V White Paper scaffolded at {.path {normalizePath(path)}}")
  cli::cli_alert_info("Edit {.file index.qmd} to set your name and course.")

  invisible(path)
}
