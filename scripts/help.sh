#!/usr/bin/env bash

# Get script directory to find cheatsheets relative to repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CHEATSHEET_DIR="$REPO_ROOT/cheatsheets"

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
