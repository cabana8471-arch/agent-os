# Workflow: Proiecte EXISTENTE

Adaugi feature-uri sau refactorizezi codul **existent**. Workflow special pentru legacy/mature projects.

---

## 🚀 Quick Overview

```
Faza 0: Audit (understand what you have)
  ├─ /agent-os:audit-deps → Dependency vulnerabilities
  ├─ /agent-os:review-code → Baseline code quality
  └─ /agent-os:analyze-refactoring → Technical debt

Faza 1: Document State (reverse-engineer mission)
  └─ /agent-os:plan-product → document existing product

Faza 2: Add Feature OR Fix Bug OR Refactor
  ├─ /agent-os:write-spec → requirements for change
  ├─ /agent-os:create-tasks → breakdown
  └─ /agent-os:implement-tasks → code + review

Faza 3: QA & Release
  └─ /agent-os:test-strategy, /agent-os:generate-docs → deploy
```

**Timeline**: 1-10 zile (depinde de task)

---

## ⚙️ Setup Inițial

### 1. Base Installation (O singură dată pe mașina ta)

Dacă nu ai instalat Agent OS pe mașina ta, execută:

```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash
```

Aceasta creează `~/agent-os` cu profilurile și scripturile de bază.

**Pentru Windows**: Deschide [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) sau [Git Bash](https://git-scm.com/download/win), apoi rulează comanda de mai sus.

### 2. Instalează Agent OS în Proiect

```bash
cd /path/to/existing-project

# Run installer
~/agent-os/scripts/project-install.sh

# Review generated files
ls agent-os/
```

### 3. Configurare

Edit `agent-os/config.yml` **to match your tech stack**:

```yaml
profile: "default"  # Or custom profile matching your tech

# If using standards as Claude Code Skills
standards_as_claude_code_skills: true

# Configure for your repo structure
# (see config.yml comments for details)
```

### 4. Selectează Tech Stack Profile (opțional)

Pentru proiecte existente, e **foarte important** să alegi un profile care să se potrivească cu tech stack-ul tau:

```bash
# Django backend
./scripts/project-install.sh --profile django-api

# Rails backend
./scripts/project-install.sh --profile rails-api

# React frontend
./scripts/project-install.sh --profile react-app

# Node.js backend
./scripts/project-install.sh --profile node-express

# Generic custom
./scripts/project-install.sh --profile general
```

**De ce?**: Agent OS va aplica conventions specifice tech stack-ului tău. Pentru codul legacy, aceasta e esențial pentru consistency.

📖 **Citeste mai mult**: [Profiles - Tech Stack Customization](../concepts/profiles.md)

---

## Faza 0: Audit - Understand Current State

### Ce se întâmplă?

Analizează codul existent pentru:
- Dependency vulnerabilities
- Code quality baseline
- Technical debt
- Refactoring opportunities

### Execuție - Pasul 1: Audit Dependencies

```bash
/agent-os:audit-deps
```

**Output**:
- ✅ `dependency-audit.md` - Vulnerabilities, outdated packages
- ✅ License compliance report
- ✅ Update recommendations

**Action**: Fix CRITICAL vulnerabilities immediately.

---

### Execuție - Pasul 2: Code Review Baseline

```bash
/agent-os:review-code
```

**Output**:
- ✅ `code-review.md` - Issues by severity (CRITICAL/HIGH/MEDIUM/LOW)
- ✅ Security findings (SQL injection, XSS, etc.)
- ✅ Code quality findings
- ✅ Standards compliance

**Action**: Categorize findings:
- CRITICAL/HIGH: Fix before feature dev
- MEDIUM/LOW: Backlog for refactoring

---

### Execuție - Pasul 3: Technical Debt Analysis

```bash
/agent-os:analyze-refactoring
```

**Output**:
- ✅ `refactoring-analysis.md` - Tech debt opportunities
- ✅ Effort estimates (1 day, 1 week, 1 month)
- ✅ Priority matrix (impact vs effort)
- ✅ Recommended refactoring order

**Action**: Plan refactoring incrementally, not all at once.

---

## Faza 1: Document Existing Product

### Ce se întâmplă?

Documentați mission/roadmap pentru codul existent (reverse-engineering).

### Execuție

```bash
/agent-os:plan-product --reverse-engineer true
```

**Agentul va analiza**:
- Existing code structure
- Features implemented
- Tech stack used
- User personas (if available)

**Agentul va crea**:
- ✅ `agent-os/product/mission.md` - What does app do?
- ✅ `agent-os/product/roadmap.md` - Feature status + next steps
- ✅ `agent-os/product/tech-stack.md` - Current tech decisions

**Benefit**: Team alignment, baseline for future planning

---

## Faza 2: Add Feature / Fix Bug / Refactor

### Tip 1: NEW FEATURE (in existing codebase)

**Execuție**:

```bash
# Step 1: Spec the feature
/agent-os:write-spec --feature "New Feature Name"

# Step 2: Break down to tasks
/agent-os:create-tasks --spec "agent-os/specs/feature-name/specification.md"

# Step 3: Implement + review
/agent-os:implement-tasks --feature "New Feature Name"
```

**Exemplu**: Add "Export tasks as CSV"
```bash
/agent-os:write-spec --feature "Export Tasks to CSV"
/agent-os:create-tasks --spec "agent-os/specs/export-csv/specification.md"
/agent-os:implement-tasks --feature "Export Tasks to CSV"
```

---

### Tip 2: BUG FIX (in existing code)

**Execuție**:

```bash
# Step 1: Research + spec
/agent-os:write-spec --feature "Fix: [Bug Description]"

# Step 2: Break down
/agent-os:create-tasks --spec "agent-os/specs/bug-fix/specification.md"

# Step 3: Implement + review
/agent-os:implement-tasks --feature "Fix: [Bug Description]"
```

**Exemplu**: Memory leak in task polling
```bash
/agent-os:write-spec --feature "Fix: Memory leak in task polling"
/agent-os:create-tasks --spec "agent-os/specs/fix-memory-leak/specification.md"
/agent-os:implement-tasks --feature "Fix: Memory leak in task polling"
```

---

### Tip 3: REFACTORING (tech debt)

**Execuție**:

```bash
# Use refactoring analysis output
# Create spec for refactoring plan
/agent-os:write-spec --feature "Refactor: [Component/Module]"

# Break down (usually 3-5 tasks per refactor)
/agent-os:create-tasks --spec "agent-os/specs/refactor-x/specification.md"

# Implement incrementally
/agent-os:implement-tasks --feature "Refactor: [Component/Module]"
```

**Exemplu**: Migrate JavaScript to TypeScript
```bash
/agent-os:write-spec --feature "Migrate: JavaScript to TypeScript - Phase 1"
/agent-os:create-tasks --spec "agent-os/specs/js-to-ts/specification.md"
/agent-os:implement-tasks --feature "Migrate: JS to TypeScript - Phase 1"

# Then Phase 2, Phase 3, etc.
```

---

## Faza 3: QA & Release

### Optional: Test Strategy

```bash
/agent-os:test-strategy --feature "Feature Name"
```

Output:
- Test recommendations (unit, integration, E2E)
- Coverage gaps
- Priority tests to write

---

### Optional: Update Documentation

```bash
/agent-os:generate-docs
```

Output:
- Updated API documentation
- README with new feature
- Setup guide updates

---

### Deploy

1. ✅ Feature implemented + tested
2. ✅ Code review approved
3. ✅ Tests passing
4. ✅ Merge to main
5. ✅ Deploy to production

---

## 📊 Common Scenarios

### Scenariul 1: Add Feature to Existing App (2-3 zile)

```bash
Day 1:
1. /agent-os:write-spec --feature "Feature Name"
2. /agent-os:create-tasks
3. /agent-os:implement-tasks (Pasul 1 of feature)

Day 2:
4. /agent-os:implement-tasks (continuare)

Day 3:
5. /agent-os:test-strategy
6. /agent-os:generate-docs (update)
7. Merge + deploy
```

---

### Scenariul 2: Fix Critical Bug (4-8 ore)

```bash
Morning:
1. /agent-os:write-spec --feature "Fix: [Bug]"
2. /agent-os:create-tasks
3. /agent-os:implement-tasks

Afternoon:
4. Merge + deploy hotfix
5. Monitor in production
```

---

### Scenariul 3: Refactoring Legacy Module (1-2 săptămâni)

```bash
Day 1-2:
1. /agent-os:analyze-refactoring (done in Faza 0)
2. /agent-os:write-spec --feature "Refactor: [Module]"
3. /agent-os:create-tasks

Days 3-7:
4. /agent-os:implement-tasks (per task, incrementally)
5. Frequent merges + testing

Day 8:
6. /agent-os:review-code (deep audit)
7. Deploy Phase 1

Day 9+:
8. Continue refactoring phases
```

---

## 💡 Best Practices

### ✅ DO

- ✅ **Audit first**: Understand current state before adding features
- ✅ **Fix critical issues**: Security + performance bugs first
- ✅ **Refactor incrementally**: Small PR-s, not big rewrites
- ✅ **Test thoroughly**: Existing code + new code + integration
- ✅ **Document changes**: Update README, API docs, etc.
- ✅ **Commit frequently**: Small logical commits
- ✅ **Code review new changes**: Even for bug fixes

### ❌ DON'T

- ❌ **Big bang refactoring**: Rewrite entire module at once
- ❌ **Ignore technical debt**: It compounds
- ❌ **Ship breaking changes**: Maintain backward compatibility
- ❌ **Skip tests on legacy code**: Higher risk area
- ❌ **Change tech stack without planning**: Costly
- ❌ **Deploy without testing**: Regression risk high
- ❌ **Ignore audit findings**: Security vulnerabilities especially

---

## 🔧 Troubleshooting

### Problema: "Code doesn't build after my changes"

**Soluție**:
1. Check compile errors in output
2. Review `/agent-os:implement-tasks` code review section
3. Fix issues locally, re-implement if needed
4. Use `/agent-os:review-code` for comprehensive audit

---

### Problema: "Refactoring too big"

**Soluție**:
1. Break into smaller phases
2. Each phase in separate PR/branch
3. Deploy incrementally
4. Validate each phase works

---

### Problema: "Unsure if change is safe"

**Soluție**:
1. Run `/agent-os:review-code` after implementing
2. Write tests (unit + integration)
3. Test in staging first
4. Monitor metrics after deploy

---

## 🔗 Linkuri Rapide

**Comenzi utilizate**:
- [`/agent-os:audit-deps`](../commands/audit-deps.md) - Dependency audit
- [`/agent-os:review-code`](../commands/review-code.md) - Code quality baseline
- [`/agent-os:analyze-refactoring`](../commands/analyze-refactoring.md) - Tech debt analysis
- [`/agent-os:plan-product`](../commands/plan-product.md) - Document existing product
- [`/agent-os:write-spec`](../commands/write-spec.md) - Feature/fix specification
- [`/agent-os:create-tasks`](../commands/create-tasks.md) - Task breakdown
- [`/agent-os:implement-tasks`](../commands/implement-tasks.md) - Implementation

**Optional**:
- [`/agent-os:update-spec`](../commands/update-spec.md) - Modify existing spec
- [`/agent-os:test-strategy`](../commands/test-strategy.md) - Test planning
- [`/agent-os:generate-docs`](../commands/generate-docs.md) - Auto-documentation
- [`/agent-os:rollback`](../commands/rollback.md) - Emergency recovery

---

## 📝 Checklist: Gata for Deploy?

### Pre-Audit (first time)
- [ ] `/agent-os:audit-deps` completed (fix critical vulns)
- [ ] `/agent-os:review-code` completed (baseline established)
- [ ] `/agent-os:analyze-refactoring` completed (tech debt identified)

### Per Feature/Fix
- [ ] `/agent-os:write-spec` completed + reviewed
- [ ] `/agent-os:create-tasks` completed + teams understand
- [ ] `/agent-os:implement-tasks` completed + tests pass
- [ ] Code review issues resolved
- [ ] `/agent-os:test-strategy` completed (optional)

### Pre-Deploy
- [ ] All tests passing (unit + integration + existing)
- [ ] Code review approved
- [ ] Documentation updated
- [ ] Merged to main branch
- [ ] Tagged release (optional)
- [ ] Tested in staging
- [ ] Ready for production ✅

---

**Gata? Start cu audit: `/agent-os:audit-deps` → `/agent-os:review-code` → [`/agent-os:plan-product`](../commands/plan-product.md)!** 🚀
