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

# Panes
Ctrl+B %                # Split vertically
Ctrl+B "                # Split horizontally
Ctrl+B x                # Kill pane
```

Use `Ctrl+B arrow keys` to move between panes.
