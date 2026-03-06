---
name: jira
description: Use when the user mentions Jira issues (e.g., "PROJ-123"), asks about tickets, wants to create/view/update issues, check sprint status, or manage their Jira workflow. Triggers on keywords like "jira", "issue", "ticket", "sprint", "backlog", or issue key patterns.
---

# Jira

Natural language interaction with Jira using `acli jira workitem` (Atlassian CLI).

---

## Quick Reference

| Intent | Command |
|--------|---------|
| View issue | `acli jira workitem view KEY` |
| View with specific fields | `acli jira workitem view KEY --fields summary,status` |
| Create issue | `bash ai/skills/jira/scripts/jira-create-ticket.sh --project "$JIRA_PROJECT" --type Story --summary "..."` |
| Search issues | `acli jira workitem search --jql "..."` |
| Add comment | `acli jira workitem comment create --key KEY --body "..."` |
| Transition issue | `acli jira workitem transition --key KEY --status "Done"` |
| List my issues | `acli jira workitem search --jql "assignee = currentUser()"` |
| My in-progress | `acli jira workitem search --jql "assignee = currentUser() AND status = 'In Progress'"` |

**Environment Variables (from `private/jira.sh`):**
- `$JIRA_PROJECT` — Your project key (e.g., "ID")
- `$JIRA_SITE` — Your Jira domain (e.g., "compass-tech.atlassian.net")
- `$JIRA_USER` — Your email (e.g., "user@compass.com")
- `$JIRA_TEAM` — Team UUID for custom field (auto-configured)
- `$JIRA_LABEL_OPTIONS` — Available labels (comma-separated)

---

## Triggers

- "create a jira ticket"
- "show me PROJ-123"
- "list my tickets"
- "move ticket to done"
- "what's in the current sprint"

---

## Issue Key Detection

Issue keys follow the pattern: `[A-Z]+-[0-9]+` (e.g., PROJ-123, ABC-1).

When a user mentions an issue key in conversation:
- View with: `acli jira workitem view KEY`

---

## Workflow

**Creating tickets:**

**CRITICAL REMINDERS:**
- **ALWAYS use `$JIRA_PROJECT`** from environment - never hardcode or guess a project key
- **SKIP asking for information the user has already provided** in their request
- **ALWAYS show the full command** before executing
- Only ask for missing required fields or unclear optional fields

**Intelligent Flow:**

Start by **parsing the user's request** to extract any information they've already provided:
- Issue type (Story, Task, Bug, etc.)
- Summary/title
- Epic ID (parent)
- Description or acceptance criteria
- Labels
- Assignee preferences
- Sprint preference

Then **only ask for missing required fields**:

1. **Type & Summary (if not provided)**:
   - If both type and summary are in the user's request, skip to step 2
   - Otherwise, use `AskUserQuestion` to ask "What's this ticket about?" with type options

2. **Parent Epic (if not provided)**:
   - If user mentioned an epic ID (e.g., "ID-14004"), use it directly
   - Otherwise, fetch epic options: `bash ai/skills/jira/scripts/jira-fetch-epics.sh`
   - Convert to `AskUserQuestion` options (max 4 options; include "Other" for custom entry)
   - Extract epic ID from selection

3. **Team (always auto-filled)**:
   - Team UUID is in `$JIRA_TEAM` (set by `private/jira.sh`)
   - The script automatically passes this as `customfield_10200`
   - **Never ask the user**

4. **Optional fields (only ask if not provided)**:
   - **Description**: If user provided details/criteria, draft a structured description. Otherwise, ask "Would you like to add a description?"
   - **Labels**: Only ask if not mentioned in request. Use options from `$JIRA_LABEL_OPTIONS`, support multi-select
   - **Assignee**: Only ask if not specified. Options: "@me" (self-assign), "Leave empty", Other
   - **Sprint**: Only ask if not mentioned. Options: current sprint, "Backlog", "Leave empty"

