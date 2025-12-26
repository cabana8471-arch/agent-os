# Workflow: Proiecte NOI

Construiești o aplicație **de la zero**. Workflow step-by-step pentru a merge de la idee la produs live.

---

## 🚀 Quick Overview

```
Fase 1: Planning
  └─ /agent-os:plan-product → mission.md, roadmap.md, tech-stack.md

Fase 2: Specification
  └─ /agent-os:write-spec → specification.md (per feature)

Fase 3: Task Breakdown
  └─ /agent-os:create-tasks → tasks.md (per feature)

Fase 4: Implementation
  └─ /agent-os:implement-tasks OR /agent-os:orchestrate-tasks → code + review

Fase 5: QA & Release
  └─ /agent-os:test-strategy, /agent-os:generate-docs → ready to ship
```

**Timeline**: 2-6 săptămâni (depinde de feature-uri)

---

## ⚙️ Setup Inițial

### 1. Base Installation (O singură dată pe mașina ta)

Dacă nu ai instalat Agent OS pe mașina ta, execută:

```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash
```

Aceasta creează `~/agent-os` cu profilurile și scripturile de bază.

**Pentru Windows**: Deschide [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) sau [Git Bash](https://git-scm.com/download/win), apoi rulează comanda de mai sus.

### 2. Crează Proiect

```bash
mkdir my-project && cd my-project
git init

# Optional: Create basic README
echo "# My Project" > README.md
git add README.md
git commit -m "Initial commit"
```

### 3. Instalează Agent OS în Proiect

```bash
# Run installer
~/agent-os/scripts/project-install.sh

# Review generated files
ls agent-os/
```

### 4. Configurare (opțional)

Edit `agent-os/config.yml`:
```yaml
version: "1.0"
claude_code_commands: true
use_claude_code_subagents: false  # Or true for bigger projects
profile: "default"
```

### 5. Selectează Tech Stack Profile (opțional)

Dacă proiectul tău folosește un tech stack specific, poți folosi un **profile personalizat** cu conventions potrivite:

```bash
# Django backend
./scripts/project-install.sh --profile django-api

# Rails backend
./scripts/project-install.sh --profile rails-api

# React frontend
./scripts/project-install.sh --profile react-app

# Node CLI tool
./scripts/project-install.sh --profile node-cli

# Custom profile
./scripts/project-install.sh --profile general
```

**Beneficiu**: Standardurile și convențiile se adapteaza automaticamente la tech stack-ul tău.

📖 **Citeste mai mult**: [Profiles - Tech Stack Customization](../concepts/profiles.md)

---

## Faza 1: Planning - Define Vision

### Ce se întâmplă?

Definiți:
- Ce problem rezolviți? (mission)
- Care sunt feature-uri pe roadmap? (phasing)
- Ce tech stack folosiți? (tech decisions)

### Execuție

```bash
/agent-os:plan-product
```

**Agentul va întreba**:
- Care e problema pe care o rezolviți?
- Cine sunt utilizatorii?
- Care sunt top 3 feature-uri MVP?
- Ce tech stack prefer?

**Răspunde** cu cât mai mult detaliu.

### Output

Agentul creează:
- ✅ `agent-os/product/mission.md` - Mission statement
- ✅ `agent-os/product/roadmap.md` - Phased feature list
- ✅ `agent-os/product/tech-stack.md` - Tech decisions

### What's Next?

Citește output-urile, validate cu team, merge la Faza 2.

---

## Faza 2: Specification - Document Requirements

### Ce se întâmplă?

Scrieți specification **detaliat** pentru prima feature din MVP.

### Execuție

```bash
/agent-os:write-spec --feature "Feature Name"
```

**Exemplu**: `/agent-os:write-spec --feature "User Registration"`

**Agentul va crea**:
- Acceptance criteria (ce trebuie să funcționeze)
- API endpoints (request/response examples)
- Data model (database schema)
- Error handling (edge cases)

### De repetat pentru fiecare feature

MVP avea 3-5 feature-uri? Repeti `/agent-os:write-spec` pentru fiecare:
1. User Registration
2. Task Management
3. Real-time Notifications
4. (optionally more)

### Output per feature

- ✅ `agent-os/specs/[feature]/specification.md`

### Opțional: Verify Spec

Dacă spec e complex, verifica-l înainte de implementare:

```bash
/agent-os:verify-spec --spec "agent-os/specs/feature-name/specification.md"
```

---

## Faza 3: Task Breakdown - Plan Implementation

### Ce se întâmplă?

Transformă specification în task-uri concrete.

### Execuție

```bash
/agent-os:create-tasks --spec "agent-os/specs/feature-name/specification.md"
```

### Output

- ✅ `agent-os/specs/[feature]/implementation/tasks.md` - List of 5-15 tasks
- ✅ Dependencies, story points, timeline

### De repetat

Repeti pentru fiecare feature din MVP.

---

## Faza 4: Implementation - Write Code

### Ce se întâmplă?

Implementezi task-uri cu **automatic code review și testing**.

### Alegere: Sequential vs Parallel?

#### Sequential (/agent-os:implement-tasks)
**Când**: Feature small-medium (< 20 SP), single developer

```bash
/agent-os:implement-tasks --feature "Feature Name"
```

**Proces**: Task 1 → code + review + verify → Task 2 → ... → Done

**Timp**: 2-4 ore per feature

---

#### Parallel (/agent-os:orchestrate-tasks)
**Când**: Feature mare (20+ SP), multiple developers

```bash
/agent-os:orchestrate-tasks --feature "Feature Name"
```

**Proces**: Analyze task dependencies → delegate smart parallelization → sync results

**Timp**: 1-2 ore (faster than sequential)

---

### Iterație

```bash
# Feature 1: User Registration
/agent-os:implement-tasks --feature "User Registration"

# Feature 2: Task Management
/agent-os:implement-tasks --feature "Task Management"

# Feature 3: Notifications
/agent-os:implement-tasks --feature "Real-time Notifications"
```

### Output per feature

- ✅ Code in your repository
- ✅ `code-review.md` - Review findings
- ✅ `verification-report.md` - Tests passed, spec met

### Tipuri de Review Output

```
CRITICAL: SQL injection risk
HIGH: Performance issue (N+1 query)
MEDIUM: Missing error handling
LOW: Code style inconsistency
```

**Action**: Fix CRITICAL + HIGH issues before merge.

---

## Faza 5: QA & Release

### Optional: Test Strategy

Design test plan:

```bash
/agent-os:test-strategy --feature "Feature Name"
```

Output:
- Unit test recommendations
- Integration test checklist
- E2E test scenarios
- Coverage gaps

---

### Documentation

Auto-generate docs:

```bash
/agent-os:generate-docs
```

Output:
- ✅ `docs/api.md` - API documentation
- ✅ `docs/setup.md` - Development setup
- ✅ `README.md` - Quick start

---

### Deploy to Production

1. ✅ All features implemented
2. ✅ All tests passing
3. ✅ Code reviews resolved
4. ✅ Documentation updated
5. ✅ Merge to main, tag release
6. ✅ Deploy

---

## 📊 Timeline Estimat

| Faza | Time | Activities |
|------|------|-----------|
| **Setup** | 30 min | Install Agent OS, configure |
| **Planning** | 1-2 h | `/agent-os:plan-product` |
| **Spec (per feature)** | 1 h | `/agent-os:write-spec` × 3 features |
| **Tasks (per feature)** | 30 min | `/agent-os:create-tasks` × 3 features |
| **Implement (per feature)** | 8 h | `/agent-os:implement-tasks` × 3 features |
| **QA & Docs** | 2-3 h | `/agent-os:test-strategy`, `/agent-os:generate-docs` |
| **Deploy** | 1 h | Tag, deploy, monitor |
| **TOTAL MVP** | 16-20 h | 2-3 days for one person |

---

## 💡 Best Practices

### ✅ DO

- ✅ **Start simple**: MVP cu 3-4 feature-uri, nu 10+
- ✅ **Follow workflow**: Plan → Spec → Tasks → Implement (în ordine)
- ✅ **Iterate per feature**: Spec one feature, implement one feature
- ✅ **Review thoroughly**: Read code review findings, fix issues
- ✅ **Test before deploy**: Run tests, verify spec met
- ✅ **Document as you go**: Commit messages, README updates
- ✅ **Commit frequently**: 1 commit per task, not 1 big commit

### ❌ DON'T

- ❌ **Skip planning**: "Let's just code!" → chaos
- ❌ **Write spec alone**: Get input from team/users
- ❌ **Implement without spec**: Wasted effort
- ❌ **Ignore code review**: These are bugs/security issues
- ❌ **Ship untested code**: Test before production
- ❌ **Big bang features**: Break into smaller pieces
- ❌ **Mess with config.yml**: Use defaults unless you know

---

## 🔧 Troubleshooting

### Problema: "Comanda X se blocheaza"

**Soluție**:
1. Wait longer (sometimes they take time)
2. Check error message in console
3. Review spec/task list - is it clear?
4. See command's troubleshooting section

---

### Problema: "Output nu e bun"

**Soluție**:
1. Provides more context in next run: "Add context: ..."
2. Request specific output: `--include-database-schema`
3. Check similar examples in command's "Exemplu Complet" section

---

### Problema: "Ne-am pierdut pe drum"

**Soluție**:
- Review [Commands INDEX](../commands/INDEX.md)
- Re-read workflow mai attentive
- Go back one step, verify output OK

---

## 🔗 Linkuri Rapide

**Comenzi folosite**:
- [`/agent-os:plan-product`](../commands/plan-product.md) - Planning phase
- [`/agent-os:write-spec`](../commands/write-spec.md) - Specification phase
- [`/agent-os:create-tasks`](../commands/create-tasks.md) - Task breakdown
- [`/agent-os:implement-tasks`](../commands/implement-tasks.md) - Implementation
- [`/agent-os:orchestrate-tasks`](../commands/orchestrate-tasks.md) - Parallel implementation
- [`/agent-os:test-strategy`](../commands/test-strategy.md) - Test planning (optional)
- [`/agent-os:generate-docs`](../commands/generate-docs.md) - Auto-documentation (optional)

**Alte comenzi**:
- [`/agent-os:verify-spec`](../commands/verify-spec.md) - Spec audit (optional)
- [`/agent-os:review-code`](../commands/review-code.md) - Deep code review (optional)

---

## 📝 Checklist: Gata pt Launch?

- [ ] `/agent-os:plan-product` completed (mission, roadmap, tech-stack)
- [ ] `/agent-os:write-spec` completed for all MVP features (3-5)
- [ ] `/agent-os:create-tasks` completed for all features
- [ ] `/agent-os:implement-tasks` completed for all features
- [ ] Code review issues resolved
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Merged to main branch
- [ ] Tagged release
- [ ] Deployed to staging
- [ ] User testing OK
- [ ] Deployed to production ✅

---

**Gata? Start cu `/agent-os:plan-product` și merge!** 🚀

```bash
/agent-os:plan-product
```
