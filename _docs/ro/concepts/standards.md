# Concept: Standards System

Agent OS enforces **code standards** - consistent style, quality, security across project.

---

## 📋 What Are Standards?

Template files that define:
- Code style (naming conventions, formatting)
- Best practices (error handling, logging)
- Security rules (input validation, auth)
- Testing requirements (coverage, test types)

---

## 📂 Standards Organization

```
profiles/default/standards/
├── global/                   # All projects
│   ├── tech-stack.md        # Technology choices
│   ├── conventions.md       # Naming, formatting
│   ├── error-handling.md    # How to handle errors
│   ├── logging.md           # How to log
│   ├── commenting.md        # Code comments
│   └── validation.md        # Input validation
│
├── backend/                  # Backend-specific
│   ├── api.md               # API design
│   ├── models.md            # Data models
│   ├── queries.md           # Database queries
│   └── migrations.md        # DB migrations
│
├── frontend/                 # Frontend-specific
│   ├── components.md        # Component structure
│   ├── css.md               # Styling
│   ├── responsive.md        # Responsive design
│   └── accessibility.md     # A11y rules
│
└── testing/                  # Testing standards
    └── test-writing.md      # Test structure
```

---

## 🎯 How Standards Apply

### During Development

1. **Implementer** reads standards
2. Writes code following standards
3. **Code-reviewer** checks standards compliance
4. Issues marked: QUAL-001 (quality), ARCH-001 (architecture)

### During Review

Code review includes:
- ✅ Security checks
- ✅ Performance checks
- ✅ Standards compliance
- ✅ Best practices

---

## ⚙️ Customizing Standards

### Per Project

Edit `agent-os/standards/` files to customize:

```markdown
# conventions.md (CUSTOM)

## Naming Conventions

### Variables
- camelCase for JS/TS variables
- snake_case for Python variables
- Constants: UPPER_SNAKE_CASE

## Formatting

### Indentation
- 2 spaces (not 4, not tabs)

### Line length
- Max 100 characters
```

---

## 🛠️ Standards as Claude Code Skills

If `standards_as_claude_code_skills: true` in config:

Standards become **Claude Code Skills** - agents have direct access without reading files.

**Benefit**: Faster access, no context window waste

---

## 📝 Standard Templates

### global/conventions.md
```markdown
# Code Conventions

## Variable Naming
- camelCase for JS
- snake_case for Python
- UPPER_CASE for constants

## Imports
- Sort alphabetically
- Group: external → internal → local

## Comments
- Explain WHY, not WHAT
- 1 comment per 10-20 lines max
```

---

### backend/api.md
```markdown
# API Design Standards

## Naming
- Plural nouns for resources (/tasks, /users)
- Verbs only for actions (/tasks/:id/export)

## HTTP Methods
- GET: fetch
- POST: create
- PATCH: partial update
- DELETE: delete

## Error Codes
- 400: bad input
- 401: auth required
- 403: permission denied
- 404: not found
- 500: server error

## Response Format
```json
{
  "data": {...},
  "meta": { "pagination": {...} }
}
```
```

---

### frontend/components.md
```markdown
# Component Standards

## File Structure
```
components/
├── TaskList.tsx
├── TaskItem.tsx
├── TaskForm.tsx
└── __tests__/
    ├── TaskList.test.tsx
    └── TaskItem.test.tsx
```

## Props
- Max 5 props (split if more)
- Boolean props prefix: `is`, `has`, `can`
- Handler props suffix: `onX`, `onXX`

## State Management
- Use hooks (useState, useContext)
- Extract logic to custom hooks
```

---

## ✅ Standards Best Practices

- ✅ Define once, use everywhere
- ✅ Automate (linters, formatters)
- ✅ Review against standards
- ✅ Update standards with learnings
- ❌ Too many standards (overwhelm)
- ❌ Ignore standards (inconsistency)
- ❌ Standards without automation

---

## 🔗 Integration

### With CI/CD

```bash
# Pre-commit hook
npm run lint    # Check conventions
npm run format  # Apply formatting
npm test        # Run tests

# GitHub Actions
- eslint (JS standards)
- prettier (formatting)
- jest (testing)
```

---

## 🎓 When to Customize

**Keep default**: For first project

**Customize**: After 1-2 projects when you have preferences

**Update**: As team learnings emerge

---

## 🔗 Relationship with Profiles

Standards sunt **parte din Profiles**. Un profile e o pachet completă care include:

- **Standards** (coding style, conventions, validation, error handling)
- Workflows (procesele de development)
- Agents (specialiști AI configurați)
- Commands (comenzile disponibile)

### Exemplu: Profile `django-api`

Profilele previn rescrierea standardelor pentru fiecare tech stack:

```
Profile: django-api
  ├─ Standards (Django ORM, Django views, Django migrations)
  │  ├─ backend/django-models.md
  │  ├─ backend/django-views.md
  │  └─ backend/django-migrations.md
  ├─ Workflows (implementation workflow)
  ├─ Agents (14 specialized agents)
  └─ Commands (16 development commands)
```

**Beneficiu**: Agent OS aplică automat conventions specifice Django (migrations, ORM patterns, view structure) fără să trebuie să editezi manual.

📖 **Citeste mai mult**: [Profiles - Complete Guide](./profiles.md)

---

**Standards = Team alignment on quality** ✨