5. **Show & confirm command**: Display the full command with all collected fields. Get explicit approval.
   ```bash
   bash ai/skills/jira/scripts/jira-create-ticket.sh \
     --project "$JIRA_PROJECT" \
     --type Story \
     --summary "..." \
     --parent ID-XXXX \
     --team "$JIRA_TEAM" \
     [--assignee email@example.com] \
     [--description "..."] \
     [--labels "label1,label2"]
   ```

6. **Execute & verify**: Run the script, then view the created ticket to confirm.

**Example: User provides complete request**

User: `/jira create a story for updating a script to have the --csv flag option and put it under epic ID-14004`

Flow:
- Extract: type=Story, summary="Update script to have --csv flag option", parent=ID-14004
- Skip steps 1-2, go directly to step 4
- Ask only for optional fields the user didn't mention (description, labels, assignee, sprint)
- Show & confirm command
- Execute

**Example: User provides minimal request**

User: `/jira create a ticket`

Flow:
- No information extracted
- Start at step 1: ask for type and summary
- Continue through full flow

**Viewing tickets:**
1. Fetch issue details first
2. Show relevant fields to user

**Updating/Transitioning tickets:**
1. Fetch issue details first
2. Check current status
3. Show proposed changes
4. Get approval before running
5. Verify after execution

---

## Before Any Operation

Ask yourself:

1. **What's the current state?** — Always fetch the issue first. Don't assume status, assignee, or fields are what user thinks they are.

2. **Who else is affected?** — Check watchers, linked issues, parent epics. A "simple edit" might notify 10 people.

3. **Is this reversible?** — Transitions may have one-way gates. Some workflows require intermediate states. Description edits have no undo.

