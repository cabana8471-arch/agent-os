# Comenzi Agent OS - Referință Completă

Agent OS pune la dispoziție **16 comenzi principale** organizate în 3 categorii: planificare, implementare și suport extins.

## 🎯 Comenzi Core Development (6)

Acestea sunt comenzile pe care le vei folosi **cel mai frecvent** și în ordine secvențială pentru a construi o feature de la zero.

| # | Comandă | Ce Face | Workflow-uri | Agenti |
|---|---------|---------|--------------|--------|
| 1 | **[`/agent-os:plan-product`](./agent-os:plan-product.md)** | 🎯 Planificare mission, roadmap, tech stack | gather-product-info, create-product-mission, create-product-roadmap, create-product-tech-stack | product-planner |
| 2 | **[`/agent-os:shape-spec`](./agent-os:shape-spec.md)** | 📐 Inițializare și clarificare cerințe | initialize-spec, research-spec | spec-initializer, spec-shaper |
| 3 | **[`/agent-os:write-spec`](./agent-os:write-spec.md)** | 📋 Scriere specification tehnic detaliat | write-spec | spec-writer |
| 4 | **[`/agent-os:create-tasks`](./agent-os:create-tasks.md)** | ✂️ Descompunere spec în task-uri | create-tasks-list | tasks-list-creator |
| 5 | **[`/agent-os:implement-tasks`](./agent-os:implement-tasks.md)** | 💻 Implementare task-uri cu code review | implement-tasks, code-review, verification | implementer, code-reviewer, implementation-verifier |
| 6 | **[`/agent-os:orchestrate-tasks`](./orchestrate-tasks.md)** | 🚀 Orchestrare multi-agent complexă | implement-tasks, compile-implementation-standards | implementer (paralel), code-reviewer |

### Fluxul Tipic (Faza 1-5)

```
1. /agent-os:plan-product       ← Definiți vision
      ↓
2. /agent-os:shape-spec        ← Clarificați feature (opțional, dacă cerințe neclare)
      ↓
3. /agent-os:write-spec        ← Scrieți specification detaliat
      ↓
4. /agent-os:create-tasks      ← Descompuneți în task-uri
      ↓
5. /agent-os:implement-tasks   ← Implementați (iterativ pe fiecare task)
    sau
   /agent-os:orchestrate-tasks ← Implementați (paralel, pentru feature mare)
```

---

## 🔧 Comenzi Extended Support (10)

Acestea sunt comenzi **opționale și complementare** pe care le folosești în situații specifice: verificare calitate, refactoring, documentație, etc.

| # | Comandă | Ce Face | Când să Folosești | Workflow-uri | Agent |
|---|---------|---------|------------------|--------------|-------|
| 7 | **[`/agent-os:verify-spec`](./agent-os:verify-spec.md)** | ✅ Verificare completitudine spec | Înainte de implementare, pentru audit | verify-spec | spec-verifier |
| 8 | **[`/agent-os:update-spec`](./agent-os:update-spec.md)** | 📝 Actualizare spec după planning/changes | Modificări cerințe, user feedback | update-spec | spec-writer |
| 9 | **[`/agent-os:review-code`](./agent-os:review-code.md)** | 🔍 Code review deep (security, quality) | Audit security, baseline review | code-review | code-reviewer |
| 10 | **[`/agent-os:test-strategy`](./agent-os:test-strategy.md)** | 🧪 Design plan teste și coverage analysis | Înainte de QA, pentru coverage gaps | test-strategy | test-strategist |
| 11 | **[`/agent-os:generate-docs`](./agent-os:generate-docs.md)** | 📚 Auto-generare API docs, README, changelog | După implementare, pentru documentație | generate-docs | documentation-writer |
| 12 | **[`/agent-os:audit-deps`](./agent-os:audit-deps.md)** | 🔐 Security audit dependențe | Pe proiecte existente, audit periodic | dependency-audit | dependency-manager |
| 13 | **[`/agent-os:analyze-refactoring`](./agent-os:analyze-refactoring.md)** | 🏗️ Analiză technical debt și refactoring | Pe proiecte existente, înainte de migration | refactoring-analysis | refactoring-advisor |
| 14 | **[`/agent-os:rollback`](./rollback.md)** | ↩️ Revert la versiune anterioară | După deploy eșuat, urgent recovery | rollback | implementer |
| 15 | **[`/agent-os:analyze-features`](./analyze-features.md)** | 🔍 Descoperire features, propuneri, duplicate check | Onboarding, planning, înainte de spec | feature-analysis | feature-analyst |
| 16 | **[`/agent-os:improve-skills`](./improve-skills.md)** | ⚡ Îmbunătățire Claude Code Skills descriptions | După instalare, periodic | - | - |

---

## 📊 Tabel Comparativ - Când să Folosești

### Proiect NOU (recomandare)

