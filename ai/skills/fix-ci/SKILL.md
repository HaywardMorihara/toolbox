---
name: fix-ci
description: Diagnose why a PR's CI checks are failing. Use when the user asks why CI is failing, what checks are broken, or wants to debug PR check failures.
---

# Fix CI

Get detailed failure reasons for a PR's CI checks using the GitHub Check Runs API.

## Steps

### 1. Get the PR's remote head SHA

```bash
gh pr view <pr-number> --json headRefOid --jq '.headRefOid'
```

Use the PR number from `gh pr view` if not provided.

### 2. Query failed check runs with diagnostic output

```bash
gh api "repos/{owner}/{repo}/commits/{sha}/check-runs" \
  --jq '.check_runs[] | select(.conclusion == "failure") | {name, output_title: .output.title, output_summary: .output.summary}'
```

The `output_summary` field contains the actual failure details (e.g., which lint jobs failed, which OWNERS approvals are missing).

### 3. Report findings

Summarize each failed check with its name, cause, and whether it requires a code fix or just a review approval.
