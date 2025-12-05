#!/usr/bin/env bash
# scripts/cwd.sh - Manage default working directory
# 
# This script manages a user-configured default working directory
# that is automatically activated in new shell sessions.
#
# Usage:
#   cwd              Set current directory as the default
#   cwd <path>       Set specified path as the default
#   cwd -g|--get     Display the currently set default directory
#   cwd -h|--help    Show this help message

# Configuration file location (user-specific, not tracked by git)
CWD_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/toolbox"
CWD_CONFIG_FILE="$CWD_CONFIG_DIR/default-wd"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Show help message
show_help() {
  cat << 'EOF'
cwd - Manage default working directory

USAGE:
  cwd              Set current directory as the default
  cwd <path>       Set specified path as the default
  cwd -g|--get     Display the currently set default directory
  cwd -h|--help    Show this help message
  cwd -v|--version Show version information

EXAMPLES:
  $ cwd                    # Sets current directory as default
  $ cwd ~/another/path     # Sets specified path as default
  $ cwd -g                 # Display the current default directory
  $ cwd                    # New tabs will cd to default automatically

CONFIGURATION:
  Default directory is stored in: ~/.config/toolbox/default-wd
  This file is not tracked by git and persists across shell sessions.
EOF
}

# Get the currently stored default working directory
get_default_wd() {
  if [[ -f "$CWD_CONFIG_FILE" ]]; then
    cat "$CWD_CONFIG_FILE"
  fi
}

# Set a new default working directory
set_default_wd() {
  local target_path="$1"
  
  # Expand ~ to home directory
  target_path="${target_path/#\~/$HOME}"
  
  # Resolve to absolute path
  if ! target_path="$(cd "$target_path" && pwd)"; then
    echo -e "${RED}Error: Cannot access directory: $1${NC}" >&2
    return 1
  fi
  
  # Create config directory if it doesn't exist
  # First ensure parent directory exists
  local parent_dir="${CWD_CONFIG_DIR%/*}"
  if [[ ! -d "$parent_dir" ]]; then
    mkdir -p "$parent_dir" || {
      echo -e "${RED}Error: Could not create parent directory: $parent_dir${NC}" >&2
      echo -e "${RED}Make sure you have write permissions in $HOME${NC}" >&2
      return 1
    }
  fi

  # Now create the config directory
  mkdir -p "$CWD_CONFIG_DIR" || {
    echo -e "${RED}Error: Could not create config directory: $CWD_CONFIG_DIR${NC}" >&2
    echo -e "${RED}Details:${NC}" >&2
    echo -e "${RED}  - Parent exists: [[ -d \"$parent_dir\" ]] = $([[ -d "$parent_dir" ]] && echo "yes" || echo "no")${NC}" >&2
    echo -e "${RED}  - Config dir path: $CWD_CONFIG_DIR${NC}" >&2
    echo -e "${RED}  - Check permissions with: ls -ld \"$parent_dir\"${NC}" >&2
    return 1
  }
  
  # Write to config file
  if echo "$target_path" > "$CWD_CONFIG_FILE"; then
    echo -e "${GREEN}Default working directory set to: $target_path${NC}"
    return 0
  else
    echo -e "${RED}Error: Could not write to config file: $CWD_CONFIG_FILE${NC}" >&2
    return 1
  fi
}

# Main logic
main() {
  local arg="${1:-}"
  
  case "$arg" in
    -h|--help)
      show_help
      return 0
      ;;
    -v|--version)
      echo "cwd version 1.0"
      return 0
      ;;
    -g|--get)
      # Display currently set default directory
      local current_wd
      current_wd="$(get_default_wd)"
      if [[ -z "$current_wd" ]]; then
        echo "No default working directory set"
        return 1
      fi
      echo "$current_wd"
      return 0
      ;;
    "")
      # No argument: use current directory
      set_default_wd "$(pwd)"
      return $?
      ;;
    *)
      # Argument provided: use it as the path
      set_default_wd "$arg"
      return $?
      ;;
  esac
}

main "$@"
