#!/usr/bin/env bash
# deps/stow.sh - GNU Stow installation

install_stow() {
  install_with_brew "INSTALL_STOW" "GNU Stow" "command -v stow" "stow"
}

# Register check for installation summary
register_check "GNU Stow" "command -v stow"
