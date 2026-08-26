#!/usr/bin/env bash
# Tests for cleanup_removed_skills in lib/claude-skills.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Stub logging helpers used by the lib
log_info() { :; }
log_warn() { :; }
log_error() { :; }
log_success() { :; }
register_check() { :; }

fail=0
assert() {
  local desc="$1"; shift
  if "$@"; then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc"
    fail=1
  fi
}

# Isolated sandbox
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"
REPO_ROOT="$TMP/repo"
skills_source="$REPO_ROOT/ai/skills"
skills_target="$HOME/.claude/skills"
mkdir -p "$skills_source" "$skills_target"

# Source the lib (REPO_ROOT must be set for _register_skill_checks)
source "$SCRIPT_DIR/claude-skills.sh"

# --- Setup fixture ---
# A live skill still present in source
mkdir -p "$skills_source/live-skill"; touch "$skills_source/live-skill/SKILL.md"
ln -s "$skills_source/live-skill" "$skills_target/live-skill"

# A removed skill: symlink present in target, source gone
ln -s "$skills_source/removed-skill" "$skills_target/removed-skill"

# A skill from a different source (e.g. ~/.ai/skills) must be untouched
mkdir -p "$TMP/other/external"; touch "$TMP/other/external/SKILL.md"
ln -s "$TMP/other/external" "$skills_target/external"

# A real (non-symlink) directory must be untouched
mkdir -p "$skills_target/real-dir"; touch "$skills_target/real-dir/SKILL.md"

# --- Run ---
cleanup_removed_skills

# --- Assert ---
assert "removed skill symlink is deleted"        [ ! -e "$skills_target/removed-skill" ]
assert "removed skill symlink is gone (-L)"      [ ! -L "$skills_target/removed-skill" ]
assert "live skill symlink is kept"              [ -L "$skills_target/live-skill" ]
assert "external-source symlink is kept"         [ -L "$skills_target/external" ]
assert "real directory is kept"                  [ -d "$skills_target/real-dir" ]

exit $fail
