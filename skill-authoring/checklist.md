# Skill Quality Checklist

Use this checklist before finalizing or refreshing any skill.

## Contents

- [Structure](#structure) - File layout, TOC requirements, reference depth
- [Discovery Metadata](#discovery-metadata) - Name and description quality gates
- [Content Quality](#content-quality) - Concision, terminology, and examples
- [Evaluation Coverage](#evaluation-coverage) - Baseline and scenario checks
- [Model Coverage](#model-coverage) - Model-tier test validation
- [Runtime And Tooling](#runtime-and-tooling) - Dependencies, MCP names, script intent
- [Validation Safety](#validation-safety) - Plan-validate-execute and intermediate outputs
- [Navigation Quality](#navigation-quality) - Routing clarity and one-level links
- [Observation And Iteration](#observation-and-iteration) - Real-usage improvement loop
- [Quick Verification Commands](#quick-verification-commands) - Fast local checks

---

## Structure

- [ ] SKILL.md body under 500 lines
- [ ] TOC present in any markdown file over 100 lines
- [ ] TOC entries are self-descriptive (not just labels)
- [ ] All references are one level deep from SKILL.md
- [ ] Directory follows clear hierarchy (hub -> reference -> scripts)

## Discovery Metadata

- [ ] Description states WHAT (capabilities)
- [ ] Description states WHEN (trigger scenarios)
- [ ] Description includes searchable keywords
- [ ] Description uses third-person voice
- [ ] Name is lowercase-hyphenated
- [ ] Name is under 64 characters
- [ ] Name does not contain reserved words (`anthropic`, `claude`)

## Content Quality

- [ ] Content only includes knowledge the agent is unlikely to infer reliably
- [ ] No over-explanation of standard concepts
- [ ] Examples are concrete, not abstract
- [ ] Terminology is consistent across all files
- [ ] No time-sensitive language unless clearly in deprecated/legacy context
- [ ] A default approach is provided before alternatives

## Evaluation Coverage

- [ ] Baseline behavior was observed on representative tasks without the skill
- [ ] At least three evaluation scenarios are documented
- [ ] Evaluation scenarios include explicit expected behaviors
- [ ] Evaluation pass/fail criteria are defined
- [ ] Evaluations map to actual user tasks, not only synthetic examples

## Model Coverage

- [ ] Skill was tested against all model tiers expected in real usage
- [ ] Model-specific gaps were documented and addressed
- [ ] Instructions are clear enough for faster models and concise enough for stronger models

## Runtime And Tooling

- [ ] Required dependencies are listed when relevant
- [ ] Installation assumptions are explicit (tools/packages are never assumed)
- [ ] Script usage intent is explicit (`run` vs `read`)
- [ ] MCP tool references use fully qualified names (`ServerName:tool_name`)
- [ ] File paths use forward slashes
- [ ] Script constants are explained (no magic values)

## Validation Safety

- [ ] Validation loop exists for quality-critical workflows (validate -> fix -> revalidate)
- [ ] Plan-validate-execute pattern is used for risky/batch/destructive operations
- [ ] Intermediate artifacts (for example `changes.json`) are verifiable and structured
- [ ] Validation errors are specific enough to guide corrections

## Navigation Quality

- [ ] Task routing is explicit (agent can find the right section quickly)
- [ ] Links include context about destination content
- [ ] Agent can determine relevance from TOC and link text alone
- [ ] No deeply nested reference chains

## Observation And Iteration

- [ ] Real usage was observed after authoring
- [ ] Misses/failures were captured and translated into edits
- [ ] Observe-refine-test loop was run at least once
- [ ] The authoring/testing two-instance loop is reflected where appropriate

---

## Quick Verification Commands

```bash
# Check SKILL.md line count
wc -l SKILL.md

# Check all markdown line counts
wc -l *.md

# Find files that need TOC (>100 lines)
wc -l *.md | awk '$1 > 100 {print $2 " needs TOC"}'

# Find references that may indicate nested paths
rg "\]\(.+/.+\)" *.md
```
