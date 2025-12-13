# Neovim Cheat Sheet

_Neovim is a modern, extensible version of Vim focused on usability and extensibility._

## KEY CONCEPT: Leader Key

**`<leader>` is mapped to `Space`** (the spacebar)
- When you see `<leader>e`, press **Space + e** (two separate key presses, not a command)
- All keybindings in this config that start with `<leader>` use Space as the prefix

## BASICS

| Command | Description |
|---------|-------------|
| `nvim <file>` | Open file in Neovim |
| `nvim .` | Open current directory |
| `:help <topic>` | Open help documentation |
| `:help index` | List of all default keybindings |
| `:q` | Quit (no unsaved changes) |
| `:q!` | Quit without saving |
| `:w` | Save file |
| `:wq` or `ZZ` | Save and quit |

## NAVIGATION (NORMAL MODE)

| Command | Description |
|---------|-------------|
| `h, j, k, l` | Move left, down, up, right |
| `w` | Jump to next word |
| `b` | Jump to previous word |
| `e` | Jump to end of word |
| `gg` | Go to start of file |
| `G` | Go to end of file |
| `:N` | Go to line N |
| `0` | Go to start of line |
| `$` | Go to end of line |
| `Ctrl+f` | Go down a page |
| `Ctrl+b` | Go up a page |
| `Ctrl+d` | Go down half a page |
| `Ctrl+u` | Go up half a page |
| `Ctrl+h/j/k/l` | Move between splits (custom) |

## EDITING (NORMAL MODE)

| Command | Description |
|---------|-------------|
| `i` | Enter insert mode before cursor |
| `a` | Enter insert mode after cursor |
| `A` | Enter insert mode at end of line |
| `I` | Enter insert mode at start of line |
| `o` | Create new line below and insert |
| `O` | Create new line above and insert |
| `x` | Delete character under cursor |
| `dd` | Delete entire line |
| `dw` | Delete word |
| `d$` | Delete to end of line |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `yy` | Copy entire line |
| `yw` | Copy word |
| `p` | Paste after cursor |
| `P` | Paste before cursor |
| `r{char}` | Replace character with {char} |
| `>` | Indent line (visual mode) |
| `<` | Unindent line (visual mode) |
| `J` | Join lines |

## SEARCHING & FINDING

### Find Within File
| Command | Description |
|---------|-------------|
| `/{pattern}` | Search forward for pattern |
| `?{pattern}` | Search backward for pattern |
| `n` | Repeat search forward |
| `N` | Repeat search backward |
| `*` | Find word under cursor (forward) |
| `#` | Find word under cursor (backward) |

### Replace Within File
| Command | Description |
|---------|-------------|
| `:%s/old/new/g` | Replace all 'old' with 'new' in file |
| `:s/old/new/g` | Replace in current line |
| `:%s/old/new/gc` | Replace all with confirmation |

### Find & Search Across Files (Telescope)

Telescope is installed and provides powerful fuzzy finding:

| Command | Keybinding | Description |
|---------|-----------|-------------|
| Find Files | `<leader>ff` | Search for files by name |
| Live Grep | `<leader>fg` | Search text content in files |
| Search Buffers | `<leader>fb` | Search open buffers |
| Recent Files | `<leader>fr` | Find recently opened files |
| Help Tags | `<leader>fh` | Search help documentation |
| Word Under Cursor | `<leader>fw` | Search for word under cursor |

**In Telescope:**
- `Ctrl+j/k` - Move up/down in results
- `Enter` - Open selection
- `Ctrl+v` - Open in vertical split
- `Ctrl+x` - Open in horizontal split
- `Ctrl+q` - Send to quicklist
- `Esc` - Close Telescope
- Type to filter results (live as you type)

## VISUAL MODE

| Command | Description |
|---------|-------------|
| `v` | Enter visual mode (character selection) |
| `V` | Enter visual line mode (line selection) |
| `Ctrl+v` | Enter visual block mode |
| `y` | Copy selected text |
| `p` | Paste after cursor |
| `P` | Paste before cursor |
| `d` | Delete selected text |
| `>` | Indent selection |
| `<` | Unindent selection |

## FILE TREE / DIRECTORY NAVIGATOR (Neo-tree)

Neo-tree is installed and provides a full-featured file explorer:

### File Explorer Commands
| Command | Description |
|---------|-------------|
| `<leader>e` | Toggle file explorer |
| `<leader>o` | Reveal current file in tree |

### Navigation in File Tree
Once in the file tree:
- `j/k` - Move up/down in tree
- `o` or `Enter` - Open file/folder
- `a` - Create new file
- `d` - Delete file
- `r` - Rename file
- `Ctrl+]` - Open in split
- `Ctrl+v` - Open in vertical split
- `Ctrl+x` - Open in horizontal split
- `.` - Toggle hidden files
- `?` - Show help

