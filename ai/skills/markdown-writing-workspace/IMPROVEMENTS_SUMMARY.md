# Markdown-Writing Skill — Complete Improvements Summary

## Changes Made

### 1. Trigger Expansion (Description Frontmatter)

**Before**: Narrow triggers that missed common editing tasks
```
Triggers on creating/drafting new docs, editing specs, READMEs, design docs, memos, 
or when you mention "improve my writing", "refactor this doc", "make this more concise"
```

**After**: Aggressive, comprehensive trigger for ANY Markdown edits
```
CRITICAL: Trigger on ANY Markdown file edits or creation requests.
Triggers include: "update", "change", "modify", "reword", "clarify", "improve", "fix", 
"make concise", "draft", "outline", "create", "edit", "refactor", "make this more"
```

### 2. Scenario 1 (Minor Edits) — Clarity & Examples

**Added explicit guidance**:
- Real example: "Please clarify the definition to mention both primary and secondary scenarios"
- Clear statement: "I'll make the change surgically without restructuring..."
- Reassurance: "Even 'trivial' edits benefit from applying Hemingway principles"
- Added "reword" to the detection keywords

### 3. New "Quick Note" in Overview

Added critical clarification upfront:
```
If you're making a small, targeted edit (clarify a term, reword a paragraph, add a note), 
the skill will NOT ask about audience/goals/non-goals—it'll just make the change. 
Only when you're creating a new document from scratch will the skill ask clarifying questions.
```

**Purpose**: Set expectation that minor edits won't trigger question-asking

### 4. Scenario 2 (Full Document Work) — Explicit Non-Triggering Conditions

Updated description:
```
Note: I only ask clarifying questions for full document creation/refactoring, 
not for minor edits to existing sections.
```

Also noted in step 2:
```
I ask three questions (only if needed for document creation):
```

**Purpose**: Make it clear the skill distinguishes between scenarios

---

## Test Results

### Iteration-1: New Document Creation Triggers
- ✅ **Eval-5**: "draft an outline" → TRIGGERED, asked clarifying questions
- ✅ **Eval-6**: "create...memo" → TRIGGERED, asked clarifying questions  
- ✅ **Eval-7**: "draft a proposal" → TRIGGERED, asked clarifying questions

### Iteration-2: Minor Edits (NO Questions)
- ✅ **Eval-8**: "clarify...update..." → TRIGGERED, NO questions asked, performed surgical edit
- ✅ **Eval-9**: "reword..." → TRIGGERED, NO questions asked, provided alternatives

---

## Scenarios Now Handled

| Scenario | Trigger | Questions? | Behavior |
|----------|---------|-----------|----------|
| **Minor edit** (clarify, reword, update) | ✅ Yes | ❌ No | Surgical edit using Hemingway style |
| **New doc creation** (draft, outline, create) | ✅ Yes | ✅ Yes | Ask audience/goals/non-goals, propose outline |
| **Full refactor** (existing doc, whole rewrite) | ✅ Yes | ✅ Yes | Ask clarifying questions before restructuring |

---

## Key Improvements

1. **Trigger reliability**: Now catches "update/modify/clarify/reword" language
2. **No unnecessary questions**: Minor edits skip the audience/goals/non-goals phase
3. **Clear documentation**: Users understand when skill will and won't ask questions
4. **Consistent behavior**: Scenario 1 stays focused; Scenario 2 asks questions only when needed
5. **Anonymized evals**: All project-specific examples replaced with generic terminology

---

## Usage Examples

### Example 1: Minor Edit (NO QUESTIONS)
```
User: "Please clarify the definition of 'Gateway' to mention both primary and async paths"
Skill:  Immediately updates the definition without asking about audience/goals
```

### Example 2: New Document (WITH QUESTIONS)
```
User: "I want to draft an outline for a backend migration guide"
Skill: Asks three questions about audience, goals, non-goals → proposes outline
```

### Example 3: Full Refactor (WITH QUESTIONS)
```
User: "This architecture doc is too verbose, can you rewrite it to be more concise?"
Skill: Asks three questions → proposes new outline → produces rewrite
```

---

## Skill Files Updated

1. **SKILL.md frontmatter** - Expanded and clarified trigger description
2. **SKILL.md Overview** - Added "Quick note on questions"
3. **SKILL.md Scenario 1** - Added example, clarified no-questions behavior
4. **SKILL.md Scenario 2** - Explicit note: questions only for document creation
5. **evals/evals.json** - Added eval-8, eval-9 (minor edit test cases), anonymized prompts

---

## Next Steps (Optional)

- Run description optimization to refine the trigger wording for even better reliability
- Add more edge case evals (e.g., "fix this typo", "reformat this list")
- Test with real-world prompts to validate behavior
