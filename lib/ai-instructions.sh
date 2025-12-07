#!/usr/bin/env bash

setup_ai_instructions() {
  local component_name="AI Instructions"

  if [[ ! -f "$REPO_ROOT/config/ai-instructions.md" ]]; then
    log_error "AI instructions file not found at $REPO_ROOT/config/ai-instructions.md"
    return 1
  fi

  if ! should_install "INSTALL_AI_INSTRUCTIONS" "$component_name"; then
    return 1
  fi

  log_info "Setting up $component_name..."

  local source_file="$REPO_ROOT/config/ai-instructions.md"
  local claude_dir="$HOME/.claude"
  local claude_link="$claude_dir/CLAUDE.md"
  local opencode_dir="$HOME/.config/opencode"
  local opencode_link="$opencode_dir/AGENTS.md"

  # Create directories if they don't exist
  if [[ ! -d "$claude_dir" ]]; then
    mkdir -p "$claude_dir" || {
      log_error "Failed to create directory: $claude_dir"
      return 1
    }
  fi

  if [[ ! -d "$opencode_dir" ]]; then
    mkdir -p "$opencode_dir" || {
      log_error "Failed to create directory: $opencode_dir"
      return 1
    }
  fi

  # Backup existing symlinks/files if they exist
  if [[ -e "$claude_link" ]]; then
    backup_file "$claude_link"
  fi

  if [[ -e "$opencode_link" ]]; then
    backup_file "$opencode_link"
  fi

  # Create symlinks
  ln -sf "$source_file" "$claude_link" || {
    log_error "Failed to create symlink: $claude_link"
    return 1
  }

  ln -sf "$source_file" "$opencode_link" || {
    log_error "Failed to create symlink: $opencode_link"
    return 1
  }

  log_success "$component_name configured successfully"
  return 0
}

register_check "Claude AI Instructions (~/.claude/CLAUDE.md)" "[[ -L $HOME/.claude/CLAUDE.md ]]"
register_check "OpenCode AI Instructions (~/.config/opencode/AGENTS.md)" "[[ -L $HOME/.config/opencode/AGENTS.md ]]"
