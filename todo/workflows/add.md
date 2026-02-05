# Add Task Workflow

Add a TODO task to the project. **All adds create task files** — complexity assessment determines scope and whether the task should be queued or pooled.

## Contents

- [Workflow Steps](#workflow-steps) - Full add process
- [Goal Detection](#goal-detection) - When to redirect to /goal
- [Expected Outcome Requirement](#expected-outcome-requirement) - For medium/large tasks
- [Complexity Assessment](#complexity-assessment) - Determining scope
- [Task File Template](#task-file-template) - Standard structure

---

## Workflow Steps

### Step 1: Read Index Files

Read `docs/todos/queue.md` and `docs/todos/pool.md` to understand current tasks.

### Step 2: Check for Redundancy

Before adding, check if similar task exists:
- Look for tasks with similar titles or descriptions
- Check task files in `tasks/` for overlapping scope

If redundant found:
- Inform user of existing task
- Ask if they want to update existing or if this is distinct
- Use AskQuestion if clarification needed

### Step 3: Check for Goal-Level Work

Before adding as a task, evaluate if this requires goal-level definition.

**Redirect to /goal when:**

| Signal | Example |
|--------|---------|
| Multi-faceted success criteria | "Improve data quality" (multiple dimensions) |
| Investigation needed | "Figure out why X is happening" |
| High stakes/risk | "Refactor core pipeline" |
| Evidence-grounded problem | "Fix the 22 mega-clusters" (specific data) |
| Anti-goals critical | "Must not break existing functionality" |

If goal-level work detected:

```
This appears to require goal-level definition with:
- Multi-dimensional success criteria
- Evidence-grounded problem statement
- Anti-goals to prevent unintended consequences

Would you like to:
- Create as a goal (recommended for complex outcomes)
- Create as a task anyway (if scope is clear)
```

If user selects goal: Direct to [goal skill](../../goal/SKILL.md).

### Step 4: Assess Priority

If user didn't specify `queue` or `pool`, assess based on indicators in SKILL.md.

If unclear, use AskQuestion:
```
Question: "Where should this task go?"
Options:
  - Queue (Scheduled - needs attention soon)
  - Pool (Unscheduled - for later consideration)
```

### Step 5: Assess Complexity

Evaluate the task to determine scope:

| Signal | Threshold | Scope |
|--------|-----------|-------|
| Single deliverable, 1-2 files | Trivial change | small |
| 2-3 deliverables, 3-5 files | Moderate work | medium |
| 4+ deliverables, 6+ files | Substantial work | large |
| Multiple distinct phases | Multi-agent work | large (consider goal type) |

See [Complexity Assessment](#complexity-assessment) for detailed guidance.

### Step 6: Determine Expected Outcome

For **medium** and **large** scope tasks, determine the Expected Outcome category.

See [Expected Outcome Requirement](#expected-outcome-requirement) for details.

| Scope | Expected Outcome |
|-------|------------------|
| small | Optional |
| medium | Required |
| large | Required |

### Step 7: Create Task File

Create task file in `docs/todos/tasks/` with kebab-case name:

1. Use the [Task File Template](#task-file-template) below
2. Set appropriate Type (task/subtask) and Scope
3. Include deliverables and success criteria
4. Set Status to "pending"
5. Set Parent to "none" (unless this is a subtask being created)
6. Add Expected Outcome section (for medium/large scope)
7. Add Goal Reference section (if part of a goal)

### Step 8: Add Link to Index

Add link to appropriate index file:

**For queue.md** (Next section):
```markdown
- [ ] [Task Title](tasks/task-name.md) - scope
```

**For pool.md** (appropriate section):
```markdown
- [Task Title](tasks/task-name.md) - scope
```

### Step 9: Confirm

Report:
- Task file created (path)
- Added to queue.md or pool.md (which section)
- Scope assessment
- Expected Outcome category (if applicable)
- Any redundancy noted

---

## Goal Detection

### When to Redirect to /goal

Evaluate these signals before creating a task:

| Signal | Indicates Goal-Level Work |
|--------|---------------------------|
| **Multi-dimensional success** | Success requires 2+ orthogonal criteria |
| **Evidence-grounded problem** | Specific data points identify the issue |
| **Investigation needed** | Can't specify success criteria without research |
| **High stakes** | Wrong implementation could cause downstream harm |
| **Anti-goals critical** | Important to define what must NOT happen |

### Quick Decision Tree

```
Does the user mention specific evidence/data?
├─ YES → Likely goal-level (evidence-grounded)
└─ NO
    │
    Will success require multiple criteria?
    ├─ YES → Likely goal-level
    └─ NO
        │
        Is investigation needed before knowing success?
        ├─ YES → Goal with Agent-to-define category
        └─ NO → Task is appropriate
```

### How to Suggest Goal

If goal-level work detected:

```
This request appears to need goal-level definition:
- [Reason 1 - e.g., "multi-dimensional success criteria needed"]
- [Reason 2 - e.g., "specific evidence points to grounded problem"]

Goals provide:
- Evidence-grounded success criteria
- Anti-goals to prevent unintended harm
- User approval before implementation

Create as goal? Or proceed as task if scope is clear?
```

---

## Expected Outcome Requirement

For **medium** and **large** scope tasks, determine the Expected Outcome.

### Outcome Categories

| Category | When to Use |
|----------|-------------|
| **Concrete** | Success criteria can be specified now |
| **Agent-to-define** | Investigation required before criteria |

### Determining the Category

Ask:
1. Can I specify measurable success criteria right now?
2. Do I need to investigate before knowing what success looks like?

| Answer | Category |
|--------|----------|
| Yes, criteria known | Concrete |
| No, need investigation | Agent-to-define |

### Adding Expected Outcome

For Concrete tasks:
```markdown
## Expected Outcome

| Field | Value |
|-------|-------|
| Category | Concrete |
| Criteria | [Specific measurable outcome] |
```

For Agent-to-define tasks:
```markdown
## Expected Outcome

| Field | Value |
|-------|-------|
| Category | Agent-to-define |
| Criteria | To be determined after investigation |
| Investigation Focus | [What needs to be investigated] |
```

### Flagging Agent-to-define Tasks

When adding an Agent-to-define task, note in confirmation:

```
Task created: "[Task Title]"
⚠️ Expected Outcome: Agent-to-define

This task requires investigation before implementation.
When implementing, the agent will:
1. Investigate and document findings
2. Propose success criteria
3. Wait for your approval
4. Then implement

This two-phase process ensures criteria match your intent.
```

---

## Complexity Assessment

### Scope Definitions

| Scope | Deliverables | Files | Agent Strategy |
|-------|--------------|-------|----------------|
| **small** | 1-2 | 1-3 | Direct execution |
| **medium** | 3-4 | 4-6 | Single subagent |
| **large** | 5+ | 7+ | Single subagent or breakdown |

### When to Suggest Breakdown

If task has:
- Multiple distinct phases that could be parallelized
- Clear sub-components that are independently valuable
- Scope that would overwhelm a single agent's context

Suggest to user:
```
This task appears large enough to benefit from breakdown into subtasks.
Would you like me to create it as a goal with planned children, or as a single large task?
```

### Examples

**Small scope:**
- "Add docstring to function X" → 1 deliverable, 1 file
- "Fix typo in README" → 1 deliverable, 1 file
- "Update dependency version" → 1 deliverable, 2 files

**Medium scope:**
- "Add logging to ingestion step" → 2-3 deliverables, 3-4 files
- "Create test for validation metrics" → 3 deliverables, 2-3 files

**Large scope:**
- "Implement NPPES integration" → 5+ deliverables, 7+ files
- "Create test suite for validation" → 6+ deliverables, 5+ files
- "Add user authentication" → 8+ deliverables, 10+ files (consider goal)

---

## Task File Template

```markdown
# [Task Title]

[Brief description - 1-2 sentences]

## Meta

| Field | Value |
|-------|-------|
| Status | pending |
| Type | task |
| Scope | [small/medium/large] |
| Parent | none |
| Created | YYYY-MM-DD |

## Goal Reference

(Include if task is part of a goal)

| Field | Value |
|-------|-------|
| Parent Goal | [Goal Title](../goals/goal-file.md) |
| Success Criteria | [Which goal criteria this task addresses] |
| Anti-Goals | [Which goal anti-goals this task must preserve] |

## Expected Outcome

(Required for medium and large scope)

| Field | Value |
|-------|-------|
| Category | Concrete / Agent-to-define |
| Criteria | [Measurable outcome for this task] |

## Context

[Why this task matters, background information]

## Deliverables

- [ ] First deliverable
- [ ] Second deliverable

## Success Criteria

- [ ] How to verify completion
```

### Extended Template (for large/complex tasks)

```markdown
# [Task Title]

[Brief description]

## Meta

| Field | Value |
|-------|-------|
| Status | pending |
| Type | task |
| Scope | large |
| Parent | none |
| Created | YYYY-MM-DD |
| Related | [Links to related docs] |
| Depends On | [Links to prerequisite tasks] |

## Goal Reference

(Include if task is part of a goal)

| Field | Value |
|-------|-------|
| Parent Goal | [Goal Title](../goals/goal-file.md) |
| Success Criteria | [Which goal criteria this task addresses] |
| Anti-Goals | [Which goal anti-goals this task must preserve] |

## Expected Outcome

| Field | Value |
|-------|-------|
| Category | Concrete / Agent-to-define |
| Criteria | [Measurable outcome for this task] |
| Anti-Goals | [What must NOT happen - derived from goal or task-specific] |

## Context

[Detailed background, why this matters]

## Deliverables

### 1. [First Deliverable Group]

[Detailed steps, code examples, specific instructions]

- [ ] Sub-item 1
- [ ] Sub-item 2

### 2. [Second Deliverable Group]

[Continue for each major piece of work]

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `path/to/file.py` | Description |

## Testing Guidance

[How to verify work is complete]

## Success Criteria

- [ ] First criterion
- [ ] Second criterion

## Verification Protocol

(For Concrete* tasks or tasks requiring downstream impact verification)

1. [How to verify criterion 1]
2. [How to verify criterion 2]
3. [How to verify anti-goals preserved]
```
