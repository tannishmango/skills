# Skill Anti-Patterns

Common mistakes that reduce skill effectiveness.

## Contents

- [Deep Nesting](#deep-nesting) - References linking to references, causes partial reads
- [Vague TOC Entries](#vague-toc-entries) - Labels without context, forces speculative reads
- [Over-Explanation](#over-explanation) - Explaining what Claude knows, wastes tokens
- [Vague Descriptions](#vague-descriptions) - No triggers/keywords, breaks discovery
- [Wrong Voice](#wrong-voice-in-description) - First/second person in description field
- [Too Many Options](#too-many-options) - Multiple approaches without guidance
- [Time-Sensitive Content](#time-sensitive-content) - Instructions that become outdated
- [Monolithic SKILL.md](#monolithic-skillmd) - Everything inline, wastes context
- [Scripts That Punt](#scripts-that-punt) - Error handling left to agent
- [Windows Paths](#windows-paths) - Backslashes break Unix systems

---

## Deep Nesting

**Problem**: References that link to files that link to other files.

```markdown
# Bad
SKILL.md → reference.md → details.md → specifics.md
```

**Why it fails**: Agent may partially read nested files, missing critical information.

**Fix**: Flatten to one level.

```markdown
# Good
SKILL.md → reference.md
SKILL.md → details.md
SKILL.md → specifics.md
```

---

## Vague TOC Entries

**Problem**: TOC entries that are just labels.

```markdown
# Bad
## Contents
- Authentication
- Database
- Errors
```

**Why it fails**: Agent cannot determine relevance, must read speculatively.

**Fix**: Self-descriptive entries.

```markdown
# Good
## Contents
- [Authentication](#auth) - OAuth2 flow, JWT tokens, 1-hour expiry
- [Database](#db) - PostgreSQL pooling, migration commands
- [Errors](#errors) - Retry patterns, alert thresholds
```

---

## Over-Explanation

**Problem**: Explaining things Claude already knows.

```markdown
# Bad
PDF (Portable Document Format) is a file format developed by Adobe
that contains text, images, and other content. To extract text from
a PDF, you'll need to use a library. There are many libraries...
```

**Why it fails**: Wastes tokens, clutters context.

**Fix**: Assume knowledge, provide only project-specific details.

```markdown
# Good
Use pdfplumber for extraction:
\`\`\`python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
\`\`\`
```

---

## Vague Descriptions

**Problem**: Description doesn't help with discovery.

```markdown
# Bad
description: Helps with music data stuff.
```

**Why it fails**: No trigger keywords, no specificity, agent can't match to tasks.

**Fix**: Include capabilities, triggers, and keywords.

```markdown
# Good
description: Process royalty reports and sync platform data. Use when handling MLC pipelines, debugging data imports, or when the user mentions ISRCs, ISWCs, or metadata reconciliation.
```

---

## Wrong Voice in Description

**Problem**: First or second person in description.

```markdown
# Bad
description: I can help you process Excel files.
description: You can use this to analyze spreadsheets.
```

**Why it fails**: Description is injected into system prompt; inconsistent voice causes discovery issues.

**Fix**: Third person.

```markdown
# Good
description: Processes Excel files and generates reports.
```

---

## Too Many Options

**Problem**: Presenting multiple approaches without guidance.

```markdown
# Bad
You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image...
```

**Why it fails**: Agent must choose without context, may choose poorly.

**Fix**: Provide a default with escape hatch.

```markdown
# Good
Use pdfplumber for text extraction.

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead.
```

---

## Time-Sensitive Content

**Problem**: Instructions that will become outdated.

```markdown
# Bad
If you're doing this before August 2025, use the old API.
After August 2025, use the new API.
```

**Why it fails**: Creates confusion, wrong instructions over time.

**Fix**: Current method primary, deprecated in collapsible section.

```markdown
# Good
## Current Method
Use v2 API endpoint.

## Deprecated
<details>
<summary>Legacy v1 API (removed 2025-08)</summary>
The v1 endpoint is no longer supported.
</details>
```

---

## Monolithic SKILL.md

**Problem**: Everything in one file.

```markdown
# Bad - 800 line SKILL.md with everything inline
```

**Why it fails**: All content loads on trigger, wastes context window.

**Fix**: Navigation hub with references.

```markdown
# Good - SKILL.md as index
## Quick Start
[Essential 20 lines]

## Reference
- [api.md](api.md) - Endpoint details
- [schemas.md](schemas.md) - Data structures
```

---

## Scripts That Punt

**Problem**: Scripts that fail and expect agent to figure it out.

```python
# Bad
def process_file(path):
    return open(path).read()  # Just fails if file missing
```

**Why it fails**: Agent wastes turns debugging, may not recover.

**Fix**: Handle errors explicitly.

```python
# Good
def process_file(path):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"File {path} not found, creating empty")
        Path(path).touch()
        return ""
```

---

## Windows Paths

**Problem**: Backslashes in file paths.

```markdown
# Bad
See scripts\helper.py
```

**Why it fails**: Breaks on Unix systems.

**Fix**: Always forward slashes.

```markdown
# Good
See scripts/helper.py
```
