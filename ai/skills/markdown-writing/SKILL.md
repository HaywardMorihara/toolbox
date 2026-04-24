---
name: markdown-writing
description: |
  Improve technical writing in Markdown using Hemingway style (clear, direct, minimal words). Tighten verbose documents, improve structure, and apply information architecture principles. Use this skill for any Markdown editing, refactoring, or creation: READMEs, specs, design docs, proposals, guides, or technical writing. When the user's intent is clear, produce output immediately. Ask clarifying questions only if genuinely needed to create better results.
triggers: |
  - Any request mentioning .md, .markdown, or Markdown files
  - Requests to "write", "create", "draft", "outline", "sketch" documentation or prose
  - Requests to "update", "change", "modify", "reword", "clarify", "improve", "refactor", "tighten", "make concise", "edit" Markdown content
  - Requests about documentation, specs, READMEs, proposals, design docs, architecture docs, guides, handbooks, or technical writing
  - Requests asking for structure, organization, or information architecture improvements
compatibility: null
---

## How This Skill Works

### Presentation Mode: Incremental or Immediate

The skill adapts to user preference:

**Incremental Mode** (recommended for substantial changes)
- User says "review this with me" or "show me changes one by one"
- Present **one focused improvement** at a time with context
- User reviews, approves, adjusts, or rejects each change
- Move to next change only after approval
- Useful for: iterative refinement, learning the reasoning, fine-tuning tone

**Immediate Mode** (default when intent is clear)
- User provides content + clear improvement request → Produce full refactored output
- No further interaction needed unless user asks for adjustments
- Useful for: quick wins, straightforward rewrites, clear intent

### When to Produce Output Immediately

If the user has provided:
- **Existing content to tighten** + a clear request to improve it → Rewrite immediately (unless they ask for step-by-step review)
- **Rough notes or outline** + a request to "turn into a spec/guide/doc" → Structure and write immediately
- **A paragraph to reword** + specific feedback about what to change → Revise immediately

Examples:
- "This README is too wordy—tighten it up" (user provides README) → Produce refactored README
- "Here are my rough notes about caching. Can you turn this into a design spec?" (user provides notes) → Write the spec
- "Reword this section to be clearer" (user provides section) → Rewrite it

### When to Present Changes Incrementally

Offer or switch to incremental mode when:
- User explicitly requests "show me changes one by one" or "review with me step by step"
- Document is large or has many improvements possible
- User wants to understand the reasoning for each change
- User may want to adjust suggestions or provide feedback between changes

**Incremental workflow:**
1. Analyze the document and identify key improvements needed
2. Present **first change** with:
   - Context: What section/idea is being changed
   - Original text (quoted)
   - Improved text (quoted)
   - Reasoning: Why this is better (Hemingway principle applied)
3. Wait for user response:
   - ✅ "Approve" → Save change, move to next
   - 🔧 "Adjust" + feedback → Refine and re-present
   - ❌ "Skip" → Move to next without this change
   - ❓ "Why?" → Explain reasoning more fully
4. Repeat until all improvements presented or user stops

### When to Ask Clarifying Questions

Ask questions **only when the user's intent is genuinely ambiguous** and clarification will lead to significantly better results. This is rare.

Examples of when to ask:
- User says "improve this document" but provides no content, no context about purpose or audience
- User provides conflicting instructions ("make it shorter" but "add more detail about X")
- User provides content but it's completely unclear what the goal is

**Do not ask:**
- "Who is the audience?" if the user's content already implies it (e.g., "I'm writing a README for developers")
- "What are your goals?" if they already said "make this less wordy" or "turn this into a proper spec"
- "What should be in scope?" if they provided the content—work with what they gave you

## Writing Principles

### Hemingway Style
- **Short sentences**: Break complex ideas into multiple sentences
- **Active voice**: "The caching layer handles requests" beats "Requests are handled by the caching layer"
- **Specific language**: "Use LRU cache with 10,000 entries" beats "consider appropriate caching strategies"
- **No filler**: Cut "It is important to note that", "arguably", "might", "perhaps", "to be honest"
- **One idea per sentence**: Avoid cramming multiple concepts together

**Bad example**: "It is often the case that developers may find themselves in a situation where they might want to consider using caching strategies in order to potentially improve overall system performance metrics."

**Good example**: "Use caching to improve system performance."

### Information Architecture
- **Lead with the summary**: 1-2 paragraphs answering "What is this? Why should I care?"
- **Organized sections**: Group related ideas; use headers to guide readers
- **Progressive disclosure**: High-level content first, details in subsections
- **Scannable format**: Short paragraphs, bullet points, clear hierarchy

