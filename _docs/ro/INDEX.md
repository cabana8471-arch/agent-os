# Documentația Agent OS în Limba Română

Bine venit! Aici găsești ghiduri complete organizate pe comenzi, workflow-uri și concepte.

## 🚀 Puncte de Start

### 1. [Quick Start](./quick-start.md) (5-10 minute)

Onboarding rapid: instalare, prima comandă, ready to go.

**Alegeți rapid**: Proiect nou sau existent? Start here!

---

### 2. [Comenzi Complete](./commands/INDEX.md) (16 comenzi documentate)

**Referință detaliată** pentru fiecare comandă Agent OS.

Cuprinde:
- Ce face comanda
- Când să o folosești
- Exemplu complet
- Troubleshooting
- Comenzi legate

**Comenzi Core**: `/agent-os:plan-product`, `/agent-os:write-spec`, `/agent-os:create-tasks`, `/agent-os:implement-tasks`, `/agent-os:orchestrate-tasks`

**Comenzi Extended**: `/agent-os:shape-spec`, `/agent-os:verify-spec`, `/agent-os:update-spec`, `/agent-os:review-code`, `/agent-os:test-strategy`, `/agent-os:generate-docs`, `/agent-os:audit-deps`, `/agent-os:analyze-refactoring`, `/agent-os:analyze-features`, `/agent-os:rollback`, `/agent-os:improve-skills`

---

### 3. [Workflow-uri](./workflows/INDEX.md) (ghiduri step-by-step)

**Două workflow-uri principale**:

1. **[Proiecte Noi](./workflows/proiecte-noi.md)** - De la idee la produs live
   - Planning → Specification → Tasks → Implement → Deploy

2. **[Proiecte Existente](./workflows/proiecte-existente.md)** - Audit → Feature/Fix → Deploy
   - Audit dependencies, code review, refactoring
   - Feature development în codebase existent

---

### 4. [Concepte](./concepts/INDEX.md) (înțelegere profundă)

Pentru cei curioși care vor să înțeleagă mai mult:

- **[Single-Agent vs Multi-Agent](./concepts/single-vs-multi-agent.md)** - Care să alegi?
- **[Cei 14 Agenți](./concepts/agenti.md)** - Cum funcționează Agent OS?
- **[Standards System](./concepts/standards.md)** - Code quality framework
- **[Best Practices](./concepts/best-practices.md)** - Do's and don'ts

---

## 🎯 Alegere Rapidă

| Caz | Acțiune |
|-----|---------|
| **Nu știu de unde să încep** | [Quick Start](./quick-start.md) (5 min) |
| **Am proiect NOU** | [Workflow Proiecte Noi](./workflows/proiecte-noi.md) |
| **Am proiect EXISTENT** | [Workflow Proiecte Existente](./workflows/proiecte-existente.md) |
| **Vreau să înțeleg o comandă specifică** | [Comenzi INDEX](./commands/INDEX.md) → alege comanda |
| **Vreau să learn deeper** | [Concepte INDEX](./concepts/INDEX.md) |

---

## 📚 Structura Documentației

```
_docs/ro/
├── INDEX.md (tu ești aici!)
├── quick-start.md (5-10 min onboarding)
│
├── commands/                      # Referință completă comenzi
│   ├── INDEX.md
│   ├── plan-product.md
│   ├── shape-spec.md
│   ├── write-spec.md
│   ├── verify-spec.md
│   ├── create-tasks.md
│   ├── implement-tasks.md
│   ├── orchestrate-tasks.md
│   ├── update-spec.md
│   ├── review-code.md
│   ├── test-strategy.md
│   ├── generate-docs.md
│   ├── audit-deps.md
│   ├── analyze-refactoring.md
│   └── rollback.md
│
├── workflows/                     # Ghiduri step-by-step
│   ├── INDEX.md
│   ├── proiecte-noi.md          # Plan → Spec → Code → Deploy
│   └── proiecte-existente.md    # Audit → Feature → Deploy
│
└── concepts/                      # Concepte avansate
    ├── INDEX.md
    ├── single-vs-multi-agent.md
    ├── agenti.md
    ├── standards.md
    └── best-practices.md
```

---

## ✨ Ce-i Nou în Documentația Asta?

### Vs Ghidurile Vechi

**Vechi**: 2 ghiduri lungi (1000+ linii fiecare)
- Pro: Complet, exemplu consistent (TaskFlow)
- Con: Lung, greu de navigat, comandă neclară

**NOU**: Modular, documentație scurtă, command-focused
- ✅ Quick Start (5 min onboarding)
- ✅ Comenzi documentate individual (300-500 linii fiecare)
- ✅ Workflow-uri concise (400 linii, action-oriented)
- ✅ Concepte separate (aprofundare pentru cei interesați)
- ✅ Ușor să navighezi (INDEX files peste tot)

### De Citit Dacă...

| Situație | Citește |
|----------|----------|
| "Nu știu cum să start" | [Quick Start](./quick-start.md) |
| "Care-i diferența single vs multi?" | [Single-Agent vs Multi-Agent](./concepts/single-vs-multi-agent.md) |
| "Ce face `/agent-os:write-spec` exact?" | [`/agent-os:write-spec`](./commands/write-spec.md) |
| "Care-i workflow pentru proiect nou?" | [Workflow Proiecte Noi](./workflows/proiecte-noi.md) |
| "Cum se aplică standards?" | [Standards System](./concepts/standards.md) |
| "Cum funcționează Agent OS?" | [Cei 14 Agenți](./concepts/agenti.md) |

---

## 🚀 Recomandări

### Nivel 1: Beginner (0-1 ora)
1. ✅ [Quick Start](./quick-start.md) - 5-10 min
2. ✅ Alege workflow: [Noi](./workflows/proiecte-noi.md) sau [Existente](./workflows/proiecte-existente.md) - 20-30 min
3. ✅ Start cu `/agent-os:plan-product`

### Nivel 2: Intermediate (1-3 ore)
4. ✅ Citeste comenzile pe care le folosești - 1-2 ore
5. ✅ [Single-Agent vs Multi-Agent](./concepts/single-vs-multi-agent.md) - 15 min
6. ✅ [Best Practices](./concepts/best-practices.md) - 20-30 min

### Nivel 3: Advanced (3+ ore)
7. ✅ [Cei 14 Agenți](./concepts/agenti.md) - 30 min
8. ✅ [Standards System](./concepts/standards.md) - 15-20 min
9. ✅ Citire detaliată toate comenzile - 2+ ore

---

## 💬 Feedback

Dacă ai feedback la documentație:
- GitHub: [Issues](https://github.com/buildermethods/agent-os/issues)
- Claude Code: `/help`

---

## 🎯 Pași Următori

**Ți-e clar unde să mergi?**

- ✅ Da → Mergi la secțiunea aleasă (Quick Start, Commands, Workflows, Concepts)
- ❓ Nu → [Quick Start](./quick-start.md) - 5 minute clarity

---

**Bun venit! Alege ruta și pornim!** 🚀

[Quick Start](./quick-start.md) | [Comenzi](./commands/INDEX.md) | [Workflows](./workflows/INDEX.md) | [Concepte](./concepts/INDEX.md)
