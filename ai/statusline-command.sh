#!/usr/bin/env bash
# Claude Code statusline: context-window usage.
# No jq dependency (jq is not installed in this cygwin env): parses the stdin
# JSON with sed + awk.
#
# Two payload quirks worth knowing:
#   * The stdin JSON can arrive pretty-printed (multi-line) or as one line,
#     depending on version/render. sed is line-oriented, so a key and its
#     value can land on different lines and fail to match -- flatten first.
#   * Some renders omit total_input_tokens (only context_window_size /
#     used_percentage are present). Derive an approximate used count instead of
#     blanking the bar mid-session.

set -u

# Flatten: strip newlines so every "key":value pair sits on one line.
input=$(cat | tr -d '\r\n')

# --- human-readable token formatting: >=1e6 -> X.Xm, >=1e3 -> X.Xk ---------
humanize() {
  awk -v n="$1" 'BEGIN {
    n = n + 0
    if (n < 1000) { printf "%d", n; exit }
    if (n >= 1000000) { s = sprintf("%.1f", n / 1000000); unit = "m" }
    else             { s = sprintf("%.1f", n / 1000);    unit = "k" }
    sub(/\.0$/, "", s)
    # 999999 rounds to "1000k"; "1m" reads better at that boundary.
    if (unit == "k" && s + 0 >= 1000) {
      s = sprintf("%.1f", n / 1000000); sub(/\.0$/, "", s); unit = "m"
    }
    printf "%s%s", s, unit
  }'
}

# field <key> -> first numeric value for "key" anywhere in the payload.
# Anchored on the leading quote so "total_tokens" cannot match
# "total_input_tokens" / "total_output_tokens".
field() {
  printf '%s' "$input" | sed -nE "s/.*\"$1\"[[:space:]]*:[[:space:]]*([0-9.]+).*/\1/p"
}

# numeric > 0, tolerant of decimals (bash's [ -gt ] is integers only)
positive() { awk -v n="$1" 'BEGIN { exit !(n + 0 > 0) }'; }

# --- fields confirmed against the live stdin JSON ---------------------------
used=$(field total_input_tokens)
[ -z "$used" ] && used=$(field total_tokens)
total=$(field context_window_size)

ctx=""
if [ -n "$used" ] && positive "$used" && [ -n "$total" ] && positive "$total"; then
  pct=$(awk -v u="$used" -v t="$total" 'BEGIN { printf "%.0f", u * 100 / t }')
  ctx="$(humanize "$used")/$(humanize "$total") ($pct%)"
else
  # Only an integer percentage is available. Derive an approximate used count
  # so the bar keeps showing something instead of going blank.
  pct2=$(field used_percentage)
  if [ -n "$pct2" ] && positive "$pct2" && [ -n "$total" ] && positive "$total"; then
    approx=$(awk -v p="$pct2" -v t="$total" 'BEGIN { printf "%d", p * t / 100 }')
    ctx="$(humanize "$approx")/$(humanize "$total") ($pct2%)"
  fi
fi

# --- render -----------------------------------------------------------------
if [ -n "$ctx" ]; then
  printf '%s' "$ctx"
fi

exit 0
