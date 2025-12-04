# VI / VIM Cheat Sheet

_Note: `vim` is feature-rich, backwards-compatible version of `vi`_

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
| `Ctrl+d` | Go down a bunch of lines |
| `Ctrl+u` | Go up a bunch of lines |

## EDITING (NORMAL MODE)

| Command | Description |
|---------|-------------|
| `x` | Delete character under cursor |
| `dd` | Delete entire line |
| `dw` | Delete word |
| `d$` | Delete to end of line |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `yy` | Copy entire line |
| `yw` | Copy word |
| `"+y` | Copy to clipboard |
| `p` | Paste after cursor |
| `P` | Paste before cursor |
| `r{char}` | Replace character with {char} |
| `~` | Toggle case of character |

## SEARCHING & REPLACING (NORMAL MODE)

| Command | Description |
|---------|-------------|
| `/{pattern}` | Search forward for pattern |
| `?{pattern}` | Search backward for pattern |
| `n` | Repeat search forward |
| `N` | Repeat search backward |
| `:%s/old/new/g` | Replace all 'old' with 'new' in file |

## SAVING & EXITING

| Command | Description |
|---------|-------------|
| `:w` | Save file |
| `:q` | Quit (no unsaved changes) |
| `:q!` | Quit without saving |
| `:wq` | Save and quit |
| `ZZ` | Save and quit (shortcut) |

## VISUAL MODE

| Command | Description |
|---------|-------------|
| `v` | Enter visual mode (character selection) |
| `V` | Enter visual line mode (line selection) |
| `Ctrl+v` | Enter visual block mode |
| `y` | Copy selected text |
| `p` | Paste after cursor |
| `P` | Paste before cursor |

## USEFUL NORMAL MODE COMMANDS

| Command | Description |
|---------|-------------|
| `.` | Repeat last command |
| `J` | Join lines |
| `>` | Indent line |
| `<` | Unindent line |
| `:%!sort` | Sort all lines |
| `:set number` | Show line numbers |
| `:set nonumber` | Hide line numbers |

## CLIPBOARD

- `"+y` - Yank to clipboard register
