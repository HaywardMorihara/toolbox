#!/usr/bin/env bash
# deps/neovim.sh - Neovim installation

install_neovim() {
  local component_name="Neovim"

  # Check if already installed
  if command -v nvim &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_NEOVIM" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Install based on OS
  case "$OS" in
    Darwin)
      brew install neovim || {
        log_error "Failed to install $component_name"
        return 1
      }
      ;;
    Linux)
      if command -v apt-get &> /dev/null; then
        sudo apt-get install -y neovim || {
          log_error "Failed to install $component_name"
          return 1
        }
      elif command -v yum &> /dev/null; then
        sudo yum install -y neovim || {
          log_error "Failed to install $component_name"
          return 1
        }
      fi
      ;;
  esac

  log_success "$component_name installed successfully"
  return 0
}

# Register check for installation summary
register_check "Neovim" "command -v nvim"
