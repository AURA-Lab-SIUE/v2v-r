#' Cross-tabulate two categories
#'
#' Counts every pair of two categorical columns and lays the counts out as a
#' grid, one row per level of `row` and one column per level of `col`, then
#' the same grid as shares (each row adds up to 1). Rows missing either column
#' are dropped first. This is the table a chi-square test reads. Introduced in
#' Chapter 12.
#'
#' The same table without v2v is `count(row, col)` followed by
#' `pivot_wider(names_from = col, values_from = n, values_fill = 0)`; the
#' function prints that equivalent the first time it runs.
#'
#' @param data A data frame.
#' @param row,col Unquoted column names: `row` becomes the rows of the grid,
#'   `col` the columns.
#' @return A list (returned invisibly) with `counts` and `shares`, both
#'   tibbles with one row per level of `row`, and `n`, the rows counted.
#' @examples
#' analysis <- dplyr::left_join(twitch_chat(), twitch_channels(), by = "channel")
#' crosstab(analysis, viewer_band, channel_type)
#' @export
crosstab <- function(data, row, col) {
  row_expr <- rlang::enquo(row)
  col_expr <- rlang::enquo(col)
  row_name <- rlang::as_label(row_expr)
  col_name <- rlang::as_label(col_expr)

  kept <- dplyr::filter(data, !is.na(!!row_expr), !is.na(!!col_expr))
  long <- dplyr::count(kept, !!row_expr, !!col_expr)
  long <- dplyr::group_by(long, !!row_expr)
  long <- dplyr::mutate(long, share = round(n / sum(n), 3))
  long <- dplyr::ungroup(long)

  counts <- tidyr::pivot_wider(
    dplyr::select(long, -share),
    names_from = !!col_expr, values_from = n, values_fill = 0
  )
  shares <- tidyr::pivot_wider(
    dplyr::select(long, -n),
    names_from = !!col_expr, values_from = share, values_fill = 0
  )

  show_equivalent(
    "crosstab",
    sprintf(
      "count(%s, %s) then pivot_wider(names_from = %s, values_from = n, values_fill = 0)",
      row_name, col_name, col_name
    )
  )
  cli::cli_text("{.strong Counts}: {row_name} (rows) by {col_name} (columns), {nrow(kept)} rows counted")
  print(counts)
  cli::cli_text("{.strong Shares}: each row of {row_name} adds up to 1")
  print(shares)

  invisible(list(counts = counts, shares = shares, n = nrow(kept)))
}

#' Flag the outliers in a number, by group
#'
#' Returns the rows whose `value` lies beyond the whiskers of its group's
#' boxplot: more than 1.5 times the interquartile range above the third
#' quartile or below the first. These are the points a boxplot draws on
#' their own. Introduced in Chapter 12 (MC 501 diagnostics).
#'
#' @param data A data frame.
#' @param value Unquoted name of the numeric column.
#' @param group Unquoted name of the grouping column. Leave it out to treat
#'   the whole table as one group.
#' @return A tibble of the flagged rows, with the group, the value, and
#'   `side` (`"high"` or `"low"`).
#' @examples
#' coded <- dplyr::mutate(twitch_chat(), message_length = nchar(message))
#' flag_outliers(coded, message_length, channel)
#' @export
flag_outliers <- function(data, value, group) {
  val_expr <- rlang::enquo(value)
  val_name <- rlang::as_label(val_expr)
  has_group <- !missing(group)
  if (has_group) {
    grp_expr <- rlang::enquo(group)
    grp_name <- rlang::as_label(grp_expr)
    data <- dplyr::group_by(data, !!grp_expr)
  }
  flagged <- dplyr::mutate(
    data,
    .q1  = stats::quantile(!!val_expr, 0.25, na.rm = TRUE),
    .q3  = stats::quantile(!!val_expr, 0.75, na.rm = TRUE),
    .iqr = .q3 - .q1,
    side = dplyr::case_when(
      !!val_expr > .q3 + 1.5 * .iqr ~ "high",
      !!val_expr < .q1 - 1.5 * .iqr ~ "low",
      TRUE ~ NA_character_
    )
  )
  flagged <- dplyr::ungroup(flagged)
  flagged <- dplyr::filter(flagged, !is.na(side))
  flagged <- dplyr::select(flagged, -.q1, -.q3, -.iqr)
  if (has_group) {
    flagged <- dplyr::relocate(flagged, !!grp_expr, !!val_expr, side)
    show_equivalent(
      "flag_outliers",
      sprintf("group_by(%s) then filter(%s > quantile(%s, 0.75) + 1.5 * IQR(%s))",
              grp_name, val_name, val_name, val_name)
    )
  } else {
    flagged <- dplyr::relocate(flagged, !!val_expr, side)
    show_equivalent(
      "flag_outliers",
      sprintf("filter(%s > quantile(%s, 0.75) + 1.5 * IQR(%s))", val_name, val_name, val_name)
    )
  }
  flagged
}

#' Concurrent viewers over time, by game category
#'
#' Total concurrent viewers in each six-hour block of the collection window,
#' for the five most-streamed game categories, with every other category
#' lumped into `Other`. This is the table the Chapter 12 line chart draws.
#' It was built from [twitch_streams()] by `data-raw/build_viewers.R` in the
#' package source: `clean_dates()` for the time, `floor_date()` for the
#' six-hour blocks, `fct_lump_n()` for the top five, then `group_by()` and
#' `summarize(sum(viewers))`.
#'
#' @return A tibble with `six_hour` (POSIXct, UTC), `category` (factor), and
#'   `total_viewers`.
#' @examples
#' twitch_viewers_over_time()
#' @export
twitch_viewers_over_time <- function() {
  e <- new.env()
  utils::data("twitch_viewers_sample", package = "v2v", envir = e)
  tibble::as_tibble(e$twitch_viewers_sample)
}
