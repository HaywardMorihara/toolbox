#!/usr/bin/env bash
# scripts/is-automation-worth-it.sh - Is automating a task worth the time?
# Based on https://xkcd.com/1205/
#
# Usage:
#   is-automation-worth-it.sh [--years N] [<time-saved-per-run> <frequency> <time-to-build>]
#
# Missing arguments are prompted for one by one (years last, blank = 5).
#   Durations:   30s, 5m, 1h, 2d, 1h30m  (1d = 24h)
#   Frequencies: N/day, N/week, N/month, N/year, daily, weekly, monthly, yearly
#   --years N    Time horizon in years; prompted for if omitted (default: 5)

set -uo pipefail

YEARS=
DAYS_PER_YEAR=365

die() { echo "Error: $*" >&2; exit 1; }

# Prints seconds for a duration like 1h30m
parse_duration() {
  local s="$1" total=0 num unit
  [[ "$s" =~ ^([0-9]+(\.[0-9]+)?[smhd])+$ ]] || return 1
  while [[ -n "$s" ]]; do
    [[ "$s" =~ ^([0-9]+(\.[0-9]+)?)([smhd])(.*)$ ]] || return 1
    num="${BASH_REMATCH[1]}"; unit="${BASH_REMATCH[3]}"; s="${BASH_REMATCH[4]}"
    case "$unit" in
      s) mult=1 ;; m) mult=60 ;; h) mult=3600 ;; d) mult=86400 ;;
    esac
    total=$(awk -v t="$total" -v n="$num" -v m="$mult" 'BEGIN{print t+n*m}')
  done
  echo "$total"
}

# Prints runs per year
parse_frequency() {
  local f="$1" n unit per_year
  case "$f" in
    daily)   n=1; unit=day ;;
    weekly)  n=1; unit=week ;;
    monthly) n=1; unit=month ;;
    yearly)  n=1; unit=year ;;
    *)
      [[ "$f" =~ ^([0-9]+(\.[0-9]+)?)/(day|week|month|year)$ ]] || return 1
      n="${BASH_REMATCH[1]}"; unit="${BASH_REMATCH[3]}"
      ;;
  esac
  case "$unit" in
    day) per_year=$DAYS_PER_YEAR ;; week) per_year=52 ;;
    month) per_year=12 ;; year) per_year=1 ;;
  esac
  awk -v n="$n" -v p="$per_year" 'BEGIN{print n*p}'
}

# Seconds -> "Xd Yh Zm Ws" style (largest units first, zero parts skipped)
format_duration() {
  local secs
  secs=$(awk -v s="$1" 'BEGIN{printf "%d", s+0.5}')
  if (( secs == 0 )); then echo "0s"; return; fi
  local h=$((secs / 3600)) m=$(((secs % 3600) / 60)) s=$((secs % 60)) out=""
  (( h )) && out+="${h}h "
  (( m )) && out+="${m}m "
  (( s )) && out+="${s}s "
  echo "${out% }"
}

prompt() {
  local var="$1" question="$2" val
  read -r -p "$question " val || die "Missing input"
  printf -v "$var" '%s' "$val"
}

positional=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    --years)
      [[ "${2:-}" =~ ^[0-9]+(\.[0-9]+)?$ ]] || die "--years requires a number"
      YEARS="$2"; shift 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
[[ ${#positional[@]} -le 3 ]] || die "Too many arguments"

saved_in="${positional[0]:-}"
freq_in="${positional[1]:-}"
build_in="${positional[2]:-}"

[[ -n "$saved_in" ]] || prompt saved_in "How much time does automating save each time? (e.g. 5m)"
[[ -n "$freq_in" ]]  || prompt freq_in  "How often do you do it? (e.g. 2/day, weekly)"
[[ -n "$build_in" ]] || prompt build_in "How long will the automation take to build? (e.g. 3h)"

saved=$(parse_duration "$saved_in") || die "Invalid duration '$saved_in' (use e.g. 30s, 5m, 1h30m, 2d)"
runs_per_year=$(parse_frequency "$freq_in") || die "Invalid frequency '$freq_in' (use e.g. 2/day, 3/week, daily)"
build=$(parse_duration "$build_in") || die "Invalid duration '$build_in' (use e.g. 30s, 5m, 1h30m, 2d)"

if [[ -z "$YEARS" ]]; then
  read -r -p "Over how many years? (default: 5) " YEARS || YEARS=""
  YEARS="${YEARS:-5}"
  [[ "$YEARS" =~ ^[0-9]+(\.[0-9]+)?$ ]] || die "Invalid years '$YEARS' (use a number)"
fi

total=$(awk -v s="$saved" -v r="$runs_per_year" -v y="$YEARS" 'BEGIN{print s*r*y}')
worth=$(awk -v t="$total" -v b="$build" 'BEGIN{print (t>b) ? 1 : 0}')

if [[ "$worth" == 1 ]]; then
  echo "Worth it."
else
  echo "Not worth it."
fi
echo "Total time saved over ${YEARS}y: $(format_duration "$total")"
echo "Build time: $(format_duration "$build")"
echo "Max build time to break even: $(format_duration "$total")"