Example structure for a spec:
```
# Feature Name

## Overview
What is this feature and why does it matter? (2-3 sentences)

## Key Decisions
- Decision 1: Rationale
- Decision 2: Rationale

## Implementation
Detailed sections here...
```

## What You'll Do

**For immediate mode:**
1. **Read the user's input** (content or rough notes)
2. **Assess whether you have enough context**
   - If yes → Proceed to step 3
   - If no → Ask clarifying question(s) that will improve the output
3. **Apply Hemingway principles**: Cut filler, shorten sentences, improve structure, use active voice
4. **Organize for clarity**: Lead with summaries, use headers, progressive disclosure
5. **Deliver the rewritten document** in Markdown
6. **Offer iteration**: "Want me to adjust anything? Reorganize sections? Add more detail somewhere?"

**For incremental mode:**
1. **Read and analyze** the document
2. **Identify improvements** grouped by type (wordiness, structure, clarity, tone)
3. **Present first improvement** with original → improved → reasoning
4. **Get feedback** (approve/adjust/skip) before moving to next
5. **Apply approved changes** incrementally, building toward final document
6. **Recap final result** once all improvements are done

## Examples

### Immediate Mode: Refactoring a verbose README

Input (user provides):
```
# DataTool

DataTool is a command-line interface tool that has been developed 
to assist with the processing and transformation of data files. 
It provides a wide range of functionalities...
```

Request: "This is too wordy. Can you make it more concise?"

Output (you produce immediately):
```
# DataTool

A CLI tool for processing and transforming data files in CSV, JSON, and XML formats.

## Installation
```bash
pip install datatool
```

## Commands
- **transform**: Convert data between formats
- **validate**: Check data quality
- **export**: Export in multiple formats
- **merge**: Combine multiple files

For details: `datatool <command> --help`
```

### Immediate Mode: Creating a spec from rough notes

Input (user provides):
```
We're adding caching. Need to decide on LRU cache vs other strategies. 
Where should it live—gateway or service? How do we handle invalidation? 
TTL? Manual? Need to handle backwards compatibility too.
```

Request: "Can you turn this into a proper design spec?"

Output (you produce immediately):
```
# Caching System Design

## Overview
We're adding a caching layer to reduce database load and improve response times. 
This spec covers cache placement, strategy, invalidation, and backwards compatibility.

## Key Decisions

### Cache Location: Service-Level
Rationale: Service-level caching gives us finer control over what gets cached...

### Cache Strategy: LRU with TTL
Rationale: LRU eviction prevents unbounded growth; TTL ensures fresh data...

### Invalidation
Manual cache invalidation on data mutations; TTL provides automatic expiration...

### Backwards Compatibility
Older clients ignore cache headers; behavior is unchanged for them...

## Implementation
[Detailed sections...]
```

### Incremental Mode: Step-by-step review of improvements

Input (user provides):
```
# Build System Architecture

The build system that we have in place is quite complex. 
It is important to note that it uses multiple orchestration tools 
in order to manage dependencies, and they work together to ensure 
that we are able to coordinate builds across different microservices. 
This is arguably necessary for maintaining consistency and avoiding issues.
```

User request: "Review this with me one by one and show me the changes."

Output (incremental):

**Change 1: Wordiness in opening**
- **Original:** "The build system that we have in place is quite complex. It is important to note that it uses multiple orchestration tools in order to manage dependencies..."
- **Improved:** "Our build system coordinates multiple orchestration tools to manage dependencies..."
- **Why:** Removes filler ("It is important to note", "in order to", "that we have in place"), uses active voice ("Our" + verb), tightens structure
- **Your feedback?** (Approve / Adjust / Skip / Why?)

---

User: "Adjust — I want to mention it's currently complex"

**Change 1 (revised):**
- **Improved:** "Our build system is complex: it coordinates multiple orchestration tools to manage dependencies..."
- **Your feedback?** (Approve / Adjust / Skip / Why?)

---

User: "Approve"

**Change 2: "arguably" hedging**
- **Original:** "This is arguably necessary for maintaining consistency..."
- **Improved:** "This approach ensures consistency and prevents build failures..."
- **Why:** Removes hedging ("arguably"), states value concretely instead of defending necessity
- **Your feedback?** (Approve / Adjust / Skip / Why?)

---

User: "Approve"

**Final result:**
```
# Build System Architecture

Our build system is complex: it coordinates multiple orchestration tools to manage dependencies across microservices. This approach ensures consistency and prevents build failures.
```
