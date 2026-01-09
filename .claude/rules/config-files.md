---
paths: "*.yml,*.yaml,config.yml,profile-config.yml"
---

# Reguli Fișiere Configurare

## config.yml (Root)
```yaml
version: X.Y.Z
base_install: true/false
claude_code_commands: true/false
use_claude_code_subagents: true/false
agent_os_commands: true/false
standards_as_claude_code_skills: true/false
lazy_load_workflows: true/false
profile: default|nextjs|react|wordpress|etc
```

## profile-config.yml (În fiecare profil)
```yaml
inherits_from: parent-profile-name
exclude_inherited_files:
  - file/to/exclude.md
```

## Ierarhie Inheritance
```
default (root)
├── nextjs → seo-nextjs-drizzle
├── react
└── wordpress → woocommerce
```

## Context Optimization
- `lazy_load_workflows: true` - Referințe @agent-os/workflows/* în loc de embedding (92% reducere)
