#!/usr/bin/env bash
# scripts/markdown-strip-images.sh - Remove image reference definitions from Markdown
# Strips all [imageX]: URLs and similar reference-style image definitions from the bottom of files
#
# Usage: ./scripts/markdown-strip-images.sh <file.md>

set -eu

markdown_file=""

# Parse arguments
if [[ $# -eq 0 ]]; then
  echo "Usage: markdown-strip-images.sh <file.md>" >&2
  exit 1
fi

markdown_file="$1"

# Resolve to absolute path
dir=$(dirname -- "$markdown_file")
file=$(basename -- "$markdown_file")
markdown_file="$(cd "$dir" && pwd)/$file"

if [[ ! -f "$markdown_file" ]]; then
  echo "Error: File not found: $markdown_file" >&2
  exit 1
fi

# Find the line number where image references start
# Pattern: [imageX]: URL or similar image reference definitions
# Typically these appear at the end of the file
line_num=$(awk '/^\[image[0-9]+\]:/ { print NR; exit }' "$markdown_file")

if [[ -z "$line_num" ]]; then
  echo "No image references found in $markdown_file"
  exit 0
fi

# Keep everything up to (but not including) the first image reference line
# Use temp file in /tmp to avoid permission issues
temp_file="/tmp/mdstrip.$$"
head -n $((line_num - 1)) "$markdown_file" > "$temp_file"
cat "$temp_file" > "$markdown_file"
rm -f "$temp_file"

echo "Stripped image references starting from line $line_num"
echo "Updated: $markdown_file"
