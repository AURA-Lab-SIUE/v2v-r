#' V2V ggplot2 theme
#'
#' Applies a consistent publication-ready visual style to a ggplot2 figure.
#' Designed for the V2V Quarto book: minimal chrome, readable axis labels,
#' and no distracting gridlines.
#'
#' @param base_size Base font size in points. Default is 12.
#' @param base_family Base font family. Default is `""` (device default).
#'
#' @return A [ggplot2::theme()] object.
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point() +
#'   theme_v2v()
#'
#' @export
theme_v2v <- function(base_size = 12, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    ggplot2::theme(
      # Axis text: keep it legible
      axis.text        = ggplot2::element_text(size = base_size * 0.85, color = "#333333"),
      axis.title       = ggplot2::element_text(size = base_size * 0.9, face = "bold",
                                               color = "#333333"),
      axis.title.x     = ggplot2::element_text(margin = ggplot2::margin(t = 8)),
      axis.title.y     = ggplot2::element_text(margin = ggplot2::margin(r = 8),
                                               angle = 90),
      # Thin, subdued axis lines; no ticks
      axis.line        = ggplot2::element_line(color = "#aaaaaa", linewidth = 0.4),
      axis.ticks       = ggplot2::element_blank(),
      # Remove major vertical gridlines; keep horizontal as faint guides
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(color = "#eeeeee", linewidth = 0.4),
      panel.grid.minor   = ggplot2::element_blank(),
      panel.background   = ggplot2::element_rect(fill = "white", color = NA),
      plot.background    = ggplot2::element_rect(fill = "white", color = NA),
      # Legend: bottom-center, no box
      legend.position  = "bottom",
      legend.title     = ggplot2::element_text(size = base_size * 0.85, face = "bold"),
      legend.text      = ggplot2::element_text(size = base_size * 0.8),
      legend.key       = ggplot2::element_rect(fill = "white", color = NA),
      legend.background = ggplot2::element_blank(),
      # Plot title and subtitle
      plot.title       = ggplot2::element_text(size = base_size * 1.1, face = "bold",
                                               hjust = 0, margin = ggplot2::margin(b = 4)),
      plot.subtitle    = ggplot2::element_text(size = base_size * 0.9, color = "#555555",
                                               hjust = 0, margin = ggplot2::margin(b = 8)),
      plot.caption     = ggplot2::element_text(size = base_size * 0.75, color = "#777777",
                                               hjust = 1, margin = ggplot2::margin(t = 8)),
      # Generous plot margins
      plot.margin      = ggplot2::margin(12, 12, 12, 12),
      # Facet labels: understated
      strip.text       = ggplot2::element_text(size = base_size * 0.85, face = "bold",
                                               color = "#444444"),
      strip.background = ggplot2::element_rect(fill = "#f5f5f5", color = NA),
      complete = TRUE
    )
}

#' Format a data frame as a tidy HTML/PDF table
#'
#' A thin wrapper around [knitr::kable()] that applies consistent styling for
#' the V2V Quarto book. Accepts a data frame or tibble (typically the output of
#' a `dplyr::summarise()` chain) and returns a formatted table that renders
#' correctly in both the HTML and PDF profiles.
#'
#' @param x A data frame or tibble.
#' @param caption Optional table caption string. Default `NULL` (no caption).
#' @param digits Number of decimal places for numeric columns. Default `2`.
#' @param ... Additional arguments passed to [knitr::kable()].
#'
#' @return A `knitr_kable` object, rendered as a table in Quarto.
#'
#' @examples
#' library(dplyr)
#' mtcars |>
#'   group_by(cyl) |>
#'   summarise(mean_mpg = mean(mpg), n = n()) |>
#'   pretty_table(caption = "Miles per gallon by cylinder count")
#'
#' @export
pretty_table <- function(x, caption = NULL, digits = 2, ...) {
  knitr::kable(
    x,
    format    = knitr::pandoc_to() %||% "html",
    digits    = digits,
    caption   = caption,
    booktabs  = TRUE,
    ...
  )
}

# Null-coalescing operator (internal)
`%||%` <- function(a, b) if (!is.null(a) && nchar(a) > 0) a else b
