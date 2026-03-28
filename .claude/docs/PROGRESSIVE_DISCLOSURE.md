# Progressive Disclosure Implementation Guide

**Version**: 1.0
**Last Updated**: 2025-12-27
**Source**: Phase 3 Step 4 research (awesome-claude-skills analysis)

---

## Purpose

Progressive Disclosure is a **token optimization pattern** for Claude Code Skills that enables **93% token reduction** (measured in real-world example) by loading skill content in stages.

**Target Audience**: Skill creators, Claude Code customization engineers

**Key Benefit**: Load only what's needed, when it's needed

---

## Core Concept

### Traditional Approach (Inefficient)

```
User prompt
↓
Claude loads ENTIRE skill content (~5-10k tokens)
↓
Response (skill may not even be relevant)
```

**Problem**: Wastes tokens on skills that might not be needed

---

### Progressive Disclosure Approach (Efficient)

```
User prompt
↓
Stage 1: Load YAML frontmatter ONLY (~100 tokens)
         Check if skill is relevant
         ↓ YES
Stage 2: Load SKILL.md body (~3-5k tokens)
         Check if bundled resources needed
         ↓ YES
Stage 3: Load bundled resources (variable size)
         Execute skill with full context
```

**Benefit**: **93% token savings** when skill not needed (100 vs ~5k tokens)

---

## 3-Stage Loading System

### Stage 1: Metadata (YAML Frontmatter)

**Size**: ~100 tokens
**Purpose**: Quick relevance check
**Contains**:
- Skill name
- Description (what, when, why)
- Optional: version, author, tags, triggers

**Example**:
```yaml
---
name: code-quality-enforcer
description: Enforce test quality and prevent implementation shortcuts when writing or modifying code. Use when implementing features, fixing bugs, or refactoring code. Prevents test tampering (FP-1) and implementation shortcuts (FP-2).
version: 1.0
tags: [quality, testing, tdd]
triggers: [implementation, bugfix, refactoring]
prevents: [FP-1, FP-2]
---
```

**Decision Point**: Is this skill relevant to current task?
- **NO**: Stop here, save ~5k tokens ✓
- **YES**: Proceed to Stage 2

---

### Stage 2: Core Instructions (SKILL.md Body)

**Size**: 3-5k tokens (recommended max)
**Purpose**: Main skill guidance
**Contains**:
- Workflow steps
- Best practices
- Examples
- Checklists
- Decision trees

**Example** (test-driven-development):
```markdown
# Test-Driven Development

## Iron Law
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

## Workflow
1. Write test first (must fail)
2. Run test, verify failure
3. Write minimal implementation
4. Run test, verify pass
5. Refactor if needed
6. Repeat

## Examples
[Detailed examples...]

## Common Mistakes
[Mistakes to avoid...]
```

**Decision Point**: Do I need additional resources (scripts, references, assets)?
- **NO**: Execute with current content ✓
- **YES**: Proceed to Stage 3

---

### Stage 3: Bundled Resources (On-Demand)

**Size**: Variable
**Purpose**: Supplementary materials loaded only when referenced
**Contains**:
- `scripts/`: Reusable code (build scripts, test runners)
- `references/`: Detailed documentation (API specs, schemas)
- `assets/`: Templates and files (config templates, document templates)

**Example Structure**:
```
code-quality-enforcer/
├── SKILL.md                    # Stage 1-2
└── resources/
    ├── scripts/
    │   ├── run_tests.sh        # Stage 3 (if needed)
    │   └── check_coverage.sh   # Stage 3 (if needed)
    ├── references/
    │   └── tdd_patterns.md     # Stage 3 (if needed)
    └── assets/
        └── test_template.py    # Stage 3 (if needed)
```

**Loading**: Referenced explicitly in SKILL.md body, loaded on-demand

---

## Token Efficiency Calculation

### Real-World Example

**Scenario**: 10 skills registered, user asks unrelated question

**Without Progressive Disclosure**:
```
Load all 10 skills fully:
10 skills × ~5k tokens = ~50k tokens
↓
Answer user question
```

**With Progressive Disclosure**:
```
Load metadata only (Stage 1):
10 skills × ~100 tokens = ~1k tokens
↓
None relevant, stop here
↓
Answer user question
```

**Savings**: 50k - 1k = **49k tokens saved (98% reduction)**

---

### Skill-in-Use Example

**Scenario**: User invokes code-quality-enforcer skill