**Project Key Validation:**
- **ALWAYS use `$JIRA_PROJECT`** from the environment when executing commands
- **NEVER hardcode or guess a project key** (e.g., don't use "KINDLY" if `$JIRA_PROJECT=ID`)
- Verify `$JIRA_PROJECT` is set: `echo $JIRA_PROJECT`
- If uncertain about what project to use, ask the user before running any commands

---

## NEVER

- **NEVER transition without fetching current status** — Workflows may require intermediate states. Some transitions might not be available from the current status.

- **NEVER edit description without showing original** — Jira has no undo. User must see what they're replacing.

- **NEVER bulk-modify without explicit approval** — Each ticket change notifies watchers. 10 edits = 10 notification storms.

- **NEVER assume field values** — Always fetch the issue first to see current values before suggesting changes.

---

## Working with Custom Fields

Some Jira instances have custom fields that `acli` doesn't expose as CLI flags. When creating tickets with required custom fields:

1. **Identify the custom field ID**: Fetch an existing ticket via REST API to find the field:
   ```bash
   curl -u "$JIRA_USER:$JIRA_API_TOKEN" \
     "https://$JIRA_SITE/rest/api/2/issue/KEY" | grep customfield
   ```

2. **Get the field value UUID** (if it's a select field):
   ```bash
   # Look for the field in the JSON response
   # Example: "customfield_10200": { "id": "d58100e1-...", "name": "Team Name" }
   ```

3. **Use REST API v2 for creation** when custom fields are required:
   ```bash
   curl -X POST \
     -u "$JIRA_USER:$JIRA_API_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "fields": {
         "project": { "key": "$JIRA_PROJECT" },
         "summary": "...",
         "issuetype": { "name": "Task" },
         "parent": { "key": "ID-XXXX" },
         "customfield_10200": "team-uuid-here"
       }
     }' \
     "https://$JIRA_SITE/rest/api/2/issue"
   ```

**Example:**
- Team field: `customfield_12345`
- "My Team - Team 1" UUID: `d58100e1-b897-4ed9-963c-9db91a741234`

## Safety

- Always show the command before running it
- Always get approval before modifying tickets
- Preserve original information when editing
- Verify updates after applying
- Always surface authentication issues clearly so the user can resolve them

---

## Sandbox Notice

**⚠️ Atlassian CLI requires network access to Jira servers.** If commands fail with "failed to fetch work item details", you may be running in sandboxed mode.

To use Jira skills, disable the sandbox:
```
/sandbox off
```

After disabling, run the setup steps below.

---

## Setup

### Quick Setup (Recommended)

Run the interactive setup script:

```bash
bash ai/skills/jira/scripts/jira-setup.sh
```

This will guide you through:
1. Installing acli (if needed)
2. Creating and storing your API token securely
3. Setting up environment variables in `private/jira.sh`
4. Authenticating with acli
5. Verifying your setup

### Manual Setup

If you prefer to set up manually, follow these steps:

**Step 1: Install Atlassian CLI**

```bash
brew install atlassian-cli
```

**Step 2: Get your API token**

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Copy the token (shown only once)

**Step 3: Store token securely**

```bash
# Create a file to store your token (readable only by you)
echo "your-api-token-here" > ~/.config/toolbox/jira-token.txt
chmod 600 ~/.config/toolbox/jira-token.txt
```

**Step 4: Create `private/jira.sh` with your org settings**

The `private/` directory is auto-sourced on shell startup and is git-ignored—perfect for org-specific config. Create this file:

```bash
# private/jira.sh
export JIRA_SITE="yourcompany.atlassian.net"
export JIRA_PROJECT="PROJ"
export JIRA_USER="your@email.com"
export JIRA_BASE_URL="https://$JIRA_SITE"
export JIRA_API_TOKEN="$(cat ~/.config/toolbox/jira-token.txt 2>/dev/null)"
export JIRA_TEAM="team-uuid-here"  # Team UUID from customfield_10200
export JIRA_EPIC_IDS="ID-100,ID-200"  # Frequently used epic IDs (descriptions fetched dynamically)
```

Then reload your shell:
```bash
refresh
```

**Step 5: Authenticate with acli (one-time setup)**

```bash
cat ~/.config/toolbox/jira-token.txt | acli jira auth login -e "$JIRA_USER" -s "$JIRA_SITE" --token
```

Piping the token from a file keeps it out of your shell history (safer than typing it).

**Step 6: Verify authentication**

```bash
acli jira user current
```

You should see your user info. If you see an error, check the troubleshooting section below.

### Troubleshooting Authentication

**If `acli` commands return "not authenticated" errors:**

1. Check your token is valid (still active at https://id.atlassian.com/manage-profile/security/api-tokens)
2. If expired, generate a new one and update `~/.config/toolbox/jira-token.txt`
3. Re-run the auth command from Step 5:
   ```bash
   cat ~/.config/toolbox/jira-token.txt | acli jira auth login -e "$JIRA_USER" -s "$JIRA_SITE" --token
   ```

**If you get a "user not found" error:**

- Verify `JIRA_USER` in `private/jira.sh` matches your Atlassian account email
- Verify `JIRA_SITE` is the correct Atlassian domain

Check: `acli jira workitem --help`

---

## Self-Healing: Diagnosing and Fixing Command Issues

When a command fails or behaves unexpectedly, use this process to identify and fix the underlying issue:

### 1. **Command Not Recognized or Has Wrong Flags**

**If you see:** `unknown flag`, `required flag`, or syntax errors

**Diagnosis:**
```bash
# Check the actual command help to see what flags are available
acli jira workitem create --help
acli jira workitem search --help
acli jira workitem transition --help
```

**Fix:** Update the skill documentation (SKILL.md or references/commands.md) with the correct flags and syntax shown in the help output.

### 2. **Custom Field Issues (Team, etc.)**

**If you see:** "The Team field is required" or "unknown flag: --team"

**Diagnosis:**
```bash
# The Team field is likely a custom field, not a standard flag
# Check an existing ticket to find the field ID
curl -u "$JIRA_USER:$JIRA_API_TOKEN" \
  "https://$JIRA_SITE/rest/api/2/issue/SAMPLE-KEY" | \
  python3 -c "import json,sys; data=json.load(sys.stdin); print('\\n'.join([f'{k}: {v}' for k,v in data['fields'].items() if 'custom' in k.lower()]))"
```

**Fix:**
- Identify the custom field ID (e.g., `customfield_10200`)
- Find the field's current value and its UUID/ID format
- Use REST API v2 instead of acli when creating with custom fields
- Update SKILL.md with the correct field ID and format

### 3. **Parent/Child Hierarchy Issues**

**If you see:** "Given parent work item does not belong to appropriate hierarchy"

**Diagnosis:**
```bash
# Check what type the parent issue is
acli jira workitem view PARENT-KEY
# Look at the Type line - it should be "Epic" for child tasks/stories
```

**Fix:**
- Parent must be an Epic, not a Story or Task
- Update the search query to filter by `issuetype = Epic`
- Update documentation if the parent type requirements were wrong

### 4. **REST API Endpoint Issues**

**If you see:** "dead link", 404, or HTML error pages instead of JSON

**Diagnosis:**
```bash
# Test the correct API endpoint
curl -u "$JIRA_USER:$JIRA_API_TOKEN" \
  "https://$JIRA_SITE/rest/api/2/issue" -X POST \
  -H "Content-Type: application/json" \
  -d '{"fields":{"project":{"key":"TEST"}}}'

# If that fails, try api/3
curl -u "$JIRA_USER:$JIRA_API_TOKEN" \
  "https://$JIRA_SITE/rest/api/3/issues" -X POST \
  -H "Content-Type: application/json" \
  -d '{"fields":{"project":{"key":"TEST"}}}'
```

**Fix:** Update the endpoint in SKILL.md. Most Jira Cloud instances use `/rest/api/2/` for creating issues.

### 5. **Field Value Format Issues**

**If you see:** "Operation value must be a string" or "is not valid"

**Diagnosis:**
```bash
# Check how the field value is structured in an existing ticket
curl -u "$JIRA_USER:$JIRA_API_TOKEN" \
  "https://$JIRA_SITE/rest/api/2/issue/SAMPLE-KEY" | \
  python3 -m json.tool | grep -A 5 "customfield_XXXXX"
```

**Fix:**
- If it's `{"id": "...", "name": "..."}`, pass just the string ID: `"customfield_XXXXX": "id-string"`
- If it's `{"value": "..."}`, check if you need the plain string or an object
- Update SKILL.md with the correct format pattern

### 6. **JQL Query Syntax Errors**

**If you see:** JQL errors in search commands

**Diagnosis:**
```bash
# Test the JQL in the web UI first, then check syntax
# Common issues: missing quotes around spaces, wrong field names
acli jira workitem search --jql "project = ID AND status = 'In Progress'" --help
```

**Fix:**
- Wrap values with spaces in single quotes: `status = 'In Progress'`
- Use double quotes for the whole JQL string in bash
- Verify field names match what Jira expects (use web UI to confirm)

### How to Update the Skill

When you discover an issue:

1. **Diagnose** using the steps above
2. **Test** the correct command in the shell
3. **Verify** it works as expected
4. **Update** the relevant section in SKILL.md or references/commands.md
5. **Document** the fix with a comment explaining why the old instruction was wrong

**Example commit message:**
```
fix: correct custom field handling in jira skill

Discovered that Team field is customfield_10200 (not a CLI flag).
Updated workflow to use REST API v2 for tickets with custom fields.
```

---

## Deep Dive

**LOAD reference when:**
- Creating issues with complex fields
- Building JQL queries beyond simple filters
- Troubleshooting errors or authentication issues
- Working with transitions or sprints

**Do NOT load reference for:**
- Simple view/list operations (Quick Reference above is sufficient)
- Basic status checks

| Task | Load Reference? |
|------|-----------------|
| View single issue | No |
| List my tickets | No |
| Create with description | **Yes** — `references/commands.md` |
| Transition issue | **Yes** — for complex workflows |
| JQL search | **Yes** — for complex queries |

References:
- `references/commands.md` - Complete acli command reference
