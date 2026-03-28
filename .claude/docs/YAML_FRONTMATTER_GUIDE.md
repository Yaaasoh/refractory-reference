# YAML Frontmatter Best Practices

**Version**: 1.0
**Last Updated**: 2025-12-27
**Source**: Phase 3 Step 4 research + ComposioHQ/awesome-claude-skills

---

## Purpose

This guide provides comprehensive best practices for writing **YAML frontmatter** in Claude Code Skills. Proper frontmatter is critical for Progressive Disclosure efficiency.

**Target Audience**: Skill creators, Claude Code customization engineers

**Key Goals**:
- **Concise**: ~100 tokens (150 max)
- **Informative**: Clear what/when/why
- **Structured**: Consistent format

---

## YAML Frontmatter Structure

### Minimal Required Format

```yaml
---
name: skill-name
description: [What this skill does], [When to use it], [Optional: what it prevents]
---
```

**Required Fields**:
- `name`: Skill identifier (kebab-case)
- `description`: Concise skill summary (~40-80 tokens)

---

### Full Format (Recommended)

```yaml
---
name: skill-name
description: [What this skill does], [When to use it], [Optional: what it prevents]
version: 1.0
author: Your Name or Organization
tags: [category1, category2, category3]
triggers: [condition1, condition2, condition3]
prevents: [FP-X, FP-Y, FP-Z]
---
```

**Optional Fields**:
- `version`: Semantic versioning (e.g., "1.0", "2.1.3")
- `author`: Creator name or organization
- `tags`: Categorization keywords (3-5 recommended)
- `triggers`: Conditions when skill should activate (3-5 recommended)
- `prevents`: Failure Pattern references (if applicable)

---

## Field-by-Field Guide

### 1. name

**Purpose**: Unique identifier for the skill
**Format**: kebab-case (lowercase, hyphen-separated)
**Length**: 2-4 words

**Good Examples**:
```yaml
name: test-driven-development
name: code-quality-enforcer
name: deployment-verifier
name: root-cause-analyzer
```

**Bad Examples**:
```yaml
name: TestDrivenDevelopment  # ❌ Not kebab-case
name: tdd                    # ❌ Too cryptic
name: test_driven_dev        # ❌ Use hyphens, not underscores
name: comprehensive-test-driven-development-workflow-enforcer  # ❌ Too long
```

**Rules**:
- ✅ Use kebab-case
- ✅ Be descriptive but concise
- ✅ 2-4 words max
- ❌ No camelCase or snake_case
- ❌ No abbreviations unless widely known
- ❌ No spaces

---

### 2. description

**Purpose**: Quick summary of what, when, and why
**Format**: 1-3 sentences, formula-driven
**Length**: ~40-80 tokens (150 max)

**Formula**:
```
[Action verb] + [core functionality] + when + [trigger condition] + Prevents + [failure patterns (if applicable)]
```

**Examples by Skill Type**:

**Quality Enforcement Skill**:
```yaml
description: Enforce test quality and prevent implementation shortcuts when writing or modifying code. Use when implementing features, fixing bugs, or refactoring code. Prevents test tampering (FP-1) and implementation shortcuts (FP-2).
```

**Workflow Skill**:
```yaml
description: Transform rough ideas into fully-formed designs through structured questioning and alternative exploration. Use when planning new features or projects. Guides through 3-phase process: Understanding, Exploration, Design.
```

**Verification Skill**:
```yaml
description: Ensure proper deployment verification at 4 stages (pre-deploy, during deploy, post-deploy, definition of done). Use when deploying to any environment. Prevents deployment verification neglect (FP-9).
```

**Analysis Skill**:
```yaml
description: Deep investigation using 5 Whys methodology before implementing fixes. Use when encountering bugs or errors. Prevents superficial root cause analysis (FP-5) and speculation-based implementation (FP-8).
```

---

**Description Structure Breakdown**:

**Part 1: What** (Core Functionality)
```
Enforce test quality and prevent implementation shortcuts
```
- Action verb: "Enforce"
- Core function: "test quality" and "prevent implementation shortcuts"
- Be specific about primary value

**Part 2: When** (Trigger Condition)
```
when writing or modifying code. Use when implementing features, fixing bugs, or refactoring code.
```
- Specific scenarios where skill applies
- Helps with auto-activation patterns
- 2-3 concrete examples

**Part 3: Why/Prevents** (Optional but Recommended)
```
Prevents test tampering (FP-1) and implementation shortcuts (FP-2).
```
- Reference Failure Patterns (if applicable)
- Explain benefit/value
- Links to defense system

---

**Good Description Examples**:

