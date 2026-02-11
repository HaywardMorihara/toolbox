---
name: final-review
description: Comprehensive code review checklist before completing tasks and committing changes
user-invocable: true
---

# Final Code Review Skill

Before marking a task as complete, committing changes, or asking for a final review, perform a thorough final code review using this checklist.

## When to Use This Skill

Invoke `/final-review` when you are about to:
- Mark a task as completed
- Commit changes to the repository
- Push to the remote repository
- Request final review from a user

This skill ensures all changes are necessary, documentation is updated, and code is production-ready.

## Final Code Review Checklist

### 1. Update Documentation First

Before anything else, ensure documentation reflects your changes:

- **Update README files** if adding, removing, or changing features
- **Update inline documentation and docstrings** when modifying function signatures or behavior
- **Update configuration examples** if changing config options
- **Update any guides or tutorials** affected by the changes

Documentation should be updated as part of the same task, not deferred to a separate effort. This is the highest priority.

### 2. Review All Changes Made

Go through every file modification and understand:
- What changed and why
- Whether the change directly addresses the problem statement
- Whether the change follows project conventions and patterns

### 3. Verify Necessity

Ask yourself for each change:
- Is this change actually needed to solve the problem?
- Could it be removed?
- Is this within the scope of the task?

Avoid scope creep and over-engineering. Only make changes that are directly requested or clearly necessary.

### 4. Clean Up Iterative Work

During development, you may make multiple attempts to debug something. Before finishing:

- Remove debug code, console.logs, or temporary test lines
- Delete commented-out code that's no longer needed
- Revert exploratory changes that didn't lead to the solution
- Clean up any redundant or dead code paths

Do NOT leave temporary work in the final commit.

### 5. Check Code Quality

Ensure the final code is:
- Clean and readable
- Follows project conventions and patterns
- Uses appropriate naming
- Has necessary comments (focused on "why" not "what")
- Avoids over-engineering and premature abstractions

### 6. Test One More Time

Verify the solution still works after cleanup:
- Run relevant tests
- Manually test the feature or bug fix
- Confirm no regressions were introduced

## Important Notes

- **Documentation comes first** - Don't clean up code before updating docs
- **Only necessary changes** - Avoid the temptation to refactor surrounding code or add "improvements" beyond the task scope
- **Completeness** - All changes must be necessary, documentation must be updated, and code must be production-ready before committing
- **Trust internal code** - Don't add defensive error handling for scenarios that can't happen based on internal guarantees; only validate at system boundaries (user input, external APIs)

## After This Review

Once you've completed all 6 steps:
1. Create a commit with a clear, focused message
2. Push to the remote if requested
3. Mark the task as complete
4. Request final review if needed

You can now confidently declare the task done.
