# Extending Toolbox

This guide explains how to add new packages, configurations, and features to your toolbox.

## Table of Contents

- [Compatibility](#compatibility)
- [Scripts and Wrapper Functions Pattern](#scripts-and-wrapper-functions-pattern)
- [Adding Homebrew Packages](#adding-homebrew-packages)
- [Adding Dotfile Configurations](#adding-dotfile-configurations)
- [Understanding Self-Registering Components](#understanding-self-registering-components)
- [Testing Your Changes](#testing-your-changes)

---

## Compatibility

**Bash Version:** This toolbox is compatible with **bash 3.2+** (the default bash on macOS). All scripts avoid features that require bash 4+ (like associative arrays) to ensure maximum compatibility.

**Supported Platforms:**
- macOS (primary platform)
- Linux (experimental, V4+)

---

## Scripts and Wrapper Functions Pattern

For user-facing commands and utilities, the toolbox uses a **scripts + wrapper functions pattern**:

1. **Core Logic in `scripts/`** - Standalone bash script with the actual functionality
2. **Wrapper Function in `~/.zshrc.toolbox`** - Thin shell function that calls the script
3. **User Configuration** - Any settings stored in `~/.config/toolbox/` (not tracked by git)

This approach keeps scripts testable and portable (can run outside shell context), while providing convenient command-line access through shell functions.

### When to Use This Pattern

✅ **Use this pattern for:**
- User-facing commands that should persist across shells
- Features with user-specific configuration
- Utilities that might need to run from cron, scripts, or other non-shell contexts

❌ **Don't use this pattern for:**
- Simple aliases (just use `.zshrc.toolbox`)
- Homebrew/package installations (use `deps/` pattern)
- Shell-only utilities that never need to run standalone

---

## Adding Homebrew Packages

### Step 1: Create a Dependency Script

Create a new file in `deps/` directory following the pattern:

```bash
# deps/your-tool.sh
#!/usr/bin/env bash

install_your_tool() {
  local component_name="Your Tool"

  # Check if already installed (idempotency)
  if command -v your-tool &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if user wants to install (respects flags and interactive mode)
  if ! should_install "INSTALL_YOUR_TOOL" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Cross-platform installation
  case "$OS" in
    Darwin)
      brew install your-tool || {
        log_error "Failed to install $component_name via Homebrew"
        return 1
      }
      ;;
    Linux)
      case "$PACKAGE_MANAGER" in
        apt)
          sudo apt-get install -y your-tool || {
            log_error "Failed to install $component_name"
            return 1
          }
          ;;
        *)
          log_warn "$component_name: No installation method for $PACKAGE_MANAGER"
          return 1
          ;;
      esac
      ;;
    *)
      log_warn "$component_name: Unsupported OS: $OS"
      return 1
      ;;
  esac

  log_success "$component_name installed successfully"
  return 0
}

# Self-register for installation summary (IMPORTANT!)
register_check "Your Tool" "command -v your-tool"
```

### Step 2: Add Flag to install.sh

In `install.sh`, add the new flag:

```bash
# Flag parsing section
INSTALL_YOUR_TOOL=false

# In parse_flags() function
      --your-tool)
        INSTALL_YOUR_TOOL=true
        ;;

# Export the flag
export INSTALL_ALL INSTALL_BREW ... INSTALL_YOUR_TOOL
```

### Step 3: Add to Installation Sequence

In `install.sh`, add to the `main()` function:

```bash
main() {
  # ... existing installations ...

  # Install your tool
  install_your_tool || log_warn "Failed to install Your Tool"

  # ... rest of installations ...
}
```

### Step 4: Update Help Message

In `install.sh`, add to `show_help()`:

```bash
OPTIONS:
  --all          Install all components non-interactively
  # ... existing options ...
  --your-tool    Install Your Tool
```

### Real Example 1: OpenCode (CLI Tool)

Here's a complete example for adding OpenCode, an interactive CLI tool installed via Homebrew:

**deps/opencode.sh:**
```bash
#!/usr/bin/env bash
# deps/opencode.sh - OpenCode CLI installation

install_opencode() {
  local component_name="OpenCode CLI"

  # Check if already installed (idempotency)
  if command -v opencode &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  # Check if user wants to install (respects flags and interactive mode)
  if ! should_install "INSTALL_OPENCODE" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."

  # Install via Homebrew
  brew install opencode || {
    log_error "Failed to install $component_name via Homebrew"
    return 1
  }

  log_success "$component_name installed successfully"
  return 0
}

# Self-register for installation summary
register_check "OpenCode CLI" "command -v opencode"
```

**Changes to install.sh:**
```bash
# Add flag (around line 28)
INSTALL_OPENCODE=false

# In parse_flags() (around line 80)
      --opencode)
        INSTALL_OPENCODE=true
        ;;

# In export list (line 101)
export INSTALL_ALL INSTALL_BREW INSTALL_STOW INSTALL_TREE INSTALL_CLAUDE INSTALL_NEOVIM INSTALL_OPENCODE INSTALL_DOTFILES INSTALL_ZSHRC INTERACTIVE

# In main() function (after other tool installations)
  install_opencode || log_warn "Failed to install OpenCode"

# In show_help() (add to OPTIONS section)
  --opencode     Install OpenCode CLI
```

### Real Example 2: ripgrep (CLI Tool with Cross-Platform Support)

Here's an example with cross-platform installation support:

**deps/ripgrep.sh:**
```bash
#!/usr/bin/env bash

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
      case "$PACKAGE_MANAGER" in
        apt)
          sudo apt-get install -y ripgrep || {
            log_error "Failed to install $component_name"
            return 1
          }
          ;;
        *)
          log_warn "$component_name: No installation method for $PACKAGE_MANAGER"
          return 1
          ;;
      esac
      ;;
  esac

  log_success "$component_name installed successfully"
  return 0
}

register_check "ripgrep" "command -v rg"
```

**Changes to install.sh:**
```bash
# Add flag
INSTALL_RIPGREP=false

# In parse_flags()
      --ripgrep)
        INSTALL_RIPGREP=true
        ;;

# Export
export INSTALL_RIPGREP

# In main()
  install_ripgrep || log_warn "Failed to install ripgrep"
```

---

## Adding Dotfile Configurations

### Step 1: Create Stow Package Structure

Organize your dotfiles under `dotfiles/<package-name>/`:

```
dotfiles/
├── zsh/
│   └── .zshrc.toolbox
└── git/
    ├── .gitconfig.toolbox
    └── .gitignore_global
```

### Step 2: Create Stow Function

In `lib/dotfiles.sh`, add a new stow function:

```bash
stow_git_config() {
  local repo_root="$1"

  if ! command -v stow &> /dev/null; then
    log_error "stow command not found"
    return 1
  fi

  if ! should_install "INSTALL_GIT_CONFIG" "git configuration"; then
    return 1
  fi

  log_info "Stowing git configuration..."

  cd "$repo_root" || return 1

  stow -d dotfiles -t ~ git || {
    log_error "Failed to stow git configuration"
    log_info "If conflicts exist, backup and remove existing files"
    return 1
  }

  log_success "Git configuration stowed successfully"
  return 0
}

# Register check
register_check "~/.gitconfig.toolbox (symlinked)" "[[ -L \$HOME/.gitconfig.toolbox ]]"
```

### Step 3: Update install.sh

Add flag, export, and call in main():

```bash
INSTALL_GIT_CONFIG=false

# In parse_flags()
      --git-config)
        INSTALL_GIT_CONFIG=true
        ;;

# In main()
  stow_git_config "$REPO_ROOT" || log_warn "Failed to stow git config"
```

### Step 4: Source Dotfile from Main Config

If the dotfile should be sourced (like .gitconfig), add to the appropriate config file:

**For git (.gitconfig):**
Add to your main `~/.gitconfig`:
```gitconfig
[include]
  path = ~/.gitconfig.toolbox
```

Or create a setup function in `lib/git-config.sh`:

```bash
setup_gitconfig_integration() {
  local gitconfig="$HOME/.gitconfig"
  local toolbox_config="$HOME/.gitconfig.toolbox"

  if [[ ! -f "$toolbox_config" ]]; then
    log_warn "~/.gitconfig.toolbox not found"
    return 1
  fi

  if [[ ! -f "$gitconfig" ]]; then
    touch "$gitconfig"
  fi

  # Check if already integrated
  if grep -q "path = ~/.gitconfig.toolbox" "$gitconfig"; then
    log_success "~/.gitconfig already includes toolbox config"
    return 0
  fi

  if ! should_install "INSTALL_GIT_CONFIG" "git config integration"; then
    return 1
  fi

  backup_file "$gitconfig"

  cat >> "$gitconfig" << 'EOF'

# Toolbox: Load custom git configurations
[include]
  path = ~/.gitconfig.toolbox
EOF

  log_success "~/.gitconfig updated successfully"
  return 0
}
```

---

## Understanding Self-Registering Components

The toolbox uses a **self-registering component system** to automatically track installed components.

### How It Works

1. **Registration:** Each installation function calls `register_check()` at the module level:
   ```bash
   # deps/tree.sh
   register_check "tree command" "command -v tree"
   ```

2. **Storage:** The `register_check()` function (in `lib/common.sh`) stores the check in parallel arrays (bash 3.2 compatible):
   ```bash
   # Parallel arrays for bash 3.2 compatibility
   INSTALL_CHECK_NAMES=()
   INSTALL_CHECK_COMMANDS=()

   register_check() {
     local name="$1"
     local check_command="$2"
     INSTALL_CHECK_NAMES+=("$name")
     INSTALL_CHECK_COMMANDS+=("$check_command")
   }
   ```

3. **Summary Generation:** At the end of installation, `show_installation_summary()` runs all checks:
   ```bash
   show_installation_summary() {
     local i
     for i in "${!INSTALL_CHECK_NAMES[@]}"; do
       local name="${INSTALL_CHECK_NAMES[$i]}"
       local check_cmd="${INSTALL_CHECK_COMMANDS[$i]}"
       if eval "$check_cmd" &> /dev/null; then
         log_success "✓ $name"
       else
         log_warn "✗ $name"
       fi
     done
   }
   ```

### Benefits

- **Automatic:** No manual maintenance of installation summary
- **Accurate:** Checks actual state, not assumptions
- **Modular:** Each component self-registers independently
- **Extensible:** New components automatically appear in summary

### Best Practices

1. **Always register at module level** (not inside functions):
   ```bash
   # ✅ GOOD - At module level
   install_foo() {
     # ... installation logic ...
   }
   register_check "Foo" "command -v foo"

   # ❌ BAD - Inside function
   install_foo() {
     # ... installation logic ...
     register_check "Foo" "command -v foo"  # Won't work reliably
   }
   ```

2. **Use robust check commands:**
   ```bash
   # For CLI tools
   register_check "ripgrep" "command -v rg"

   # For symlinks
   register_check "~/.zshrc.toolbox" "[[ -L \$HOME/.zshrc.toolbox ]]"

   # For file content
   register_check "~/.zshrc sources toolbox" "grep -Fq 'source ~/.zshrc.toolbox' \$HOME/.zshrc"

   # For complex checks
   register_check "Homebrew" "command -v brew"
   ```

3. **Use descriptive names:**
   ```bash
   # ✅ GOOD
   register_check "Claude CLI" "command -v claude"
   register_check "~/.zshrc.toolbox (symlinked)" "[[ -L \$HOME/.zshrc.toolbox ]]"

   # ❌ BAD
   register_check "cli" "command -v claude"
   register_check "zshrc" "[[ -L \$HOME/.zshrc.toolbox ]]"
   ```

---

## Testing Your Changes

### Basic Testing Checklist

1. **Syntax Check:**
   ```bash
   bash -n deps/your-tool.sh
   bash -n install.sh
   ```

2. **Test Interactive Mode:**
   ```bash
   ./install.sh
   # Answer "yes" to your component
   # Verify it installs correctly
   ```

3. **Test Non-Interactive Mode:**
   ```bash
   ./install.sh --your-tool
   # Verify it installs without prompts
   ```

4. **Test --all Flag:**
   ```bash
   ./install.sh --all
   # Verify your component is included
   ```

5. **Test Idempotency:**
   ```bash
   ./install.sh --your-tool
   ./install.sh --your-tool  # Should skip, not reinstall
   ```

6. **Test Installation Summary:**
   ```bash
   ./install.sh --all
   # Check that your component appears in the summary
   # Should show ✓ if installed, ✗ if failed
   ```

7. **Test Help Message:**
   ```bash
   ./install.sh --help
   # Verify your flag is documented
   ```

### Advanced Testing

**Test on Clean System:**
If possible, test on a clean macOS installation or VM to ensure all dependencies are correctly specified.

**Test Uninstall/Reinstall:**
```bash
# Uninstall your tool
brew uninstall your-tool  # or rm if not via brew

# Reinstall via toolbox
./install.sh --your-tool
```

**Test with Different Flags:**
```bash
# Test that it respects when not selected
./install.sh --brew --stow  # Should NOT install your-tool

# Test explicit installation
./install.sh --your-tool    # Should install your-tool
```

---

## Common Patterns

### Pattern: CLI Tool via Homebrew

```bash
install_tool_name() {
  local component_name="Tool Name"

  if command -v tool-name &> /dev/null; then
    log_success "$component_name is already installed"
    return 0
  fi

  if ! should_install "INSTALL_TOOL_NAME" "$component_name"; then
    return 1
  fi

  log_info "Installing $component_name..."
  brew install tool-name || {
    log_error "Failed to install $component_name"
    return 1
  }

  log_success "$component_name installed successfully"
  return 0
}

register_check "Tool Name" "command -v tool-name"
```

### Pattern: Dotfile with Integration

```bash
stow_config() {
  cd "$REPO_ROOT" || return 1
  stow -d dotfiles -t ~ package-name || return 1
  log_success "Config stowed"
  return 0
}

setup_config_integration() {
  local config="$HOME/.main-config"
  local toolbox_config="$HOME/.config.toolbox"

  if grep -Fq "source ~/.config.toolbox" "$config"; then
    log_success "Already integrated"
    return 0
  fi

  backup_file "$config"
  echo "source ~/.config.toolbox" >> "$config"
  log_success "Integration complete"
  return 0
}

register_check "~/.config.toolbox (symlinked)" "[[ -L \$HOME/.config.toolbox ]]"
register_check "~/.main-config sources toolbox" "grep -Fq 'source ~/.config.toolbox' \$HOME/.main-config"
```

### Pattern: Platform-Specific Installation

```bash
install_platform_tool() {
  local component_name="Platform Tool"

  if [[ "$OS" != "Darwin" ]]; then
    log_warn "$component_name: Only supported on macOS"
    return 1
  fi

  # ... rest of installation logic ...
}

register_check "Platform Tool (macOS only)" "[[ \"$(uname)\" == \"Darwin\" ]] && command -v platform-tool"
```

---

## File Naming Conventions

- **Scripts:** Use lowercase with hyphens: `my-tool.sh`
- **Functions:** Use lowercase with underscores: `install_my_tool()`
- **Variables:** Use uppercase with underscores: `INSTALL_MY_TOOL`
- **Dotfiles:** Prefix with dot: `.my-config.toolbox`

---

## Need Help?

- Check existing implementations in `deps/` and `lib/` directories
- Review `lib/common.sh` for available utility functions
- See `FEATURES.md` for planned additions you could implement
- Open an issue on GitHub for questions

---

## Quick Reference

### Available Utility Functions (from lib/common.sh)

```bash
log_info "Message"              # Blue info message
log_success "Message"           # Green success message
log_warn "Message"              # Yellow warning message
log_error "Message"             # Red error message

prompt_yes_no "Question?" "y"   # Interactive yes/no prompt (default: y)
backup_file "/path/to/file"     # Backup file with timestamp

should_install "FLAG_NAME" "component name"  # Check if should install
register_check "Name" "check command"        # Register for summary
show_installation_summary                    # Display all checks
```

### Available Variables

```bash
$OS                  # Darwin, Linux, etc.
$PACKAGE_MANAGER     # brew, apt, yum, etc.
$REPO_ROOT           # Path to toolbox repository
$INTERACTIVE         # true/false
$INSTALL_ALL         # true/false
```