**Example 1** (purpose-driven-impl):
```yaml
description: Ensure clear purpose before implementation using 5W1H framework (Who, What, When, Where, Why, How). Use when starting new features or projects. Prevents purpose ambiguity (FP-3).
```

**Tokens**: ~35
**Analysis**: Concise, clear what/when/why, mentions framework, references FP

---

**Example 2** (verification-enforcer):
```yaml
description: Comprehensive verification at 4 levels (smoke tests, edge cases, error handling, stress tests). Use when testing features or deployments. Prevents verification insufficiency (FP-6, FP-10).
```

**Tokens**: ~32
**Analysis**: Mentions 4 levels (concrete), clear usage, prevents 2 FPs

---

**Example 3** (brainstorming - obra/superpowers):
```yaml
description: Transform rough ideas into fully-formed designs through structured questioning and alternative exploration
```

**Tokens**: ~16
**Analysis**: Simple, no trigger/prevents but still clear. Minimalist style works if name is descriptive.

---

**Bad Description Examples**:

**Example 1** (Too Vague):
```yaml
description: A skill for code quality.
```
**Problems**:
- ❌ Too vague ("for code quality" - what specifically?)
- ❌ No trigger condition
- ❌ No failure pattern reference
- ❌ Doesn't explain "when" to use

---

**Example 2** (Too Long):
```yaml
description: This is a comprehensive skill designed to help you enforce test quality by preventing test tampering and implementation shortcuts. It works by providing detailed guidance throughout the implementation process, from writing tests first (following TDD principles) to ensuring that tests are not weakened to pass. The skill is particularly useful when you are implementing new features, fixing bugs, or refactoring code, as these are common scenarios where shortcuts might be tempting. By using this skill, you can prevent Failure Patterns FP-1 (test tampering) and FP-2 (implementation shortcuts), which are documented in our failure patterns catalog. The skill includes workflow steps, best practices, examples, and verification checklists to ensure comprehensive quality enforcement.
```
**Tokens**: ~150+
**Problems**:
- ❌ Way too long (~150 tokens, should be ~40-80)
- ❌ Verbose, repetitive
- ❌ Belongs in SKILL.md body, not frontmatter
- ❌ Defeats Progressive Disclosure purpose

---

**Example 3** (No Context):
```yaml
description: TDD enforcement
```
**Problems**:
- ❌ Too terse
- ❌ No trigger condition
- ❌ No explanation of value
- ❌ Cryptic abbreviation (TDD)

---

### 3. version

**Purpose**: Track skill revisions
**Format**: Semantic versioning (MAJOR.MINOR.PATCH)
**Length**: 3-10 characters

**Examples**:
```yaml
version: 1.0        # Initial release
version: 1.1        # Minor update (new features, backward compatible)
version: 2.0        # Major update (breaking changes)
version: 1.2.3      # Patch update
```

**When to Increment**:
- **MAJOR**: Breaking changes (workflow restructure, incompatible updates)
- **MINOR**: New features (added sections, new examples)
- **PATCH**: Bug fixes (typos, clarifications, small improvements)

---

### 4. author

**Purpose**: Attribution
**Format**: Name or organization
**Length**: 10-30 characters

**Examples**:
```yaml
author: obra/superpowers
author: Claude Code Research Project
author: John Doe
author: READYFOR Engineering Team
```

---

### 5. tags

**Purpose**: Categorization and searchability
**Format**: Array of lowercase keywords
**Recommended**: 3-5 tags

**Tag Categories**:

**By Domain**:
```yaml
tags: [quality, testing, tdd]           # Development
tags: [deployment, devops, ci-cd]       # Operations
tags: [analysis, debugging, investigation]  # Troubleshooting
tags: [design, architecture, planning]  # Design
tags: [documentation, writing]          # Documentation
```

**By Technology**:
```yaml
tags: [python, testing, pytest]
tags: [javascript, react, frontend]
tags: [docker, kubernetes, cloud]
```

**By Use Case**:
```yaml
tags: [bugfix, error-handling]
tags: [feature-development, implementation]
tags: [refactoring, code-quality]
```

**Good Examples**:
```yaml
tags: [quality, testing, tdd]
tags: [deployment, verification, devops]
tags: [purpose, planning, requirements]
tags: [investigation, debugging, root-cause]
```

**Bad Examples**:
```yaml
tags: []  # ❌ Empty, not useful
tags: [a, b, c, d, e, f, g, h, i, j]  # ❌ Too many, unfocused
tags: [Quality Testing TDD Enforcement]  # ❌ Should be array, not single string
tags: [TEST, QA, VERIFY]  # ❌ Uppercase, inconsistent
```

---

