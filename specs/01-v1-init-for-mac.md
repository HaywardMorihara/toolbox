# Development Toolbox Implementation Plan

## Overview

Create a development toolbox repository that installs dependencies, configurations, and scripts via:
```bash
git clone https://github.com/HaywardMorihara/toolbox ~/development/toolbox
cd ~/development/toolbox
./install.sh --all
```

**V1 Scope:**
- Install GNU Stow and tree via Homebrew
- Install Claude CLI (if not already installed)
- Add ~/.zshrc customizations via sourced ~/.zshrc.toolbox
- Fully idempotent and cross-platform ready (macOS primary)

**Architecture:**
- **Homebrew:** Package management for CLI tools
- **GNU Stow:** Simple dotfile symlink management
- **Modular bash scripts:** Flexible, maintainable installation flow
- **Self-registering components:** Each module manages its own installation check

---

## 1. Directory Structure

```
/Users/nathaniel.morihara/development/toolbox/
├── install.sh                    # Main installation orchestrator
├── README.md                     # Usage documentation
├── FEATURES.md                   # Future features roadmap
│
├── specs/                        # Specifications and plans
│   └── 01-v1-init-for-mac.md     # This file - V1 implementation plan
│
├── lib/                          # Core installation utilities
│   ├── common.sh                 # Shared utilities (logging, prompts, checks)
│   ├── os-detection.sh           # Platform identification
│   ├── dotfiles.sh               # Stow operations for dotfiles
│   ├── zsh-config.sh             # ~/.zshrc modification handler
│   └── mac/                      # macOS-specific utilities
│       ├── brew.sh               # Homebrew installation (Mac-specific)
│       └── defaults.sh           # macOS system preferences (future)
│
├── deps/                         # Dependency installation scripts
│   ├── stow.sh                   # GNU Stow installation
│   ├── claude.sh                 # Claude CLI installation
│   └── tree.sh                   # tree command installation
│
├── dotfiles/                     # Dotfiles managed by GNU Stow
│   └── zsh/
│       └── .zshrc.toolbox        # Custom Zsh config (symlinked to ~)
│
├── scripts/                      # Utility scripts
│   └── help.sh                   # Help/info script (prints "hello world" for V1)
│
└── docs/
    └── EXTENDING.md              # Guide for adding tools/configs
```

**Key Design Decisions:**
- `lib/` contains core utilities and helpers
- `lib/mac/` isolates macOS-specific functionality (including Homebrew)
- `deps/` contains cross-platform package installation scripts
- `dotfiles/` follows GNU Stow conventions (uses `stow -d dotfiles`)
- `scripts/` for standalone utility scripts
- `specs/` for specifications and implementation plans
- Each module self-registers for installation summary via `register_check()`

