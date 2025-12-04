#!/usr/bin/env bash
# deps/opencode.sh - OpenCode CLI installation

install_opencode() {
  local component_name="OpenCode CLI"

  # Check if already installed (idempotency)
  if command -v opencode &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if user wants to install (respects flags and interactive mode)
  if ! should_install "INSTALL_OPENCODE" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Install via Homebrew
  brew install opencode || {
    log_error "Failed to install $component_name via Homebrew"
    return 1
  }

  log_success "$component_name installed successfully"
  return 0
}

# Self-register for installation summary
register_check "OpenCode CLI" "command -v opencode"
