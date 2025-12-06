#!/usr/bin/env bash
# deps/neovim.sh - Neovim installation

install_neovim() {
  install_with_brew "INSTALL_NEOVIM" "Neovim" "command -v nvim" "neovim"
}

# Register check for installation summary
register_check "Neovim" "command -v nvim"
