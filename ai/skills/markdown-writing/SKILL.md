---
name: markdown-writing
description: |
  Improve technical writing (specs, READMEs, documentation) in Markdown files. Ensures writing is succinct and uses a Hemingway style (clear, direct, minimal words). Structures documents with high-level content first, then links readers to detailed sub-sections as needed. Use this skill whenever you're authoring, creating, or revising Markdown documentation, technical designs, or any prose-heavy Markdown file. Triggers on creating/drafting new docs, editing specs, READMEs, design docs, memos, or when you mention "improve my writing", "refactor this doc", "make this more concise", "draft", "outline", or similar requests.
compatibility: null
---

## Overview

This skill helps you write clearer, more concise Markdown documents. It applies two principles:

1. **Succinctness (Hemingway style)**: Direct language, no filler, every word earns its place
2. **Information architecture**: High-level summaries first; detailed sub-sections come later and are linked from the top

## How to Use This Skill

### Scenario 1: Minor Edits (No IA Phase)

If you're making a **small, localized change** to an existing document—adding a note, updating a section, removing outdated content—skip the information architecture phase entirely. Just tell me what to change:

- "Add a note about X to the [Section Name]"
- "Update the configuration section to mention Y"
- "Remove the deprecated API reference"

I'll make the change surgically without restructuring the document or proposing a new outline.

**How I detect this**: You reference an existing section by name, ask to "add", "update", or "remove" specific content, and don't ask to refactor or restructure the whole document.

### Scenario 2: Full Document Work (With IA Phase)

If you're working from **raw thoughts, an outline, or a full document you want to refactor**, we'll collaborate on the information architecture first:

1. **You provide input**: Raw thoughts, a rough outline, or the existing document
2. **I ask three questions**:
   - **Audience**: Who will read this? (e.g., "engineers on my team", "API users", "future maintainers")
   - **Goals**: What do you want readers to understand or be able to do?
   - **Non-Goals**: What's explicitly out of scope?
3. **I propose an outline** based on your answers
4. **You refine it**: Adjust sections, reorder, add/remove details
5. **I produce the full rewrite** using that outline, applying Hemingway principles throughout

## Writing Principles

### Succinctness (Hemingway Style)

- **Use short sentences.** Break complex ideas into multiple sentences rather than cramming them together.
- **Cut unnecessary words.** Remove adjectives that don't add meaning, avoid hedging language ("might", "perhaps", "arguably").
- **Be specific.** "Use TLS 1.3 for encryption" beats "make sure to consider encryption mechanisms."
- **Avoid repetition.** Say something once, clearly, rather than restating it multiple times.
- **No filler.** Delete: "It is important to note that...", "In summary, as we've discussed...", "It should be understood that..."

**Example:**
- ❌ *Poor*: "It is often the case that developers may find themselves in a situation where they might want to consider using caching strategies in order to potentially improve overall system performance metrics."
- ✅ *Better*: "Use caching to improve system performance."

### Information Architecture

Structure the document so readers encounter ideas in order of importance:

1. **Lead with the summary**: Start with what readers need to know. One or two paragraphs that answer: What is this? Why should you care?
2. **Provide a roadmap**: Briefly describe what sections follow and who they're for.
3. **Detailed sections below**: Each section can go deep. Use headers and links to guide readers to the details they need.

**Example structure for a spec:**
- 1-2 paragraph overview (what + why)
- "For [Audience], see [Section]" pointers
- Detailed sections (design, implementation, tradeoffs, etc.)

## The Rewrite Output

When I produce the full rewrite, I will:
- Apply the outline we agreed on
- Write with succinctness and clarity (Hemingway style)
- Keep high-level content at the top; push details into sub-sections
- Preserve all substantive information from the original (or your outline)
- Present the final Markdown as a clean, complete document

If you want to iterate further after the rewrite, we can refine sections, adjust the outline, or tighten specific passages.

## Edge Cases

- **Unclear input**: If I can't tell whether you want a minor edit or full IA collaboration, I'll ask.
- **Existing document + minor edit**: If you reference a specific section, I treat it as a minor edit. If you say "refactor this whole thing", I treat it as Scenario 2.
- **Very short documents**: Even a single-page README benefits from IA clarity—lead with the essential info, link to details.
