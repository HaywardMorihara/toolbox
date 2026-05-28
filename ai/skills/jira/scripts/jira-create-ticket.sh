#!/usr/bin/env bash

# Create a Jira ticket via REST API v2.
#
# Org-agnostic: standard fields are built-in flags; organization-specific custom
# fields are passed generically via --field / --field-json (see private/jira/config.md).
#
# Usage:
#   jira-create-ticket.sh \
#     --project ID \
#     --type Story \
#     --summary "Ticket summary" \
#     [--parent ID-1234] \
#     [--assignee email@example.com] \
#     [--description "Multi-line description"] \
#     [--labels "label1,label2"] \
#     [--field customfield_10200=team-uuid] \
#     [--field-json customfield_99999='{"value":"x"}']
#
# --field KEY=VALUE        Custom field with a string value: "KEY": "VALUE"
# --field-json KEY=<json>  Custom field with a raw JSON value: "KEY": <json>
#                          (objects, arrays, select fields). Both flags repeatable.
#
# Set DRY_RUN=1 to print the request JSON instead of submitting it.

set -euo pipefail

# Default values
PARENT=""
ASSIGNEE=""
DESCRIPTION=""
LABELS=""
FIELD_STR=()
FIELD_JSON=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --project) PROJECT="$2"; shift 2 ;;
    --type) TYPE="$2"; shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    --parent) PARENT="$2"; shift 2 ;;
    --assignee) ASSIGNEE="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --labels) LABELS="$2"; shift 2 ;;
    --field) FIELD_STR+=("$2"); shift 2 ;;
    --field-json) FIELD_JSON+=("$2"); shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Validate required fields
if [[ -z "${PROJECT:-}" ]] || [[ -z "${TYPE:-}" ]] || [[ -z "${SUMMARY:-}" ]]; then
  echo "Error: Missing required fields"
  echo "Required: --project, --type, --summary"
  exit 1
fi

# Validate environment
if [[ -z "${JIRA_SITE:-}" ]] || [[ -z "${JIRA_USER:-}" ]] || [[ -z "${JIRA_API_TOKEN:-}" ]]; then
  echo "Error: Missing Jira environment variables"
  echo "Required: JIRA_SITE, JIRA_USER, JIRA_API_TOKEN"
  exit 1
fi

# Build the fields object with jq (safe escaping for arbitrary values)
FIELDS=$(jq -n \
  --arg project "$PROJECT" \
  --arg summary "$SUMMARY" \
  --arg type "$TYPE" \
  '{project: {key: $project}, summary: $summary, issuetype: {name: $type}}')

if [[ -n "$PARENT" ]]; then
  FIELDS=$(jq --arg p "$PARENT" '. + {parent: {key: $p}}' <<<"$FIELDS")
fi

if [[ -n "$DESCRIPTION" ]]; then
  FIELDS=$(jq --arg d "$DESCRIPTION" '. + {description: $d}' <<<"$FIELDS")
fi

if [[ -n "$ASSIGNEE" ]]; then
  FIELDS=$(jq --arg a "$ASSIGNEE" '. + {assignee: {name: $a}}' <<<"$FIELDS")
fi

if [[ -n "$LABELS" ]]; then
  LABELS_JSON=$(tr ',' '\n' <<<"$LABELS" | jq -R . | jq -s .)
  FIELDS=$(jq --argjson l "$LABELS_JSON" '. + {labels: $l}' <<<"$FIELDS")
fi

# Custom string-valued fields (--field KEY=VALUE)
for pair in "${FIELD_STR[@]+"${FIELD_STR[@]}"}"; do
  key="${pair%%=*}"
  val="${pair#*=}"
  if [[ -z "$key" || "$key" == "$pair" ]]; then
    echo "Error: --field expects KEY=VALUE, got: $pair"
    exit 1
  fi
  FIELDS=$(jq --arg k "$key" --arg v "$val" '. + {($k): $v}' <<<"$FIELDS")
done

# Custom raw-JSON fields (--field-json KEY=<json>)
for pair in "${FIELD_JSON[@]+"${FIELD_JSON[@]}"}"; do
  key="${pair%%=*}"
  val="${pair#*=}"
  if [[ -z "$key" || "$key" == "$pair" ]]; then
    echo "Error: --field-json expects KEY=<json>, got: $pair"
    exit 1
  fi
  if ! jq -e . >/dev/null 2>&1 <<<"$val"; then
    echo "Error: --field-json value for $key is not valid JSON: $val"
    exit 1
  fi
  FIELDS=$(jq --arg k "$key" --argjson v "$val" '. + {($k): $v}' <<<"$FIELDS")
done

REQUEST=$(jq -n --argjson f "$FIELDS" '{fields: $f}')

# Dry run: print the request and exit
if [[ "${DRY_RUN:-}" == "1" ]]; then
  echo "$REQUEST"
  exit 0
fi

# Submit the request
RESPONSE=$(curl -s -X POST \
  -u "$JIRA_USER:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$REQUEST" \
  "https://$JIRA_SITE/rest/api/2/issue")

# Check for errors
if echo "$RESPONSE" | grep -q '"errorMessages"'; then
  echo "Error creating ticket:"
  echo "$RESPONSE" | jq '.errorMessages'
  exit 1
fi

# Extract and display the created ticket key
KEY=$(echo "$RESPONSE" | jq -r '.key')
echo "✓ Ticket created: $KEY"
echo "https://$JIRA_SITE/browse/$KEY"
