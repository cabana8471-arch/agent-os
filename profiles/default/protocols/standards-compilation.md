# Standards Compilation Protocol

> Version: 1.0.0
> Purpose: Define which standards each agent type receives during compilation

This protocol ensures consistency in standards assignment across all agents, preventing both overloading agents with irrelevant standards and omitting necessary ones.

---

## Core Principle

**Agents receive only the standards relevant to their role.** This:
- Reduces context window usage
- Focuses agent attention on applicable guidance
- Prevents conflicting or irrelevant instructions

---

## Agent Categories and Standards Matrix

### Planning Agents

These agents work on high-level planning and don't need implementation details.

| Agent | Standards Pattern |
|-------|-------------------|
| `product-planner` | `{{standards/global/*}}` |
| `spec-initializer` | `{{standards/global/*}}` |
| `spec-shaper` | `{{standards/global/*}}` |
| `spec-writer` | `{{standards/global/*}}` |
| `spec-verifier` | `{{standards/global/*}}` |
| `tasks-list-creator` | `{{standards/global/*}}` |

**Rationale:** Planning agents focus on requirements, roadmaps, and specifications. They don't need backend/frontend implementation patterns.

### Implementation Agents

These agents write or verify code and need comprehensive implementation guidance.

| Agent | Standards Pattern |
|-------|-------------------|
| `implementer` | `{{standards/*}}` (all) |
| `implementation-verifier` | `{{standards/*}}` (all) |

**Rationale:** Implementation agents must follow all coding standards, from global conventions to specific backend/frontend/testing patterns.

### Review and Analysis Agents

These agents analyze code quality and need all standards for comprehensive review.

| Agent | Standards Pattern |
|-------|-------------------|
| `code-reviewer` | `{{standards/*}}` (all) |
| `test-strategist` | `{{standards/global/*}}`, `{{standards/testing/*}}` |
| `documentation-writer` | `{{standards/global/*}}` |
| `refactoring-advisor` | `{{standards/*}}` (all) |
| `feature-analyst` | `{{standards/global/*}}`, `{{standards/backend/*}}`, `{{standards/frontend/*}}` |
| `dependency-manager` | `{{standards/global/*}}` |

**Rationale:** Review agents need visibility into all standards to identify violations. Test strategists focus on testing patterns. Documentation writers need global conventions only.

---

## Standards Categories Reference

### Global Standards (`standards/global/`)

Core standards applicable to all development:

| Standard | Purpose |
|----------|---------|
| `tech-stack.md` | Project technologies and versions |
| `coding-style.md` | Code formatting and naming conventions |
| `conventions.md` | General development conventions |
| `validation.md` | Input validation patterns |
| `error-handling.md` | Error handling strategies |
| `logging.md` | Logging best practices |
| `performance.md` | Performance optimization guidelines |
| `security.md` | Security best practices |
| `commenting.md` | Code documentation standards |
| `deprecation.md` | Deprecation handling |

### Backend Standards (`standards/backend/`)

Server-side implementation patterns:

| Standard | Purpose |
|----------|---------|
| `api.md` | API design and endpoints |
| `models.md` | Data model patterns |
| `queries.md` | Database query optimization |
| `migrations.md` | Database migration strategies |

### Frontend Standards (`standards/frontend/`)

Client-side implementation patterns:

| Standard | Purpose |
|----------|---------|
| `components.md` | Component architecture |
| `css.md` | Styling guidelines |
| `responsive.md` | Responsive design patterns |
| `accessibility.md` | Accessibility requirements |
| `routing.md` | Navigation patterns |
| `state-management.md` | State handling strategies |

### Testing Standards (`standards/testing/`)

Quality assurance patterns:

| Standard | Purpose |
|----------|---------|
| `test-writing.md` | Test implementation guidelines |

---

## Compilation Rules

### Rule 1: Use Specific Patterns

When compiling agent files, use the appropriate pattern:

```yaml
# Planning agent
{{standards/global/*}}

# Implementation agent
{{standards/*}}

# Testing-focused agent
{{standards/global/*}}
{{standards/testing/*}}
```

### Rule 2: No Duplicate Standards

The compilation script must deduplicate standards when multiple patterns overlap:

```bash
# Bad: Will include global/* twice
{{standards/*}}
{{standards/global/*}}

# Good: Use only the broader pattern
{{standards/*}}
```

### Rule 3: Profile Inheritance

Standards are resolved through profile inheritance:

1. Check current profile for standard
2. If not found, check parent profile
3. Continue up inheritance chain
4. Use default profile as fallback

### Rule 4: Exclusion Handling

Profile exclusions take precedence:

```yaml
# In profile-config.yml
exclude_inherited_files:
  - standards/backend/models.md
```

Excluded standards are not passed to any agent in that profile.

---

## Validation Checklist

When modifying agent standards:

- [ ] Agent category correctly identified (planning/implementation/review)
- [ ] Standards pattern matches agent role
- [ ] No unnecessary standards included
- [ ] No required standards missing
- [ ] Exclusions properly configured in profile

---

## Error Handling

### Missing Standard File

If a standard file doesn't exist:

1. Log a warning during compilation
2. Continue with remaining standards
3. Note missing file in agent output

### Invalid Pattern

If a standards pattern is invalid:

1. Log error with pattern details
2. Fall back to `{{standards/global/*}}`
3. Continue compilation with warning

---

## Related Protocols

- `{{protocols/output-protocol}}` - How agents return results
- `{{protocols/issue-tracking}}` - Issue identification during review
- `{{protocols/verification-checklist}}` - Quality gates for each phase
