---
paths: scripts/*.sh
---

# Reguli Scripturi Bash

## Fișiere Principale
- `common-functions.sh` - Utilități partajate (YAML parsing, file ops, profile inheritance)
- `project-install.sh` - Instalare Agent OS în proiecte
- `project-update.sh` - Actualizare cu version handling
- `create-profile.sh` - Wizard creare profile

## Convenții
- Folosește funcții din `common-functions.sh` pentru operații comune
- Validează input cu getopts/getopt
- Exit codes: 0 success, 1 error, 2 usage error
- Parsează YAML cu funcțiile dedicate din common-functions.sh

## Flag-uri Comune (project-install.sh, project-update.sh)
`--profile`, `--claude-code-commands`, `--use-claude-code-subagents`, `--agent-os-commands`,
`--standards-as-claude-code-skills`, `--lazy-load-workflows`, `--dry-run`, `--verbose`,
`--re-install`, `--overwrite-all`, `--overwrite-standards`, `--overwrite-commands`, `--overwrite-agents`
