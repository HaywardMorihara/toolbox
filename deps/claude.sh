#!/usr/bin/env bash
# deps/claude.sh - Claude CLI installation

install_claude() {
  local component_name="Claude CLI"

  # Check if already installed
  if command -v claude &> /dev/null; then
    local version=$(claude --version 2>&1 | head -n1)
    log_success "$component_name is already installed: $version"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_CLAUDE" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Try Homebrew if available
  if command -v brew &> /dev/null; then
    if brew install --cask claude-code 2>/dev/null; then
      log_success "$component_name installed via Homebrew"
      return 0
    fi
  fi

  log_warn "$component_name not installed. Install via Homebrew: brew install --cask claude-code"
  return 1
}

# Register check for installation summary
register_check "Claude CLI" "command -v claude"
