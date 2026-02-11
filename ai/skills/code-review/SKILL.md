# Code Review Skill

Analyzes recent code changes and suggests refactoring opportunities.

## When to Use This Skill

Use this skill after making code changes to get structured feedback on:
- Opportunities to simplify logic
- Better naming or organization
- Potential bugs or edge cases
- Code duplication or patterns that could be abstracted
- Performance improvements
- Testing gaps

## How to Invoke

```
/code-review
```

## What It Does

1. Reviews recent code changes (from git diff or modified files)
2. Identifies specific refactoring opportunities
3. Explains the rationale for each suggestion
4. Provides concrete examples of improvements
5. Prioritizes suggestions by impact

## Example Output

- Simplify conditional logic with early returns
- Extract common pattern into helper function
- Rename variable for clarity
- Add missing error handling
- Split large function into smaller ones
