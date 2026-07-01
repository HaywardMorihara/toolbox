# Git Worktrees

Check out multiple branches of the same repo simultaneously in different directories — no stashing or switching needed. Worktrees share the same `.git` store but have independent working directories and `HEAD`.

## Essential Commands

```bash
# Create
git worktree add ../my-other-dir existing-branch
git worktree add -b new-branch ../my-other-dir main   # create branch too

# List / remove
git worktree list
git worktree remove ../my-other-dir
git worktree remove --force ../my-other-dir            # has uncommitted changes
git worktree prune                                     # clean up if dir was deleted manually
```

The same branch cannot be checked out in two worktrees simultaneously.
