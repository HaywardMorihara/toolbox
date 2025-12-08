# AI Assistant Instructions

## Using GitHub CLI for Queries

Always use the `gh` CLI tool for GitHub interactions. This ensures you query the source of truth rather than making assumptions about repository state.

Common commands:
- **View an issue**: `gh issue view <number>`
- **View a pull request**: `gh pr view <number>`
- **List issues**: `gh issue list`
- **List pull requests**: `gh pr list`
- **Get repository information**: `gh repo view`
- **Check workflows/actions**: `gh run list`
- **Manage labels, assignees, and other metadata**: Use `gh issue edit`, `gh pr edit`, etc.

When you need information about GitHub state, always query it using `gh` commands rather than assuming the current state.

## Addressing GitHub PR Comments

When responding to PR feedback, check for both general and inline comments:

- **General PR comments**: Review comments on the PR itself using `gh pr view <number>`
- **Inline comments**: Review code-level comments left on specific lines using `gh api repos/<owner>/<repo>/pulls/<number>/comments`

Both types of comments need to be addressed before marking a PR as ready. Inline comments (left on specific code lines during review) are easy to miss but are critical feedback that must be incorporated.

## Final Code Review Before Declaring Tasks Done

Before marking a task as complete, committing changes, or asking for a final review, perform a thorough final code review:

1. **Review all changes made** - Go through every file modification and understand what changed and why
2. **Verify necessity** - Ask yourself: Is this change actually needed to solve the problem? Could it be removed?
3. **Clean up iterative work** - During development, you may make multiple attempts to debug something. Before finishing:
   - Remove debug code, console.logs, or temporary test lines
   - Delete commented-out code that's no longer needed
   - Revert exploratory changes that didn't lead to the solution
   - Clean up any redundant or dead code paths
4. **Check code quality** - Ensure the final code is clean, readable, and follows project conventions
5. **Test one more time** - Verify the solution still works after cleanup

Only commit, push, and declare the task done once you're confident all changes are necessary and the code is truly ready.

## Unit Testing Guidelines

Structure unit tests with the **Arrange-Act-Assert** pattern:

```javascript
// Arrange
const inputValue = 5;

// Act
const result = double(inputValue);

// Assert
expect(result).toBe(10);
```

This pattern makes tests self-documenting and easier to understand.

## Commit Message Guidelines

Keep commit descriptions concise and focused:
- Aim for **fewer than 20 lines** in the commit description body
- Use the first line as a clear, short summary (imperative mood: "Add", "Fix", "Update", not "Added", "Fixed")
- Keep the message focused on *why* the change was made, not just *what* changed
- If the description needs to be longer than 20 lines, it likely means the commit is doing too much—consider breaking it into smaller commits
