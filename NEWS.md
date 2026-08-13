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
