#!/usr/bin/env bash
# lib/dotfiles.sh - GNU Stow operations

stow_dotfiles() {
  local repo_root="$1"

  # Check if stow is available
  if ! command -v stow &> /dev/null; then
    log_error "stow command not found. Install GNU Stow first."
    return 1
  fi

  # Check if should install
  if ! should_install "INSTALL_DOTFILES" "dotfiles"; then
    return 1
  fi

  log_info "Stowing dotfiles..."

  cd "$repo_root" || return 1

  # Stow zsh package (using dotfiles/ directory)
  stow -d dotfiles -t ~ zsh || {
    log_error "Failed to stow zsh dotfiles"
    log_info "If conflicts exist, backup and remove: ~/.zshrc.toolbox"
    return 1
  }

  log_success "Dotfiles stowed: ~/.zshrc.toolbox is now symlinked"
  return 0
}

# Register check for installation summary
register_check "~/.zshrc.toolbox (symlinked)" "[[ -L \$HOME/.zshrc.toolbox ]]"
