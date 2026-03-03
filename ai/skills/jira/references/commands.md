# Commands Reference

Complete reference for `acli jira workitem` (Atlassian CLI).

**Note:** This guide uses environment variables for portability. Set these in `private/jira.sh` (see SKILL.md Setup section):
- `JIRA_PROJECT` — Your project ID (e.g., "PROJ")
- `JIRA_SITE` — Your Atlassian domain (e.g., "yourcompany.atlassian.net")
- `JIRA_USER` — Your Atlassian account email

---

## Viewing Issues

```bash
# View single issue (default fields: key, issuetype, summary, status, assignee, description)
acli jira workitem view KEY

# View with specific fields (comma-separated, no spaces)
acli jira workitem view KEY --fields summary,status

# View specific fields including description
acli jira workitem view KEY --fields summary,description,status

# Raw JSON output
acli jira workitem view KEY --json

# View all fields
acli jira workitem view KEY --fields '*all'

# View navigable fields only
acli jira workitem view KEY --fields '*navigable'

# View all except a specific field
acli jira workitem view KEY --fields '*navigable,-comment'

# Open in web browser
acli jira workitem view KEY --web
```

---

## Creating Issues

```bash
# Create with summary (interactive for other fields)
acli jira workitem create --project "$JIRA_PROJECT" --summary "Login button not working"

# Create with summary, type, and description
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Story \
  --summary "Login button not working" \
  --description "Users cannot click the login button on Safari"

# Create as a Bug
acli jira workitem create --project "$JIRA_PROJECT" --type Bug --summary "Login fails on Safari"

# Create as a Task
acli jira workitem create --project "$JIRA_PROJECT" --type Task --summary "Update documentation"

# Create with assignee (use email or @me for self-assign)
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Story \
  --summary "..." \
  --assignee "user@example.com"

# Self-assign
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Story \
  --summary "..." \
  --assignee "@me"

# Create with labels
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Bug \
  --summary "..." \
  --label "bug,urgent"

# Create with description from file
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Story \
  --summary "..." \
  --description-file "description.txt"

# Open editor for summary and description
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Story \
  --editor

# Create from JSON file
acli jira workitem create --project "$JIRA_PROJECT" --from-json "workitem.json"

# Generate JSON template
acli jira workitem create --generate-json

# Create via REST API v2 (when custom fields are required)
curl -X POST \
  -u "$JIRA_USER:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": { "key": "'$JIRA_PROJECT'" },
      "summary": "Task summary",
      "description": "Task description",
      "issuetype": { "name": "Task" },
      "parent": { "key": "ID-14004" },
      "customfield_10200": "team-uuid-here",
      "labels": ["label1", "label2"]
    }
  }' \
  "https://$JIRA_SITE/rest/api/2/issue"
```

---

## Searching Issues

```bash
# Basic search with JQL
acli jira workitem search --jql "project = \"$JIRA_PROJECT\""

# Search for my issues
acli jira workitem search --jql "assignee = currentUser()"

# Search by status
acli jira workitem search --jql "project = \"$JIRA_PROJECT\" AND status = 'In Progress'"

# Search by type
acli jira workitem search --jql "project = \"$JIRA_PROJECT\" AND type = Story"

# Combined search
acli jira workitem search --jql "project = \"$JIRA_PROJECT\" AND status = 'To Do' AND type = Bug"

# Search by created date (past 7 days)
acli jira workitem search --jql "created >= -7d"

# Search by text in summary
acli jira workitem search --jql "summary ~ 'login' AND project = \"$JIRA_PROJECT\""

# Limit number of results
acli jira workitem search --jql "assignee = currentUser()" --limit 10

# Get count of results
acli jira workitem search --jql "project = \"$JIRA_PROJECT\"" --count

# Get all results with pagination
acli jira workitem search --jql "project = \"$JIRA_PROJECT\"" --paginate

# Output as CSV
acli jira workitem search --jql "project = \"$JIRA_PROJECT\"" --csv

# Output as JSON
acli jira workitem search --jql "project = \"$JIRA_PROJECT\"" --json

# Search with specific fields
acli jira workitem search --jql "project = \"$JIRA_PROJECT\"" --fields "key,summary,status,assignee"

# Search using filter ID
acli jira workitem search --filter 10001

# Open search results in web browser
acli jira workitem search --jql "project = \"$JIRA_PROJECT\"" --web
```

---

## Transitioning Issues

```bash
# Transition a single work item to a new status
acli jira workitem transition --key "KEY-123" --status "In Progress"
acli jira workitem transition --key "KEY-123" --status "Done"

# Transition multiple work items
acli jira workitem transition --key "KEY-1,KEY-2,KEY-3" --status "Done"

# Transition with JQL query
acli jira workitem transition --jql "project = TEAM AND status = 'To Do'" --status "In Progress"

# Transition using filter ID
acli jira workitem transition --filter 10001 --status "Done"

# Transition without confirmation prompt
acli jira workitem transition --key "KEY-123" --status "Done" --yes

# Output as JSON
acli jira workitem transition --key "KEY-123" --status "Done" --json

# Ignore errors when transitioning multiple items
acli jira workitem transition --jql "project = TEAM" --status "Done" --ignore-errors
```

---

## Adding Comments

```bash
# Add comment to a single work item
acli jira workitem comment create --key "KEY-123" --body "This is my comment"

# Add comment from a file
acli jira workitem comment create --key "KEY-123" --body-file "comment.txt"

# Comment on multiple work items via JQL
acli jira workitem comment create --jql "project = PROJECT" --body "Comment on all matching items"

# Open editor to write comment
acli jira workitem comment create --key "KEY-123" --editor

# List comments on a work item
acli jira workitem comment list KEY-123
```

---

## Other Operations

```bash
# View issue in web browser
acli jira workitem view KEY --web

# Get issue info in JSON
acli jira workitem view KEY --json

# List projects
acli jira project list

# List boards
acli jira board list

# Get current user info
acli jira user current
```

---

## Common JQL Patterns

```bash
# Current user
assignee = currentUser()
reporter = currentUser()

# Status filters
status = "In Progress"
status in ("To Do", "In Progress")
status != Done

# Type filters
type = Story
type in (Bug, Task)

# Project filter
project = "$JIRA_PROJECT"

# Date filters
created >= -7d
updated >= -24h

# Custom fields (if available)
customfield_10000 = "value"

# Combine filters
assignee = currentUser() AND status = "In Progress" AND type = Bug
```

---

## Special Characters in JQL

When JQL contains spaces or special characters, use quotes:

```bash
acli jira workitem search --jql "status = 'In Progress'"
acli jira workitem search --jql "summary ~ 'login error'"
```

---

## Error Handling

**Authentication error:**

See "Troubleshooting Authentication" in SKILL.md. To re-authenticate:
```bash
cat ~/.config/toolbox/jira-token.txt | acli jira auth login -e "$JIRA_USER" -s "$JIRA_SITE" --token
```

**Issue not found:**
- Verify the issue key is correct
- Confirm you have permission to view it
- Check the project exists

**Invalid transition:**
- Run `acli jira workitem transition KEY` to see available states
- The current status may not allow transition to target state
- Some workflows require intermediate states

---

## Help

```bash
acli jira workitem --help
acli jira workitem create --help
acli jira workitem search --help
```
