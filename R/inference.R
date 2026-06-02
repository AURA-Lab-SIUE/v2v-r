#' Welch two-sample t-test with Cohen's d
#'
#' Wraps [stats::t.test()] (Welch variant, unequal-variance default) and
#' computes Cohen's d as the effect-size measure. Prints a student-legible
#' summary and returns the full results invisibly for further inspection.
#' Introduced in Chapter 13.
#'
#' Cohen's d benchmarks (Cohen, 1988): 0.2 = small, 0.5 = medium, 0.8 = large.
#' Below 0.2 is described as negligible.
#'
#' @param data A data frame containing the value and group columns.
#' @param value <[`tidy-select`][dplyr::dplyr_tidy_select]> Unquoted name of
#'   the numeric outcome variable (e.g., `message_length`).
#' @param group <[`tidy-select`][dplyr::dplyr_tidy_select]> Unquoted name of
#'   the grouping variable. Must have exactly two distinct non-NA levels.
#' @return A list (returned invisibly) with elements `t`, `df`, `p_value`,
#'   `mean_a`, `mean_b`, `cohens_d`, `interpretation`, and `raw` (the
#'   underlying [stats::t.test()] result).
#' @examples
#' library(v2v)
#' library(dplyr)
#'
#' chat <- twitch_chat() |>
#'   mutate(message_length = nchar(message))
#'
#' channel_type <- twitch_streams() |>
#'   filter(!is.na(game)) |>
#'   count(channel, game) |>
#'   group_by(channel) |>
#'   slice_max(n, n = 1, with_ties = FALSE) |>
#'   ungroup() |>
#'   mutate(is_gaming = !(game %in% c("Art", "Just Chatting", "Music"))) |>
#'   select(channel, is_gaming)
#'
#' analysis <- chat |> left_join(channel_type, by = "channel")
#'
#' run_t_test(analysis, value = message_length, group = is_gaming)
#' @export
run_t_test <- function(data, value, group) {
  val_expr <- rlang::enquo(value)
  grp_expr <- rlang::enquo(group)

  val_name <- rlang::as_label(val_expr)
  grp_name <- rlang::as_label(grp_expr)

  vals <- dplyr::pull(data, !!val_expr)
  grps <- dplyr::pull(data, !!grp_expr)

  keep <- !is.na(vals) & !is.na(grps)
  vals <- vals[keep]
  grps <- grps[keep]

  levels <- sort(unique(grps))
  if (length(levels) != 2L) {
    cli::cli_abort(
      "{.arg {grp_name}} must have exactly two non-NA levels; found {length(levels)}."
    )
  }

  a_vals <- vals[grps == levels[1]]
  b_vals <- vals[grps == levels[2]]

  raw <- stats::t.test(a_vals, b_vals, var.equal = FALSE)

  n_a <- length(a_vals); n_b <- length(b_vals)
  s_a <- stats::sd(a_vals); s_b <- stats::sd(b_vals)
  sp  <- sqrt(((n_a - 1) * s_a^2 + (n_b - 1) * s_b^2) / (n_a + n_b - 2))
  d   <- (mean(a_vals) - mean(b_vals)) / sp

  interp <- dplyr::case_when(
    abs(d) < 0.20 ~ "negligible",
    abs(d) < 0.50 ~ "small",
    abs(d) < 0.80 ~ "medium",
    .default      = "large"
  )

  p_fmt <- if (raw$p.value < .001) "< .001" else
    if (raw$p.value < .01) "< .01" else
      formatC(raw$p.value, digits = 3, format = "f")

  sig_word <- if (raw$p.value < .05) "statistically significant" else
    "not statistically significant"

  cli::cli_text("{.strong Welch two-sample t-test}")
  cli::cli_text("{val_name} by {grp_name}")
  cli::cli_text("")
  cli::cli_text("  Mean ({levels[1]})      {round(mean(a_vals), 2)}")
  cli::cli_text("  Mean ({levels[2]})      {round(mean(b_vals), 2)}")
  cli::cli_text("  Difference         {round(mean(a_vals) - mean(b_vals), 2)}")
  cli::cli_text("")
  cli::cli_text("  t                  {round(unname(raw$statistic), 2)}")
  cli::cli_text("  df                 {round(unname(raw$parameter), 1)}")
  cli::cli_text("  p-value            {p_fmt}")
  cli::cli_text("  Cohen's d          {round(d, 2)}  ({interp})")
  cli::cli_text("")
  cli::cli_text(
    "  {levels[1]} and {levels[2]} differ by a {sig_word}, {interp} amount."
  )

  invisible(list(
    t              = unname(raw$statistic),
    df             = unname(raw$parameter),
    p_value        = raw$p.value,
    mean_a         = mean(a_vals),
    mean_b         = mean(b_vals),
    cohens_d       = d,
    interpretation = interp,
    raw            = raw
  ))
}


