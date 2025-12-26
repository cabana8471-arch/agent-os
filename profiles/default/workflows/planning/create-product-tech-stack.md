# Create Product Tech Stack

## Purpose

Document all technology stack choices for the product, reconciling user preferences with project requirements.

## Workflow

### Step 1: Note User's Input Regarding Tech Stack

IF the user has provided specific information in the current conversation in regards to tech stack choices, these notes ALWAYS take precedence. These must be reflected in your final `tech-stack.md` document that you will create.

### Step 2: Gather User's Default Tech Stack Information

Reconcile and fill in the remaining gaps in the tech stack list by finding, reading and analyzing information regarding the tech stack. Find this information in the following sources, in this order:

1. If user has provided their default tech stack under "User Standards & Preferences Compliance", READ and analyze this document.
2. If the current project has any of these files, read them to find information regarding tech stack choices for this codebase:
   - `claude.md`
   - `agents.md`

### Step 3: Create the Tech Stack Document

Create `agent-os/product/tech-stack.md` and populate it with the final list of all technical stack choices, reconciled between the information the user has provided to you and the information found in provided sources.

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

After creating the tech stack document, return ONLY this summary:

```
✅ Tech stack documented.
📁 Report: agent-os/product/tech-stack.md
📊 Summary: Frontend, Backend, DB, Auth, Deploy, Tools defined
⏱️ Next: Ready for specification phase
```

**Do NOT include** full tech stack details or library versions in the conversation response.

## Important Constraints

- User-provided tech stack choices always take precedence over defaults
- Document both the choice and the rationale where possible
- Include version numbers for critical dependencies
- Note any deviations from standard/default choices

## Pre-conditions

Before running this workflow:
- [ ] Product mission exists at `agent-os/product/mission.md` (or user provides tech requirements directly)
- [ ] User has confirmed or provided tech stack preferences

## Error Recovery

If tech stack documentation encounters issues:
1. **No tech stack preferences provided:** Use sensible defaults based on project type, document as "default choice"
2. **Conflicting choices:** Ask user to clarify (e.g., React vs Vue)
3. **Missing CLAUDE.md or agents.md:** Proceed with user-provided preferences only
4. **Outdated versions:** Flag deprecated dependencies and suggest modern alternatives

For other errors, refer to `{{workflows/implementation/error-recovery}}`
