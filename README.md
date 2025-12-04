# Toolbox

My personal development toolbox - automated setup for development dependencies and configurations.

## Quick Start

```bash
git clone https://github.com/HaywardMorihara/toolbox ~/development/toolbox
cd ~/development/toolbox
./install.sh --all
source ~/.zshrc
```

## What Gets Installed

### Core Dependencies
- **Homebrew** - macOS package manager (prerequisite for other tools)
- **GNU Stow** - Dotfile symlink manager
- **tree** - Directory visualization tool
- **Claude CLI** - AI assistance (with fallback handling if unavailable)

### Configurations
- **~/.zshrc.toolbox** - Custom Zsh config (symlinked via Stow)
- **~/.zshrc** - Modified to source ~/.zshrc.toolbox

## Installation Options

### Install Everything (Recommended)
```bash
./install.sh --all
```
Non-interactive mode - installs all components without prompting.

### Update and Install
```bash
./install.sh --update --all
```
Pulls latest changes from git, then installs all components.

### Interactive Mode (Default)
```bash
./install.sh
```
Prompts for each component, allowing you to pick and choose.

### Cherry-Pick Components
```bash
./install.sh --brew --stow --tree    # Install specific components
./install.sh --dotfiles --zshrc      # Just setup dotfiles
```

## Available Flags

- `--all` - Install all components non-interactively
- `--update` - Pull latest changes from git before installing
- `--brew` - Install Homebrew
- `--stow` - Install GNU Stow
- `--tree` - Install tree command
- `--claude` - Install Claude CLI
- `--dotfiles` - Stow dotfiles (symlink ~/.zshrc.toolbox)
- `--zshrc` - Modify ~/.zshrc to source toolbox config
- `-h, --help` - Show help message

## Useful Commands

After installation, these commands are available from ~/.zshrc.toolbox:

```bash
refresh            # Reload shell configuration (no need to source ~/.zshrc manually)
toolbox            # Navigate to toolbox repository
toolbox-update     # Pull latest changes from git
cwd                # Set current directory as the default working directory
```

New terminal tabs will automatically switch to your default working directory.

## Customizing Your Config

Edit the custom Zsh configuration:
```bash
vim ~/.zshrc.toolbox
```

Since it's symlinked via Stow, changes are automatically tracked in the git repository.

## Adding New Tools

See [docs/EXTENDING.md](docs/EXTENDING.md) for detailed instructions on:
- Adding new Homebrew packages
- Adding new dotfile configurations
- Understanding the self-registering component system

## Safety Features

- **Idempotent** - Safe to re-run installation multiple times
- **Backups** - Automatically backs up existing files before modification
- **Interactive prompts** - Default mode asks permission for each step
- **Installation summary** - Shows what succeeded/failed at the end

## Troubleshooting

### Homebrew not found after installation (Apple Silicon Macs)
Restart your terminal or run:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Stow conflicts
If stow reports conflicts with existing files:
```bash
# Backup existing file
mv ~/.zshrc.toolbox ~/.zshrc.toolbox.backup
# Re-run installation
./install.sh --dotfiles
```

### Claude CLI installation fails
Claude CLI may not be available via Homebrew. The installer will warn but continue. Install manually if needed.

## Directory Structure

```
toolbox/
├── install.sh              # Main installation orchestrator
├── README.md               # This file
├── FEATURES.md             # Feature roadmap
│
├── lib/                    # Modular installation functions
│   ├── common.sh           # Shared utilities (logging, prompts, self-registering components)
│   ├── os-detection.sh     # Platform identification
│   ├── dotfiles.sh         # Stow operations
│   ├── zsh-config.sh       # ~/.zshrc modification handler
│   └── mac/                # macOS-specific functions
│       └── brew.sh         # Homebrew installation
│
├── deps/                   # Dependency installers (cross-platform)
│   ├── stow.sh             # GNU Stow
│   ├── tree.sh             # tree command
│   └── claude.sh           # Claude CLI
│
├── dotfiles/               # Stow-managed dotfiles
│   └── zsh/
│       └── .zshrc.toolbox  # Custom Zsh configuration
│
├── scripts/                # Utility scripts
│   └── help.sh             # Help information (placeholder)
│
└── docs/                   # Documentation
    └── EXTENDING.md        # Extension guide
```

## Philosophy

This toolbox focuses on:
- **Simplicity** - Bash scripts you can understand and modify
- **Modularity** - Each component is independent and self-contained
- **Clarity** - Explicit installation order, no magic auto-detection
- **Cross-platform ready** - Structure supports future Linux support (V4+)

## Inspiration

- [joe.sh/terminal-tools](https://joe.sh/terminal-tools) - Philosophy and approach
- [josephschmitt/dotfiles](https://github.com/josephschmitt/dotfiles) - Structure and conventions

## Future Plans

See [FEATURES.md](FEATURES.md) for the complete roadmap including:
- V2: More CLI tools (ripgrep, fzf, bat, eza, fd, jq, yq)
- V3: Advanced dotfiles (git, tmux, neovim, ssh)
- V4: Cross-platform support (Linux)
- V5: Enhanced developer experience (health checks, dry-run mode, tests)

## License

MIT
