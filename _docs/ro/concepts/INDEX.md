# Concepte - Înțelegere Profundă

Aceasta e secțiunea pentru a **înțelege mai aprofundat** cum funcționează Agent OS: arhitectura, agenti, design decisions.

**Pentru cine**: Architects, leads, sau persoane curioase care vor să înțeleagă mai mult.

---

## 📚 Concepte Disponibile

### 1. [Single-Agent vs Multi-Agent](./single-vs-multi-agent.md)

Cum alegi între modurile **single-agent** și **multi-agent**?

**Cuprinde**:
- Ce e diferența? (sequential vs parallel)
- Performance comparison (time, cost)
- Când să folosești ce?
- Exemplu TaskFlow

**Citește când**: Ales între /agent-os:implement-tasks single vs multi, sau optimize pentru budget/time

---

### 2. [Agenti - Cei 14 AI Specialists](./agenti.md)

Agent OS are **14 agenți specializați** pentru diferite sarcini.

**Cuprinde**:
- Toți 14 agenții explicați
- Ce fiecare agent face?
- Tools available pe fiecare
- Model assignment (opus vs sonnet vs haiku)
- Când Agent OS delegă la care agent?

**Citește când**: Vrei să înțelegi cum Agent OS funcționează "behind the scenes"

---

### 3. [Standards - Coding Standards System](./standards.md)

Agent OS impune **standards** pentru code quality, style, security.

**Cuprinde**:
- 4 categorii de standards (global, backend, frontend, testing)
- Cum se aplică în development?
- Cum să customizezi standards?
- Standards ca Claude Code Skills

**Citește când**: Vrei să standardizezi codul, sa setezi reguli custom

---

### 4. [Best Practices](./best-practices.md)

Lessons learned și **best practices** din experience cu Agent OS.

**Cuprinde**:
- Development workflow best practices
- Commit strategy
- Error handling patterns
- When to refactor
- Multi-agent coordination tips

**Citește când**: Vrei să optimizezi workflow, evita pitfalls

---

### 5. [Profiles - Configurații pentru Tipuri de Proiecte](./profiles.md)

Agent OS suportă **multiple profiles** pentru tech stacks și project types diferite.

**Cuprinde**:
- Ce sunt profiles (pachete configurare complete)
- Default profile vs custom profiles
- Când să folosești multiple profiles (Rails vs Django vs Node.js)
- Profile inheritance (django-api → general → default)
- Creating custom profiles (`create-profile.sh`)
- Using profiles (`--profile flag`, `config.yml`)
- Switching profiles (re-run project-install)
- Common profiles (django-api, rails-api, react-app, node-cli)
- Best practices

**Citește când**: Lucrezi cu multiple tech stacks, vrei să customizezi pentru tech stack specific

---

## 🎯 Alegere Rapidă

### Intreb: "Ar trebui single-agent sau multi-agent?"
➡️ [Single-Agent vs Multi-Agent](./single-vs-multi-agent.md)

### Intreb: "Cum funcționează Agent OS?"
➡️ [Agenti](./agenti.md)

### Intreb: "Cum setup code standards?"
➡️ [Standards](./standards.md)

### Intreb: "Ce sunt best practices?"
➡️ [Best Practices](./best-practices.md)

---

## 📊 Tabel Comparativ

| Concept | Nivel | Timp | Pentru Cine |
|---------|-------|------|-------------|
| Single-Agent vs Multi-Agent | Intermediate | 10 min | Dev, Tech Lead |
| Agenti (14 specialists) | Advanced | 30 min | Architect, Tech Lead |
| Standards System | Intermediate | 15 min | Tech Lead, DevOps |
| Best Practices | Beginner | 20 min | Everyone |

---

## 🔄 Fluxul Cunoașterii (Recommended Order)

### Level 1: Beginner
1. ✅ [Quick Start](../quick-start.md) - How to use Agent OS
2. ✅ [Workflows](../workflows/INDEX.md) - Which workflow to use

### Level 2: Intermediate
3. ✅ [Best Practices](./best-practices.md) - Learn patterns
4. ✅ [Single-Agent vs Multi-Agent](./single-vs-multi-agent.md) - Understand tradeoffs

### Level 3: Advanced
5. ✅ [Agenti (14 specialists)](./agenti.md) - How Agent OS works
6. ✅ [Standards System](./standards.md) - Code quality framework

---

## 📚 Deep Dive Examples

### Setup per Scenario

#### Scenario 1: Small Team, Budget Constrained
**Read**: Single-Agent vs Multi-Agent → choose single-agent → follow workflows

#### Scenario 2: Large Team, Speed Important
**Read**: Single-Agent vs Multi-Agent → choose multi-agent → Best Practices for coordination

#### Scenario 3: Enterprise, Standards Critical
**Read**: Standards → customize standards per team → Best Practices for compliance

#### Scenario 4: Learning/Curious
**Read**: All concepte in order → Agenti → Best Practices → Workflows

---

## 🔗 Linkuri Rapide

**Concepte Core**:
- [Single-Agent vs Multi-Agent](./single-vs-multi-agent.md)
- [Agenti - 14 Specialists](./agenti.md)
- [Standards System](./standards.md)
- [Best Practices](./best-practices.md)

**Alte Resurse**:
- [Commands](../commands/INDEX.md)
- [Workflows](../workflows/INDEX.md)
- [Quick Start](../quick-start.md)
- [Main Index](../INDEX.md)

---

## 🎓 Learning Path

```
If you have 30 minutes:
1. Quick Start (5 min) - how to use
2. Workflows (15 min) - which one
3. Best Practices (10 min) - do's and don'ts

If you have 1 hour:
1-3. Above
4. Single-Agent vs Multi-Agent (15 min) - tradeoffs

If you have 2 hours:
1-4. Above
5. Standards (15 min) - code quality
6. Agenti (15 min) - architecture

If you have 4+ hours (Deep Dive):
1-6. All above, thorough
7. Read all command files (2+ hours)
8. Try workflows on sample project
```

---

**Ready for deep dive? Pick a concept and start reading!** 🧠

```
1. /single-vs-multi-agent.md   (quick decision guide)
2. /agenti.md                  (architecture understanding)
3. /standards.md               (code quality setup)
4. /best-practices.md          (workflow optimization)
```
