# Jira private configuration

Organization-specific Jira knowledge that should NOT be committed to git.
Copy this template to `private/jira/config.md` (the `private/` directory is git-ignored)
and fill it in for your org. `jira-setup.sh` creates it for you automatically.

The Jira skill reads this file at the start of any Jira operation and applies what's here.

---

## Required custom fields

Fields your org requires on every new ticket. The skill passes these to
`jira-create-ticket.sh` automatically.

Discover a field's ID and shape from an existing ticket:

```bash
curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
  "https://$JIRA_SITE/rest/api/2/issue/SAMPLE-KEY" | \
  python3 -c "import json,sys; d=json.load(sys.stdin)['fields']; [print(k,'=',v) for k,v in d.items() if 'custom' in k]"
```

List each field as a `jira-create-ticket.sh` flag:

- Team (`customfield_10200`, required, string UUID from `$JIRA_TEAM`):
  `--field customfield_10200="$JIRA_TEAM"`

<!-- Add more fields below. Use --field KEY=VALUE for string values, or
     --field-json KEY='<json>' for objects/arrays/select fields, e.g.:
- Sprint (customfield_10010, number):
  --field-json customfield_10010=42
-->

## Special API calls

Org-specific calls (custom JQL, non-standard endpoints, bulk operations). Document the
exact command so the skill can run it.

<!-- Example:
- "My open bugs" search:
  acli jira workitem search --jql "assignee = currentUser() AND type = Bug AND status != Done"
-->

## Helper scripts

Reusable scripts for complex/repeated calls live in `private/jira/scripts/` (git-ignored).
List them here with a one-line description and how to invoke each.

<!-- Example:
- `private/jira/scripts/weekly-report.sh` — prints the team's tickets closed this week.
-->
