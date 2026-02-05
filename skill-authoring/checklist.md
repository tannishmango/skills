# Skill Quality Checklist

Use this checklist before finalizing any skill.

---

## Structure

- [ ] SKILL.md under 500 lines
- [ ] TOC present in any file exceeding 100 lines
- [ ] TOC entries are self-descriptive (not just labels)
- [ ] All references one level deep from SKILL.md
- [ ] Directory follows three-tier hierarchy (SKILL.md → reference → scripts)

## Discovery

- [ ] Description states WHAT (capabilities)
- [ ] Description states WHEN (triggers)
- [ ] Description includes searchable keywords
- [ ] Description is third-person voice
- [ ] Name is lowercase-hyphenated
- [ ] Name under 64 characters
- [ ] No reserved words in name (anthropic, claude)

## Content

- [ ] Only includes knowledge Claude lacks
- [ ] No over-explanation of standard concepts
- [ ] Concrete examples provided (not abstract)
- [ ] Consistent terminology throughout
- [ ] No time-sensitive information (or in deprecated section)

## Navigation

- [ ] Decision trees guide to correct content
- [ ] Links include context about destination
- [ ] Agent can determine relevance from TOC/links alone
- [ ] No deeply nested references

## Scripts (if applicable)

- [ ] Scripts solve problems (don't punt to agent)
- [ ] Error handling is explicit and helpful
- [ ] Required packages documented
- [ ] No magic constants (all values justified)
- [ ] Forward slashes in all paths (no Windows backslashes)

---

## Quick Verification Commands

```bash
# Check SKILL.md line count
wc -l SKILL.md

# Check all file line counts
wc -l *.md

# Find files needing TOC (>100 lines)
wc -l *.md | awk '$1 > 100 {print $2 " needs TOC"}'

# Verify no deeply nested references
grep -r "](.*/" *.md | grep -v "scripts/"
```
