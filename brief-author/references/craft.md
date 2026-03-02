# Brief Craft

## Contents

- [Core Principles](#core-principles) - Foundational rules for agent briefs
- [Context Density Calibration](#context-density-calibration) - Matching detail level to task complexity
- [File Reference Strategy](#file-reference-strategy) - When and how to use @ references vs inline summaries
- [Framing the Receiving Agent](#framing-the-receiving-agent) - Setting up the agent's mindset
- [Broader Scope Framing](#broader-scope-framing) - Positioning the task within the initiative
- [Handoff Metadata Block](#handoff-metadata-block) - Required receiving-agent instruction block
- [Anti-Patterns](#anti-patterns) - Common brief authoring mistakes
- [Optimization Tips](#optimization-tips) - Making the brief effective for LLM agents

---

## Core Principles

### Self-Contained But Not Bloated

The receiving agent starts with zero context. The brief must carry enough information for it to orient and begin working within 1-2 tool calls of reading the brief. But cramming every detail wastes context window and obscures the task.

### Specific Over Vague

"Continue the refactor" is useless. "Refactor the `conflicts` module by extracting signal detection logic from `pipeline.py` into a new `signals.py` module, following the pattern in `scoring/`" gives a clear starting point.

### Prioritized

If the brief contains multiple items, order by priority. State which items are blocking and which are optional.

### Honest About State

Include what's broken, incomplete, or uncertain. Agents that inherit a clean-looking brief and discover hidden issues waste time diagnosing what the previous agent already knew about.

### Issue-Aware

Reference open issues from the initiative's issues log when relevant. The receiving agent should know what other agents have discovered.

## Context Density Calibration

### Small Task (Single File, Bug Fix, Quick Follow-Up)

Lean brief. Context + Task + Key Files. ~10-30 lines of prompt content.

- Brief context sentence: what was done, what remains
- Specific task with file path
- 1-3 @ file references

### Medium Task (Multi-File Feature, Refactor Phase)

Moderate brief. Full structure minus tangential items. ~30-80 lines.

- Context paragraph covering broader scope and progress
- Task with priority ordering
- 5-10 @ file references with notes on what each contains
- Known issues section if self-audit found anything
- Approach guidance if non-obvious

### Large Task (Multi-Track Feature, Complex Investigation)

Full structure. ~80-150+ lines.

- Thorough context covering the entire initiative, progress, and blockers
- Task broken into phases or tracks with dependencies
- Comprehensive @ references organized by relevance
- Full known issues with categorization
- Detailed approach guidance including subagent strategy
- Reference to initiative issues log

### Over-Sized Brief (Smell)

If the prompt content exceeds ~200 lines, consider splitting into multiple sequential briefs. A brief that tries to cover too much signals the next session will also try to do too much.

## File Reference Strategy

### Use @ References When

- The file exists in the repo and contains information the agent needs
- The file would be too long to summarize inline
- The agent needs to read actual code, not just a description
- Specs, plans, or investigation docs define the work

### Use Inline Summaries When

- The relevant information is a few key facts from a large file
- The file doesn't exist yet (describing what needs to be created)
- The context is about decisions made, not code to read
- Specific lines or behaviors need calling out

### Hybrid Approach (Preferred For Medium+ Tasks)

Reference the file AND provide a brief note:

```
@src/conflicts/pipeline.py - The `run_pipeline()` function currently handles both signal
detection and scoring inline. Lines 145-200 contain the signal logic that needs extraction.
```

### Avoid

- Pasting large code blocks into the brief. Use @ references.
- Referencing files without context. `@src/models.py` alone doesn't tell the agent why it matters.
- Referencing 20+ files. The task may be too large for one session.

## Framing the Receiving Agent

### Continuation Framing

When continuing previous work:

> You are continuing work on [feature/initiative]. The previous session [accomplished X]. This session should [accomplish Y].

### Fresh Start Framing

When starting new work that needs context:

> [Context about what exists]. Your task is to [specific objective].

### Investigation Framing

When analysis precedes action:

> Before implementing changes, investigate [specific question]. Read [files] to understand [aspect]. Then [propose/implement/document] based on findings.

## Broader Scope Framing

When the brief's task is part of an initiative, include scope orientation:

1. **What is the initiative?** Name it, describe it in 1-2 sentences.
2. **What briefs exist?** Reference the overview or list completed/in-progress briefs.
3. **Where are we?** Which briefs are done, which is current, what's upcoming.
4. **What does this brief cover?** Map it to the initiative's progress.

Reference the initiative's overview:

```
This is part of the bundle sharing refactor (@docs/briefs/bundle-sharing-refactor/overview.md).
Briefs 001-003 are complete. This brief covers the next phase. See the overview for full status.
```

### Open Issues Reference

If the initiative has open issues, reference them:

```
The initiative has 2 open issues in @docs/briefs/bundle-sharing-refactor/issues.md.
Issue "Writer identity ambiguity" (important) may affect your work on the matching logic.
```

## Handoff Metadata Block

Every brief must include this block between the metadata header and the prompt content. It instructs the receiving agent on lifecycle management:

```markdown
## Handoff Metadata

This brief is tracked at @docs/briefs/<initiative>/NNN-slug.md
Invoke /brief-receive to register and begin work.
When you finish, update Status to `completed` and fill the Outcome section.
If you discover issues outside your scope, append them to @docs/briefs/<initiative>/issues.md
```

For standalone briefs, adjust the paths:

```markdown
## Handoff Metadata

This brief is tracked at @docs/briefs/YYYY-MM-DD-slug.md
Invoke /brief-receive to register and begin work.
When you finish, update Status to `completed` and fill the Outcome section.
If you discover issues outside your scope, append them to @docs/briefs/issues.md
```

The metadata block is **not optional**. It is the compliance mechanism that ensures the receiving agent follows the `brief-receive` protocol.

## Anti-Patterns

### The Vague Brief

> "Continue working on the feature. Check the recent changes and pick up where I left off."

The receiving agent has no idea what "the feature" is or where "off" was.

### The Code Dump

Pasting hundreds of lines of code instead of using @ references. Wastes context window.

### The Optimistic Summary

Describing previous work as complete and clean when it has gaps or known issues. The receiving agent inherits a false picture.

### The Kitchen Sink

Including every tangential issue and minor observation. The receiving agent can't distinguish primary work from noise. Tangential issues belong in `issues.md`, not inline in the brief.

### The Process-Heavy Brief

Spending half the brief telling the agent how to work instead of what to accomplish. Some orchestration guidance is valuable; excessive process prescription is not.

### Missing Progress State

Describing the task but not where things stand. The agent doesn't know if this is greenfield, partial continuation, or a fix for a failed attempt.

### Missing Issue Context

Authoring a brief for an initiative without reading the existing issues log. The receiving agent may duplicate work or miss known problems.

## Optimization Tips

### Front-Load the Task

Put the core task description near the top. Context is important but the agent should encounter "what to do" early.

### Use Headers

Structure with markdown headers. Agents process structured briefs more reliably than wall-of-text.

### State Completion Criteria

When possible, define what "done" looks like:

> This task is complete when: (1) signal logic extracted to its own module, (2) existing tests pass, (3) new unit tests cover extracted functions.

### Name Things Consistently

Use the same names for modules, functions, and concepts that the codebase uses.

### Flag Landmines

If there are known gotchas (circular imports, fragile tests, environment-specific behavior), call them out explicitly.
