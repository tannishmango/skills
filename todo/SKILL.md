# TODO Manager

Manage project TODOs in `docs/todos/`. Add, list, promote, complete, breakdown, and implement tasks.

## Contents

- [Goal vs Task](#goal-vs-task) - When to use /goal vs /todo
- [Critical: User Confirmation Required](#critical-user-confirmation-required) - NEVER auto-complete
- [File Structure](#file-structure) - Where TODOs live, file purposes
- [Action Router](#action-router) - Determine action from user input
- [Quick Workflows](#quick-workflows) - Inline: list, promote, remove
- [Detailed Workflows](#detailed-workflows) - Links to add, complete, implement, breakdown
- [Task File Format](#task-file-format) - Standard task structure
- [Task Hierarchy](#task-hierarchy) - Parent/children relationships
- [Examples](#examples) - Common invocation patterns

---

## Goal vs Task

### When to Use `/goal`

Use the [goal skill](../goal/SKILL.md) when:

| Signal | Example |
|--------|---------|
| Multi-faceted outcome | Success requires multiple orthogonal criteria |
| Evidence-grounded problem | Specific data points identify the issue |
| High stakes | Wrong implementation could cause downstream harm |
| Investigation needed | Can't specify success criteria without research |
| Anti-goals critical | Important to define what must NOT happen |

### When to Use `/todo`

Use `/todo` for tasks when:

| Signal | Example |
|--------|---------|
| Clear deliverables | Specific files to create/modify |
| Well-understood scope | No investigation needed |
| Single-agent work | Focused task without multi-phase coordination |
| Low risk | Failure doesn't cascade to other systems |

### Quick Decision

```
Is success measurable with multiple criteria?
├─ YES → Consider /goal
└─ NO
    │
    Is investigation needed before knowing success?
    ├─ YES → Use /goal (Agent-to-define)
    └─ NO → Use /todo
```

See [goal skill](../goal/SKILL.md) for goal definition workflows.

---

## Critical: User Confirmation Required

**NEVER mark a task as complete without explicit user confirmation.**

Tasks require one of these user approval signals before archiving:

| Signal | Example User Input |
|--------|-------------------|
| Explicit approval | "yes complete it", "looks good, mark done", "approved" |
| Verification request | User asks agent to review changes/tests after context summary |
| Manual completion | User runs `/todo complete` themselves |

### Prohibited: Auto-Completion

The agent must **NOT**:
- Automatically complete tasks after implementation
- Mark tasks done based on deliverables being checked off
- Archive tasks without user saying they're ready

### Required: Implementation → Review Handoff

After implementing a task, the workflow is:

1. Agent implements deliverables
2. Agent presents verification summary (changes made, tests run/passed)
3. **STOP and WAIT for user**
4. User either:
   - Reviews and approves → Agent completes task
   - Summarizes context → Agent re-reviews, then awaits approval
   - Requests changes → Agent iterates
5. Only after explicit approval → Archive task

See [workflows/implement.md](workflows/implement.md) for the full verification handoff protocol.

---

## File Structure

| File | Purpose | Content |
|------|---------|---------|
| `docs/todos/queue.md` | Ordered work queue | Links only - what to work on next |
| `docs/todos/pool.md` | Unscheduled work pool | Links only - ideas, improvements, research |
| `docs/todos/tasks/` | Task definitions | Self-contained task files with full details |
| `docs/todos/completed/` | Archive | Completed task index and files |
| `docs/todos/README.md` | Format and usage conventions | Reference documentation |

**Key principle**: Queue/pool files contain only links. All task details live in task files.

### Queue Sections

| Section | Purpose |
|---------|---------|
| Active | Currently being worked |
| Next | Ordered backlog of scheduled work |

### Pool Sections

| Section | Purpose |
|---------|---------|
| Ideas | Quick ideas for later |
| Improvements | Enhancements to existing functionality |
| Research | Topics to explore |

---

## Action Router

Determine action from user input:

| Pattern | Action | Reference |
|---------|--------|-----------|
| `add ...` | Add task (auto-assesses complexity) | [workflows/add.md](workflows/add.md) |
| `list` or no args | List current tasks | [List Workflow](#list-workflow) |
| `promote [title]` | Move pool → queue | [Promote Workflow](#promote-workflow) |
| `remove [title]` | Delete a task | [Remove Workflow](#remove-workflow) |
| `show queue` | Show queue only | [List Workflow](#list-workflow) |
| `show pool` | Show pool only | [List Workflow](#list-workflow) |
| `complete [title]` | Archive completed task | [workflows/complete.md](workflows/complete.md) |
| `implement [title]` | Work on task, await user approval, then archive | [workflows/implement.md](workflows/implement.md) |
| `breakdown [title]` | Decompose task into subtasks | [workflows/breakdown.md](workflows/breakdown.md) |
| `status [title]` | Show task status and children | [Status Workflow](#status-workflow) |

---

## Quick Workflows

### List Workflow

1. Read `queue.md`, `pool.md`, scan `tasks/` directory
2. Display summary:

```
## Queue
### Active
- [>] Task Title - scope

### Next
- [ ] Task Title - scope
- [!] Task Title (blocked) - scope

## Pool
### Ideas / Improvements / Research
- Task Title - scope

## Goals in Progress
- Goal Title (3/5 children complete)
```

### Promote Workflow

1. Read both `queue.md` and `pool.md`
2. Find task in `pool.md` by title match
3. Remove link from `pool.md`
4. Add link to `queue.md` → Next section
5. Update task file Status to "pending" if was different
6. Confirm the promotion

### Remove Workflow

1. Find task by title match in queue/pool
2. Use AskQuestion to confirm removal
3. Remove link from queue.md or pool.md
4. Ask whether to also delete the task file
5. If yes, delete from `tasks/`
6. Confirm removal

### Status Workflow

1. Find task file by title
2. Display:
   - Current status
   - Type (goal/task/subtask)
   - Parent (if any)
   - Children with their statuses (if any)
   - Deliverables progress

---

## Detailed Workflows

For complex workflows with multiple steps and decision points:

- [workflows/add.md](workflows/add.md) - Add tasks, assess complexity, create task files
- [workflows/complete.md](workflows/complete.md) - Archive tasks, update parent progress, manage completion history
- [workflows/implement.md](workflows/implement.md) - Execute task work, spawn subagents, await user approval
- [workflows/breakdown.md](workflows/breakdown.md) - Decompose large tasks into subtasks, create hierarchy

---

## Task File Format

Every task lives in `tasks/` with this structure:

```markdown
# Task Title

Brief description (1-2 sentences).

## Meta

| Field | Value |
|-------|-------|
| Status | pending / active / blocked / done |
| Type | goal / task / subtask |
| Scope | small / medium / large |
| Parent | [Parent Task](parent-task.md) or none |
| Created | YYYY-MM-DD |

## Goal Reference

(For tasks that are part of a goal)

| Field | Value |
|-------|-------|
| Parent Goal | [Goal Title](../goals/goal-file.md) or none |
| Success Criteria | [Which goal criteria this task addresses] |
| Anti-Goals | [Which goal anti-goals this task must preserve] |

## Expected Outcome

(Required for medium and large scope tasks)

| Field | Value |
|-------|-------|
| Category | Concrete / Agent-to-define |
| Criteria | [Measurable outcome for this task] |

## Children

(Only for tasks broken into subtasks)

- [ ] [Child Task A](child-a.md)
- [x] [Child Task B](child-b.md)

## Context

Why this matters, background information.

## Deliverables

- [ ] Specific deliverable 1
- [ ] Specific deliverable 2

## Success Criteria

- [ ] How to verify completion
```

### Expected Outcome Categories

| Category | Definition | Protocol |
|----------|------------|----------|
| **Concrete** | Success criteria known upfront | Implement → Verify |
| **Agent-to-define** | Investigation required first | Investigate → Propose criteria → Get approval → Implement |

For Agent-to-define tasks, see [workflows/implement.md](workflows/implement.md) for the two-phase protocol.

---

## Task Hierarchy

Tasks can form hierarchies through Parent/Children links:

```
Goal (large scope, multiple agents)
├── Task A (medium scope)
│   ├── Subtask A1
│   └── Subtask A2
└── Task B (small scope)
```

### Hierarchy Rules

1. A task with Children = parent task (tracks progress via children)
2. A task with Parent = child task (contributes to parent completion)
3. Parent status = "done" only when ALL children are "done"
4. Breaking down a task creates children, not siblings

### Task Types

| Type | Scope | Agent Strategy |
|------|-------|----------------|
| **goal** | Large, multi-faceted | Requires [goal skill](../goal/SKILL.md) workflow; always decomposes |
| **task** | Focused, achievable | Single agent; must reference goal criteria if part of goal |
| **subtask** | Small, atomic | Single agent; inherits parent task's goal criteria |

**Note**: Goals have their own file format and live in `docs/todos/goals/`. See [goal skill](../goal/SKILL.md).

### Queue Status Markers

In `queue.md`, use these status markers:

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending - not started |
| `[>]` | Active - currently being worked |
| `[!]` | Blocked - waiting on dependency |
| `[x]` | Done - ready to archive |

---

## Priority Assessment

When user doesn't specify location, assess:

**Queue indicators** (→ queue.md):
- Blocks current work or deliverables
- Required for a specific milestone
- Data quality issue affecting analysis
- Security or correctness concern
- Words: "need", "must", "required", "blocking", "critical", "urgent"

**Pool indicators** (→ pool.md):
- Improves developer experience
- Optimization or refactoring
- Future feature ideas
- Research or exploration
- Words: "could", "might", "idea", "maybe", "eventually", "nice to have"

If unclear, use AskQuestion:
```
Question: "Where should this task go?"
Options:
  - Queue (Scheduled - needs attention soon)
  - Pool (Unscheduled - for later consideration)
```

---

## Examples

**Add with auto-assessment:**
```
/todo add figure out how to include population counts by zip code
```
→ Assess as research/pool, create task file, add link to pool.md

**Add to queue:**
```
/todo add queue: fix data quality issue in NPPES matching
```
→ Create task file, add link to queue.md

**Breakdown a task:**
```
/todo breakdown Testing Foundation
```
→ Evaluate task, create child tasks, update parent with Children section

**List:**
```
/todo list
```
→ Display summary of queue, pool, and goal progress

**Complete:**
```
/todo complete Stage 1: Ingestion Testing
```
→ Archive to `completed/`, update parent if exists

**Implement:**
```
/todo implement Professional Licensing
```
→ Execute work (spawn subagent if complex), present verification summary, **wait for user approval**, then archive

**Status:**
```
/todo status Testing Foundation
```
→ Show task details, children, and progress
