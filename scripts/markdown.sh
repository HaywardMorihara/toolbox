#!/usr/bin/env bash
# scripts/markdown.sh - View Markdown files in the browser
# Converts Markdown to HTML with embedded images and Mermaid diagram support
#
# Usage: ./scripts/markdown.sh [OPTIONS] <file.md>
# Options:
#   --keep, -k    Keep the generated HTML file instead of auto-deleting

set -euo pipefail

keep_file=false
markdown_file=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  if [[ "$1" == "--keep" ]] || [[ "$1" == "-k" ]]; then
    keep_file=true
    shift
  elif [[ "$1" == -* ]]; then
    echo "Error: Unknown option: $1" >&2
    exit 1
  else
    markdown_file="$1"
    shift
  fi
done

if [[ -z "$markdown_file" ]]; then
  echo "Usage: markdown.sh [--keep|-k] <file.md>" >&2
  exit 1
fi

# Resolve to absolute path
markdown_file="$(cd "$(dirname "$markdown_file")" && pwd)/$(basename "$markdown_file")"

if [[ ! -f "$markdown_file" ]]; then
  echo "Error: File not found: $markdown_file" >&2
  exit 1
fi

if ! command -v pandoc &> /dev/null; then
  echo "Error: pandoc is not installed" >&2
  exit 1
fi

# Create temp HTML file
temp_html=$(mktemp /tmp/markdown-XXXXXX.html)

# Convert to HTML with embedded resources
pandoc "$markdown_file" -s --embed-resources -t html -o "$temp_html" \
  --resource-path="$(dirname "$markdown_file")" 2>/dev/null || {
  # Fallback for older pandoc versions
  pandoc "$markdown_file" -s --self-contained -t html -o "$temp_html" \
    --resource-path="$(dirname "$markdown_file")" 2>/dev/null || {
    echo "Error: Failed to convert markdown to HTML" >&2
    rm -f "$temp_html"
    exit 1
  }
}

# Inject Mermaid.js using sed
mermaid_script='<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"><\/script><script>mermaid.initialize({startOnLoad: true});mermaid.contentLoaded();<\/script>'
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s|</body>|$mermaid_script</body>|" "$temp_html"
else
  sed -i "s|</body>|$mermaid_script</body>|" "$temp_html"
fi

# Open in browser
if [[ "$OSTYPE" == "darwin"* ]]; then
  open "$temp_html"
elif command -v xdg-open &> /dev/null; then
  xdg-open "$temp_html"
else
  echo "Error: Cannot determine how to open browser" >&2
  rm -f "$temp_html"
  exit 1
fi

# Handle cleanup
if [[ "$keep_file" == true ]]; then
  echo "HTML file saved to: $temp_html"
else
  (sleep 3 && rm -f "$temp_html") &
  disown
fi
