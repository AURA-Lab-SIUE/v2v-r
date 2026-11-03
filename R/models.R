#' One-way ANOVA with eta squared
#'
#' Wraps [stats::aov()] for one numeric outcome across three or more groups,
#' and adds eta squared and omega squared as the effect-size measures, Welch's
#' F (which does not assume equal spread), and Tukey's pairwise follow-up.
#' Prints a student-legible summary and returns the full results invisibly.
#' Introduced in Chapter 13.
#'
#' Eta squared benchmarks (Cohen, 1988): .01 = small, .06 = medium,
#' .14 = large.
#'
#' @param data A data frame containing the value and group columns.
#' @param value Unquoted name of the numeric outcome variable.
#' @param group Unquoted name of the grouping variable, with three or more
#'   distinct non-NA levels.
#' @return A list (returned invisibly) with `f`, `df_between`, `df_within`,
#'   `p_value`, `eta_squared`, `omega_squared`, `n`, `groups` (a tibble of
#'   n, mean, and SD per level), `welch`, `tukey` (a tibble of pairwise
#'   differences), `interpretation`, and `raw` (the [stats::aov()] fit).
#' @examples
#' analysis <- dplyr::left_join(twitch_chat(), twitch_channels(), by = "channel")
#' analysis <- dplyr::mutate(analysis, message_length = nchar(message))
#' run_anova(analysis, value = message_length, group = viewer_band)
#' @export
run_anova <- function(data, value, group) {
  val_expr <- rlang::enquo(value)
  grp_expr <- rlang::enquo(group)
  val_name <- rlang::as_label(val_expr)
  grp_name <- rlang::as_label(grp_expr)

  vals <- dplyr::pull(data, !!val_expr)
  grps <- dplyr::pull(data, !!grp_expr)
  keep <- !is.na(vals) & !is.na(grps)
  d <- data.frame(value = vals[keep], group = factor(grps[keep]))
  levels <- levels(d$group)
  if (length(levels) < 3L) {
    cli::cli_abort("{.arg {grp_name}} must have three or more non-NA levels; found {length(levels)}.")
  }

  raw <- stats::aov(value ~ group, data = d)
  tab <- summary(raw)[[1]]
  ss_between <- tab[["Sum Sq"]][1]
  ss_within  <- tab[["Sum Sq"]][2]
  ms_within  <- tab[["Mean Sq"]][2]
  df_between <- tab[["Df"]][1]
  df_within  <- tab[["Df"]][2]
  f_val <- tab[["F value"]][1]
  p_val <- tab[["Pr(>F)"]][1]
  eta   <- ss_between / (ss_between + ss_within)
  omega <- (ss_between - df_between * ms_within) / (ss_between + ss_within + ms_within)
  welch <- stats::oneway.test(value ~ group, data = d)

  interp <- dplyr::case_when(
    eta < 0.01 ~ "negligible",
    eta < 0.06 ~ "small",
    eta < 0.14 ~ "medium",
    .default   = "large"
  )
  sig_word <- if (p_val < .05) "statistically significant" else "not statistically significant"

  groups <- dplyr::summarize(
    dplyr::group_by(d, group),
    n = dplyr::n(), mean = mean(value), sd = stats::sd(value), .groups = "drop"
  )
  names(groups)[1] <- grp_name

  tk <- stats::TukeyHSD(raw)$group
  tukey <- tibble::tibble(
    pair = rownames(tk), difference = tk[, "diff"],
    conf_low = tk[, "lwr"], conf_high = tk[, "upr"], p_adjusted = tk[, "p adj"]
  )

  data_name <- data_label(substitute(data))
  cli::cli_text("{.strong One-way ANOVA}")
  cli::cli_text("{val_name} by {grp_name}")
  cli::cli_verbatim(c(
    "",
    sprintf("  %-22s n = %d, mean = %s, SD = %s", groups[[1]], groups$n, num(groups$mean), num(groups$sd)),
    "",
    sprintf("  %-22s %s", "F", num(f_val)),
    sprintf("  %-22s %d, %d", "df", df_between, df_within),
    sprintf("  %-22s %s", "p-value", p_apa(p_val)),
    sprintf("  %-22s %s  (%s)", "Eta squared", formatC(eta, digits = 3, format = "f"), interp),
    sprintf("  %-22s %s", "Omega squared", formatC(omega, digits = 3, format = "f")),
    sprintf("  %-22s F = %s, p %s", "Welch's ANOVA", num(unname(welch$statistic)), p_apa(welch$p.value)),
    "",
    sprintf("  The groups differ by a %s, %s amount.", sig_word, interp),
    "",
    "  Tukey's pairwise follow-up (adjusted p):",
    sprintf("    %-28s diff = %s, p %s", tukey$pair, num(tukey$difference),
            vapply(tukey$p_adjusted, p_apa, character(1))),
    "",
    "  The same test without v2v:",
    sprintf("    fit <- aov(%s ~ %s, data = %s)", val_name, grp_name, data_name),
    "    summary(fit)",
    "    effectsize::eta_squared(fit)",
    "    TukeyHSD(fit)"
  ))

  invisible(list(
    f = f_val, df_between = df_between, df_within = df_within, p_value = p_val,
    eta_squared = eta, omega_squared = omega, n = nrow(d), groups = groups,
    welch = welch, tukey = tukey, interpretation = interp, raw = raw
  ))
}


