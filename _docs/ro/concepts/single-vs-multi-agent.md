# Concept: Single-Agent vs Multi-Agent

Majoritatea comenzilor Agent OS au **2 variante**: single-agent (sequential) și multi-agent (parallel).

Cum alegi?

---

## 🔀 Ce-i Diferența?

### Single-Agent Mode

**Proces**: 1 agent execută sequential

```
Agent → Task 1 → Task 2 → Task 3 → Task 4 → Done
         ↓        ↓        ↓        ↓
        2h       2h       2h       2h
       TOTAL: 8 hours
```

**Exemplu**: 1 developer lucrează task 1, apoi task 2, etc.

---

### Multi-Agent Mode

**Proces**: Multiple agents în parallel

```
Agent A → Task 1 ┐
Agent B → Task 2 ├→ All parallel → Merge → Done
Agent C → Task 3 ┤                ↓
Agent D → Task 4 ┘             2h final
TOTAL: 2-3 hours (60% faster!)
```

**Exemplu**: 4 developers, fiecare pe task diferit, merge la final.

---

## 📊 Tabel Comparativ

| Aspect | Single-Agent | Multi-Agent |
|--------|-------------|-----------|
| **Execuție** | Sequential (1 task at a time) | Parallel (multiple tasks) |
| **Viteză** | Lent pentru 50+ SP | Rapid pentru 50+ SP |
| **Cost (tokens)** | Lower | Higher (more agents) |
| **Complexitate** | Simplu, mai puțini parametri | Complex, merge conflicts |
| **Best for** | Small features (<20 SP) | Large features (20+ SP) |
| **Setup** | Easy | Harder (dependency mgmt) |

---

## ⏱️ Timeline Comparison

### Feature: 60 Story Points (3 developers, 20 SP fiecare)

#### Single-Agent
```
Task 1 (20 SP): 3-4 days
Task 2 (20 SP): 3-4 days
Task 3 (20 SP): 3-4 days
TOTAL: 9-12 days (sequential)
```

---

#### Multi-Agent
```
Task 1 (20 SP) ┐
Task 2 (20 SP) ├→ Parallel
Task 3 (20 SP) ┘
TOTAL: 3-4 days (parallel) + 1 day merge
TOTAL: 4-5 days (40% faster!)
```

---

## 💰 Cost Comparison (Token Usage)

### Single-Agent (cheap but slow)
```
1 agent × 8 hours × 100k tokens/hour = 800k tokens
Cost: Low, Time: High
```

---

### Multi-Agent (expensive but fast)
```
4 agents × 2 hours × 100k tokens/hour = 800k tokens
Cost: High, Time: Low
```

**Takeaway**: Cost similar, but time very different!

---

## 🎯 Decision Matrix

### Use Single-Agent When:

✅ Feature **< 20 SP** (small)
✅ 1 developer available
✅ Budget constrained (reduce token cost)
✅ Feature has **tight dependencies** (can't parallelize)
✅ Code quality critical (1 agent = consistent style)

### Use Multi-Agent When:

✅ Feature **20+ SP** (large)
✅ Multiple developers available
✅ **Timeline critical** (need fast)
✅ Feature can **parallelize** (independent tasks)
✅ Want **redundancy** (multiple perspective)

---

## 💡 Exemplu Concret: TaskFlow Task CRUD API

### Option 1: Single-Agent

```bash
/agent-os:implement-tasks --feature "Task CRUD API"
```

**Flow**:
1. Database schema (3 SP) ← 1 agent
2. Models (3 SP) ← 1 agent
3. POST endpoint (5 SP) ← 1 agent
4. GET endpoints (5 SP) ← 1 agent
5. PATCH endpoint (5 SP) ← 1 agent
6. DELETE endpoint (3 SP) ← 1 agent
7. Permission logic (5 SP) ← 1 agent
8. Error handling (5 SP) ← 1 agent
9. Tests (8 SP) ← 1 agent
10. Docs (3 SP) ← 1 agent

**Total**: 45 SP × 0.5 days/SP = ~22 days (sequential)

---

### Option 2: Multi-Agent

```bash
/agent-os:orchestrate-tasks --feature "Task CRUD API"
```

**Flow**:
- Agent 1: DB schema
- Agent 2: Models
- Agent 3: API endpoints (POST, GET, PATCH, DELETE)
- Agent 4: Permission logic + error handling
- Agent 5: Tests + docs

(All parallel, then merge)

**Total**: ~5-6 days (4x faster!)

---

## 🔧 How to Choose

### Decision Tree

```
1. How big is the feature?
   - < 20 SP → Single-Agent ✅
   - 20-50 SP → Either (prefer Multi for speed)
   - > 50 SP → Multi-Agent ✅

2. How many developers available?
   - 1 → Single-Agent ✅
   - 2+ → Multi-Agent ✅

3. How urgent?
   - Not urgent → Single-Agent (cheap)
   - Urgent → Multi-Agent (fast)

4. How complex dependencies?
   - High coupling → Single-Agent
   - Independent tasks → Multi-Agent
```

---

## ⚠️ Pitfalls

### Single-Agent Pitfalls

- ❌ Too slow for large features
- ❌ Single point of failure
- ❌ No perspective diversity

---

### Multi-Agent Pitfalls

- ❌ Merge conflicts (if not careful)
- ❌ Complexity (coordination needed)
- ❌ Higher token cost
- ❌ Overkill untuk feature kecil

---

## 🚀 Best Practices

- ✅ Start single-agent for small features
- ✅ Transition multi-agent when feature grows
- ✅ Monitor token usage (budget)
- ✅ Clear task boundaries (easier to parallelize)
- ✅ Review merge resolutions carefully
- ❌ Don't over-parallelize (5 agents for 8 tasks = overhead)
- ❌ Don't under-parallelize (1 agent for 50 SP = slow)

---

## 📈 Scaling Guide

| Team Size | Feature Size | Recommendation |
|-----------|-------------|----------------|
| 1 dev | MVP | Single-Agent |
| 2 dev | 20-50 SP | Multi-Agent (2 agents) |
| 3-5 dev | 50+ SP | Multi-Agent (3-5 agents) |
| 5+ dev | Epic | Multi-Agent + orchestration |

---

**Ready to choose? Single or Multi?** 🚀

```
Small feature? → Use /agent-os:implement-tasks (single-agent default)
Large feature? → Use /agent-os:orchestrate-tasks (multi-agent optimized)
```
