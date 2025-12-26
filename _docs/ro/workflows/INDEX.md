# Workflow-uri - Ghiduri Pas-cu-Pas

Aici veți găsi **ghiduri detaliate** pentru cum să utilizați Agent OS în diferite scenarii: proiecte noi și proiecte existente.

## 📚 Workflow-uri Disponibile

### 1. [Proiecte NOI](./proiecte-noi.md)

Construiești o aplicație **de la zero**. Workflow complet de la planning la implementare.

**Timp**: 2-3 săptămâni pentru feature-uri MVP

**Faze**:
1. **Planning** (`/agent-os:plan-product`) - Define vision, roadmap, tech stack
2. **Specification** (`/agent-os:write-spec`) - Document requirements
3. **Task Breakdown** (`/agent-os:create-tasks`) - Split into tasks
4. **Implementation** (`/agent-os:implement-tasks` or `/agent-os:orchestrate-tasks`) - Code it
5. **QA & Documentation** (`/agent-os:test-strategy`, `/agent-os:generate-docs`) - Polish

**Best for**: Startup projects, new ideas, greenfield development

---

### 2. [Proiecte EXISTENTE](./proiecte-existente.md)

Adăugi feature-uri sau refactorizezi **codul existent**. Workflow special pentru legacy/mature projects.

**Timp**: Depinde de task (audit 2-4 ore, feature 3-5 zile)

**Faze**:
1. **Audit** (`/agent-os:audit-deps`, `/agent-os:review-code`, `/agent-os:analyze-refactoring`) - Understand current state
2. **Planning** - Document reverse-engineered mission/roadmap
3. **Feature/Fix** (`/agent-os:write-spec` → `/agent-os:implement-tasks`) - Add or fix
4. **QA & Refactor** - Test thoroughly, refactor if needed

**Best for**: Adding features to existing apps, bug fixes, refactoring

---

## 🎯 Alegere Rapidă

### Am proiect NOU?
➡️ [Workflow Proiecte Noi](./proiecte-noi.md)

### Am proiect EXISTENT?
➡️ [Workflow Proiecte Existente](./proiecte-existente.md)

---

## 📊 Tabel Comparativ

| Aspect | Proiect Nou | Proiect Existent |
|--------|-------------|------------------|
| **Start point** | Idea only | Codebase exists |
| **First steps** | `/agent-os:plan-product` | `/agent-os:audit-deps`, `/agent-os:review-code` |
| **Tech stack** | Choose freely | Adapt to existing |
| **Planning effort** | High (mission from scratch) | Medium (document existing) |
| **Implementation** | Greenfield (faster) | Legacy awareness (slower) |
| **Best for** | Startups, new ideas | Adding features, refactoring |

---

## 🚀 Exemplu: TaskFlow App

### Scenariul 1: Nou Proiect (Start from idea)

```
Week 1:
1. /agent-os:plan-product              (mission, roadmap, tech)
2. /agent-os:write-spec feature1       (user registration)
3. /agent-os:create-tasks feature1
4. /agent-os:implement-tasks feature1
5. /agent-os:test-strategy

Week 2-3:
6. /agent-os:write-spec feature2       (task management)
7. /agent-os:create-tasks feature2
8. /agent-os:implement-tasks feature2
9. /agent-os:generate-docs
10. Deploy MVP
```

**Workflow**: [Proiecte Noi](./proiecte-noi.md)

---

### Scenariul 2: Proiect Existent (Codebase exists)

```
Day 1:
1. /agent-os:audit-deps                (what's the health?)
2. /agent-os:review-code               (baseline code quality)
3. /agent-os:analyze-refactoring       (technical debt?)

Day 2:
4. /agent-os:write-spec new-feature    (task export)
5. /agent-os:create-tasks
6. /agent-os:implement-tasks
7. Merge + deploy

Day 3-4:
8. /agent-os:test-strategy
9. /agent-os:generate-docs (update)
10. Follow-up release
```

**Workflow**: [Proiecte Existente](./proiecte-existente.md)

---

## 📖 Cum să Citești

### Pentru Proiect NOU
1. ✅ Citeste [Quick Start](../quick-start.md) (5 min)
2. ✅ Citeste [Proiecte Noi](./proiecte-noi.md) (20 min)
3. ✅ Citeste comenzile pe care le vei folosi (plan-product, write-spec, etc.)
4. ✅ Executa comenzile în ordine

### Pentru Proiect EXISTENT
1. ✅ Citeste [Quick Start](../quick-start.md) (5 min)
2. ✅ Citeste [Proiecte Existente](./proiecte-existente.md) (20 min)
3. ✅ Executa audit commands
4. ✅ Citeste comenzile pentru feature-urile pe care le adaugi
5. ✅ Executa plan + implement commands

---

## 🔗 Linkuri Rapide

**Comenzi Core**:
- [`/agent-os:plan-product`](../commands/plan-product.md)
- [`/agent-os:write-spec`](../commands/write-spec.md)
- [`/agent-os:create-tasks`](../commands/create-tasks.md)
- [`/agent-os:implement-tasks`](../commands/implement-tasks.md)

**Comenzi Suport**:
- [`/agent-os:audit-deps`](../commands/audit-deps.md)
- [`/agent-os:review-code`](../commands/review-code.md)
- [`/agent-os:analyze-refactoring`](../commands/analyze-refactoring.md)

**Toate Comenzile**: [`Commands INDEX`](../commands/INDEX.md)

---

**Gata? Selectează workflow-ul tău și mergi!** 🚀
