# Git Worktrees Cheatsheet

## Create Worktrees

```bash
git worktree add ../toolbox-agent1 -b feature/agent-1-task
git worktree add ../toolbox-agent2 -b feature/agent-2-task
```

## List Worktrees

```bash
git worktree list
```

## Clean Up Worktrees

```bash
git worktree remove ../toolbox-agent1
git worktree remove ../toolbox-agent2
```

## Key Points

- Each worktree is an **isolated directory** with checked-out files on a different branch
- Agents can work **in parallel** without interfering with each other
- Worktrees **share git history** - no duplication of commits
- Always use `git worktree remove` to clean up (not `rm`)
