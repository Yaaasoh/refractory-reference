# Skill Catalog

**Version**: 1.0
**Last Updated**: 2025-12-27
**Source**: ComposioHQ/awesome-claude-skills + obra/superpowers + Phase 3 research

---

## Purpose

This document catalogs **50+ Claude Code Skills** organized by category, with implementation patterns and usage guidance. Skills are specialized mini-contexts that guide Claude Code through specific tasks.

**Target Audience**: Claude Code users, skill creators, engineering teams

**How to Use This Catalog**:
1. Find skills by category or search by task
2. Reference implementation patterns
3. Use as inspiration for custom skills

---

## Quick Reference

| Category | Skill Count | Primary Use Cases |
|----------|-------------|-------------------|
| **Development & Code** | 16 | TDD, architecture, code quality, testing |
| **Productivity & Organization** | 7 | File management, workflow optimization |
| **Document Processing** | 5 | DOC, PDF, PPT, Excel manipulation |
| **Communication & Writing** | 6 | Brainstorming, content creation, research |
| **Creative & Media** | 6 | Design, image enhancement, media processing |
| **Business & Marketing** | 5 | Branding, naming, strategy |
| **Data & Analysis** | 2 | CSV analysis, root cause tracing |
| **Collaboration & Project Mgmt** | 3 | Git workflows, review implementation |

**Total**: 50+ skills

---

## Skill Categories

### 1. Development & Code (16 skills)

#### 1.1. test-driven-development (obra/superpowers)
**Purpose**: Enforce TDD methodology with strict discipline
**Iron Law**: "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST"

**Workflow**:
1. Write test first (must fail)
2. Verify test fails
3. Write minimal implementation
4. Verify test passes
5. Refactor if needed

**Best For**:
- New feature development
- Bug fixes requiring tests
- Maintaining test coverage

