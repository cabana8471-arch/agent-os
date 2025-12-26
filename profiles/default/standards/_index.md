# Standards Priority Guide

This index provides guidance on when and how to apply each standard.

## Critical (Must Follow)
These standards prevent security vulnerabilities and data integrity issues:
- `global/security.md` - Security practices (authentication, authorization, input sanitization)
- `global/validation.md` - Input validation and data integrity
- `global/error-handling.md` - Error handling and exception management

## Important (Should Follow)
These standards ensure code quality and maintainability:
- `global/coding-style.md` - Code formatting and naming conventions
- `global/logging.md` - Logging and observability
- `backend/api.md` - API design and conventions
- `backend/models.md` - Database model design
- `frontend/components.md` - UI component architecture
- `frontend/accessibility.md` - Accessibility compliance

## Recommended (Consider Following)
These standards improve development workflow:
- `global/conventions.md` - Project conventions
- `global/performance.md` - Performance optimization
- `backend/queries.md` - Database query optimization
- `backend/migrations.md` - Database migration practices
- `frontend/css.md` - CSS methodology
- `frontend/responsive.md` - Responsive design
- `global/commenting.md` - Code documentation

## Phase-Specific
Apply during specific development phases:
- `testing/test-writing.md` - Apply during implementation and verification phases
- `global/tech-stack.md` - Reference during planning and setup

## Cross-References

Standards are interconnected. When implementing one, consider related standards:

### Security Cluster (implement together)
- `global/security.md` ↔ `global/validation.md` - Input sanitization is security
- `global/security.md` ↔ `global/logging.md` - Sensitive data logging rules
- `global/security.md` ↔ `global/error-handling.md` - Safe error messages

### Error & Observability Cluster (tightly coupled)
- `global/error-handling.md` ↔ `global/logging.md` - Error context and correlation IDs
- `global/logging.md` ↔ `global/performance.md` - Performance logging thresholds

### API Cluster
- `backend/api.md` ↔ `global/validation.md` - Request validation
- `backend/api.md` ↔ `global/error-handling.md` - HTTP error responses
- `backend/api.md` ↔ `global/security.md` - Authentication/authorization

### Data Layer Cluster
- `global/validation.md` ↔ `backend/models.md` - Layered validation (API + DB)
- `backend/queries.md` ↔ `global/security.md` - SQL injection prevention
- `backend/queries.md` ↔ `global/performance.md` - Query optimization

### Frontend Cluster
- `frontend/components.md` ↔ `global/error-handling.md` - Error boundaries
- `frontend/components.md` ↔ `frontend/accessibility.md` - Accessible component design
- `frontend/components.md` ↔ `frontend/css.md` - Component styling patterns
- `frontend/responsive.md` ↔ `global/performance.md` - Core Web Vitals
- `frontend/responsive.md` ↔ `frontend/css.md` - Responsive styling methodology
- `frontend/accessibility.md` ↔ `testing/test-writing.md` - Accessibility testing
- `frontend/css.md` ↔ `global/performance.md` - CSS optimization and purging

### Code Quality Cluster
- `global/coding-style.md` ↔ `global/commenting.md` - Code clarity and documentation
- `global/coding-style.md` ↔ `global/conventions.md` - Team standards consistency
