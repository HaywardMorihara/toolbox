#!/usr/bin/env bash

# Interactive Jira setup script for toolbox
# Guides users through acli installation, token storage, and authentication

set -euo pipefail

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   Jira CLI (acli) Setup Assistant     ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Step 1: Check/Install acli
echo "Step 1: Installing Atlassian CLI (acli)"
echo ""

if command -v acli &> /dev/null; then
  echo "✓ Atlassian CLI is already installed"
else
  echo "Installing acli via Homebrew..."
  if brew install atlassian-cli; then
    echo "✓ acli installed successfully"
  else
    echo "✗ Failed to install acli. Exiting."
    exit 1
  fi
fi

echo ""
echo "─────────────────────────────────────────"
echo ""

# Step 2: Get API token (with idempotency check)
echo "Step 2: Create and store your API token"
echo ""

if [[ -f ~/.config/toolbox/jira-token.txt ]]; then
  echo -n "Token file already exists. Update token? [y/n]: "
  read -r update_token

  if [[ ! "$update_token" =~ ^[yY]$ ]]; then
    echo "✓ Keeping existing token"
    echo ""
    echo "─────────────────────────────────────────"
    echo ""
  else
    echo "Go to: https://id.atlassian.com/manage-profile/security/api-tokens"
    echo "Click 'Create API token' and copy the token"
    echo ""
    echo -n "Paste your API token: "
    read -r token

    if [[ -z "$token" ]]; then
      echo "✗ No token provided. Exiting."
      exit 1
    fi

    mkdir -p ~/.config/toolbox
    echo "$token" > ~/.config/toolbox/jira-token.txt
    chmod 600 ~/.config/toolbox/jira-token.txt

    echo "✓ Token updated in ~/.config/toolbox/jira-token.txt"
    echo ""
    echo "─────────────────────────────────────────"
    echo ""
  fi
else
  echo "Go to: https://id.atlassian.com/manage-profile/security/api-tokens"
  echo "Click 'Create API token' and copy the token"
  echo ""
  echo -n "Paste your API token: "
  read -r token

  if [[ -z "$token" ]]; then
    echo "✗ No token provided. Exiting."
    exit 1
  fi

  mkdir -p ~/.config/toolbox
  echo "$token" > ~/.config/toolbox/jira-token.txt
  chmod 600 ~/.config/toolbox/jira-token.txt

  echo "✓ Token stored in ~/.config/toolbox/jira-token.txt"
  echo ""
  echo "─────────────────────────────────────────"
  echo ""
fi

echo ""
echo "─────────────────────────────────────────"
echo ""

# Step 3: Collect org settings (with idempotency check)
echo "Step 3: Configure your organization settings"
echo ""

TOOLBOX_ROOT="${TOOLBOX_ROOT:-.}"
private_dir="$TOOLBOX_ROOT/private"
sample_ticket=""

# Load existing values if they exist
if [[ -f "$private_dir/jira.sh" ]]; then
  source "$private_dir/jira.sh" 2>/dev/null || true
fi

# Use existing values as defaults, or fallback to generic defaults
default_site="${JIRA_SITE:-yourcompany.atlassian.net}"
default_project="${JIRA_PROJECT:-PROJ}"
default_user="${JIRA_USER:-your@email.com}"
default_team="${JIRA_TEAM:-My Team}"
default_epic_ids="${JIRA_EPIC_IDS:-}"
default_label_options="${JIRA_LABEL_OPTIONS:-}"

echo -n "Your Atlassian site domain [$default_site]: "
read -r jira_site
jira_site="${jira_site:-$default_site}"

echo -n "Your project ID [$default_project]: "
read -r jira_project
jira_project="${jira_project:-$default_project}"

echo -n "Your Atlassian account email [$default_user]: "
read -r jira_user
jira_user="${jira_user:-$default_user}"

# Check if Team UUID is already configured
if [[ -n "$JIRA_TEAM" && "$JIRA_TEAM" != "My Team" ]]; then
  echo ""
  echo "✓ Team UUID already configured: $JIRA_TEAM"
  jira_team="$JIRA_TEAM"
