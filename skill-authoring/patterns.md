# Skill Design Patterns

## Contents

- [Directory Structure](#directory-structure) - Three-tier hierarchy, file organization
- [TOC Formats](#toc-formats) - Self-descriptive entries, linking patterns
- [Navigation Trees](#navigation-trees) - Decision routing, conditional workflows
- [Indexed Snippets](#indexed-snippets) - Searchable code blocks with context
- [Checklist Workflows](#checklist-workflows) - Multi-step trackable processes
- [Progressive Disclosure](#progressive-disclosure) - When to inline vs reference
- [Template Pattern](#template-pattern) - Output format templates for consistent results
- [Examples Pattern](#examples-pattern) - Input/output examples for quality-dependent tasks
- [Feedback Loop Pattern](#feedback-loop-pattern) - Validation loops for quality-critical tasks
- [Complete Example](#complete-example) - Full worked skill with all files

---

## Directory Structure

### Three-Tier Hierarchy

```
skill-name/
├── SKILL.md              # Tier 1: Navigation hub (<500 lines)
├── reference/            # Tier 2: Detailed docs
│   ├── api.md
│   ├── schemas.md
│   └── examples.md
└── scripts/              # Tier 3: Executable utilities
    ├── validate.py
    └── generate.py
```

### Flat vs Nested

Prefer flat structure—all reference files directly under skill directory or one `reference/` folder:

```
# Good - flat
skill/
├── SKILL.md
├── patterns.md
├── examples.md
└── scripts/

# Bad - deeply nested
skill/
├── SKILL.md
└── docs/
    └── advanced/
        └── details/
            └── info.md
```

---

## TOC Formats

### Self-Descriptive Entries

Each TOC entry must contain enough context for relevance determination:

```markdown
## Contents

- [Authentication](#authentication) - JWT setup, token refresh, Redis session storage
- [Database Queries](#database-queries) - BigQuery schemas, query optimization, caching
- [Error Handling](#error-handling) - Retry patterns, exponential backoff, alert thresholds
- [Deployment](#deployment) - Docker builds, K8s configs, rollback procedures
```

### Link with Context

When linking to files, include what's inside:

```markdown
## Reference Files

- [api.md](api.md) - REST endpoints, authentication headers, rate limits
- [schemas.md](schemas.md) - Database tables, column types, relationships
- [examples.md](examples.md) - Common queries, edge cases, troubleshooting
```

---

## Navigation Trees

### Decision Router

Guide agents to correct content without forcing reads:

```markdown
## Task Router

**Creating new content?**
→ See [creation.md](creation.md) for templates

**Debugging existing code?**
→ See [debugging.md](debugging.md) for diagnostics

**Deploying changes?**
→ See [deployment.md](deployment.md) for CI/CD
```

### Conditional Workflow

For tasks with branches:

```markdown
## Modification Workflow

1. Determine modification type:

   **Creating new?** → Follow Creation Workflow
   **Editing existing?** → Follow Edit Workflow

2. Creation Workflow:
   - Use template from [templates.md](templates.md)
   - Validate with `python scripts/validate.py`

3. Edit Workflow:
   - Read existing file
   - Apply changes
   - Run validation
```

---

## Indexed Snippets

### With Searchable Context

Provide snippets with enough metadata for discovery:

```markdown
## Common Operations

### Database Connection (PostgreSQL, connection pooling, async)
\`\`\`python
from db import get_pool
async with get_pool().acquire() as conn:
    result = await conn.fetch("SELECT * FROM users")
\`\`\`

### API Authentication (JWT, bearer tokens, refresh)
\`\`\`python
headers = {"Authorization": f"Bearer {get_token()}"}
response = requests.get(url, headers=headers)
\`\`\`

### File Processing (CSV, pandas, chunked reading)
\`\`\`python
for chunk in pd.read_csv("large.csv", chunksize=10000):
    process(chunk)
\`\`\`
```

---

## Checklist Workflows

### Trackable Multi-Step Processes

```markdown
## Deployment Checklist

Copy and track:

\`\`\`
- [ ] Run tests: `pytest tests/`
- [ ] Build container: `docker build -t app .`
- [ ] Push to registry: `docker push`
- [ ] Deploy: `kubectl apply -f k8s/`
- [ ] Verify: `kubectl get pods`
- [ ] Monitor: Check logs for 5 minutes
\`\`\`
```

### With Validation Gates

```markdown
## Release Workflow

\`\`\`
Phase 1: Preparation
- [ ] All tests passing
- [ ] Version bumped
- [ ] Changelog updated

Phase 2: Build (only after Phase 1 complete)
- [ ] Docker image built
- [ ] Image scanned for vulnerabilities

Phase 3: Deploy (only after Phase 2 complete)
- [ ] Staged deployment
- [ ] Smoke tests passing
- [ ] Production deployment
\`\`\`
```

---

## Progressive Disclosure

### When to Inline

Put content directly in SKILL.md when:
- It's essential for most uses of the skill
- It's under 20 lines
- Agents need it immediately without navigation

### When to Reference

Move to separate files when:
- Content exceeds 30 lines
- Only needed for specific sub-tasks
- It's reference material (API docs, schemas)
- It changes independently from core workflow

### Example Split

**SKILL.md** (inline essentials):
```markdown
## Quick Start

Run validation:
\`\`\`bash
python scripts/validate.py input.json
\`\`\`

## Detailed Reference

- For schema definitions, see [schemas.md](schemas.md)
- For error codes, see [errors.md](errors.md)
```

**schemas.md** (detailed reference):
```markdown
# Schema Definitions

## User Schema
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | uuid | yes | Primary key |
| email | string | yes | Unique email |
...
```

---

## Template Pattern

Provide output format templates for consistent results:

```markdown
## Report Structure

Use this template:

\`\`\`markdown
# [Analysis Title]

## Executive Summary
[One-paragraph overview of key findings]

## Key Findings
- Finding 1 with supporting data
- Finding 2 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
\`\`\`
```

---

## Examples Pattern

For skills where output quality depends on seeing examples:

```markdown
## Commit Message Format

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
\`\`\`
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
\`\`\`

**Example 2:**
Input: Fixed bug where dates displayed incorrectly
Output:
\`\`\`
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
\`\`\`
```

---

## Feedback Loop Pattern

For quality-critical tasks, implement validation loops:

```markdown
## Document Editing Process

1. Make your edits
2. **Validate immediately**: `python scripts/validate.py output/`
3. If validation fails:
   - Review the error message
   - Fix the issues
   - Run validation again
4. **Only proceed when validation passes**
```

---

## Complete Example

A full worked example of a well-structured skill.

### Directory Structure

```
code-review/
├── SKILL.md
├── standards.md
└── examples.md
```

### SKILL.md

```markdown
---
name: code-review
description: Review code for quality, security, and maintainability following team standards. Use when reviewing pull requests, examining code changes, or when the user asks for a code review.
---

# Code Review

## Contents

- [Quick Start](#quick-start) - Core review process
- [Review Checklist](#review-checklist) - Items to verify
- [Feedback Format](#feedback-format) - How to structure comments
- [Reference Files](#reference-files) - Detailed standards and examples

## Quick Start

When reviewing code:

1. Check for correctness and potential bugs
2. Verify security best practices
3. Assess code readability and maintainability
4. Ensure tests are adequate

## Review Checklist

- [ ] Logic is correct and handles edge cases
- [ ] No security vulnerabilities (SQL injection, XSS, etc.)
- [ ] Code follows project style conventions
- [ ] Functions are appropriately sized and focused
- [ ] Error handling is comprehensive
- [ ] Tests cover the changes

## Feedback Format

Format feedback as:
- 🔴 **Critical**: Must fix before merge
- 🟡 **Suggestion**: Consider improving
- 🟢 **Nice to have**: Optional enhancement

## Reference Files

- [standards.md](standards.md) - Detailed coding standards, security requirements
- [examples.md](examples.md) - Example reviews showing good feedback patterns
```

### standards.md

```markdown
# Coding Standards

## Contents

- [Security](#security) - SQL injection, XSS, auth patterns
- [Performance](#performance) - Query optimization, caching
- [Style](#style) - Naming, formatting, organization

---

## Security

### SQL Injection Prevention
Always use parameterized queries:
\`\`\`python
# Good
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))

# Bad
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")
\`\`\`

### XSS Prevention
Escape all user input in templates. Use framework-provided escaping.

---

## Performance

### Query Optimization
- Add indexes for frequently queried columns
- Avoid N+1 queries—use JOINs or batch loading
- Paginate large result sets

---

## Style

### Naming
- Functions: verb_noun (get_user, create_order)
- Classes: PascalCase (UserService, OrderProcessor)
- Constants: UPPER_SNAKE (MAX_RETRIES, API_TIMEOUT)
```

### examples.md

```markdown
# Review Examples

## Example 1: Security Issue

**Code:**
\`\`\`python
def get_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return db.execute(query)
\`\`\`

**Feedback:**
🔴 **Critical**: SQL injection vulnerability. User input is interpolated directly into query string.

**Fix:**
\`\`\`python
def get_user(user_id):
    return db.execute("SELECT * FROM users WHERE id = %s", (user_id,))
\`\`\`

---

## Example 2: Suggestion

**Code:**
\`\`\`python
def process_items(items):
    results = []
    for item in items:
        result = transform(item)
        results.append(result)
    return results
\`\`\`

**Feedback:**
🟡 **Suggestion**: Consider using list comprehension for cleaner code:
\`\`\`python
def process_items(items):
    return [transform(item) for item in items]
\`\`\`
```
