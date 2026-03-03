# Jira CLI Setup

Quick guide to use Jira via the Atlassian CLI (acli).

## Prerequisites

- `acli` (Atlassian CLI) installed
- Jira account with API access

## Setup

### 1. Install acli

```bash
brew install atlassian-cli
```

### 2. Authenticate

```bash
acli jira auth
```

This will prompt you for your Jira domain and credentials, then store them locally.

### 3. Verify Installation

```bash
acli jira workitem view <PROJ-123> --fields key,summary,status
```

Replace `PROJ-123` with any valid ticket in your Jira instance.

## Usage

### View a Ticket

```bash
# View with default fields
acli jira workitem view PROJ-123 --fields key,issuetype,summary,status,assignee,description

# View with minimal fields
acli jira workitem view PROJ-123 --fields key,summary
```

### Create a Ticket

```bash
# Interactive (prompts for fields)
acli jira workitem create --project PROJ

# Non-interactive
acli jira workitem create \
  --project PROJ \
  --type Story \
  --summary "User needs export feature" \
  --description "Allow users to export data as CSV or JSON"
```

### Search for Tickets

```bash
# My issues
acli jira workitem search --jql "assignee = currentUser()"

# My in-progress issues
acli jira workitem search --jql "assignee = currentUser() AND status = 'In Progress'"

# All bugs in project
acli jira workitem search --jql "project = PROJ AND type = Bug"
```

### Transition a Ticket

```bash
# Interactive (shows available states)
acli jira workitem transition PROJ-123

# Transition to specific state
acli jira workitem transition PROJ-123 --state "In Progress"
acli jira workitem transition PROJ-123 --state "Done"
```

### Add a Comment

```bash
acli jira workitem comment add PROJ-123 --body "Implementation complete, ready for review"
```

### Open in Browser

```bash
acli jira workitem open PROJ-123
```

## Aliases

For convenience, add to your shell config:

```bash
alias jira='acli jira workitem'
```

Then use:
```bash
jira view PROJ-123 --fields key,summary,status
jira create --project PROJ --type Story --summary "..."
jira search --jql "..."
```

## Troubleshooting

### "Authentication failed"

Re-authenticate:
```bash
acli jira auth
```

### "Issue not found"

- Verify the issue key (e.g., `PROJ-123`, not `proj-123`)
- Confirm you have permission to view it
- Check the project exists in your Jira instance

### "Invalid transition"

The current status may not allow direct transition to the target state. Run:
```bash
acli jira workitem transition PROJ-123
```

to see available states, or check your project's workflow diagram.

## References

- [acli Documentation](https://github.com/atlassian-labs/mce-cli)
- [Jira API Documentation](https://developer.atlassian.com/cloud/jira/rest/v3/api-group-issues/)
