#!/usr/bin/env bash
# deps/fonts.sh - Nerd fonts installation

install_fonts() {
  local component_name="Hack Nerd Font"

  # Check if already installed
  if brew list font-hack-nerd-font &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_FONTS" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Install based on OS
  case "$OS" in
    Darwin)
      brew install font-hack-nerd-font || {
        log_error "Failed to install $component_name"
        return 1
      }
      ;;
    Linux)
      log_warn "Font installation on Linux requires manual setup"
      return 1
      ;;
  esac

  log_success "$component_name installed successfully"
  return 0
}

# Register check for installation summary
register_check "Hack Nerd Font" "brew list font-hack-nerd-font"
