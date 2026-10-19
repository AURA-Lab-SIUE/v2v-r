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

    remotes::install_github("aura-lab/v2v-r")

# v2v 0.2.0

Twitch chat and stream sample data; sampling, reliability and timestamp
helpers; the original portfolio scaffold.
