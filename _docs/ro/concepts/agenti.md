# Concept: Cei 14 Agenti AI Specialists

Agent OS are **14 specialized AI agents** (Claude instances with different tools, models, prompts).

Fiecare agent e optimizer pentru specific task: planning, spec writing, implementation, review, etc.

---

## 🎯 Overview

```
PLANNING
├─ product-planner        (Define mission, roadmap, tech stack)
│
SPECIFICATION
├─ spec-initializer       (Create spec folder structure)
├─ spec-shaper            (Clarify requirements)
├─ spec-writer            (Write detailed specifications)
└─ spec-verifier          (Audit spec quality)

IMPLEMENTATION
├─ tasks-list-creator     (Break spec into tasks)
├─ implementer            (Write code)
├─ code-reviewer          (Deep review)
└─ implementation-verifier (Verify completion)

EXTENDED
├─ test-strategist        (Design test plans)
├─ documentation-writer   (Auto-generate docs)
├─ dependency-manager     (Audit dependencies)
├─ refactoring-advisor    (Technical debt analysis)
└─ feature-analyst        (Feature discovery, proposals, duplicates)
```

---

## 👥 Core Development Agents (8)

### 1. product-planner
**Role**: Define vision, mission, roadmap

**Used by**: `/agent-os:plan-product`

**Tools**: Bash, Read, Write, WebFetch

**Model**: Inherit (uses parent model)

**Responsibilities**:
- Gather product info
- Write mission statement
- Create product roadmap
- Decide tech stack
- Competitive analysis

**Output**: mission.md, roadmap.md, tech-stack.md

---

### 2. spec-initializer
**Role**: Create spec folder structure, initialize

**Used by**: `/agent-os:shape-spec`

**Tools**: Write, Read, Bash

**Model**: Sonnet (medium complexity)

**Responsibilities**:
- Create spec directory structure
- Initialize templates
- Setup for spec-shaper

---

### 3. spec-shaper
**Role**: Clarify vague requirements

**Used by**: `/agent-os:shape-spec`

**Tools**: Write, Read, Bash, WebFetch, Grep, Glob, Skill

**Model**: Sonnet

**Responsibilities**:
- Ask clarifying questions
- Identify ambiguities
- Document requirements
- Create requirement analysis

---

### 4. spec-writer
**Role**: Write detailed technical specifications

**Used by**: `/agent-os:write-spec`, `/agent-os:update-spec`

**Tools**: Write, Read, Bash, WebFetch, Grep, Glob, Skill

**Model**: Sonnet

**Responsibilities**:
- Write acceptance criteria
- Document API specifications
- Create data model / schema
- Define error handling
- Security considerations

**Output**: specification.md, implementation-notes.md, data-model.md

---

### 5. spec-verifier
**Role**: Verify spec completeness and quality

**Used by**: `/agent-os:verify-spec`

**Tools**: Write, Read, Bash, WebFetch, Skill

**Model**: Sonnet

**Responsibilities**:
- Check spec against checklist
- Find gaps and ambiguities
- Suggest improvements
- Verify acceptance criteria clarity

**Output**: verification-report.md

---

### 6. tasks-list-creator
**Role**: Break spec into implementable tasks

**Used by**: `/agent-os:create-tasks`

**Tools**: Write, Read, Bash, WebFetch, Skill

**Model**: Sonnet

**Responsibilities**:
- Analyze spec
- Create task breakdown
- Estimate story points
- Identify dependencies
- Create implementation schedule

**Output**: tasks.md, task-breakdown.md, implementation-schedule.md

---

### 7. implementer
**Role**: Write code to implement tasks

**Used by**: `/agent-os:implement-tasks`, `/agent-os:orchestrate-tasks`

**Tools**: Write, Read, Bash, WebFetch, Skill, Playwright

**Model**: Sonnet (default, or specify)

**Responsibilities**:
- Understand task requirements
- Write code
- Create tests
- Follow standards
- Document code

**Output**: Code in repository

---

### 8. implementation-verifier
**Role**: Verify tasks are complete and spec met

**Used by**: `/agent-os:implement-tasks`, `/agent-os:orchestrate-tasks`

**Tools**: Write, Read, Bash, WebFetch, Skill, Playwright

**Model**: Sonnet

**Responsibilities**:
- Run tests
- Verify spec compliance
- Check code quality
- Generate verification report

**Output**: verification-report.md

---

## 🔧 Extended Support Agents (6)

### 9. code-reviewer
**Role**: Deep code review (security, quality, standards)

**Used by**: `/agent-os:review-code`, included in `/agent-os:implement-tasks`

**Tools**: Write, Read, Bash, WebFetch, Grep, Glob

**Model**: Opus (best for comprehensive review)

**Responsibilities**:
- Security vulnerability detection
- Code quality analysis
- Standards compliance check
- Bug detection
- Performance issues

**Output**: code-review.md (with issue IDs: SEC-001, BUG-015, etc.)

---

### 10. test-strategist
**Role**: Design test plans and coverage strategy

**Used by**: `/agent-os:test-strategy`

**Tools**: Write, Read, Bash, WebFetch, Grep, Glob

**Model**: Sonnet

**Responsibilities**:
- Analyze code coverage gaps
- Design unit tests
- Design integration tests
- Design E2E tests
- Prioritize tests

**Output**: test-strategy.md, coverage-report.md

