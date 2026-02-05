---
name: skill-authoring
description: Design and create effective Agent Skills following progressive disclosure principles. Use when creating skills, writing SKILL.md files, designing skill architecture, or when the user asks about skill best practices, TOC requirements, or context optimization.
---

# Skill Authoring

## Contents

- [Mental Model](#mental-model) - How skills load, three-tier architecture
- [Quick Reference](#quick-reference) - Constraints, limits, storage locations
- [Task Router](#task-router) - Navigate to correct reference by task type
- [Before You Begin](#before-you-begin) - Requirements gathering checklist
- [Workflow](#workflow) - Step-by-step skill creation process
- [Description Requirements](#description-requirements) - Discovery field formatting
- [TOC Requirements](#toc-requirements) - When and how to add table of contents
- [Reference Files](#reference-files) - Links to detailed patterns, checklist, anti-patterns

---

Skills are **selective-load information architectures**—agent-queryable knowledge bases that minimize context window usage through progressive disclosure.

## Mental Model

```
Startup:     All skill metadata (name/description) pre-loaded
Trigger:     SKILL.md loads on-demand
Navigation:  Reference files load only when explicitly read
Execution:   Scripts run without loading source code
```

Design skills as search databases with intelligent entry points, not as documentation.

## Quick Reference

| Constraint | Limit |
|------------|-------|
| SKILL.md | <500 lines |
| TOC required | Any file >100 lines |
| Reference depth | 1 level from SKILL.md |
| Name format | lowercase-hyphenated, <64 chars |
| Description | <1024 chars, third-person |

### Storage Locations

| Type | Path | Scope |
|------|------|-------|
| Personal | `~/.cursor/skills/skill-name/` | Available across all your projects |
| Project | `.cursor/skills/skill-name/` | Shared with anyone using the repository |

**IMPORTANT**: Never create skills in `~/.cursor/skills-cursor/`. This directory is reserved for Cursor's internal built-in skills.

## Task Router

**Creating a new skill?**
→ Start with [Before You Begin](#before-you-begin), then follow [Workflow](#workflow)

**Reviewing/improving a skill?**
→ Use [checklist.md](checklist.md) for quality verification

**Debugging skill discovery issues?**
→ Check description field—see [Description Requirements](#description-requirements)

**Looking for structure patterns or examples?**
→ See [patterns.md](patterns.md) for templates and complete examples

**Avoiding common mistakes?**
→ See [anti-patterns.md](anti-patterns.md)

---

## Before You Begin

Gather these requirements before creating a skill:

### Essential Questions

1. **Purpose**: What specific task or workflow should this skill enable?
2. **Knowledge gap**: What domain knowledge does the agent lack that this provides?
3. **Storage**: Personal (`~/.cursor/skills/`) or project (`.cursor/skills/`)?
4. **Triggers**: When should the agent automatically apply this skill?
5. **Output format**: Are there specific templates, formats, or styles required?

### Inferring from Context

If you have conversation context, infer the skill from what was discussed—workflows, patterns, or domain knowledge that emerged naturally.

### Gathering Information

Use the AskQuestion tool when available for efficient structured gathering:

```
Example questions:
- "Where should this skill be stored?" → ["Personal (~/.cursor/skills/)", "Project (.cursor/skills/)"]
- "Should this skill include executable scripts?" → ["Yes", "No"]
- "What's the primary trigger scenario?" → [open-ended or specific options]
```

If AskQuestion is unavailable, ask conversationally.

---

## Workflow

### 1. Gather Requirements
Complete [Before You Begin](#before-you-begin) checklist.

### 2. Design Structure

```
skill-name/
├── SKILL.md           # Navigation + essentials (<500 lines)
├── reference/         # Detailed docs (loaded on-demand)
│   └── *.md
└── scripts/           # Utilities (executed, not loaded)
    └── *.py
```

### 3. Write Description

Template:

```yaml
description: [Capabilities]. Use when [triggers] or when the user mentions [keywords].
```

### 4. Create SKILL.md

- Navigation hub with decision trees
- Essential workflows inline (under 20 lines each)
- Links to reference files with context
- TOC if exceeding 100 lines

### 5. Create Supporting Files

- Reference files for detailed content (>30 lines)
- Utility scripts for repeatable operations
- Examples file if output quality depends on seeing examples

### 6. Verify Quality

Run through [checklist.md](checklist.md).

---

## Description Requirements

The description is the **only** thing agents see before loading. It must:

1. **State capabilities** (what it does)
2. **State triggers** (when to use)
3. **Include keywords** (searchable terms)
4. **Use third person** (injected into system prompt)

```yaml
# Good
description: Process royalty reports and sync platform data. Use when handling MLC pipelines, debugging data imports, or when the user mentions ISRCs, ISWCs, or metadata reconciliation.

# Bad
description: Helps with music data stuff.
```

### More Examples

```yaml
# Git commit helper
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.

# Code review
description: Review code for quality, security, and best practices following team standards. Use when reviewing pull requests, code changes, or when the user asks for a code review.

# PDF processing
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

---

## TOC Requirements

Any file >100 lines needs a TOC where entries are **self-descriptive**:

```markdown
## Contents
- [Authentication](#auth) - OAuth2 with Google, Redis token storage, 1-hour expiry
- [Database](#db) - PostgreSQL pooling, migrations, backup procedures
```

NOT just labels:
```markdown
## Contents
- Authentication
- Database
```

The agent must determine relevance from the TOC entry alone.

---

## Reference Files

- [patterns.md](patterns.md) - Structure patterns, TOC formats, navigation trees, complete examples
- [checklist.md](checklist.md) - Pre-submission quality verification
- [anti-patterns.md](anti-patterns.md) - Common mistakes and how to avoid them
