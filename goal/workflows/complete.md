# Complete Goal Workflow

Verify a goal against its success criteria and anti-goals, then archive.

## Contents

- [User Approval Required](#user-approval-required) - Gate before completion
- [Workflow Steps](#workflow-steps) - Full verification process
- [Verification Checklist](#verification-checklist) - What to check
- [Anti-Goal Verification](#anti-goal-verification) - Confirming no violations
- [Downstream Impact Verification](#downstream-impact-verification) - For Concrete* goals

---

## User Approval Required

**CRITICAL**: Goal completion requires explicit user approval.

### When Complete Can Be Called

| Scenario | Approval Status |
|----------|-----------------|
| User explicitly says "/goal complete [name]" | Pre-approved |
| All tasks complete, verification summary presented | Requires approval |
| Agent decides goal is done | **NOT ALLOWED** |

### The Verification Principle

Verification must be against the **pre-approved criteria**, not agent judgment:

```
Approved Criteria: "22 mega-clusters dissolved"
    ↓
Verification: Count mega-clusters, compare to 22
    ↓
NOT: "I think the clusters look better"
```

---

## Workflow Steps

### Step 1: Find Goal

1. Search `docs/todos/goals/` for goal by title
2. Read the full goal file
3. Verify status is "active" (implementation was done)

### Step 2: Check All Tasks Complete

If goal has Work Breakdown section:

1. Check each linked task
2. All must be in `completed/tasks/`
3. If any incomplete, warn user

```
Warning: This goal has incomplete tasks:
- [x] Task A (completed)
- [ ] Task B (pending)

Complete goal anyway? This is unusual.
```

### Step 3: Run Verification Protocol

Execute each step in the goal's Verification Protocol section:

For each verification step:
1. Run the specified check (query, command, test)
2. Record actual result
3. Compare to expected value

### Step 4: Check Success Criteria

For each success criterion:

| Criterion | Expected | Actual | Status |
|-----------|----------|--------|--------|
| [Criterion 1] | [Value] | [Measured] | ✓ / ✗ |
| [Criterion 2] | [Value] | [Measured] | ✓ / ✗ |

### Step 5: Verify Anti-Goals

**CRITICAL**: Check that NO anti-goals were violated.

See [Anti-Goal Verification](#anti-goal-verification) for details.

### Step 6: Check Downstream Impact (if Concrete*)

For goals with Outcome Category: Concrete*

See [Downstream Impact Verification](#downstream-impact-verification).

### Step 7: Present Verification Summary

Present results and **STOP**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Goal Verification - Awaiting Approval

**Goal**: [Title]

### Success Criteria Verification

| Criterion | Expected | Actual | Status |
|-----------|----------|--------|--------|
| [Criterion 1] | [X] | [Y] | ✓ Met |
| [Criterion 2] | [X] | [Y] | ✓ Met |

### Anti-Goal Verification

| Anti-Goal | Verification | Status |
|-----------|--------------|--------|
| Must NOT [constraint 1] | [How verified] | ✓ Preserved |
| Must NOT [constraint 2] | [How verified] | ✓ Preserved |

### Downstream Impact (if applicable)

[Results of downstream checks]

### Tasks Completed

- [x] [Task 1](../completed/tasks/task-1.md)
- [x] [Task 2](../completed/tasks/task-2.md)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**All criteria met. Mark goal complete?**

Reply with:
- "approved" / "complete it" - Archive the goal
- "verify again" - Re-run verification
- Or describe concerns
```

### Step 8: Wait for User Approval

**Do NOT proceed without explicit approval.**

Approval signals:
- "approved"
- "complete it"
- "yes, archive"
- "goal is done"

### Step 9: Archive Goal

After user approval:

1. Update goal file Status to "done"
2. Move goal file to `docs/todos/completed/goals/`
3. Update `docs/todos/completed/index.md` with entry
4. Report completion

---

## Verification Checklist

Before presenting verification summary, confirm:

- [ ] All success criteria checked with actual measurements
- [ ] Each measurement matches the verification protocol
- [ ] All anti-goals explicitly verified
- [ ] Downstream impact checked (if Concrete*)
- [ ] All linked tasks are completed

### What to Include in Verification

| Element | Include |
|---------|---------|
| Criterion check | Specific command/query run, actual output |
| Anti-goal check | How absence of violation was confirmed |
| Evidence | Screenshot, log output, query result |

### What NOT to Include

| Element | Why Not |
|---------|---------|
| Agent judgment | "I think it's done" - not objective |
| Partial completion | "Most criteria met" - not verified |
| Changed criteria | "Actually we should check X instead" |

---

## Anti-Goal Verification

### Why Anti-Goals Must Be Checked

Anti-goals catch cases where primary criteria are met but harm occurred:

| Scenario | Primary Criteria | Anti-Goal |
|----------|------------------|-----------|
| Over-aggressive filtering | ✓ False positives reduced | ✗ False negatives increased |
| Speed optimization | ✓ Faster processing | ✗ Validation skipped |
| Data cleaning | ✓ Bad records removed | ✗ Good records also removed |

### How to Verify Anti-Goals

Each anti-goal needs explicit verification:

```markdown
### Anti-Goal: Must NOT increase false negative rate

**Verification**:
- Baseline false negative rate: 2.3% (from original data)
- Current false negative rate: 2.1%
- Status: ✓ Preserved (actually improved)

### Anti-Goal: Must NOT require schema changes

**Verification**:
- Compared schema of output files before/after
- All columns identical: ✓ No schema changes
```

### Common Anti-Goal Verifications

| Anti-Goal Type | Verification Method |
|----------------|---------------------|
| "Must NOT break X" | Test X still works, compare before/after |
| "Must NOT exceed Y" | Measure Y, compare to threshold |
| "Must NOT change Z" | Compare Z before and after |
| "Must NOT remove W" | Query for W, confirm still present |

### Anti-Goal Failures

If an anti-goal is violated:

1. **Stop** - Do not complete the goal
2. Report the violation with evidence
3. Ask user how to proceed:
   - Revise implementation to fix violation
   - Accept violation with justification (requires explicit user approval)
   - Roll back changes

---

## Downstream Impact Verification

### When This Applies

Goals with `Outcome Category: Concrete*` require downstream impact verification.

### What to Check

Verify that downstream systems still work correctly:

| Downstream System | Verification |
|-------------------|--------------|
| Dependent parquet files | Load and validate schema |
| Downstream pipeline stages | Run and confirm success |
| Consumer applications | Test key functionality |
| Reports/dashboards | Verify data displays correctly |

### Example Verification

```markdown
## Downstream Impact Verification

### Changed Files
- `data/processed/nppes_maine.parquet` - Filtered to Maine only

### Downstream Consumers
1. **Linkage stage** (`src/linkage/runner.py`)
   - Test: `uv run python -m src.linkage.runner`
   - Result: ✓ Completed successfully

2. **Validation stage** (`src/validation/runner.py`)
   - Test: `uv run python -m src.validation.runner`
   - Result: ✓ Completed successfully

3. **Enriched providers output**
   - Test: Loaded `data/processed/enriched_providers.parquet`
   - Result: ✓ Valid schema, expected record count
```

### If Downstream Impact Found

If changes caused downstream issues:

1. Document the impact
2. Ask user how to proceed:
   - Fix the downstream issue as part of this goal
   - Create new task/goal to address downstream impact
   - Roll back if impact is too severe

---

## Archive Format

### Goal Entry in completed/index.md

```markdown
## Goals

- [Goal Title](goals/goal-name.md) - YYYY-MM-DD - [Outcome summary]
```

### Completed Goal File

The archived goal file retains all sections plus:

```markdown
## Completion

| Field | Value |
|-------|-------|
| Completed | YYYY-MM-DD |
| Verified By | [User who approved] |
| Tasks | N tasks completed |

### Final Verification Summary

[Paste of the verification summary that was approved]
```
