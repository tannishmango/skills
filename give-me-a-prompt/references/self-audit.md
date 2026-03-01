# Self-Audit Patterns

## Contents

- [Why Self-Audit Matters](#why-self-audit-matters) - The core problem this solves
- [Silent Omission Categories](#silent-omission-categories) - Common ways agents quietly drop work
- [Detection Techniques](#detection-techniques) - How to find what was missed
- [Subagent Blind Spots](#subagent-blind-spots) - Visibility gaps from delegated work
- [Surfacing Findings](#surfacing-findings) - How to present audit results

---

## Why Self-Audit Matters

Agents routinely make scope-reducing decisions without surfacing them. A spec says "implement X with Y and Z" and the agent implements X with Y, quietly dropping Z because it was complex or ambiguous. The user doesn't notice because agents touch many files and produce confident summaries. Subagents compound this by adding a layer of delegation where the parent agent may not fully review all output.

Self-audit before a handoff prompt is the countermeasure. It forces the current agent to compare what was asked against what was delivered and surface the delta honestly.

## Silent Omission Categories

These are the most common patterns where agents quietly reduce scope or skip work:

### Complexity Avoidance

The agent encounters a requirement that would significantly increase implementation complexity and implements a simpler version without mentioning the tradeoff.

**Signs**: A feature works for the basic case but not for the edge cases described in the spec. The agent's summary describes what was built but doesn't mention what the spec also asked for.

**Detection**: Compare the original request/spec/plan against the actual implementation. Look for requirements that are present in the input but absent from the output and the agent's summary.

### Implicit Simplification

The agent replaces a dynamic/configurable solution with hardcoded values, constants, or simplified logic.

**Signs**: Magic numbers, hardcoded strings, single-case switch statements where the spec called for configurability. Functions that handle one variant when multiple were specified.

**Detection**: Search for TODO comments, hardcoded values, and placeholder strings in new code. Check if configurable behavior was reduced to constants.

### Deferred Error Handling

The agent implements happy paths and defers or omits error handling, validation, and recovery logic.

**Signs**: Bare except clauses, missing input validation, no handling for API failures or edge-case inputs. Functions that assume all inputs are well-formed.

**Detection**: Trace each new function's error paths. Check if external calls have failure handling. Look for validation logic at boundaries.

### Test Coverage Gaps

The agent writes implementation but skips or minimally covers testing, especially for edge cases and error paths.

**Signs**: Tests only cover the happy path. No tests for error conditions. No tests for boundary inputs. Integration tests missing for new API endpoints.

**Detection**: Compare the set of implemented behaviors against the set of tested behaviors. Check if error paths and edge cases have test coverage.

### Interface Drift

The agent implements something that works internally but doesn't fully integrate with the broader system. API contracts, GraphQL schema changes, database migrations, or type definitions may be out of sync.

**Signs**: New functions not wired into existing call sites. Schema changes without corresponding resolver updates. Model changes without migrations.

**Detection**: Trace the integration surface. Check if new code is reachable from the existing system. Verify schema, migration, and type alignment.

### Scope Creep Avoidance (Silent)

The agent notices that a requirement implies additional changes elsewhere but skips those changes to stay focused. This is sometimes correct, but should be surfaced.

**Signs**: A change to module A that logically requires corresponding changes in modules B and C, but B and C were not touched. The agent's summary focuses on A.

**Detection**: Look at the dependency graph of changed code. Identify callers, consumers, and related modules. Check if they need updates.

## Detection Techniques

### Spec-vs-Implementation Diff

Read the original task description, plan, spec, or user request. List every concrete requirement. Check each against the implementation. Mark as: done, partial, or missing.

### Code-Level Scan

Review files the session touched. Look for:

- TODO / FIXME / HACK comments (the agent's own breadcrumbs)
- Functions that are defined but not called or tested
- Stubbed return values or placeholder logic
- Import statements for unused modules (sometimes remnants of abandoned approaches)

### Summary Inversion

Read the agent's own summaries and completion messages from the session. Invert them: what did the summary *not* mention? Summaries tend to list what was done. The gaps between "what was asked" and "what was summarized" often contain the silent omissions.

### Change Set Review

Look at the set of files modified. Ask:

- Are there files that *should* have been modified but weren't?
- Are there files that were modified with partial changes (e.g., added a function but didn't update the corresponding test file)?
- Were configuration files, migrations, or schema files updated to match code changes?

## Subagent Blind Spots

When subagents were used during the session, audit their work with extra scrutiny:

### Reduced Visibility

The parent agent sees subagent output summaries but may not review every line of code they produced. Files touched by subagents deserve explicit review.

### Instruction Drift

Subagents receive a task description from the parent but may interpret it differently. Check if the subagent's output actually matches what the parent intended and what the user originally requested.

### Partial Completion

Subagents may complete their assigned task partially and report success. The parent agent, trusting the report, moves on. Verify subagent deliverables against the original subtask description.

### Cross-Subagent Integration

When multiple subagents handle related work, integration gaps are common. One subagent modifies an interface, another consumes it, and neither fully aligns with the other's changes.

### Audit Protocol

For sessions that used subagents:

1. List every subagent invocation and its assigned task.
2. For each, compare the task description against the actual output.
3. Check for integration between subagent outputs.
4. Flag any subagent output that was accepted without review.

## Surfacing Findings

After running the audit, categorize findings:

### Must Include In Prompt

The next agent needs to handle these. They are prerequisites or blockers for the next task:

- Incomplete implementations that the next task depends on
- Bugs introduced that affect the codebase
- Missing migrations, schema changes, or type updates
- Critical test gaps for code that's already merged or will be

### Mention To User

These need a user decision and don't belong in the prompt unilaterally:

- Scope questions: "The spec says X but I implemented Y because of Z. Should the next agent implement X or is Y acceptable?"
- Design tradeoffs: "I used approach A instead of B. This has implications for..."
- Discovered problems in existing code that are outside the current effort

### Document For Later

Not urgent but shouldn't be lost:

- Minor code quality issues noticed in passing
- Performance concerns that aren't blocking
- Refactoring opportunities
- Ideas or improvements that occurred during implementation

For "document for later" items, the prompt can instruct the next agent to write them down in a specific location (investigation doc, TODO file, issue tracker) rather than acting on them.
