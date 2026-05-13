# tmux Quick Start

**Prefix key:** `Ctrl+B` (press, release, then next key)

## Essential Commands

```bash
# Start/attach sessions
tmux new-session -s myname
tmux attach -t myname
tmux list-sessions

# Detach from session
Ctrl+B d

# Windows
Ctrl+B c                # Create window
Ctrl+B ,                # Rename window

# Panes
Ctrl+B %                # Split vertically
Ctrl+B "                # Split horizontally
Ctrl+B x                # Kill pane
:resize-pane -R 5       # Resize right by 5 columns
:resize-pane -x 80      # Set absolute width to 80 columns 
Ctrl+B Space            # Different layout
Ctrl+B { (or })         # Swap panes
```

Use `Ctrl+B arrow keys` to move between panes.
