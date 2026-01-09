# Agent OS

Spec-driven agentic development framework. Bash scripts + Markdown templates.

## Comenzi
- `~/agent-os/scripts/project-install.sh` - Instalare
- `~/agent-os/scripts/project-update.sh` - Actualizare
- `~/agent-os/scripts/create-profile.sh` - Creare profil

## 6 Faze
plan-product → shape-spec → write-spec → create-tasks → implement-tasks → orchestrate-tasks

## Agenți (14)
**Core:** product-planner, spec-initializer, spec-shaper, spec-writer, tasks-list-creator, implementer, implementation-verifier, spec-verifier
**Extended:** code-reviewer, test-strategist, documentation-writer, dependency-manager, refactoring-advisor, feature-analyst

## Comenzi Claude Code
**Core:** /plan-product, /shape-spec, /write-spec, /create-tasks, /implement-tasks, /orchestrate-tasks
**Extended:** /review-code, /verify-spec, /update-spec, /test-strategy, /generate-docs, /audit-deps, /analyze-refactoring, /analyze-features, /rollback

## Structură
- `profiles/` - Profiluri: default, nextjs, react, wordpress, woocommerce, seo-nextjs-drizzle
- `scripts/` - common-functions.sh, project-install.sh, project-update.sh
- `config.yml` - Configurație globală

## Context Optimization
- `lazy_load_workflows: true` în config.yml reduce context cu 92%
- Output protocol: rapoarte în fișiere, sumar în conversație

Detalii suplimentare în `.claude/rules/` (încărcate selectiv pe bază de paths).
