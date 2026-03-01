# Handoff Prompt Examples

## Contents

- [Small: Bug Fix Follow-Up](#small-bug-fix-follow-up) - Simple continuation after a focused session
- [Medium: Feature Phase Continuation](#medium-feature-phase-continuation) - Multi-file work as part of a broader feature
- [Large: Multi-Track Feature With Orchestration](#large-multi-track-feature-with-orchestration) - Complex handoff with subagent guidance and tangential items

---

Each example shows a complete handoff prompt as the user would paste it. Commentary follows each example.

## Small: Bug Fix Follow-Up

```
## Context

The previous agent session fixed a race condition in the conflict detection pipeline
where duplicate signals were being emitted when two assets shared overlapping ISRC sets.
The fix was applied in `src/conflicts/pipeline.py` by adding a deduplication step in
`emit_signals()`. All existing tests pass.

## Task

Add targeted unit tests for the deduplication logic introduced in the fix. Specifically:

1. Test that `emit_signals()` produces no duplicates when called with overlapping ISRC sets
2. Test the edge case where two assets have identical ISRC sets (should produce exactly one signal)
3. Test that non-overlapping ISRC sets still produce independent signals (regression check)

## Key Files

@src/conflicts/pipeline.py - The `emit_signals()` function starting around line 87 contains
the new deduplication logic.
@tests/conflicts/test_pipeline.py - Existing test file to add the new tests to.

## Known Issues

The deduplication uses a set-based approach which doesn't preserve signal ordering. This is
fine for the current use case but may matter if signal priority ordering is added later.
Note this in a code comment if you encounter it.
```

**Commentary**: Lean prompt. No orchestration guidance needed for a straightforward test-writing task. Known issue is mentioned as an aside, not a task. The agent can start immediately.

---

## Medium: Feature Phase Continuation

```
## Context

This is part of the asset value score redesign (@openspec/changes/redesign-asset-value-score/tasks.md).
The initiative replaces the legacy single-score model with a multi-dimensional scoring system.

Progress so far:
- Task 1 (data model changes): Complete. New `ScoreDimension` model and `AssetScoreProfile`
  are in place with an Alembic migration.
- Task 2 (scoring engine): Complete. The `DimensionalScorer` class in `src/scoring/engine.py`
  computes individual dimension scores.
- Task 3 (aggregation layer): This is the current task, partially started.

The previous session created the `AggregationStrategy` base class and the `WeightedAverage`
strategy in `src/scoring/aggregation.py`. However, the session ran long and the following
items were not completed:

## Task

Complete Task 3 (aggregation layer) from the task list. Remaining items:

1. **Implement `HierarchicalAggregation` strategy** - The second aggregation strategy defined
   in the design doc. It should aggregate dimension scores in a tree structure based on
   score category groupings defined in `ScoreDimension.category`.

2. **Wire aggregation into the scoring pipeline** - The `DimensionalScorer.compute()` method
   currently returns raw dimension scores. Update it to accept an `AggregationStrategy` and
   return both raw scores and the aggregated result.

3. **Add tests for both strategies** - Unit tests for `WeightedAverage` (partially written,
   need edge cases) and `HierarchicalAggregation` (not started).

## Key Files

@openspec/changes/redesign-asset-value-score/tasks.md - Full task list with acceptance criteria
@openspec/changes/redesign-asset-value-score/proposal.md - Design rationale and scoring model
@src/scoring/aggregation.py - Existing aggregation module with `AggregationStrategy` base
  and `WeightedAverage`. The `HierarchicalAggregation` class needs to be added here.
@src/scoring/engine.py - The `DimensionalScorer` class that needs the aggregation integration
@tests/scoring/test_aggregation.py - Partial tests for `WeightedAverage`, needs completion

## Known Issues

- The `WeightedAverage` strategy currently uses equal weights as a default. The design doc
  specifies configurable weights per dimension. The previous agent implemented equal weights
  only and did not surface this simplification. You should either implement configurable
  weights or explicitly confirm with the user that equal weights are acceptable for now.

- There's a potential circular import between `scoring/engine.py` and `scoring/aggregation.py`
  if aggregation strategies need to reference `DimensionalScorer` types. Use Protocol or
  TYPE_CHECKING import if this arises.

## Approach Guidance

Start by reading the design doc and existing aggregation code to understand the patterns
already established. The `HierarchicalAggregation` should follow the same interface as
`WeightedAverage`. Write the implementation, then the integration, then the tests.
```

**Commentary**: Medium-density prompt. Includes broader scope positioning, explicit progress tracking, a surfaced silent omission (the equal-weights simplification), and a practical warning about circular imports. Approach guidance is light and appropriate.

---

## Large: Multi-Track Feature With Orchestration

```
## Context

This is part of a multi-PR initiative to add conflict detection and resolution capabilities
to Castle (@docs/conflicts/overview.md for the full architecture).

The initiative spans 6 major areas:
1. Signal architecture - DONE (@docs/conflicts/signal-architecture.md)
2. Detection pipeline - DONE
3. Path analysis - IN PROGRESS (this prompt)
4. Resolution strategies - NOT STARTED
5. GraphQL API surface - NOT STARTED
6. UI integration - NOT STARTED

The previous two agent sessions built the signal architecture and detection pipeline. The
detection pipeline (@src/conflicts/pipeline.py) can now identify potential conflicts between
assets by analyzing overlapping metadata (ISRCs, ISWCs, writer/artist identities). It emits
typed signals that are persisted to the `conflict_signals` table.

The previous session also discovered some issues outside the pipeline work that should be
noted (see Tangential Items below).

## Task

Implement the path analysis system (area 3) which takes conflict signals and determines
the resolution path for each conflict. This involves:

### Track A: Path Resolution Engine

Build the core path resolution logic:

1. Create `src/conflicts/paths.py` with a `PathResolver` class
2. Implement path determination rules from @docs/conflicts/paths.md
3. Each signal type maps to one or more resolution paths (the mapping is defined in the doc)
4. `PathResolver.resolve(signal: ConflictSignal) -> list[ResolutionPath]` is the primary interface
5. `ResolutionPath` should be a new model - add it to `src/conflicts/models.py` and create
   the corresponding Alembic migration (use `make citadel-revision` for autogeneration)

### Track B: Path Persistence and Querying

1. Add a `conflict_paths` table via the new model
2. Create `src/conflicts/queries.py` with functions to:
   - Store resolved paths
   - Query paths by conflict ID, signal type, and resolution status
   - Aggregate path statistics (counts by type and status)
3. Write integration tests against the test database

### Track C: Pipeline Integration

1. Extend the detection pipeline to call `PathResolver` after signal emission
2. Store resolved paths automatically as part of the pipeline run
3. Add pipeline-level tests that verify end-to-end signal -> path flow

## Key Files

@docs/conflicts/overview.md - Architecture overview for the entire conflict system
@docs/conflicts/paths.md - Detailed path analysis requirements and resolution path definitions
@docs/conflicts/signal-architecture.md - Signal types and their semantics (needed for path mapping)
@src/conflicts/pipeline.py - Existing detection pipeline to extend
@src/conflicts/models.py - Existing conflict models (ConflictSignal, etc.)
@src/conflicts/queries.py - May or may not exist yet; create if needed
@alembic/ - Migration directory; use `make citadel-revision` to autogenerate

## Known Issues

- The `ConflictSignal` model uses a string enum for `signal_type`. The path mapping in the
  docs references signal types that may not all be in the current enum. Verify the enum
  values match the docs before building the path resolver, and add any missing values
  (this requires an Alembic migration for the enum - see the alembic-migrations skill
  for enum-safe migration patterns).

- The previous session's pipeline tests use an in-memory SQLite database. The path
  persistence tests will need the full Postgres test setup since they involve enum types
  and potentially Postgres-specific query patterns. Check if the test infrastructure
  supports this or if setup is needed.

- `pipeline.py` has grown to ~400 lines. After integrating path resolution, consider
  whether it should be split, but don't refactor it as part of this task unless integration
  makes it unwieldy. Flag it for the next session if so.

## Approach Guidance

This task has three relatively independent tracks. Consider this approach:

1. **Plan first**: Read the path analysis requirements doc thoroughly. Create a brief plan
   or use TodoWrite to outline the implementation order. Tracks A and B are largely
   independent; Track C depends on both.

2. **Use subagents for parallelism**: Tracks A (path resolution engine) and B (persistence
   and querying) can be developed in parallel by subagents once the shared model
   (`ResolutionPath`) is defined. Define the model first, then parallelize.

3. **Sequence Track C last**: Pipeline integration depends on both A and B being complete.
   Do this in the main agent after subagent tracks finish.

4. **Commit incrementally**: Commit after the model + migration, after Track A, after
   Track B, and after Track C. This keeps changes reviewable.

For the Alembic migration, follow the project's migration skill - specifically the enum
safety patterns since you may need to add enum values.

## Tangential Items

The following were discovered during the previous session but are outside this task's scope:

- **Writer identity ambiguity**: The `artist_writer_identities` table has duplicate entries
  for some writers where name variations weren't properly normalized. This doesn't block
  conflict detection but may produce false-positive signals in some cases. Document this
  in @docs/investigations/ if a file doesn't already exist, or append to the existing
  investigation doc if one covers this topic.

- **Test fixture staleness**: Several test fixtures in `tests/conftest.py` reference
  deprecated model fields. They still work but produce warnings. Low priority but worth
  noting for a future cleanup pass. Don't fix these now.
```

**Commentary**: Full-structure prompt for a complex multi-track task. Includes detailed broader scope positioning with progress tracking, three parallel work tracks with dependency analysis, specific orchestration guidance (define shared model first, then parallelize), practical known issues with actionable guidance, and tangential items with explicit handling instructions. The new agent can orient immediately, plan its approach, and begin with confidence about what matters and what to defer.

---

## Patterns Across Examples

Regardless of size, effective handoff prompts share these traits:

1. **State is explicit**: what's done, what's in progress, what's broken
2. **Files are referenced with context**: not just paths but what to look for in each
3. **Omissions are surfaced**: previous agent's gaps are called out, not hidden
4. **Scope is bounded**: the agent knows what's in and out of scope
5. **Complexity matches format**: small tasks get lean prompts, large tasks get structured ones
