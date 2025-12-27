
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Agent OS is a spec-driven agentic development framework that provides structured workflows, standards, and commands to help AI coding agents (Claude Code, Cursor, Windsurf) develop software more effectively. It's not a traditional application—it's a system of Bash scripts, YAML configuration, and Markdown templates that get installed into target projects.

**Language:** Bash (shell scripts) + Markdown (templates/documentation)
**License:** MIT
**Creator:** Brian Casel @ Builder Methods

## Key Commands

### Installing Agent OS into a project
```bash
~/agent-os/scripts/project-install.sh [OPTIONS]
```

Common flags:
- `--profile PROFILE` - Use a specific profile (default: from config.yml)
- `--claude-code-commands true/false` - Install Claude Code commands
- `--use-claude-code-subagents true/false` - Enable subagent delegation
- `--agent-os-commands true/false` - Install for Cursor/Windsurf
- `--standards-as-claude-code-skills true/false` - Use Claude Code Skills feature
- `--dry-run` - Preview changes without executing
- `--verbose` - Show detailed output
- `--re-install` - Delete and reinstall
- `--overwrite-all` - Overwrite all existing files
- `--overwrite-standards` - Overwrite only standards files
- `--overwrite-commands` - Overwrite only command files
- `--overwrite-agents` - Overwrite only agent files

### Updating an existing installation
```bash
~/agent-os/scripts/project-update.sh [OPTIONS]
```
Same flags as project-install.sh, plus handles version updates.

### Creating a new profile
```bash
~/agent-os/scripts/create-profile.sh
```
Interactive script to create customized profiles.

## Architecture

### Six Development Phases
Agent OS organizes development into sequential phases:
1. **plan-product** - Define mission, roadmap, tech stack
2. **shape-spec** - Refine feature ideas into requirements
3. **write-spec** - Create detailed specification documents
4. **create-tasks** - Break specs into implementation tasks
5. **implement-tasks** - Implement tasks with agents
6. **orchestrate-tasks** - Multi-agent coordination for complex features

### Agent System (`profiles/default/agents/`)
Fourteen specialized agents with YAML frontmatter defining metadata (name, description, tools, color, model):

**Core Development Agents (8):**
- `product-planner` - Plans product mission and roadmap
- `spec-initializer` - Initializes spec folder structure
- `spec-shaper` - Refines and shapes feature requirements
- `spec-writer` - Writes detailed specifications
- `tasks-list-creator` - Creates prioritized task lists
- `implementer` - Implements tasks following specs
- `implementation-verifier` - Verifies implementation completeness
- `spec-verifier` - Verifies specification quality

**Extended Support Agents (6):**
- `code-reviewer` - Reviews code for quality, security, and standards compliance
- `test-strategist` - Designs test strategies, analyzes coverage gaps
- `documentation-writer` - Generates and updates technical documentation
- `dependency-manager` - Audits and manages project dependencies
- `refactoring-advisor` - Identifies technical debt and refactoring opportunities
- `feature-analyst` - Discovers existing features, proposes new ones, prevents duplicates

#### Model Assignment Strategy

Agents are configured with specific models based on task complexity:

- **opus**: Agents requiring deep reasoning and complex analysis
  - `code-reviewer` - Comprehensive review, vulnerability detection
  - `refactoring-advisor` - Architectural analysis, technical debt identification
  - `feature-analyst` - Feature discovery, pattern recognition, duplicate prevention

- **sonnet** (default for subagents): Moderate complexity tasks
  - `spec-initializer` - Simple structure creation
  - `spec-verifier` - Checklist verification
  - `test-strategist` - Test strategy design
  - `documentation-writer` - Documentation generation

- **haiku**: Simple, repetitive, cost-efficient tasks
  - `dependency-manager` - Dependency audits (mostly tool calls)

- **inherit**: Inherits from parent (used for main agents in the pipeline)

#### Agent Tools Matrix

| Agent | Write | Read | Bash | WebFetch | Skill | Grep | Glob | Playwright |
|-------|-------|------|------|----------|-------|------|------|------------|
| product-planner | ✓ | ✓ | ✓ | ✓ | - | - | - | - |
| spec-initializer | ✓ | ✓ | ✓ | - | - | - | - | - |
| spec-shaper | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| spec-writer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| spec-verifier | ✓ | ✓ | ✓ | ✓ | ✓ | - | - | - |
| tasks-list-creator | ✓ | ✓ | ✓ | ✓ | ✓ | - | - | - |
| implementer | ✓ | ✓ | ✓ | ✓ | ✓ | - | - | ✓ |
| implementation-verifier | ✓ | ✓ | ✓ | ✓ | ✓ | - | - | ✓ |
| code-reviewer | ✓ | ✓ | ✓ | ✓ | - | ✓ | ✓ | - |
| test-strategist | ✓ | ✓ | ✓ | ✓ | - | ✓ | ✓ | - |
| documentation-writer | ✓ | ✓ | ✓ | ✓ | - | ✓ | ✓ | - |
| dependency-manager | ✓ | ✓ | ✓ | ✓ | - | ✓ | ✓ | - |
| refactoring-advisor | ✓ | ✓ | ✓ | - | - | ✓ | ✓ | - |
| feature-analyst | ✓ | ✓ | ✓ | ✓ | - | ✓ | ✓ | - |

#### Agent Color Assignments (AOS-0060)

Each agent has a unique color in its frontmatter for visual identification in UIs that support agent colors. The 14 distinct colors (cyan, green, blue, purple, orange, red, pink, olive, yellow, lime, teal, gray, magenta, indigo) are intentional to help users quickly distinguish between different agent types during orchestrated workflows.

