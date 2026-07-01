# tmux Quick Start

**Prefix key:** `Ctrl+B` (press, release, then next key)

**Mac:** for `Opt`/`Alt` (Meta) bindings to work, enable Option as Meta — iTerm2: Preferences → Profiles → Keys → Left Option = **Esc+**; Terminal.app: Preferences → Profiles → Keyboard → **Use Option as Meta key**.

## Essential Commands

```bash
# Start/attach sessions
tmux new-session -s myname
tmux attach -t myname
tmux list-sessions
Ctrl+B $                # Rename session
Ctrl+B s                # Interactive session switcher
Ctrl+B (                # Previous session
Ctrl+B d                # detach from the session
tmux kill-session -t session-name

# Windows
Ctrl+B c                # Create window
Ctrl+B ,                # Rename window
Ctrl+B w                # List windows
Ctrl+B n                # Next window
Ctrl+B 0                # Swtich to index 0 window
Ctrl+B &                # Delete window

# Panes
Ctrl+B %                # Split vertically
Ctrl+B "                # Split horizontally
Ctrl+B x                # Kill pane
:resize-pane -R 5       # Resize right by 5 columns
:resize-pane -x 80      # Set absolute width to 80 columns 
Ctrl+B Space            # Different layout
Ctrl+B Opt+1            # Rebalance side-by-side panes to even width (Mac: Option key)
Ctrl+B { (or })         # Swap panes

# Copy mode
Ctrl+B [                # Enter Copy mode
(Space)                 # Start highlighting
Enter                   # Copy
```

Use `Ctrl+B arrow keys` to move between panes.
