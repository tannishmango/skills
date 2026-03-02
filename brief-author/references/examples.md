# Brief Examples

## Contents

- [Small: Bug Fix Follow-Up](#small-bug-fix-follow-up) - Simple standalone brief
- [Medium: Feature Phase Continuation](#medium-feature-phase-continuation) - Initiative brief with issue capture
- [Large: Multi-Track Feature With Orchestration](#large-multi-track-feature-with-orchestration) - Full initiative brief with parallel tracks and issue awareness
- [Patterns Across Examples](#patterns-across-examples) - Common traits of effective briefs

---

Each example shows the complete brief file as it would be written to `docs/briefs/`. Commentary follows each example.

## Small: Bug Fix Follow-Up

**File**: `docs/briefs/2026-03-01-conflict-dedup-tests.md` (standalone)

```markdown
# Conflict Dedup Tests

| Field | Value |
|-------|-------|
| Status | drafted |
| Created | 2026-03-01 |
| Parent | root |

---

## Handoff Metadata

This brief is tracked at @docs/briefs/2026-03-01-conflict-dedup-tests.md
Invoke /brief-receive to register and begin work.
When you finish, update Status to `completed` and fill the Outcome section.
If you discover issues outside your scope, append them to @docs/briefs/issues.md

---

## Context

The previous agent session fixed a race condition in the conflict detection pipeline
where duplicate signals were being emitted when two assets shared overlapping ISRC sets.
The fix was applied in `src/conflicts/pipeline.py` by adding a deduplication step in
`emit_signals()`. All existing tests pass.

## Task

Add targeted unit tests for the deduplication logic:

1. Test that `emit_signals()` produces no duplicates with overlapping ISRC sets
2. Test the edge case where two assets have identical ISRC sets (should produce one signal)
3. Test that non-overlapping ISRC sets still produce independent signals (regression check)

## Key Files

@src/conflicts/pipeline.py - The `emit_signals()` function starting around line 87 has
the new deduplication logic.
@tests/conflicts/test_pipeline.py - Existing test file to add the new tests to.

## Known Issues

The deduplication uses a set-based approach which doesn't preserve signal ordering. Fine
for current use but may matter if signal priority ordering is added later. Note in a
code comment if encountered.

---

## Outcome

_Filled by receiving agent when work completes._
```

**Commentary**: Lean standalone brief. No initiative directory needed. No orchestration guidance for a straightforward test-writing task. Known issue mentioned as context, not as a task.

---

## Medium: Feature Phase Continuation

**File**: `docs/briefs/asset-value-redesign/003-aggregation-layer.md`

**Initiative state**: `overview.md` shows briefs 001 (data model) and 002 (scoring engine) completed. The initiative's `issues.md` has one open issue about configurable weights.

```markdown
# Aggregation Layer

| Field | Value |
|-------|-------|
| Status | drafted |
| Created | 2026-03-01 |
| Parent | [002-scoring-engine](002-scoring-engine.md) |

---

## Handoff Metadata

This brief is tracked at @docs/briefs/asset-value-redesign/003-aggregation-layer.md
Invoke /brief-receive to register and begin work.
When you finish, update Status to `completed` and fill the Outcome section.
If you discover issues outside your scope, append them to @docs/briefs/asset-value-redesign/issues.md

---

## Context

This is part of the asset value score redesign
(@docs/briefs/asset-value-redesign/overview.md).

Progress:
- Brief 001 (data model): Complete. `ScoreDimension` and `AssetScoreProfile` models in place.
- Brief 002 (scoring engine): Complete. `DimensionalScorer` computes dimension scores.
- Brief 003 (aggregation layer): This brief. Partially started by the previous session.

The previous session created `AggregationStrategy` base class and `WeightedAverage` strategy
in `src/scoring/aggregation.py`. The session ran long and remaining items were not completed.

**Open issues**: The initiative has 1 open issue
(@docs/briefs/asset-value-redesign/issues.md): `WeightedAverage` uses equal weights only;
the design doc specifies configurable weights per dimension. This simplification was
surfaced by brief 002's self-audit.

## Task

Complete the aggregation layer. Remaining items:

1. **Implement `HierarchicalAggregation` strategy** - Second strategy from the design doc.
   Aggregates dimension scores in a tree structure based on `ScoreDimension.category`.

2. **Wire aggregation into the scoring pipeline** - `DimensionalScorer.compute()` currently
   returns raw scores. Update it to accept an `AggregationStrategy` and return both raw
   scores and the aggregated result.

3. **Add tests for both strategies** - `WeightedAverage` tests exist but need edge cases.
   `HierarchicalAggregation` tests not started.

## Key Files

@openspec/changes/redesign-asset-value-score/tasks.md - Full task list with acceptance criteria
@openspec/changes/redesign-asset-value-score/proposal.md - Design rationale and scoring model
@src/scoring/aggregation.py - Existing module with `AggregationStrategy` and `WeightedAverage`
@src/scoring/engine.py - `DimensionalScorer` class needing aggregation integration
@tests/scoring/test_aggregation.py - Partial tests for `WeightedAverage`

## Known Issues

- The open issue about configurable weights (see initiative issues.md). Either implement
  configurable weights or confirm with the user that equal weights are acceptable for now.
- Potential circular import between `scoring/engine.py` and `scoring/aggregation.py` if
  aggregation strategies reference `DimensionalScorer` types. Use Protocol or TYPE_CHECKING.

## Approach Guidance

Start by reading the design doc and existing aggregation code to understand established
patterns. `HierarchicalAggregation` should follow the same interface as `WeightedAverage`.
Implement, then integrate, then test.

---

## Outcome

_Filled by receiving agent when work completes._
```

**Commentary**: Medium-density initiative brief. References the overview and open issues. Surfaces the prior agent's silent omission (equal weights). Provides specific approach guidance without over-prescribing.

---

## Large: Multi-Track Feature With Orchestration

**File**: `docs/briefs/conflict-detection/003-path-analysis.md`

**Initiative state**: `overview.md` shows 001 (signal architecture) and 002 (detection pipeline) completed. `issues.md` has two open issues from previous agents.

```markdown
# Path Analysis System

| Field | Value |
|-------|-------|
| Status | drafted |
| Created | 2026-03-01 |
| Parent | [002-detection-pipeline](002-detection-pipeline.md) |

---

## Handoff Metadata

This brief is tracked at @docs/briefs/conflict-detection/003-path-analysis.md
Invoke /brief-receive to register and begin work.
When you finish, update Status to `completed` and fill the Outcome section.
If you discover issues outside your scope, append them to @docs/briefs/conflict-detection/issues.md

---

## Context

This is part of the conflict detection and resolution initiative
(@docs/briefs/conflict-detection/overview.md).

The initiative spans 6 areas:
1. Signal architecture - DONE (brief 001)
2. Detection pipeline - DONE (brief 002)
3. Path analysis - THIS BRIEF
4. Resolution strategies - NOT STARTED
5. GraphQL API surface - NOT STARTED
6. UI integration - NOT STARTED

Previous sessions built the signal architecture and detection pipeline. The pipeline
(@src/conflicts/pipeline.py) identifies potential conflicts by analyzing overlapping
metadata (ISRCs, ISWCs, writer/artist identities) and emits typed signals persisted
to `conflict_signals`.

**Open issues** (2 in @docs/briefs/conflict-detection/issues.md):
1. "Writer identity ambiguity" (important) - duplicate entries in `artist_writer_identities`
   where name variations weren't normalized. May produce false-positive signals.
2. "Test fixture staleness" (minor) - deprecated model fields in `tests/conftest.py`
   produce warnings.

## Task

Implement the path analysis system (area 3) which takes conflict signals and determines
resolution paths.

### Track A: Path Resolution Engine

1. Create `src/conflicts/paths.py` with `PathResolver` class
2. Implement path determination rules from @docs/conflicts/paths.md
3. Each signal type maps to resolution paths (mapping defined in the doc)
4. `PathResolver.resolve(signal: ConflictSignal) -> list[ResolutionPath]`
5. `ResolutionPath` model in `src/conflicts/models.py` with Alembic migration

### Track B: Path Persistence and Querying

1. `conflict_paths` table via the new model
2. `src/conflicts/queries.py` with functions to store and query resolved paths
3. Integration tests against the test database

### Track C: Pipeline Integration

1. Extend detection pipeline to call `PathResolver` after signal emission
2. Store resolved paths automatically as part of pipeline runs
3. End-to-end pipeline tests verifying signal -> path flow

## Key Files

@docs/conflicts/overview.md - Architecture overview
@docs/conflicts/paths.md - Path analysis requirements and resolution path definitions
@docs/conflicts/signal-architecture.md - Signal types and semantics (needed for path mapping)
@src/conflicts/pipeline.py - Detection pipeline to extend
@src/conflicts/models.py - Existing conflict models
@alembic/ - Migration directory; use `make citadel-revision` to autogenerate

## Known Issues

- `ConflictSignal` uses a string enum for `signal_type`. The path mapping references
  signal types that may not all be in the current enum. Verify enum values match the
  docs. Adding values requires an enum-safe Alembic migration (see alembic-migrations skill).

- Pipeline tests use in-memory SQLite. Path persistence tests need full Postgres setup
  since they involve enum types. Check test infrastructure support.

- `pipeline.py` is ~400 lines. After integrating path resolution, consider whether to
  split it. Flag for the next brief if so -- don't refactor as part of this task.

- The open "writer identity ambiguity" issue from the initiative's issues.md may produce
  false-positive signals that affect path analysis. Be aware when writing tests and consider
  whether path analysis should handle this case gracefully.

## Approach Guidance

This task has three relatively independent tracks:

1. **Define shared model first**: Create `ResolutionPath` model and migration before
   parallelizing. Tracks A and B both depend on this model.

2. **Parallelize Tracks A and B**: Use subagents. Track A (path resolution engine) and
   Track B (persistence and querying) can be developed concurrently after the model exists.

3. **Sequence Track C last**: Pipeline integration depends on both A and B.

4. **Commit incrementally**: After model + migration, after Track A, after Track B,
   after Track C.

For the Alembic migration, use the project's alembic-migrations skill for enum safety.

---

## Outcome

_Filled by receiving agent when work completes._
```

**Commentary**: Full-structure initiative brief. References initiative overview and open issues. Three parallel tracks with dependency analysis. Specific orchestration guidance (shared model first, then parallelize). References open issues from other agents and their impact on this task. Practical known issues with actionable guidance.

---

## Patterns Across Examples

Effective briefs share these traits regardless of size:

1. **State is explicit**: what's done, what's in progress, what's broken
2. **Files are referenced with context**: not just paths but what to look for
3. **Omissions are surfaced**: previous agent's gaps called out, not hidden
4. **Scope is bounded**: the agent knows what's in and out of scope
5. **Issues are persistent**: discovered problems written to issues.md, not just mentioned
6. **Initiative context is present**: open issues and previous brief outcomes are referenced
7. **Handoff metadata is always included**: receiving agent knows where the brief file is and what protocol to follow
