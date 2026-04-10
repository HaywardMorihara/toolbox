#!/usr/bin/env bash

##
# pr-monitor.sh - Monitor pull requests where you are the author or have commented
#
# Checks for open PRs across repositories where you're the author or have interacted,
# and identifies which ones have updates since your last comment.
#

set -euo pipefail

# Show help
show_help() {
  cat <<'EOF'
pr-monitor - Monitor pull requests across repos

USAGE
  pr-monitor [FLAGS] [REPO]

ARGUMENTS
  REPO                Repository in owner/repo format (e.g., anthropics/claude-code)
                      If not specified, uses current repo's git remote

FLAGS
  --all               Check all repos configured in ~/.config/toolbox/pr-monitor.conf
  --help              Show this help message

EXAMPLES
  pr-monitor                           # Check current repo
  pr-monitor --all                     # Check all configured repos
  pr-monitor anthropics/claude-code    # Check specific repo

CONFIGURATION (required for --all)
  Create ~/.config/toolbox/pr-monitor.conf with:

    REPOS=(
      "owner/repo1"
      "owner/repo2"
    )
    GITHUB_USER="your-github-username"  # Optional - auto-detected if omitted

  Then run: pr-monitor --all

OUTPUT
  [AUTHOR]   - PRs you created (shown in green)
  [UPDATES]  - PRs where you commented and there are newer comments (shown in yellow)
  [no changes] - PRs where you commented but no updates since your last interaction (dimmed)

REQUIREMENTS
  - GitHub CLI (gh) - https://cli.github.com/
  - Active GitHub authentication: gh auth login

EOF
}


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m'

# Utilities
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_gray() { echo -e "${GRAY}$1${NC}"; }

# Configuration
CONFIG_FILE="$HOME/.config/toolbox/pr-monitor.conf"
GITHUB_USER="${GITHUB_USER:-}"
CHECK_ALL=false

# Load configuration
load_config() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Configuration file not found: $CONFIG_FILE"
    log_info "Create it with:"
    cat >&2 <<'EOF'

REPOS=("owner/repo1" "owner/repo2")
GITHUB_USER="your-github-username"

EOF
    return 1
  fi

  # Source config
  # shellcheck disable=SC1090
  source "$CONFIG_FILE" || {
    log_error "Failed to load config from $CONFIG_FILE"
    return 1
  }

  # Set default GitHub user if not configured
  if [[ -z "$GITHUB_USER" ]]; then
    GITHUB_USER=$(git config user.name 2>/dev/null || echo "")
    if [[ -z "$GITHUB_USER" ]]; then
      log_error "GITHUB_USER not configured and git config user.name not found"
      return 1
    fi
  fi

  return 0
}