**Without Progressive Disclosure**:
```
Load code-quality-enforcer:
- SKILL.md: 4.5k tokens
- scripts/: 1k tokens
- references/: 2k tokens
- assets/: 0.5k tokens
Total: 8k tokens
```

**With Progressive Disclosure**:
```
Stage 1 (Metadata):
- YAML frontmatter: 100 tokens
  → Relevant? YES

Stage 2 (Core):
- SKILL.md body: 4.5k tokens
  → Bundled resources needed? NO
  → Stop here

Total: 4.6k tokens
```

**Savings**: 8k - 4.6k = **3.4k tokens saved (42.5% reduction)**

---

## Implementation Guide

### Step 1: Create YAML Frontmatter

**Template**:
```yaml
---
name: skill-name
description: [What this skill does], [When to use it], [Why/what it prevents]
version: 1.0
author: Your Name or Organization
tags: [category1, category2, category3]
triggers: [condition1, condition2]
prevents: [FP-X, FP-Y]  # Optional: Failure Pattern references
---
```

**Description Formula**:
```
[Action verb] + [core functionality] + "when" + [trigger condition] + "Prevents" + [failure patterns]
```

**Examples**:

**Good**:
```yaml
description: Enforce test quality and prevent implementation shortcuts when writing or modifying code. Use when implementing features, fixing bugs, or refactoring code. Prevents test tampering (FP-1) and implementation shortcuts (FP-2).
```

**Bad**:
```yaml
description: A skill for code quality.
```
(Too vague, no trigger, no context)

---

### Step 2: Write Concise SKILL.md Body

**Target**: 3-5k tokens (<5k strongly recommended)

**Structure Template**:
```markdown
# Skill Name

## Purpose
[1-2 sentences: What this skill does]

## When to Use
- Scenario 1
- Scenario 2
- Scenario 3

## Workflow

### Phase 1: [Name]
**Actions**:
- Step 1
- Step 2

**Output**: [What to produce]

### Phase 2: [Name]
...

## Examples

### Example 1: [Scenario]
[Concrete example with input/output]

### Example 2: [Scenario]
...

## Common Mistakes
- Mistake 1: [Description + How to avoid]
- Mistake 2: [Description + How to avoid]

## Verification
- [ ] Check 1
- [ ] Check 2

## References
- Related skill: skill-name
- Related rule: docs/rules/file.md
- Related hook: .claude/hooks/hook.sh
```

**Size Management Tips**:
- **Be concise**: Remove fluff, keep essentials
- **Use bullet points**: More scannable than paragraphs
- **Limit examples**: 2-3 max, keep them short
- **Reference don't duplicate**: Link to detailed docs instead of repeating

---

### Step 3: Organize Bundled Resources (Optional)

**Decision Tree**:
```
Do I have code that's repeated verbatim?
├─ YES → scripts/
└─ NO  → Continue

Do I have detailed reference material (>1k tokens)?
├─ YES → references/
└─ NO  → Continue

Do I have templates or assets to use in output?
├─ YES → assets/
└─ NO  → Done (no bundled resources needed)
```

