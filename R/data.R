#' Twitch chat-message sample
#'
#' A stratified random sample of 48,000 chat messages, 6,000 per channel,
#' drawn from a 21.96-million-row November 2018 Twitch IRC dump. The 8 focal
#' channels span the pedagogically useful variation axes: gaming versus
#' non-gaming, peak-audience size, sender concentration, and snapshot
#' density.
#'
#' @format A tibble with 48,000 rows and 5 variables:
#' \describe{
#'   \item{id}{integer; surrogate primary key from the source database}
#'   \item{channel}{character; one of `xqcow`, `forsen`, `sodapoppin`,
#'     `asmongold`, `loltyler1`, `disguisedtoast`, `giantwaffle`,
#'     `bobross`. In the raw dump these are prefixed with `#` (IRC
#'     convention); the prefix has been stripped in this fixture so that
#'     `channel` joins cleanly to [twitch_streams_sample]. Recovering the
#'     IRC representation is a Chapter 11 exercise.}
#'   \item{sender}{character; pseudonymous Twitch username, public on the
#'     IRC feed.}
#'   \item{message}{character; UTF-8 message text, up to 509 characters.
#'     Includes Twitch emote tokens (`LULW`, `OMEGALUL`, `KEKW`, `Pog`,
#'     `Kappa`, ...) as first-class lexical items; do not strip them
#'     during normal preprocessing.}
#'   \item{date}{numeric; Unix epoch in **milliseconds** (not seconds).
#'     Convert with [clean_dates()] or
#'     `as.POSIXct(date / 1000, origin = "1970-01-01", tz = "UTC")`.}
#' }
#' @source 1.6 GB pg_dump custom-format archive at
#'   `D:/hub/archive/grad-school/dissertation/twitch_backup.sql`
#'   (Alex Leith dissertation backup, November 2018). Sampled with
#'   `set.seed(20261113)`. See the V2V data report at
#'   `inst/extdata/v2v-data-report.md` for the full extraction pipeline,
#'   focal-channel rationale, and chapter-keyed analytical results.
"twitch_chat_sample"

#' Twitch stream-snapshot sample
#'
#' Concurrent stream metadata for the same 8 focal channels and the same
#' collection window as [twitch_chat_sample]. Unlike the chat sample, the
#' full focal-channel coverage is shipped without sampling, because the
#' underlying snapshot count is small enough to bundle in entirety.
#'
#' @format A tibble with 17,892 rows and 6 variables:
#' \describe{
#'   \item{id}{integer; surrogate primary key.}
#'   \item{channel}{character; bare channel name (no `#` prefix); matches
#'     [twitch_chat_sample]$channel.}
#'   \item{title}{character; current stream title at snapshot time. 12
#'     rows have a NULL title in this fixture.}
#'   \item{game}{character; current Twitch category at snapshot time. 18
#'     rows have a NULL game. The category set spans gaming
#'     (League of Legends, Rocket League, World of Warcraft, Skyrim,
#'     Fortnite, ...) and non-gaming (Just Chatting, Art).}
#'   \item{viewers}{integer; concurrent viewer count as reported by Twitch
#'     at snapshot time. Not de-botted; treat as Twitch's stated count,
#'     not a ground-truth audience measure.}
#'   \item{date}{numeric; Unix epoch in **milliseconds**; same conversion
#'     rule as [twitch_chat_sample]$date.}
#' }
#' @source Same provenance as [twitch_chat_sample]. Snapshots are taken
#'   on roughly minute-scale cadence per channel during the collection
#'   window 2018-11-18 to 2018-11-24.
"twitch_streams_sample"
