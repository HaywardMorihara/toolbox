# Private Commands

This directory is for **local-only custom commands** that you don't want to commit to the repository. Perfect for work-specific shortcuts, personal aliases, or commands with sensitive paths.

## Features

- **Git-ignored**: Everything in this directory is automatically excluded from version control
- **Auto-loaded**: All `.sh` files in this directory are automatically sourced when your shell starts
- **Isolated**: Keep work-specific commands separate from the shared toolbox

## Usage

1. Create a `.sh` file in this directory (e.g., `commands.sh`, `work.sh`, etc.)
2. Add your custom shell functions or aliases
3. Reload your shell with `refresh` or open a new terminal

## Example

Create `private/commands.sh`:

```bash
# Navigate to your work project
myproject() {
  cd ~/work/myproject || return
}

# Quick SSH to your dev server
devssh() {
  ssh user@dev-server.example.com
}

# Custom git aliases specific to your workflow
gwip() {
  git add -A && git commit -m "WIP: checkpoint"
}
```

After creating the file, run `refresh` and your commands will be available!

## Tips

- Use descriptive function names to avoid conflicts
- Keep sensitive information (API keys, passwords) in environment variables, not here
- You can organize commands across multiple `.sh` files if you prefer
- These commands work exactly like the built-in toolbox commands

## Need Help?

Check the main README for more information about the toolbox system.
