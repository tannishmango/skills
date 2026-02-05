# Investigate Goal Workflow

For Agent-to-define goals where investigation is required before success criteria can be specified.

## Contents

- [When This Applies](#when-this-applies) - Agent-to-define category triggers
- [Investigation Protocol](#investigation-protocol) - Two-phase process
- [Proposal Format](#proposal-format) - How to propose success criteria
- [Approval Transition](#approval-transition) - Moving from investigating to approved

---

## When This Applies

This workflow applies to goals with `Outcome Category: Agent-to-define`.

### Triggers for Agent-to-define

| Signal | Example |
|--------|---------|
| Problem observed but cause unclear | "Performance is slow" |
| Multiple possible root causes | "Data quality issues exist" |
| Need exploration before knowing success | "Something is wrong with matching" |
| Evidence is qualitative not quantitative | "Users report incorrect results" |

### Goal File Indicators

```markdown
## Meta

| Field | Value |
|-------|-------|
| Status | investigating |
| Outcome Category | Agent-to-define |
```

---

## Investigation Protocol

### Phase 1: Investigation (Before Criteria Defined)

**Objective**: Gather evidence, identify root cause, determine what success looks like.

#### Step 1: Read Goal File

Load the goal file and understand:
- What problem is observed
- What evidence exists so far
- What gaps need investigation

#### Step 2: Conduct Investigation

Investigate based on problem type:

| Problem Type | Investigation Actions |
|--------------|----------------------|
| Data quality | Query data, check distributions, find anomalies |
| Performance | Profile code, measure timing, identify bottlenecks |
| Incorrect results | Trace specific cases, compare expected vs actual |
| System behavior | Review logs, check configurations, test scenarios |

#### Step 3: Document Findings

Update the goal file with findings:

```markdown
## Investigation Findings

### Date: YYYY-MM-DD

**Questions Investigated**:
- [Question 1]
- [Question 2]

**Findings**:
- [Specific finding with data]
- [Another finding]

**Root Cause Analysis Update**:

| Field | Value |
|-------|-------|
| Hypothesis | [Updated hypothesis] |
| Confidence | [Updated: HIGH/MEDIUM/LOW] |
| Evidence | [New evidence] |
| Gaps | [Remaining unknowns] |
```

#### Step 4: Assess Readiness

After investigation, assess:

| Outcome | Root Cause Confidence | Next Step |
|---------|----------------------|-----------|
| Clear picture | HIGH | Propose success criteria |
| More investigation needed | MEDIUM | Continue investigation |
| Blocked | LOW | Consider Deferred status |

### Phase 2: Proposal (Criteria Definition)

**Objective**: Propose evidence-grounded success criteria for user approval.

#### Step 5: Draft Success Criteria

Based on investigation findings, derive criteria:

```
Finding: "22 mega-clusters exist due to RA over-linking"
    ↓
Criterion: "22 mega-clusters dissolved"

Finding: "75.1% of ownership flags are false positives from RAs"
    ↓
Criterion: "ownership_concentration fires <25%"
```

#### Step 6: Draft Anti-Goals

Based on understanding from investigation:

```
Risk identified: "Filtering RAs could break legitimate entity links"
    ↓
Anti-goal: "Must NOT break legitimate healthcare system clusters"
```

#### Step 7: Draft Verification Protocol

Based on how you gathered evidence:

```markdown
## Verification Protocol

1. **Check mega-cluster count**:
   ```python
   clusters = pl.read_parquet("data/processed/master_entities.parquet")
   mega = clusters.group_by("cluster_id").len().filter(pl.col("len") > 100)
   print(f"Mega-clusters: {len(mega)}")  # Expected: 0
   ```

2. **Check ownership_concentration rate**:
   [Similar verification code]
```

---

## Proposal Format

When ready to propose success criteria, present to user:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Investigation Complete - Proposing Success Criteria

**Goal**: [Title]

### Investigation Summary

**Root Cause Identified**: [Brief description]

**Key Findings**:
- [Finding 1 with data]
- [Finding 2 with data]

**Confidence**: HIGH / MEDIUM

### Proposed Success Criteria

Based on the investigation, I propose these measurable criteria:

1. [Criterion 1] - derived from [finding]
2. [Criterion 2] - derived from [finding]
3. [Criterion 3] - derived from [finding]

### Proposed Anti-Goals

To prevent unintended consequences:

- Must NOT [constraint 1] - because [reason from investigation]
- Must NOT [constraint 2] - because [reason from investigation]

### Proposed Verification Protocol

1. [Verification step 1]
2. [Verification step 2]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Approve these success criteria?**

Reply with:
- "approved" - Criteria locked, ready to implement
- "modify [aspect]" - Request specific changes
- "investigate more" - Continue investigation phase
```

### Proposal Requirements

| Element | Requirement |
|---------|-------------|
| Each criterion | Traces to specific investigation finding |
| Each anti-goal | Addresses identified risk from investigation |
| Verification | Uses same methods as investigation |
| Confidence | Reflects quality of evidence gathered |

---

## Approval Transition

### Before Approval

Goal file shows:

```markdown
## Meta

| Field | Value |
|-------|-------|
| Status | investigating |
| Outcome Category | Agent-to-define |
```

### User Approval

User says one of:
- "approved"
- "criteria look good"
- "yes, implement"

### After Approval

1. **Update goal file**:

```markdown
## Meta

| Field | Value |
|-------|-------|
| Status | approved |
| Outcome Category | Agent-to-define |
```

2. **Add approved criteria**:

The Success Criteria and Anti-Goals sections are now LOCKED.

3. **Proceed to implementation**:

Goal can now be broken into tasks and implemented.

### If Not Approved

| User Response | Action |
|---------------|--------|
| "modify [aspect]" | Update proposed criteria, re-propose |
| "investigate more" | Return to investigation phase |
| "different approach" | Consider new hypothesis, re-investigate |

---

## Important Constraints

### Two-Phase Rule

**Investigation and implementation MUST be separate phases.**

| Phase | Allowed | Not Allowed |
|-------|---------|-------------|
| Investigation | Read, query, analyze, explore | Modify code, change data |
| Implementation | Execute against approved criteria | Change criteria |

### No Implementation Before Approval

Even if investigation reveals an "obvious" fix:

1. Still propose success criteria
2. Still get user approval
3. Then implement

This prevents:
- Agent defining and evaluating own success
- Narrow interpretations that miss user intent
- Goalposts moving during implementation

### Criteria Lock After Approval

Once criteria are approved:
- No changing criteria without new approval cycle
- No adding criteria mid-implementation
- No relaxing anti-goals

If implementation reveals criteria need updating:
1. Stop implementation
2. Explain what new information changed
3. Propose updated criteria
4. Get new approval
5. Resume implementation
