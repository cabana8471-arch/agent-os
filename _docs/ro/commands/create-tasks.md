# Comandă: /agent-os:create-tasks

## 📋 Ce Face

Comanda `/agent-os:create-tasks` descompune specification tehnică în **task-uri concrete implementabile**. Transformă spec (1000+ cuvinte) în 8-15 task-uri clară, fiecare estimat 4-8 ore.

După execuție, veți avea:
- `tasks.md` - Lista task-uri cu story points, dependență, assignare
- `task-breakdown.md` - Detalii per task
- `implementation-schedule.md` - Ordering și timeline

---

## ✅ Când să Folosești

- **După spec**: După `/agent-os:write-spec`, înainte de implementare
- **Feature breakdown**: Transform spec în actionable items
- **Team assignment**: Pentru a distribui muncă între developers
- **Tracking**: Pentru a urmări progres pe Jira/Linear/etc

### Exemple

1. **Task CRUD API spec** → 12 task-uri (DB + API endpoints + tests)
2. **Payment integration spec** → 8 task-uri (webhooks + refunds + edge cases)

---

## ❌ Când SĂ NU Folosești

- ❌ Fără spec (first make spec!)
- ❌ Feature trivial (1-2 task-uri, skip formal breakdown)
- ❌ Hotfix urgent (directyapı implement)

---

## 🔀 Variante Disponibile

### Single-Agent Mode
**Când**: Feature mică-medie

**Avantaje**: Rapid, suficient para feature normala

**Dezavantaje**: Overkill pentru feature mica

**Timp**: 10-15 minute

---

### Multi-Agent Mode
**Când**: Epic mare (50+ story points)

**Avantaje**: Better dependency analysis, parallel task design

**Dezavantaje**: Overkill pentru feature mica

**Timp**: 15-20 minute

---

## 📥 Input Necesar

- [ ] `/agent-os:write-spec` executat complet
- [ ] Tech stack decided
- [ ] Team size/skills known

---

## 📤 Output Generat

- `agent-os/specs/[feature]/implementation/tasks.md` - Task list
- `agent-os/specs/[feature]/implementation/task-breakdown.md` - Details
- `agent-os/specs/[feature]/implementation/implementation-schedule.md` - Timeline

**Exemplu tasks.md**:
```markdown
# Task Breakdown - Task CRUD API

| # | Task | Story Points | Dependencies | Owner |
|---|------|-------------|--------------|-------|
| 1 | Database schema + migrations | 3 | None | Backend Lead |
| 2 | Models (Task, Task activity) | 3 | Task 1 | Backend Dev 1 |
| 3 | POST /api/tasks endpoint | 5 | Task 2 | Backend Dev 1 |
| 4 | GET /api/tasks endpoint + pagination | 5 | Task 2 | Backend Dev 2 |
| 5 | GET /api/tasks/:id endpoint | 3 | Task 2 | Backend Dev 2 |
| 6 | PATCH /api/tasks/:id endpoint | 5 | Task 2 | Backend Dev 1 |
| 7 | DELETE /api/tasks/:id endpoint | 3 | Task 2 | Backend Dev 2 |
| 8 | Permission middleware | 5 | Task 2 | Backend Lead |
| 9 | Input validation + error handling | 5 | Task 3-7 | Backend Dev 1 |
| 10 | Unit tests (models + endpoints) | 8 | Task 3-9 | QA |
| 11 | Integration tests (API flows) | 8 | Task 3-9 | QA |
| 12 | API documentation + README | 3 | Task 3-7 | Tech Writer |

**Total**: 61 story points = ~2 weeks (3 developers)
```

---

## 💡 Exemplu Complet

**Input**: specification.md din `/agent-os:write-spec`

**Output**:

### Task 1: Database Schema
- Create tasks table with all fields
- Create task_activities table for audit log
- Add indexes on (assignee_id, status)
- Write migration script

### Task 2: Models
- Task ORM model (validation, relationships)
- TaskActivity model
- Permissions helper (can_edit?, can_delete?)

### Task 3-7: API Endpoints
- Each endpoint: implement + error handling
- Task 3: POST /tasks
- Task 4: GET /tasks (with filtering, pagination)
- Task 5: GET /tasks/:id
- Task 6: PATCH /tasks/:id
- Task 7: DELETE /tasks/:id

### Task 8: Permissions
- Middleware to check JWT
- Row-level security checks
- Rate limiting

### Task 9-11: Testing
- Unit tests (ORM, helpers)
- Integration tests (API flows)
- End-to-end tests (UI if applicable)

### Task 12: Documentation
- API documentation
- Setup guide
- Examples

---

## ⚙️ Flags

```bash
/agent-os:create-tasks --spec "path/to/spec.md" --team-size 3        # Optimize for 3 devs
/agent-os:create-tasks --spec "path/to/spec.md" --estimate-type story-points  # SP vs hours
/agent-os:create-tasks --spec "path/to/spec.md" --aggressive          # Push for faster delivery
/agent-os:create-tasks --spec "path/to/spec.md" --conservative        # Safer estimates
```

---

## 🔧 Troubleshooting

### Problema: "Task-uri prea mari"

**Soluție**: Some tasks > 8 story points = split them

---

### Problema: "Dependencies complexe"

**Soluție**: Request dependency diagram in output

---

## 🔗 Comenzi Legate

**Înainte**: [`/agent-os:write-spec`](./agent-os:write-spec.md)

**După**: [`/agent-os:implement-tasks`](./agent-os:implement-tasks.md) sau [`/agent-os:orchestrate-tasks`](./agent-os:orchestrate-tasks.md)

---

## 💭 Best Practices

- ✅ Each task 4-8 story points (est. 1 day for 1 dev)
- ✅ Clear dependencies documented
- ✅ Parallel-able tasks grouped
- ✅ Buffer for unknowns (20%)
- ❌ Task-uri prea lungi (> 13 SP = split)
- ❌ Fuzzy estimates (be specific)

---

**Gata? Continuă cu [`/agent-os:implement-tasks`](./agent-os:implement-tasks.md) pentru implementare!** 🚀