#' Linear regression with one predictor
#'
#' Wraps [stats::lm()] for one numeric outcome predicted by one numeric
#' predictor. Prints the slope, the intercept, the standardized slope,
#' R-squared, and the F-test, and returns the full results invisibly.
#' Introduced in Chapter 13.
#'
#' @param data A data frame containing the two columns.
#' @param outcome Unquoted name of the numeric outcome variable.
#' @param predictor Unquoted name of the numeric predictor.
#' @return A list (returned invisibly) with `slope`, `intercept`, `beta`
#'   (the standardized slope), `r_squared`, `f`, `df_model`, `df_residual`,
#'   `p_value`, `n`, and `raw` (the [stats::lm()] fit).
#' @examples
#' analysis <- dplyr::mutate(twitch_chat(), message_length = nchar(message),
#'                           hour = as.integer(format(clean_dates(date), "%H")))
#' run_regression(analysis, outcome = message_length, predictor = hour)
#' @export
run_regression <- function(data, outcome, predictor) {
  out_expr <- rlang::enquo(outcome)
  pre_expr <- rlang::enquo(predictor)
  out_name <- rlang::as_label(out_expr)
  pre_name <- rlang::as_label(pre_expr)

  ys <- dplyr::pull(data, !!out_expr)
  xs <- dplyr::pull(data, !!pre_expr)
  keep <- !is.na(ys) & !is.na(xs)
  d <- data.frame(y = ys[keep], x = xs[keep])

  raw <- stats::lm(y ~ x, data = d)
  s <- summary(raw)
  slope <- unname(stats::coef(raw)["x"])
  intercept <- unname(stats::coef(raw)["(Intercept)"])
  beta <- slope * stats::sd(d$x) / stats::sd(d$y)
  f_val <- unname(s$fstatistic["value"])
  df_model <- unname(s$fstatistic["numdf"])
  df_resid <- unname(s$fstatistic["dendf"])
  p_val <- unname(stats::pf(f_val, df_model, df_resid, lower.tail = FALSE))
  r2 <- s$r.squared
  sig_word <- if (p_val < .05) "statistically significant" else "not statistically significant"

  data_name <- data_label(substitute(data))
  cli::cli_text("{.strong Linear regression}")
  cli::cli_text("{out_name} predicted by {pre_name}")
  cli::cli_verbatim(c(
    "",
    sprintf("  %-22s %d", "n", nrow(d)),
    sprintf("  %-22s %s  (%s per unit of %s)", "Slope", num(slope), out_name, pre_name),
    sprintf("  %-22s %s", "Intercept", num(intercept)),
    sprintf("  %-22s %s  (standardized slope)", "Beta", formatC(beta, digits = 3, format = "f")),
    sprintf("  %-22s %s", "R-squared", formatC(r2, digits = 3, format = "f")),
    sprintf("  %-22s %s on %d and %d df", "F", num(f_val), as.integer(df_model), as.integer(df_resid)),
    sprintf("  %-22s %s", "p-value", p_apa(p_val)),
    "",
    sprintf("  %s explains %s%% of the variation in %s, a %s amount.",
            pre_name, formatC(100 * r2, digits = 1, format = "f"), out_name, sig_word),
    "",
    "  The same test without v2v:",
    sprintf("    fit <- lm(%s ~ %s, data = %s)", out_name, pre_name, data_name),
    "    summary(fit)",
    "    lm.beta::lm.beta(fit)"
  ))

  invisible(list(
    slope = slope, intercept = intercept, beta = beta, r_squared = r2,
    f = f_val, df_model = df_model, df_residual = df_resid, p_value = p_val,
    n = nrow(d), raw = raw
  ))
}

# APA 7: the exact p to three decimals, no leading zero, and "< .001" below that.
p_apa <- function(p) {
  if (p < .001) "< .001" else paste("=", sub("^0", "", formatC(p, digits = 3, format = "f")))
}
