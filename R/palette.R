#' V2V accessible colour palette
#'
#' A colourblind-safe qualitative palette for V2V figures, based on the
#' Okabe-Ito set (Okabe & Ito, 2008). The eight hues remain distinguishable
#' under deuteranopia, protanopia, and tritanopia, which is why they are the
#' recommended default for accessible categorical data visualisation.
#'
#' Colour alone is never a sufficient encoding for accessibility (WCAG 2.1
#' SC 1.4.1, Use of Colour). Pair these scales with a second channel where the
#' distinction carries meaning: direct labels, facets, shape (`aes(shape=)`),
#' or linetype. For filled areas (bars, boxes), add a thin dark outline
#' (`colour = "grey20"`) so adjacent fills meet the 3:1 non-text contrast
#' guidance (WCAG 2.1 SC 1.4.11) against each other and the background.
#'
#' The eight hues are ordered contrast-first: the first four
#' (blue, vermillion, bluish green, reddish purple) each clear a 3:1 contrast
#' ratio against white, so a typical figure with four or fewer categories meets
#' the non-text contrast guidance on fill alone. The remaining four are lower
#' contrast against white and rely on the outline convention above.
#'
#' @format A named character vector of eight hex colours.
#' @source Okabe, M., & Ito, K. (2008). Color Universal Design (CUD).
#' @examples
#' scales::show_col(v2v_colours)
#' @export
v2v_colours <- c(
  blue           = "#0072B2",  # 5.2:1 vs white
  vermillion     = "#D55E00",  # 3.9:1
  bluish_green   = "#009E73",  # 3.4:1
  reddish_purple = "#CC79A7",  # 3.1:1
  orange         = "#E69F00",
  sky_blue       = "#56B4E9",
  grey           = "#999999",
  yellow         = "#F0E442"
)

#' Discrete V2V colour palette generator
#'
#' Returns a function that produces `n` colourblind-safe colours from
#' [v2v_colours], for use in custom scales. Errors if more than eight
#' categories are requested, because beyond eight distinct hues colour ceases
#' to be a reliable accessible encoding; use faceting or direct labels instead.
#'
#' @return A function of one argument `n` returning a character vector of hex
#'   colours.
#' @examples
#' v2v_pal()(3)
#' @export
v2v_pal <- function() {
  function(n) {
    if (n > length(v2v_colours)) {
      stop(
        "v2v_pal() supports up to ", length(v2v_colours),
        " categories; you asked for ", n,
        ". Beyond this, colour is no longer an accessible encoding — ",
        "use facets or direct labels instead.",
        call. = FALSE
      )
    }
    unname(v2v_colours[seq_len(n)])
  }
}

#' Accessible discrete colour and fill scales for V2V figures
#'
#' Drop-in ggplot2 scales that apply the colourblind-safe [v2v_colours]
#' palette. Use `scale_colour_v2v()` / `scale_color_v2v()` for line, point, and
#' text colour; `scale_fill_v2v()` for bar, area, and box fill.
#'
#' @param ... Passed to [ggplot2::discrete_scale()].
#' @return A ggplot2 scale, added to a plot with `+`.
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(factor(cyl), fill = factor(cyl))) +
#'   geom_bar(colour = "grey20") +
#'   scale_fill_v2v() +
#'   theme_v2v()
#' @name scale_v2v
#' @export
scale_colour_v2v <- function(...) {
  ggplot2::discrete_scale("colour", palette = v2v_pal(), ...)
}

#' @rdname scale_v2v
#' @export
scale_color_v2v <- scale_colour_v2v

#' @rdname scale_v2v
#' @export
scale_fill_v2v <- function(...) {
  ggplot2::discrete_scale("fill", palette = v2v_pal(), ...)
}

#' Accessible continuous fill and colour scales for V2V figures
#'
#' Wrappers around ggplot2's viridis scales, which are perceptually uniform and
#' colourblind-safe for continuous data. Use for heatmaps, density, and any
#' quantity mapped to colour.
#'
#' @param ... Passed to [ggplot2::scale_fill_viridis_c()] /
#'   [ggplot2::scale_colour_viridis_c()].
#' @return A ggplot2 scale, added to a plot with `+`.
#' @examples
#' library(ggplot2)
#' ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
#'   geom_raster() +
#'   scale_fill_v2v_c()
#' @name scale_v2v_continuous
#' @export
scale_fill_v2v_c <- function(...) {
  ggplot2::scale_fill_viridis_c(option = "viridis", ...)
}

#' @rdname scale_v2v_continuous
#' @export
scale_colour_v2v_c <- function(...) {
  ggplot2::scale_colour_viridis_c(option = "viridis", ...)
}

#' @rdname scale_v2v_continuous
#' @export
scale_color_v2v_c <- scale_colour_v2v_c
