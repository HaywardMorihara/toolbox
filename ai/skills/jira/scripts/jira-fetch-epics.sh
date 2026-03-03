#!/usr/bin/env bash

# Fetch Jira epics and return formatted options for AskUserQuestion
# Loads JIRA environment from private/jira.sh and returns epic options
# Output format: one option per line as "ID-XXXX — Epic Name"
#
# Usage: bash ai/skills/jira/scripts/jira-fetch-epics.sh
# Returns lines suitable for AskUserQuestion options

set -euo pipefail

# Determine toolbox root (script is in toolbox/ai/skills/jira/scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLBOX_ROOT="${TOOLBOX_ROOT:-$(cd "$SCRIPT_DIR/../../../.." && pwd)}"

# Load Jira environment
if [[ ! -f "$TOOLBOX_ROOT/private/jira.sh" ]]; then
  echo "Error: $TOOLBOX_ROOT/private/jira.sh not found. Run 'bash ai/skills/jira/scripts/jira-setup.sh' first." >&2
  exit 1
fi

# Source Jira config
source "$TOOLBOX_ROOT/private/jira.sh"

# Fetch and format configured epic IDs with their summaries
if [[ -z "${JIRA_EPIC_IDS:-}" ]]; then
  echo "Error: JIRA_EPIC_IDS not configured in private/jira.sh" >&2
  exit 1
fi

# Split comma-separated epic IDs
IFS=',' read -ra epic_ids <<< "$JIRA_EPIC_IDS"

for epic_id in "${epic_ids[@]}"; do
  epic_id=$(echo "$epic_id" | xargs)  # Trim whitespace

  if [[ -z "$epic_id" ]]; then
    continue
  fi

  # Fetch the epic details and extract summary
  epic_data=$(acli jira workitem view "$epic_id" --json 2>/dev/null || echo "{}")
  epic_summary=$(echo "$epic_data" | python3 -c "
import json, sys
try:
  data = json.load(sys.stdin)
  summary = data.get('summary', data.get('fields', {}).get('summary', ''))
  if summary:
    print(summary)
except:
  pass
" 2>/dev/null)

  if [[ -n "$epic_summary" ]]; then
    echo "$epic_id — $epic_summary"
  fi
done