### 6. triggers

**Purpose**: Auto-activation conditions (for hooks)
**Format**: Array of lowercase keywords/phrases
**Recommended**: 3-5 triggers

**Trigger Types**:

**By Task Type**:
```yaml
triggers: [implementation, bugfix, refactoring]
triggers: [deploy, deployment, install]
triggers: [new feature, create, add]
```

**By Keywords in Prompt**:
```yaml
triggers: [error, bug, problem, failure]
triggers: [test, verify, check]
triggers: [deploy, publish, release]
```

**By File Type**:
```yaml
triggers: [*.test.js, *.spec.ts, test/**]
triggers: [Dockerfile, docker-compose.yml]
```

**Good Examples**:
```yaml
triggers: [implementation, bugfix, feature-development]
triggers: [deploy, deployment, install, publish]
triggers: [error, bug, problem, failure, not working]
triggers: [new, create, add, initialize]
```

**Usage in Hooks**:
```bash
# auto_activate_skills.sh
if echo "$PROMPT" | grep -qiE "(implementation|bugfix|feature-development)"; then
  activate_skill "code-quality-enforcer"
fi
```

---

### 7. prevents

**Purpose**: Link to Failure Pattern defense system
**Format**: Array of FP references (e.g., FP-1, FP-2)
**Recommended**: 1-3 patterns

**Failure Pattern References**:
```yaml
prevents: [FP-1]              # Test Tampering
prevents: [FP-2]              # Implementation Shortcuts
prevents: [FP-3]              # Purpose Ambiguity
prevents: [FP-4]              # Test-Driven Implementation (anti-pattern)
prevents: [FP-5]              # Superficial Root Cause Analysis
prevents: [FP-6]              # Verification Insufficiency
prevents: [FP-7]              # False Completion Reporting
prevents: [FP-8]              # Speculation-Based Implementation
prevents: [FP-9]              # Deployment Verification Neglect
prevents: [FP-10]             # Verification Insufficiency (General)
```

**Examples**:
```yaml
prevents: [FP-1, FP-2]        # code-quality-enforcer
prevents: [FP-3]              # purpose-driven-impl
prevents: [FP-5, FP-8]        # root-cause-analyzer
prevents: [FP-6, FP-10]       # verification-enforcer
prevents: [FP-9]              # deployment-verifier
prevents: [FP-7]              # (hooks only, no skill yet)
```

**Note**: Not all skills prevent failure patterns. Workflow/creative skills may not have `prevents` field.

---

## Complete Examples

### Example 1: Quality Enforcement Skill

```yaml
---
name: code-quality-enforcer
description: Enforce test quality and prevent implementation shortcuts when writing or modifying code. Use when implementing features, fixing bugs, or refactoring code. Prevents test tampering (FP-1) and implementation shortcuts (FP-2).
version: 1.0
author: Claude Code Research Project
tags: [quality, testing, tdd]
triggers: [implementation, bugfix, refactoring]
prevents: [FP-1, FP-2]
---
```

**Token Count**: ~65
**Analysis**: Complete, all fields used, under token limit

---

### Example 2: Workflow Skill

```yaml
---
name: brainstorming
description: Transform rough ideas into fully-formed designs through structured questioning and alternative exploration. Use when planning new features or projects.
version: 1.0
author: obra/superpowers
tags: [design, planning, architecture]
triggers: [new feature, planning, design]
---
```

**Token Count**: ~40
**Analysis**: No `prevents` (workflow skill, not defensive), still complete

---

### Example 3: Minimalist Style

```yaml
---
name: test-driven-development
description: Enforce TDD Iron Law - NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST. Use when implementing features.
---
```

**Token Count**: ~20
**Analysis**: Minimal but effective, clear purpose, no optional fields

---

### Example 4: Domain-Specific Skill

```yaml
---
name: python-api-builder
description: Build RESTful APIs using FastAPI with best practices (validation, error handling, documentation). Use when creating Python web services.
version: 1.0
tags: [python, api, fastapi, backend]
triggers: [api, endpoint, rest]
---
```

**Token Count**: ~40
**Analysis**: Technology-specific, clear use case

---

## Token Optimization Techniques

### Technique 1: Use Fragments, Not Sentences

**Verbose**:
```yaml
description: This skill will help you enforce test quality and prevent implementation shortcuts.
```
(16 tokens)

**Concise**:
```yaml
description: Enforce test quality and prevent implementation shortcuts.
```
(9 tokens)

**Savings**: 43%

---

### Technique 2: Combine Related Concepts

**Verbose**:
```yaml
description: Prevents test tampering. Also prevents implementation shortcuts. Use when implementing.
```
(13 tokens)

