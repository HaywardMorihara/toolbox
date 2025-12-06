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

# Input validation helpers
# =======================

# Validate that a file exists and is readable
validate_file_exists() {
  local file_path="$1"
  local file_description="${2:-file}"

  if [[ ! -f "$file_path" ]]; then
    log_error "Failed: $file_description not found at: $file_path"
    return 1
  fi

  if [[ ! -r "$file_path" ]]; then
    log_error "Failed: Cannot read $file_description (permission denied): $file_path"
    return 1
  fi

  return 0
}

# Validate that a directory exists
validate_dir_exists() {
  local dir_path="$1"
  local dir_description="${2:-directory}"

  if [[ ! -d "$dir_path" ]]; then
    log_error "Failed: $dir_description not found at: $dir_path"
    return 1
  fi

  return 0
}

# Validate that a directory is writable
validate_dir_writable() {
  local dir_path="$1"
  local dir_description="${2:-directory}"

  if [[ ! -d "$dir_path" ]]; then
    log_error "Failed: $dir_description not found at: $dir_path"
    return 1
  fi

  if [[ ! -w "$dir_path" ]]; then
    log_error "Failed: Cannot write to $dir_description (permission denied): $dir_path"
    log_error "Suggestion: Check directory ownership or permissions"
    return 1
  fi

  return 0
}

# Validate required environment variable is set
validate_var_set() {
  local var_name="$1"
  local var_value="${!var_name:-}"

  if [[ -z "$var_value" ]]; then
    log_error "Failed: Required environment variable not set: \$$var_name"
    return 1
  fi

  return 0
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
  log_info "  2. Customize configs: cd $REPO_ROOT"
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

# Generic installer helper for standard package installations
# Reduces boilerplate across deps/*.sh files
#
# Usage: install_with_brew "FLAG_NAME" "Component Name" "check_command" "package_name"
#
# Parameters:
#   $1: FLAG_NAME - Environment variable name (e.g., INSTALL_TREE)
#   $2: Component Name - Human-readable name for logging
#   $3: check_command - Command to check if already installed (e.g., "command -v tree")
#   $4: package_name - Package name for package manager
#
# This function:
#   1. Checks if already installed (using check_command)
#   2. Respects installation flags via should_install()
#   3. Installs via OS-specific package manager (brew, apt, yum)
#   4. Logs success or failure
#   5. Returns 0 on success, 1 on skip or failure
#
# Example:
#   install_tree() {
#     install_with_brew "INSTALL_TREE" "tree" "command -v tree" "tree"
#   }
install_with_brew() {
  local flag_name="$1"
  local component_name="$2"
  local check_cmd="$3"
  local package_name="$4"

  # Check if already installed
  if eval "$check_cmd" &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if should install (respects --all, specific flags, and interactive mode)
  if ! should_install "$flag_name" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Install based on OS
  case "$OS" in
    Darwin)
      brew install "$package_name" || {
        log_error "Failed to install $component_name"
        return 1
      }
      ;;
    Linux)
      if command -v apt-get &> /dev/null; then
        sudo apt-get install -y "$package_name" || {
          log_error "Failed to install $component_name"
          return 1
        }
      elif command -v yum &> /dev/null; then
        sudo yum install -y "$package_name" || {
          log_error "Failed to install $component_name"
          return 1
        }
      else
        log_error "No supported package manager found (apt-get or yum required)"
        return 1
      fi
      ;;
    *)
      log_error "Unsupported OS: $OS"
      return 1
      ;;
  esac

  log_success "$component_name installed successfully"
  return 0
}
