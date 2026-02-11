# AI Assistant Instructions

## GitHub CLI and Pull Requests

Use the `/gh-pr-comments` skill to:
- Query GitHub state using the `gh` CLI (ensures source of truth, not assumptions)
- Review all PR feedback including general comments and inline code comments
- Understand common GitHub CLI commands for issues, PRs, and workflows

Invoke with `/gh-pr-comments` when you need to gather complete PR context or check for feedback before marking PRs as ready.

## Final Code Review

Use the `/final-review` skill before completing tasks and committing changes. It provides a comprehensive 6-step checklist ensuring:
- Documentation is updated first
- All changes are necessary and within scope
- Iterative/debug code is cleaned up
- Code quality standards are met
- Changes are tested one final time

Invoke with `/final-review` when you're about to mark a task as complete.

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

## Comment Writing Guidelines

Write comments that explain **why** code exists, not **what** it does:
- Avoid low-value comments that merely restate the code (e.g., `// set x to 5` above `x = 5`)
- Focus on:
  - Non-obvious logic or decisions
  - Edge cases and gotchas
  - Workarounds and why they're necessary
  - Complex algorithms or interactions
  - Important context that isn't immediately clear from code

This keeps comments valuable and reduces noise in the codebase.
