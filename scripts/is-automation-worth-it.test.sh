#!/usr/bin/env bash
# Tests for is-automation-worth-it.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUT="$SCRIPT_DIR/is-automation-worth-it.sh"

fail=0
check() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == *"$expected"* ]]; then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc"
    echo "  expected to contain: $expected"
    echo "  actual: $actual"
    fail=1
  fi
}

# 5m * 2/day * 365 * 5y = 18250 min = 304h10m; max build = same
out=$("$SUT" 5m 2/day 3h </dev/null 2>&1)
check "worth it verdict" "Worth it" "$out"
check "total saved" "304h 10m" "$out"

# 1s daily over 5y = 1825s = 30m25s; build 1h is not worth it
out=$("$SUT" 1s daily 1h </dev/null 2>&1)
check "not worth it verdict" "Not worth it" "$out"
check "break-even shown" "30m 25s" "$out"

# Alias frequencies: weekly == 1/week; 1h * 52 * 5 = 260h
out=$("$SUT" 1h weekly 1h </dev/null 2>&1)
check "weekly alias" "260h" "$out"
out=$("$SUT" 1h 1/week 1h </dev/null 2>&1)
check "N/week form" "260h" "$out"

# Combined durations: 1h30m weekly -> 390h
out=$("$SUT" 1h30m weekly 1m </dev/null 2>&1)
check "combined duration" "390h" "$out"

# Days: 1d yearly over 5y = 5d = 120h
out=$("$SUT" 1d yearly 1h </dev/null 2>&1)
check "day unit" "120h" "$out"

# --years override: 1h weekly, 1y = 52h
out=$("$SUT" --years 1 1h weekly 1m </dev/null 2>&1)
check "years override" "52h" "$out"
check "years in output" "1y" "$out"

# Interactive: missing args are prompted one by one, years is the 4th prompt
out=$(printf '5m\n2/day\n3h\n1\n' | "$SUT" 2>&1)
check "interactive all prompted" "Worth it" "$out"
check "interactive years prompted" "over 1y" "$out"
out=$(printf '2/day\n3h\n2\n' | "$SUT" 5m 2>&1)
check "interactive partial" "over 2y" "$out"
out=$(printf '5m\n2/day\n3h\n\n' | "$SUT" 2>&1)
check "blank years defaults to 5" "over 5y" "$out"
out=$(printf '5m\n2/day\n3h\n' | "$SUT" --years 1 2>&1)
check "years flag skips years prompt" "over 1y" "$out"
out=$(printf '5m\n2/day\n3h\nabc\n' | "$SUT" 2>&1)
check "invalid years message" "Invalid years" "$out"

# Invalid input
out=$("$SUT" abc daily 1h </dev/null </dev/null 2>&1); rc=$?
check "invalid duration message" "Invalid duration" "$out"
[[ $rc -ne 0 ]] && check "invalid duration exit" "x" "x" || check "invalid duration exit" "nonzero" "rc=$rc"
out=$("$SUT" 5m sometimes 1h </dev/null 2>&1)
check "invalid frequency message" "Invalid frequency" "$out"

exit $fail
