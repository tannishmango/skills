# Skill Design Patterns

## Contents

- [Directory Structure](#directory-structure) - Three-tier hierarchy and one-level references
- [TOC Formats](#toc-formats) - Self-descriptive entries and contextual links
- [Navigation Trees](#navigation-trees) - Decision routing and conditional workflows
- [Evaluation Scenario Pattern](#evaluation-scenario-pattern) - Baseline and JSON scenario templates
- [Model Coverage Pattern](#model-coverage-pattern) - Cross-model test matrix format
- [Observation Loop Pattern](#observation-loop-pattern) - Observe-refine-test workflow with log template
- [Plan-Validate-Execute Pattern](#plan-validate-execute-pattern) - Safe execution for risky or batch operations
- [Runtime And Dependency Pattern](#runtime-and-dependency-pattern) - Declare tooling assumptions and setup
- [MCP Tool Reference Pattern](#mcp-tool-reference-pattern) - Fully qualified tool naming
- [Script Intent Pattern](#script-intent-pattern) - Explicit execute-vs-read instructions
- [Visual Analysis Pattern](#visual-analysis-pattern) - When and how to use image-based analysis
- [Template Pattern](#template-pattern) - Output-format templates
- [Examples Pattern](#examples-pattern) - Input/output style guidance
- [Checklist Workflow Pattern](#checklist-workflow-pattern) - Trackable multi-step execution
- [Progressive Disclosure Pattern](#progressive-disclosure-pattern) - What to keep inline vs referenced
- [Authoring-Testing Loop Pattern](#authoring-testing-loop-pattern) - Two-instance refinement cycle
- [Complete Example](#complete-example) - End-to-end skill skeleton

---

## Directory Structure

### Three-Tier Hierarchy

```text
skill-name/
├── SKILL.md              # Tier 1: Navigation hub (<500 lines)
├── references/            # Tier 2: Detailed docs (read on demand)
│   ├── workflows.md
│   ├── api.md
│   └── examples.md
└── scripts/              # Tier 3: Utilities (executed or read)
    ├── validate.py
    └── transform.py
```

### Flat vs Nested

```text
# Good
skill/
├── SKILL.md
├── references/
│   ├── api.md
│   └── workflows.md
└── scripts/

# Bad
skill/
├── SKILL.md
└── docs/
    └── advanced/
        └── internals/
            └── details.md
```

---

## TOC Formats

### Self-Descriptive Entries

```markdown
## Contents

- [Authentication](#authentication) - OAuth flow, token refresh, session storage
- [Database Queries](#database-queries) - Query templates, index hints, pagination
- [Validation](#validation) - Schema checks, error patterns, retry strategy
```

### Link With Context

```markdown
## References

- [references/workflows.md](references/workflows.md) - End-to-end operational flows
- [references/api.md](references/api.md) - Endpoint definitions and constraints
- [references/examples.md](references/examples.md) - Real input/output examples
```

---

## Navigation Trees

### Decision Router

```markdown
## Task Router

**Creating a new artifact?**
→ See [references/workflows.md](references/workflows.md) - Creation workflow and templates

**Updating existing artifacts?**
→ See [references/workflows.md](references/workflows.md) - Edit and validation loop

**Troubleshooting failures?**
→ See [references/api.md](references/api.md) - Error signatures and remedies
```

### Conditional Workflow

```markdown
## Modification Workflow

1. Determine mode:
   - **Create** -> Creation path
   - **Edit** -> Edit path

2. Creation path:
   - Build draft from template
   - Validate draft

3. Edit path:
   - Read current state
   - Apply change
   - Revalidate
```

---

## Evaluation Scenario Pattern

Create evaluations before writing extensive docs.

### Baseline Steps

```markdown
1. Run 2-5 representative tasks without the skill.
2. Record concrete misses (missing rule, wrong tool, wrong format, etc.).
3. Convert misses into evaluation scenarios.
```

### Scenario Template

```json
{
  "skills": ["skill-name"],
  "query": "Perform task X with constraints Y",
  "files": ["optional/input.file"],
  "expected_behavior": [
    "Behavior 1 must happen",
    "Behavior 2 must happen",
    "Behavior 3 must happen"
  ]
}
```

### Minimum Coverage Rule

```markdown
- At least 3 scenarios
- Include one edge case
- Include one failure recovery case
```

---

## Model Coverage Pattern

Use a small matrix to ensure coverage across model tiers used by your team.

```markdown
## Model Test Matrix

| Model tier          | Scenario set | Pass rate | Notes                       |
| ------------------- | ------------ | --------- | --------------------------- |
| Fast tier           | 1, 2, 3      | 2/3       | Missed strict output format |
| Balanced tier       | 1, 2, 3      | 3/3       | Pass                        |
| High-reasoning tier | 1, 2, 3      | 3/3       | Pass                        |
```

If one tier fails consistently, adjust instructions for clarity and rerun.

---

## Observation Loop Pattern

Track real usage and update the skill from evidence.

```markdown
## Observe-Refine-Test Log

### Observation

- Task: User asked for weekly report generation
- Miss: Agent skipped required validation step

### Refinement

- Added explicit "validate before publish" gate in workflow section

### Retest

- Re-ran scenarios 2 and 3
- Result: Pass
```

Use this loop continuously, not just once at initial authoring.

---

## Plan-Validate-Execute Pattern

Use this for risky, destructive, or large batch operations.

```markdown
## Batch Update Workflow

1. Plan:
   - Build `changes.json` with proposed updates

2. Validate:
   - Run `python scripts/validate_changes.py changes.json`
   - Fix errors until validation passes

3. Execute:
   - Run `python scripts/apply_changes.py changes.json`

4. Verify:
   - Run post-checks
   - If failed, return to plan step
```

Prefer deterministic validation output with actionable error messages.

---

## Runtime And Dependency Pattern

State assumptions explicitly so runtime behavior is predictable.

````markdown
## Runtime Requirements

- Python 3.11+
- Packages:
  - `pydantic`
  - `httpx`

Install:

```bash
pip install pydantic httpx
```

Do not assume these packages are available unless installed in the current environment.
````

Use concrete package names and direct install instructions.

---

## MCP Tool Reference Pattern

Always use fully qualified names.

```markdown
Use `GitHub:create_issue` to open issues.
Use `BigQuery:bigquery_schema` to fetch schema metadata.
```

Avoid unqualified references like `create_issue` without server prefix.

---

## Script Intent Pattern

Explicitly state whether scripts should be executed or read.

```markdown
## Script Usage

- Execute: `python scripts/validate.py output.json`
- Read-only reference: `scripts/validate.py` explains validation rules
```

If both are needed, specify order and purpose.

---

## Visual Analysis Pattern

Use this when layout or spatial relationships matter.

```markdown
## Visual Layout Workflow

1. Convert source to images:
   `python scripts/render_pages.py input.pdf output_pages/`
2. Analyze rendered images for field positions and visual anomalies.
3. Generate structured mapping output.
4. Validate mapping before apply step.
```

Use visual analysis when text-only parsing is unreliable.

---

## Template Pattern

Use strict templates when output format must be exact.

````markdown
## Output Template

ALWAYS use:

```markdown
# [Title]

## Summary

[One paragraph]

## Findings

- Finding with evidence

## Actions

1. Action item
```
````

For flexible tasks, present the template as a default, not a hard requirement.

---

## Examples Pattern

Provide input/output pairs when style quality matters.

````markdown
## Commit Message Examples

Input: Add retry logic to API client
Output:

```
fix(api): add retry logic for transient failures

Retry on timeout and 5xx responses with capped exponential backoff
```
````

Include multiple examples that differ in scope and intent.

---

## Checklist Workflow Pattern

Track progress explicitly for complex tasks.

```markdown
## Release Checklist

- [ ] Run tests
- [ ] Validate outputs
- [ ] Build artifact
- [ ] Deploy
- [ ] Verify post-deploy behavior
```

Add gate conditions when one phase must finish before the next starts.

---

## Progressive Disclosure Pattern

### Keep Inline In SKILL.md

- High-frequency steps
- Critical safety rules
- Short sections (typically under ~20 lines)

### Move To Reference Files

- Long schemas
- Large examples
- Task-specific subflows
- Materials not needed on every invocation

### Example Split

```markdown
# SKILL.md

## Quick Start

Run `python scripts/validate.py input.json`

## Detailed References

- [references/errors.md](references/errors.md) - Error catalog and remediations
```

---

## Authoring-Testing Loop Pattern

Use a two-instance approach to reduce blind spots.

```markdown
## Iteration Loop

1. Authoring instance drafts/updates skill instructions.
2. Testing instance performs real tasks using the skill.
3. Capture misses in a short log.
4. Feed misses back into authoring instance.
5. Re-test and repeat until stable.
```

This pattern keeps improvements grounded in observed behavior.

---

## Complete Example

```text
reporting-skill/
├── SKILL.md
├── references/
│   ├── workflows.md
│   ├── schemas.md
│   └── examples.md
└── scripts/
    ├── validate_report.py
    └── generate_report.py
```

```markdown
---
name: generating-reports
description: Generates validated operational reports with consistent structure. Use when creating weekly or monthly reports or when the user requests report synthesis from structured data.
---

# Report Generation

## Contents

- [Quick Start](#quick-start) - Generate and validate report
- [Task Router](#task-router) - Choose workflow by task type
- [References](#references) - Deep docs and schema details

## Quick Start

1. Build draft report
2. Validate using `python scripts/validate_report.py report.json`
3. Revise until validation passes

## Task Router

**Need schema details?** -> [references/schemas.md](references/schemas.md) - Source fields and types
**Need edge-case examples?** -> [references/examples.md](references/examples.md) - Failure and recovery examples

## References

- [references/workflows.md](references/workflows.md) - End-to-end generation flows
```
