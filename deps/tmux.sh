#!/usr/bin/env bash
# deps/tmux.sh - tmux terminal multiplexer installation

install_tmux() {
  install_with_brew "INSTALL_TMUX" "tmux" "command -v tmux" "tmux"
}

register_check "tmux" "command -v tmux"
