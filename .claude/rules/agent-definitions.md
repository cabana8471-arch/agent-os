---
paths: profiles/*/agents/*.md
---

# Reguli Definiții Agenți

## YAML Frontmatter Obligatoriu
```yaml
name: nume-agent
description: Descriere scurtă
tools: [Write, Read, Bash, WebFetch, Skill, Grep, Glob, Playwright]
color: culoare-unică
model: opus|sonnet|haiku|inherit
```

## Cei 14 Agenți
**Core (8):** product-planner, spec-initializer, spec-shaper, spec-writer, tasks-list-creator, implementer, implementation-verifier, spec-verifier

**Extended (6):** code-reviewer, test-strategist, documentation-writer, dependency-manager, refactoring-advisor, feature-analyst

## Strategia de Modele
- **opus** - Analiză complexă: code-reviewer, refactoring-advisor, feature-analyst
- **sonnet** - Moderate: spec-initializer, spec-verifier, test-strategist, documentation-writer
- **haiku** - Simple/tool-heavy: dependency-manager
- **inherit** - Pipeline principal (moștenește de la parent)

## Culori Unice (14)
cyan, green, blue, purple, orange, red, pink, olive, yellow, lime, teal, gray, magenta, indigo