---

### 11. documentation-writer
**Role**: Auto-generate API docs, README, setup guides

**Used by**: `/agent-os:generate-docs`

**Tools**: Write, Read, Bash, WebFetch, Grep, Glob

**Model**: Sonnet

**Responsibilities**:
- Generate API documentation
- Write README
- Create setup guide
- Update CHANGELOG
- Examples and usage

**Output**: api.md, README.md, setup.md, CHANGELOG.md

---

### 12. dependency-manager
**Role**: Audit dependencies for vulnerabilities and health

**Used by**: `/agent-os:audit-deps`

**Tools**: Write, Read, Bash, WebFetch, Grep, Glob

**Model**: Haiku (lightweight scanning)

**Responsibilities**:
- Scan for vulnerabilities
- Check outdated packages
- Verify license compatibility
- Recommend updates

**Output**: dependency-audit.md

---

### 13. refactoring-advisor
**Role**: Identify technical debt and refactoring opportunities

**Used by**: `/agent-os:analyze-refactoring`

**Tools**: Write, Read, Bash, Grep, Glob

**Model**: Opus (best for architectural analysis)

**Responsibilities**:
- Analyze code for technical debt
- Identify code smells
- Suggest refactoring
- Prioritize improvements
- Estimate effort

**Output**: refactoring-analysis.md, priority-matrix.md

---

### 14. feature-analyst
**Role**: Discover existing features, propose new ones, check duplicates

**Used by**: `/agent-os:analyze-features`

**Tools**: Write, Read, Bash, Grep, Glob, WebFetch

**Model**: Opus (best for pattern recognition and complex analysis)

**Responsibilities**:
- Scan codebase for existing features
- Identify architectural patterns and conventions
- Propose new features based on gaps found
- Check if proposed features already exist (prevent duplicates)
- Create feature catalogs and gap analysis

**4 Analysis Modes**:
1. **Discover** - Catalog all existing features
2. **Propose** - Suggest new features based on patterns
3. **Check Duplicate** - Verify proposed feature doesn't exist
4. **Full Analysis** - All of the above combined

**Output**: feature-analysis.md, feature-catalog, gap-analysis, FEAT-XXX/DUP-XXX/GAP-XXX issues

---

## 🧠 Model Assignment Strategy

### Opus (Most Capable)
Used for complex tasks that need deep reasoning:
- `code-reviewer` - Security + quality analysis
- `refactoring-advisor` - Architectural decisions
- `feature-analyst` - Feature discovery, pattern recognition, duplicate prevention

---

### Sonnet (Balanced)
Used for moderate complexity tasks (default):
- `spec-writer` - Detailed documentation
- `implementer` - Code generation
- `test-strategist` - Test planning
- `documentation-writer` - Auto-docs
- And most others

---

### Haiku (Fast & Cheap)
Used for simple, repetitive tasks:
- `dependency-manager` - Mostly tool calls, scanning

---

### Inherit
Some agents inherit parent model:
- `product-planner` - Uses inherit (flexible)

---

## 🔄 Agent Workflow Example

### Feature: Task CRUD API

```
1. product-planner
   └─ /agent-os:plan-product → roadmap includes "Task CRUD"

2. spec-writer
   └─ /agent-os:write-spec → specification.md

3. spec-verifier
   └─ /agent-os:verify-spec → verification-report.md (optional)

4. tasks-list-creator
   └─ /agent-os:create-tasks → 12 tasks

5. implementer (× 12 tasks)
   └─ /agent-os:implement-tasks → code per task

6. code-reviewer
   └─ Automatic review after each task

7. implementation-verifier
   └─ Automatic verification after code review

8. test-strategist
   └─ /agent-os:test-strategy → test-strategy.md (optional)

9. documentation-writer
   └─ /agent-os:generate-docs → API docs (optional)
```

---

## 🛠️ Agent Tools Matrix

| Agent | Write | Read | Bash | WebFetch | Grep | Glob | Skill | Playwright |
|-------|-------|------|------|----------|------|------|-------|-----------|
| product-planner | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| spec-initializer | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| spec-shaper | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| spec-writer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| spec-verifier | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| tasks-list-creator | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| implementer | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |
| implementation-verifier | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ |
| code-reviewer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| test-strategist | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| documentation-writer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| dependency-manager | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| refactoring-advisor | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ |
| feature-analyst | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |

---

## 📊 Agent Load Distribution

### During `/agent-os:implement-tasks` (single-agent)

```
implementer         ■■■■■■■■ 80% (main work)
code-reviewer       ■■ 10% (auto review each task)
implementation-ver  ■ 10% (verify completion)
```

---

### During `/agent-os:orchestrate-tasks` (multi-agent)

```
implementer         ■■■■ 40% (parallel x4 agents)
code-reviewer       ■■ 10% (parallel review)
implementation-ver  ■ 10% (parallel verification)
coordonare internă  ■ 5% (orchestration - handled by main agent)
```

---

## 🎓 Learning Path

**For Developers**: Focus on implementer agent behavior

**For Tech Leads**: Understand all agents + orchestration

**For Architects**: Deep dive into model assignment + workflow design

---

**Now you understand the 14 agents! Ready to use them?** 🚀

Choose a command like `/agent-os:plan-product` and see which agent(s) get delegated!

**NEW!** Try `/agent-os:analyze-features` for feature discovery and proposals!
