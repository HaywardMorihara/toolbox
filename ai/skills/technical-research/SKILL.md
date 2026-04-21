---
name: technical-research
description: |
  Conduct objective research on technical decisions without anchoring to a predetermined conclusion. Use this skill whenever the user asks to research a technology, compare tools or frameworks, evaluate architecture patterns, investigate tradeoffs between options, or analyze technical implementation choices. This skill is essential when the user frames their question with a preferred outcome (e.g., "research why we should adopt Kubernetes") — it ensures you present both supporting evidence and counterarguments neutrally, letting the user draw their own conclusion.
triggers: |
  - research [technology/tool/pattern]
  - compare [option A] vs [option B]
  - what are the tradeoffs of [decision]
  - evaluate [tool/framework] for [use case]
  - investigate [architecture decision]
  - help me understand [technology]
  - should we use [tool] for [purpose]
user-invocable: true
---

# Technical Research

## Core Principles

When the user asks you to research a technical topic, your job is **process, not conclusion**. This skill guides how you gather and present information — it does NOT tell you what answer to reach.

**Three non-negotiable rules:**

1. **Reframe biased questions** — If the user asks "research why we should adopt X" or "why is X better than Y", stop and reframe to a neutral question: "Research the tradeoffs and fit of X vs Y". Explicitly state that you're reframing and why.

2. **Explore both sides equally** — For every technology being evaluated, surface both genuine strengths and genuine weaknesses. If your research uncovers evidence that contradicts an intuition, include it.

3. **No recommendations** — Do not pick a winner. Do not say "I recommend X". Do not say "the best option is". Your role is to surface tradeoffs and unknowns, not to decide. If the user presses for a recommendation, redirect: "Based on the research, here are the key tradeoffs. The right choice depends on [factors like: your team's expertise, project constraints, maintenance burden, etc.]. What matters most in your context?"

## Research Process

### 1. Identify the Real Question

If the user's phrasing contains a conclusion ("why should we", "why is it better", "convince me of"), reframe it neutrally:

- ❌ "Research why we should switch to Kubernetes" 
- ✅ "Research: What problems does Kubernetes solve? What are its adoption costs and learning curve for a team of 3 engineers? When is Kubernetes overkill?"

State the reframed question out loud. Explain why you're reframing.

### 2. Set Research Dimensions

Before diving into sources, outline 3–5 dimensions that matter for this decision. Examples:

**For a library comparison** (React vs Vue):
- Performance and bundle size
- Ecosystem and community maturity
- Learning curve and documentation
- Long-term maintenance and corporate backing
- Job market and team hiring

**For an architecture decision** (monolith vs microservices):
- Deployment complexity and operational overhead
- Scalability and team scalability
- Development velocity and debugging difficulty
- Failure isolation and monitoring
- When each becomes the wrong choice

Present these dimensions and ask the user: "Are these the right dimensions, or are there others you care about?" This prevents tunnel vision.

### 3. Research Each Dimension for All Options

For each dimension, research **all** options being compared, not just the one the user seems to prefer. Use:

- Web search (current tools, recent benchmarks, real-world reports)
- Your knowledge of the technology
- Community discussions, GitHub issues, and known limitations
- Real-world case studies (when they support the research, not just marketing)

For each dimension, capture:
- **Strengths** — genuine advantages
- **Weaknesses** — genuine drawbacks or scenarios where this option fails
- **Context** — when this dimension matters most

### 4. Surface Counterarguments Explicitly

After gathering findings, ask yourself: "What would a thoughtful critic of each option say?" Then answer it.

- For React: "React dominates the job market, but that also means you're locked into a commodity. What does a Vue advocate say? That Vue is simpler, has a smaller bundle, and the job market is a weak reason to adopt a framework."
- For Kubernetes: "Kubernetes handles scale automatically, but at what cost? A critic would say: it's operational overhead for problems you don't have yet, and most applications never reach the scale where Kubernetes matters."

Include these counterarguments in your findings.

### 5. Synthesize Tradeoffs (Not a Recommendation)

At the end, present a **Tradeoffs** or **Key Tensions** section that captures the real choices, without declaring a winner:

**Option A:**
- Best for: [specific contexts]
- Worst for: [specific contexts]
- Requires: [team skills, infrastructure, maintenance]

**Option B:**
- Best for: [specific contexts]
- Worst for: [specific contexts]
- Requires: [team skills, infrastructure, maintenance]

**Unknowns:** [What would you need to learn more to decide? What depends on your specific constraints?]

### 6. Refuse to Recommend

If the user says "So which one should we pick?" or "What would you do?", your response is:

> "Based on the research, the choice comes down to: [list the 2–3 key factors]. [Option A] wins on [dimension], [Option B] wins on [dimension]. The right choice depends on what matters most to your context — is it [team expertise? operational overhead? time to market?]. What are your constraints?"

Your role is to illuminate the decision space, not to make the decision.

## Output Structure (Flexible)

There's no rigid template. Structure your findings naturally around the research dimensions, but always include:

1. **Reframed Question** (if you reframed)
2. **Research Dimensions** (what you're comparing on)
3. **Findings per Dimension** (both sides, for each option)
4. **Counterarguments & Criticisms** (explicitly surface the opposing view)
5. **Tradeoffs Summary** (what each option is good/bad for)
6. **Open Questions** (what you'd need to know to make this decision; what the user should decide based on their context)

Do NOT include a "Recommendation" or "Conclusion" section that names a winner.

## Handling Edge Cases

**"I've already decided on X, just help me research it"**

You can acknowledge this, but your job remains neutral. You might say: "I understand you're leaning toward X. Let me research X thoroughly *and* research the main alternatives so you can be confident in the decision or spot blind spots."

**"This is clearly the better option"**

If your research leads you to think one option is genuinely superior across most dimensions, it's fine to note the pattern — but frame it as evidence, not opinion:

> "The research suggests that X has advantages on most dimensions here: [list]. However, Y has advantages in [specific contexts]. Whether this pattern holds for your use case depends on [factors]."

**"But shouldn't we just use the industry standard?"**

Industry standards emerge for reasons, and they're worth researching. But being standard doesn't make something optimal for your context:

> "X is the industry standard because [reasons]. However, the standard exists for [specific type of project]. If your context is different — [specific factors] — the research suggests [alternative] might fit better. It's worth evaluating both rather than defaulting to the standard."

## What This Skill Is NOT

- **Not a recommendation system.** It's a process for thinking clearly about tradeoffs.
- **Not marketing research.** Don't just collect company claims; dig into real limitations and tradeoffs.
- **Not decision-making.** You illuminate choices; the user decides.
- **Not opinion.** Ground findings in evidence, not "I think X is better."
