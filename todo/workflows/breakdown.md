# Breakdown Task Workflow

Decompose a large task into smaller subtasks, creating a parent-child hierarchy.

## Contents

- [Workflow Steps](#workflow-steps) - Full breakdown process
- [Decomposition Strategy](#decomposition-strategy) - How to split tasks effectively
- [Hierarchy Management](#hierarchy-management) - Parent-child relationships

---

## Workflow Steps

### Step 1: Find and Analyze Task

1. Search `queue.md` and `pool.md` for task by title
2. Read the full task file from `tasks/`
3. Analyze deliverables, scope, and structure

### Step 2: Evaluate Breakdown Need

Check if breakdown is appropriate:

| Factor | Breakdown Appropriate | Keep Single Task |
|--------|----------------------|------------------|
| Scope | large | small/medium |
| Deliverables | 5+ distinct items | 1-4 items |
| Modules touched | 3+ unrelated areas | Single area |
| Phases | Multiple distinct phases | Linear flow |
| Dependencies | Some deliverables independent | All sequential |

If breakdown not beneficial:
```
This task appears well-scoped for single execution.
Breakdown would add overhead without benefit.
Proceed with implementation instead?
```

### Step 3: Identify Logical Groupings

Analyze deliverables and group by:

1. **Functional area** - Group by module/component
2. **Phase** - Group by workflow stage (setup, implement, test)
3. **Dependency** - Group items that must be sequential
4. **Skill** - Group by type of work (research, coding, docs)

Aim for 2-5 subtasks. More than 5 suggests the parent is actually a "goal".

### Step 4: Confirm Breakdown Plan

Present proposed breakdown to user:

```
Proposed breakdown of "[Task Title]":

1. "[Subtask A Title]" (scope: small)
   - Deliverable 1
   - Deliverable 2

2. "[Subtask B Title]" (scope: medium)
   - Deliverable 3
   - Deliverable 4
   - Deliverable 5

3. "[Subtask C Title]" (scope: small)
   - Deliverable 6

Proceed with this breakdown?
```

Use AskQuestion:
```
Question: "Create these subtasks?"
Options:
  - Yes, create subtasks
  - Modify breakdown (let me adjust)
  - Cancel
```

### Step 5: Update Parent Task

Modify the original task file:

1. Change Type to "goal" if creating 4+ children, otherwise keep "task"
2. Add Children section with links to subtasks
3. Move deliverables to Context or remove (they now live in children)
4. Update Status to "active" (waiting on children)

**Before:**
```markdown
## Meta

| Field | Value |
|-------|-------|
| Status | pending |
| Type | task |
| Scope | large |

## Deliverables

- [ ] Deliverable 1
- [ ] Deliverable 2
- [ ] Deliverable 3
```

**After:**
```markdown
## Meta

| Field | Value |
|-------|-------|
| Status | active |
| Type | task |
| Scope | large |

## Children

- [ ] [Subtask A](subtask-a.md)
- [ ] [Subtask B](subtask-b.md)
- [ ] [Subtask C](subtask-c.md)

## Context

Original scope included: [summary of deliverables, now in children]
```

### Step 6: Create Subtask Files

For each subtask, create a new task file in `tasks/`:

```markdown
# [Subtask Title]

[Description derived from parent deliverables]

## Meta

| Field | Value |
|-------|-------|
| Status | pending |
| Type | subtask |
| Scope | [small/medium] |
| Parent | [Parent Task](parent-task.md) |
| Created | YYYY-MM-DD |

## Context

Part of [Parent Task](parent-task.md).

## Deliverables

- [ ] Deliverable moved from parent
- [ ] Another deliverable

## Success Criteria

- [ ] Criteria for this subtask
```

### Step 7: Update Queue

Add subtasks to `queue.md` in execution order:

```markdown
## Next

- [ ] [Parent Task](tasks/parent-task.md) - large (3 children)
  - [ ] [Subtask A](tasks/subtask-a.md) - small
  - [ ] [Subtask B](tasks/subtask-b.md) - medium
  - [ ] [Subtask C](tasks/subtask-c.md) - small
```

Or flat (if subtasks are independent):

```markdown
## Next

- [ ] [Subtask A](tasks/subtask-a.md) - small
- [ ] [Subtask B](tasks/subtask-b.md) - medium
- [ ] [Subtask C](tasks/subtask-c.md) - small
```

### Step 8: Confirm

Report:
- Parent task updated with Children section
- N subtask files created
- Subtasks added to queue
- Suggested execution order

---

## Decomposition Strategy

### Good Breakdown Characteristics

1. **Each subtask is independently completable** - Can be done without others
2. **Each subtask has clear scope** - Obvious when it's done
3. **Subtasks are similar size** - Avoid 1 huge + 3 tiny
4. **Dependencies are minimized** - Prefer parallel potential

### Common Decomposition Patterns

**By Phase:**
```
Large Task
├── Setup/Research subtask
├── Implementation subtask
└── Testing/Documentation subtask
```

**By Component:**
```
Large Task
├── Module A changes
├── Module B changes
└── Integration subtask
```

**By Layer:**
```
Large Task
├── Database changes
├── Backend logic
└── API/Interface changes
```

### Anti-Patterns to Avoid

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| Too many subtasks (6+) | Overhead exceeds benefit | Group into 3-4 |
| Too few subtasks (2) | Probably didn't need breakdown | Keep as single task |
| Highly dependent chain | Each waits on previous | Group dependent items |
| Uneven sizes | One subtask dominates | Rebalance groupings |

---

## Hierarchy Management

### Tracking Progress

Parent tasks show progress via Children checkboxes:

```markdown
## Children

- [x] [Subtask A](subtask-a.md) ← completed
- [>] [Subtask B](subtask-b.md) ← in progress
- [ ] [Subtask C](subtask-c.md) ← pending
```

### Nested Breakdown

If a subtask itself is too large:
1. It can be broken down further
2. Its Type changes from "subtask" to "task"
3. Its children become "subtask" type
4. Maximum recommended depth: 3 levels (goal → task → subtask)

### Completing Hierarchies

When last child completes:
1. Parent's Children all show `[x]`
2. Parent status can change to "done"
3. Archive parent and all children together

See [complete.md](complete.md) for parent completion handling.
