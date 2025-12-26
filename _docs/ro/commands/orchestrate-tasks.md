# Comandă: /agent-os:orchestrate-tasks

## 📋 Ce Face

Comanda `/agent-os:orchestrate-tasks` **orchestrează implementarea paralel** pentru feature-uri **mari și complexe**. În loc să implementezi task 1 → task 2 → task 3 (sequențial), aceasta:
1. Analizează task-uri și dependency-uri
2. Delegă parallel agenti specialized (implementer, reviewer, verifier)
3. Sincronizează, merge conflicte, coordonează

**Rezultat**: Feature mare (50+ SP) în 2-3 ore vs 4-5 ore sequential.

---

## ✅ Când să Folosești

- **Feature mare** (20+ task-uri, 50+ SP)
- **Epic complex** - multi-part feature cu dependency-uri
- **Team parallelization** - vrei multiple developers on same feature
- **Urgent delivery** - need feature faster

### Exemplu

**Payment Integration** (25 tasks, 80 SP):
- Sequential: 4-5 days (1 dev) sau 2-3 days (2 devs)
- Orchestrated: 1-2 days (smart parallelization)

---

## ❌ Când SĂ NU Folosești

- ❌ Feature mică (< 20 SP → use `/agent-os:implement-tasks`)
- ❌ Simple feature (< 10 tasks)
- ❌ High coupling (tasks depend on each other heavily)
- ❌ Single developer team

---

## 🔀 Variante Disponibile

### Single-Agent Mode (Orchestrator)

**Când**: Feature mare but single developer

**Avantaje**:
- ✅ Smart parallelization (simulate multi-dev)
- ✅ Dependency awareness
- ✅ Merge conflict resolution

**Dezavantaje**:
- ❌ Still sequential (1 agent can't truly parallelize)
- ❌ Slower than multi-agent

**Timp**: 2-3 ore

---

### Multi-Agent Mode (Recommended)

**Când**: Feature mare + multiple developers OR want true parallelization

**Avantaje**:
- ✅ True parallelization (multiple agents in parallel)
- ✅ Specialized agents (implementer + reviewer + verifier)
- ✅ Fastest delivery
- ✅ Better quality (multi-perspective)

**Dezavantaje**:
- ❌ More complex output
- ❌ Overkill pentru feature mica

**Timp**: 1.5-2 hours (parallel)

---

## 📥 Input Necesar

- [ ] `/agent-os:create-tasks` executat (detailed task list with dependencies)
- [ ] Code environment setup
- [ ] Database available
- [ ] Preferred: team/developer info (for smart assignment)

---

## 📤 Output Generat

**Per-task**:
- Code implemented
- Code review report
- Verification report

**Orchestration**:
- `orchestration-report.md` - Task assignment, parallelization, timeline
- `merge-conflicts.md` - Any conflicts resolved, merge strategy
- `implementation-summary.md` - Overall status per task

---

## 💡 Exemplu Complet

### Context: TaskFlow - Payment Integration (25 tasks)

**Execuție**:

```bash
/agent-os:orchestrate-tasks --feature "Payment Integration"
```

### Orchestration Analysis

Orchestrator analizează 25 tasks și dependency-uri:

```
Parallel Group 1 (can do together):
- Task 1: Stripe API integration (4 SP)
- Task 2: Database schema for payments (3 SP)
- Task 3: Configuration management (2 SP)

Parallel Group 2 (after Group 1):
- Task 4: Charge endpoint (5 SP)
- Task 5: Refund endpoint (5 SP)
- Task 6: Webhook handler (5 SP)

Parallel Group 3 (after Group 2):
- Task 7-15: Edge cases, error handling, tests (8x 3-5 SP)

Parallel Group 4 (final):
- Task 16-25: Integration tests, docs, deployment (10x 2-3 SP)
```

### Execution Timeline

```
Time 0h00 - 0h45: Group 1 (3 tasks paralel)
  ✅ Task 1: Stripe API integration DONE
  ✅ Task 2: DB schema DONE
  ✅ Task 3: Config DONE

Time 0h45 - 1h30: Group 2 (3 tasks paralel)
  ✅ Task 4: Charge endpoint DONE
  ✅ Task 5: Refund endpoint DONE
  ✅ Task 6: Webhook handler DONE

Time 1h30 - 2h00: Group 3 (8 tasks paralel)
  ✅ 8 edge case/error handling tasks DONE

Time 2h00 - 2h30: Group 4 (10 tasks paralel)
  ✅ Tests, docs, deployment DONE

TOTAL: 2.5 hours (vs 5-6 hours sequential)
```

### Code Review Coordination

Orchestrator ensures:
- ✅ All code reviewed (consistency)
- ✅ Conflicts resolved (if parallel tasks touch same files)
- ✅ Standards applied uniformly
- ✅ Security checked (all endpoints, all edge cases)

### Verification Coordination

- ✅ Unit tests run per task
- ✅ Integration tests (cross-task) after all complete
- ✅ Final verification: whole feature works end-to-end

### Output Report

```
✅ Payment Integration complete
📁 Orchestration Report: 25/25 tasks
⏱️ Timeline: 2.5 hours (paralel) vs 5-6 hours (sequential)
📊 Code quality: A (0 critical, 2 minor style issues)
🧪 Test coverage: 91%
🔀 Merge conflicts: 1 (resolved - both added payment_id to tasks table)
🚀 Ready for: staging deployment
```

---

## ⚙️ Options

```bash
/agent-os:orchestrate-tasks --feature "Name"                    # Standard
/agent-os:orchestrate-tasks --feature "Name" --max-parallel 2   # Limit parallelization
/agent-os:orchestrate-tasks --feature "Name" --aggressive       # Fast, less QA
/agent-os:orchestrate-tasks --feature "Name" --focus-quality    # Slower, strict QA
/agent-os:orchestrate-tasks --feature "Name" --team-members john,mary,ali  # Assign to devs
```

---

## 🔧 Troubleshooting

### Problema: "Merge conflict"

**Soluție**: Orchestrator handles, but you should review resolution

---

### Problema: "Task A blocked by Task B"

**Soluție**: Orchestrator reorders tasks intelligently

---

## 🔗 Comenzi Legate

**Vs**: [`/agent-os:implement-tasks`](./agent-os:implement-tasks.md) (sequential, better for small features)

**După**:
- [`/agent-os:test-strategy`](./agent-os:test-strategy.md)
- [`/agent-os:review-code`](./agent-os:review-code.md)

---

## 💭 Best Practices

- ✅ Use for features > 50 SP
- ✅ Detailed task list with clear dependencies
- ✅ Let orchestrator optimize parallelization
- ✅ Review merge resolutions
- ❌ Don't use for simple features
- ❌ Don't ignore task dependencies

---

**Gata? Feature-ul e implementat! Continuă cu [`/agent-os:test-strategy`](./agent-os:test-strategy.md) și [`/agent-os:generate-docs`](./agent-os:generate-docs.md)!** 🚀
