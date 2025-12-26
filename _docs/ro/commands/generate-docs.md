# Comandă: /agent-os:generate-docs

## 📋 Ce Face

Auto-generate API documentation, README, CHANGELOG, setup guides.

Output: `API.md`, `README.md`, `CHANGELOG.md`, `SETUP.md`

---

## ✅ Când să Folosești

- După feature implementation
- API documentation
- Onboarding documentation
- Before public release

---

## ❌ Când SĂ NU Folosești

- Internal only, no external docs needed

---

## 📤 Output Generat

- `docs/api.md` - API endpoints, examples, authentication
- `docs/setup.md` - Development environment setup
- `README.md` - Project overview, quick start
- `CHANGELOG.md` - Version history, what's new

---

## 💡 Exemplu

**Input**: Task CRUD API implemented

**Output**:
```markdown
# TaskFlow API Documentation

## Overview
RESTful API for task management with real-time collaboration.

## Base URL
```
https://api.taskflow.com/v1
```

## Endpoints

### Create Task
```
POST /tasks
Content-Type: application/json

{
  "title": "Fix bug",
  "description": "Memory leak in polling",
  "assignee_id": "user_123",
  "due_date": "2024-01-20"
}

Response: 201
{
  "id": "task_456",
  "title": "Fix bug",
  "status": "todo",
  "created_at": "2024-01-15T10:00:00Z"
}
```

[... more endpoints ...]

## Authentication
Bearer token in Authorization header.

## Error Codes
- 400: Invalid input
- 401: Unauthorized
- 403: Forbidden
- 404: Not found
```

---

## 🔗 Comenzi Legate

**După**: `/agent-os:implement-tasks`

**Before**: Release

---

**Gata? Deploy și share docs!** 🚀
