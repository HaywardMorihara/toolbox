# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Installation

```bash
# Install everything non-interactively
./install.sh --all

# Interactive mode (prompts for each component)
./install.sh

# Install specific components
./install.sh --brew --stow --tree --claude --dotfiles --zshrc

# Show help
./install.sh --help
```

### Development

```bash
# Check shell script syntax
bash -n install.sh
bash -n lib/common.sh
bash -n deps/your-tool.sh

# Run the installer in debug mode
bash -x ./install.sh --all

# Test a single component
./install.sh --your-flag
```

## Architecture Overview

### Self-Registering Component System

The toolbox uses a **self-registering component system** to track installed components without manual maintenance:

1. **Registration**: Each installation function calls `register_check()` at the module level:
   ```bash
   register_check "Component Name" "command -v component"
   ```

2. **Storage**: The `register_check()` function (in `lib/common.sh`) stores checks in parallel arrays (bash 3.2 compatible)

3. **Summary**: At the end of installation, `show_installation_summary()` runs all checks and displays results

This pattern eliminates manual tracking and ensures accurate status reporting.

### Directory Structure

- **install.sh** - Main orchestrator that:
  - Auto-sources all files from `lib/`, `lib/mac/`, and `deps/`
  - Parses command-line flags
  - Manages installation sequence with dependency ordering
  - Calls installation functions and displays summary

- **lib/** - Core functionality and setup
  - `common.sh` - Shared utilities (logging, prompts, self-registering component system, file backup)
  - `os-detection.sh` - Platform detection ($OS, $PACKAGE_MANAGER variables)
  - `dotfiles.sh` - GNU Stow operations
  - `zsh-config.sh` - ~/.zshrc integration
  - `config.sh` - Configuration directories setup (e.g., ~/.config/toolbox)
  - `mac/brew.sh` - Homebrew installation (macOS-specific)
  - **Purpose**: System setup, configuration, and utility functions. Functions that set up the environment or manage configurations.

- **deps/** - External dependency installers
  - Each file contains a single `install_*()` function for an external tool
  - Must call `register_check()` at module level
  - All files are auto-sourced by install.sh
  - Examples: `stow.sh`, `tree.sh`, `claude.sh`
  - **Purpose**: Installing external packages/tools via package managers (brew, etc.)

- **dotfiles/** - Stow-managed user configurations
  - Each subdirectory is a Stow package (e.g., `zsh/`, `git/`)
  - Files use `.toolbox` suffix to avoid conflicts (e.g., `.zshrc.toolbox`)
  - Symlinked to home directory via Stow

### Installation Flow

1. **Flag Parsing** - `parse_flags()` converts CLI flags to boolean variables
2. **OS Detection** - `detect_os()` sets $OS and $PACKAGE_MANAGER
3. **Auto-Sourcing** - All lib and deps scripts are sourced
4. **Installation** - `main()` executes functions in dependency order:
   - Config directories (~/.config/toolbox) - needed by tools like `cwd`
   - Homebrew (prerequisite for other tools)
   - GNU Stow (required for dotfiles)
   - Individual tools (tree, Claude CLI, Neovim, OpenCode, GitHub CLI)
   - Dotfiles (creates symlinks via Stow)
   - Shell integration (sources .zshrc.toolbox from .zshrc)
5. **Summary** - All registered checks are run and displayed

### Key Design Patterns

**Idempotency**: Each function checks if already installed and skips if present:
```bash
if command -v tool &> /dev/null; then
  log_success "Tool is already installed"
  return 0
fi
```

**Interactive + Non-Interactive Modes**: The `should_install()` function handles both:
- `INSTALL_ALL=true` skips prompts
- `INTERACTIVE=true` shows prompts for each component
- Specific flags enable only selected components

**Error Handling**: Critical failures (Homebrew, Stow) exit the script. Optional components log warnings and continue.

**Bash 3.2 Compatibility**: Avoids bash 4+ features (associative arrays) using parallel arrays instead.

## Adding New Components

### Dependency Script Template

Create `deps/your-tool.sh`:
```bash
#!/usr/bin/env bash

install_your_tool() {
  local component_name="Your Tool"

  if command -v your-tool &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  if ! should_install "INSTALL_YOUR_TOOL" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."
  brew install your-tool || {
    log_error "Failed to install $component_name"
    return 1
  }

  log_success "$component_name installed successfully"
  return 0
}

register_check "Your Tool" "command -v your-tool"
```

### Updates to install.sh

1. Add flag declaration: `INSTALL_YOUR_TOOL=false`
2. Add case in `parse_flags()`: `--your-tool) INSTALL_YOUR_TOOL=true ;;`
3. Export flag: `export INSTALL_YOUR_TOOL` (in export list on line 96)
4. Add to `main()`: `install_your_tool || log_warn "Failed to install Your Tool"`
5. Add to help: `--your-tool    Install Your Tool`

### Dotfile Script Template

In `lib/dotfiles.sh`, add:
```bash
stow_git_config() {
  cd "$REPO_ROOT" || return 1
  stow -d dotfiles -t ~ git || {
    log_error "Failed to stow git configuration"
    return 1
  }
  log_success "Git configuration stowed successfully"
  return 0
}

register_check "~/.gitconfig.toolbox (symlinked)" "[[ -L \$HOME/.gitconfig.toolbox ]]"
```

## Important Variables

From environment or script exports:
- `$OS` - Operating system (Darwin, Linux, etc.)
- `$PACKAGE_MANAGER` - Package manager (brew, apt, yum, etc.)
- `$REPO_ROOT` - Path to toolbox repository
- `$INTERACTIVE` - true/false
- `$INSTALL_ALL` - true/false
- `INSTALL_*` flags - Component-specific installation flags

## Utility Functions (from lib/common.sh)

```bash
log_info "Message"              # Blue info message
log_success "Message"           # Green success message
log_warn "Message"              # Yellow warning message
log_error "Message"             # Red error message

prompt_yes_no "Question?" "y"   # Interactive yes/no (default: y)
backup_file "/path/to/file"     # Backup with timestamp

should_install "FLAG_NAME" "component name"  # Respects flags + interactive mode
register_check "Name" "check command"        # Register for summary (call at module level!)
show_installation_summary                    # Display all checks
```

## Updating Documentation After install.sh Changes

Whenever you make meaningful changes to `install.sh` (flags, behavior, installation order, etc.), update README.md, AGENTS.md, and keep `show_help()` in sync.

## Common Pitfalls

1. **Forgetting to register checks** - Always call `register_check()` at module level, not inside functions
2. **Not checking idempotency** - Verify installations skip if already present
3. **Missing flag declaration** - Add to `parse_flags()`, export list, and help message
4. **Wrong check commands** - Use `command -v tool` for CLI tools, `[[ -L $HOME/file ]]` for symlinks
5. **Not respecting the dependency order** - Homebrew must come before other tools
6. **Forgetting documentation updates** - Always sync README.md, AGENTS.md, and install.sh help text after interface changes

## References

- README.md - Project overview and quick start
- FEATURES.md - Complete roadmap including V2-V7 planned features
- docs/EXTENDING.md - Detailed extension guide with real examples and testing checklist
