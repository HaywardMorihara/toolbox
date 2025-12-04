#!/usr/bin/env bash
# lib/common.sh - Core utilities with self-registering component system

# Colors
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

# User interaction
prompt_yes_no() {
  local prompt="$1"
  local default="${2:-n}"  # Default to 'n'

  local prompt_suffix
  if [[ "$default" == "y" ]]; then
    prompt_suffix="[Y/n]"
  else
    prompt_suffix="[y/N]"
  fi

  while true; do
    read -p "$prompt $prompt_suffix: " response
    response=${response:-$default}

    case "$response" in
      [Yy]*)
        return 0
        ;;
      [Nn]*)
        return 1
        ;;
      *)
        echo "Please answer yes or no."
        ;;
    esac
  done
}

backup_file() {
  local file="$1"

  if [[ -f "$file" ]]; then
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup"
    log_info "Backed up: $backup"
  fi
}

# Self-registering component system (bash 3.2 compatible)
# Use parallel arrays instead of associative arrays
INSTALL_CHECK_NAMES=()
INSTALL_CHECK_COMMANDS=()

register_check() {
  local name="$1"
  local check_command="$2"
  INSTALL_CHECK_NAMES+=("$name")
  INSTALL_CHECK_COMMANDS+=("$check_command")
}

# Installation summary iterates through registered checks
show_installation_summary() {
  echo ""
  log_info "====== Installation Summary ======"

  local i
  for i in "${!INSTALL_CHECK_NAMES[@]}"; do
    local name="${INSTALL_CHECK_NAMES[$i]}"
    local check_cmd="${INSTALL_CHECK_COMMANDS[$i]}"

    if eval "$check_cmd" &> /dev/null; then
      log_success "✓ $name"
    else
      log_warn "✗ $name"
    fi
  done

  echo ""
  log_info "Next steps:"
  log_info "  1. Reload your shell: source ~/.zshrc"
  log_info "  2. Customize configs: cd ~/development/toolbox"
}

# Helper to check if component should be installed
should_install() {
  local flag_name="$1"
  local component_name="$2"
  local flag_value="${!flag_name}"

  # If --all flag is set, install everything
  if [[ "$INSTALL_ALL" == true ]]; then
    return 0
  fi

  # If specific flag is set, install
  if [[ "$flag_value" == true ]]; then
    return 0
  fi

  # If interactive mode, prompt user
  if [[ "$INTERACTIVE" == true ]]; then
    if prompt_yes_no "Install $component_name?" "y"; then
      return 0
    else
      log_info "Skipping $component_name"
      return 1
    fi
  fi

  # Default: skip
  return 1
}