**Source**: [obra/superpowers](https://github.com/obra/superpowers/tree/main/skills/test-driven-development)

---

#### 1.2. software-architecture
**Purpose**: Design scalable, maintainable system architecture
**Covers**:
- Architectural patterns (MVC, microservices, event-driven)
- Design principles (SOLID, DRY, KISS)
- System design decisions
- Technology stack selection

**Best For**:
- New project planning
- System redesign
- Architectural reviews

---

#### 1.3. code-quality-enforcer (Custom - FP-1, FP-2)
**Purpose**: Prevent test tampering and implementation shortcuts
**Features**:
- TDD enforcement (4-phase workflow)
- Anti-tampering detection
- Implementation quality checks

**Prevents**:
- Weakening tests to pass
- Skipping proper implementation
- Quality shortcuts

**Source**: Created in Phase 4 Step 3 (this project)

---

#### 1.4. root-cause-analyzer (Custom - FP-5, FP-8)
**Purpose**: Deep investigation before implementation
**Methodology**:
- 5 Whys analysis
- Evidence-based investigation
- Read-before-write principle

**Prevents**:
- Superficial fixes
- Speculation-based implementation
- Symptom treating instead of root cause fixing

**Source**: Created in Phase 4 Step 3 (this project)

---

#### 1.5. verification-enforcer (Custom - FP-6, FP-10)
**Purpose**: Comprehensive verification at 4 levels
**Levels**:
1. Smoke tests (basic functionality)
2. Edge cases (boundaries, limits)
3. Error handling (invalid inputs, failures)
4. Stress tests (performance, load)

**Prevents**:
- Incomplete testing
- Missing edge cases
- Insufficient verification

**Source**: Created in Phase 4 Step 3 (this project)

---

#### 1.6. deployment-verifier (Custom - FP-9)
**Purpose**: Ensure proper deployment verification
**4-Stage Process**:
1. Pre-Deploy: Check files, environment, backups
2. During Deploy: Monitor command output
3. Post-Deploy: HTTP check, functionality test, screenshot
4. Definition of Done: All checks passed + evidence collected

**Prevents**:
- Skipping post-deploy checks
- Assuming deployment success
- Missing verification evidence

**Source**: Created in Phase 4 Step 3 (this project)

---

#### 1.7. purpose-driven-impl (Custom - FP-3)
**Purpose**: Ensure clear purpose before implementation
**Framework**: 5W1H (Who, What, When, Where, Why, How)

**Process**:
1. Purpose Statement creation
2. Requirements clarification
3. Success criteria definition
4. Then implementation

**Prevents**:
- Starting without clear purpose
- Environment confusion
- Ambiguous requirements

**Source**: Created in Phase 4 Step 3 (this project)

---

#### 1.8. MCP Builder
**Purpose**: Build Model Context Protocol servers
**Features**:
- Server scaffolding
- Tool definition
- Integration testing

**Best For**:
- Creating custom MCP servers
- Extending Claude Code capabilities

---

#### 1.9. Debugging Assistant
**Purpose**: Systematic debugging workflow
**Covers**:
- Error analysis
- Stack trace interpretation
- Reproduction steps
- Fix validation

---

#### 1.10. API Developer
**Purpose**: RESTful API design and implementation
**Features**:
- Endpoint design
- Request/response schemas
- Error handling
- API documentation

---

#### 1.11. Database Schema Designer
**Purpose**: Design normalized database schemas
**Covers**:
- Entity relationship modeling
- Normalization (1NF, 2NF, 3NF)
- Index strategy
- Migration planning

---

#### 1.12. Code Reviewer
**Purpose**: Automated code review with best practices
**Checks**:
- Code quality
- Security vulnerabilities
- Performance issues
- Best practice violations

---

#### 1.13. Refactoring Guide
**Purpose**: Safe refactoring workflows
**Patterns**:
- Extract function/class
- Rename safely
- Remove duplication
- Improve readability

---

#### 1.14. Performance Optimizer
**Purpose**: Identify and fix performance bottlenecks
**Covers**:
- Profiling
- Optimization strategies
- Caching
- Query optimization

---

#### 1.15. Security Auditor
**Purpose**: Security vulnerability detection
**Checks**:
- OWASP Top 10
- Input validation
- Authentication/authorization
- Dependency vulnerabilities

---

#### 1.16. Test Generator
**Purpose**: Generate comprehensive test suites
**Generates**:
- Unit tests
- Integration tests
- Edge case tests
- Mock data

---

### 2. Productivity & Organization (7 skills)

#### 2.1. File Organizer
**Purpose**: Organize files by type, date, or custom rules
**Features**:
- Pattern-based organization
- Batch operations
- Duplicate detection

---

#### 2.2. kaizen (Continuous Improvement)
**Purpose**: Systematic workflow improvement
**Methodology**:
- Identify waste
- Propose improvements
- Measure impact
- Iterate

---

#### 2.3. Task Planner
**Purpose**: Break complex tasks into actionable steps
**Output**:
- Task breakdown
- Dependency mapping
- Time estimation
- Priority ordering

---

#### 2.4. Documentation Generator
**Purpose**: Auto-generate documentation from code
**Generates**:
- API docs
- README files
- Code comments
- Architecture diagrams

---

#### 2.5. Workflow Optimizer
**Purpose**: Optimize development workflows
**Covers**:
- Build process
- CI/CD pipelines
- Git workflows
- Tool integration

---

#### 2.6. Meeting Note Taker
**Purpose**: Structure and summarize meeting notes
**Features**:
- Action item extraction
- Decision tracking
- Follow-up scheduling

---

#### 2.7. Knowledge Base Curator
**Purpose**: Organize and maintain knowledge repositories
**Functions**:
- Content categorization
- Link validation
- Duplicate removal
- Search optimization

---

### 3. Document Processing (5 skills)

#### 3.1. docx Processor
**Purpose**: Create and manipulate Word documents
**Capabilities**:
- Document generation
- Style application
- Template processing

---

#### 3.2. pdf Processor
**Purpose**: Read, extract, and generate PDFs
**Features**:
- Text extraction
- PDF generation
- Merging/splitting

---

#### 3.3. pptx Creator
**Purpose**: PowerPoint presentation generation
**Capabilities**:
- Slide creation
- Chart/table insertion
- Template application

---

#### 3.4. xlsx Analyzer
**Purpose**: Excel file processing and analysis
**Features**:
- Data extraction
- Formula application
- Chart generation

---

#### 3.5. Markdown to EPUB
**Purpose**: Convert Markdown to eBook format
**Features**:
- Formatting preservation
- TOC generation
- Metadata handling

---

### 4. Communication & Writing (6 skills)

#### 4.1. brainstorming (obra/superpowers)
**Purpose**: Transform rough ideas into structured designs
**3-Phase Process**:

**Phase 1: Understanding**
- Check project state
- Ask questions **one at a time**
- Use multiple-choice format
- Focus on purpose, constraints, success criteria

**Phase 2: Exploration**
- Present 2-3 approaches with trade-offs
- Lead with recommended option
- Provide clear reasoning

**Phase 3: Design Presentation**
- Break into small sections (200-300 words)
- Validate after each section
- Cover: architecture, components, data flow, error handling, testing

**Implementation**:
- Document: `docs/plans/YYYY-MM-DD-<topic>-design.md`
- Git-based version control
- Create isolated workspace
- Follow YAGNI principle

**Key Principles**:
- **1 question at a time** (avoid multiple questions)
- **Multiple-choice format** (reduce decision burden)
- **Staged validation** (200-300 words per section)
- **YAGNI enforcement** (remove unnecessary features upfront)

**Source**: [obra/superpowers](https://github.com/obra/superpowers/tree/main/skills/brainstorming)

---

#### 4.2. Content Research Writer
**Purpose**: Research and write well-sourced content
**Features**:
- Source gathering
- Fact checking
- Citation management
- Coherent narrative

---

#### 4.3. Technical Writer
**Purpose**: Create clear technical documentation
**Outputs**:
- User guides
- Technical specs
- How-to articles
- Release notes

---

#### 4.4. Email Composer
**Purpose**: Draft professional emails
**Handles**:
- Business correspondence
- Customer support
- Internal communication

---

#### 4.5. Report Generator
**Purpose**: Create structured reports
**Types**:
- Status reports
- Analysis reports
- Executive summaries

---

#### 4.6. Copy Editor
**Purpose**: Edit and improve written content
**Checks**:
- Grammar and spelling
- Clarity and conciseness
- Tone and style
- Formatting

---

### 5. Creative & Media (6 skills)

#### 5.1. Canvas Design
**Purpose**: Create designs using Canvas (HTML5)
**Capabilities**:
- Layout creation
- Visual elements
- Interactive components

---

#### 5.2. Image Enhancer
**Purpose**: Image processing and enhancement
**Features**:
- Quality improvement
- Format conversion
- Batch processing

---

#### 5.3. SVG Generator
**Purpose**: Create scalable vector graphics
**Outputs**:
- Icons
- Diagrams
- Illustrations

---

#### 5.4. Color Palette Creator
**Purpose**: Generate harmonious color schemes
**Methods**:
- Complementary colors
- Analogous colors
- Brand-based palettes

---

#### 5.5. Logo Designer
**Purpose**: Create logo concepts
**Process**:
- Concept exploration
- Sketch generation
- Refinement

---

#### 5.6. UI Mockup Generator
**Purpose**: Create UI mockups and wireframes
**Outputs**:
- Low-fidelity wireframes
- High-fidelity mockups
- Interactive prototypes

---

### 6. Business & Marketing (5 skills)

#### 6.1. Brand Guidelines Creator
**Purpose**: Develop comprehensive brand guidelines
**Covers**:
- Visual identity
- Voice and tone
- Usage rules

---

#### 6.2. Domain Name Brainstormer
**Purpose**: Generate and evaluate domain names
**Criteria**:
- Memorability
- Availability
- SEO potential

---

#### 6.3. Marketing Strategy Planner
**Purpose**: Develop marketing strategies
**Components**:
- Target audience
- Channel selection
- Campaign planning

---

#### 6.4. Competitive Analysis
**Purpose**: Analyze competitor landscape
**Analyzes**:
- Feature comparison
- Pricing strategies
- Market positioning

---

#### 6.5. Business Plan Writer
**Purpose**: Create structured business plans
**Sections**:
- Executive summary
- Market analysis
- Financial projections
- Operations plan

---

### 7. Data & Analysis (2 skills)

#### 7.1. CSV Data Summarizer
**Purpose**: Analyze and summarize CSV data
**Features**:
- Statistical analysis
- Pattern detection
- Visualization suggestions

---

#### 7.2. Root Cause Tracing
**Purpose**: Trace issues to root causes
**Methodology**:
- 5 Whys
- Fishbone diagrams
- Timeline analysis

---

### 8. Collaboration & Project Management (3 skills)

#### 8.1. git-pushing
**Purpose**: Streamline Git workflows
**Features**:
- Commit message generation
- Branch management
- Merge conflict resolution

---

#### 8.2. review-implementing
**Purpose**: Implement code review feedback
**Process**:
- Parse review comments
- Prioritize changes
- Implement fixes
- Verify resolution

---

#### 8.3. Project Timeline Creator
**Purpose**: Create project timelines and Gantt charts
**Outputs**:
- Milestone planning
- Dependency mapping
- Resource allocation

---

## Implementation Patterns

### Pattern 1: Progressive Disclosure (Recommended)

**Structure**:
```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (~100 tokens)
│   └── Markdown instructions (<5k tokens)
└── Bundled Resources (optional)
    ├── scripts/      # Deterministic, repeated code
    ├── references/   # Documentation, schemas
    └── assets/       # Templates, output files
```

**Loading Stages**:
1. **Metadata** (YAML frontmatter): ~100 tokens
2. **Core Instructions** (SKILL.md body): <5k tokens
3. **Bundled Resources** (on-demand): Variable

**Benefit**: **93% token reduction** (real example from research)

---

### Pattern 2: YAML Frontmatter Best Practices

**Required Fields**:
```yaml
---
name: skill-name
description: What this skill does, when to use it, which failure patterns it prevents (if applicable). Use when [trigger condition].
---
```

**Optional Fields**:
```yaml
---
name: skill-name
description: Skill description
version: 1.0
author: Your Name
tags: [category1, category2]
triggers: [condition1, condition2]
prevents: [FP-1, FP-2]  # Failure Pattern references
---
```

**Description Guidelines**:
- **What**: Core functionality
- **When**: Trigger conditions
- **Why**: Prevents which failure patterns (if applicable)

**Example**:
```yaml
---
name: code-quality-enforcer
description: Enforce test quality and prevent implementation shortcuts when writing or modifying code. Use when implementing features, fixing bugs, or refactoring code. Prevents test tampering (FP-1) and implementation shortcuts (FP-2).
---
```

---

### Pattern 3: Workflow Skills (Multi-Phase)

**Template**:
```markdown
# Skill Name

## Phase 1: [Stage Name]
**Actions**:
- Step 1
- Step 2

**Output**: What to produce

## Phase 2: [Stage Name]
**Actions**:
- Step 1
- Step 2

**Output**: What to produce

## Phase 3: [Stage Name]
...
```

**Examples**: brainstorming, deployment-verifier, test-driven-development

---

### Pattern 4: Checklist Skills

**Template**:
```markdown
# Skill Name

## Pre-Task Checklist
- [ ] Check 1
- [ ] Check 2

## Execution Checklist
- [ ] Step 1
- [ ] Step 2

## Verification Checklist
- [ ] Verify 1
- [ ] Verify 2

## Evidence Collection
- [ ] Collect 1
- [ ] Collect 2
```

**Examples**: deployment-verifier, verification-enforcer

---

### Pattern 5: Decision Tree Skills

**Template**:
```markdown
# Skill Name

## Step 1: Identify Scenario

If A:
  → Follow path 1
If B:
  → Follow path 2
If C:
  → Follow path 3

## Step 2: Path 1
...

## Step 3: Path 2
...
```

**Examples**: root-cause-analyzer, debugging-assistant

---

### Pattern 6: Template-Based Skills

**Template**:
```markdown
# Skill Name

## Input Requirements
- Required: X, Y, Z
- Optional: A, B

## Template

[Provide structured template with placeholders]

## Example

[Show filled example]

## Validation

- Check 1
- Check 2
```

**Examples**: Business plan writer, report generator

---

## Creating Custom Skills

### Skill Creation Workflow (6 Steps)

**Step 1: Understand Use Cases**
- Collect actual scenarios
- Clarify application methods

**Step 2: Plan Reusable Content**
- Identify scripts, references, assets
- Design repeatable structure

**Step 3: Initialize Skill**
- Use template or `init_skill.py`
- Create directory structure

**Step 4: Edit Skill**
- Implement SKILL.md
- Add bundled resources if needed

**Step 5: Package**
- Validate with `package_skill.py`
- Create distribution zip

**Step 6: Iterate**
- Gather feedback
- Improve based on actual usage

**Source**: [ComposioHQ skill-creator](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/skill-creator)

---

### Resource Selection Guidelines

**scripts/**:
- **Use for**: Deterministic code written repeatedly
- **Examples**: Build scripts, test runners, formatters

**references/**:
- **Use for**: Documentation, schemas, detailed reference material
- **Examples**: API specs, style guides, architecture docs

**assets/**:
- **Use for**: Templates, files used in output
- **Examples**: Document templates, image assets, config templates

---

### Size Constraints

**Recommended Limits**:
- **YAML frontmatter**: ~100 tokens
- **SKILL.md body**: <5k tokens (ideally 3-4k)
- **Total skill size**: <10k tokens including resources

**Why**: Progressive Disclosure efficiency

**Trade-off**: Smaller = faster load, but must be complete enough to be useful

---

## Usage Guidelines

### When to Invoke Skills

**Automatic (via Hooks)**:
- auto_activate_skills.sh detects context and suggests skills
- Example: Implementation task → suggests code-quality-enforcer

**Manual Invocation**:
- User requests specific skill
- Claude recognizes task matches skill purpose

**From Rules**:
- Rules reference Skills for detailed guidance
- Example: test.md → references test-driven-development skill

---

### Skill Combination Strategies

**Sequential**:
```
1. brainstorming (design phase)
→ 2. software-architecture (architecture phase)
→ 3. test-driven-development (implementation)
→ 4. deployment-verifier (deployment)
```

**Parallel** (different aspects):
```
- code-quality-enforcer (implementation quality)
+ verification-enforcer (testing quality)
+ purpose-driven-impl (purpose clarity)
```

**Nested** (invoke sub-skill):
```
deployment-verifier calls:
  → verification-enforcer (for comprehensive testing)
```

---

## Skill Effectiveness Metrics

### From Phase 3 Research

**Token Efficiency**:
- Progressive Disclosure: 93% token reduction (actual measurement)
- YAML-only load: ~100 tokens vs ~5k for full skill

**Success Rate**:
- Detailed instructions (Phase 2 of Explore → Plan → Code → Commit): "Significantly improve first-try success" (Anthropic official)
- Structured workflows: Higher completion rates

**Quality Improvement**:
- TDD skill: Reduces test tampering incidents
- Anti-tampering skills: Prevents FP-1, FP-2 patterns

---

## References

**Primary Sources**:
- [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills): 50+ skills catalog
- [obra/superpowers](https://github.com/obra/superpowers): High-quality skill examples
- Phase 3 research: Step 4 awesome-claude-skills collection

**Related Documentation**:
- `PROGRESSIVE_DISCLOSURE.md`: Implementation details
- `YAML_FRONTMATTER_GUIDE.md`: Best practices
- `FAILURE_PATTERNS.md`: Failure patterns that skills prevent

**Custom Skills (Created in Phase 4)**:
- `.claude/skills/code-quality-enforcer/`
- `.claude/skills/deployment-verifier/`
- `.claude/skills/purpose-driven-impl/`
- `.claude/skills/root-cause-analyzer/`
- `.claude/skills/verification-enforcer/`

---

**Last Updated**: 2025-12-27
**Version**: 1.0
**Maintainer**: Claude Code Research Project
