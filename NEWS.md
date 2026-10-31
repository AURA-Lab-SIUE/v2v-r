# v2v 0.3.7

Released with the AURA Lab R Companion 0.6.0 (labor #rgui, 2026-10-31).

* `deploy_portfolio()`: when publishing fails, the "Publishing to GitHub Pages" step now
  ends with a cross. It ended with a green tick right after "Publish failed:", because the
  step was closed from inside a helper function that could not see it.
* `deploy_portfolio()`: the `_quarto.yml` check says "found" (it checks that the file is
  there, not that it is valid), and when the file is missing it names the folder that holds
  your project instead of saying "project root".
* `deploy_portfolio()` checks for the quarto R package before rendering and says how to
  install it. Without it, the render failed with "there is no package called 'quarto'".

# v2v 0.3.6

* `deploy_portfolio()` publishes to GitHub Pages. It called
  `quarto::quarto_publish_site()`, which publishes to Posit Connect through rsconnect
  and has no GitHub Pages route, so every deploy ended in `Publish failed:` with an
  empty message. It now runs `quarto publish gh-pages` from inside the project.
* On the first deploy, `deploy_portfolio()` creates an empty `gh-pages` branch on the
  `origin` remote before publishing, because `quarto publish` will not create one
  without asking. It does this without touching the working folder or switching
  branches. A project with no `origin` remote stops with a message saying so.
* The uncommitted-changes check covers the project folder only and skips its rendered
  output folder (`output-dir` in `_quarto.yml`, `docs` by default). Every render
  rewrites that folder, so the check had failed on every deploy after the first, and
  an unsaved file elsewhere in the course workspace no longer blocks a deploy.
* A failed render or publish now prints the actual error. A render that fails for lack
  of a TeX installation names the fix, `quarto install tinytex`.

# v2v 0.3.5

Released with the AURA Lab R Companion 0.5.3 (labor #rgui, 2026-10-22).

* `setup()` has a **VS Code** section: it reports `languageserver` (code completion
  and help) and `httpgd` (plots in a VS Code panel), which the R extension for VS Code
  uses, and adds any missing one to the install line it prints. A missing one does not
  fail the check, so a student working from plain R still passes. On R 4.6 or later it
  also notes that VS Code's R extension must be 3.0.0 or newer, because earlier versions
  never connect to R 4.6 and leave the Workspace panel empty. The `"checks"` table gains
  the kind `"vscode"`.
* `?common_errors` gains three sections: `R: (not attached)` or `Connection to server
  got closed` in VS Code, the stray `[200~` and `[201~` characters, and `file is in use`
  or `cannot remove prior installation` on Windows. Each names the R Companion's one-click
  fix first and the manual steps second.

# v2v 0.3.4

* Corrected a stale GitHub path in the 0.3.0 release note: the reinstall command
  cited `aura-lab/v2v-r`, which does not resolve. Every install line in the package
  now names the canonical `AURA-Lab-SIUE/v2v-r`. The `?v2v::common_errors` reinstall
  advice already names it; this fixes the one remaining wrong reference.

# v2v 0.3.3

Released for the AURA Lab R Companion (labor #rgui, 2026-10-19).

* `setup()` now checks R 4.1 or later, the `tidyverse`, `rmarkdown`, and `remotes`,
  and `dplyr` 1.1.0 or later, so it can no longer report "Everything the course
  needs is installed" on a machine without the tidyverse. `setup(course = "mc451")`
  and `setup(course = "mc501")` add each course's packages. The result carries a
  `"checks"` table, and `setup(quiet = TRUE)` returns it without printing, so a tool
  can read the result instead of parsing the checklist.
* `reliability()` prints a short report (items, observed agreement, the statistic,
  its label, and the `irr` call that computes the same number) instead of a raw
  list, and returns `n` and `agreement` as well. Krippendorff's alpha no longer
  warns "NAs introduced by coercion" on text codes; the value is unchanged.
* `run_t_test()` prints each group's n, mean, and SD, and `run_chi_square()` prints
  the smallest expected count, both with their columns aligned again. Both print
  the plain R call that runs the same test, and report an exact p-value
  (`= .040`, `< .001`) where they used to print `< .01`. The returned lists gain
  `n_a`, `n_b`, `sd_a`, `sd_b`, `levels`, `n`, and `min_expected`; no element
  was removed or renamed.
* `join_chat_streams()` keeps the chat's `ts` column as `ts` and adds the matched
  snapshot's time as `snapshot_ts`. In 0.3.2 the two came back as `ts.x` and `ts.y`,
  so code after the join that used `ts` found `stats::ts()` and failed.
* `join_chat_streams()` and `clean_dates()` name the plain dplyr or lubridate call they
  stand for, once per session (`options(v2v.show_equivalent = FALSE)` turns it off).
* `?common_errors`: the Quarto section no longer repeats the diagnosis that 0.3.1
  fixed, and the reinstall advice names the working command.
* DESCRIPTION: the author ORCID is corrected to 0000-0003-1310-6763 (the old one
  failed R's checksum and warned on every install).

# v2v 0.3.2

The package code is now licensed under MIT (`LICENSE.md`); the two bundled Twitch
datasets and the documentation stay under CC BY 4.0 (`LICENSE-DATA.md`). Nothing
else changed.

`new_portfolio()` no longer overwrites a project in use. Run a second time on the
same folder, it used to replace the codebook and every White Paper section with
blank stubs, without a warning. It now stops and says the project already exists.

`new_portfolio()` also works from inside the course workspace. The workspace is a
git repository, so the scaffold used to stop and ask whether to create a project
inside another one. That nesting is the intended layout, so it no longer asks.

# v2v 0.3.0

`new_portfolio()` now scaffolds the white paper the Fall 2026 syllabi actually
assign. The 0.2.0 scaffold was left over from an earlier course design: it
created a "feature article" report, and its `_quarto.yml` listed four chapter
files the function never wrote, so a student's first `quarto render` failed.

The new scaffold is IMRaD, and every file named in `_quarto.yml` exists:

    index.qmd            abstract
    01-introduction.qmd  02-methods.qmd  03-results.qmd
    04-discussion.qmd    05-reflection.qmd
    references.qmd       references.bib
    journals/week-01.qmd codebook/codebook.qmd
    data/raw/  data/derived/  figures/

**If you scaffolded a portfolio before this release**, your folder does not
match the white paper rubric. Scaffold a fresh one and move your writing into
it rather than renaming files in place.

Reinstall with:

    remotes::install_github("AURA-Lab-SIUE/v2v-r")

# v2v 0.2.0

Twitch chat and stream sample data; sampling, reliability and timestamp
helpers; the original portfolio scaffold.