```
Pas 1: /agent-os:plan-product
Pas 2: /agent-os:write-spec (sau /agent-os:shape-spec → /agent-os:write-spec)
Pas 3: /agent-os:create-tasks
Pas 4: /agent-os:implement-tasks (pentru feature mică)
       SAU /agent-os:orchestrate-tasks (pentru feature mare)
Pas 5 (opțional): /agent-os:test-strategy + /agent-os:generate-docs
```

### Proiect EXISTENT (recomandare)

```
Pasul 1: /agent-os:analyze-features (discover existing features) ← NOU!
Pasul 2: /agent-os:audit-deps (audit inițial)
Pasul 3: /agent-os:review-code (baseline review)
Pasul 4: /agent-os:analyze-refactoring (identificare tech debt)
Pasul 5: /agent-os:analyze-features --mode check-duplicate (verifică înainte de spec)
Pasul 6: /agent-os:write-spec (pentru feature nouă sau bug fix)
Pasul 7: /agent-os:create-tasks → /agent-os:implement-tasks
Pasul 8 (opțional): /agent-os:test-strategy + /agent-os:generate-docs
```

### Refactoring Mare

```
Pasul 1: /agent-os:analyze-refactoring
Pasul 2: /agent-os:write-spec (plan refactoring)
Pasul 3: /agent-os:create-tasks (pe porții)
Pasul 4: /agent-os:implement-tasks (incremental)
Pasul 5: /agent-os:review-code (validate changes)
```

---

## 🔀 Single-Agent vs Multi-Agent

### Toate comenzile au 2 variante:

**Single-Agent Mode**
- ✅ Mai simplu, mai puțini parametri
- ✅ Potrivit pentru feature mică-medie
- ❌ Lent pentru task-uri complexe (30-60 min pe comandă)

**Multi-Agent Mode** (când disponibil)
- ✅ Multi-parallelizare (3-5x mai rapid)
- ✅ Agenti specializați pe fiecare fază
- ❌ Mai complex, mai mulți parametri
- ❌ Nu disponibil pentru `/agent-os:orchestrate-tasks`

### Alegere Rapidă
- **Proiect mic** (1-5 feature-uri): Single-Agent
- **Proiect mare** (10+ feature-uri): Multi-Agent
- **Urgent**: Multi-Agent (mai rapid)

**Citește detaliu**: [Single-Agent vs Multi-Agent](../concepts/single-vs-multi-agent.md)

---

## 📖 Cum să Citești Documentația Unei Comenzi

Fiecare fișier de comandă (ex: `plan-product.md`) conține:

1. **📋 Ce Face** - Descriere scurtă (1-2 paragrafe)
2. **✅ Când să Folosești** - 3-4 scenarii specifice
3. **❌ Când SĂ NU Folosești** - Anti-patterns
4. **🔀 Variante Disponibile** - Single vs Multi-Agent
5. **📥 Input Necesar** - Pre-condiții și checklist
6. **📤 Output Generat** - Fișiere și informații
7. **💡 Exemplu Complet** - Pas-cu-pas cu TaskFlow
8. **⚙️ Opțiuni Avansate** - Flags și customizări
9. **🔧 Troubleshooting** - Probleme și soluții
10. **🔗 Comenzi Legate** - Înainte/După
11. **📚 Resurse Tehnice** - Workflow-uri și agenti
12. **💭 Best Practices** - Recomandări și anti-patterns

---

## 🎓 Ordinea Lecturii (Recomandare)

### Pentru Proiect NOU

1. ✅ [Quick Start](../quick-start.md) (5 min)
2. ✅ [Workflow Proiecte Noi](../workflows/proiecte-noi.md) (15 min)
3. ✅ `/agent-os:plan-product` - citire detaliu
4. ✅ `/agent-os:write-spec` - citire detaliu
5. ✅ `/agent-os:create-tasks` - citire detaliu
6. ✅ `/agent-os:implement-tasks` - citire detaliu
7. ⚠️ `/agent-os:test-strategy` - citire opțională
8. ⚠️ `/agent-os:generate-docs` - citire opțională

### Pentru Proiect EXISTENT

1. ✅ [Quick Start](../quick-start.md) (5 min)
2. ✅ [Workflow Proiecte Existente](../workflows/proiecte-existente.md) (15 min)
3. ✅ `/agent-os:audit-deps` - citire detaliu
4. ✅ `/agent-os:review-code` - citire detaliu
5. ✅ `/agent-os:analyze-refactoring` - citire detaliu
6. ✅ `/agent-os:write-spec` - citire detaliu
7. ✅ `/agent-os:implement-tasks` - citire detaliu
8. ⚠️ Restul - citire opțională

### Pentru Deep Dive (Architect/Lead)

1. ✅ [Concepte - Agenti](../concepts/agenti.md) (20 min)
2. ✅ [Concepte - Standards](../concepts/standards.md) (10 min)
3. ✅ [Concepte - Single vs Multi-Agent](../concepts/single-vs-multi-agent.md) (15 min)
4. ✅ Toate comenzile - citire detaliu (2-3 ore)

