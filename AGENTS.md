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
./install.sh --brew --stow --tree --claude --pandoc --dotfiles --zshrc

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

### Worktree Workflow (Multi-Agent Development)

When multiple agents need to work on different features simultaneously, use git worktrees to avoid conflicts. Worktrees are **opt-in only** — explicitly request them when needed, not by default.

**When to use worktrees:**
- Multiple agents working on different features at the same time
- You want to keep changes isolated and avoid merging branches locally until ready
- You need the primary repo to remain clean for quick context switches

**Basic workflow:**

```bash
# 1. Create a new worktree for a feature
./scripts/worktree.sh create feature/my-feature

# 2. Navigate to the worktree and work
cd .worktrees/my-feature
# ... make changes, commit, test ...

# 3. When done: pull latest main, push, remove worktree, and update primary repo
./scripts/worktree.sh cleanup .worktrees/my-feature
```

**Available commands:**

```bash
# Create a new worktree for a branch
./scripts/worktree.sh create <branch_name>

# Finalize changes: pull main → push → remove worktree → pull main in primary repo
./scripts/worktree.sh cleanup <worktree_path>

# List all active worktrees
./scripts/worktree.sh list

# Find orphaned worktrees (optional, only when needed)
./scripts/worktree.sh cleanup-orphaned          # List orphaned worktrees
./scripts/worktree.sh cleanup-orphaned --remove # Remove orphaned worktrees
```

**Important notes:**
- Worktrees are stored in `.worktrees/` (git-ignored, local only)
- Each worktree is a **separate directory** with its own checkout
- The `cleanup` command handles the complete workflow: pull → push → remove
- Only use `cleanup-orphaned` if worktrees are stuck or the primary repo is in an inconsistent state

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

- **ai/** - AI-specific configurations
  - `AI_INSTRUCTIONS.md` - Claude Code project instructions (symlinked to ~/.claude/CLAUDE.md)
  - `skills/` - Custom Claude Code skills
  - **Purpose**: Configuration for AI tools and Claude Code integration

- **dotfiles/** - Stow-managed user configurations
  - Each subdirectory is a Stow package (e.g., `zsh/`, `git/`)
  - Files use `.toolbox` suffix to avoid conflicts (e.g., `.zshrc.toolbox`)
  - Symlinked to home directory via Stow

- **cheatsheets/** - Quick reference guides for common tasks
  - Organized by topic (e.g., `git.md`, `bash.md`)
  - Quick command references without extensive explanation

- **scripts/** - Utility scripts for toolbox commands
  - Independent bash scripts for complex command implementations
  - Called as wrappers from shell functions in dotfiles
  - Examples: `markdown.sh` for the `md` command, `cwd.sh` for the `cwd` command
  - **Purpose**: Keep shell config files (dotfiles) simple and readable. Complex logic belongs in scripts.

### Installation Flow

1. **Flag Parsing** - `parse_flags()` converts CLI flags to boolean variables
2. **OS Detection** - `detect_os()` sets $OS and $PACKAGE_MANAGER
3. **Auto-Sourcing** - All lib and deps scripts are sourced
4. **Installation** - `main()` executes functions in dependency order:
   - Config directories (~/.config/toolbox) - needed by tools like `cwd`
   - Homebrew (prerequisite for other tools)
   - GNU Stow (required for dotfiles)
   - Individual tools (tree, Claude CLI, Neovim, OpenCode, GitHub CLI, Pandoc)
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

## Private Commands

The `private/` directory allows users to add custom commands without committing them to the repository. All `.sh` files in this directory are automatically sourced when the shell starts.

**Key features:**
- Git-ignored (never committed)
- Auto-loaded on shell startup
- Perfect for work-specific shortcuts or commands with sensitive paths

**Location:** `private/`

**File naming:** Any `.sh` file (e.g., `commands.sh`, `work.sh`)

**Example (`private/commands.sh`):**
```bash
# Navigate to your work project
myproject() {
  cd ~/work/myproject || return
}

# Quick SSH to dev server
devssh() {
  ssh user@dev-server.example.com
}
```

**How it works:**
The `.zshrc.toolbox` file includes this section:
```bash
# ===== Private Commands (local only) =====
# Source user-defined private commands if they exist
if [[ -n "$TOOLBOX_ROOT" && -d "$TOOLBOX_ROOT/private" ]]; then
  # Use nullglob to prevent errors when no .sh files exist
  setopt local_options null_glob
  for private_file in "$TOOLBOX_ROOT/private"/*.sh; do
    [[ -f "$private_file" ]] && source "$private_file"
  done
  unset private_file
fi
```

**Testing:**
After creating a private command file, run `refresh` to reload the shell config.

## Shell Configuration Best Practices

**Keep dotfiles (.zshrc.toolbox, etc.) simple and readable:**

- **Shell config files should only contain:**
  - Simple environment setup and exports
  - Aliases for common commands
  - Simple function wrappers (1-5 lines) that delegate to scripts

- **Complex logic belongs in scripts/:**
  - Multi-line functions with loops, conditionals, or file operations
  - Functions that do significant processing or have many lines of code
  - Always call scripts via wrappers: `bash "$TOOLBOX_ROOT/scripts/scriptname.sh" "$@"`

- **Why:**
  - Shell config files are sourced on every shell start (performance)
  - Shell config should be quickly scannable and understandable
  - Complex logic is easier to debug and maintain in dedicated scripts
  - Scripts can be tested and executed independently

**Example pattern:**
```bash
# In .zshrc.toolbox (KEEP SIMPLE - just a wrapper)
md() {
  bash "$TOOLBOX_ROOT/scripts/markdown.sh" "$@"
}

# In scripts/markdown.sh (COMPLEX LOGIC GOES HERE)
#!/usr/bin/env bash
# Full implementation with all the logic
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