### Standards System (`profiles/default/standards/`)
19 standard template files across 4 categories (including _index.md):
- `global/` - tech-stack, coding-style, conventions, validation, commenting, error-handling, logging, performance, security
- `backend/` - api, models, queries, migrations
- `frontend/` - components, css, responsive, accessibility
- `testing/` - test-writing

### Workflows (`profiles/default/workflows/`)
Step-by-step instructions organized by phase:
- `planning/` - gather-product-info, create-product-mission, create-product-roadmap, create-product-tech-stack
- `specification/` - initialize-spec, research-spec, write-spec, verify-spec, update-spec
- `implementation/` - implement-tasks, create-tasks-list, compile-implementation-standards, error-recovery, rollback, verification/*
- `review/` - code-review
- `testing/` - test-strategy
- `documentation/` - generate-docs
- `maintenance/` - dependency-audit, refactoring-analysis
- `analysis/` - feature-analysis

### Commands (`profiles/default/commands/`)
Claude Code commands with single-agent and multi-agent variants for each development phase.

**Core Development Commands:**
- `/plan-product` - Define product mission, roadmap, tech stack
- `/shape-spec` - Initialize and shape feature requirements
- `/write-spec` - Create detailed specification documents
- `/create-tasks` - Break specs into implementation tasks
- `/implement-tasks` - Implement tasks with agents (includes code review)
- `/orchestrate-tasks` - Multi-agent coordination with smart assignment

**Extended Support Commands:**
- `/review-code` - Perform code review for quality, security, standards
- `/verify-spec` - Verify spec completeness before implementation
- `/update-spec` - Update specifications after initial creation (change requests, corrections)
- `/test-strategy` - Design test plans and coverage strategies
- `/generate-docs` - Generate API docs, README, changelog
- `/audit-deps` - Security audit and dependency health check
- `/analyze-refactoring` - Identify technical debt and improvements
- `/analyze-features` - Discover existing features, propose new ones, check for duplicates
- `/rollback` - Revert changes to a known-good state (code, spec, or database rollback)
- `/improve-skills` - Improve Claude Code Skills descriptions for better discoverability

### Profiles System
Profiles are customizable configuration sets in `profiles/`. The `default` profile provides all templates. Custom profiles can inherit from others and override specific files.

#### Available Profiles

| Profile | Inherits From | Purpose |
|---------|---------------|---------|
| `default` | - | Base profile with complete Agent OS setup |
| `nextjs` | default | Next.js App Router specific standards |
| `react` | default | Frontend-only React library standards |
| `seo-nextjs-drizzle` | nextjs | Next.js + Drizzle ORM + BetterAuth |
| `wordpress` | default | WordPress plugin/theme development |
| `woocommerce` | wordpress | WooCommerce e-commerce development |

#### Profile Inheritance

Profiles support inheritance via `profile-config.yml`:
- `inherits_from` - specifies the parent profile to inherit from
- `exclude_inherited_files` - array of files to exclude from parent

Inheritance hierarchy:
```
default (root)
├── nextjs → seo-nextjs-drizzle
├── react
└── wordpress → woocommerce
```

### Protocols System (`profiles/default/protocols/`)
Reusable protocol definitions for consistent behavior:
- `output-protocol.md` - Context optimization rules (write to file, return summary)
- `issue-tracking.md` - Issue ID system (SEC-001, BUG-015, etc.)
- `verification-checklist.md` - Quality gate checklists for each phase

## Configuration

`config.yml` controls installation behavior:
- `version` - Agent OS version
- `base_install` - Perform base installation
- `claude_code_commands` - Install Claude Code commands
- `use_claude_code_subagents` - Enable subagent delegation
- `agent_os_commands` - Install for other tools (Cursor, Windsurf)
- `standards_as_claude_code_skills` - Use Claude Code Skills feature
- `lazy_load_workflows` - Use file references instead of embedding workflows (context optimization)
- `profile` - Default profile to use

## Context Optimization

Agent OS includes features to reduce context window usage by ~75-90%:

### Lazy Loading Workflows
When `lazy_load_workflows: true` in config.yml:
- Workflows are referenced as `@agent-os/workflows/path.md` instead of embedded
- Agents read workflow files on-demand when needed
- Reduces agent file size from ~750 lines to ~56 lines (92% reduction)

### Output Protocol
Workflows follow the output protocol (`profiles/default/protocols/output-protocol.md`):
- Write detailed reports to files (e.g., `agent-os/specs/[spec]/implementation/code-review.md`)
- Return only 3-5 line summaries to conversation
- Format: `✅ [Phase] complete. 📁 Report: [path] 📊 Summary: [metrics]`

### Issue Tracking Protocol
Code review and analysis use structured issue IDs:
- Format: `[CATEGORY]-[NUMBER]` (e.g., SEC-001, BUG-015, PERF-003)
- Categories: SEC, BUG, PERF, QUAL, DOC, TEST, ARCH, DEP, FEAT, DUP, GAP
- Severity: CRITICAL, HIGH, MEDIUM, LOW

## Template Syntax

Agent templates use mustache-style syntax:
- `{{workflows/path}}` - Include workflow content (or reference if lazy loading)
- `{{protocols/path}}` - Include protocol reference
- `{{standards/*}}` - Include all standards
- `{{IF flag}}...{{ENDIF flag}}` - Include content when flag is true
- `{{UNLESS flag}}...{{ENDUNLESS flag}}` - Include content when flag is false
- `{{PHASE X: @agent-os/commands/path}}` - Multi-agent phase embedding (embeds compiled command file through full pipeline)

## Key Scripts

- `scripts/common-functions.sh` - Shared utilities (YAML parsing, file operations, profile inheritance)
- `scripts/project-install.sh` - Main installation script
- `scripts/project-update.sh` - Update script with version handling
- `scripts/create-profile.sh` - Profile creation wizard
