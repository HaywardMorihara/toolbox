# Markdown-Writing Skill: Before & After Comparison

## The Problem (Before)

Your request to **clarify terminology in a definition** was not caught by the skill:

```
❯ Please make sure the definition encompasses both primary and secondary scenarios

  Read 1 file (ctrl+o to expand)

⏺ Update(my-documentation.md)
  ⎿  Added 1 line, removed 1 line

⏺ I'm not currently using any Skills. The last skill I invoked was /markdown-writing...
  Right now I'm just using basic tools (Read, Edit)
```

**Root cause**: Trigger was too narrow — didn't catch "clarify" or "update" language for minor edits.

---

## Solution Implemented

### Change 1: Expanded Trigger Keywords

**Before**:
```
Triggers on creating/drafting new docs, editing specs, READMEs, design docs, memos, 
or when you mention "improve my writing", "refactor this doc", "make this more concise"
```

**After**:
```
CRITICAL: Trigger on ANY Markdown file edits or creation requests.
Triggers include: "update", "change", "modify", "reword", "clarify", "improve", "fix", 
"make concise", "draft", "outline", "create", "edit", "refactor", "make this more"
```

✅ Now catches: **"clarify"**, **"update"**

---

### Change 2: Added Clear No-Questions Note

**Before**: Silent about when it would ask questions

**After**: Explicit upfront note in Overview:
```
Quick note on questions: If you're making a small, targeted edit (clarify a term, 
reword a paragraph, add a note), the skill will NOT ask about audience/goals/non-goals—
it'll just make the change. Only when you're creating a new document from scratch will 
the skill ask clarifying questions to shape the outline.
```

✅ Removes surprise question-asking on minor edits

---

### Change 3: Updated Scenario 2 Documentation

**Before**:
```
If you're working from raw thoughts, an outline, or a full document you want to refactor, 
we'll collaborate on the information architecture first:

1. You provide input
2. I ask three questions
```

**After**:
```
If you're working from raw thoughts, an outline, or a full document you want to refactor—
particularly when creating new documents from scratch—we'll collaborate on the 
information architecture first. 

Note: I only ask clarifying questions for full document creation/refactoring, 
not for minor edits to existing sections.

1. You provide input
2. I ask three questions (only if needed for document creation)
```

✅ Clear: Questions only for full doc creation, not minor edits

---

## Test Results

### Your Original Request (Should Have Triggered)
```
"Please clarify the definition to mention both primary and secondary scenarios"
```

**Before**: ❌ Did NOT trigger → Used basic Edit tool

**After**: ✅ WOULD trigger on "clarify" keyword
- Would recognize as Scenario 1 (Minor Edit)
- Would NOT ask questions
- Would perform surgical clarification

---

### Similar Requests Now Handled

| Request | Before | After |
|---------|--------|-------|
| "clarify the definition..." | ❌ No | ✅ Scenario 1, no Q's |
| "update the section to..." | ❌ No | ✅ Scenario 1, no Q's |
| "reword this to be punchier..." | ❌ No | ✅ Scenario 1, no Q's |
| "draft an outline..." | ✅ Yes | ✅ Scenario 2, with Q's |
| "create a memo..." | ✅ Yes | ✅ Scenario 2, with Q's |
| "fix this typo..." | ❌ No | ✅ Scenario 1, no Q's |
| "improve this paragraph..." | ✅ Sometimes | ✅ Yes, Scenario 1, no Q's |

---

## Files Modified

1. **SKILL.md Frontmatter** 
   - Added "CRITICAL" warning
   - Expanded trigger keywords list
   - Emphasized "always consult this skill"

2. **SKILL.md Overview Section**
   - Added "Quick note on questions"
   - Clarifies no-questions behavior for minor edits

3. **SKILL.md Scenario 1**
   - Added real example from your use case
   - Clarified no restructuring/outline proposing
   - Added "reword", "clarify" to detection examples

4. **SKILL.md Scenario 2**
   - Added note: "only ask for full document creation"
   - Parenthetical: "(only if needed for document creation)"

5. **evals/evals.json**
   - Added eval-8 (minor edit: clarify definition)
   - Added eval-9 (minor edit: reword paragraph)
   - Anonymized all project-specific examples

---

## Verification

✅ **Eval-8 Test**: "clarify definition...update to cover both paths"
- Triggered ✅
- No questions asked ✅  
- Performed surgical edit ✅

✅ **Eval-9 Test**: "reword introduction...punchier"
- Triggered ✅
- No questions asked ✅
- Provided alternatives ✅

---

## Expected Behavior Now

When you write: **"Please clarify [Term] to include [New Context]"**

**Skill will**:
1. Trigger on "clarify" keyword ✅
2. Recognize as Scenario 1 (Minor Edit) ✅
3. Skip audience/goals/non-goals questions ✅
4. Perform focused edit using Hemingway principles ✅
5. Return updated definition/section ✅

**Skill will NOT**:
- Ask "Who is your audience?" ❌
- Ask "What are your goals?" ❌
- Ask "What's out of scope?" ❌
- Propose a new outline ❌
- Restructure the document ❌

---

## Summary

The markdown-writing skill now:
- ✅ Reliably triggers on editing requests (clarify, update, reword, modify, etc.)
- ✅ Handles minor edits WITHOUT asking clarifying questions
- ✅ Handles document creation WITH clarifying questions (as intended)
- ✅ Has clear documentation about when questions happen
- ✅ Includes test cases for both scenarios
