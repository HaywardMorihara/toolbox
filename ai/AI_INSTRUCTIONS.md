# AI Assistant Instructions

## Voice

Speak simply. Be concise:

1. Never use a metaphor, simile or other figure of speech which you are used to seeing in print.
2. Never use a long word where a short one will do.
3. If it is possible to cut a word out, always cut it out.
4. Never use the passive where you can use the active.
5. Never use a foreign phrase, a scientific word or a jargon word if you can think of an everyday English equivalent.
6. Break any of these rules sooner than say anything outright barbarous.

Review every prose output against these rules before delivering.

## Planning with Red-Green TDD

When creating an implementation plan (via plan mode or EnterPlanMode):

**Always include a "Verification" section** that describes automated tests/checks using the **Red-Green TDD pattern**:

1. **Red Phase**: Write automated tests/verification that will initially *fail* because the feature doesn't exist yet
   - Tests should clearly demonstrate what behavior you want to build
   - Verify these tests fail before implementation begins

2. **Green Phase**: Implement the code to make the tests pass
   - The tests prove the implementation works correctly
   - Guards against unused or non-functional code

**Verification can take many forms:**
- Unit tests (Jest, pytest, etc.)
- Integration tests
- Custom verification scripts
- Smoke tests or validation checks
- Type checking failures (if using TypeScript)
- Any automated check that demonstrates the feature works

**Example plan section:**
```
## Verification Plan (Red-Green TDD)
**Red Phase - Write failing tests for:**
- Test case 1: [what it should do]
- Test case 2: [edge case or alternative behavior]
- Run with: [command to see tests fail]

**Green Phase - Implement until tests pass:**
- Implement [specific functionality]
- Run: [command to verify tests pass]
- Success: All tests passing, including edge cases
```

## Comment Writing Guidelines

Write comments that explain **why** code exists, not **what** it does:
- Avoid low-value comments that merely restate the code (e.g., `// set x to 5` above `x = 5`)
- Focus on:
  - Non-obvious logic or decisions
  - Edge cases and gotchas
  - Workarounds and why they're necessary
  - Complex algorithms or interactions
  - Important context that isn't immediately clear from code

This keeps comments valuable and reduces noise in the codebase.
