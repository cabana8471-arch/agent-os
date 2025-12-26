# Comandă: /agent-os:write-spec

## 📋 Ce Face

Comanda `/agent-os:write-spec` creează o **specification tehnică detaliată** pentru o feature sau epic. Aceasta transformă ideile de la planning/roadmap în cerințe concrete, API specifications, și decision documents.

După execuție, vor exista:
- `specification.md` - Spec tehnic complet (cerințe, API, diagrami, edge cases)
- `implementation-notes.md` - Sfaturi pe implementare
- `data-model.md` - Schema bază de date (dacă relevant)

---

## ✅ Când să Folosești

- **Înainte de implementare**: Pentru orice feature în roadmap
- **Feature nouă în proiect existent**: Documentare cerințe noi
- **Complex feature**: Orice are dependency-uri sau edge cases
- **Team alignment**: Pentru a califica toți pe ce se implementează

### Exemple Concrete

1. **TaskFlow - Feature: Task CRUD API**
   - Scop: Scriere spec pentru task create/read/update/delete endpoints
   - Input: Feature descriere din roadmap
   - Output: API spec complet cu 5 endpoints, data model, error handling

2. **Legacy App - Feature: User Export**
   - Scop: Documente cum Users pot export data în CSV
   - Input: User request din support
   - Output: Spec cu validare, error cases, performance considerations

---

## ❌ Când SĂ NU Folosești

- ❌ Pentru bug fix simplu (1-2 linii cod)
- ❌ Dacă spec deja exists și good quality
- ❌ Pentru hotfix urgent (go direct to implement)
- ❌ Refactoring pur (fără change în behavior)

---

## 🔀 Variante Disponibile

### Single-Agent Mode

**Când**: Feature mică-medie (1-3 API endpoints, simpla logică)

**Avantaje**:
- ✅ Rapid (15-25 min)
- ✅ Suficient detaliu pentru feature simpla
- ✅ Ușor pentru team review

**Dezavantaje**:
- ❌ Mai puțin thorough pe edge cases
- ❌ Poate miss cross-feature implications

**Timp**: 15-25 minute

---

### Multi-Agent Mode

**Când**: Feature mare (10+ endpoints), complex logic, multi-team coordination

**Avantaje**:
- ✅ Thorough (tech perspectivă multiple)
- ✅ Better edge case coverage
- ✅ Faster (parallelization)

**Dezavantaje**:
- ❌ Output mai lung (need synthesis)
- ❌ Overkill pentru feature simpla

**Timp**: 20-30 minute (paralel)

---

## 📥 Input Necesar

### Pre-condiții Checklist

- [ ] `/agent-os:plan-product` executat (mission + roadmap)
- [ ] Feature e în roadmap (sau aprovat ca ad-hoc)
- [ ] Tech stack decidit (din `/agent-os:plan-product`)
- [ ] Database schema rough (dacă applicable)

### Informații Cerute (Agentul va întreba)

**Pasul 1: Feature Description**
- Care e feature name?
- Ce problema rezolva?
- User stories (cine, ce, de ce)?

**Pasul 2: Acceptance Criteria**
- Ce trebuie să funcționeze?
- Care sunt success metrics?
- Care sunt edge cases importante?

**Pasul 3: Technical Context**
- Afectează alte features?
- Database changes?
- API integrations?
- Performance requirements?

---

## 📤 Output Generat

### Fișiere Create

- **`agent-os/specs/[feature-name]/specification.md`** (~1500 cuvinte)
  - Feature overview + problem statement
  - Acceptance criteria (AC1, AC2, ..., ACN)
  - API specifications (endpoints, request/response)
  - Data model / schema changes
  - Error handling strategy
  - Security considerations
  - Performance / scalability notes
  - Migration plan (dacă breaking change)

- **`agent-os/specs/[feature-name]/implementation-notes.md`** (~500 cuvinte)
  - Implementation tips
  - Potential pitfalls
  - Testing strategy outline
  - Code organization suggestions

- **`agent-os/specs/[feature-name]/data-model.md`** (~300 cuvinte)
  - Database schema (SQL DDL)
  - Relationships
  - Indexes
  - Migration scripts (if applicable)

### Informații Returnate în Conversație

- ✅ Feature spec summary (1-2 paragrafe)
- ✅ Number of endpoints/components
- ✅ Estimated complexity (Low/Medium/High)
- ✅ Next steps (usually `/agent-os:create-tasks` → `/agent-os:implement-tasks`)

