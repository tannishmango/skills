# Skill Anti-Patterns

Common mistakes that reduce skill reliability, discoverability, or execution quality.

## Contents

- [Deep Nesting](#deep-nesting) - Reference chains deeper than one level
- [Vague TOC Entries](#vague-toc-entries) - Labels without context
- [Over-Explanation](#over-explanation) - Repeating knowledge the model already has
- [Vague Descriptions](#vague-descriptions) - Missing capabilities, triggers, and keywords
- [Wrong Voice In Description](#wrong-voice-in-description) - First/second person discovery text
- [Too Many Options](#too-many-options) - Multiple defaults with no guidance
- [Time-Sensitive Content](#time-sensitive-content) - Instructions that decay over time
- [Monolithic SKILL.md](#monolithic-skillmd) - Oversized hub with all details inline
- [No Evaluations](#no-evaluations) - No baseline or test scenarios
- [No Model Coverage](#no-model-coverage) - Skill only tested on one model tier
- [No Observation Loop](#no-observation-loop) - No real-usage feedback cycle
- [Unqualified MCP Tools](#unqualified-mcp-tools) - Missing `ServerName:tool_name`
- [Dependency Assumptions](#dependency-assumptions) - Assuming tools/packages are installed
- [Missing Validation Checkpoints](#missing-validation-checkpoints) - No plan-validate-execute gates
- [Ambiguous Script Intent](#ambiguous-script-intent) - Unclear whether to run or read scripts
- [Scripts That Punt](#scripts-that-punt) - Error handling deferred to the agent
- [Windows Paths](#windows-paths) - Backslashes in cross-platform skill docs

---

## Deep Nesting

**Problem**: SKILL.md links to references that link to deeper references.

```markdown
# Bad

SKILL.md -> reference.md -> details.md -> specifics.md
```

**Why it fails**: The agent may only partially inspect nested files and miss critical content.

**Fix**: Keep links one level deep from SKILL.md.

```markdown
# Good

SKILL.md -> reference.md
SKILL.md -> details.md
SKILL.md -> specifics.md
```

---

## Vague TOC Entries

**Problem**: TOC entries are only section names.

```markdown
# Bad

## Contents

- Authentication
- Database
```

**Why it fails**: The agent cannot decide relevance without speculative reads.

**Fix**: Use self-descriptive TOC entries.

```markdown
# Good

## Contents

- [Authentication](#authentication) - OAuth flow, token refresh, session storage
- [Database](#database) - Query templates, index hints, pagination
```

---

## Over-Explanation

**Problem**: Explaining standard concepts instead of task-critical specifics.

```markdown
# Bad

PDF files are a common format. To extract text, you need a library...
```

**Why it fails**: Wastes context and hides the actionable guidance.

**Fix**: Assume baseline knowledge and provide concrete instructions.

````markdown
# Good

Use pdfplumber:

```python
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

---

## Vague Descriptions

**Problem**: Description is too broad for discovery.

```yaml
# Bad
description: Helps with data work.
```

**Why it fails**: The skill is not discoverable for specific requests.

**Fix**: Include capabilities, triggers, and keywords.

```yaml
# Good
description: Generates validated weekly operational reports. Use when creating recurring reports or when the user mentions report synthesis, KPI summaries, or weekly status dashboards.
```

---

## Wrong Voice In Description

**Problem**: First or second person in frontmatter description.

```yaml
# Bad
description: I help you process spreadsheets.
description: You can use this for analytics.
```

**Why it fails**: Discovery text is injected into system context; voice inconsistency harms matching.

**Fix**: Use third-person phrasing.

```yaml
# Good
description: Processes spreadsheets and generates analytical summaries.
```

---

## Too Many Options

**Problem**: Presenting several equivalent approaches without default guidance.

```markdown
# Bad

You can use pypdf, pdfplumber, PyMuPDF, or custom OCR...
```

**Why it fails**: Increases decision noise and inconsistent behavior.

**Fix**: Provide one default path and one explicit fallback.

```markdown
# Good

Use pdfplumber for text extraction.
For scanned PDFs, use OCR with pytesseract.
```

---

## Time-Sensitive Content

**Problem**: Instructions tied to date windows that later become incorrect.

```markdown
# Bad

Before August 2025 use API v1, after August 2025 use API v2.
```

**Why it fails**: Old text survives and creates contradictory behavior.

**Fix**: Keep one current method and move legacy behavior to a deprecated section.

---

## Monolithic SKILL.md

**Problem**: Putting all details in SKILL.md.

```markdown
# Bad

SKILL.md with 800+ lines and no references
```

**Why it fails**: Bloats context whenever the skill triggers.

**Fix**: Keep SKILL.md as a concise router and move details to references.

---

## No Evaluations

**Problem**: Authoring docs without baseline or explicit scenario tests.

```markdown
# Bad

No baseline tasks
No evaluation scenarios
```

**Why it fails**: Improvements are unmeasured and regressions go unnoticed.

**Fix**:

- Run representative tasks without the skill.
- Define at least three evaluation scenarios.
- Add expected behavior for each scenario.

---

## No Model Coverage

**Problem**: Testing the skill on only one model tier.

```markdown
# Bad

Validated only on one high-capability model.
```

**Why it fails**: Instructions may fail on faster tiers or be overly verbose on stronger tiers.

**Fix**: Test across all model tiers used in production workflows.

---

## No Observation Loop

**Problem**: No post-launch observation and refinement cycle.

```markdown
# Bad

Skill written once and never tested on real usage.
```

**Why it fails**: Real-world misses remain unresolved.

**Fix**: Run an observe-refine-test loop and log misses with corresponding edits.

---

## Unqualified MCP Tools

**Problem**: MCP tools are referenced without server prefix.

```markdown
# Bad

Use `create_issue`
```

**Why it fails**: Tool resolution fails or becomes ambiguous.

**Fix**: Use `ServerName:tool_name`.

```markdown
# Good

Use `GitHub:create_issue`
```

---

## Dependency Assumptions

**Problem**: Skill assumes packages or CLIs already exist.

```markdown
# Bad

Run `python process.py` (without listing dependencies)
```

**Why it fails**: Runtime errors and inconsistent behavior across environments.

**Fix**: Declare runtime requirements and installation steps explicitly.

---

## Missing Validation Checkpoints

**Problem**: Directly applying changes without validating intermediate artifacts.

```markdown
# Bad

Generate updates and apply immediately.
```

**Why it fails**: Errors propagate into destructive or large-scale operations.

**Fix**: Use plan-validate-execute.

```markdown
# Good

1. Create `changes.json`
2. Validate `changes.json`
3. Apply only if validation passes
4. Verify output
```

---

## Ambiguous Script Intent

**Problem**: Script references do not specify execute vs read.

```markdown
# Bad

See `scripts/validate.py`
```

**Why it fails**: The agent may read when it should execute, or execute when reference was intended.

**Fix**: Explicit intent wording.

```markdown
# Good

Execute: `python scripts/validate.py report.json`
Read-only reference: `scripts/validate.py` documents rule definitions
```

---

## Scripts That Punt

**Problem**: Scripts fail and leave recovery to the agent.

```python
# Bad
def process(path):
    return open(path).read()
```

**Why it fails**: Error handling becomes inconsistent and brittle.

**Fix**: Handle expected failures with clear recovery behavior.

---

## Windows Paths

**Problem**: Backslashes in file references.

```markdown
# Bad

See scripts\validate.py
```

**Why it fails**: Breaks on Unix environments and reduces portability.

**Fix**: Use forward slashes universally.

```markdown
# Good

See scripts/validate.py
```