**Dependency Installation Pattern (Explicit by Design):**
- **Decision**: Keep dependency installation explicit in `install.sh` rather than auto-detecting `deps/*.sh` files
- **Rationale**: Maintains clear installation order, easier to understand control flow, simpler for V1
- **Trade-off**: Requires 3 updates per new dependency (deps/*.sh file, flag in install.sh, function call)
- **Future**: Can be automated with a specialized agent or migration to auto-registration in V2

---

## 2. install.sh Architecture

**Location:** `/Users/nathaniel.morihara/development/toolbox/install.sh`

### Core Structure

```bash
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

  # 5. Stow dotfiles (creates ~/.zshrc.toolbox symlink)
  stow_dotfiles "$REPO_ROOT" || log_warn "Failed to stow dotfiles"

  # 6. Modify ~/.zshrc (source ~/.zshrc.toolbox)
  setup_zshrc_integration || log_warn "Failed to setup .zshrc integration"

  # Summary
  show_installation_summary

  log_info "====== Installation Complete ======"
}

main
```

### Flag Parsing

```bash
INSTALL_ALL=false
INSTALL_BREW=false
INSTALL_STOW=false
INSTALL_TREE=false
INSTALL_CLAUDE=false
INSTALL_DOTFILES=false
INSTALL_ZSHRC=false
INTERACTIVE=true

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
      --dotfiles)
        INSTALL_DOTFILES=true
        ;;
      --zshrc)
        INSTALL_ZSHRC=true
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

  export INSTALL_ALL INSTALL_BREW INSTALL_STOW INSTALL_TREE INSTALL_CLAUDE INSTALL_DOTFILES INSTALL_ZSHRC INTERACTIVE
}
```

**Note:** Individual component flags allow cherry-picking what to install. If no flags are provided and not `--all`, interactive mode prompts for each component.

---

## 3. Installation Sequence & Dependencies

### Dependency Graph

```
1. Homebrew (package manager)
   ↓
   ├──> GNU Stow ───┐
   ├──> tree        │
   └──> Claude CLI  │
                    ↓
         Stow dotfiles (creates ~/.zshrc.toolbox symlink)
                    ↓
         Modify ~/.zshrc (append source line)
```

### Detailed Installation Steps

**Step 1: Install Homebrew**
- Check: `command -v brew`
- Install via: Official Homebrew installation script
- macOS: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Linux: Same script (experimental support)
- Idempotent: Skip if already installed

**Step 2: Install GNU Stow**
- Check: `command -v stow`
- macOS: `brew install stow`
- Linux: `sudo apt-get install stow` or `sudo yum install stow`
- Idempotent: Skip if already installed

**Step 3: Install tree**
- Check: `command -v tree`
- macOS: `brew install tree`
- Linux: `sudo apt-get install tree`
- Idempotent: Skip if already installed

**Step 4: Install Claude CLI**
- Check: `command -v claude`
- Install: Check `~/.local/bin/claude` first (already installed)
- Fallback: Download from GitHub releases or install via Homebrew if available
- Idempotent: Skip if already installed

**Step 5: Stow dotfiles**
- Check: `command -v stow` (should be available after Step 2)
- Run: `stow -d "$REPO_ROOT/dotfiles" -t ~ zsh`
- Creates: `~/.zshrc.toolbox -> /Users/nathaniel.morihara/development/toolbox/dotfiles/zsh/.zshrc.toolbox`
- Idempotent: Stow won't recreate existing symlinks

**Step 6: Modify ~/.zshrc**
- Check if `source ~/.zshrc.toolbox` already present
- If not, append with comment block
- Create `~/.zshrc` if doesn't exist
- Idempotent: Uses grep to check before appending

---

## 4. Key Implementation Files

### lib/common.sh - Self-Registering Component System

**Essential utility functions with component registration:**

```bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

# User interaction
prompt_yes_no() {
  local prompt="$1"
  local default="${2:-n}"  # Default to 'n'

  local prompt_suffix
  if [[ "$default" == "y" ]]; then
    prompt_suffix="[Y/n]"
  else
    prompt_suffix="[y/N]"
  fi

  while true; do
    read -p "$prompt $prompt_suffix: " response
    response=${response:-$default}

    case "$response" in
      [Yy]*)
        return 0
        ;;
      [Nn]*)
        return 1
        ;;
      *)
        echo "Please answer yes or no."
        ;;
    esac
  done
}

backup_file() {
  local file="$1"

  if [[ -f "$file" ]]; then
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup"
    log_info "Backed up: $backup"
  fi
}

# Self-registering component system
declare -A INSTALL_CHECKS

register_check() {
  local name="$1"
  local check_command="$2"
  INSTALL_CHECKS["$name"]="$check_command"
}

# Installation summary iterates through registered checks
show_installation_summary() {
  echo ""
  log_info "====== Installation Summary ======"

  for name in "${!INSTALL_CHECKS[@]}"; do
    local check_cmd="${INSTALL_CHECKS[$name]}"

    if eval "$check_cmd" &> /dev/null; then
      log_success "✓ $name"
    else
      log_warn "✗ $name"
    fi
  done

  echo ""
  log_info "Next steps:"
  log_info "  1. Reload your shell: source ~/.zshrc"
  log_info "  2. Customize configs: cd ~/development/toolbox"
}

# Helper to check if component should be installed
should_install() {
  local flag_name="$1"
  local component_name="$2"
  local flag_value="${!flag_name}"

  # If --all flag is set, install everything
  if [[ "$INSTALL_ALL" == true ]]; then
    return 0
  fi

  # If specific flag is set, install
  if [[ "$flag_value" == true ]]; then
    return 0
  fi

  # If interactive mode, prompt user
  if [[ "$INTERACTIVE" == true ]]; then
    if prompt_yes_no "Install $component_name?" "y"; then
      return 0
    else
      log_info "Skipping $component_name"
      return 1
    fi
  fi

  # Default: skip
  return 1
}
```

### lib/mac/brew.sh

```bash
# lib/mac/brew.sh - Homebrew installation (macOS-specific)

install_brew() {
  local component_name="Homebrew"

  # Check if already installed
  if command -v brew &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_BREW" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
    log_error "Failed to install $component_name"
    return 1
  }

  # Add Homebrew to PATH for current session (macOS Apple Silicon)
  if [[ "$OS" == "Darwin" ]] && [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  log_success "$component_name installed successfully"
  return 0
}

# Register check for installation summary
register_check "Homebrew" "command -v brew"
```

### deps/stow.sh

```bash
# deps/stow.sh - GNU Stow installation

install_stow() {
  local component_name="GNU Stow"

  # Check if already installed
  if command -v stow &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_STOW" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Install based on OS
  case "$OS" in
    Darwin)
      brew install stow || {
        log_error "Failed to install $component_name"
        return 1
      }
      ;;
    Linux)
      if command -v apt-get &> /dev/null; then
        sudo apt-get install -y stow || {
          log_error "Failed to install $component_name"
          return 1
        }
      elif command -v yum &> /dev/null; then
        sudo yum install -y stow || {
          log_error "Failed to install $component_name"
          return 1
        }
      fi
      ;;
  esac

  log_success "$component_name installed successfully"
  return 0
}

# Register check for installation summary
register_check "GNU Stow" "command -v stow"
```

### deps/tree.sh

```bash
# deps/tree.sh - tree command installation

install_tree() {
  local component_name="tree"

  # Check if already installed
  if command -v tree &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_TREE" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Install based on OS
  case "$OS" in
    Darwin)
      brew install tree || {
        log_error "Failed to install $component_name"
        return 1
      }
      ;;
    Linux)
      if command -v apt-get &> /dev/null; then
        sudo apt-get install -y tree || {
          log_error "Failed to install $component_name"
          return 1
        }
      elif command -v yum &> /dev/null; then
        sudo yum install -y tree || {
          log_error "Failed to install $component_name"
          return 1
        }
      fi
      ;;
  esac

  log_success "$component_name installed successfully"
  return 0
}

# Register check for installation summary
register_check "tree" "command -v tree"
```

### deps/claude.sh

```bash
# deps/claude.sh - Claude CLI installation

install_claude() {
  local component_name="Claude CLI"

  # Check if already installed
  if command -v claude &> /dev/null; then
    local version=$(claude --version 2>&1 | head -n1)
    log_success "$component_name is already installed: $version"
    return 0
  fi

  # Check if should install
  if ! should_install "INSTALL_CLAUDE" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Claude is already at ~/.local/bin/claude for this user
  # For general case, check if it's in the expected location
  if [[ -f "$HOME/.local/bin/claude" ]]; then
    log_success "$component_name found at ~/.local/bin/claude"

    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
      log_warn "Add $HOME/.local/bin to your PATH"
    fi

    return 0
  fi

  # Try Homebrew if available
  if command -v brew &> /dev/null; then
    if brew install --cask claude 2>/dev/null; then
      log_success "$component_name installed via Homebrew"
      return 0
    fi
  fi

  log_warn "$component_name not installed. Install manually from https://claude.ai/download"
  return 1
}

# Register check for installation summary
register_check "Claude CLI" "command -v claude"
```

### lib/dotfiles.sh

```bash
# lib/dotfiles.sh - GNU Stow operations

stow_dotfiles() {
  local repo_root="$1"

  # Check if stow is available
  if ! command -v stow &> /dev/null; then
    log_error "stow command not found. Install GNU Stow first."
    return 1
  fi

  # Check if should install
  if ! should_install "INSTALL_DOTFILES" "dotfiles"; then
    return 1
  fi

  log_info "Stowing dotfiles..."

  cd "$repo_root" || return 1

  # Stow zsh package (using dotfiles/ directory)
  stow -d dotfiles -t ~ zsh || {
    log_error "Failed to stow zsh dotfiles"
    log_info "If conflicts exist, backup and remove: ~/.zshrc.toolbox"
    return 1
  }

  log_success "Dotfiles stowed: ~/.zshrc.toolbox is now symlinked"
  return 0
}

# Register check for installation summary
register_check "~/.zshrc.toolbox (symlinked)" "[[ -L \$HOME/.zshrc.toolbox ]]"
```

### lib/zsh-config.sh

```bash
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
```

---

## 5. dotfiles/zsh/.zshrc.toolbox Content

**Location:** `/Users/nathaniel.morihara/development/toolbox/dotfiles/zsh/.zshrc.toolbox`

```bash
# ~/.zshrc.toolbox
# Managed by: https://github.com/HaywardMorihara/toolbox
# This file is symlinked from the toolbox repo and sourced by ~/.zshrc

# ===== Path Configuration =====
# Ensure local binaries are in PATH
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (if installed)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ===== Aliases =====
alias ls='ls -G'          # Colorized ls (macOS)
alias ll='ls -lah'        # Long listing
alias tree='tree -C'      # Colorized tree

# Git shortcuts
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'

# Homebrew shortcuts
alias brewup='brew update && brew upgrade && brew cleanup'
alias brewlist='brew list'

# ===== Custom Functions =====

# Quick navigation to toolbox repo
toolbox() {
  cd "$HOME/development/toolbox" || return
}

# Refresh shell configuration
refresh() {
  source ~/.zshrc
  echo "Shell configuration reloaded!"
}

# Update toolbox repository
toolbox-update() {
  echo "Updating toolbox..."
  cd "$HOME/development/toolbox" || return
  git pull
  echo "Toolbox updated! Run './install.sh --all' to apply any new changes."
}

# List all installed Homebrew packages
brew-installed() {
  echo "Formulae:"
  brew list --formula
  echo ""
  echo "Casks:"
  brew list --cask
}

# ===== Environment Variables =====
# Add tool-specific environment variables here

# Example: Set default editor
export EDITOR="vim"

# ===== Welcome Message (optional) =====
# Uncomment to show a message when opening new terminal
# echo "Toolbox loaded! Run 'toolbox' to navigate to repo."
```

---

## 6. Extending the Toolbox

### Adding New Homebrew Packages

**Step 1:** Create a new script in `deps/`

```bash
# deps/ripgrep.sh

install_ripgrep() {
  local component_name="ripgrep"

  if command -v rg &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  if ! should_install "INSTALL_RIPGREP" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  case "$OS" in
    Darwin)
      brew install ripgrep || {
        log_error "Failed to install $component_name"
        return 1
      }
      ;;
    Linux)
      # Add Linux installation
      ;;
  esac

  log_success "$component_name installed successfully"
  return 0
}

# Register check for installation summary
register_check "ripgrep" "command -v rg"
```

**Step 2:** Add flag to `install.sh`

```bash
INSTALL_RIPGREP=false

# In parse_flags():
--ripgrep)
  INSTALL_RIPGREP=true
  ;;
```

**Step 3:** Add to installation sequence in `install.sh`

```bash
# After other installations
install_ripgrep || log_warn "Failed to install ripgrep"
```

**Note:** The script will be automatically sourced by the `for` loop in `install.sh`. This pattern keeps extension simple while maintaining explicit control over installation order.

### Adding scripts/help.sh (Example)

**Location:** `/Users/nathaniel.morihara/development/toolbox/scripts/help.sh`

```bash
#!/usr/bin/env bash
# scripts/help.sh - V1 placeholder

echo "Hello world from toolbox scripts!"
echo "Future: This will show help information"
```

Make it executable:
```bash
chmod +x scripts/help.sh
```

### Adding New Dotfile Configurations

**Step 1:** Create dotfile structure in `dotfiles/`

```bash
mkdir -p dotfiles/git
echo "[user]" > dotfiles/git/.gitconfig.toolbox
echo "  name = Hayward Morihara" >> dotfiles/git/.gitconfig.toolbox
```

**Step 2:** Add stow operation in `lib/dotfiles.sh`

```bash
stow_git_config() {
  log_info "Stowing git configuration..."
  cd "$REPO_ROOT" || return 1
  stow -d dotfiles -t ~ git
  log_success "Git config symlinked"
}
```

**Step 3:** Call in `install.sh` and register check

```bash
stow_git_config || log_warn "Failed to stow git config"
register_check "~/.gitconfig.toolbox (symlinked)" "[[ -L \$HOME/.gitconfig.toolbox ]]"
```

### docs/EXTENDING.md Content

**Location:** `/Users/nathaniel.morihara/development/toolbox/docs/EXTENDING.md`

This file should contain:
- Complete guide for adding new Homebrew packages
- Complete guide for adding new dotfile configurations
- Examples from section 6 above
- Explanation of the self-registering component system
- Tips for testing new components
- Common pitfalls and solutions
- Reference to the explicit dependency pattern decision

**Structure:**
```markdown
# Extending Toolbox

## Adding New Homebrew Packages

[Include example from section 6 above]

## Adding New Dotfile Configurations

[Include example from section 6 above]

## Self-Registering Components

[Explain register_check() system]

## Testing Your Extensions

[Testing checklist]

## Common Patterns

[Best practices]
```

---

## 7. README.md Content

**Location:** `/Users/nathaniel.morihara/development/toolbox/README.md`

```markdown
# Toolbox

My personal development toolbox - package management and configurations for macOS.

## Quick Start

```bash
git clone https://github.com/HaywardMorihara/toolbox ~/development/toolbox
cd ~/development/toolbox
./install.sh --all
source ~/.zshrc
```

## What Gets Installed

### Via Homebrew
- **Homebrew** - macOS package manager
- **GNU Stow** - Dotfile symlink manager
- **tree** - Directory visualization tool
- **Claude CLI** - AI assistance (if not already installed)

### Configurations
- **~/.zshrc.toolbox** - Custom Zsh config (symlinked via Stow)
- **~/.zshrc** - Modified to source ~/.zshrc.toolbox

## Installation Options

### Install Everything (Recommended)
```bash
./install.sh --all
```

### Interactive Mode (Default)
```bash
./install.sh
```
Prompts for each component - install only what you want.

### Cherry-Pick Components
```bash
./install.sh --brew --stow --tree
```
Install only specified components (and their dependencies).

**Available Flags:**
- `--all` - Install everything non-interactively
- `--brew` - Install Homebrew
- `--stow` - Install GNU Stow
- `--tree` - Install tree command
- `--claude` - Install Claude CLI
- `--dotfiles` - Stow dotfiles
- `--zshrc` - Modify ~/.zshrc to source toolbox config

## Adding New Packages

See [docs/EXTENDING.md](docs/EXTENDING.md) for detailed guide.

**Quick example:**
1. Create `deps/ripgrep.sh` with install function
2. Add flag parsing to `install.sh`
3. Add function call to installation sequence

## Useful Commands

```bash
# From ~/.zshrc.toolbox:
toolbox        # Navigate to toolbox repo
refresh        # Reload shell configuration (source ~/.zshrc)
toolbox-update # Pull latest changes from repo
brew-installed # List all Homebrew packages
brewup         # Update and upgrade all Homebrew packages

# Homebrew:
brew search <package>    # Search for packages
brew install <package>   # Install package
brew upgrade             # Upgrade all packages
brew cleanup             # Remove old versions
```

## Troubleshooting

### Homebrew not in PATH
Restart your terminal or run:
```bash
# Apple Silicon Macs:
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Macs:
eval "$(/usr/local/bin/brew shellenv)"
```

### Stow conflicts
Backup and remove conflicting file:
```bash
mv ~/.zshrc.toolbox ~/.zshrc.toolbox.backup
./install.sh --dotfiles
```

### Permission errors
Ensure you own your home directory files:
```bash
ls -la ~/.zshrc ~/.zshrc.toolbox
```

## Directory Structure

```
toolbox/
├── install.sh           # Installation orchestrator
├── lib/                 # Core utilities
│   └── mac/             # macOS-specific (Homebrew)
├── deps/                # Package installation scripts
├── dotfiles/            # Dotfiles (Stow-managed)
├── scripts/             # Utility scripts
├── specs/               # Implementation plans
└── docs/                # Documentation
```

## Philosophy

This toolbox combines simplicity with flexibility:
- **Homebrew:** Industry-standard package management for macOS
- **GNU Stow:** Simple, transparent dotfile symlinks
- **Modular Scripts:** Easy to extend and customize
- **Self-Registering Components:** Automatic installation summaries

## Inspiration

- [joe.sh/terminal-tools](https://joe.sh/terminal-tools) - Terminal tools philosophy
- [josephschmitt/dotfiles](https://github.com/josephschmitt/dotfiles) - Dotfiles organization

## License

MIT
```

---

## 8. FEATURES.md Content

**Location:** `/Users/nathaniel.morihara/development/toolbox/FEATURES.md`

```markdown
# Toolbox Feature Roadmap

## Implemented (V1)

- [x] Homebrew installation (macOS package manager)
- [x] GNU Stow installation and dotfile management
- [x] tree command installation
- [x] Claude CLI installation (with fallback handling)
- [x] Zsh configuration via ~/.zshrc.toolbox (Stow-managed symlink)
- [x] Interactive installation mode (prompts for each component)
- [x] --all flag for non-interactive installation
- [x] Cherry-pick flags (--brew, --stow, --tree, --claude, --dotfiles, --zshrc)
- [x] Idempotent installation (safe to re-run)
- [x] Self-registering components (automatic installation summaries)
- [x] Modular directory structure (lib/, deps/, dotfiles/, scripts/)
- [x] macOS-specific functionality isolation (lib/mac/)
- [x] refresh command for reloading shell config

## V2: Enhanced Package Management

- [ ] More CLI tools: ripgrep, fzf, bat, eza, fd, jq, yq
- [ ] Brewfile integration for declarative package management
- [ ] Auto-update mechanism for toolbox repository
- [ ] Specialized agent for adding new dependencies
- [ ] Auto-detection pattern for deps/ (if complexity is manageable)

## V3: Advanced Dotfiles

- [ ] Git configuration package (.gitconfig.toolbox)
- [ ] Tmux configuration package
- [ ] Neovim configuration (LazyVim integration)
- [ ] SSH config management
- [ ] Shell theme (Starship or Oh My Posh)

## V4: Cross-Platform

- [ ] Full Linux support (Ubuntu, CentOS, Fedora)
- [ ] Detect and handle both Darwin and Linux elegantly
- [ ] Linux-specific package managers (apt, yum, dnf)
- [ ] CI/CD testing on multiple platforms

## V5: Developer Experience

- [ ] Health check command (./toolbox check or toolbox-check function)
- [ ] Dry-run mode (--dry-run)
- [ ] Verbose logging (--verbose or -v)
- [ ] State tracking (.toolbox/state.json)
- [ ] Automated tests (BATS or similar)
- [ ] Update notifications

## V6: macOS System Configuration

- [ ] GUI applications via Homebrew casks (VSCode, Docker, etc.)
- [ ] macOS system preferences automation (lib/mac/defaults.sh)
- [ ] Dock configuration
- [ ] Finder preferences
- [ ] Font management
- [ ] Login items management

## V7: Development Environments

- [ ] Profile-based installations (work, personal, minimal, full)
- [ ] Development environment templates
- [ ] Language-specific setups (Python, Node.js, Rust, Go)
- [ ] Database tools (PostgreSQL, Redis, MongoDB)
- [ ] Cloud CLI tools (AWS, GCP, Azure)
- [ ] Container tools (Docker, Podman, kubectl, helm, k9s)

## Ideas Under Consideration

- nix-darwin integration (for those who want declarative package management)
- home-manager for dotfiles (more powerful than Stow)
- LazyGit configuration
- Development containers (Dev Containers)
- Python/Node.js version management (pyenv, nvm, asdf)
- Secrets management (git-crypt, sops, 1Password CLI)
- Terminal multiplexer configs (tmux, zellij)
- YAML configuration file (install.conf.yaml)

## Non-Goals

- GUI configuration tool (CLI-first philosophy)
- Windows support (focus on Unix-like systems)
- Root-level system modifications (user-space only)
- Replacing system package managers entirely
```

---

## 9. Implementation Checklist

### Phase 1: Core Infrastructure
1. ✓ Plan complete (specs/01-v1-init-for-mac.md)
2. Create `lib/common.sh` - Logging, prompts, self-registering component system
3. Create `lib/os-detection.sh` - Platform detection
4. Create `FEATURES.md` - Feature roadmap
5. Create `README.md` - Usage documentation

### Phase 2: macOS & Dependency Scripts
6. Create `lib/mac/brew.sh` - Homebrew installation (Mac-specific)
7. Create `deps/stow.sh` - GNU Stow installation
8. Create `deps/tree.sh` - tree command installation
9. Create `deps/claude.sh` - Claude CLI installation with fallback

### Phase 3: Dotfiles and Shell
10. Create directory: `dotfiles/zsh/`
11. Create `dotfiles/zsh/.zshrc.toolbox` - Custom Zsh config with refresh command
12. Create `lib/dotfiles.sh` - Stow operations
13. Create `lib/zsh-config.sh` - ~/.zshrc modification

### Phase 4: Main Orchestrator
14. Create `install.sh` - Main installation script with auto-sourcing

### Phase 5: Scripts & Documentation
15. Create `scripts/help.sh` - Hello world placeholder script
16. Create `docs/EXTENDING.md` - Extension guide
17. Create `specs/` directory structure

### Phase 6: Testing
18. Test on clean macOS system (Intel and/or Apple Silicon)
19. Test idempotency (re-run install.sh --all)
20. Test interactive mode
21. Test cherry-pick flags (--brew --stow --tree)
22. Test self-registering installation summary

---

## Critical Files Summary

**Priority 1 (Essential for V1):**
1. `lib/common.sh` - Core utilities with self-registering component system
2. `lib/mac/brew.sh` - Homebrew installation
3. `deps/stow.sh`, `deps/tree.sh`, `deps/claude.sh` - Package installers
4. `install.sh` - Main orchestrator
5. `dotfiles/zsh/.zshrc.toolbox` - Custom Zsh config

**Priority 2 (Important for complete experience):**
6. `lib/dotfiles.sh` - Stow operations
7. `lib/zsh-config.sh` - .zshrc integration
8. `lib/os-detection.sh` - OS detection
9. `README.md` - User documentation
10. `FEATURES.md` - Roadmap

**Priority 3 (Nice to have):**
11. `scripts/help.sh` - Placeholder utility script
12. `docs/EXTENDING.md` - Extension guide
13. `specs/01-v1-init-for-mac.md` - This plan document

---

## Key Design Principles

1. **Explicit Over Implicit:** Installation order is clear in `install.sh` main()
2. **Self-Registering Components:** Each module calls `register_check()` for automatic summaries
3. **Platform Isolation:** Mac-specific code in `lib/mac/`, cross-platform in `deps/`
4. **Idempotent Operations:** All install functions check if already installed first
5. **Flexible Invocation:** Interactive (default), --all (non-interactive), or cherry-pick (specific flags)
6. **Easy Extension:** Add deps/*.sh file, update install.sh flags & function call

---

## Notes on Implementation

**Claude CLI Installation:**
- Check if already at `~/.local/bin/claude` (user's current installation)
- Fallback to Homebrew cask if available
- Log warning if not installed, provide manual installation link

**Self-Registering Components:**
- Each installer calls `register_check("Name", "check_command")` at module load time
- `show_installation_summary()` iterates through all registered checks
- No manual maintenance of summary function required

**Auto-Sourcing Pattern:**
- `for script in lib/*.sh; do source "$script"; done`
- Same for `lib/mac/*.sh` and `deps/*.sh`
- Simple, discoverable, minimal boilerplate

---

## What Changed from Initial Plan

- **Removed nix-darwin:** Simplified to Homebrew-only for V1
- **Moved brew.sh:** From `deps/` to `lib/mac/` (Mac-specific)
- **Added refresh command:** Quick way to reload shell config
- **Added specs/ directory:** For implementation plans
- **Changed extending.md:** Now `EXTENDING.md` (capitalized)
- **Added help.sh:** Placeholder script instead of .gitkeep
- **Decided on explicit deps:** Keep installation order clear for V1
