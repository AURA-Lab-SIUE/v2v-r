# Startup message. Students in MC 451 and MC 501 load this package in week 2,
# often on the first day they have ever opened R, and `library(v2v)` printing
# absolutely nothing is indistinguishable from a failure to someone who does not
# yet know that silence is how success looks in R. The message says the load
# worked, names the version so a student can confirm they have the fix an
# instructor told them to install, and points at the one function they are meant
# to run next.
#
# packageStartupMessage, not message or cat: it is the only one that
# suppressPackageStartupMessages() can silence, which matters because this
# package is loaded inside rendered .qmd documents where the banner would
# otherwise land in the student's finished paper.

.onAttach <- function(libname, pkgname) {
  version <- utils::packageVersion(pkgname)
  packageStartupMessage(
    "v2v ", version, " loaded.\n",
    "  setup()  checks that R, Quarto and Git are ready\n",
    "  ?v2v     lists what this package gives you"
  )
}
