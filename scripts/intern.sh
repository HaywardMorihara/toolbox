#!/usr/bin/env bash
# scripts/intern.sh - LLM provider router
# Routes calls to different LLM providers based on configuration
#
# Usage: intern [ARGS...]
#
# Configuration: ~/.config/toolbox/llm.conf
#
# Supported providers:
#   - claude (default)
#   - opencode

set -euo pipefail

# Default LLM provider
readonly DEFAULT_PROVIDER="claude"

# Get the provider from config file
get_llm_provider() {
  # Try config file
  local config_file="${XDG_CONFIG_HOME:-$HOME/.config}/toolbox/llm.conf"
  if [[ -f "$config_file" ]]; then
    # Extract LLM value from config file (handles comments and whitespace)
    grep -E "^LLM\s*=" "$config_file" | head -n1 | cut -d'=' -f2 | xargs || echo "$DEFAULT_PROVIDER"
    return 0
  fi

  # Default fallback
  echo "$DEFAULT_PROVIDER"
}

# Route to the appropriate provider
route_to_provider() {
  local provider="$1"
  shift || true

  case "$provider" in
    claude)
      if command -v claude &> /dev/null; then
        claude "$@"
      else
        echo "Error: 'claude' command not found. Install Claude CLI first." >&2
        return 1
      fi
      ;;
    opencode)
      if command -v opencode &> /dev/null; then
        opencode "$@"
      else
        echo "Error: 'opencode' command not found. Install OpenCode CLI first." >&2
        return 1
      fi
      ;;
    *)
      echo "Error: Unknown LLM provider: $provider" >&2
      echo "Supported providers: claude, opencode" >&2
      return 1
      ;;
  esac
}

# Main
main() {
  local provider
  provider=$(get_llm_provider)

  if [[ -z "$provider" ]]; then
    provider="$DEFAULT_PROVIDER"
  fi

  route_to_provider "$provider" "$@"
}

main "$@"
