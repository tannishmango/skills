---
name: give-me-a-prompt
description: Generates context-rich, agent-optimized handoff prompts for seamless transitions between agent chat sessions. Use when ending a session, continuing in a new chat, managing multi-session work, or when the user says "give me a prompt", "handoff", "next agent", "transition prompt", or "continue in new chat". Covers self-audit of current work, broader scope awareness, meta-orchestration guidance, and silent omission surfacing.
---

# Give Me A Prompt

## Contents

- [When To Use](#when-to-use) - Trigger conditions and expected outcome
- [Gate Check](#gate-check) - Assess whether a prompt is warranted before writing one
- [Workflow](#workflow) - End-to-end flow from context gathering through prompt delivery
- [Self-Audit Checklist](#self-audit-checklist) - Critical checks for surfacing omissions and incomplete work
- [Prompt Structure](#prompt-structure) - Template for the generated handoff prompt
- [Meta-Orchestration Guidance](#meta-orchestration-guidance) - How to advise the next agent on approach
- [Clarification Questions](#clarification-questions) - When and how to ask the user for input
- [Tooling Notes](#tooling-notes) - Tool usage within this skill
- [Evaluation Scenarios](#evaluation-scenarios) - Expected behavior for representative invocations
- [Reference Files](#reference-files) - Self-audit patterns, prompt craft, and examples

---

## When To Use

Use this skill when:

- The user asks for a prompt to paste into a new agent chat
- The current session reaches a natural stopping point and work continues in a new session
- The user is managing a multi-session feature, refactor, investigation, or migration

Expected outcome: A single, self-contained, copyable prompt block that the user pastes into a fresh agent chat. The prompt carries enough context for the new agent to continue work without re-discovery.

## Gate Check

Before writing any prompt, assess:

1. **Is there actionable work for another agent?** If this session completed everything, say so.
2. **Can an agent do the next step?** If the user needs to wait on CI, check external systems, make business decisions, or do something non-automatable, communicate that instead.
3. **Is the scope non-trivial?** Don't generate a handoff prompt for one-liner tasks. Offer a brief suggestion instead.

If the gate fails, tell the user why and suggest what they should do next. Do not generate a prompt just because the skill was invoked.

## Workflow

### 1) Determine Task Source

The task for the new agent comes from one of these (priority order):

1. **Explicit user instructions**: The user stated what the prompt should cover.
2. **Implicit from current chat**: No explicit instructions. Infer what should happen next from the session's work, open tasks, deferred items, and broader scope.
3. **Nothing actionable**: Neither source yields meaningful work. Fail the gate.

When inferring implicitly, review the full conversation arc: what was planned, what was implemented, what was deferred, what broke, and what was discovered along the way.

### 2) Establish Broader Scope

Determine whether this task fits into a larger effort:

- Is this part of a feature, refactor, investigation, upgrade, migration, or multi-PR initiative?
- Does a plan, spec, task list, or investigation doc exist? Where does this task fall in overall progress?
- What context from the broader scope should the next agent have?

If broader scope is not stated and not obvious, consider asking the user. If scope is genuinely isolated, note that in the prompt so the next agent doesn't waste time looking for a parent plan.

### 3) Self-Audit Current Work

**This is the most critical step.** Before writing the prompt, honestly audit what the current session accomplished and what it did not.

Run through the [Self-Audit Checklist](#self-audit-checklist). For detailed patterns and common silent-omission categories, read `references/self-audit.md`.

Surface findings explicitly. Do not silently pass incomplete work to the next agent.

### 4) Scope the Prompt

Combine the task, broader context, and self-audit findings:

- **Primary scope**: The main task(s) for the next agent.
- **Preliminary items**: Things to address first (incomplete work, bugs, silent omissions from self-audit) if they fit scope or are quick wins.
- **Tangential items**: Discovered issues outside the prompt's scope. Include as an aside for the agent to document or assess fit, not to solve, unless scope is small enough to absorb them.
- **Excluded items**: Things that don't belong. Mention to the user outside the prompt if they need attention.

### 5) Consider Meta-Orchestration

Evaluate how the next agent should approach the work. See [Meta-Orchestration Guidance](#meta-orchestration-guidance). Only include orchestration guidance when task complexity genuinely benefits from it.

### 6) Ask Clarifications If Needed

See [Clarification Questions](#clarification-questions). Only ask when the prompt would be meaningfully better with user input.

### 7) Write and Present the Prompt

Write the prompt using [Prompt Structure](#prompt-structure). Present it in a fenced code block so the user can copy it directly.

After the code block, provide a brief companion summary:

- What the prompt covers
- Anything excluded and why
- Items that need user attention but aren't in the prompt

## Self-Audit Checklist

Run these checks against the current session's work. For detailed guidance, read `references/self-audit.md`.

| Check | What to look for |
| --- | --- |
| **Completeness** | Were all planned/requested items implemented? If anything was skipped, why? |
| **Silent omissions** | Did the agent choose a simpler path without surfacing the tradeoff? Were spec requirements quietly dropped? |
| **Partial implementations** | Stubbed functions, TODO comments, placeholder logic, hardcoded values needing follow-up? |
| **Error handling** | Were error paths implemented or just happy paths? |
| **Edge cases** | Were known edge cases handled or deferred? |
| **Test coverage** | Were tests written? Are there gaps? |
| **Open questions** | Unresolved design questions or ambiguities that were worked around? |
| **Discovered issues** | Bugs or problems found in existing code? Fixed or just noted? |
| **Subagent blind spots** | If subagents were used, was their work fully reviewed? |
| **Scope decisions** | Did the agent explicitly reduce scope? Was the user informed? |

Categorize each finding as:

- **Must include in prompt** - the next agent needs to handle this
- **Mention to user** - needs user decision, doesn't belong in the prompt
- **Document for later** - not urgent, but shouldn't be lost

## Prompt Structure

Adapt sections based on relevance. Not every section is needed for every prompt. Read `references/prompt-craft.md` for detailed guidance and `references/examples.md` for concrete examples.

```
## Context

[What broader feature/refactor/investigation this is part of, if any]
[Overall progress: what has been completed, what remains]
[What the previous agent session accomplished, with specifics]

## Task

[Clear, specific description of what this agent should do]
[Priority ordering if multiple items]
[Preliminary items to address first, if any]

## Key Files and References

[@file references the agent should read to understand current state]
[@doc references for specs, plans, task lists, or investigations]
[Any new files created in the previous session that are relevant]

## Known Issues and Considerations

[Items from self-audit: incomplete work, bugs found, silent omissions]
[Categorized: must-fix-first / include-in-scope / document-for-later]

## Approach Guidance

[Should the agent plan first, analyze first, or dive in?]
[Should it use subagents for parallel tracks?]
[Suggested breakdown if the task is complex]
[Specific tools or capabilities to leverage]

## Tangential Items

[Issues discovered outside the primary scope]
[Instruct agent to document these or assess fit]
```

For simple follow-up tasks, collapse to just Context + Task + Key Files. For complex multi-track work, use the full structure. Match prompt density to task complexity.

## Meta-Orchestration Guidance

Include approach guidance in the prompt when the task benefits from it:

- **Plan first**: Task is ambiguous, touches many files, or involves architectural decisions. Instruct the agent to create or review a plan before coding.
- **Subagent parallelism**: Task has independent tracks (backend + frontend, multiple unrelated modules). Suggest parallel subagents.
- **Analysis first**: Task requires understanding existing behavior, patterns, or data before changes. Instruct investigation before implementation.
- **Incremental commits**: Task is large. Suggest committed checkpoints rather than one massive change.
- **Tool awareness**: Reference platform capabilities the agent should leverage (explore subagents for codebase discovery, TodoWrite for tracking multi-step work, plan mode for design decisions).

Do not over-prescribe. A simple bug fix does not need orchestration guidance.

## Clarification Questions

Ask the user when:

- Broader scope is ambiguous and materially affects the prompt
- Multiple plausible next steps exist and choosing wrong wastes the next session
- Self-audit revealed issues where user preference on handling is unclear
- The user's intent for the next agent is genuinely ambiguous

Do not ask:

- For process compliance or to appear thorough
- When context provides a reasonable answer
- When the question can safely be deferred to the next agent

Use `AskQuestion` for structured choices when available; ask conversationally for open-ended input.

## Tooling Notes

- No external packages or scripts required.
- Use `AskQuestion` for structured clarification when available.
- Use `TodoWrite` to track audit findings if the list is complex.
- MCP references: **N/A**.
- Script intent: **N/A**.

## Evaluation Scenarios

### Scenario 1: Explicit Handoff With Broader Scope

**Input**: User says "give me a prompt to continue implementing the scoring refactor in a new chat." The current session completed 2 of 5 tasks from a plan.

**Expected behavior**:

- Prompt references the plan and positions the task as 3-of-5
- Self-audit surfaces any gaps in the 2 completed tasks
- Prompt includes @ references to the plan and changed files
- Meta-orchestration guidance is included if task 3 is complex

### Scenario 2: Implicit Handoff (No Explicit Instructions)

**Input**: User invokes the skill with no task description. The current session implemented a feature and there are clear next steps from the plan.

**Expected behavior**:

- Agent infers next steps from the session's work and any referenced plan
- Self-audit runs and surfaces any silent omissions from the current session
- Prompt is generated for the inferred next task with full context

### Scenario 3: Gate Check Failure

**Input**: User invokes the skill. The current session completed all work and there's nothing actionable remaining.

**Expected behavior**:

- Agent does NOT generate a prompt
- Agent communicates that everything is complete and no handoff is needed
- If there are minor follow-ups (docs, cleanup), agent mentions them but doesn't generate a full handoff prompt for trivial work

### Scenario 4: Silent Omission Surfacing

**Input**: The current session was tasked with implementing a feature per spec. The agent implemented a simpler version (e.g., hardcoded values instead of configurable, happy path only) without mentioning the simplification.

**Expected behavior**:

- Self-audit catches the gap between spec and implementation
- The finding is surfaced in the prompt's Known Issues section
- The prompt categorizes it as must-fix-first or include-in-scope depending on severity

## Reference Files

- [references/self-audit.md](references/self-audit.md) - Detailed self-audit patterns, common silent-omission categories, subagent visibility gaps, and how to surface findings
- [references/prompt-craft.md](references/prompt-craft.md) - Prompt engineering for agent handoffs, context density calibration, anti-patterns, and @ reference strategy
- [references/examples.md](references/examples.md) - Concrete handoff prompts at small, medium, and large complexity levels
d