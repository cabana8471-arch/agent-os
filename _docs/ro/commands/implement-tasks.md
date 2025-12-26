# Comandă: /agent-os:implement-tasks

## 📋 Ce Face

Comanda `/agent-os:implement-tasks` **implementează task-uri din spec** cu **automatic code review și verification**. Iterează task cu task, iar fiecare task e:
1. Implementat
2. Code-reviewed (automatic)
3. Verified complet

După execuție:
- ✅ Cod implementat complet
- ✅ Code review raport (security, quality, standards)
- ✅ Verification raport (tests pass, spec met)

---

## ✅ Când să Folosești

- **Feature mică-medie** (1-12 task-uri, <50 story points)
- **Sequential implementation** (task 1 → task 2 → ... → task N)
- **Buildup feature** - start simple, add complexity
- **Preferred mode** pentru 90% din development

### Exemplu

**Task CRUD API** (12 task-uri): Start cu DB schema → Models → API endpoints → Tests
Fiecare task e implementat + reviewed + verified independent.

---

## ❌ Când SĂ NU Folosești

- ❌ Feature mica trivial (< 4 story points)
- ❌ Fără spec/task-uri (first `/agent-os:create-tasks`!)
- ❌ Feature mare complexă (> 50 SP → use `/agent-os:orchestrate-tasks`)
- ❌ Hotfix urgent (use `/agent-os:implement-tasks --quick`)

---

## 🔀 Variante Disponibile

### Single-Agent Mode

**Când**: Feature mică-medie (< 20 SP)

**Avantaje**:
- ✅ Rapid per task (15-30 min/task)
- ✅ Single agent = consistent style
- ✅ Simpler setup

**Dezavantaje**:
- ❌ Sequential (task 1, apoi task 2, etc.)
- ❌ Slow pentru 50+ SP features

**Timp**: 2-4 ore pentru 12-task feature

---

### Multi-Agent Mode

**Când**: Feature medie-mare (20-50 SP), multiple developers

**Avantaje**:
- ✅ Parallelization (faster)
- ✅ Specialized agents (implementer + reviewer + verifier)
- ✅ Better quality (multi-check)

**Dezavantaje**:
- ❌ Complexity (handle merges, conflicts)
- ❌ Overkill pentru feature mica

**Timp**: 2-3 ore (paralel)

---

## 📥 Input Necesar

- [ ] `/agent-os:create-tasks` executat (task list)
- [ ] Code environment setup (repo, branch, etc.)
- [ ] Database available (for migrations)

---

## 📤 Output Generat

**Per-task**:
- ✅ Code implemented (actual PR/changes)
- ✅ Code review report (`code-review.md`)
- ✅ Verification report (`verification-report.md`)

**Final**:
- `agent-os/specs/[feature]/implementation/code-review.md` - Overall review
- `agent-os/specs/[feature]/implementation/verification-report.md` - Tests, spec met
- Actual code changes in your repo

---

## 💡 Exemplu Complet

### Context: TaskFlow - Task CRUD API (12 tasks)

**Execuție**:

```bash
/agent-os:implement-tasks --feature "Task CRUD API"
```

### Faza 1: Database (Task 1-2)

**Task 1**: Database schema + migrations
```sql
-- Created:
CREATE TABLE tasks (...)
CREATE TABLE task_activities (...)
CREATE INDEX idx_tasks_assignee_status ON tasks(assignee_id, status)
```

✅ Code review: "Good schema, proper indexes, migration scripts clean"
✅ Verification: "Migration passes, schema matches spec"

---

**Task 2**: Models (Task, TaskActivity)
```python
# Created:
class Task(Model):
    title: str
    description: str
    status: Enum
    # ... + validation, relationships, helpers

class TaskActivity(Model):
    task_id: FK
    action: str
    # ... + audit trail
```

✅ Code review: "Models well-structured, proper relationships"
✅ Verification: "Tests pass (ORM tests), spec met"

---

### Faza 2: API Endpoints (Task 3-7)

