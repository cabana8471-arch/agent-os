# Standards Table of Contents

This document provides an overview of all standards available in the default profile.

## Global Standards

General standards that apply across the entire project:

| Standard | Description |
|----------|-------------|
| [coding-style.md](global/coding-style.md) | Code formatting and style guidelines |
| [commenting.md](global/commenting.md) | Documentation and commenting practices |
| [conventions.md](global/conventions.md) | Naming and coding conventions |
| [deprecation.md](global/deprecation.md) | Standard deprecation process |
| [error-handling.md](global/error-handling.md) | Error handling patterns |
| [tech-stack.md](global/tech-stack.md) | Technology stack documentation |
| [validation.md](global/validation.md) | Input validation guidelines |

## Frontend Standards

Standards for frontend/UI development:

| Standard | Description |
|----------|-------------|
| [accessibility.md](frontend/accessibility.md) | Accessibility (a11y) best practices |
| [components.md](frontend/components.md) | UI component patterns |
| [css.md](frontend/css.md) | CSS and styling guidelines |
| [responsive.md](frontend/responsive.md) | Responsive design patterns |
| [routing.md](frontend/routing.md) | Client-side routing patterns |
| [state-management.md](frontend/state-management.md) | State management best practices |

## Backend Standards

Standards for server-side development:

| Standard | Description |
|----------|-------------|
| [api.md](backend/api.md) | API design guidelines |
| [migrations.md](backend/migrations.md) | Database migration practices |
| [models.md](backend/models.md) | Data model patterns |
| [queries.md](backend/queries.md) | Database query best practices |

## Testing Standards

Standards for testing and quality assurance:

| Standard | Description |
|----------|-------------|
| [test-writing.md](testing/test-writing.md) | Test writing guidelines |

---

## Using Standards

Standards are automatically referenced in commands using the `@agent-os/standards/` prefix. For example:

```markdown
See @agent-os/standards/frontend/components.md for component guidelines.
```

## Adding New Standards

1. Create a new `.md` file in the appropriate category folder
2. Follow the existing format (heading, bullet points)
3. Update this TOC with the new standard
4. Run `project-install.sh` to deploy to projects
