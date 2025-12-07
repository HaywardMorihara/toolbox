#!/usr/bin/env bash
# deps/pandoc.sh - Pandoc document converter installation

install_pandoc() {
  install_with_brew "INSTALL_PANDOC" "pandoc" "command -v pandoc" "pandoc"
}

# Register check for installation summary
register_check "pandoc" "command -v pandoc"