**Concise**:
```yaml
description: Prevent test tampering and implementation shortcuts when implementing features.
```
(11 tokens)

**Savings**: 15%

---

### Technique 3: Use "when X" Pattern

**Verbose**:
```yaml
description: Use this skill if you are implementing features, or if you are fixing bugs, or if you are refactoring code.
```
(23 tokens)

**Concise**:
```yaml
description: Use when implementing features, fixing bugs, or refactoring code.
```
(12 tokens)

**Savings**: 48%

---

### Technique 4: Reference by Code (FP-X)

**Verbose**:
```yaml
description: Prevents Failure Pattern 1 (test tampering) and Failure Pattern 2 (implementation shortcuts).
```
(15 tokens)

**Concise**:
```yaml
description: Prevents test tampering (FP-1) and implementation shortcuts (FP-2).
```
(12 tokens)

**Savings**: 20%

---

### Technique 5: Omit Redundant Fields

**If name is clear**:
```yaml
name: deployment-verifier
description: Verify deployments using 4-stage process.
```

**No need to repeat**:
```yaml
name: deployment-verifier
description: Deployment verification skill that verifies deployments...  # ❌ Redundant
```

---

## Common Mistakes

### Mistake 1: Frontmatter in Wrong Location

**Wrong**:
```markdown
# Skill Name

---
name: skill-name
description: Description here
---

Content...
```

**Correct**:
```markdown
---
name: skill-name
description: Description here
---

# Skill Name

Content...
```

**Rule**: Frontmatter MUST be at very top of file

---

### Mistake 2: Invalid YAML Syntax

**Wrong**:
```yaml
---
name: skill-name
description: This has: colons and needs "quotes"
---
```

**Correct**:
```yaml
---
name: skill-name
description: "This has: colons and needs quotes"
---
```

**Rule**: Quote strings with special characters

---

### Mistake 3: Inconsistent Field Names

**Wrong**:
```yaml
---
name: skill-1
description: First skill
---

---
skillName: skill-2  # ❌ Different field name
desc: Second skill  # ❌ Abbreviated
---
```

**Correct**:
```yaml
---
name: skill-1
description: First skill
---

---
name: skill-2
description: Second skill
---
```

**Rule**: Use consistent field names across all skills

---

### Mistake 4: Missing Required Fields

**Wrong**:
```yaml
---
name: skill-name
# Missing description
---
```

**Correct**:
```yaml
---
name: skill-name
description: Skill description
---
```

**Rule**: `name` and `description` are REQUIRED

---

## Validation Checklist

**Before Publishing Skill**:

- [ ] Frontmatter at very top of file
- [ ] Valid YAML syntax (no syntax errors)
- [ ] `name` field present (kebab-case, 2-4 words)
- [ ] `description` field present (~40-80 tokens)
- [ ] Description includes "what" (core function)
- [ ] Description includes "when" (trigger condition)
- [ ] Description includes "why/prevents" (if applicable)
- [ ] Total frontmatter <150 tokens
- [ ] All optional fields have valid format
- [ ] Tags are lowercase, 3-5 items
- [ ] Triggers are relevant keywords, 3-5 items
- [ ] Prevents references valid FP codes (if applicable)

---

## Testing Your Frontmatter

### Token Count Test

**Method 1: Online Token Counter**
```
1. Copy YAML frontmatter
2. Visit https://platform.openai.com/tokenizer
3. Paste and count
4. Target: <150 tokens (preferably ~100)
```

**Method 2: jq + wc**
```bash
# Extract frontmatter
head -n 10 SKILL.md | sed '1d;$d' | wc -w
# Rough estimate: words * 1.3 = tokens
```

---

### Syntax Validation

```bash
# Extract frontmatter and validate YAML
head -n 10 SKILL.md | sed '1d;$d' | yq . > /dev/null
# No output = valid YAML
# Error = fix syntax
```

---

### Completeness Check

```bash
# Check required fields
grep -q "^name:" SKILL.md || echo "Missing: name"
grep -q "^description:" SKILL.md || echo "Missing: description"
```

---

## References

**Primary Sources**:
- [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills): Official examples
- [obra/superpowers](https://github.com/obra/superpowers): High-quality skill examples
- Phase 3 Step 4: awesome-claude-skills analysis

**Related Documentation**:
- `PROGRESSIVE_DISCLOSURE.md`: Full skill structure guide
- `SKILL_CATALOG.md`: 50+ skill examples
- Phase 4 custom skills: Implementation examples

---

**Last Updated**: 2025-12-27
**Version**: 1.0
**Maintainer**: Claude Code Research Project
