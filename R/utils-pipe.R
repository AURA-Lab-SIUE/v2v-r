#' Pipe operator
#'
#' Re-exported from dplyr (originally magrittr) so that `library(v2v)` gives
#' students the tidyverse pipe without a separate library call.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL
