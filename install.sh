#!/usr/bin/env bash
set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

# Source all library functions automatically
for script in "$SCRIPT_DIR"/lib/*.sh; do
  source "$script"
done

# Source Mac-specific library functions
for script in "$SCRIPT_DIR"/lib/mac/*.sh; do
  source "$script"
done

# Source all dependency scripts automatically
for script in "$SCRIPT_DIR"/deps/*.sh; do
  source "$script"
done

# Flag parsing
INSTALL_ALL=false
INSTALL_BREW=false
INSTALL_STOW=false
INSTALL_TREE=false
INSTALL_CLAUDE=false
INSTALL_NEOVIM=false
INSTALL_OPENCODE=false
INSTALL_GH=false
INSTALL_DOTFILES=false
INSTALL_ZSHRC=false
INSTALL_UPDATE=false
INTERACTIVE=true

show_help() {
  cat << EOF
Usage: ./install.sh [OPTIONS]

Toolbox Installation Script - Install development dependencies and configurations

OPTIONS:
  --all          Install all components non-interactively
  --brew         Install Homebrew
  --stow         Install GNU Stow
  --tree         Install tree command
  --claude       Install Claude CLI
  --neovim       Install Neovim
  --opencode     Install OpenCode CLI
  --gh           Install GitHub CLI
  --dotfiles     Stow dotfiles (symlink ~/.zshrc.toolbox)
  --zshrc        Modify ~/.zshrc to source toolbox config
  --update       Update toolbox repository (git pull)
  -h, --help     Show this help message

EXAMPLES:
  ./install.sh --all                    # Install everything
  ./install.sh                          # Interactive mode (prompts for each)
  ./install.sh --brew --stow --tree     # Install specific components

For more information, see: https://github.com/HaywardMorihara/toolbox
EOF
}

parse_flags() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --all)
        INSTALL_ALL=true
        INTERACTIVE=false
        ;;
      --brew)
        INSTALL_BREW=true
        ;;
      --stow)
        INSTALL_STOW=true
        ;;
      --tree)
        INSTALL_TREE=true
        ;;
      --claude)
        INSTALL_CLAUDE=true
        ;;
      --neovim)
        INSTALL_NEOVIM=true
        ;;
      --opencode)
        INSTALL_OPENCODE=true
        ;;
      --gh)
        INSTALL_GH=true
        ;;
      --dotfiles)
        INSTALL_DOTFILES=true
        ;;
      --zshrc)
        INSTALL_ZSHRC=true
        ;;
      --update)
        INSTALL_UPDATE=true
        ;;
      --help|-h)
        show_help
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
    shift
  done

  export INSTALL_ALL INSTALL_BREW INSTALL_STOW INSTALL_TREE INSTALL_CLAUDE INSTALL_NEOVIM INSTALL_OPENCODE INSTALL_GH INSTALL_DOTFILES INSTALL_ZSHRC INSTALL_UPDATE INTERACTIVE
}

# Parse flags
parse_flags "$@"

# Detect OS
detect_os

# Warn if not macOS (primary platform)
if [[ "$OS" != "Darwin" ]]; then
  log_warn "Primary platform is macOS. Linux support is experimental."
  if [[ "$INTERACTIVE" == true ]] && ! prompt_yes_no "Continue anyway?"; then
    exit 0
  fi
fi

# Installation sequence (dependency order)
main() {
  log_info "====== Toolbox Installation Starting ======"

  # Pull latest changes if --update flag is set
  if [[ "$INSTALL_UPDATE" == true ]]; then
    log_info "Pulling latest changes from remote..."
    cd "$REPO_ROOT" || exit 1
    if ! git pull; then
      log_error "Failed to pull latest changes"
      exit 1
    fi
    log_success "Repository updated"
  fi

  # 1. Install Homebrew (macOS package manager, prerequisite for other tools)
  install_brew || {
    log_error "Homebrew installation failed. Cannot proceed."
    exit 1
  }

  # 2. Install GNU Stow (required for dotfiles)
  install_stow || {
    log_error "GNU Stow installation failed. Cannot proceed."
    exit 1
  }

  # 3. Install tree command
  install_tree || log_warn "Failed to install tree"

  # 4. Install Claude CLI
  install_claude || log_warn "Failed to install Claude CLI"

   # 5. Install Neovim
   install_neovim || log_warn "Failed to install Neovim"

   # 6. Install OpenCode CLI
   install_opencode || log_warn "Failed to install OpenCode"

   # 7. Install GitHub CLI
   install_gh || log_warn "Failed to install GitHub CLI"

   # 8. Stow dotfiles (creates ~/.zshrc.toolbox symlink)
   stow_dotfiles "$REPO_ROOT" || log_warn "Failed to stow dotfiles"

   # 9. Modify ~/.zshrc (source ~/.zshrc.toolbox)
   setup_zshrc_integration || log_warn "Failed to setup .zshrc integration"

  # Summary
  show_installation_summary

  log_info "====== Installation Complete ======"
}

main
