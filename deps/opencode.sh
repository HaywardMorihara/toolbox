#!/usr/bin/env bash
# deps/opencode.sh - OpenCode CLI installation

install_opencode() {
  install_with_brew "INSTALL_OPENCODE" "OpenCode CLI" "command -v opencode" "opencode"
}

# Self-register for installation summary
register_check "OpenCode CLI" "command -v opencode"
