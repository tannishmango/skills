# Complete Task Workflow

Archive a TODO task to the completion history **after user approval**.

## Contents

- [User Approval Required](#user-approval-required) - Gate before any completion
- [Workflow Steps](#workflow-steps) - Full completion process
- [Parent Task Updates](#parent-task-updates) - Updating parent when child completes
- [Archive Entry Format](#archive-entry-format) - Standard format for archived items

---

## User Approval Required

**CRITICAL**: This workflow requires explicit user approval before archiving.

### When Complete Can Be Called

| Scenario | Approval Status |
|----------|-----------------|
| User explicitly says "complete [task]" | Pre-approved by user command |
| Called from implement workflow | Requires approval in implement flow first |
| Agent decides task is done | **NOT ALLOWED** - must get user approval |

### Pre-Approved Signals

The complete workflow can proceed when user has said:
- `/todo complete [task name]`
- "yes, mark it complete"
- "complete it" / "archive it"
- "approved" (after verification summary)

### Not Approved

Do NOT proceed with completion if:
- Agent is calling complete on its own initiative
- User hasn't explicitly confirmed
- Last user message was a context summary (re-review first)

---

## Workflow Steps

### Step 1: Find Task

1. Search `queue.md` and `pool.md` for task link by title match
2. Read the linked task file from `tasks/`
3. Display task details for confirmation

### Step 2: Check for Children

If task has Children section:
- Check status of all children
- If any children not "done", warn user:

```
Warning: This task has incomplete children:
- [ ] Child A (pending)
- [x] Child B (done)

Complete anyway? This will also mark children as complete.
```

### Step 3: Confirm Completion

**If user explicitly called `/todo complete [task]`**: Skip confirmation (user pre-approved).

**Otherwise**, user approval is required:

```
Question: "Mark this task as complete and archive it?"
Show: Task title, description, deliverables summary
Options: Yes (archive it), No (cancel)
```

**Do NOT proceed without explicit "Yes" or equivalent approval.**

If approval was given during the implement workflow's verification handoff, that counts as approval for this step.

### Step 4: Update Task File Status

Update the task file's Meta section:
```markdown
| Status | done |
```

### Step 5: Update Parent (if exists)

If task has Parent field (not "none"):
1. Read parent task file
2. Find this task in parent's Children section
3. Mark as complete: `- [x] [This Task](this-task.md)`
4. Check if ALL children now complete
5. If all complete, prompt to complete parent too

See [Parent Task Updates](#parent-task-updates) for details.

### Step 6: Move Task File to Completed

1. Ensure `docs/todos/completed/tasks/` exists
2. Copy task file to `docs/todos/completed/tasks/`
3. Delete original from `docs/todos/tasks/`

### Step 7: Update Completed Index

Add entry to `docs/todos/completed/index.md`:

```markdown
- [Task Title](tasks/task-name.md) - YYYY-MM-DD
```

### Step 8: Remove from Queue/Pool

Remove the task link from `queue.md` or `pool.md`.

### Step 9: Confirm

Report:
- Task archived
- Task file moved to completed/tasks/
- Parent updated (if applicable)
- Whether parent is now complete

---

## Parent Task Updates

When completing a child task:

### Step 1: Read Parent

Read parent task file and find Children section.

### Step 2: Update Child Status

Change from:
```markdown
- [ ] [Child Task](child-task.md)
```

To:
```markdown
- [x] [Child Task](child-task.md)
```

### Step 3: Check Completion

Count children:
- Total children
- Completed children (marked `[x]`)

### Step 4: Handle Full Completion

If all children complete:

```
All children of "[Parent Task]" are now complete:
- [x] Child A
- [x] Child B
- [x] Child C

Would you like to mark the parent as complete too?
```

If yes, recursively run completion workflow on parent.

### Step 5: Handle Partial Completion

If some children remain:
- Just update the child status
- Report progress: "Parent 'X' is now 2/3 complete"

---

## Archive Entry Format

Entries in `completed/index.md`:

```markdown
- [Task Title](tasks/task-name.md) - YYYY-MM-DD
```

For tasks without files (legacy):

```markdown
- Task Title - YYYY-MM-DD
```

### Full Archive File

For detailed history, `completed/completed-current.md` contains full entries:

```markdown
### [Task Title]

[Original description]

- **Completed**: YYYY-MM-DD
- **Original location**: queue/pool
- **Details**: [tasks/task-name.md](tasks/task-name.md)
- **Implementation summary**: [Brief what was done]
```