# Get current repo in owner/repo format from git remote origin
get_current_repo() {
  local remote_url
  remote_url=$(git config --get remote.origin.url 2>/dev/null) || return 1

  # Handle both HTTPS and SSH URLs
  if [[ "$remote_url" =~ ^https://github\.com/([^/]+)/(.+)\.git$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  elif [[ "$remote_url" =~ ^git@github\.com:([^/]+)/(.+)\.git$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  else
    return 1
  fi
}

# Check if gh CLI is available
require_gh() {
  if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is required but not installed"
    log_info "Install it with: brew install gh"
    return 1
  fi
  return 0
}

# Check a single PR - return status (AUTHOR, COMMENTED_WITH_UPDATES, COMMENTED_NO_UPDATES, SKIP)
check_single_pr() {
  local repo="$1"
  local pr_number="$2"
  local author_login="$3"
  local github_user="$4"

  # Check if we're the author
  if [[ "$author_login" == "$github_user" ]]; then
    echo "AUTHOR"
    return 0
  fi

  # Get comments and reviews for this PR
  local pr_data
  pr_data=$(gh pr view "$pr_number" --repo "$repo" --json comments,reviews 2>/dev/null)

  if [[ -z "$pr_data" ]]; then
    echo "SKIP"
    return 0
  fi

  # Combine comments and reviews into a single array
  local all_interactions
  all_interactions=$(echo "$pr_data" | jq '
    (.comments // []) +
    (
      (.reviews // []) | map(
        select(.state == "COMMENTED" or .state == "APPROVED" or .state == "CHANGES_REQUESTED") |
        {author: {login: .author.login}, createdAt: .submittedAt}
      )
    )
  ' 2>/dev/null)

  if [[ -z "$all_interactions" ]] || [[ "$all_interactions" == "null" ]]; then
    echo "SKIP"
    return 0
  fi

  # Check if user has interacted (commented or reviewed)
  local has_user_interaction
  has_user_interaction=$(echo "$all_interactions" | jq --arg user "$github_user" 'any(.author.login == $user)' 2>/dev/null)

  if [[ "$has_user_interaction" != "true" ]]; then
    echo "SKIP"
    return 0
  fi

  # Find user's last interaction and latest interaction
  local last_user_interaction latest_interaction
  last_user_interaction=$(echo "$all_interactions" | jq -r --arg user "$github_user" '[.[] | select(.author.login == $user)] | max_by(.createdAt) | .createdAt // empty' 2>/dev/null)
  latest_interaction=$(echo "$all_interactions" | jq -r 'max_by(.createdAt) | .createdAt // empty' 2>/dev/null)

  if [[ -z "$last_user_interaction" ]] || [[ -z "$latest_interaction" ]]; then
    echo "SKIP"
    return 0
  fi

  # Check if there are updates since our last interaction
  if [[ "$latest_interaction" > "$last_user_interaction" ]]; then
    echo "COMMENTED_WITH_UPDATES"
  else
    echo "COMMENTED_NO_UPDATES"
  fi
}

# Check if a date is within the last 7 days
is_recent() {
  local date_str="$1"
  local date_epoch
  local now_epoch
  local seven_days_seconds=$((7 * 24 * 3600))

  date_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$date_str" "+%s" 2>/dev/null)
  now_epoch=$(date "+%s")

  if [[ -z "$date_epoch" ]]; then
    return 1
  fi

  local diff=$((now_epoch - date_epoch))
  [[ $diff -lt $seven_days_seconds ]]
}

# Check if a date is older than 2 months
is_too_old() {
  local date_str="$1"
  local date_epoch
  local now_epoch
  local two_months_seconds=$((60 * 24 * 3600))

  date_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$date_str" "+%s" 2>/dev/null)
  now_epoch=$(date "+%s")

  if [[ -z "$date_epoch" ]]; then
    return 1
  fi

  local diff=$((now_epoch - date_epoch))
  [[ $diff -gt $two_months_seconds ]]
}

# Get most recent activity AFTER user's last interaction
get_latest_activity_after_user() {
  local repo="$1"
  local pr_number="$2"
  local github_user="$3"

  local pr_data

  pr_data=$(gh pr view "$pr_number" --repo "$repo" --json comments,reviews 2>/dev/null)

  if [[ -z "$pr_data" ]]; then
    return
  fi

  # Get user's last interaction date (from both comments and reviews)
  local user_last_date
  user_last_date=$(echo "$pr_data" | jq -r --arg user "$github_user" '
    (
      [(.comments // [] | map(select(.author.login == $user) | .createdAt))] +
      [(.reviews // [] | map(select(.author.login == $user) | .submittedAt))]
    ) |
    flatten | max
  ' 2>/dev/null)

  if [[ -z "$user_last_date" ]] || [[ "$user_last_date" == "null" ]]; then
    return
  fi

  # Get the first activity (comment or review) after that date
  local latest_activity
  latest_activity=$(echo "$pr_data" | jq -r --arg user_date "$user_last_date" '
    (
      (.comments // [] | map(select(.createdAt > $user_date) | {author: .author.login, date: .createdAt, body: .body, type: "comment"})) +
      (.reviews // [] | map(select(.submittedAt > $user_date and (.state == "COMMENTED" or .state == "APPROVED" or .state == "CHANGES_REQUESTED")) | {author: .author.login, date: .submittedAt, body: .body, type: .state}))
    ) |
    sort_by(.date) |
    .[0] |
    if . then "\(.author)|\(.date)|\(.type)|\(.body // \"(see PR for details)\")" else empty end
  ' 2>/dev/null)

  if [[ -n "$latest_activity" ]]; then
    echo "$latest_activity"
  fi
}

# Extract and format the first line of a comment/review body
format_activity_description() {
  local body="$1"
  local max_length=80

  # Get first line, strip markdown, limit length
  local first_line
  first_line=$(echo "$body" | head -1 | sed 's/^[#*_-]*//;s/[#*_-]*$//;s/^ *//;s/ *$//')

  if [[ ${#first_line} -gt $max_length ]]; then
    first_line="${first_line:0:$max_length}..."
  fi

  echo "$first_line"
}

# Get most recent activity (overall, for non-update PRs)
get_latest_activity() {
  local repo="$1"
  local pr_number="$2"

  local pr_data

  pr_data=$(gh pr view "$pr_number" --repo "$repo" --json comments,reviews 2>/dev/null)

  if [[ -z "$pr_data" ]]; then
    return
  fi

  # Get the most recent activity from comments and reviews combined
  local latest_activity
  latest_activity=$(echo "$pr_data" | jq -r '
    (
      (.comments // [] | map({author: .author.login, date: .createdAt, body: .body, type: "comment"})) +
      (.reviews // [] | map(select(.state == "COMMENTED" or .state == "APPROVED" or .state == "CHANGES_REQUESTED") | {author: .author.login, date: .submittedAt, body: .body, type: .state}))
    ) |
    sort_by(.date) | reverse | .[0] |
    if . then "\(.author)|\(.date)|\(.type)|\(.body)" else empty end
  ' 2>/dev/null)

  if [[ -n "$latest_activity" ]]; then
    echo "$latest_activity"
  fi
}

# Get PR URL
get_pr_url() {
  local repo="$1"
  local number="$2"
  echo "https://github.com/$repo/pull/$number"
}

# Display PR information
display_pr() {
  local number="$1"
  local title="$2"
  local author="$3"
  local status="$4"
  local repo="$5"
  local updated_at="$6"

  # Format the date
  local formatted_date
  formatted_date=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$updated_at" "+%b %d" 2>/dev/null || echo "$updated_at")

  # Check if PR was updated in the last week
  local show_details=false
  if is_recent "$updated_at"; then
    show_details=true
  fi

  # Create clickable PR link
  local pr_url
  pr_url=$(get_pr_url "$repo" "$number")
  local pr_link="#$number"

  case "$status" in
    AUTHOR)
      echo -e "${GREEN}[AUTHOR]${NC} ${pr_link} - $title"
      echo -e "  ${GRAY}$pr_url${NC}"
      echo -e "  ${GRAY}by $author • updated $formatted_date${NC}"
      ;;
    COMMENTED_WITH_UPDATES)
      echo -e "${YELLOW}[UPDATES]${NC} ${pr_link} - $title"
      echo -e "  ${GRAY}$pr_url${NC}"
      echo -e "  ${GRAY}by $author • updated $formatted_date${NC}"
      ;;
    COMMENTED_NO_UPDATES)
      log_gray "  [no changes] ${pr_link} - $title"
      log_gray "  $pr_url"
      log_gray "  by $author • updated $formatted_date"
      ;;
  esac

  # For recent PRs, show latest activity details
  if [[ "$show_details" == true ]]; then
    local activity

    # For UPDATES status, show what changed AFTER user's last interaction
    if [[ "$status" == "COMMENTED_WITH_UPDATES" ]]; then
      activity=$(get_latest_activity_after_user "$repo" "$number" "$GITHUB_USER")
    else
      # For other statuses, just show the latest overall activity
      activity=$(get_latest_activity "$repo" "$number")
    fi

    if [[ -n "$activity" ]]; then
      local activity_author activity_type activity_date activity_body

      # Parse based on format returned
      if [[ "$status" == "COMMENTED_WITH_UPDATES" ]]; then
        # Format from get_latest_activity_after_user: author|type|date|body
        IFS='|' read -r activity_author activity_type activity_date activity_body <<< "$activity"
      else
        # Format from get_latest_activity: author|date|type|body
        IFS='|' read -r activity_author activity_date activity_type activity_body <<< "$activity"
      fi

      local activity_formatted_date
      activity_formatted_date=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$activity_date" "+%b %d %H:%M" 2>/dev/null || echo "$activity_date")

      echo -e "  ${GRAY}└─ Latest: $activity_author on $activity_formatted_date${NC}"

      local description
      description=$(format_activity_description "$activity_body")

      if [[ -n "$description" ]]; then
        echo -e "  ${GRAY}   \"$description\"${NC}"
      elif [[ "$status" == "COMMENTED_WITH_UPDATES" ]]; then
        # For updates with no visible description, indicate to check PR
        echo -e "  ${GRAY}   (click link above to see details)${NC}"
      fi
    fi
  fi
}

# Process all repos using GitHub search API to find relevant PRs
check_repos() {
  local target_repos=()
  local found_relevant=false

  # Determine which repos to check
  if [[ "$CHECK_ALL" == true ]]; then
    # Check all configured repos
    target_repos=("${REPOS[@]}")
  elif [[ -n "${1:-}" ]]; then
    # Check specific repo passed as argument
    target_repos=("$1")
  else
    # Check current repo
    local current_repo
    current_repo=$(get_current_repo) || {
      log_error "Could not determine current repo. Make sure you're in a git repo with a GitHub remote."
      log_info "Or specify a repo: pr-monitor owner/repo"
      return 1
    }
    target_repos=("$current_repo")
  fi

  for repo in "${target_repos[@]}"; do
    log_info "Checking $repo..."

    # Use GitHub search API to find PRs where user is author or has interacted
    # This is much more efficient than fetching all PRs in a monorepo
    local author_prs reviewed_prs

    # Search for PRs authored by user
    author_prs=$(gh search prs --repo "$repo" --author "$GITHUB_USER" --state open --json number,title,author,updatedAt 2>/dev/null || echo "[]")

    # Search for PRs where user has reviewed/commented
    reviewed_prs=$(gh search prs --repo "$repo" --reviewed-by "$GITHUB_USER" --state open --json number,title,author,updatedAt 2>/dev/null || echo "[]")

    # Combine and deduplicate
    local prs
    prs=$(echo "$author_prs $reviewed_prs" | jq -s 'add | unique_by(.number)' 2>/dev/null || echo "[]")

    local pr_count
    pr_count=$(echo "$prs" | jq 'length' 2>/dev/null || echo 0)

    if [[ $pr_count -eq 0 ]]; then
      log_gray "  No relevant PRs"
      continue
    fi

    # Process each PR, separating recent from stale
    # Create temp files for recent and stale PRs
    local recent_file="/tmp/pr_monitor_recent_$$"
    local stale_file="/tmp/pr_monitor_stale_$$"
    touch "$recent_file" "$stale_file"

    echo "$prs" | jq -c '.[]' | while read -r pr; do
      local number title author_login status updated_at
      number=$(echo "$pr" | jq -r '.number')
      title=$(echo "$pr" | jq -r '.title')
      author_login=$(echo "$pr" | jq -r '.author.login')
      updated_at=$(echo "$pr" | jq -r '.updatedAt')

      # Skip PRs older than 2 months
      if is_too_old "$updated_at"; then
        continue
      fi

      status=$(check_single_pr "$repo" "$number" "$author_login" "$GITHUB_USER")

      if [[ "$status" != "SKIP" ]]; then
        if is_recent "$updated_at"; then
          echo "$number|$title|$author_login|$status|$repo|$updated_at" >> "$recent_file"
        else
          echo "$number|$title|$author_login|$status|$repo|$updated_at" >> "$stale_file"
        fi
      fi
    done

    # Display stale PRs first (oldest at top)
    if [[ -s "$stale_file" ]]; then
      while IFS='|' read -r number title author_login status repo_name updated_at; do
        display_pr "$number" "$title" "$author_login" "$status" "$repo_name" "$updated_at"
        echo ""  # Add spacing between PRs
        found_relevant=true
      done < "$stale_file"
    fi

    # Add divider if there are both recent and stale PRs
    if [[ -s "$recent_file" && -s "$stale_file" ]]; then
      log_gray "─────────────────────────────────────"
      echo ""
    fi

    # Display recent PRs last (newest at bottom)
    if [[ -s "$recent_file" ]]; then
      while IFS='|' read -r number title author_login status repo_name updated_at; do
        display_pr "$number" "$title" "$author_login" "$status" "$repo_name" "$updated_at"
        echo ""  # Add spacing between PRs
        found_relevant=true
      done < "$recent_file"
    fi

    # Cleanup temp files
    rm -f "$recent_file" "$stale_file"
  done

  if [[ "$found_relevant" == false ]]; then
    echo ""
    log_success "No PRs with your involvement found"
  fi
}

# Parse arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)
        CHECK_ALL=true
        shift
        ;;
      *)
        # Assume it's a repo name
        echo "$1"
        shift
        ;;
    esac
  done
}

# Main
main() {
  # Check for --help before anything else
  if [[ "${1:-}" == "--help" ]]; then
    show_help
    return 0
  fi

  require_gh || return 1

  local specified_repo
  specified_repo=$(parse_args "$@")

  # Only require config if checking all repos
  if [[ "$CHECK_ALL" == true ]]; then
    load_config || return 1
  fi

  # Set default GitHub user if not already set
  if [[ -z "$GITHUB_USER" ]]; then
    # Get GitHub username from gh CLI
    GITHUB_USER=$(gh api user -q '.login' 2>/dev/null || echo "")
    if [[ -z "$GITHUB_USER" ]]; then
      log_error "Could not determine GitHub username. Set GITHUB_USER in config or run 'gh auth login'"
      return 1
    fi
  fi

  log_info "Monitoring PRs for user: $GITHUB_USER"
  echo ""

  if [[ "$CHECK_ALL" == true ]]; then
    check_repos
  else
    check_repos "$specified_repo"
  fi
}

main "$@"
