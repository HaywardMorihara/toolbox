---
name: gh-pr-comments
description: Query GitHub pull requests for all comments (general + inline code comments) using gh CLI
user-invocable: true
argument-hint: "[owner/repo] [pr-number]"
---

# GitHub PR Comments Skill

Query GitHub pull requests for all comments including both general PR comments and inline code-level comments on specific lines.

## When to Use This Skill

Use this skill when you need to:
- Review all feedback on a pull request before marking it ready
- Check for code-level inline comments that are easy to miss
- Address both general PR discussion and specific line comments
- Gather complete PR context before implementing changes

## Key Commands

### View PR Summary (including general comments)

```bash
gh pr view <number> --repo owner/repo
```

This shows:
- PR title, description, status
- General discussion comments on the PR itself

### View Inline Code Comments (most important!)

```bash
gh api repos/owner/repo/pulls/<number>/comments
```

This retrieves all review comments left on **specific lines of code**, formatted as JSON.

**Why this matters**: Inline comments are easy to miss because they're not visible in the main PR view. They're critical feedback that must be addressed.

### Full Workflow Example

```bash
# 1. View the PR and general comments
gh pr view 123 --repo myorg/myrepo

# 2. Get inline code comments
gh api repos/myorg/myrepo/pulls/123/comments | jq '.[] | {user: .user.login, path: .path, line: .line, body: .body}'

# 3. Alternative: Get all PR reviews (which may contain inline comments)
gh pr review-status 123 --repo myorg/myrepo
```

## Important Notes

- **Inline comments** are the hardest feedback to spot but most critical to address
- Always check both the PR view (general comments) AND the comments API (inline comments)
- Use `jq` to parse JSON when needed for readable output
- The comments API includes both review comments and conversation comments

## Field Explanation (from API response)

When examining inline comments:
- `user.login` - Who made the comment
- `path` - Which file the comment is on
- `line` - Which line number
- `body` - The comment text
- `state` - For review comments: "COMMENTED", "APPROVED", or "CHANGES_REQUESTED"

## Useful Filters

Get only changes-requested reviews:
```bash
gh api repos/owner/repo/pulls/<number>/reviews | jq '.[] | select(.state == "CHANGES_REQUESTED")'
```

Get comments on a specific file:
```bash
gh api repos/owner/repo/pulls/<number>/comments | jq '.[] | select(.path == "src/app.js")'
```
