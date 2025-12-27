# Task List Creation Process

You are creating a tasks breakdown from a given spec and requirements for a new feature.

## PHASE 1: Get and read the spec.md and/or requirements document(s)

You will need ONE OR BOTH of these files to inform your tasks breakdown:
- `agent-os/specs/[spec-path]/spec.md`
- `agent-os/specs/[spec-path]/planning/requirements.md`

IF you don't have ONE OR BOTH of those files in your current conversation context, then ask user to provide direction on where to you can find them by outputting the following request then wait for user's response:

```
I'll need a spec.md or requirements.md (or both) in order to build a tasks list.

Please direct me to where I can find those.  If you haven't created them yet, you can run /shape-spec or /write-spec.
```

## PHASE 2: Create tasks.md

Once you have `spec.md` AND/OR `requirements.md`, use the **tasks-list-creator** subagent to break down the spec and requirements into an actionable tasks list with strategic grouping and ordering.

Provide the tasks-list-creator:
- `agent-os/specs/[spec-path]/spec.md` (if present)
- `agent-os/specs/[spec-path]/planning/requirements.md` (if present)
- `agent-os/specs/[spec-path]/planning/visuals/` and its' contents (if present)

The tasks-list-creator will create `tasks.md` inside the spec folder.

{{UNLESS standards_as_claude_code_skills}}
## Standards for Subagent

IMPORTANT: When delegating to the tasks-list-creator subagent, ensure you pass the following standards context so the tasks align with the user's preferred tech stack and conventions:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

## PHASE 3: Inform user

Once the tasks-list-creator has created `tasks.md` output the following to inform the user:

```
Your tasks list is ready!

Tasks list created: `agent-os/specs/[spec-path]/tasks.md`

OPTIONAL: Run `/test-strategy` to design your test plan before implementation.

NEXT STEP 👉 Run `/implement-tasks` (simple) or `/orchestrate-tasks` (advanced) to start building!
```
