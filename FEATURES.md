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