---

## 💡 Exemplu Complet

### Context: TaskFlow - Feature: Task CRUD API

**Scenariu**: Vrei să scrieți specification pentru API endpoint-urile de Task management.

### Execuție Pas-cu-Pas

**Pasul 1: Lansare Comanda**

```bash
/agent-os:write-spec --feature "Task CRUD API"
```

**Pasul 2: Răspunzi Întrebări**

> **Agent**: Feature description - what's this feature?
> **Tu**: CRUD operations pentru tasks. Create, read, update, delete. Include filtering, sorting, pagination.

> **Agent**: User stories?
> **Tu**:
> - As a user, I want to create a task with title, description, assignee
> - As a user, I want to update task status (todo, in-progress, done)
> - As a user, I want to list tasks with filters (assignee, status, due date)
> - As a user, I want to delete completed tasks

> **Agent**: Database - New table or existing?
> **Tu**: New table. Need to track: id, title, description, status, assignee, due_date, created_at, updated_at

> **Agent**: Security/permission model?
> **Tu**: Users can only see/edit tasks assigned to them or in shared projects

---

### Pasul 3: Agent Creează Spec

#### `specification.md` (generat)

```markdown
# Task CRUD API Specification

## Feature Overview
API endpoints for creating, reading, updating, and deleting tasks.
Includes filtering, sorting, pagination, and permission-based access control.

## Acceptance Criteria

### AC1: Create Task
- POST /api/tasks
- Body: { title, description, assignee_id?, due_date? }
- Response: 201 with task object
- Validate: title required, max 255 chars; description max 5000 chars

### AC2: List Tasks
- GET /api/tasks
- Query params: assignee_id, status, skip, limit
- Response: 200 with task array + total count
- Pagination: default limit 20, max 100

### AC3: Get Single Task
- GET /api/tasks/:taskId
- Response: 200 with task object or 404
- Include activity log (comments, updates)

### AC4: Update Task
- PATCH /api/tasks/:taskId
- Body: { title, description, status, assignee_id, due_date }
- Response: 200 with updated task
- Validate permissions: only assignee/creator/admin can update
- Track activity: log all changes

### AC5: Delete Task
- DELETE /api/tasks/:taskId
- Response: 204 No Content
- Soft delete: mark deleted_at, don't actually delete

## Data Model

```sql
CREATE TABLE tasks (
  id BIGINT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status ENUM('todo', 'in-progress', 'done'),
  assignee_id INT REFERENCES users(id),
  creator_id INT REFERENCES users(id) NOT NULL,
  due_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP,
  project_id INT REFERENCES projects(id)
)
```

## API Response Examples

### Create Task (201)
```json
{
  "id": "task_123",
  "title": "Implement API",
  "status": "todo",
  "assignee": { "id": "user_1", "name": "John" },
  "created_at": "2024-01-15T10:00:00Z"
}
```

### List Tasks (200)
```json
{
  "data": [
    { "id": "task_123", "title": "...", "status": "todo" },
    { "id": "task_124", "title": "...", "status": "in-progress" }
  ],
  "total": 42,
  "skip": 0,
  "limit": 20
}
```

## Error Handling

| Status | Scenario | Response |
|--------|----------|----------|
| 400 | Invalid input (missing title) | `{error: "title_required"}` |
| 401 | Unauthorized (not logged in) | `{error: "auth_required"}` |
| 403 | Forbidden (no permission) | `{error: "permission_denied"}` |
| 404 | Task not found | `{error: "task_not_found"}` |
| 409 | Conflict (race condition) | `{error: "conflict_retry"}` |

## Security Considerations

- ✅ All endpoints require authentication (JWT token)
- ✅ Row-level security: users can only access their own tasks
- ✅ Rate limiting: 100 requests/minute per user
- ✅ Input validation: sanitize title, description
- ✅ SQL injection protection: use ORM/parameterized queries

## Performance Notes

- Index on (assignee_id, status) for filtering
- Pagination for large result sets
- Consider caching GET /tasks (5 min TTL)
- Soft delete for data retention (GDPR)
```

#### `implementation-notes.md` (generat)

