# Ticket Creation Skill

Help create well-structured software engineering ticket descriptions that provide clear context while leaving room for engineer ownership.

## Process

### 1. Research Phase

Before drafting the ticket:
- Explore the relevant codebase areas using search and file reading
- Identify existing patterns, conventions, and related code
- Check for similar past tickets or PRs if context is available
- Note any technical constraints or dependencies discovered

### 2. Clarifying Questions

Ask the user about:
- **Problem/Goal**: What problem are we solving or what value are we adding?
- **User Impact**: Who is affected and how?
- **Scope Boundaries**: What should explicitly NOT be included?
- **Priority/Urgency**: Is there a deadline or dependency driving this?
- **Existing Context**: Are there related tickets, PRs, or discussions?

### 3. Ticket Structure

```markdown
## Summary

[1-2 sentence description of what needs to be done and why]

## Context

[Background information the engineer needs to understand the problem]
- Why this matters now
- Relevant user feedback, metrics, or incidents
- Links to related discussions, docs, or previous work

## User Story (if applicable)

As a [type of user],
I want [goal/desire],
So that [benefit/value].

## Technical Context

[Pointers to relevant code areas - not prescriptive solutions]
- Relevant files/modules: `path/to/relevant/code`
- Related systems or services
- Known constraints or considerations

## Acceptance Criteria

[Concrete, testable conditions for "done" - focus on WHAT, not HOW]
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Out of Scope

[Explicitly state what this ticket does NOT cover]
- [Item 1]
- [Item 2]

## Open Questions

[Unresolved questions for the engineer to investigate or decide]
- [ ] [Question 1]
- [ ] [Question 2]

## Testing Considerations

[Types of testing needed, edge cases to consider]
- Unit tests for...
- Integration tests for...
- Edge cases: ...

## Non-Functional Requirements (if applicable)

- Performance: [expectations]
- Security: [considerations]
- Accessibility: [requirements]

## References

- [Link to relevant docs]
- [Link to related tickets]
- [Link to design mocks]
```

## Principles

### Leave Room for Engineer Ownership

- **Describe the problem, not the solution**: Focus on what needs to be achieved, not how to achieve it
- **Provide context, not instructions**: Give background that helps the engineer make good decisions
- **Flag considerations, don't mandate approaches**: "Consider X" rather than "Use X"
- **Open questions are valuable**: Explicitly list areas where the engineer should investigate and decide

### Good Acceptance Criteria

- Testable and objective (avoid "should be fast" - use "responds in <200ms")
- Focused on user/system outcomes, not implementation details
- Include edge cases and error scenarios
- Don't over-specify - leave implementation flexibility

### What Makes a Ticket Actionable

- Engineer can start work without scheduling a meeting
- Scope is clear enough to estimate
- Success criteria are unambiguous
- Dependencies and blockers are identified
- Context is sufficient but not overwhelming

## Anti-Patterns to Avoid

- **Solution masquerading as problem**: "Add a button that does X" vs "Users need a way to X"
- **Vague acceptance criteria**: "Works correctly" or "Is performant"
- **Missing context**: Assuming the reader knows why this matters
- **Over-specification**: Dictating implementation details unnecessarily
- **Kitchen sink scope**: Trying to solve everything in one ticket
- **No out-of-scope section**: Leading to scope creep

## Example Clarifying Questions

For a feature request:
- "What user problem does this solve?"
- "How do users currently work around this?"
- "What's the minimum viable version of this feature?"

For a bug fix:
- "What's the expected vs actual behavior?"
- "How are users affected? How often does this occur?"
- "Are there any workarounds currently in use?"

For a refactor:
- "What pain points is this addressing?"
- "What should remain unchanged from the user's perspective?"
- "Are there upcoming features this enables?"