**Task 3**: POST /api/tasks
```python
@app.post("/tasks")
def create_task(body: CreateTaskRequest):
    # Validation
    # Permission check
    # Create task
    # Return 201 + task object
```

✅ Code review: "Input validation good, error handling complete"
✅ Verification: "Unit tests pass, manual testing OK"

---

**Task 4**: GET /api/tasks + pagination + filtering
```python
@app.get("/tasks")
def list_tasks(
    assignee_id: Optional[int],
    status: Optional[str],
    skip: int = 0,
    limit: int = 20
):
    # Filters
    # Pagination
    # Return tasks array
```

✅ Code review: "Pagination correct, SQL injection protected"
✅ Verification: "Integration tests pass, pagination works"

---

**Task 5-7**: GET/:id, PATCH/:id, DELETE/:id
(Similar workflow for each)

---

### Faza 3: Security + Testing (Task 8-11)

**Task 8**: Permission middleware
✅ Code review: "JWT validation correct, row-level security implemented"
✅ Verification: "Tests pass, permission checks work"

**Task 9**: Input validation + error handling
✅ Code review: "All error codes documented, validation comprehensive"
✅ Verification: "Error tests pass, edge cases covered"

**Task 10-11**: Unit + integration tests
✅ Code review: "Test coverage 85%+, good assertions"
✅ Verification: "All tests pass, CI green"

---

### Faza 4: Documentation (Task 12)

**Task 12**: API docs + README
✅ Code review: "Documentation complete, examples clear"
✅ Verification: "Examples tested, README accurate"

---

### Final Output:

```
✅ Feature implementation complete
📁 Reports:
   - code-review.md (all issues listed by severity)
   - verification-report.md (tests, spec compliance)
🎯 Tasks completed: 12/12
📊 Code quality: A- (2 style issues, 1 perf opportunity)
🧪 Test coverage: 87%
➡️ Next: deploy to staging, user testing
```

---

## ⚙️ Options

```bash
/agent-os:implement-tasks --feature "Name" --agent sonnet           # Faster
/agent-os:implement-tasks --feature "Name" --agent opus             # Better quality
/agent-os:implement-tasks --feature "Name" --quick                  # Skip review (danger!)
/agent-os:implement-tasks --feature "Name" --task-list "custom.md"  # Custom task list
/agent-os:implement-tasks --feature "Name" --parallel               # Parallel (use multi-agent)
/agent-os:implement-tasks --feature "Name" --focus-quality          # Strict QA
```

---

## 🔧 Troubleshooting

### Problema: "Implementation stuck on Task X"

**Cauză**: Task e blocked by dependency or ambiguous

**Soluție**:
1. Review task description: is spec clear?
2. Check dependencies: is prior task done?
3. Skip and come back later (reorder tasks)

---

### Problema: "Code review found security issue"

**Cauză**: Security gap in implementation

**Soluție**:
1. Fix per code review
2. Re-run verify after fix
3. Update spec if review suggests change

---

## 🔗 Comenzi Legate

**Înainte**: [`/agent-os:create-tasks`](./agent-os:create-tasks.md)

**După**:
- [`/agent-os:test-strategy`](./agent-os:test-strategy.md) (coverage analysis)
- [`/agent-os:review-code`](./agent-os:review-code.md) (deep audit)
- [`/agent-os:generate-docs`](./agent-os:generate-docs.md) (auto-docs)

---

## 💭 Best Practices

- ✅ Implement tasks in order (respect dependencies)
- ✅ Review code review feedback - fix issues
- ✅ Commit frequently (1 commit per task)
- ✅ Update status as you go (transparency)
- ❌ Ignore code review findings
- ❌ Skip tasks ("we'll do it later")
- ❌ Implement without spec

---

**Gata? Continuă cu [`/agent-os:test-strategy`](./agent-os:test-strategy.md) atau [`/agent-os:generate-docs`](./agent-os:generate-docs.md)!** 🚀
