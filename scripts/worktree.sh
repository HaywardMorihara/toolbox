#!/usr/bin/env bash
# scripts/worktree.sh - Git worktree management for parallel development
#
# Provides utilities for agents to manually manage git worktrees,
# enabling multiple agents to work on different features simultaneously without
# interfering with each other.
#
# Functions:
#   worktree_create <branch_name> - Create a new worktree for the given branch
#   worktree_cleanup_and_merge <worktree_path> - Remove a worktree and finalize changes
#   worktree_cleanup_orphaned [--remove] - Find and optionally remove orphaned worktrees
#   worktree_list - List all active worktrees

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Create a new git worktree for a feature branch
#
# Usage: worktree_create <branch_name>
#
# Parameters:
#   $1: branch_name - Name for the new branch/worktree (e.g., "feature/my-feature")
#
# Returns:
#   0 on success, 1 on failure
#
# The worktree is created in .worktrees/<branch-name> relative to the repo root.
#
# Example:
#   worktree_create "feature/issue-30"
#
worktree_create() {
  local branch_name="$1"

  # Validate inputs
  if [[ -z "$branch_name" ]]; then
    log_error "branch_name is required"
    log_info "Usage: worktree_create <branch_name>"
    return 1
  fi

  # Validate we're in a git repository
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not in a git repository"
    return 1
  fi

  # Get repo root directory
  local repo_root
  repo_root="$(git rev-parse --show-toplevel)" || {
    log_error "Failed to determine git repository root"
    return 1
  }

  # Sanitize branch name to create safe directory name
  # Replace / with - to avoid nested directories
  local safe_name="${branch_name#*/}"  # Remove prefix like "feature/"
  safe_name="${safe_name//\//-}"       # Replace remaining slashes with dashes

  # Create worktrees directory if it doesn't exist
  local worktrees_dir="$repo_root/.worktrees"
  if [[ ! -d "$worktrees_dir" ]]; then
    mkdir -p "$worktrees_dir" || {
      log_error "Failed to create .worktrees directory: $worktrees_dir"
      return 1
    }
  fi

  # Create worktree directory path
  local worktree_path="$worktrees_dir/$safe_name"

  # Check if worktree directory already exists
  if [[ -d "$worktree_path" ]]; then
    log_warn "Worktree directory already exists: $worktree_path"
    return 1
  fi

  # Check if branch already exists in git worktree list
  if git worktree list | grep -q "$branch_name"; then
    log_warn "Branch already has an active worktree: $branch_name"
    return 1
  fi

  log_info "Creating worktree for branch: $branch_name"
  log_info "Worktree location: $worktree_path"

  # Create the worktree with a new branch
  if git worktree add "$worktree_path" -b "$branch_name"; then
    log_success "Worktree created successfully"
    log_info "To work in the new worktree, run:"
    log_info "  cd \"$worktree_path\""
    return 0
  else
    log_error "Failed to create worktree"
    # Clean up the directory if git worktree creation failed
    rm -rf "$worktree_path"
    return 1
  fi
}

