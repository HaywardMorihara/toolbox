---
name: remember
description: Create persistent reminders and workflow automations by storing guidance as skills, skill updates, or project instructions
user-invocable: true
---

# Remember Skill

A meta-skill that helps you capture and store reminders, preferences, and workflows as persistent guidance. When you say "remember to [do something]", this skill helps determine the best way to encode that reminder so it applies to future work.

## When to Use This Skill

### Manual Invocation
Use `/remember` when you want to create a new reminder about:
- A recurring workflow or process
- A preference or guideline you want applied to future work
- An automation or check you should run before starting a task
- A pattern you've noticed that should be codified

### Automatic Recognition
Claude should proactively suggest this skill when you say things like:
- "Remember to [action] next time [trigger]"
- "Make sure we [action] before [situation]"
- "I should [action] whenever [condition]"

## Workflow

### Phase 1: Clarify the Reminder

First, understand what you want to remember by asking:

1. **What should happen?** (the action/behavior to remember)
   - What is the specific action or check you want to happen?
   - Is it something automated, manual, or a mix?

2. **When should it happen?** (the trigger/context)
   - What triggers this? (before task start, during certain workflows, on PR reviews, etc.)
   - Is it a one-time thing or recurring?

3. **How important/frequent is this?**
   - How often will this come up?
   - What's the impact if it's forgotten?

4. **Who does it apply to?**
   - Is this just for you or for anyone working on this project?
   - Should it apply to all projects or just this one?

### Phase 2: Decide Storage Method

Use this decision tree to pick the best approach:

```
Is this a workflow/tool/command that needs to be runnable on demand?
├─ YES → Create a NEW SKILL
│  └─ Examples:
│     - "remember to check Jira before starting" → skill that lists Jira issues
│     - "remember to run my validation checks" → skill that bundles multiple commands
│     - "remember to ask for approval" → skill that guides a workflow
│
├─ NO → Does this enhance or extend an existing skill?
│  ├─ YES → UPDATE THE EXISTING SKILL
│  │  └─ Examples:
│  │     - Add a new command to gh-pr-comments skill
│  │     - Extend jira skill with new functionality
│  │
│  └─ NO → Does this apply to all projects or this specific one?
│     ├─ ALL PROJECTS → Update AGENTS.md (global instructions)
│     │  └─ Examples:
│     │     - "remember to always use the Explore agent for broad searches"
│     │     - "remember to check task list before starting work"
│     │     - "remember to document all architectural decisions"
│     │
│     └─ THIS PROJECT → Update CLAUDE.md (project instructions)
│        └─ Examples:
│           - "remember to run Gazelle before mocks in Go"
│           - "remember to use testify suite for Go tests"
```

### Phase 3: Execute with Approval

1. **Show the user what you'll create**
   - Display the new skill/updates you'll make
   - Explain why this approach was chosen
   - Ask for approval before writing anything

2. **Get explicit approval**
   - User must say yes (or equivalent) before you write files
   - This prevents accidentally overwriting instructions

3. **Write and commit**
   - Create the skill/update the file
   - Create a git commit with clear message
   - Confirm completion

## Examples

### Example 1: Create a New Skill
**User says**: "Remember to check our Jira backlog before starting any feature work"

**Decision**: This is a workflow that needs to run on demand → Create new skill

**Action**: Create `~/development/toolbox/ai/skills/jira-backlog-check/SKILL.md` with:
- Description of the skill
- How to invoke it
- What commands it runs (likely `jira` skill calls + filtering)
- Clear output format

### Example 2: Update Existing Skill
**User says**: "Remember to also check for Jira subtasks, not just parent tickets"

**Decision**: This enhances the existing `jira` skill → Update existing skill

**Action**: Add guidance to `~/development/toolbox/ai/skills/jira/SKILL.md` about subtask handling

### Example 3: Update Project Instructions
**User says**: "Remember to always run `compass workspace clean --expunge` before building after long breaks"

**Decision**: This is a build system best practice for this project → Update CLAUDE.md

**Action**: Add to `/Users/nathaniel.morihara/development/urbancompass/CLAUDE.md` under Build/Test Commands section

### Example 4: Update Global Instructions
**User says**: "Remember to always ask users to clarify ambiguous requirements before planning implementation"

**Decision**: This is a general guideline for all projects → Update AGENTS.md

**Action**: Add to `~/development/toolbox/AGENTS.md` under guidelines section

## Implementation Tips

When creating new skills:
- Make the skill name descriptive and lowercase with hyphens
- Include clear "when to use" section explaining the trigger
- Provide example commands and outputs
- Reference related skills if applicable

When updating CLAUDE.md or AGENTS.md:
- Preserve existing content structure
- Add your reminder in the most appropriate section
- Keep explanations concise but clear
- Link to related sections if needed

When updating existing skills:
- Don't remove or break existing content
- Add new capabilities at the end of sections
- Update examples if they become incomplete
- Maintain the existing tone and style

## Approval Workflow

```
User triggers /remember or mentions "remember to X"
         ↓
Phase 1: Ask clarifying questions
         ↓
Phase 2: Determine which file/skill to create/update
         ↓
Phase 3: Show user the proposed changes (BEFORE writing)
         ↓
User approves or provides feedback
         ↓
Write changes and create commit
         ↓
Confirm completion
```

**Critical**: Always show the user what you plan to write before writing it.
