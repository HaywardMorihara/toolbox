# Claude Code

## Resources
- [Dashboard](https://platform.claude.com/dashboard)
- [Documentation](https://docs.claude.com/en/home)
- [Prompt Library](https://docs.claude.com/en/resources/prompt-library/library)
- [Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Prompt Engineering Guide](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)

## Workshop Notes
[AI Workshop: Deep Dive into Anthropic's Claude Code - 2025/10/16](https://drive.google.com/file/d/1bsHBx2-vp9RwkhmQRtXs2IXbdY8btncL/view)

### Key Features & Commands
- **`/init`** - Creates `CLAUDE.md` for repo context (can be local or in `~/.claude/CLAUDE.md`)
- **Memory** - `#` to commit to memory (which is `CLAUDE.md`). Tell Claude to remember things (user or project memory)
- **`/context`** - Show context usage; `/clear` to clear
- **Plan Mode** - `Shift+Tab` for planning (can export to file)
- **Models** - Haiku (workhorse), Opus (planning, expensive)
- **Terminal** - `/terminal-setup`, `/config`, `/permissions`
- **Navigation** - `/vim`, `/ide`, `/compact` (automatic)
- **Resume** - `--resume` or `claude --resume` to continue sessions
- **Rewind** - `Esc + Esc` to go back
- **Custom Slash Commands** - `.claude/commands/<command>.md` (with arguments)
- **Skills** - Well-tuned prompts for specific workflows. For building them, tell them ("Read this. Think about it. Write down the new stuff you learned.")
- **Subagents** - `/agents` ([Docs](https://docs.claude.com/en/docs/claude-code/sub-agents)), saved to `.claude/agents/`
- **Plugins** - Share agents, hooks, MCPs across teams ([Docs](https://docs.claude.com/en/docs/claude-code/plugins))
- **Hooks** - Before/after command execution (bash commands)
- **MCP Servers** - Extensions like tools; `mcp add <server-name>` (config: `.mcp.json`)
  - SQL MCPs available
  - Can run locally (e.g., Puppeteer for screenshots)
- `Ctrl+t` - show the tasks the agent is executing
- `Ctrl+Shift+G` - switch to the full-screen vim editor

### Tips
- Tell Claude the document structure you want (or provide template)
- Give it tools/commands to test what it's doing
- Use for search tasks
- Read files from the internet
- Provide images for analysis

### Tools
- [SuperPowers](https://github.com/obra/superpowers) (kinda like Skills?)
