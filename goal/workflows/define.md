# Define Goal Workflow

Create a new goal with evidence-grounded success criteria and anti-goals.

## Contents

- [Workflow Steps](#workflow-steps) - Full goal definition process
- [Evidence Gathering](#evidence-gathering) - Requirements for problem grounding
- [Success Criteria Derivation](#success-criteria-derivation) - From evidence to measurable outcomes
- [Anti-Goal Definition](#anti-goal-definition) - Defining what must NOT happen
- [User Approval Gate](#user-approval-gate) - Required approval before any work

---

## Workflow Steps

### Step 1: Gather Problem Evidence

Before creating a goal, gather specific evidence:

1. **What specific problem exists?** (not abstract complaints)
2. **What data points prove it?** (counts, percentages, specific cases)
3. **What is the impact?** (downstream effects, user-visible issues)

See [Evidence Gathering](#evidence-gathering) for requirements.

### Step 2: Analyze Root Cause

Document the root cause analysis:

| Field | Requirement |
|-------|-------------|
| Hypothesis | What we think is causing the problem |
| Confidence | HIGH (verified) / MEDIUM (likely) / LOW (uncertain) |
| Evidence | What supports this hypothesis |
| Gaps | What we don't know yet |

If Confidence is LOW → Consider Agent-to-define category, may need investigation.

### Step 3: Determine Outcome Category

Based on evidence quality:

| Evidence Quality | Root Cause Confidence | Category |
|------------------|----------------------|----------|
| Specific data points | HIGH/MEDIUM | Concrete |
| Problem observed, cause unclear | LOW | Agent-to-define |
| External blocker | N/A | Deferred |

### Step 4: Draft Success Criteria

Derive criteria ONLY from evidence:

```
Evidence: "22 mega-clusters with >100 records contain false positives"
    ↓
Criterion: "22 mega-clusters (>100 records) dissolved"

Evidence: "75.1% of ownership_concentration flags are benign RA services"
    ↓
Criterion: "ownership_concentration signal fires <25% of clusters"
```

**Multi-dimensional requirement**: Include at least 2 orthogonal criteria.

### Step 5: Define Anti-Goals

Required for all non-trivial goals. Ask:

1. What would a malicious implementation do?
2. What side effects are unacceptable?
3. What existing functionality must be preserved?
4. What downstream systems depend on current behavior?

See [Anti-Goal Definition](#anti-goal-definition) for guidance.

### Step 6: Write Verification Protocol

For each success criterion, document:
- How to verify it (specific commands, queries, checks)
- Expected values/thresholds
- Where to check (files, systems, outputs)

### Step 7: Create Goal File

Create `docs/todos/goals/[goal-name].md` using the template from SKILL.md.

### Step 8: Request User Approval

Present the goal definition and **STOP**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Goal Definition - Awaiting Approval

**Goal**: [Title]
**Category**: [Concrete / Agent-to-define / Deferred]

### Problem Statement

[Evidence summary]

### Proposed Success Criteria

1. [Criterion 1]
2. [Criterion 2]

### Anti-Goals

- Must NOT [constraint 1]
- Must NOT [constraint 2]

### Verification Protocol

[How success will be verified]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Approve this goal definition?**

Reply with:
- "approved" - Goal is ready for implementation
- "modify [aspect]" - Request specific changes
- "needs investigation" - Change to Agent-to-define
```

### Step 9: Update Goal Status

After user approval:
1. Update goal file Status to "approved"
2. Goal is now ready for task breakdown and implementation

---

## Evidence Gathering

### Required Evidence Types

| Type | Example | Purpose |
|------|---------|---------|
| **Counts** | "1,774 non-Maine records" | Quantify the problem |
| **Percentages** | "17% of records are out-of-state" | Show proportion |
| **Specific cases** | "JEFFERSON GREEN matched NC entity" | Concrete examples |
| **Impact data** | "Causes 3% false positive rate" | Downstream effect |

### Evidence Quality Levels

| Level | Description | Appropriate For |
|-------|-------------|-----------------|
| **Verified** | Query results, test output, logs | Concrete goals |
| **Observed** | User reports, manual inspection | Agent-to-define |
| **Hypothesized** | Suspected but not confirmed | Requires investigation |

### Gathering Evidence

```python
# Example: Evidence gathering for data quality issue
import polars as pl

df = pl.read_parquet("data/processed/nppes_maine.parquet")
non_maine = df.filter(pl.col("state") != "ME")

# Count evidence
print(f"Non-Maine records: {len(non_maine)}")  # → 1,774

# Breakdown evidence
state_counts = non_maine.group_by("state").len().sort("len", descending=True)
print(state_counts.head(5))  # → FL: 311, OH: 130, NC: 83, ...

# Specific case evidence
jefferson = df.filter(pl.col("name").str.contains("JEFFERSON"))
print(jefferson.select(["name", "state", "city"]))
```

---

## Success Criteria Derivation

### The Derivation Rule

Every criterion MUST trace to specific evidence:

```
[Evidence] → [Criterion]
"22 mega-clusters with >100 records" → "22 mega-clusters dissolved"
"Processing takes 45 minutes" → "Processing completes in <10 minutes"
"3 providers have MO addresses" → "0 providers have out-of-state addresses"
```

### Bad Criteria (Invented)

| Criterion | Problem |
|-----------|---------|
| "Improve accuracy" | No baseline, no target |
| "Make it better" | Not measurable |
| "Reduce false positives" | No threshold |
| "Optimize performance" | No specific metric |

### Good Criteria (Grounded)

| Criterion | Grounding |
|-----------|-----------|
| "Dissolve 22 mega-clusters (>100 records)" | Evidence: mega-cluster count |
| "ownership_concentration fires <25%" | Evidence: current rate 75.1% |
| "0 non-Maine records in nppes_maine.parquet" | Evidence: 1,774 exist now |

### Multi-Dimensional Requirement

Single criteria invite gaming. Include orthogonal measures:

```markdown
## Success Criteria

1. 22 mega-clusters dissolved  ← Primary: removes false positives
2. No increase in false negatives  ← Secondary: prevents over-filtering
3. Processing time <15 minutes  ← Tertiary: maintains performance
```

---

## Anti-Goal Definition

### Why Anti-Goals Are Required

Without anti-goals, agents can "succeed" while causing harm:

| Criterion | Without Anti-Goal | Malicious Success |
|-----------|-------------------|-------------------|
| "Reduce false positives" | - | Delete all matches → 0 false positives |
| "Improve speed" | - | Skip validation → faster |
| "Clean data" | - | Delete everything → no bad data |

### Deriving Anti-Goals

For each success criterion, ask:

1. **Inverse question**: What's the opposite failure mode?
   - Criterion: "Reduce false positives"
   - Anti-goal: "Must NOT increase false negatives"

2. **Side effect question**: What could break?
   - Criterion: "Remove non-Maine records"
   - Anti-goal: "Must NOT remove records with missing state that are actually Maine"

3. **Downstream question**: What depends on current behavior?
   - Criterion: "Dissolve mega-clusters"
   - Anti-goal: "Must NOT break legitimate healthcare system clusters"

### Anti-Goal Format

```markdown
### Anti-Goals

- Must NOT increase false negative rate beyond current baseline
- Must NOT require schema changes to downstream parquet files
- Must NOT remove records that are used by validation stage
- Must NOT increase processing time by more than 2x
```

---

## User Approval Gate

### Why Approval Is Required

The approval gate breaks the self-evaluation loop:
- Agent proposes criteria based on evidence
- User validates that criteria match intent
- Agent implements against USER-APPROVED criteria
- No moving goalposts during implementation

### Approval Signals

| Approved | Not Approved |
|----------|--------------|
| "approved" | (no response) |
| "yes, proceed" | "looks okay" (ambiguous) |
| "criteria look good" | Questions about criteria |
| "ready to implement" | Requests for changes |

### After Approval

1. Update goal Status to "approved"
2. Proceed to task breakdown (if needed)
3. Begin implementation against approved criteria
4. Criteria are now LOCKED - no changes without new approval cycle