### Switching Between File Tree and Editor
- `Ctrl+h` - Move cursor to file tree (from editor)
- `Ctrl+l` - Move cursor to editor (from file tree)
- `<leader>e` - Toggle file tree closed/open

## MODES

| Mode | Enter | Exit |
|------|-------|------|
| Insert | `i`, `a`, `o`, etc. | `Esc` |
| Visual | `v` | `Esc` |
| Visual Line | `V` | `Esc` |
| Visual Block | `Ctrl+v` | `Esc` |
| Command | `:` | `Esc` or `Enter` |

## USEFUL COMMANDS

| Command | Description |
|---------|-------------|
| `.` | Repeat last command |
| `;` | Repeat last f/t motion |
| `Ctrl+a` | Increment number under cursor |
| `Ctrl+x` | Decrement number under cursor |
| `<leader>e` | Toggle file explorer (Neo-tree) |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Search text in files (Telescope) |
| `gd` | Go to definition (requires LSP) |
| `K` | Hover documentation (requires LSP) |
| `gr` | Find references (requires LSP) |
| `<leader>rn` | Rename symbol (requires LSP) |
| `<leader>ca` | Code actions (requires LSP) |
| `Ctrl+Space` | Trigger autocompletion |
| `Tab` | Next completion item |
| `Shift+Tab` | Previous completion item |
| `Enter` | Accept completion |

## WINDOWS / SPLITS

| Command | Description |
|---------|-------------|
| `:split` | Horizontal split |
| `:vsplit` | Vertical split |
| `Ctrl+h/j/k/l` | Navigate between splits |
| `Ctrl+w+o` | Close all other splits |
| `Ctrl+w+=` | Equalize split sizes |
| `:only` | Close all other windows |

## BUFFERS

| Command | Description |
|---------|-------------|
| `:e <file>` | Open file in buffer |
| `:b N` | Switch to buffer N |
| `:bn` | Next buffer |
| `:bp` | Previous buffer |
| `:bd` | Delete (close) buffer |
| `:ls` | List all buffers |

## TABS

| Command | Description |
|---------|-------------|
| `:tabnew` | Create new tab |
| `:tabnext` or `gt` | Go to next tab |
| `:tabprevious` or `gT` | Go to previous tab |
| `:tabclose` | Close current tab |

## CONFIGURATION & CUSTOMIZATION

Your config is located in: `~/.config/nvim/`

### File Locations
| File | Purpose |
|------|---------|
| `init.lua` | Entry point |
| `lua/config/options.lua` | Editor settings |
| `lua/config/keymaps.lua` | Keybindings |
| `lua/config/lazy.lua` | Plugin manager setup |
| `lua/plugins/*.lua` | Plugin configurations |

### Add Custom Keybinding
Edit `lua/config/keymaps.lua` and add:
```lua
map("n", "<leader>x", function()
  -- Your code here
end, opts)
```

### Install Language Server
- Run `:Mason` for interactive UI
- Or `:MasonInstall lua_ls` for CLI
- Then uncomment server in `lua/plugins/lsp.lua`

### Add a Plugin
Create `lua/plugins/myfeature.lua`:
```lua
return {
  {
    "user/plugin-name",
    config = function()
      -- Setup code
    end,
  },
}
```

## TIPS FOR BEGINNERS

1. **Focus on basic movement first** - Master `hjkl`, `w`, `b`, `^`, `$`
2. **Combine commands** - `d2w` deletes 2 words, `3j` moves down 3 lines
3. **Use counts** - `5dd` deletes 5 lines
4. **Learn one thing at a time** - Don't memorize everything
5. **Use `:help`** - Neovim has excellent documentation
6. **Customize gradually** - Add keybindings as needed
7. **Practice motions** - Get comfortable with navigation before adding plugins

## USEFUL RESOURCES

- `:help tutor` - Interactive tutorial within Neovim
- `:help motion` - Motion documentation
- `:help user-manual` - Complete Neovim manual
- [Neovim Documentation](https://neovim.io/doc/user/)
- [Our Neovim Config README](../dotfiles/nvim/README.md) - Local documentation

## COMMON ISSUES

**Colors look wrong**
- Check terminal supports true color: `echo $TERM`
- Set in shell: `export TERM=xterm-256color`

**LSP not working**
- Install server: `:Mason`
- Uncomment in `lua/plugins/lsp.lua`
- Restart Neovim

**Slow performance**
- Check plugin load times: `:Lazy profile`
- Ensure plugins have `event` or `lazy = true` set