else
  echo ""
  echo "To get your Team UUID:"
  echo "1. Open your Jira project in a browser"
  echo "2. Find a ticket assigned to your team"
  echo "3. Copy the issue key (e.g., PROJ-123)"
  echo ""
  echo -n "Sample ticket from your team [PROJ-123]: "
  read -r sample_ticket
  sample_ticket="${sample_ticket:-PROJ-123}"

  echo ""
  echo "Fetching team UUID from $sample_ticket..."
  echo ""

  # Load token if it exists
  if [[ -f ~/.config/toolbox/jira-token.txt ]]; then
    token=$(cat ~/.config/toolbox/jira-token.txt)

    # Fetch the ticket and extract team info
    team_json=$(curl -s -u "$jira_user:$token" \
      "https://$jira_site/rest/api/2/issue/$sample_ticket" 2>/dev/null || echo "{}")

    # Try to extract Team field (customfield_10200)
    jira_team=$(echo "$team_json" | python3 -c "
import json, sys
try:
  data = json.load(sys.stdin)
  team_field = data.get('fields', {}).get('customfield_10200', {})
  if isinstance(team_field, dict):
    print(f\"{team_field.get('id', '')}\")
  elif isinstance(team_field, str):
    print(team_field)
except:
  pass
" 2>/dev/null)

    if [[ -n "$jira_team" ]]; then
      echo "✓ Found Team UUID: $jira_team"
    else
      echo "⚠ Could not auto-detect Team UUID from $sample_ticket"
      echo "You may need to look it up manually. The Team field is customfield_10200."
      echo ""
      echo -n "Enter your Team UUID manually: "
      read -r jira_team
    fi
  else
    echo "⚠ Token file not found. Skipping Team UUID auto-detection."
    echo ""
    echo -n "Enter your Team UUID: "
    read -r jira_team
  fi
fi

echo ""
echo "─────────────────────────────────────────"
echo ""

# Step 3.5: Get commonly used epic IDs (optional)
echo "Step 3.5: Configure commonly used epic IDs (optional)"
echo ""
echo "Enter the key IDs of epics you frequently work with (e.g., ID-100, ID-200)."
echo "Their descriptions will be fetched from Jira automatically when creating tickets."
echo ""

if [[ -n "$default_epic_ids" ]]; then
  echo "Current epic IDs: $default_epic_ids"
  echo ""
  echo -n "Update epic IDs? [y/n]: "
  read -r update_epics

  if [[ "$update_epics" =~ ^[yY]$ ]]; then
    echo ""
    echo "Enter new epic IDs (comma-separated, e.g., 'ID-100,ID-200')."
    echo "Press Enter with empty input to keep existing values."
    echo ""
    echo -n "Epic IDs: "
    read -r jira_epic_ids
    jira_epic_ids="${jira_epic_ids:-$default_epic_ids}"
  else
    echo "✓ Keeping existing epic IDs"
    jira_epic_ids="$default_epic_ids"
  fi
else
  echo "Enter epic IDs (comma-separated, e.g., 'ID-100,ID-200')."
  echo "Leave empty to skip."
  echo ""
  echo -n "Epic IDs: "
  read -r jira_epic_ids
  jira_epic_ids="${jira_epic_ids:-}"
fi

echo ""
echo "─────────────────────────────────────────"
echo ""

# Step 3.6: Get commonly used labels (optional)
echo "Step 3.6: Configure commonly used labels (optional)"
echo ""
echo "Enter labels you frequently use when creating tickets (e.g., bug, urgent, needs-review)."
echo "These will be offered as quick options in AskUserQuestion when creating tickets."
echo ""

if [[ -n "$default_label_options" ]]; then
  echo "Current labels: $default_label_options"
  echo ""
  echo -n "Update labels? [y/n]: "
  read -r update_labels

  if [[ "$update_labels" =~ ^[yY]$ ]]; then
    echo ""
    echo "Enter label options (comma-separated, e.g., 'bug,urgent,needs-review')."
    echo "Press Enter with empty input to keep existing values."
    echo ""
    echo -n "Labels: "
    read -r jira_label_options
    jira_label_options="${jira_label_options:-$default_label_options}"
  else
    echo "✓ Keeping existing labels"
    jira_label_options="$default_label_options"
  fi
else
  echo "Enter label options (comma-separated, e.g., 'bug,urgent,needs-review')."
  echo "Leave empty to skip."
  echo ""
  echo -n "Labels: "
  read -r jira_label_options
  jira_label_options="${jira_label_options:-}"
fi

echo ""
echo "─────────────────────────────────────────"
echo ""

# Step 4: Create private/jira.sh
echo "Step 4: Creating private/jira.sh with your settings"
echo ""

mkdir -p "$private_dir"

cat > "$private_dir/jira.sh" << EOF
# Jira configuration for acli
# Set these environment variables for use with acli commands and Jira skill

export JIRA_SITE="$jira_site"
export JIRA_PROJECT="$jira_project"
export JIRA_USER="$jira_user"

# JIRA_TEAM is the Team field UUID (customfield_10200)
# This is used when creating tickets with required Team fields via REST API
export JIRA_TEAM="$jira_team"

export JIRA_BASE_URL="https://\$JIRA_SITE"
export JIRA_API_TOKEN="\$(cat ~/.config/toolbox/jira-token.txt 2>/dev/null)"

# Frequently used epic IDs (comma-separated)
# Descriptions are fetched dynamically from Jira when creating tickets
# These will be offered as quick options in AskUserQuestion
# Example: export JIRA_EPIC_IDS="ID-100,ID-200,ID-300"
export JIRA_EPIC_IDS="$jira_epic_ids"

# Frequently used label options (comma-separated)
# Offered as quick options in AskUserQuestion when creating tickets
# Example: export JIRA_LABEL_OPTIONS="bug,urgent,needs-review"
export JIRA_LABEL_OPTIONS="$jira_label_options"
EOF

chmod 600 "$private_dir/jira.sh"
echo "✓ Created $private_dir/jira.sh"

echo ""
echo "─────────────────────────────────────────"
echo ""

# Step 5: Authenticate with acli
echo "Step 5: Authenticate with acli"
echo ""
echo "This is a one-time setup. acli will store your credentials securely."
echo ""

echo -n "Authenticate now? [y/n]: "
read -r auth_response

if [[ "$auth_response" =~ ^[yY]$ ]]; then
  echo ""
  echo "Authenticating as $jira_user to $jira_site..."
  if cat ~/.config/toolbox/jira-token.txt | acli jira auth login -e "$jira_user" -s "$jira_site" --token; then
    echo "✓ Authentication successful!"
  else
    echo "✗ Authentication failed. Check your email and site settings."
    exit 1
  fi
else
  echo "Skipping authentication. You can authenticate later by running:"
  echo "  cat ~/.config/toolbox/jira-token.txt | acli jira auth login -e \"\$JIRA_USER\" -s \"\$JIRA_SITE\" --token"
fi

echo ""
echo "─────────────────────────────────────────"
echo ""

# Step 6: Verify
echo "Step 6: Verifying setup"
echo ""

# Test authentication
if acli jira user current > /dev/null 2>&1; then
  echo "✓ Authentication verified"
else
  echo "⚠ Could not verify authentication. Try running:"
  echo "  acli jira user current"
fi

# Test Team UUID by fetching a sample ticket
if [[ -n "$jira_team" ]] && [[ -f ~/.config/toolbox/jira-token.txt ]] && [[ -n "$sample_ticket" ]]; then
  echo ""
  echo "Verifying Team UUID configuration..."
  token=$(cat ~/.config/toolbox/jira-token.txt)
  team_check=$(curl -s -u "$jira_user:$token" \
    "https://$jira_site/rest/api/2/issue/$sample_ticket" 2>/dev/null | \
    python3 -c "
import json, sys
try:
  data = json.load(sys.stdin)
  team_field = data.get('fields', {}).get('customfield_10200', {})
  if isinstance(team_field, dict) and team_field.get('id') == '$jira_team':
    print('match')
  elif isinstance(team_field, str) and team_field == '$jira_team':
    print('match')
except:
  pass
" 2>/dev/null)

  if [[ "$team_check" == "match" ]]; then
    echo "✓ Team UUID verified: $jira_team"
  else
    echo "⚠ Team UUID may not be correct. Verify in JIRA: https://$jira_site/browse/$sample_ticket"
  fi
fi

echo ""
echo "✓ Jira setup complete!"
echo ""
echo "Your configuration is stored in: $private_dir/jira.sh"
echo ""
echo "Try these commands to test:"
echo "  acli jira user current                    # Show your user info"
echo "  acli jira project list                    # List projects"
echo "  acli jira workitem view $jira_project-1   # View an issue"
echo ""
