#' Twitch chat-message sample
#'
#' A stratified random sample of ~35,000 chat messages from 50 Twitch
#' channels active in the November 18-24, 2018 window. The 50 channels
#' are drawn from a population of 1,690 channels with both chat and
#' stream presence: 8 anchor channels (top-volume, gaming/non-gaming
#' variety) plus 42 additional channels stratified by chat-volume decile
#' to represent the long tail.
#'
#' Each channel contributes up to 1,000 messages to the sample. Channels
#' with fewer than 1,000 messages during the collection window contribute
#' everything they have; this is why the total is below the theoretical
#' 50,000 ceiling. Encountering channels with very few messages is itself
#' part of the population structure students should see.
#'
#' @format A tibble with ~35,000 rows and 5 variables:
#' \describe{
#'   \item{id}{integer; surrogate primary key from the source database.}
#'   \item{channel}{character; one of 50 distinct channels. Eight are
#'     **anchor channels** referenced repeatedly throughout the textbook:
#'     `xqcow`, `forsen`, `sodapoppin`, `asmongold`, `loltyler1`,
#'     `disguisedtoast`, `giantwaffle`, `bobross`. The remaining 42 are
#'     drawn from the chat-volume distribution as a stratified random
#'     sample, ensuring the broader Twitch ecology is visible. In the
#'     raw dump these channel names are prefixed with `#` (IRC
#'     convention); the prefix has been stripped here so that `channel`
#'     joins cleanly to [twitch_streams_sample]. Recovering the IRC
#'     representation is a Chapter 11 exercise.}
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
#'   `set.seed(20261113)`. See `data-raw/manifest.json` (or the V2V data
#'   report) for the full sampling design, per-channel breakdown, and
#'   chapter-keyed analytical results.
"twitch_chat_sample"

#' Twitch stream-snapshot sample
#'
#' Concurrent stream metadata for the same 50 channels and the same
#' collection window as [twitch_chat_sample]. Unlike the chat sample, the
#' full focal-channel coverage is shipped without sampling, because the
#' underlying snapshot count is small enough to bundle in entirety.
#'
#' @format A tibble with ~32,000 rows and 6 variables:
#' \describe{
#'   \item{id}{integer; surrogate primary key.}
#'   \item{channel}{character; bare channel name (no `#` prefix); matches
#'     [twitch_chat_sample]$channel.}
#'   \item{title}{character; current stream title at snapshot time. Some
#'     rows have a NULL title in this fixture.}
#'   \item{game}{character; current Twitch category at snapshot time. Some
#'     rows have a NULL game. The category set spans gaming
#'     (League of Legends, Rocket League, World of Warcraft, Skyrim,
#'     Fortnite, ...) and non-gaming (Just Chatting, Art, Music & Performing
#'     Arts, Sports & Fitness, Talk Shows & Podcasts).}
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
