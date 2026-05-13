#' Compute intercoder reliability between two coders
#'
#' Wraps [irr::kappa2()] (Cohen's kappa, for two coders and nominal codes)
#' and [irr::kripp.alpha()] (Krippendorff's alpha, which extends to more
#' than two coders and to ordinal/interval/ratio codes). Returns a list
#' with the chosen statistic and a Landis & Koch (1977) interpretation
#' label so students can read the result without consulting a separate
#' reference table.
#'
#' Landis & Koch benchmarks: `< 0.20` = slight, `0.21-0.40` = fair,
#' `0.41-0.60` = moderate, `0.61-0.80` = substantial, `0.81-1.00` =
#' almost perfect. The V2V graduate threshold is `>= 0.70`; values below
#' that mean the codebook needs revision, not that the coders need to
#' work harder.
#'
#' @param coder_a Vector of codes from the first coder.
#' @param coder_b Vector of codes from the second coder. Same length and
#'   levels as `coder_a`.
#' @param method One of `"kappa"` (default, Cohen's) or `"alpha"`
#'   (Krippendorff's, for any level of measurement).
#' @return A list with elements `statistic` (the numeric value),
#'   `method` (the method name), `interpretation` (Landis & Koch label),
#'   and `raw` (the full underlying object from `irr` for further
#'   inspection).
#' @examples
#' library(v2v)
#'
#' # Synthetic example: two coders mostly agree on whether messages contain emotes
#' msgs <- twitch_chat(channels = "bobross", n = 50)
#' coder_a <- grepl("LULW|Pog|KEKW", msgs$message)
#' coder_b <- grepl("LULW|Pog|KEKW|Kappa", msgs$message) # slightly different rule
#'
#' reliability(coder_a, coder_b, method = "kappa")
#' @export
reliability <- function(coder_a, coder_b, method = c("kappa", "alpha")) {
  method <- match.arg(method)
  if (length(coder_a) != length(coder_b)) {
    cli::cli_abort("{.arg coder_a} and {.arg coder_b} must be the same length.")
  }

  if (method == "kappa") {
    raw <- irr::kappa2(data.frame(coder_a = coder_a, coder_b = coder_b))
    stat <- raw$value
  } else {
    ratings <- rbind(as.character(coder_a), as.character(coder_b))
    raw <- irr::kripp.alpha(ratings)
    stat <- raw$value
  }

  interpretation <- if (is.na(stat)) {
    "undefined"
  } else if (stat < 0.20) {
    "slight (Landis & Koch 1977)"
  } else if (stat < 0.40) {
    "fair (Landis & Koch 1977)"
  } else if (stat < 0.60) {
    "moderate (Landis & Koch 1977)"
  } else if (stat < 0.80) {
    "substantial (Landis & Koch 1977)"
  } else {
    "almost perfect (Landis & Koch 1977)"
  }

  list(
    statistic = stat,
    method = if (method == "kappa") "Cohen's kappa" else "Krippendorff's alpha",
    interpretation = interpretation,
    raw = raw
  )
}
