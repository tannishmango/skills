---
name: goal
description: Define rigorous outcome specifications for complex tasks with evidence-grounded success criteria and anti-goals. Use when creating goals, defining expected outcomes, validating goal completion, or when the user mentions success criteria, anti-goals, Goodhart's Law, or outcome definition.
---

# Goal Definition

## Contents

- [Mental Model](#mental-model) - Why goals exist, Goodhart's Law mitigation
- [When to Use](#when-to-use) - Goal vs task distinction, trigger patterns
- [Outcome Categories](#outcome-categories) - Concrete, Agent-to-define, Deferred
- [Goal File Format](#goal-file-format) - Standard structure for goal files
- [Anti-Goals](#anti-goals) - Defining what must NOT happen
- [Action Router](#action-router) - Navigate to correct workflow
- [Workflows](#workflows) - Links to define, investigate, complete

---

## Mental Model

Goals solve the **Goodhart's Law problem** in AI agent orchestration:

> "When a measure becomes a target, it ceases to be a good measure."

### The Problem

When agents define their own success criteria, they gravitate toward:
- Easily measurable things (not necessarily important)
- Things they can achieve (not necessarily valuable)
- Narrow interpretations that technically satisfy criteria while missing the point

### The Solution

Goals enforce structural guardrails:

| Guardrail | Prevents |
|-----------|----------|
| **Evidence grounding** | Invented metrics disconnected from real problems |
| **Multi-dimensional criteria** | Single-metric optimization at expense of others |
| **Explicit anti-goals** | Solutions that technically succeed but cause harm |
| **Approval gates** | Agents evaluating their own success |

### Separation of Concerns

```
DEFINE phase: Agent proposes → User approves criteria
IMPLEMENT phase: Agent executes against approved criteria
VERIFY phase: Check against pre-approved criteria (no moving goalposts)
```

---

## When to Use

### Use `/goal` When

- **Multi-faceted outcome** - Success requires multiple orthogonal criteria
- **Evidence-grounded problem** - Specific data points identify the issue
- **High stakes** - Wrong implementation could cause downstream harm
- **Investigation needed** - Can't specify success criteria without research first
- **Anti-goals critical** - Important to define what must NOT happen

### Use `/todo` When

- **Clear deliverables** - Specific files to create/modify
- **Well-understood scope** - No investigation needed
- **Single-agent work** - Focused task without multi-phase coordination
- **Low risk** - Failure doesn't cascade to other systems

### Keyword Triggers

Goal skill applies when user mentions:
- "success criteria", "expected outcome", "anti-goals"
- "how will we know", "verification", "measurable"
- "root cause", "evidence", "grounded"
- "what must not happen", "constraints", "guardrails"

---

## Outcome Categories

Every goal has an Outcome Category that determines its workflow:

| Category | Definition | Protocol |
|----------|------------|----------|
| **Concrete** | Success criteria derivable from evidence now | Define → Approve → Implement → Verify |
| **Agent-to-define** | Investigation required before criteria can be specified | Investigate → Propose → Approve → Implement → Verify |
| **Concrete\*** | Concrete but requires downstream impact verification | Same as Concrete + downstream check |
| **Deferred** | External dependency prevents progress | Document blockers → Wait |

### Identifying the Category

**Concrete**:
- Evidence exists showing the problem
- Measurable criteria can be derived from that evidence
- Example: "22 mega-clusters exist" → "dissolve 22 mega-clusters"

**Agent-to-define**:
- Problem is observed but root cause unclear
- Need investigation before knowing what success looks like
- Example: "Performance is slow" → investigate first → then define criteria

**Deferred**:
- External blocker prevents progress
- Document what's needed and wait
- Example: "Need API access from vendor"

---

## Goal File Format

Goals live in `docs/todos/goals/` with this structure:

```markdown
# [Goal Title]

[1-2 sentence description grounded in evidence]

## Meta

| Field | Value |
|-------|-------|
| Status | pending / investigating / approved / active / done |
| Outcome Category | Concrete / Agent-to-define / Deferred |
| Confidence | HIGH / MEDIUM / LOW |
| Created | YYYY-MM-DD |

## Problem Statement

### Evidence

- [Specific data point 1]
- [Specific data point 2]

### Root Cause

| Field | Value |
|-------|-------|
| Hypothesis | [What we think is causing this] |
| Confidence | HIGH / MEDIUM / LOW |
| Evidence | [What supports this] |
| Gaps | [What we don't know] |

## Success Definition

### Success Criteria

1. [Measurable criterion derived from evidence]
2. [Second orthogonal criterion]

### Anti-Goals

- Must NOT [constraint 1]
- Must NOT [constraint 2]

## Verification Protocol

1. [How to verify criterion 1]
2. [How to verify criterion 2]

## Work Breakdown

(Added when goal is decomposed into tasks)

- [ ] [Task 1](../tasks/task-1.md)
- [ ] [Task 2](../tasks/task-2.md)
```

### Status Values

| Status | Meaning |
|--------|---------|
| pending | Goal created, not yet approved |
| investigating | Agent-to-define goal, investigation in progress |
| approved | Success criteria approved by user |
| active | Implementation in progress |
| done | Verification complete, archived |

---

## Anti-Goals

Anti-goals are **required** for all non-trivial goals. They define what the solution must NOT do.

### Purpose

| Without Anti-Goals | With Anti-Goals |
|-------------------|-----------------|
| Agent optimizes primary metric | Agent balances primary metric against constraints |
| Narrow interpretation succeeds | Narrow interpretation fails anti-goal check |
| Gaming is invisible | Gaming is caught at verification |

### Good Anti-Goals

```markdown
### Anti-Goals

- Must NOT break legitimate entity linkages (false negatives)
- Must NOT increase processing time by more than 10%
- Must NOT require schema changes to downstream consumers
- Must NOT remove data that valid use cases depend on
```

### Bad Anti-Goals

```markdown
### Anti-Goals

- Must NOT be bad  ← Too vague
- Must NOT have bugs  ← Aspirational, not measurable
- Must NOT take too long  ← No threshold
```

### Deriving Anti-Goals

Ask these questions:
1. What would a malicious implementation do to "succeed" while causing harm?
2. What side effects would make this solution worse than no solution?
3. What existing functionality must be preserved?
4. What downstream systems depend on current behavior?

---

## Action Router

| Pattern | Action | Reference |
|---------|--------|-----------|
| `define [problem]` | Create new goal from evidence | [workflows/define.md](workflows/define.md) |
| `investigate [goal]` | Research Agent-to-define goal | [workflows/investigate.md](workflows/investigate.md) |
| `complete [goal]` | Verify and archive goal | [workflows/complete.md](workflows/complete.md) |
| `list` | Show goals and their status | [List Goals](#list-goals) |
| `status [goal]` | Show goal details and tasks | [Goal Status](#goal-status) |

### List Goals

1. Read `docs/todos/goals/` directory
2. For each goal file, read Meta section
3. Display summary:

```
## Goals

| Status | Goal | Category | Tasks |
|--------|------|----------|-------|
| investigating | [Goal A](goals/goal-a.md) | Agent-to-define | - |
| active | [Goal B](goals/goal-b.md) | Concrete | 2/4 |
| pending | [Goal C](goals/goal-c.md) | Deferred | - |
```

### Goal Status

1. Read goal file
2. Display full details including:
   - Meta (status, category, confidence)
   - Problem Statement (evidence, root cause)
   - Success Criteria and Anti-Goals
   - Work Breakdown progress (if has tasks)

---

## Workflows

Detailed workflows for goal lifecycle:

- [workflows/define.md](workflows/define.md) - Creating new goals with evidence grounding
- [workflows/investigate.md](workflows/investigate.md) - Agent-to-define investigation protocol
- [workflows/complete.md](workflows/complete.md) - Goal verification and archival

---

## Critical Constraints

### 1. No Work Before Goal Approval

| Goal Type | Requirement |
|-----------|-------------|
| Concrete | User must approve success criteria before implementation |
| Agent-to-define | Must complete investigation AND get criteria approved first |
| Deferred | Document blockers, no implementation until unblocked |

### 2. Evidence Grounding

Success criteria MUST reference specific evidence:

| Bad (Invented) | Good (Grounded) |
|----------------|-----------------|
| "Improve matching accuracy" | "Dissolve 22 mega-clusters (>100 records)" |
| "Make it faster" | "Reduce processing time from 45min to <10min" |
| "Fix the data quality" | "Remove 1,774 non-Maine records from NPPES" |

### 3. Multi-Dimensional Criteria

Single-metric goals are Goodhart bait. Require orthogonal criteria:

```markdown
## Success Criteria

1. 22 mega-clusters dissolved  ← Primary metric
2. ownership_concentration fires <25%  ← Secondary measure
3. Top 10 officers are actual owners, not RA services  ← Quality check
```

### 4. Verification Separation

The entity that defines success criteria must NOT be the same one that evaluates:

```
Phase 1: Agent investigates, proposes criteria
Phase 2: User reviews, approves/modifies criteria
Phase 3: Agent implements against APPROVED criteria
Phase 4: Verification against pre-approved criteria (no changing)
```

---

## Integration with TODO Skill

Goals decompose into tasks. The relationship:

```
Goal (outcome definition)
├── Success Criteria (what must be true)
├── Anti-Goals (what must NOT happen)
└── Tasks (how to get there)
    ├── Task A → addresses criteria 1, 2
    └── Task B → addresses criteria 3
```

Tasks reference their parent goal:

```markdown
## Goal Reference

| Field | Value |
|-------|-------|
| Parent Goal | [Goal Title](../goals/goal-file.md) |
| Success Criteria | Criteria 1, 2 |
| Anti-Goals | Anti-goal 1 |
```

See `/todo` skill for task management workflows.
