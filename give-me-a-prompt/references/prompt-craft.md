# Prompt Craft for Agent Handoffs

## Contents

- [Core Principles](#core-principles) - Foundational rules for handoff prompts
- [Context Density Calibration](#context-density-calibration) - Matching detail level to task complexity
- [File Reference Strategy](#file-reference-strategy) - When and how to use @ references vs inline summaries
- [Framing the New Agent](#framing-the-new-agent) - Setting up the agent's mindset and orientation
- [Broader Scope Framing](#broader-scope-framing) - Positioning the task within a larger effort
- [Anti-Patterns](#anti-patterns) - Common handoff prompt mistakes
- [Prompt Optimization Tips](#prompt-optimization-tips) - Making the prompt effective for LLM agents

---

## Core Principles

### Self-Contained But Not Bloated

The new agent starts with zero context. The prompt must carry enough information for the agent to orient itself and begin working without a re-discovery phase. But cramming in every detail wastes context window and obscures the actual task.

Rule of thumb: the new agent should be able to start its first meaningful action within 1-2 tool calls of reading the prompt. If it needs to read 10 files just to understand what the prompt is asking, the prompt lacks context. If the prompt is 500 lines of pasted code, it's bloated.

### Specific Over Vague

"Continue the refactor" is useless. "Refactor the `conflicts` module by extracting signal detection logic from `pipeline.py` into a new `signals.py` module, following the pattern established in the `scoring/` package" gives the agent a clear starting point.

### Prioritized

If the prompt contains multiple items, order them by priority. State which items are blocking and which are optional. The new agent should know what to do first without guessing.

### Honest About State

Include what's broken, incomplete, or uncertain. Agents that inherit a clean-looking prompt and then discover hidden issues waste time diagnosing what the previous agent already knew about.

## Context Density Calibration

### Small Task (Single File, Bug Fix, Quick Follow-Up)

Lean prompt. Context + Task + Key Files. Maybe 10-30 lines.

- Brief context sentence: what was done, what remains
- Specific task with file path
- 1-3 @ file references

### Medium Task (Multi-File Feature Continuation, Refactor Phase)

Moderate prompt. Full structure minus tangential items. 30-80 lines.

- Context paragraph covering broader scope and progress
- Task with priority ordering
- 5-10 @ file references with brief notes on what each contains
- Known issues section if self-audit found anything
- Approach guidance if non-obvious

### Large Task (Multi-Track Feature, Complex Investigation, Architecture Change)

Full structure. 80-150+ lines.

- Thorough context covering the entire initiative, progress, and blockers
- Task broken into phases or tracks with dependencies noted
- Comprehensive @ references organized by relevance
- Full known issues with categorization
- Detailed approach guidance including subagent strategy
- Tangential items section

### Over-Sized Prompt (Smell)

If the prompt exceeds ~200 lines, consider whether the task should be split into multiple sequential prompts. A prompt that tries to cover too much signals that the next agent's session will also try to do too much.

## File Reference Strategy

### Use @ References When

- The file exists in the repo and contains information the agent needs
- The file would be too long to summarize inline
- The agent needs to read the actual code, not just a description of it
- Specs, plans, or investigation docs exist that define the work

### Use Inline Summaries When

- The relevant information is a few key facts from a large file
- The file doesn't exist yet (describing what needs to be created)
- The context is about decisions made, not code to read
- You need to call out specific lines or behaviors that the agent might miss in a full file read

### Hybrid Approach (Preferred For Medium+ Tasks)

Reference the file AND provide a brief note on what the agent should pay attention to:

```
@src/conflicts/pipeline.py - The `run_pipeline()` function currently handles both signal
detection and scoring inline. Lines 145-200 contain the signal logic that needs extraction.
```

This gives the agent the pointer and the context, reducing round-trips.

### Avoid

- Pasting large code blocks into the prompt. Use @ references instead.
- Referencing files without context. `@src/models.py` alone doesn't tell the agent why it matters.
- Referencing too many files. If you're listing 20+ files, the task may be too large for one session.

## Framing the New Agent

### Continuation Framing

When the task is a continuation of previous work, open with that framing:

> You are continuing work on [feature/refactor/investigation]. The previous session [accomplished X]. This session should [accomplish Y].

This immediately orients the agent as a continuation rather than starting fresh.

### Fresh Start Framing

When the task is new work that happens to need context from a previous session:

> [Context about what exists]. Your task is to [specific objective].

### Investigation Framing

When the task requires analysis before action:

> Before implementing changes, investigate [specific question]. Read [files] to understand [aspect]. Then [propose/implement/document] based on findings.

## Broader Scope Framing

When the prompt's task is part of a larger effort, include a scope orientation section that answers:

1. **What is the overall initiative?** Name it and describe it in 1-2 sentences.
2. **What phases/tasks exist?** List or reference the plan/task list.
3. **Where are we?** Which phases are done, which is current, which are upcoming.
4. **What does this prompt's task correspond to?** Map it to the plan.

This prevents the new agent from either (a) treating the task as isolated and missing dependencies, or (b) trying to solve the entire initiative in one session.

If the broader scope has a tracking document or task list, reference it:

```
This task is part of the asset value score redesign (@openspec/changes/redesign-asset-value-score/tasks.md).
Tasks 1-3 are complete. This prompt covers Task 4. Tasks 5-6 will follow in subsequent sessions.
```

## Anti-Patterns

### The Vague Handoff

> "Continue working on the feature. Check the recent changes and pick up where I left off."

The new agent has no idea what "the feature" is, what was changed, or where "off" was. It will spend its entire session discovering context.

### The Code Dump

Pasting hundreds of lines of code into the prompt instead of using file references. Wastes context window and makes the task description hard to find.

### The Optimistic Summary

Describing the previous session's work as complete and clean when it has gaps, silent omissions, or known issues. The new agent inherits a false picture and builds on a shaky foundation.

### The Kitchen Sink

Including every tangential issue, every minor code quality observation, and every possible future task. The prompt becomes overwhelming and the new agent can't distinguish primary work from noise.

### The Process-Heavy Prompt

Spending half the prompt telling the agent how to work ("first, create a plan, then review the plan, then create todos for the plan, then...") instead of describing what to accomplish. Some orchestration guidance is valuable; excessive process prescription is not.

### Missing Progress State

Describing the task but not where things stand. The agent doesn't know if this is greenfield, a continuation with partial work done, or a fix for something that was attempted and failed.

## Prompt Optimization Tips

### Front-Load the Task

Put the core task description near the top. Context is important but the agent should encounter "what to do" early, then "background" and "considerations" after.

### Use Headers

Structure with markdown headers so the agent can parse sections. Agents process structured prompts more reliably than wall-of-text prompts.

### Be Explicit About Completion Criteria

When possible, state what "done" looks like:

> This task is complete when: (1) signal detection logic is extracted to its own module, (2) existing tests pass, (3) new unit tests cover the extracted functions.

### Name Things Consistently

Use the same names for modules, functions, and concepts that the codebase uses. Don't paraphrase or rename things in the prompt that have established names in the code.

### Flag Landmines

If there are known gotchas (circular imports, fragile tests, environment-specific behavior), call them out explicitly rather than hoping the new agent discovers them gracefully.
