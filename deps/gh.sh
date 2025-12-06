#!/usr/bin/env bash
# deps/gh.sh - GitHub CLI installation

install_gh() {
  install_with_brew "INSTALL_GH" "GitHub CLI" "command -v gh" "gh"
}

# Register check for installation summary
register_check "GitHub CLI" "command -v gh"
