# Toolbox

My personal development toolbox - automated setup for development dependencies and configurations.

## Quick Start

```bash
git clone https://github.com/HaywardMorihara/toolbox ~/toolbox  # Or any location you prefer
cd ~/toolbox
./install.sh --all
source ~/.zshrc
```

**Note:** You can clone the toolbox to any directory. The installation path is automatically detected and stored for shell functions to use. `~/toolbox` is just the recommended example location.

## Updating Your Environment

To get the latest tools and configurations:

```bash
cd ~/toolbox
./install.sh --update --all
```

## Mission

A craftsman is only as good as their tools. This toolbox is a curated collection of tools, configurations, and scripts that travel with you across machines. It's your personal dev environment in version control.

**Key principle:** Each tool has a "space cost." We ruthlessly prioritize what goes in this toolbox. Not every useful tool belongs here—only ones that meaningfully improve your workflow and justify their maintenance overhead.

**With AI (LLMs):** The barrier to implementing useful automation has dropped dramatically. This makes it more viable to build custom tools and scripts tailored to your actual workflow, rather than relying on generic off-the-shelf solutions.

## When Is It Worth Automating?

Reference: [XKCD #1205: Is It Worth the Time?](https://xkcd.com/1205/)

![XKCD: Is It Worth the Time?](docs/is_it_worth_the_time.png)

The classic automation chart still applies, but remember: **with LLMs, the time cost of implementing automation has shifted left.** What wasn't worth automating last year might be very worth it now.

## What Gets Installed

### Core Dependencies
- **Homebrew** - macOS package manager (prerequisite for other tools)
- **GNU Stow** - Dotfile symlink manager

### Development Tools
- **tree** - Directory visualization tool
- **Claude CLI** - AI assistance from the command line
- **Neovim** - Modern text editor (with lazy.nvim plugin manager)
- **OpenCode CLI** - OpenCode editor CLI
- **GitHub CLI (gh)** - GitHub command-line interface
- **Pandoc** - Universal document converter (Markdown to HTML, etc.)

### Configurations
- **~/.zshrc.toolbox** - Custom Zsh config (symlinked via Stow)
- **~/.config/nvim/** - Neovim configuration with lazy.nvim
- **~/.config/toolbox/cheatsheets/** - Quick reference guides
- **~/.zshrc** - Modified to source ~/.zshrc.toolbox

## Code Dependencies

```mermaid
graph LR
    subgraph "Core Installation"
        install["install.sh<br/>(main orchestrator)"]
    end

    subgraph "Library Functions"
        common["lib/common.sh<br/>(logging, prompts,<br/>registration)"]
        osdetect["lib/os-detection.sh<br/>(OS detection)"]
        config["lib/config.sh<br/>(config dirs)"]
        dotfiles["lib/dotfiles.sh<br/>(stow operations)"]
        zshconf["lib/zsh-config.sh<br/>(shell integration)"]
        brew["lib/mac/brew.sh<br/>(Homebrew setup)"]
    end

    subgraph "Tool Installers"
        deps["deps/*.sh<br/>(tree, claude,<br/>neovim, gh, pandoc)"]
    end

    subgraph "Shell Configuration"
        zshrc[".zshrc.toolbox<br/>(shell config)"]
    end

    subgraph "Scripts"
        markdown["scripts/markdown.sh<br/>(Markdown viewer)"]
        cwd["scripts/cwd.sh<br/>(dir management)"]
        help["scripts/help.sh<br/>(help system)"]
    end

    subgraph "Dotfiles"
        nvim["nvim config"]
        cheatsheets["cheatsheets"]
    end

    install -->|sources| common
    install -->|sources| osdetect
    install -->|sources| config
    install -->|sources| dotfiles
    install -->|sources| zshconf
    install -->|sources| brew
    install -->|sources| deps

    brew -->|uses| common
    brew -->|uses| osdetect
    deps -->|uses| common
    deps -->|uses| osdetect
    dotfiles -->|uses| common
    zshconf -->|uses| common

    zshrc -->|calls| markdown
    zshrc -->|calls| cwd
    zshrc -->|calls| help

    markdown -->|requires| pandoc["Pandoc<br/>(installed by deps)"]

    install -->|stows| nvim
    install -->|stows| cheatsheets
    install -->|integrates| zshrc
```

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
./install.sh --brew --stow --tree          # Install specific components
./install.sh --claude --neovim --gh        # Install dev tools
./install.sh --pandoc                      # Install Markdown viewer tools
./install.sh --dotfiles --zshrc            # Just setup dotfiles
```

## Available Flags

- `--all` - Install all components non-interactively
- `--update` - Pull latest changes from git before installing
- `--brew` - Install Homebrew
- `--stow` - Install GNU Stow
- `--tree` - Install tree command
- `--claude` - Install Claude CLI
- `--neovim` - Install Neovim
- `--opencode` - Install OpenCode CLI
- `--gh` - Install GitHub CLI
- `--pandoc` - Install Pandoc document converter
- `--dotfiles` - Stow dotfiles (symlink ~/.zshrc.toolbox, nvim config, cheatsheets)
- `--zshrc` - Modify ~/.zshrc to source toolbox config
- `-h, --help` - Show help message

## Useful Commands

After installation, these commands are available from ~/.zshrc.toolbox:

```bash
refresh            # Reload shell configuration (no need to source ~/.zshrc manually)
toolbox            # Navigate to toolbox repository
toolbox-update     # Pull latest changes from git
cwd                # Set current directory as the default working directory
md                 # View Markdown files in your browser
```

New terminal tabs will automatically switch to your default working directory.

## Private Commands

Want to add your own custom commands without committing them to the repository? Use the `private/` directory!

All `.sh` files in the `private/` directory are automatically sourced when your shell starts, but they're git-ignored and never committed. Perfect for:
- Work-specific shortcuts
- Personal aliases
- Commands with sensitive paths

**Example:** Create `private/commands.sh`:
```bash
# Navigate to your work project
myproject() {
  cd ~/work/myproject || return
}

# Quick SSH to your dev server
devssh() {
  ssh user@dev-server.example.com
}
```

After creating the file, run `refresh` and your commands will be available!

See `private/README.md` for more examples and tips.

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

### Tool Graduation

As tools grow and mature, they can graduate into standalone repositories if they're stable, well-documented, and solve a general problem worth sharing. The toolbox serves as an incubator—not everything needs to stay here forever.

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
├── AGENTS.md               # Claude Code project instructions
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
│   ├── claude.sh           # Claude CLI
│   ├── neovim.sh           # Neovim editor
│   ├── opencode.sh         # OpenCode CLI
│   ├── gh.sh               # GitHub CLI
│   └── pandoc.sh           # Pandoc document converter
│
├── ai/                      # AI-specific configurations
│   ├── AI_INSTRUCTIONS.md  # AI instructions for Claude Code
│   └── skills/              # Claude Code custom skills
│
├── dotfiles/               # Stow-managed dotfiles
│   ├── zsh/
│   │   └── .zshrc.toolbox  # Custom Zsh configuration
│   ├── nvim/
│   │   └── .config/nvim/   # Neovim configuration
│   └── cheatsheets/
│       └── .config/toolbox/cheatsheets/  # Reference guides
│
├── scripts/                # Utility scripts (complex command logic)
│   ├── help.sh             # Help/cheatsheet display
│   ├── cwd.sh              # Working directory management
│   └── markdown.sh         # Markdown viewer
│
├── private/                # Private commands (git-ignored)
│   └── README.md           # Instructions and examples
│
└── docs/                   # Documentation
    └── EXTENDING.md        # Extension guide
```

## Philosophy

This toolbox focuses on:
- **Simplicity** - Bash scripts you can understand and modify
- **Idempotent** - The script can be freely re-run, and will proceed if any one installation fails
- **Modularity** - Each component is independent and self-contained
- **Clarity** - Explicit installation order, no magic auto-detection
- **Cross-platform ready** - Structure supports future Linux support (V4+)

### Iterative Tool Development

When adding new tools or scripts:
- **Start with V1** - Build the simplest version that solves one specific problem
- **Make it work first** - Don't over-engineer or add "future" features
- **Then iterate** - Once V1 is working, gradually add features and make it more generic
- **Avoid scope creep** - Resist the temptation to make tools ambitious from the start

This keeps development fast and prevents tools from becoming bloated before they're even useful.

## Inspiration

- [joe.sh/terminal-tools](https://joe.sh/terminal-tools) - Philosophy and approach
- [josephschmitt/dotfiles](https://github.com/josephschmitt/dotfiles) - Structure and conventions

## License

MIT
