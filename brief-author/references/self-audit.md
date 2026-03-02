# Self-Audit Patterns

## Contents

- [Why Self-Audit Matters](#why-self-audit-matters) - The core problem and behavioral change
- [Silent Omission Categories](#silent-omission-categories) - Common ways agents quietly drop work
- [Detection Techniques](#detection-techniques) - How to find what was missed
- [Subagent Blind Spots](#subagent-blind-spots) - Visibility gaps from delegated work
- [Cross-Agent Awareness](#cross-agent-awareness) - Reading initiative context before auditing
- [Mandatory Issue Persistence](#mandatory-issue-persistence) - Writing findings to files, not just mentioning them

---

## Why Self-Audit Matters

Agents routinely make scope-reducing decisions without surfacing them. A spec says "implement X with Y and Z" and the agent implements X with Y, quietly dropping Z because it was complex or ambiguous. The user doesn't notice because agents touch many files and produce confident summaries. Subagents compound this by adding delegation layers where the parent agent may not fully review all output.

Self-audit before authoring a brief is the countermeasure. It forces the current agent to compare what was asked against what was delivered and surface the delta honestly.

### Behavioral Change From Previous Workflow

The old workflow had three categories with these behaviors:

| Category | Old Behavior | New Behavior |
| --- | --- | --- |
| Must include in brief | Include in brief | Include in brief (unchanged) |
| Mention to user | Verbal mention only | Verbal mention AND write to issues.md |
| Document for later | Verbal suggestion to document | **Mandatory write to issues.md** |

The critical change: **"document for later" is now a file write, not a suggestion.** Every finding in categories 2 and 3 must be persisted to the initiative's `issues.md` (or global `issues.md` for standalone work). Nothing is communicated only verbally.

## Silent Omission Categories

### Complexity Avoidance

The agent encounters a complex requirement and implements a simpler version without mentioning the tradeoff.

**Signs**: A feature works for the basic case but not for edge cases described in the spec. The agent's summary describes what was built but omits what the spec also asked for.

**Detection**: Compare the original request/spec/plan against the implementation. List every concrete requirement. Check each: done, partial, or missing.

### Implicit Simplification

The agent replaces a dynamic/configurable solution with hardcoded values or simplified logic.

**Signs**: Magic numbers, hardcoded strings, single-case handling where the spec called for configurability.

**Detection**: Search for TODO comments, hardcoded values, and placeholder strings in new code. Check if configurable behavior was reduced to constants.

### Deferred Error Handling

The agent implements happy paths and defers or omits error handling, validation, and recovery logic.

**Signs**: Bare except clauses, missing input validation, no handling for API failures.

**Detection**: Trace each new function's error paths. Check if external calls have failure handling.

### Test Coverage Gaps

The agent writes implementation but skips or minimally covers testing.

**Signs**: Tests only cover happy paths. No tests for error conditions or boundary inputs.

**Detection**: Compare implemented behaviors against tested behaviors.

### Interface Drift

The agent implements something that works internally but doesn't fully integrate with the broader system.

**Signs**: New functions not wired into call sites. Schema changes without resolver updates. Model changes without migrations.

**Detection**: Trace the integration surface. Check if new code is reachable from the existing system.

### Scope Creep Avoidance (Silent)

The agent notices a requirement implies additional changes elsewhere but skips them to stay focused.

**Signs**: A change to module A that logically requires corresponding changes in B and C, but B and C were not touched.

**Detection**: Look at the dependency graph of changed code. Check callers, consumers, and related modules.

## Detection Techniques

### Spec-vs-Implementation Diff

Read the original task description, plan, or spec. List every concrete requirement. Mark each as: done, partial, or missing.

### Code-Level Scan

Review files the session touched. Look for:

- TODO / FIXME / HACK comments
- Functions defined but not called or tested
- Stubbed return values or placeholder logic
- Import statements for unused modules

### Summary Inversion

Read the agent's own summaries. Invert them: what did the summary *not* mention? The gaps between "what was asked" and "what was summarized" often contain silent omissions.

### Change Set Review

Look at the set of files modified. Ask:

- Are there files that *should* have been modified but weren't?
- Are there files modified with partial changes?
- Were configuration files, migrations, or schema files updated to match?

## Subagent Blind Spots

When subagents were used during the session, audit their work with extra scrutiny.

### Reduced Visibility

The parent agent sees subagent output summaries but may not review every line of code. Files touched by subagents deserve explicit review.

### Instruction Drift

Subagents receive a task description from the parent but may interpret it differently. Check if the subagent's output matches what the parent intended and what the user originally requested.

### Partial Completion

Subagents may complete their task partially and report success. Verify subagent deliverables against the original subtask description.

### Cross-Subagent Integration

When multiple subagents handle related work, integration gaps are common. Check alignment between subagent outputs.

### Audit Protocol

For sessions that used subagents:

1. List every subagent invocation and its assigned task.
2. Compare each task description against actual output.
3. Check integration between subagent outputs.
4. Flag any subagent output accepted without review.

## Cross-Agent Awareness

When authoring a brief for an existing initiative, the agent operates in a multi-agent context. Previous agents may have:

- Implemented features that the current agent's changes depend on or affect
- Discovered issues that are still open
- Made architectural decisions that constrain the current work
- Left incomplete work that was deferred

### Pre-Audit Context Gathering

Before running the self-audit, read:

1. The initiative's `overview.md` to understand what previous briefs accomplished
2. The initiative's `issues.md` to see open issues from other agents
3. The most recent completed brief's Outcome section for specifics

This context prevents the common failure where an agent claims an issue "existed before my changes" when in fact another agent on the same initiative introduced it.

### Attributing Issues

When the self-audit discovers an issue:

- If it was introduced by the current session: must include in brief
- If it was introduced by a previous agent on the same initiative: write to issues.md with correct source attribution
- If it genuinely predates the initiative: write to issues.md and note it as pre-existing
- If uncertain: write to issues.md and note the uncertainty. Do not silently classify as "pre-existing" to avoid responsibility.

## Mandatory Issue Persistence

After completing the self-audit, every finding must be handled:

### Must Include In Brief

The receiving agent needs to handle these. They are prerequisites or blockers:

- Incomplete implementations the next task depends on
- Bugs introduced that affect the codebase
- Missing migrations, schema changes, or type updates
- Critical test gaps

### Mention To User AND Write To Issues Log

These need a user decision AND must be persisted:

- Scope questions: "The spec says X but I implemented Y. Should the next agent implement X or is Y acceptable?"
- Design tradeoffs with downstream implications
- Discovered problems in existing code outside the current effort

### Write To Issues Log (Mandatory)

Not urgent but must not be lost:

- Minor code quality issues
- Performance concerns that aren't blocking
- Refactoring opportunities
- Ideas or improvements discovered during implementation

For the issues log entry format, see [formats.md](formats.md).
