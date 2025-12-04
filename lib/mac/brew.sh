#!/usr/bin/env bash
# lib/mac/brew.sh - Homebrew installation (macOS-specific)

install_brew() {
  local component_name="Homebrew"

  # Check if already installed
  if command -v brew &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_BREW" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
    log_error "Failed to install $component_name"
    return 1
  }

  # Add Homebrew to PATH for current session (macOS Apple Silicon)
  if [[ "$OS" == "Darwin" ]] && [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  log_success "$component_name installed successfully"
  return 0
}

# Register check for installation summary
register_check "Homebrew" "command -v brew"
