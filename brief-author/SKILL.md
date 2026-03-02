---
name: brief-author
description: Authors persistent work briefs for agent-to-agent handoffs with initiative management and mandatory issue capture. Use when ending a session, handing off to another agent, managing multi-session features, or when the user says "give me a prompt", "brief", "handoff", "next agent", or "continue in new chat". Writes briefs to docs/briefs/ with lifecycle tracking, self-audit, and cross-agent awareness.
---

# Brief Author

## Contents

- [When To Use](#when-to-use) - Trigger conditions and expected outputs
- [Gate Check](#gate-check) - Pre-flight checks including cross-agent awareness
- [Workflow](#workflow) - End-to-end flow from audit through file creation
- [Self-Audit Summary](#self-audit-summary) - Mandatory audit with issue persistence
- [Meta-Orchestration Guidance](#meta-orchestration-guidance) - How to advise the receiving agent on approach
- [Clarification Questions](#clarification-questions) - When to ask the user for input
- [Tooling Notes](#tooling-notes) - Tool usage within this skill
- [Evaluation Scenarios](#evaluation-scenarios) - Expected behavior for representative invocations
- [Reference Files](#reference-files) - Formats, self-audit patterns, craft guidance, examples

---

## When To Use

Use this skill when:

- The user asks for a prompt to paste into a new agent chat
- The current session reaches a natural stopping point and work continues in a new session
- The user is managing a multi-session feature, refactor, investigation, or migration
- The user says "give me a prompt", "brief", "handoff", "next agent", or "continue in new chat"

Expected outputs:

1. A **brief file** written to `docs/briefs/` with metadata, prompt content, and outcome placeholder
2. Any discovered issues **appended to the issues log** (mandatory, not optional)
3. The **initiative overview updated** (if part of an initiative)
4. The prompt content **presented in a fenced code block** for the user to copy-paste

## Gate Check

Before writing any brief, assess:

1. **Is there actionable work for another agent?** If this session completed everything, say so.
2. **Can an agent do the next step?** If the user needs to wait on CI, external systems, or business decisions, communicate that instead.
3. **Is the scope non-trivial?** Don't generate a brief for one-liner tasks. Offer a brief suggestion instead.
4. **Cross-agent awareness**: If `docs/briefs/` exists with a relevant initiative, **read its overview.md and issues.md first**. This gives you awareness of what other agents accomplished and what issues they found. Do not write a brief in ignorance of existing initiative context.

If the gate fails, tell the user why and suggest what they should do next.

## Workflow

### 1) Determine Task Source

The task for the new agent comes from one of these (priority order):

1. **Explicit user instructions**: The user stated what the brief should cover.
2. **Implicit from current chat**: Infer next steps from the session's work, open tasks, deferred items, and broader scope.
3. **Nothing actionable**: Fail the gate.

### 2) Resolve Initiative Context

Check `docs/briefs/` for an existing initiative relevant to the current work.

- **Initiative exists**: Read its `overview.md` and `issues.md`. Note the current brief count to determine the next sequence number.
- **No initiative exists**: Ask the user whether this is part of a new initiative or standalone work.
  - New initiative: Create the initiative directory with `overview.md` and `issues.md`.
  - Standalone: The brief will be written as a date-prefixed file at the `docs/briefs/` root.

For directory structure and naming conventions, read [references/formats.md](references/formats.md).

### 3) Self-Audit Current Work

**This is the most critical step.** Before writing the brief, honestly audit what the current session accomplished and what it did not.

Run through the self-audit checklist. For detailed patterns and common silent-omission categories, read [references/self-audit.md](references/self-audit.md).

Categorize each finding and handle as follows:

| Category | Action |
| --- | --- |
| **Must include in brief** | Include in the brief's Known Issues section |
| **Mention to user** | Tell the user AND append to issues.md |
| **Document for later** | **Mandatory append to issues.md** |

The "Document for later" category is a **file write, not a verbal suggestion**. Every finding in categories 2 and 3 must be persisted.

### 4) Write Issues to Log

Append all findings from self-audit categories 2 and 3 to the appropriate `issues.md`:

- Initiative work: append to `docs/briefs/<initiative>/issues.md`
- Standalone work: append to `docs/briefs/issues.md`

This step is **not optional**. If the self-audit found no issues in categories 2 or 3, skip this step. Otherwise, every finding gets written.

For the issues log entry format, read [references/formats.md](references/formats.md).

### 5) Scope the Brief

Combine the task, broader context, and self-audit findings:

- **Primary scope**: The main task(s) for the receiving agent.
- **Preliminary items**: Things to address first (incomplete work, bugs, must-fix issues from self-audit).
- **Tangential items**: Issues outside scope. These are already persisted in issues.md. Reference them in the brief as an aside, not as tasks.

### 6) Consider Meta-Orchestration

Evaluate how the receiving agent should approach the work. Only include guidance when task complexity genuinely benefits from it:

- **Plan first**: Task is ambiguous, touches many files, or involves architectural decisions.
- **Subagent parallelism**: Task has independent tracks that can be developed concurrently.
- **Analysis first**: Task requires understanding existing behavior before changes.
- **Incremental commits**: Task is large enough to warrant committed checkpoints.

Do not over-prescribe. A simple bug fix does not need orchestration guidance.

### 7) Write Brief File

Create the numbered brief file in the initiative directory (or standalone file at root). For the complete file format, read [references/formats.md](references/formats.md).

The brief file must include:

1. **Metadata header**: Status (`drafted`), created date, parent link
2. **Handoff metadata block**: File path reference and `/brief-receive` invocation instruction
3. **Prompt content**: The actual brief (context, task, key files, known issues, approach guidance)
4. **Outcome section**: Empty placeholder for the receiving agent to fill

For prompt content construction guidance, read [references/craft.md](references/craft.md).

### 8) Update Initiative Overview

If part of an initiative, add a row to the overview's status table:

```markdown
| N | [NNN-slug](NNN-slug.md) | drafted | [one-line summary] |
```

Update the open issues count if issues were written in step 4.

### 9) Present Brief to User

Present the prompt content section of the brief in a **fenced code block** so the user can copy it directly.

After the code block, provide a brief companion summary:

- What the brief covers
- Anything excluded and why
- The file path where the brief was written
- Any items that need user attention but aren't in the brief

## Self-Audit Summary

The self-audit checks for completeness, silent omissions, partial implementations, error handling gaps, test coverage, open questions, discovered issues, subagent blind spots, and scope decisions.

The critical behavioral change from the old workflow: **every finding must be either included in the brief or written to the issues log**. Nothing is communicated only verbally.

For the full checklist, detection techniques, and silent omission categories, read [references/self-audit.md](references/self-audit.md).

## Meta-Orchestration Guidance

Include approach guidance in the brief when the task benefits from it. Common patterns:

| Pattern | When | Guidance |
| --- | --- | --- |
| Plan first | Ambiguous scope, many files, architectural decisions | Instruct agent to plan before coding |
| Subagent parallelism | Independent tracks (backend + frontend, unrelated modules) | Suggest parallel subagents with shared model definition first |
| Analysis first | Behavior understanding needed before changes | Instruct investigation before implementation |
| Incremental commits | Large task | Suggest committed checkpoints |

Reference platform capabilities the agent should leverage (explore subagents, TodoWrite, plan mode).

## Clarification Questions

Ask the user when:

- Initiative context is ambiguous and materially affects the brief
- Multiple plausible next steps exist and choosing wrong wastes the next session
- Self-audit revealed issues where user preference on handling is unclear

Do not ask for process compliance or when context provides a reasonable answer.

Use `AskQuestion` for structured choices when available.

## Tooling Notes

- No external packages or scripts required.
- Use `AskQuestion` for structured clarification when available.
- Use `TodoWrite` to track audit findings if the list is complex.
- Use `Glob` to scan `docs/briefs/` for existing initiatives and brief files.
- MCP references: **N/A**.
- Script intent: **N/A**.

## Evaluation Scenarios

### Scenario 1: First Brief in New Initiative

**Input**: Agent completes feature work, invokes skill. No `docs/briefs/` directory exists.

**Expected behavior**:

- Skill creates `docs/briefs/`, `docs/briefs/<initiative>/`, `overview.md`, `issues.md`
- Asks user for initiative name
- Writes `001-<slug>.md` with status `drafted`
- Updates overview with one row
- Presents prompt in fenced code block

### Scenario 2: Continuation Within Initiative

**Input**: Agent receives brief referencing an existing initiative. Completes work, invokes skill.

**Expected behavior**:

- Reads existing `overview.md` and `issues.md` (gate check)
- Determines next sequence number from existing briefs
- Self-audit runs and surfaces gaps
- Writes next numbered brief, updates overview
- Brief references issues found by previous agents if relevant

### Scenario 3: Issue Discovery and Persistence

**Input**: Agent finds a critical bug outside scope during self-audit.

**Expected behavior**:

- Writes the issue to `issues.md` (mandatory)
- Includes it in the brief's Known Issues section (both, not either/or)
- Categorizes severity

### Scenario 4: Parallel Track Spawning

**Input**: Agent determines next work has two independent tracks.

**Expected behavior**:

- Writes two brief files (both referencing current brief as parent)
- Updates overview with both entries
- Suggests subagent parallelism in approach guidance

### Scenario 5: Standalone Work

**Input**: User invokes skill for a one-off task not part of any initiative.

**Expected behavior**:

- Creates `docs/briefs/` if needed
- Writes a date-prefixed standalone brief at the root
- No initiative directory or overview created

### Scenario 6: Cross-Agent Awareness

**Input**: Agent invokes skill for an initiative where a previous agent logged issues.

**Expected behavior**:

- Gate check reads the issues log
- Generated brief references relevant open issues
- Receiving agent is made aware of issues found by other agents

## Reference Files

- [references/formats.md](references/formats.md) - File format specs for brief files, initiative overview, issues log, standalone briefs, and the docs/briefs/ README template
- [references/self-audit.md](references/self-audit.md) - Self-audit patterns, silent omission categories, mandatory issue persistence, cross-agent awareness, and detection techniques
- [references/craft.md](references/craft.md) - Prompt engineering for agent briefs, context density calibration, anti-patterns, handoff metadata block, and file reference strategy
- [references/examples.md](references/examples.md) - Concrete brief examples at small, medium, and large complexity levels showing file-based workflow with initiative context
