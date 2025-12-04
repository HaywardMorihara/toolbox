#!/usr/bin/env bash

CHEATSHEET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/toolbox/cheatsheets"

if [[ $# -eq 0 ]]; then
  cat "$CHEATSHEET_DIR/bash.md"
  exit 0
fi

if [[ -f "$CHEATSHEET_DIR/$1.md" ]]; then
  cat "$CHEATSHEET_DIR/$1.md"
else
  echo "Cheatsheet '$1' not found."
  echo "Available cheatsheets:"
  for f in "$CHEATSHEET_DIR"/*.md; do
    fname=$(basename "$f" .md)
    echo "  $fname"
  done
  exit 1
fi
