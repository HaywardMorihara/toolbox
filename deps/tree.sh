#!/usr/bin/env bash
# deps/tree.sh - tree command installation

install_tree() {
  install_with_brew "INSTALL_TREE" "tree" "command -v tree" "tree"
}

# Register check for installation summary
register_check "tree" "command -v tree"
