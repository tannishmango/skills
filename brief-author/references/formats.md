# File Format Specifications

## Contents

- [Directory Structure](#directory-structure) - Layout of docs/briefs/ and naming conventions
- [Brief File Format](#brief-file-format) - Metadata header, handoff block, prompt content, outcome
- [Initiative Overview Format](#initiative-overview-format) - Status table and issue count
- [Issues Log Format](#issues-log-format) - Append-only issue entries
- [Standalone Brief Format](#standalone-brief-format) - Date-prefixed briefs outside initiatives
- [README Template](#readme-template) - Template for docs/briefs/README.md

---

## Directory Structure

```
docs/briefs/
+-- README.md                     # Format conventions (created on first use)
+-- issues.md                     # Global issues log (not tied to any initiative)
+-- <initiative-slug>/            # One dir per feature/initiative
|   +-- overview.md               # What, why, status table
|   +-- issues.md                 # Initiative-scoped issue log
|   +-- 001-<slug>.md             # Brief files (numbered for ordering)
|   +-- 002-<slug>.md
|   +-- ...
+-- <YYYY-MM-DD>-<slug>.md        # Standalone briefs (no initiative)
```

### Naming Conventions

- **Initiative slugs**: Lowercase, hyphen-separated, descriptive. Match the feature or effort name. Example: `bundle-sharing-refactor`, `notification-email-system`.
- **Brief slugs**: Short descriptor of the brief's primary task. Example: `001-setup-models`, `002-api-resolvers`, `003-integration-tests`.
- **Standalone slugs**: Date-prefixed with descriptor. Example: `2026-03-01-fix-race-condition`.
- **Sequence numbers**: Zero-padded to 3 digits (`001`, `002`, ...). Determines ordering within an initiative.

### First-Use Initialization

When `docs/briefs/` does not exist, create:

1. `docs/briefs/` directory
2. `docs/briefs/README.md` (see [README Template](#readme-template))
3. `docs/briefs/issues.md` with empty Open/Resolved sections

When creating a new initiative, create:

1. `docs/briefs/<initiative-slug>/` directory
2. `docs/briefs/<initiative-slug>/overview.md`
3. `docs/briefs/<initiative-slug>/issues.md` with empty Open/Resolved sections

## Brief File Format

```markdown
# [Short Title]

| Field | Value |
|-------|-------|
| Status | drafted |
| Created | YYYY-MM-DD |
| Parent | [NNN-slug](NNN-slug.md) or root |

---

## Handoff Metadata

This brief is tracked at @docs/briefs/<initiative>/NNN-slug.md
Invoke /brief-receive to register and begin work.
When you finish, update Status to `completed` and fill the Outcome section.
If you discover issues outside your scope, append them to @docs/briefs/<initiative>/issues.md

---

## Context

[What broader feature/initiative this is part of, if any]
[Overall progress: what has been completed, what remains]
[What the previous agent session accomplished, with specifics]

## Task

[Clear, specific description of what this agent should do]
[Priority ordering if multiple items]
[Preliminary items to address first, if any]

## Key Files and References

[@file references the agent should read to understand current state]
[@doc references for specs, plans, or investigations]
[New files created in the previous session that are relevant]

## Known Issues and Considerations

[Items from self-audit: incomplete work, bugs found, silent omissions]
[Reference to open issues in the initiative's issues.md if relevant]

## Approach Guidance

[Should the agent plan first, analyze first, or dive in?]
[Subagent strategy if applicable]
[Specific tools or skills to leverage]

---

## Outcome

_Filled by receiving agent when work completes._
```

### Field Definitions

| Field | Values | Meaning |
|-------|--------|---------|
| Status | `drafted` | Brief written, not yet pasted into a new agent |
| | `dispatched` | User pasted brief into a new agent, receiving agent acknowledged |
| | `completed` | Receiving agent finished work and filled Outcome |
| | `stale` | Brief abandoned or superseded by a newer brief |
| Created | `YYYY-MM-DD` | Date the brief was authored |
| Parent | Link or `root` | The brief this one continues from. `root` for first brief in an initiative or standalone |

### Parent Links and DAGs

- Linear chain: brief 001 (root) -> 002 (parent: 001) -> 003 (parent: 002)
- Parallel spawn: brief 001 (root) -> 002 (parent: 001), 003 (parent: 001), 004 (parent: 001)
- Convergence: brief 005 (parent: 002, 003, 004) -- list multiple parents comma-separated

### Prompt Content Sections

Not every section is required for every brief. Match density to task complexity:

| Complexity | Required Sections |
|------------|------------------|
| Small | Context, Task, Key Files |
| Medium | Context, Task, Key Files, Known Issues, Approach Guidance |
| Large | All sections |

For detailed prompt construction guidance, see [craft.md](craft.md).

## Initiative Overview Format

```markdown
# [Initiative Name]

[1-2 sentence description of the initiative]

## Briefs

| # | Brief | Status | Summary |
|---|-------|--------|---------|
| 1 | [001-setup-models](001-setup-models.md) | completed | Data models and migrations |
| 2 | [002-api-resolvers](002-api-resolvers.md) | dispatched | GraphQL resolvers and queries |

## Open Issues

[N] open -- see [issues.md](issues.md)
```

### Overview Update Rules

- **Add rows** when new briefs are written (brief-author step 8)
- **Update status** when a brief's lifecycle changes (receiving agent updates)
- **Additive only**: Do not rewrite history. Do not edit summaries of completed briefs.
- **Issue count**: Update the count when issues are appended. Exact count is fine; approximate is acceptable.

## Issues Log Format

```markdown
# Issues

## Open

### YYYY-MM-DD: [Issue Title]
- **Source**: [NNN-slug](NNN-slug.md) or "session without brief"
- **Severity**: critical / important / minor
- **Description**: [Concise description of what was found]

## Resolved

### YYYY-MM-DD: [Issue Title]
- **Resolution**: [What was done]
- **Resolved by**: [NNN-slug](NNN-slug.md)
```

### Severity Definitions

| Severity | Meaning |
|----------|---------|
| critical | Blocks current work, causes incorrect behavior, or risks data loss |
| important | Affects quality or correctness but has a workaround |
| minor | Code quality, cleanup, or optimization opportunity |

### Log Rules

- **Append-only** for the Open section. New issues go at the bottom.
- **Move to Resolved** when fixed. Copy the entry, add resolution details, remove from Open.
- **Source link** references the brief that discovered the issue. If discovered outside a brief workflow, use "session without brief".
- **Global vs initiative**: Use `docs/briefs/issues.md` for issues not tied to any initiative. Use `docs/briefs/<initiative>/issues.md` for initiative-scoped issues.

## Standalone Brief Format

Standalone briefs are date-prefixed files at the `docs/briefs/` root. They use the same format as initiative briefs but without initiative-specific references:

- File name: `YYYY-MM-DD-<slug>.md`
- Parent field: `root` (or link to another standalone brief if continuing work)
- Handoff metadata references `docs/briefs/YYYY-MM-DD-slug.md` instead of an initiative path
- Issues go to `docs/briefs/issues.md` (global log)

## README Template

Create this file at `docs/briefs/README.md` on first use:

```markdown
# Agent Work Briefs

Persistent records of agent-to-agent handoffs with lifecycle tracking and issue capture.

## Structure

- **Initiative directories** (`<slug>/`): Group related briefs for a feature or effort. Each has an `overview.md` and `issues.md`.
- **Standalone briefs** (`YYYY-MM-DD-slug.md`): One-off briefs not part of an initiative.
- **Global issues** (`issues.md`): Issues not tied to any initiative.

## Brief Lifecycle

`drafted` -> `dispatched` -> `completed` (or `stale`)

## Skills

- `/brief-author` -- Author a brief at the end of a session
- `/brief-receive` -- Receive and acknowledge a brief at the start of a session
```