---

## 🚀 Comenzi după Fază

### PLANNING PHASE

**Comenzi**:
- [`/agent-os:plan-product`](./agent-os:plan-product.md) ← START

**Output**: mission.md, roadmap.md, tech-stack.md

---

### SPECIFICATION PHASE

**Comenzi** (în ordine):
1. [`/agent-os:shape-spec`](./agent-os:shape-spec.md) (opțional, doar dacă cerințe neclare)
2. [`/agent-os:write-spec`](./agent-os:write-spec.md) (mandatory)
3. [`/agent-os:verify-spec`](./agent-os:verify-spec.md) (opțional, pentru audit)

**Output**: specification.md, verification-report.md

---

### IMPLEMENTATION PHASE

**Comenzi** (alegeți una):
- [`/agent-os:implement-tasks`](./agent-os:implement-tasks.md) ← Pentru feature mică/medie (task cu task)
- [`/agent-os:orchestrate-tasks`](./agent-os:orchestrate-tasks.md) ← Pentru feature mare (paralel)

**Suport** (opțional, înainte sau după):
- [`/agent-os:test-strategy`](./agent-os:test-strategy.md) ← Planning teste
- [`/agent-os:review-code`](./agent-os:review-code.md) ← Deep audit code

**Output**: cod, code-review.md, verification-report.md

---

### MAINTENANCE PHASE (proiecte existente)

**Comenzi** (alegeți ce aveți nevoie):
- [`/agent-os:analyze-features`](./analyze-features.md) ← **Feature discovery & proposals** (NOU!)
- [`/agent-os:audit-deps`](./agent-os:audit-deps.md) ← Audit dependențe
- [`/agent-os:review-code`](./agent-os:review-code.md) ← Baseline review
- [`/agent-os:analyze-refactoring`](./agent-os:analyze-refactoring.md) ← Technical debt
- [`/agent-os:update-spec`](./agent-os:update-spec.md) ← Update cerințe
- [`/agent-os:generate-docs`](./agent-os:generate-docs.md) ← Auto-docs
- [`/agent-os:rollback`](./agent-os:rollback.md) ← Emergency recovery

**Output**: feature-analysis.md, audit-report.md, code-review.md, refactoring-analysis.md, etc.

---

## 📞 Troubleshooting Common

### Comanda X nu merge
**Soluție**:
1. Verifică [Troubleshooting din fișierul comenzii](./agent-os:plan-product.md)
2. Verifică `config.yml` și `standards/`
3. Verifică output din [workflow-ul corespunzător](../../profiles/default/workflows/)

### Nu știu ce comandă să folosesc
**Soluție**:
- [Workflow Proiecte Noi](../workflows/proiecte-noi.md) - o-step guidance
- [Workflow Proiecte Existente](../workflows/proiecte-existente.md) - step-by-step guidance

### Vreau să refactorizez
**Soluție**:
1. Execută [`/agent-os:analyze-refactoring`](./agent-os:analyze-refactoring.md)
2. Urmează recomandări din raport
3. Folosiți `/agent-os:implement-tasks` pe task-uri refactoring

---

## 🔗 Linkuri Rapid

### Comenzi Core (ÎNCEPEȚI AICI)
- [`/agent-os:plan-product`](./agent-os:plan-product.md) - Planificare
- [`/agent-os:write-spec`](./agent-os:write-spec.md) - Specification
- [`/agent-os:create-tasks`](./agent-os:create-tasks.md) - Task breakdown
- [`/agent-os:implement-tasks`](./agent-os:implement-tasks.md) - Implementation

### Comenzi Extended
- [`/agent-os:shape-spec`](./agent-os:shape-spec.md), [`/agent-os:verify-spec`](./agent-os:verify-spec.md), [`/agent-os:update-spec`](./agent-os:update-spec.md)
- [`/agent-os:review-code`](./agent-os:review-code.md), [`/agent-os:test-strategy`](./agent-os:test-strategy.md), [`/agent-os:generate-docs`](./agent-os:generate-docs.md)
- [`/agent-os:audit-deps`](./audit-deps.md), [`/agent-os:analyze-refactoring`](./analyze-refactoring.md), [`/agent-os:rollback`](./rollback.md)
- [`/agent-os:analyze-features`](./analyze-features.md), [`/agent-os:improve-skills`](./improve-skills.md)

### Workflows & Concepte
- [Workflow Proiecte Noi](../workflows/proiecte-noi.md)
- [Workflow Proiecte Existente](../workflows/proiecte-existente.md)
- [Concepte](../concepts/INDEX.md)
- [Main Index](../INDEX.md)

---

**Gata să pornești? Alege o comandă de mai sus și citește documentația sa!** 🚀
