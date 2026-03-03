#!/usr/bin/env bash

# Create a Jira ticket via REST API v2
# Handles required custom fields like Team (customfield_10200)
#
# Usage:
#   jira-create-ticket.sh \
#     --project ID \
#     --type Story \
#     --summary "Ticket summary" \
#     --parent ID-1234 \
#     --team "$JIRA_TEAM" \
#     [--assignee email@example.com] \
#     [--description "Multi-line description"] \
#     [--labels "label1,label2"]

set -euo pipefail

# Default values
ASSIGNEE=""
DESCRIPTION=""
LABELS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --project) PROJECT="$2"; shift 2 ;;
    --type) TYPE="$2"; shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    --parent) PARENT="$2"; shift 2 ;;
    --team) TEAM="$2"; shift 2 ;;
    --assignee) ASSIGNEE="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --labels) LABELS="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Validate required fields
if [[ -z "${PROJECT:-}" ]] || [[ -z "${TYPE:-}" ]] || [[ -z "${SUMMARY:-}" ]] || [[ -z "${PARENT:-}" ]] || [[ -z "${TEAM:-}" ]]; then
  echo "Error: Missing required fields"
  echo "Required: --project, --type, --summary, --parent, --team"
  exit 1
fi

# Validate environment
if [[ -z "${JIRA_SITE:-}" ]] || [[ -z "${JIRA_USER:-}" ]] || [[ -z "${JIRA_API_TOKEN:-}" ]]; then
  echo "Error: Missing Jira environment variables"
  echo "Required: JIRA_SITE, JIRA_USER, JIRA_API_TOKEN"
  exit 1
fi

# Build the request JSON
REQUEST=$(cat <<EOF
{
  "fields": {
    "project": { "key": "$PROJECT" },
    "summary": "$SUMMARY",
    "issuetype": { "name": "$TYPE" },
    "parent": { "key": "$PARENT" },
    "customfield_10200": "$TEAM"
EOF
)

# Add optional description
if [[ -n "$DESCRIPTION" ]]; then
  REQUEST+=",
    \"description\": $(printf '%s\n' "$DESCRIPTION" | jq -Rs .)"
fi

# Add optional assignee
if [[ -n "$ASSIGNEE" ]]; then
  REQUEST+=",
    \"assignee\": { \"name\": \"$ASSIGNEE\" }"
fi

# Add optional labels
if [[ -n "$LABELS" ]]; then
  # Convert comma-separated string to JSON array
  LABELS_JSON=$(echo "$LABELS" | tr ',' '\n' | jq -R . | jq -s .)
  REQUEST+=",
    \"labels\": $LABELS_JSON"
fi

REQUEST+="
  }
}"

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