# Remove a worktree and finalize changes
#
# This function performs the complete cleanup workflow:
#   1. Pull latest main into the worktree
#   2. Push changes to remote
#   3. Remove the worktree
#   4. Pull latest main in the primary repository
#
# Usage: worktree_cleanup_and_merge <worktree_path>
#
# Parameters:
#   $1: worktree_path - Path to the worktree to remove
#
# Returns:
#   0 on success, 1 on failure
#
# Example:
#   worktree_cleanup_and_merge ".worktrees/issue-30"
#
worktree_cleanup_and_merge() {
  local worktree_path="$1"

  if [[ -z "$worktree_path" ]]; then
    log_error "worktree_path is required"
    log_info "Usage: worktree_cleanup_and_merge <worktree_path>"
    return 1
  fi

  # Resolve to absolute path
  if [[ ! "$worktree_path" = /* ]]; then
    worktree_path="$(cd "$worktree_path" 2>/dev/null && pwd)" || {
      log_error "Worktree path does not exist: $1"
      return 1
    }
  fi

  # Validate the path exists
  if [[ ! -d "$worktree_path" ]]; then
    log_error "Worktree path does not exist: $worktree_path"
    return 1
  fi

  # Verify it's actually a git worktree
  if ! git -C "$worktree_path" rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Directory is not a valid git worktree: $worktree_path"
    return 1
  fi

  log_info "Starting worktree cleanup and merge workflow..."

  # Step 1: Pull latest main in the worktree
  log_info "Step 1: Pulling latest main in worktree..."
  if ! git -C "$worktree_path" pull origin main 2>/dev/null; then
    log_warn "Failed to pull from origin main (might not exist or already up to date)"
  fi

  # Step 2: Push changes to remote
  log_info "Step 2: Pushing changes to remote..."
  local current_branch
  current_branch=$(git -C "$worktree_path" rev-parse --abbrev-ref HEAD)

  if ! git -C "$worktree_path" push -u origin "$current_branch"; then
    log_error "Failed to push changes"
    log_info "Please fix the push error and try again"
    return 1
  fi

  # Step 3: Remove the worktree
  log_info "Step 3: Removing worktree..."
  if ! git worktree remove "$worktree_path"; then
    log_warn "Failed to remove worktree cleanly, attempting force removal..."
    if ! git worktree remove --force "$worktree_path"; then
      log_error "Failed to remove worktree (even with --force)"
      return 1
    fi
  fi

  # Step 4: Pull latest main in primary repository
  log_info "Step 4: Pulling latest main in primary repository..."
  local repo_root
  repo_root="$(git rev-parse --show-toplevel)" || {
    log_error "Failed to determine git repository root"
    return 1
  }

  if ! git -C "$repo_root" pull origin main 2>/dev/null; then
    log_warn "Failed to pull from origin main in primary repo"
  fi

  log_success "Worktree cleanup and merge workflow completed successfully"
  return 0
}

# List all active git worktrees
#
# Usage: worktree_list
#
# Returns:
#   0 always
#
# Example:
#   worktree_list
#
worktree_list() {
  log_info "Active git worktrees:"
  git worktree list || {
    log_error "Failed to list worktrees"
    return 1
  }
}

# Find and optionally remove orphaned worktrees
#
# A worktree is considered orphaned if:
#   1. The worktree directory doesn't exist on disk
#   2. The worktree directory exists but contains no valid git repository
#
# Usage: worktree_cleanup_orphaned [--remove]
#
# Parameters:
#   --remove - Actually remove orphaned worktrees (dry-run by default)
#
# Returns:
#   0 if no orphaned worktrees found, 1 if orphaned worktrees exist/were found
#
# Example:
#   worktree_cleanup_orphaned           # List orphaned worktrees (dry-run)
#   worktree_cleanup_orphaned --remove  # Remove orphaned worktrees
#
worktree_cleanup_orphaned() {
  local remove_flag=false

  # Parse arguments
  if [[ "$1" == "--remove" ]]; then
    remove_flag=true
  fi

  log_info "Checking for orphaned worktrees..."

  local orphaned_count=0
  local worktree_line

  # Read worktree list line by line, skip first line (main)
  while IFS= read -r worktree_line; do
    # Skip empty lines and the main worktree
    [[ -z "$worktree_line" ]] && continue
    [[ "$worktree_line" == *"(bare)"* ]] && continue
    [[ "$worktree_line" == *"(detached)"* ]] && continue

    # Extract path (first field before whitespace)
    local wt_path="${worktree_line%% *}"

    # Check if path exists and is a valid git repo
    if [[ ! -d "$wt_path" ]] || ! git -C "$wt_path" rev-parse --git-dir > /dev/null 2>&1; then
      log_warn "Found orphaned worktree: $wt_path"
      orphaned_count=$((orphaned_count + 1))

      # Remove if requested
      if [[ "$remove_flag" == true ]]; then
        if git worktree remove --force "$wt_path" 2>/dev/null; then
          log_success "Removed orphaned worktree: $wt_path"
        else
          log_error "Failed to remove orphaned worktree: $wt_path"
        fi
      fi
    fi
  done < <(git worktree list)

  if [[ $orphaned_count -eq 0 ]]; then
    log_success "No orphaned worktrees found"
    return 0
  else
    if [[ "$remove_flag" == false ]]; then
      log_warn "Found $orphaned_count orphaned worktree(s)"
      log_info "Run with --remove flag to clean them up: worktree_cleanup_orphaned --remove"
    fi
    return 1
  fi
}

# Main script logic - allow sourcing or direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # Script is being executed directly, not sourced
  command="$1"
  shift || true

  case "$command" in
    create)
      worktree_create "$@"
      ;;
    cleanup)
      worktree_cleanup_and_merge "$@"
      ;;
    list)
      worktree_list "$@"
      ;;
    cleanup-orphaned)
      worktree_cleanup_orphaned "$@"
      ;;
    *)
      echo "Git Worktree Management Script"
      echo ""
      echo "Usage: $(basename "$0") <command> [options]"
      echo ""
      echo "Commands:"
      echo "  create <branch_name>           Create a new worktree for the given branch"
      echo "  cleanup <worktree_path>        Remove worktree and finalize changes (pull/push/merge)"
      echo "  list                           List all active worktrees"
      echo "  cleanup-orphaned [--remove]    Find orphaned worktrees (or remove with --remove)"
      echo ""
      echo "Examples:"
      echo "  $(basename "$0") create feature/my-feature"
      echo "  $(basename "$0") cleanup .worktrees/my-feature"
      echo "  $(basename "$0") cleanup-orphaned --remove"
      ;;
  esac
fi
