---
paths: profiles/**/*.md
---

# Reguli Template-uri Profile

## Sintaxă Mustache
- `{{workflows/path}}` - Include workflow (sau referință dacă lazy_load)
- `{{protocols/path}}` - Include protocol
- `{{standards/*}}` - Include toate standardele
- `{{IF flag}}...{{ENDIF flag}}` - Condiții (when flag=true)
- `{{UNLESS flag}}...{{ENDUNLESS flag}}` - Condiții (when flag=false)
- `{{PHASE X: @agent-os/commands/path}}` - Multi-agent phase embedding

## Categorii Standards (profiles/*/standards/)
- `global/` - tech-stack, coding-style, conventions, security, etc.
- `backend/` - api, models, queries, migrations
- `frontend/` - components, css, routing, state-management
- `testing/` - test-writing

## Convenții
- Fișierele `_index.md` și `_toc.md` sunt speciale (index/table of contents)