**scripts/**:
- Executable files (shell scripts, Python, etc.)
- Build/test/deploy automation
- Formatters, linters
- **Criterion**: Deterministic, repeated code

**references/**:
- Markdown documentation
- API specifications
- Schema definitions
- Architecture guides
- **Criterion**: >1k tokens, referenced occasionally

**assets/**:
- Config templates
- Document templates
- Image files
- Data files
- **Criterion**: Used in skill output

---

### Step 4: Reference Resources in SKILL.md

**Syntax**:
```markdown
## Detailed Information

For complete API specification, see: [references/api_spec.md](references/api_spec.md)

To run tests, execute:
```bash
bash scripts/run_tests.sh
```

Use the template:
[assets/config_template.json](assets/config_template.json)
```

**Loading Behavior**:
- Claude loads referenced files **on-demand**
- Not loaded if not referenced or not needed
- Keeps token usage minimal

---

### Step 5: Test Token Usage

**Method 1: Manual Calculation**
```
YAML frontmatter tokens:
- Use online token counter (e.g., https://platform.openai.com/tokenizer)
- Aim for <150 tokens

SKILL.md body tokens:
- Count full content (YAML + markdown)
- Subtract YAML tokens
- Aim for 3-5k tokens
```

**Method 2: Claude Code /context Command**
```bash
# In Claude Code session
/context

# Shows token usage breakdown
# Check "Skills" section
```

**Optimization Tips**:
- If >5k tokens: Consider moving detailed content to `references/`
- If <2k tokens: Might need more detail for effectiveness
- Sweet spot: 3-4k tokens (detailed but concise)

---

## Best Practices

### 1. Frontmatter Best Practices

**DO**:
- ✅ Write clear, specific descriptions
- ✅ Include trigger conditions
- ✅ Reference failure patterns (if applicable)
- ✅ Use consistent formatting

**DON'T**:
- ❌ Write vague descriptions ("helps with X")
- ❌ Exceed 150 tokens in frontmatter
- ❌ Include implementation details in frontmatter
- ❌ Use inconsistent field names

---

### 2. SKILL.md Body Best Practices

**DO**:
- ✅ Use structured workflows (Phase 1, Phase 2, etc.)
- ✅ Provide concrete examples
- ✅ Include verification checklists
- ✅ Cross-reference related skills/rules/hooks

**DON'T**:
- ❌ Write wall-of-text paragraphs
- ❌ Duplicate content from other skills
- ❌ Exceed 5k tokens
- ❌ Include code that should be in `scripts/`

---

### 3. Bundled Resources Best Practices

**DO**:
- ✅ Organize by type (scripts/, references/, assets/)
- ✅ Use clear file names
- ✅ Reference explicitly in SKILL.md
- ✅ Keep files focused and modular

**DON'T**:
- ❌ Create resources "just in case"
- ❌ Duplicate code across multiple skills
- ❌ Put large files (>10k tokens) in references/
- ❌ Include unused files

---

## Advanced Patterns

### Pattern 1: Nested Skills

**Use Case**: Complex skill that calls sub-skills

**Example**:
```markdown
# Deployment Workflow

## Phase 3: Verification
For comprehensive verification, invoke the verification-enforcer skill:

**Skill invocation**: `verification-enforcer`

Follow its 4-level verification process...
```

**Benefit**: Modular skill composition, reuse verification logic

---

### Pattern 2: Conditional Loading

**Use Case**: Load different content based on context

**Example**:
```markdown
# Code Quality Enforcer

## Language-Specific Guidelines

For Python projects:
- See [references/python_guidelines.md](references/python_guidelines.md)

For JavaScript projects:
- See [references/javascript_guidelines.md](references/javascript_guidelines.md)
```

**Benefit**: Only load relevant language guide

---

### Pattern 3: Incremental Disclosure

**Use Case**: Progressive detail levels

**Example**:
```markdown
# Test-Driven Development

## Quick Start (Beginner)
1. Write test first
2. Make it fail
3. Make it pass

For detailed workflow, see: [references/tdd_detailed.md](references/tdd_detailed.md)

For advanced patterns, see: [references/tdd_advanced.md](references/tdd_advanced.md)
```

**Benefit**: Serve beginners and experts with same skill

---

## Measured Benefits

### From Phase 3 Research

**Token Efficiency**:
- **93% reduction**: When skill not needed (100 tokens vs ~5k)
- **42% reduction**: When skill used without bundled resources
- **Net benefit**: Significant context window preservation

**Performance**:
- Faster initial response (less to load)
- Lower cost per interaction
- More skills can be registered without token bloat

**User Experience**:
- Skills remain responsive
- No "context window full" errors
- Can have larger skill libraries

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Frontmatter Bloat

**Bad**:
```yaml
---
name: code-quality-enforcer
description: This is a comprehensive skill designed to help you enforce test quality by preventing test tampering and implementation shortcuts. It works by providing detailed guidance throughout the implementation process, from writing tests first (following TDD principles) to ensuring that tests are not weakened to pass. The skill is particularly useful when you are implementing new features, fixing bugs, or refactoring code, as these are common scenarios where shortcuts might be tempting. By using this skill, you can prevent Failure Patterns FP-1 (test tampering) and FP-2 (implementation shortcuts), which are documented in our failure patterns catalog.
# ... 300+ tokens! ❌
---
```

**Good**:
```yaml
---
name: code-quality-enforcer
description: Enforce test quality and prevent implementation shortcuts when writing or modifying code. Use when implementing features, fixing bugs, or refactoring code. Prevents test tampering (FP-1) and implementation shortcuts (FP-2).
# ~50 tokens ✅
---
```

---

### Anti-Pattern 2: Everything in SKILL.md

**Bad**:
```
code-quality-enforcer/
└── SKILL.md (12k tokens!) ❌
    ├── Workflow
    ├── Detailed Python guide (2k tokens)
    ├── Detailed JavaScript guide (2k tokens)
    ├── Test pattern examples (2k tokens)
    ├── Anti-pattern catalog (2k tokens)
    └── Complete test code examples (2k tokens)
```

**Good**:
```
code-quality-enforcer/
├── SKILL.md (4k tokens) ✅
│   ├── Workflow
│   ├── Core principles
│   ├── Examples (brief)
│   └── References to bundled resources
└── resources/
    ├── references/
    │   ├── python_guide.md
    │   ├── javascript_guide.md
    │   ├── test_patterns.md
    │   └── anti_patterns.md
    └── scripts/
        └── example_tests/
```

---

### Anti-Pattern 3: Unused Bundled Resources

**Bad**:
```
skill/
├── SKILL.md
└── resources/
    ├── scripts/
    │   ├── deploy.sh         # Never referenced ❌
    │   └── backup.sh         # Never referenced ❌
    ├── references/
    │   ├── guide_v1.md       # Deprecated ❌
    │   └── guide_v2.md       # Current
    └── assets/
        └── old_template.json # Unused ❌
```

**Good**:
```
skill/
├── SKILL.md
└── resources/
    ├── references/
    │   └── guide.md          # Referenced in SKILL.md ✅
    └── assets/
        └── template.json     # Referenced in SKILL.md ✅
```

**Rule**: **If not referenced in SKILL.md, remove it**

---

## Testing Your Implementation

### Checklist

**Stage 1 (Frontmatter)**:
- [ ] Description is <150 tokens
- [ ] Clearly states: what, when, why/prevents
- [ ] Trigger conditions specified
- [ ] All required fields present

**Stage 2 (SKILL.md Body)**:
- [ ] Total size (YAML + body) is 3-5k tokens
- [ ] Structured workflow (phases, steps)
- [ ] Concrete examples included
- [ ] Verification checklist present
- [ ] Cross-references provided

**Stage 3 (Bundled Resources)**:
- [ ] All bundled resources are referenced in SKILL.md
- [ ] Organized by type (scripts/, references/, assets/)
- [ ] No duplicate or deprecated files
- [ ] File names are clear and descriptive

---

### Load Testing

**Scenario 1: Skill Not Needed**
```
Test: Load skill metadata only
Expected: ~100 tokens loaded
Actual: [measure with /context]
Pass: Actual ≈ 100 tokens ✅
```

**Scenario 2: Skill Used, No Bundled Resources**
```
Test: Load SKILL.md without resources
Expected: 3-5k tokens loaded
Actual: [measure with /context]
Pass: Actual = YAML + body tokens ✅
```

**Scenario 3: Skill Used, With Bundled Resources**
```
Test: Load full skill with resources
Expected: <10k tokens total
Actual: [measure with /context]
Pass: Actual ≤ 10k tokens ✅
```

---

## Migration Guide

### Converting Traditional Skill to Progressive Disclosure

**Before** (single large file):
```
my-skill/
└── SKILL.md (8k tokens)
```

**After** (progressive disclosure):
```
my-skill/
├── SKILL.md (4k tokens = 100 YAML + 3.9k body)
└── resources/
    └── references/
        └── detailed_guide.md (4k tokens)
```

**Steps**:

1. **Extract frontmatter** (if doesn't exist):
   - Create YAML block at top
   - Add name, description, version
   - Aim for ~100 tokens

2. **Identify bundled resource candidates**:
   - Code examples > 500 tokens → scripts/
   - Documentation > 1k tokens → references/
   - Templates → assets/

3. **Extract to bundled resources**:
   - Move identified content to appropriate folders
   - Add references in SKILL.md

4. **Optimize SKILL.md body**:
   - Remove duplication
   - Shorten examples (link to detailed versions)
   - Use bullet points
   - Target 3-5k tokens

5. **Test**:
   - Verify token counts
   - Ensure all references work
   - Confirm skill still effective

---

## References

**Primary Sources**:
- [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills): Progressive Disclosure pattern
- Phase 3 Step 4: awesome-claude-skills collection
- obra/superpowers: High-quality implementation examples

**Related Documentation**:
- `YAML_FRONTMATTER_GUIDE.md`: YAML best practices
- `SKILL_CATALOG.md`: 50+ skill examples
- Phase 4 custom skills: Implementation examples

---

**Last Updated**: 2025-12-27
**Version**: 1.0
**Maintainer**: Claude Code Research Project
