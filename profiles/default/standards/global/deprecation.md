> **Related Standards**: See `global/conventions.md` for versioning practices, `global/commenting.md` for deprecation notices in code.

## Standard Deprecation Process

This document defines the process for deprecating standards, patterns, or technologies in the project.

### Deprecation Lifecycle

1. **Announcement**: Document the deprecation in relevant standards and changelog
2. **Warning Period**: Maintain backward compatibility while showing deprecation warnings
3. **Migration Support**: Provide migration guides and tooling
4. **Removal**: Remove deprecated items after adequate transition time

### Marking as Deprecated

When deprecating a standard or pattern:

```markdown
> **DEPRECATED**: This pattern is deprecated as of [date].
> Use [alternative] instead. Will be removed in [version/date].
> Migration guide: [link or instructions]
```

### Deprecation Checklist

- [ ] Document reason for deprecation
- [ ] Identify replacement/alternative approach
- [ ] Create migration guide if needed
- [ ] Set removal timeline (minimum 2 major versions or 3 months)
- [ ] Add deprecation notice to affected files
- [ ] Update _toc.md to mark deprecated items
- [ ] Notify team/stakeholders

### Standard Lifecycle States

| State | Description |
|-------|-------------|
| **Active** | Current recommended approach |
| **Deprecated** | Still functional but not recommended for new code |
| **Removed** | No longer available; migration required |

### Timeline Guidelines

| Category | Warning Period | Notes |
|----------|---------------|-------|
| Minor patterns | 1 month | Small utility patterns |
| Major standards | 3 months | Core architectural patterns |
| Security-related | Immediate | No warning period for security issues |
| Technologies | 6 months | Framework/library changes |

### Migration Documentation

When deprecating, provide:

1. **Why**: Reason for deprecation
2. **What**: Specific items being deprecated
3. **When**: Timeline for removal
4. **How**: Step-by-step migration instructions
5. **Help**: Resources and support contacts

### Versioning Standards

Consider using semantic versioning principles:

- **Patch**: Documentation fixes, clarifications
- **Minor**: New standards, backward-compatible changes
- **Major**: Breaking changes, removals, significant restructuring

### Review Process

Before removing deprecated items:

1. Check for remaining usage in codebase
2. Verify migration guide accuracy
3. Confirm team awareness
4. Document in changelog
5. Update dependent documentation
