---
name: brief-receive
description: Receives and tracks agent work briefs through completion. Use when starting a session from a handoff brief, when the prompt contains a Handoff Metadata section, or when the user says "brief-receive", "start from brief", or "pick up the brief". Updates brief lifecycle status, records outcomes, and captures discovered issues.
---

# Brief Receive

## Contents

- [When To Use](#when-to-use) - Trigger conditions
- [Protocol](#protocol) - The 4-step receiving workflow
- [Issue Capture](#issue-capture) - Persisting discovered issues during work
- [Evaluation Scenarios](#evaluation-scenarios) - Expected behavior

---

## When To Use

Use this skill when:

- The agent's input prompt contains a `## Handoff Metadata` section referencing a brief file
- The user invokes `/brief-receive` explicitly
- The user says "start from brief", "pick up the brief", or similar

## Protocol

Four steps. No branching. No decisions.

### Step 1: Read

Read the brief file referenced in the handoff metadata section of your prompt.

```
This brief is tracked at @docs/briefs/<initiative>/NNN-slug.md
```

Read this file. Also read the initiative's `overview.md` and `issues.md` if they exist, to understand broader context and open issues from previous agents.

### Step 2: Acknowledge

Update the brief file's Status field from `drafted` to `dispatched`:

```markdown
| Status | dispatched |
```

### Step 3: Work

Execute the task described in the brief. This is the agent's normal work -- not part of this skill's protocol.

During work, if you discover issues outside the brief's scope, follow [Issue Capture](#issue-capture) below.

### Step 4: Complete

When work is finished, update the brief file:

1. Change Status to `completed`:

```markdown
| Status | completed |
```

2. Fill the Outcome section with a concise summary of what was accomplished:

```markdown
## Outcome

- Implemented [what was done]
- Files changed: [list key files]
- Tests: [pass/fail status]
- Issues discovered: [count, if any -- details in issues.md]
```

3. If the initiative has an `overview.md`, update the brief's status in the overview table.

4. If you need to hand off to another agent, invoke `/brief-author` to continue the chain.

## Issue Capture

When you discover issues outside the brief's scope during your work:

1. **Append to the issues log** at the path specified in the handoff metadata:

```markdown
### YYYY-MM-DD: [Issue Title]
- **Source**: [NNN-slug](NNN-slug.md)
- **Severity**: critical / important / minor
- **Description**: [what was found]
```

2. **Mention the issue count** in your Outcome section when completing the brief.

Issues must be written to the file, not just mentioned verbally. This is mandatory.

## Evaluation Scenarios

### Scenario 1: Standard Receive and Complete

**Input**: Agent receives prompt with handoff metadata pointing to `docs/briefs/my-feature/002-api-layer.md`.

**Expected behavior**:

- Reads the brief file and initiative context (overview, issues)
- Updates status to `dispatched`
- Does the work described in the brief
- Updates status to `completed`, fills Outcome
- Updates overview table

### Scenario 2: Issue Discovery During Work

**Input**: While executing the brief's task, agent discovers a bug in existing code unrelated to the task.

**Expected behavior**:

- Appends issue to `docs/briefs/my-feature/issues.md`
- Continues with the brief's primary task
- Notes the issue in the Outcome section

### Scenario 3: Chained Handoff

**Input**: Agent completes the brief's task but the feature needs more work.

**Expected behavior**:

- Completes the current brief (status `completed`, Outcome filled)
- Invokes `/brief-author` to create the next brief in the chain
- New brief references current brief as parent
