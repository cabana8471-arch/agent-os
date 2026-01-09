---
paths: profiles/*/workflows/**/*.md
---

# Reguli Workflow-uri

## Categorii Workflow-uri
- `planning/` - gather-product-info, create-product-mission, create-product-roadmap, create-product-tech-stack
- `specification/` - initialize-spec, research-spec, write-spec, verify-spec, update-spec
- `implementation/` - implement-tasks, create-tasks-list, compile-implementation-standards, error-recovery, rollback
- `review/` - code-review
- `testing/` - test-strategy
- `documentation/` - generate-docs
- `maintenance/` - dependency-audit, refactoring-analysis
- `analysis/` - feature-analysis

## Output Protocol
- Scrie rapoarte detaliate în fișiere (ex: `agent-os/specs/[spec]/implementation/code-review.md`)
- Returnează doar sumar 3-5 linii în conversație
- Format: `✅ [Phase] complete. 📁 Report: [path] 📊 Summary: [metrics]`

## Issue Tracking Protocol
- Format: `[CATEGORY]-[NUMBER]` (ex: SEC-001, BUG-015)
- Categorii: SEC, BUG, PERF, QUAL, DOC, TEST, ARCH, DEP, FEAT, DUP, GAP
- Severity: CRITICAL, HIGH, MEDIUM, LOW