#' Chi-square test of independence with Cramer's V
#'
#' Wraps [stats::chisq.test()] and computes Cramer's V as the effect-size
#' measure. Prints a student-legible summary and returns the full results
#' invisibly. Introduced in Chapter 13.
#'
#' Cramer's V benchmarks (Cohen, 1988): 0.1 = small, 0.3 = medium, 0.5 = large.
#'
#' @param data A data frame.
#' @param x <[`tidy-select`][dplyr::dplyr_tidy_select]> Unquoted name of the
#'   first categorical variable.
#' @param y <[`tidy-select`][dplyr::dplyr_tidy_select]> Unquoted name of the
#'   second categorical variable.
#' @return A list (returned invisibly) with elements `chi_sq`, `df`,
#'   `p_value`, `cramers_v`, `interpretation`, and `raw`.
#' @examples
#' library(v2v)
#' library(dplyr)
#'
#' streams <- twitch_streams() |>
#'   filter(!is.na(game)) |>
#'   mutate(
#'     is_gaming   = !(game %in% c("Art", "Just Chatting", "Music")),
#'     viewer_band = cut(viewers, breaks = c(0, 5000, 20000, Inf),
#'                       labels = c("small", "medium", "large"))
#'   )
#'
#' run_chi_square(streams, x = is_gaming, y = viewer_band)
#' @export
run_chi_square <- function(data, x, y) {
  x_expr <- rlang::enquo(x)
  y_expr <- rlang::enquo(y)
  x_name <- rlang::as_label(x_expr)
  y_name <- rlang::as_label(y_expr)

  xs <- dplyr::pull(data, !!x_expr)
  ys <- dplyr::pull(data, !!y_expr)

  keep <- !is.na(xs) & !is.na(ys)
  xs   <- xs[keep]
  ys   <- ys[keep]
  n    <- length(xs)

  tbl <- table(xs, ys)
  raw <- stats::chisq.test(tbl)

  k <- min(nrow(tbl), ncol(tbl)) - 1L
  v <- sqrt(unname(raw$statistic) / (n * max(k, 1)))

  interp <- dplyr::case_when(
    v < 0.10 ~ "negligible",
    v < 0.30 ~ "small",
    v < 0.50 ~ "medium",
    .default  = "large"
  )

  p_fmt <- if (raw$p.value < .001) "< .001" else
    if (raw$p.value < .01) "< .01" else
      formatC(raw$p.value, digits = 3, format = "f")

  sig_word <- if (raw$p.value < .05) "statistically significant" else
    "not statistically significant"

  cli::cli_text("{.strong Chi-square test of independence}")
  cli::cli_text("{x_name} by {y_name}")
  cli::cli_text("")
  cli::cli_text("  N                  {n}")
  cli::cli_text("  Chi-squared        {round(unname(raw$statistic), 2)}")
  cli::cli_text("  df                 {unname(raw$parameter)}")
  cli::cli_text("  p-value            {p_fmt}")
  cli::cli_text("  Cramer's V         {round(v, 2)}  ({interp})")
  cli::cli_text("")
  cli::cli_text(
    "  The association between {x_name} and {y_name} is {sig_word} and {interp} in size."
  )

  invisible(list(
    chi_sq         = unname(raw$statistic),
    df             = unname(raw$parameter),
    p_value        = raw$p.value,
    cramers_v      = v,
    interpretation = interp,
    raw            = raw
  ))
}
