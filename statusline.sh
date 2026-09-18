#!/bin/bash
# Claude Code status line: model │ context usage │ 5-hour rate-limit usage
# Reads the session JSON from stdin (see https://code.claude.com/docs/en/statusline).
# The two bars stretch to fill the terminal; below MIN_BAR blocks each they are dropped.

MIN_BAR=5   # narrowest useful bar; anything smaller falls back to the compact form
MARGIN=4    # columns left free for Claude Code's own indentation around the row

input=$(cat)

GRAY=$'\033[90m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; DIM=$'\033[2m'; RST=$'\033[0m'

# "-" marks an absent value: rate_limits only appears after the first API
# response, and context percentage can be null early in a session.
IFS=$'\t' read -r MODEL CTX FIVE RESETS_AT < <(jq -r '[
  (.model.display_name // "?"),
  (.context_window.used_percentage // 0 | floor),
  (.rate_limits.five_hour.used_percentage | if . == null then "-" else floor end),
  (.rate_limits.five_hour.resets_at // "-")
] | @tsv' <<<"$input" 2>/dev/null)
MODEL=${MODEL:-?}; CTX=${CTX:-0}; FIVE=${FIVE:--}; RESETS_AT=${RESETS_AT:--}

# Yellow from 75%, red from 90%; empty below that (gray bar, plain number)
tint() {
  if (( $1 >= 90 )); then printf '%s' "$RED"
  elif (( $1 >= 75 )); then printf '%s' "$YELLOW"; fi
}

# meter PCT WIDTH -> "▓▓░░░░ 12%", or just "12%" when WIDTH is 0
meter() {
  local pct=$1 width=$2 color filled full empty
  color=$(tint "$pct")
  if (( width > 0 )); then
    (( filled = pct > 100 ? width : pct * width / 100 ))
    printf -v full '%*s' "$filled" ''
    printf -v empty '%*s' "$(( width - filled ))" ''
    printf '%s%s%s%s ' "${color:-$GRAY}" "${full// /▓}" "${empty// /░}" "$RST"
  fi
  printf '%s%d%%%s' "$color" "$pct" "$RST"
}

# clock EPOCH -> HH:MM. GNU date takes "-d @epoch", BSD/macOS date takes "-r epoch"
clock() {
  case $OSTYPE in
    darwin*|*bsd*) date -r "$1" +%H:%M ;;
    *)             date -d "@$1" +%H:%M ;;
  esac 2>/dev/null
}

RESET_TIME=""
[[ $FIVE != "-" && $RESETS_AT != "-" ]] && RESET_TIME=$(clock "$RESETS_AT")

# Visible length of the bar-less line, counted by hand so it does not depend
# on the locale: "MODEL │ ctx NN% │ 5h NN% ↻ HH:MM" or "... │ 5h --"
bars=1
len=$(( ${#MODEL} + 3 + 4 + ${#CTX} + 1 + 3 + 3 ))
if [[ $FIVE == "-" ]]; then
  (( len += 2 ))
else
  bars=2
  (( len += ${#FIVE} + 1 ))
  [[ -n $RESET_TIME ]] && (( len += 3 + ${#RESET_TIME} ))
fi

# Split what is left of the row between the bars (each costs its width + a space)
avail=$(( ${COLUMNS:-80} - MARGIN - len ))
width=$(( avail / bars - 1 ))
if (( width < MIN_BAR )); then
  width=0
  (( avail < 0 )) && RESET_TIME=""   # too narrow even without bars: drop the reset time
fi

SEP=" ${DIM}│${RST} "
if [[ $FIVE == "-" ]]; then
  five_part="5h ${DIM}--${RST}"
else
  five_part="5h $(meter "$FIVE" "$width")"
  [[ -n $RESET_TIME ]] && five_part+=" ${DIM}↻ ${RESET_TIME}${RST}"
fi

printf '%s%sctx %s%s%s\n' "$MODEL" "$SEP" "$(meter "$CTX" "$width")" "$SEP" "$five_part"
