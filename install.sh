#!/usr/bin/env bash
set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

# Validate repository structure exists
if [[ ! -d "$REPO_ROOT/lib" ]]; then
  echo "ERROR: Repository structure invalid. Missing lib directory at: $REPO_ROOT/lib" >&2
  exit 1
fi

if [[ ! -d "$REPO_ROOT/deps" ]]; then
  echo "ERROR: Repository structure invalid. Missing deps directory at: $REPO_ROOT/deps" >&2
  exit 1
fi

# Source all library functions automatically
for script in "$SCRIPT_DIR"/lib/*.sh; do
  if [[ ! -r "$script" ]]; then
    echo "ERROR: Cannot read library script: $script" >&2
    exit 1
  fi
  source "$script"
done

# Source Mac-specific library functions
if [[ -d "$SCRIPT_DIR/lib/mac" ]]; then
  for script in "$SCRIPT_DIR"/lib/mac/*.sh; do
    if [[ ! -r "$script" ]]; then
      echo "ERROR: Cannot read library script: $script" >&2
      exit 1
    fi
    source "$script"
  done
fi

# Source all dependency scripts automatically
for script in "$SCRIPT_DIR"/deps/*.sh; do
  if [[ ! -r "$script" ]]; then
    echo "ERROR: Cannot read dependency script: $script" >&2
    exit 1
  fi
  source "$script"
done

# Flag parsing
INSTALL_ALL=false
INSTALL_CONFIG=false
INSTALL_BREW=false
INSTALL_STOW=false
INSTALL_TREE=false
INSTALL_CLAUDE=false
INSTALL_NEOVIM=false
INSTALL_OPENCODE=false
INSTALL_GH=false
INSTALL_FONTS=false
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
  --config       Create config directories (~/.config/toolbox)
  --brew         Install Homebrew
  --stow         Install GNU Stow
  --tree         Install tree command
  --claude       Install Claude CLI
  --neovim       Install Neovim
  --opencode     Install OpenCode CLI
  --gh           Install GitHub CLI
  --fonts        Install Hack Nerd Font
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
      --config)
        INSTALL_CONFIG=true
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
      --fonts)
        INSTALL_FONTS=true
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

  export INSTALL_ALL INSTALL_CONFIG INSTALL_BREW INSTALL_STOW INSTALL_TREE INSTALL_CLAUDE INSTALL_NEOVIM INSTALL_OPENCODE INSTALL_GH INSTALL_FONTS INSTALL_DOTFILES INSTALL_ZSHRC INSTALL_UPDATE INTERACTIVE
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

  # Validate basic requirements
  log_info "Validating environment..."

  # Check REPO_ROOT is set and exists
  if ! validate_var_set "REPO_ROOT"; then
    exit 1
  fi

  if ! validate_dir_exists "$REPO_ROOT" "Repository root"; then
    exit 1
  fi

  # Check HOME directory exists and is writable
  if ! validate_dir_exists "$HOME" "Home directory"; then
    exit 1
  fi

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

  # 1. Setup config directories (needed by tools like cwd)
  setup_config_dirs || log_warn "Failed to setup config directories"

  # 2. Install Homebrew (macOS package manager, prerequisite for other tools)
  install_brew || {
    log_error "Homebrew installation failed. Cannot proceed."
    exit 1
  }

  # 3. Install GNU Stow (required for dotfiles)
  install_stow || {
    log_error "GNU Stow installation failed. Cannot proceed."
    exit 1
  }

  # 4. Install tree command
  install_tree || log_warn "Failed to install tree"

  # 5. Install Claude CLI
  install_claude || log_warn "Failed to install Claude CLI"

  # 6. Install Neovim
  install_neovim || log_warn "Failed to install Neovim"

  # 7. Install OpenCode CLI
  install_opencode || log_warn "Failed to install OpenCode"

  # 8. Install GitHub CLI
  install_gh || log_warn "Failed to install GitHub CLI"

  # 9. Install Hack Nerd Font
  install_fonts || log_warn "Failed to install fonts"

  # 10. Stow dotfiles (creates ~/.zshrc.toolbox symlink)
  stow_dotfiles "$REPO_ROOT" || log_warn "Failed to stow dotfiles"

  # 11. Modify ~/.zshrc (source ~/.zshrc.toolbox)
  setup_zshrc_integration || log_warn "Failed to setup .zshrc integration"

  # Summary
  show_installation_summary

  log_info "====== Installation Complete ======"
}

main
