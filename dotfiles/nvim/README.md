# Neovim Configuration

A modern, modular Neovim configuration inspired by [LazyVim](https://www.lazyvim.org/), designed to provide a fully-featured IDE experience out of the box.

## Overview

This configuration provides:

- **File Explorer** - Neo-tree for browsing and managing files in a tree view
- **Fuzzy Finder** - Telescope for searching files, text, and more across your project
- **Autocompletion** - Intelligent code completion with LSP and snippet support
- **Language Server Protocol (LSP)** - Go-to-definition, hover documentation, diagnostics, and more
- **Syntax Highlighting** - Tree-sitter-powered accurate parsing
- **Beautiful Theme** - Tokyo Night color scheme
- **Smart Navigation** - Enhanced keybindings for window and buffer navigation
- **Performance** - Lazy-loading plugins for fast startup

## Quick Start

1. **Install Neovim** (0.9+)
   ```bash
   brew install neovim  # macOS
   ```

2. **The configuration auto-installs on first run**
   - When you open Neovim, `lazy.nvim` (the plugin manager) will auto-install if needed
   - All plugins will be downloaded and compiled automatically

3. **Done!** You're ready to use Neovim

## Project Structure

```
nvim/
├── init.lua              # Entry point (loads config.lazy)
│
└── lua/
    ├── config/           # Configuration modules (loaded early)
    │   ├── lazy.lua      # Bootstrap lazy.nvim and plugin loading
    │   ├── options.lua   # Editor settings (numbers, tabs, indentation, etc.)
    │   ├── keymaps.lua   # Global keybindings
    │   └── autocmds.lua  # Auto-triggered commands
    │
    └── plugins/          # Plugin specifications (auto-loaded by lazy.nvim)
        ├── theme.lua     # Color scheme (Tokyo Night)
        ├── neotree.lua   # File explorer (Neo-tree)
        ├── telescope.lua # Fuzzy finder (Telescope)
        ├── completion.lua # Code completion (nvim-cmp)
        ├── lsp.lua       # Language Server Protocol setup
        └── treesitter.lua # Syntax highlighting
```

### How It Works

1. **init.lua** - The entry point
   - Minimal file that just requires `config.lazy`
   - Everything else is modular and separated

2. **config/lazy.lua** - Bootstrap & setup
   - Installs `lazy.nvim` plugin manager if needed
   - Loads configuration files in order
   - Discovers and loads all plugin specs from `plugins/`
   - Sets up lazy-loading behavior and performance optimizations

3. **config/options.lua** - Editor settings
   - Line numbers and indentation
   - Search behavior (case sensitivity)
   - Mouse support
   - Split behavior
   - Undo persistence
   - *Load this early so settings apply before plugins load*

4. **config/keymaps.lua** - Global keybindings
   - Window navigation (`Ctrl+hjkl`)
   - Line moving (`Alt+jk`)
   - Better indentation behavior
   - Terminal escape handling
   - *Loaded after plugins so plugins can extend this*

5. **config/autocmds.lua** - Auto-triggered actions
   - Highlight text when copying (yank)
   - Auto-resize splits
   - Optional: auto-format on save
   - *Loaded after plugins*

6. **plugins/** - Plugin specifications
   - Each file defines one or more related plugins
   - Plugins are lazy-loaded (only load when needed)
   - Easy to enable/disable/customize plugins

## Available Features

**Important: `<leader>` is mapped to `Space`** (the spacebar)
- When you see `<leader>e`, press **Space + e** (two separate key presses)
- This is a **keybinding**, not a command (you don't type `:`)

### File Navigation (Neo-tree & Telescope)

| Feature | Keybinding | Description |
|---------|-----------|-------------|
| Toggle File Explorer | `<leader>e` | Open/close the file tree navigator |
| Reveal Current File | `<leader>o` | Show current file in tree |
| Find Files | `<leader>ff` | Search for files by name |
| Live Grep (Search Text) | `<leader>fg` | Search text content in files |
| Search Buffers | `<leader>fb` | Search open buffers |
| Search Recent Files | `<leader>fr` | Find recently opened files |
| Help Tags | `<leader>fh` | Search help documentation |

### Editor Features

| Feature | Keybinding | Description |
|---------|-----------|-------------|
| Window Navigation | `Ctrl+h/j/k/l` | Move between split windows |
| Move Line Down | `Alt+j` | Move current line down |
| Move Line Up | `Alt+k` | Move current line up |
| Indent Block | `>` (visual) | Indent selection, stay selected |
| Unindent Block | `<` (visual) | Unindent selection, stay selected |
| Clear Search | `Esc` | Remove search highlighting |

### LSP Features (Code Intelligence)

| Feature | Keybinding | Description |
|---------|-----------|-------------|
| Go to Definition | `gd` | Jump to where symbol is defined |
| Hover Documentation | `K` | Show documentation/type info |
| Go to Implementation | `gi` | Jump to implementation |
| Find References | `gr` | Find all uses of symbol |
| Rename Symbol | `<leader>rn` | Rename symbol everywhere |
| Code Actions | `<leader>ca` | Show code actions (fixes, refactor) |
| Show Error | `<leader>e` | Show error details |
| Previous Diagnostic | `[d` | Jump to previous error/warning |
| Next Diagnostic | `]d` | Jump to next error/warning |

### Completion Features

| Feature | Keybinding | Description |
|---------|-----------|-------------|
| Complete | `Ctrl+Space` | Trigger autocompletion menu |
| Next Item | `Tab` | Move to next completion option |
| Previous Item | `Shift+Tab` | Move to previous completion option |
| Confirm | `Enter` | Accept completion |
| Scroll Up | `Ctrl+b` | Scroll completion docs up |
| Scroll Down | `Ctrl+f` | Scroll completion docs down |

## Plugins Included

### Core
- **[lazy.nvim](https://github.com/folke/lazy.nvim)** - Plugin manager with lazy-loading
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)** - Completion engine
- **[LuaSnip](https://github.com/L3MON4D3/LuaSnip)** - Snippet engine
- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)** - LSP configuration
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** - Syntax highlighting
- **[tokyonight.nvim](https://github.com/folke/tokyonight.nvim)** - Color scheme

### Navigation & Discovery
- **[neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)** - File tree explorer
- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)** - Fuzzy finder for files, text, and more
- **[plenary.nvim](https://github.com/nvim-lua/plenary.nvim)** - Common utilities (required by Neo-tree and Telescope)
- **[nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)** - File type icons
- **[nui.nvim](https://github.com/MunifTanjim/nui.nvim)** - UI components (required by Neo-tree)

### Completion Sources
- `cmp-nvim-lsp` - LSP completions (the main source)
- `cmp-buffer` - Buffer word completions
- `cmp-path` - File path completions
- `cmp_luasnip` - Snippet completions

## Customization Guide

### Adding a New Language Server

1. Open `lua/plugins/lsp.lua`
2. Find the commented-out examples (Python, TypeScript, Go)
3. Uncomment and adjust for your language:

```lua
lspconfig.pylsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})
```

4. Install the server via:
   - `:Mason` (interactive UI)
   - Or `:MasonInstall pylsp` (command line)

5. Restart Neovim

### Changing the Color Scheme

1. Open `lua/plugins/theme.lua`
2. Change the plugin and colorscheme command:

```lua
{
  "catppuccin/nvim",  -- Different theme
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd([[colorscheme catppuccin-mocha]])
  end,
}
```

### Adding Keybindings

1. Open `lua/config/keymaps.lua`
2. Add your keybinding using the `map` function:

```lua
-- Toggle something with <leader>t
map("n", "<leader>t", function()
  -- Your code here
end, opts)
```

### Modifying Editor Settings

1. Open `lua/config/options.lua`
2. Add or modify any setting:

```lua
vim.opt.numberwidth = 4  -- Width of line number column
vim.opt.wrap = false     -- Don't wrap long lines
```

### Auto-formatting on Save

1. Open `lua/config/autocmds.lua`
2. Uncomment the `auto_format` autocommand
3. Requires a formatter plugin (consider adding `conform.nvim`)

### Adding a New Plugin

1. Create a new file in `lua/plugins/` (e.g., `lua/plugins/git.lua`)
2. Define your plugin spec:

```lua
return {
  {
    "your/plugin",
    event = "BufReadPre",  -- When to load (optional)
    config = function()
      -- Setup code
    end,
  },
}
```

3. It will auto-load! No need to update any other files.

## Understanding Lazy Loading

Plugins can be loaded in different ways:

- **Not specified** - Load immediately when Neovim starts
- **`event = "InsertEnter"`** - Load when entering insert mode
- **`event = { "BufReadPre", "BufNewFile" }`** - Load when opening a file
- **`lazy = false`** - Always load immediately (used for themes)

This keeps startup fast while ensuring plugins are available when needed.

## Common Issues

### Icons not displaying (iTerm users)

If you're using iTerm and seeing boxes instead of icons in the file tree or completion menus, you need to change the terminal font:

1. Open **iTerm Settings** → **Profiles** → **Text**
2. Change **Font** to **Hack Nerd Font Mono** (or another Nerd Font variant)
3. Restart Neovim

The nvim setup relies on Nerd Font icons from `nvim-web-devicons`. Make sure your terminal font supports these icons.

**Reference:** [vim-devicons issue #226](https://github.com/ryanoasis/vim-devicons/issues/226)

### Colors look wrong

- Ensure your terminal supports true color (24-bit color)
- Set `TERM=xterm-256color` or similar in your shell

### LSP not working

1. Check what language server you need:
   - `:Mason` to browse available servers
   - Look for your language

2. Install it:
   - `:MasonInstall <server-name>`

3. Uncomment the configuration in `lua/plugins/lsp.lua`

4. Restart Neovim (`:quit` and reopen)

### Slow startup

- Check plugin load times: `:Lazy profile`
- Ensure plugins have appropriate `event` or `lazy = true` settings
- Consider lazy-loading heavy plugins

### Completion not working

1. Make sure you're in Insert Mode
2. Try triggering manually: `Ctrl+Space`
3. Check dependencies are installed: `:Lazy`

## Going Further

### Explore More Plugins

Recommended plugins to add:

- **Git Integration** - `gitsigns.nvim` for git diff indicators and blame
- **Status Line** - `lualine.nvim` for better status bar with git and LSP info
- **Which-key** - `which-key.nvim` to show available keybindings on `<leader>`
- **Auto Formatter** - `conform.nvim` for code formatting with multiple formatters
- **Diagnostics** - `trouble.nvim` for better diagnostics list and quickfix

### Learn Neovim

- `:help` - Neovim built-in documentation
- `nvim-lspconfig` [repository](https://github.com/neovim/nvim-lspconfig) - LSP configuration examples
- `lazy.nvim` [documentation](https://github.com/folke/lazy.nvim) - Plugin manager docs

### Next Steps

1. **Try essential commands:**
   - `:help tutor` - Interactive Vim/Neovim tutorial
   - `:help motion` - Learn text navigation
   - `:help commands` - Learn Neovim commands

2. **Customize to your workflow:**
   - Add your preferred plugins
   - Configure language servers for your languages
   - Create custom keybindings

3. **Read other configs:**
   - [LazyVim](https://github.com/LazyVim/LazyVim) - The inspiration for this config
   - [Vim documentation](https://vim.org) - Official Vim reference

## Tips for Beginners

1. **Master basic movement first:**
   - `hjkl` - Move cursor
   - `w/b` - Move by word
   - `^/$` - Start/end of line
   - `gg/G` - Start/end of file

2. **Learn the modes:**
   - Normal mode - Navigation and editing
   - Insert mode - Typing text (press `i`)
   - Visual mode - Selecting text (press `v`)
   - Command mode - Running commands (press `:`)
   - Use `Esc` to return to Normal mode

3. **Use the leader key:**
   - Leader is mapped to `<Space>`
   - `<leader>rn` to rename, `<leader>ca` for code actions
   - Explore available options with `:Lazy` and plugin docs

4. **Don't memorize everything:**
   - Vim is about muscle memory, learn gradually
   - Start with basic motions and expand your knowledge
   - Use `:help` liberally

## Architecture Notes

This configuration follows LazyVim's philosophy:

- **Minimal core** - Only essential configs and plugins
- **Modular** - Easy to understand and customize each part
- **Lazy-loaded** - Fast startup through lazy plugin loading
- **Extensible** - Add plugins by just creating new files

The structure makes it easy to:
- Find what you're looking for (organized by function)
- Disable features (just remove the line)
- Understand the configuration (each file is focused)
- Share knowledge (send specific config files to others)

## License

This configuration is inspired by and follows the conventions of [LazyVim](https://www.lazyvim.org/).
