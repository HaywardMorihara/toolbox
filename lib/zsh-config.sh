#!/usr/bin/env bash
# lib/zsh-config.sh - ~/.zshrc modification handler

setup_zshrc_integration() {
  local zshrc="$HOME/.zshrc"
  local toolbox_config="$HOME/.zshrc.toolbox"
  local source_line="source ~/.zshrc.toolbox"

  # Check if toolbox config exists (should be symlinked by stow)
  if [[ ! -f "$toolbox_config" ]]; then
    log_warn "~/.zshrc.toolbox not found. Did dotfiles stow successfully?"
    return 1
  fi

  # Create ~/.zshrc if it doesn't exist
  if [[ ! -f "$zshrc" ]]; then
    log_info "Creating new ~/.zshrc"
    touch "$zshrc"
  fi

  # Check if already integrated (idempotency)
  if grep -Fq "$source_line" "$zshrc"; then
    log_success "~/.zshrc already sources toolbox config"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_ZSHRC" ".zshrc integration"; then
    log_warn "To use toolbox config, manually add: $source_line"
    return 1
  fi

  # Backup existing .zshrc
  backup_file "$zshrc"

  # Append source line
  log_info "Adding toolbox integration to ~/.zshrc"
  cat >> "$zshrc" << 'EOF'

# Toolbox: Load custom development configurations
# Managed by: https://github.com/HaywardMorihara/toolbox
source ~/.zshrc.toolbox
EOF

  log_success "~/.zshrc updated successfully"
  log_info "Reload your shell: source ~/.zshrc"
  return 0
}

# Register check for installation summary
register_check "~/.zshrc sources toolbox" "grep -Fq 'source ~/.zshrc.toolbox' \$HOME/.zshrc"
