# Register globals used inside NSE contexts that R CMD check cannot infer:
# - data names returned by utils::data()
# - bare column names inside dplyr::join_by(), which does not accept
#   the .data$ pronoun (its expressions are quoted in a different way
#   than regular dplyr verbs).

utils::globalVariables(c(
  "twitch_chat_sample",
  "twitch_streams_sample",
  "channel",
  "ts",
  "closest"
))
