---
name: give-me-a-walkthrough
description: Generates an interactive, self-contained HTML walkthrough artifact for any skill, workflow, concept, or tool. Opens in the browser as a multi-section guided tour with navigation, interactive exercises, and live demos. Use when a user wants to understand a skill, learn a workflow, explore a concept interactively, or when they say "walkthrough", "tour me through", "show me how", "interactive guide", or "give me a walkthrough".
---

# Give Me A Walkthrough

## Contents

- [When To Use](#when-to-use) - Trigger conditions
- [What You're Building](#what-youre-building) - The artifact and its purpose
- [Workflow](#workflow) - End-to-end steps from intake to delivery
- [Anatomy Of A Great Walkthrough](#anatomy-of-a-great-walkthrough) - What separates good from great
- [Design Mandate](#design-mandate) - Creative freedom with guardrails
- [Evaluation Scenarios](#evaluation-scenarios) - Expected behavior for representative invocations
- [Reference Files](#reference-files) - HTML architecture patterns

---

## When To Use

Invoke when:

- The user asks for a walkthrough, tour, or interactive guide for anything
- The user wants to understand a skill, workflow, concept, tool, or codebase area
- The user says "give me a walkthrough", "tour me through X", "show me how X works", "interactive guide for X"
- A complex skill or workflow would benefit from a structured, explorable presentation over a wall of text

## What You're Building

A single self-contained HTML file that:

- Opens directly in the browser (`open /tmp/walkthrough.html`)
- Requires no server, no build step, no dependencies beyond what CDNs provide
- Guides the user through the subject in digestible, navigable sections
- Uses interactivity to teach — not just display

The artifact is a **teaching tool**, not a documentation page. The user should learn by doing, not just reading.

## Workflow

### 1) Understand the Subject

Before designing anything, deeply understand what you're walking through:

- What is the core concept or workflow?
- What are the key decision points, steps, or components?
- What would a first-time user most likely misunderstand?
- What's the most satisfying "aha" moment to engineer?

If the subject is a skill, read it fully. If it's a workflow, trace it end-to-end. If it's a concept, identify its mental model.

### 2) Plan the Sections

Design the section arc before writing HTML. A walkthrough is a narrative:

- **Opening section**: Orient the user. What is this? Why does it matter? What will they learn?
- **Core sections**: Each covers one distinct concept, step, or component. 4–8 sections is typical.
- **Interactive sections**: At least one section should require the user to do something — click, toggle, choose, reveal, build.
- **Closing section**: Quick reference, summary, or "what's next". Leave the user with something they can return to.

Sections should build on each other. Each section should feel like a natural next step from the previous one.

### 3) Design the Experience

Commit to a design direction before writing a line of HTML. See [Design Mandate](#design-mandate).

The design should:
- Match the tone and nature of the subject (a debugging workflow feels different from a creative tool)
- Be immediately distinctive — someone should recognize this as intentionally designed
- Use typography, color, and motion to guide attention, not decorate

### 4) Build the Artifact

Write the HTML file. See [references/html-patterns.md](references/html-patterns.md) for proven structural patterns.

Key implementation requirements:

- **Self-contained**: All CSS, JS, and fonts inline or from CDN. No local file dependencies.
- **Section navigation**: Sidebar or top nav that shows progress and allows jumping between sections
- **Progress tracking**: User should know where they are and how far they've gone
- **Interactivity**: At least 2–3 interactive moments (toggles, reveals, quizzes, builders, simulators)
- **Responsive to interaction**: State changes should feel immediate and satisfying
- **Copyable outputs**: If the walkthrough produces something (a prompt, a command, a config), make it copyable

### 5) Deliver

Write the file to `/tmp/[subject-slug]-walkthrough.html` and open it:

```bash
open /tmp/[subject-slug]-walkthrough.html
```

Tell the user the file path so they can reopen it later.

## Anatomy Of A Great Walkthrough

These are the qualities that separate a great walkthrough from a mediocre one:

### Teaches by doing, not just showing

The best sections make the user interact to discover the answer, not just read it. Examples:
- "Click the scenario that passes the gate check" (not "here are the gate check rules")
- "Toggle sections on/off to see how prompt density changes" (not "small tasks use fewer sections")
- "Run the self-audit to reveal what was missed" (not "here are the silent omission categories")

### Has a clear narrative arc

The sections tell a story. The user starts confused and ends confident. Each section resolves one question and opens the next.

### Uses the right level of density

Not every section needs to be interactive. Some concepts are best explained with a well-designed static layout. Match the format to the content.

### Makes the subject feel approachable

Even complex workflows should feel manageable by the end. The walkthrough should reduce cognitive load, not add to it.

### Has a memorable closing

The final section should give the user something to take away: a quick reference card, a cheat sheet, a summary they'll want to screenshot.

## Design Mandate

**Full creative freedom. No prescribed aesthetic.**

Every walkthrough should look and feel like it was designed specifically for its subject. Do not reuse color schemes, font pairings, or layout patterns from previous walkthroughs.

Before writing HTML, commit to a design direction:

- What is the emotional tone of this subject? (precise/technical, playful/exploratory, serious/authoritative, warm/approachable)
- What visual metaphor fits? (terminal/code aesthetic, editorial magazine, dashboard, notebook, game UI, etc.)
- What typography pairing serves the content?
- What color palette fits the tone — and is it dark, light, or something unexpected?

The design should feel **inevitable** for the subject. A walkthrough of a debugging workflow should feel different from a walkthrough of a creative tool.

**Non-negotiable design quality bars** (regardless of aesthetic direction):

- Typography must be intentional — avoid generic system fonts
- Color palette must be cohesive — not random
- Interactive states must feel responsive and satisfying
- Layout must guide the eye — use hierarchy, spacing, and contrast deliberately
- The artifact must look like something a skilled designer made, not a default template

See [references/html-patterns.md](references/html-patterns.md) for structural patterns that work across design directions.

## Evaluation Scenarios

### Scenario 1: Skill Walkthrough

**Input**: "Give me a walkthrough of the `give-me-a-prompt` skill."

**Expected behavior**:
- Agent reads the skill fully before designing
- Sections map to the skill's key concepts (gate check, self-audit, prompt structure, anti-patterns)
- At least one interactive exercise (e.g., scenario quiz, prompt builder, omission reveal)
- Design feels appropriate to the subject (agent workflow tooling)
- File opens in browser and all interactions work

### Scenario 2: Workflow Walkthrough

**Input**: "Walk me through how our Alembic migration workflow works."

**Expected behavior**:
- Agent reads the alembic-migrations skill and any relevant docs
- Sections cover the workflow steps in order
- Interactive elements simulate or demonstrate key decision points
- Design is distinct from Scenario 1 — different aesthetic, different feel
- Closing section is a quick reference the user can return to

### Scenario 3: Concept Walkthrough

**Input**: "Give me an interactive walkthrough of what self-audit means in the context of agent handoffs."

**Expected behavior**:
- Agent focuses on the concept, not a full skill tour
- Sections build the mental model progressively
- Interactive "spot the omission" or categorization exercises
- Shorter artifact (3–5 sections) appropriate to the narrower scope
- Design matches the focused, precise nature of the subject

## Reference Files

- [references/html-patterns.md](references/html-patterns.md) - Structural patterns for multi-section HTML walkthroughs: navigation, section switching, interactive components, and delivery
