# Implement Task Workflow

Work on a TODO task, then **hand off for user verification before completing**.

## Contents

- [Workflow Steps](#workflow-steps) - Full implementation process
- [Agent-to-define Protocol](#agent-to-define-protocol) - Two-phase process for investigation tasks
- [Breakdown Evaluation](#breakdown-evaluation) - When to decompose vs execute
- [Subagent Execution](#subagent-execution) - When and how to spawn subagents
- [Verification](#verification) - Confirming work is complete
- [Test Quality Verification](#test-quality-verification) - Ensuring tests provide real guarantees
- [Verification Handoff](#verification-handoff) - User approval gate (REQUIRED)
- [Next Steps Guidance](#next-steps-guidance) - Post-completion continuity

---

## Workflow Steps

### Step 1: Find and Display Task

1. Search `queue.md` for task by title
2. Read the task file from `tasks/`
3. Display full task details (Meta, Context, Deliverables, Success Criteria)

### Step 2: Check Dependencies

If task file has `Depends On` field:

1. Parse each dependency link
2. Check if dependency exists in `completed/tasks/`
3. If NOT found: dependency incomplete

Handle incomplete dependencies:

```
Question: "This task depends on '[dependency]' which is not yet complete."
Options:
  - Proceed anyway (I'll handle the dependency manually)
  - Cancel (I'll implement the dependency first)
  - Show dependency details
```

### Step 3: Check Expected Outcome Category

If task has `Expected Outcome` section:

| Category | Protocol |
|----------|----------|
| Concrete | Proceed to Step 4 |
| Agent-to-define | Follow [Agent-to-define Protocol](#agent-to-define-protocol) |

If no Expected Outcome section: Treat as Concrete, proceed to Step 4.

### Step 4: Evaluate for Breakdown — CRITICAL STEP

**Before executing, evaluate whether the task should be broken down.**

Check these criteria:

| Signal | Indicates Breakdown Needed |
|--------|---------------------------|
| Scope is "large" | Consider breakdown |
| 5+ distinct deliverables | Likely needs breakdown |
| Multiple phases that could parallelize | Breakdown beneficial |
| Task touches 3+ unrelated modules | Agent context may overflow |
| Deliverables have different skill requirements | Different agents beneficial |

**Evaluation outcomes:**

1. **Task is comprehensive and single-agent feasible** → Proceed to Step 4
2. **Task would benefit from breakdown** → Offer breakdown

If breakdown beneficial:

```
Question: "This task appears to benefit from breakdown into subtasks."
Show: Suggested breakdown (2-4 subtasks)
Options:
  - Break down first, then implement children
  - Execute as single task anyway
  - Cancel
```

If "Break down first" selected:
- Run [breakdown.md](breakdown.md) workflow
- Then prompt to implement first child

See [Breakdown Evaluation](#breakdown-evaluation) for detailed criteria.

### Step 4: Confirm Implementation

Use AskQuestion:
```
Question: "Ready to implement this task?"
Show: Task title, scope, key deliverables
Options: Yes (proceed), No (cancel)
```

### Step 5: Update Status

Update task file Meta:
```markdown
| Status | active |
```

Update queue.md marker:
```markdown
- [>] [Task Title](tasks/task-name.md) - scope
```

### Step 6: Execute Implementation

Choose execution strategy based on scope:

| Scope | Strategy |
|-------|----------|
| small | Execute directly |
| medium | Spawn single subagent |
| large | Spawn subagent (or breakdown if Step 3 suggested it) |

See [Subagent Execution](#subagent-execution) for subagent configuration.

### Step 7: Verify Results

After execution:
- Check all deliverables marked complete
- Run any specified tests
- Verify success criteria met

See [Verification](#verification) for details.

### Step 8: Verification Handoff (REQUIRED)

**DO NOT auto-complete.** Present verification summary and wait for user approval.

See [Verification Handoff](#verification-handoff) for the full protocol.

**Output the verification summary, then STOP and WAIT for user response.**

### Step 9: User Approval Gate

The agent must receive explicit user approval before proceeding:

| User Response | Action |
|---------------|--------|
| Approval ("yes", "complete it", "looks good") | Proceed to Step 10 |
| Context summary provided | Re-review changes and tests, then wait again |
| Change requests | Iterate on implementation, return to Step 7 |
| No response | **WAIT** - do not proceed |

**CRITICAL**: If user provides a context summary (compressed chat), the agent must:
1. Re-read the task file and deliverables
2. Review changes made (files modified, code written)
3. Review tests written/run and their results
4. Check for any logical gaps or issues missed on first pass
5. Report findings, then **wait for approval again**

### Step 10: Complete the Task

**Only after explicit user approval**, run the Complete workflow from [complete.md](complete.md):
- Update status to "done"
- Move task file to completed/tasks/
- Update parent if exists
- Remove from queue.md

### Step 11: Next Steps Guidance

After completing a task, determine next steps based on task hierarchy.

See [Next Steps Guidance](#next-steps-guidance) for full details.

**Quick decision tree:**

1. **Has Parent?** → Check for sibling tasks
2. **Sibling exists?** → Provide continuation prompt with context
3. **No siblings remaining?** → Parent complete summary
4. **No Parent?** → Standard completion summary

### Step 12: Summary

Report:
- What was implemented
- Files created/modified
- Tests run (pass/fail)
- Task archived to completed/
- Next step guidance (see Step 11)

---

## Agent-to-define Protocol

For tasks with `Expected Outcome Category: Agent-to-define`, follow this two-phase process.

### Why Two Phases?

Agent-to-define tasks require investigation before knowing what success looks like. This prevents:
- Agent defining and evaluating own success
- Narrow interpretations that miss user intent
- Criteria changing during implementation

### Phase 1: Investigation

**Objective**: Understand the problem, propose success criteria.

#### Step 1: Investigate

Based on the task context:
- Read relevant code and data
- Run queries to understand current state
- Identify root cause or key factors
- Document findings

#### Step 2: Propose Criteria

Present findings and proposed success criteria:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Investigation Complete - Proposing Success Criteria

**Task**: [Title]

### Investigation Findings

- [Finding 1 with evidence]
- [Finding 2 with evidence]

### Proposed Success Criteria

Based on investigation, I propose:

1. [Criterion 1] - derived from [finding]
2. [Criterion 2] - derived from [finding]

### Proposed Anti-Goals

- Must NOT [constraint 1]
- Must NOT [constraint 2]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Approve these success criteria before implementation?**
```

#### Step 3: Wait for Approval

**STOP** - Do not proceed until user approves criteria.

| User Response | Action |
|---------------|--------|
| "approved" / "yes" | Update task file, proceed to Phase 2 |
| "modify [aspect]" | Revise criteria, re-propose |
| "investigate more" | Continue investigation |

#### Step 4: Update Task File

After approval, update task's Expected Outcome:

```markdown
## Expected Outcome

| Field | Value |
|-------|-------|
| Category | Agent-to-define (approved) |
| Criteria | [Approved criterion 1]; [Approved criterion 2] |
| Anti-Goals | [Approved anti-goal 1]; [Approved anti-goal 2] |
```

### Phase 2: Implementation

After criteria approved, proceed with normal implementation:
- Continue from Step 4 (Evaluate for Breakdown)
- Implement against APPROVED criteria only
- Verification must check approved criteria AND anti-goals

### Critical Constraints

1. **No implementation before criteria approval**
   - Even if "obvious" fix is clear, propose criteria first

2. **Criteria are locked after approval**
   - No changing criteria mid-implementation
   - If new information changes criteria: stop, re-propose, get new approval

3. **Anti-goals must be verified**
   - Verification checklist includes anti-goal checks
   - See [Verification](#verification) for anti-goal verification

---

## Breakdown Evaluation

### When to Break Down

**Break down when ANY of these apply:**

| Signal | Threshold |
|--------|-----------|
| Deliverables count | 6+ distinct items |
| Files touched | 8+ files across multiple modules |
| Phases | 3+ distinct phases (research, implement, test) |
| Context risk | Reading task would consume >50% of agent context |
| Parallel potential | 2+ deliverables have no dependencies on each other |

**Keep as single task when:**

- Deliverables are tightly coupled
- Sequential dependencies between all items
- Single module/area of codebase
- Clear single-agent scope

### How to Suggest Breakdown

When breakdown is beneficial, suggest logical groupings:

```
This task has 8 deliverables that could be grouped into 3 subtasks:

1. "Setup and Configuration" (deliverables 1-2)
   - Create directory structure
   - Set up fixtures

2. "Core Implementation" (deliverables 3-5)
   - Implement main logic
   - Add error handling
   - Write unit tests

3. "Integration and Documentation" (deliverables 6-8)
   - Integration tests
   - Update documentation
   - Add to CI

Would you like to break this down?
```

---

## Subagent Execution

### When to Use Subagents

| Scope | Subagent? | Reason |
|-------|-----------|--------|
| small | No | Direct execution faster |
| medium | Yes | Fresh context prevents overflow |
| large | Yes | Essential for quality |

### Subagent Configuration

```
Task tool parameters:
- subagent_type: "generalPurpose"
- readonly: false
- model: (omit for default, or "fast" for simple tasks)
- description: "Implement [task title]"
- prompt: [constructed from task file]
```

### Constructing Subagent Prompt

Include in prompt:

1. Full task file contents (deliverables, success criteria, key files)
2. Instruction to check off deliverables as completed
3. Request to report: files created/modified, tests run, issues encountered
4. **Testing requirements** (see [Test Quality Verification](#test-quality-verification))

Example structure:
```
Implement the following task. Check off each deliverable checkbox as you complete it.

CRITICAL - Testing Requirements:
Read .cursor/skills/testing/SKILL.md before writing any tests.

Tests MUST:
1. Have a HAPPY PATH test FIRST that proves the feature works (not just "doesn't crash")
2. Assert POSITIVE VALUES (not emptiness like == 0, .empty, == [])
3. Test OUTCOMES, not log messages
4. FAIL if you deleted the core logic or returned hardcoded []

Tests that ONLY verify disabled/empty states are WORTHLESS. The primary test must prove
the feature produces correct positive results when enabled with valid data.

RED FLAG claims to avoid:
- "Tests disabled signals return empty" ← Where's the enabled test?
- "Uses exact value assertions (== 0)" ← Asserting emptiness proves nothing
- "Verifies specific log messages" ← That's implementation testing

Report back with:
- Files created/modified
- Tests written (for each: name, what POSITIVE behavior it verifies)
- Test results (pass/fail)
- Confirmation: "Happy path test proves feature works: [test name]"
- Any issues encountered

[Full task file contents here]
```

### Direct Execution (Small Tasks)

For small scope tasks:
- Execute directly without spawning subagent
- Write code, create files, update documentation
- Follow existing project patterns
- Test changes if applicable

---

## Verification

### After Subagent Execution

1. Review subagent's report
2. Verify claimed completions match actual file state
3. Run any tests mentioned to confirm they pass
4. Check success criteria against actual deliverables

### After Direct Execution

1. Confirm all deliverables addressed
2. Run any specified tests
3. Check success criteria met
4. Verify no regressions introduced

### Verification Checklist

- [ ] All deliverable checkboxes can be marked complete
- [ ] Tests pass (if specified)
- [ ] **Test quality verified** (see [Test Quality Verification](#test-quality-verification))
- [ ] No new linter errors introduced
- [ ] Success criteria met
- [ ] Documentation updated (if required)
- [ ] **Anti-goals preserved** (if task has anti-goals defined)
- [ ] **Goal anti-goals preserved** (if task is part of a goal)
- [ ] **Downstream impact verified** (if Concrete* category)

### Anti-Goal Verification

If the task has anti-goals (from Expected Outcome or Goal Reference):

For each anti-goal:
1. Determine how to verify it was NOT violated
2. Run verification check
3. Document result

Example anti-goal verifications:

| Anti-Goal | Verification Method | Expected |
|-----------|---------------------|----------|
| Must NOT increase false negatives | Compare count before/after | Count unchanged or lower |
| Must NOT break existing tests | Run test suite | All tests pass |
| Must NOT change schema | Compare parquet schemas | Identical columns |

Include anti-goal verification in the verification summary presented to user.

---

## Test Quality Verification

**CRITICAL**: Tests must provide real guarantees, not false confidence.

Before marking any implementation complete, verify test quality using the testing skill.

### Required: Read Testing Skill

If tests were written or modified:

1. Read `.cursor/skills/testing/SKILL.md`
2. Apply the verification checklist from that skill

### Quick Test Quality Gates

Every test must pass ALL of these:

| Gate | Check |
|------|-------|
| **Happy path exists** | Is there a test proving the feature WORKS? |
| **Positive assertions** | Are assertions checking presence, not absence? |
| **No emptiness assertions** | Primary tests don't use `== 0`, `.empty`, `== []`? |
| **Outcomes not logs** | Tests verify data/state, not log messages? |
| **Mutant test** | Would returning `[]` or deleting logic fail tests? |
| **Specific values** | Does every assert check a specific expected value? |

### Red Flags That Require Fixing

If you see any of these patterns, the tests are insufficient:

```python
# CRITICAL - These patterns indicate WORTHLESS tests:
assert len(result) == 0         # → Test enabled path with expected positive results
assert result.empty             # → Prove the feature produces correct output
assert "log message" in caplog  # → Assert actual data/state changes instead
config = {"enabled": False}     # → Test enabled=True FIRST

# Also fix these common issues:
assert result is not None       # → assert result == expected_value
assert result                   # → assert specific content
assert len(result) > 0          # → assert len(result) == N
assert "text" in sql_string     # → execute SQL and assert results
```

### The "Looks Good But Worthless" Self-Check

If a subagent reports tests like:
- "Tests specific behavior (disabled signals return empty DataFrames)"
- "Uses exact value assertions (`== 0`)"
- "Verifies specific log messages"

**These are RED FLAGS.** The tests check boxes but prove nothing. Require:
1. A test that proves the feature WORKS when enabled (happy path)
2. Assertions on actual data values, not emptiness
3. Outcome testing, not log message testing

### Testing Skill Reference

For comprehensive guidance, read:

- `.cursor/skills/testing/SKILL.md` - Core principles, quality gates
- `.cursor/skills/testing/antipatterns.md` - Common failures to avoid
- `.cursor/skills/testing/checklist.md` - Per-test verification
- `.cursor/skills/testing/examples.md` - Good vs bad examples

### Subagent Test Review

When a subagent reports tests written:

1. Review each test the subagent lists
2. Check for red flag patterns above
3. If issues found: either fix directly or prompt subagent to fix
4. **Do not complete the task until tests pass quality gates**

---

## Verification Handoff

**CRITICAL**: Tasks are NEVER auto-completed. User must explicitly approve.

### Why This Gate Exists

- Prevents premature completion before user reviews quality
- Allows user to catch issues agent missed on first pass
- Supports context compression workflow (user summarizes, agent re-reviews)
- Ensures deliverables match user's actual expectations

### Verification Summary Format

After implementation, present this summary and **STOP**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Implementation Complete - Awaiting Approval

**Task**: [Task Title]

### Changes Made

| File | Change |
|------|--------|
| `path/to/file1.py` | [Brief description] |
| `path/to/file2.py` | [Brief description] |
| `tests/test_file.py` | [Tests added] |

### Deliverables Status

- [x] Deliverable 1 - [how addressed]
- [x] Deliverable 2 - [how addressed]
- [x] Deliverable 3 - [how addressed]

### Tests

| Test | Result | Verifies |
|------|--------|----------|
| `test_happy_path` | ✓ Pass | [What positive behavior] |
| `test_edge_case` | ✓ Pass | [What edge case] |

**Test command**: `pytest tests/test_file.py -v`

### Success Criteria Check

- [x] Criterion 1 - [verified by...]
- [x] Criterion 2 - [verified by...]

### Anti-Goal Verification

(Include if task has anti-goals from Expected Outcome or Goal Reference)

| Anti-Goal | Verification | Status |
|-----------|--------------|--------|
| Must NOT [constraint 1] | [How verified] | ✓ Preserved |
| Must NOT [constraint 2] | [How verified] | ✓ Preserved |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Ready to mark complete?**

Reply with:
- "yes" / "complete it" - Archive the task
- "review again" - I'll re-examine changes and tests
- Or describe any changes needed

```

### After Presenting Summary

**STOP. Do not proceed until user responds.**

The agent must not:
- Assume silence is approval
- Auto-complete after a timeout
- Mark task done because deliverables are checked

### Handling Context Summary

If user provides a compressed context summary instead of approval:

1. **Re-read** the task file (`tasks/[task-name].md`)
2. **Re-read** each file that was modified
3. **Re-run** tests if appropriate, or review test output
4. **Check** for:
   - Logical gaps in implementation
   - Edge cases not handled
   - Tests that pass but don't prove functionality
   - Deliverables that were addressed superficially
   - Regressions in other parts of the codebase
5. **Report** findings in a new verification summary
6. **Wait** for approval again

Example re-review response:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Re-Review Complete

After re-examining with fresh context:

### Verified ✓

- [Aspect that looks correct]
- [Another verified element]

### Potential Issues Found

| Issue | Severity | Recommendation |
|-------|----------|----------------|
| [Description] | Low/Med/High | [Fix or accept] |

### Unchanged Assessment

[Aspects that remain correctly implemented]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Approve completion?** Or describe changes needed.
```

### Approval Signals

Only these user responses authorize completion:

| Approved | Not Approved |
|----------|--------------|
| "yes" | (no response) |
| "complete it" | "looks okay" (ambiguous) |
| "mark done" | "I think so" (uncertain) |
| "approved" | Questions about implementation |
| "looks good, complete" | Requests for more info |

When uncertain, ask: "Would you like me to mark this task complete and archive it?"

---

## Next Steps Guidance

After successfully completing and archiving a task, provide appropriate continuation guidance.

### Decision Flow

```
Task completed
│
├─ Has Parent task?
│   │
│   ├─ YES → Read parent's Children section
│   │   │
│   │   ├─ Next sibling pending?
│   │   │   └─ YES → Provide continuation prompt (Section A)
│   │   │
│   │   └─ All siblings complete?
│   │       └─ YES → Provide parent completion summary (Section B)
│   │
│   └─ NO → Standard completion message
│
└─ No parent → Standard completion message
```

### Section A: Continuation Prompt (Next Sibling Exists)

When another subtask exists under the same parent:

**1. Identify the next task**

Read parent's Children section, find first unchecked item:
```markdown
## Children
- [x] [Completed Task A](task-a.md)
- [x] [Just Completed Task](this-task.md)
- [ ] [Next Task](next-task.md)         ← This one
- [ ] [Future Task](future-task.md)
```

**2. Read the next task file**

Load full task details from `tasks/next-task.md`.

**3. Provide continuation prompt**

Output format:

```
✓ Task "[Completed Task]" completed and archived.
  Parent "[Parent Name]" progress: 2/4 subtasks complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Next: [Next Task Title]

[Brief description from next task file]

**Scope**: [small/medium/large]
**Key deliverables**:
- [Deliverable 1]
- [Deliverable 2]
- [Deliverable 3]

**Context from completed work**:
- [Relevant files created/modified that next task may use]
- [Patterns established that should be followed]
- [Any dependencies or setup already in place]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**To continue**, run:

/todo implement [Next Task Title]
```

**4. Context to include**

Provide handoff context relevant to the next task:

| Context Type | Include When |
|--------------|--------------|
| Files created | Next task modifies or extends them |
| Patterns used | Next task should follow same patterns |
| Test structure | Next task adds to test suite |
| Config changes | Next task depends on configuration |
| Dependencies added | Next task may need them |

### Section B: Parent Completion Summary (All Siblings Done)

When the completed task was the final subtask of a parent:

**1. Verify parent completion**

All children marked `[x]`:
```markdown
## Children
- [x] [Task A](task-a.md)
- [x] [Task B](task-b.md)
- [x] [Task C](task-c.md)  ← Just completed
```

**2. Read parent task context**

From parent task file, gather:
- Original goal/purpose
- Success criteria
- Expected outcomes

**3. Provide completion summary**

Output format:

```
✓ Task "[Final Subtask]" completed and archived.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 Parent Task Complete: [Parent Task Title]

All [N] subtasks have been completed:
- [x] [Task A] - [brief what it accomplished]
- [x] [Task B] - [brief what it accomplished]
- [x] [Task C] - [brief what it accomplished]

### What Was Accomplished

[Synthesize the overall achievement from the parent task's original goal.
Describe the cumulative outcome of all subtasks.]

### Expected Results

Based on the parent task's success criteria:
- [Expected outcome 1]
- [Expected outcome 2]
- [Expected outcome 3]

### Review Checklist

Verify the implementation by checking:

- [ ] [Specific verification step from success criteria]
- [ ] [Another verification step]
- [ ] [Integration point to test]
- [ ] [User-facing behavior to confirm]

### Files to Review

Key files created or modified across all subtasks:
- `path/to/file1.py` - [purpose]
- `path/to/file2.py` - [purpose]
- `tests/test_file.py` - [what it tests]

### Potential Deviations to Watch For

If actual results differ from expected:
- [Symptom 1] → [Possible cause]
- [Symptom 2] → [Possible cause]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Parent task ready to archive.** Run:

/todo complete [Parent Task Title]
```

**4. Synthesize from subtasks**

To build the summary:

| Summary Element | Source |
|-----------------|--------|
| What was accomplished | Combine deliverables from all child tasks |
| Expected results | Parent's Success Criteria section |
| Review checklist | Parent's Success Criteria + child deliverables |
| Files to review | Files modified across all children |
| Deviation warnings | Common failure modes for this type of work |

### Standard Completion (No Parent)

For standalone tasks without a parent:

```
✓ Task "[Task Title]" completed and archived.

**Summary**:
- [What was implemented]
- [Key files modified]
- [Tests: X passed]

**Archived to**: docs/todos/completed/tasks/[task-name].md
```

### Important Notes

1. **Only suggest siblings** - Never suggest unrelated tasks from other parents or the general queue
2. **Context is key** - The continuation prompt should give the next agent everything needed to start immediately
3. **Verify parent completion** - Before showing parent summary, confirm ALL children are marked done
4. **Actionable review checklist** - Give specific, checkable items, not vague guidance