```markdown
# Implementation Notes - Task CRUD API

## Key Decisions

1. **Soft Deletes**: Don't actually delete tasks, mark deleted_at
   - Reason: Data retention, audit trail, recovery
   - Implication: Always filter WHERE deleted_at IS NULL

2. **Pagination Required**: Not GET /tasks?limit=999
   - Reason: Performance, database load
   - Implementation: skip + limit (not offset for better perf)

3. **Activity Tracking**: Log all updates
   - Reason: User can see what changed and when
   - Implementation: task_updates table or JSON column

## Implementation Tips

- Start with create + read (simplest path)
- Add update/delete after core works
- Don't optimize early (indexes after profiling)
- Test error cases: invalid input, permission denied, race conditions

## Testing Strategy

1. Unit tests: validation logic, permission checks
2. Integration tests: API endpoints with real DB
3. E2E tests: full flow create → read → update → delete
4. Load test: pagination performance (1M tasks)
```

---

### Pasul 4: Review Output

```
✅ Spec write complete
📁 Reports:
   - agent-os/specs/task-crud/specification.md
   - agent-os/specs/task-crud/implementation-notes.md
   - agent-os/specs/task-crud/data-model.md
📊 Complexity: Medium (5 endpoints, permission model)
⏱️ Estimated Dev Time: 3-5 days (2 engineers)
➡️ Next: /agent-os:create-tasks for task breakdown
```

### Pasul 5: Continuă

Acum ești gata pentru:

```bash
/agent-os:create-tasks --spec "agent-os/specs/task-crud/specification.md"
```

---

## ⚙️ Opțiuni Avansate

### Flags Disponibile

```bash
/agent-os:write-spec --feature "Name" --include-api-examples      # Detailed API examples
/agent-os:write-spec --feature "Name" --include-database-schema   # SQL DDL included
/agent-os:write-spec --feature "Name" --include-testing-plan      # Test strategy detailed
/agent-os:write-spec --feature "Name" --include-performance-notes # Scalability notes
/agent-os:write-spec --feature "Name" --minimal                   # Short spec (1-2 pages)
/agent-os:write-spec --feature "Name" --comprehensive             # Full spec (5-10 pages)
```

---

## 🔧 Troubleshooting

### Problema: "Spec e prea vag"

**Cauză**: Feature description neclară

**Soluție**:
1. Fii specific: "User can see all tasks" → "User sees tasks assigned to them, paginated 20 per page"
2. Include edge cases: What if due_date is past? What if user is unassigned?
3. Clarify permissions: Who can create/edit/delete?

---

### Problema: "Spec e prea lung"

**Cauză**: Feature prea mare sau multi-part

**Soluție**:
1. Split în features mici: "Task CRUD" + "Task Filtering" (separate specs)
2. Request `/agent-os:write-spec --minimal` (shorter version)
3. Move edge cases la later phase

---

### Problema: "Missing database schema"

**Cauză**: Spec nu include SQL DDL

**Soluție**:
- Request explicit: `/agent-os:write-spec --feature "X" --include-database-schema`
- Or review `data-model.md` file generated

---

## 🔗 Comenzi Legate

### Înainte de această comandă

- **[`/agent-os:plan-product`](./agent-os:plan-product.md)** - Must do first (roadmap + tech stack)
- **[`/agent-os:shape-spec`](./agent-os:shape-spec.md)** - Optional (if requirements unclear)

### După această comandă

- **[`/agent-os:verify-spec`](./agent-os:verify-spec.md)** - Optional audit before implement
- **[`/agent-os:create-tasks`](./agent-os:create-tasks.md)** - Break spec into tasks
- **[`/agent-os:implement-tasks`](./agent-os:implement-tasks.md)** - Implement + code review

---

## 📚 Resurse Tehnice

- **Workflow**: [`workflows/agent-os:write-spec`](../../profiles/default/workflows/specification/agent-os:write-spec.md)
- **Agent**: [`spec-writer`](../../profiles/default/agents/spec-writer.md)
- **Standards**: `global/api`, `backend/models`, `backend/queries`

---

## 💭 Best Practices

### ✅ DO

- ✅ Include acceptance criteria (measurable)
- ✅ Data model with migrations
- ✅ Error handling strategy
- ✅ Security/permission model
- ✅ Performance considerations

### ❌ DON'T

- ❌ Vague requirements ("make it fast")
- ❌ Skip edge cases
- ❌ Missing permission model
- ❌ No error handling discussion
- ❌ Spec without testing strategy

---

**Gata cu `/agent-os:write-spec`? Next: [`/agent-os:create-tasks`](./agent-os:create-tasks.md) pentru breakdown task-uri!** 🚀
