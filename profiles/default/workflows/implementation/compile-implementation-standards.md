# Compile Implementation Standards

## Purpose

Compile a list of standard file references that should guide implementation based on the current task group configuration.

## Workflow

### Step 1: Identify Standards Configuration

1. Find the current task group in `orchestration.yml`
2. Check the list of `standards` specified for this task group in `orchestration.yml`
3. Compile the list of file references to those standards, one file reference per line, using this logic for determining which files to include:
   a. If the value for `standards` is simply `all`, then include every single file, folder, sub-folder and files within sub-folders in your list of files.
   b. If the item under standards ends with "*" then it means that all files within this folder or sub-folder should be included. For example, `frontend/*` means include all files and sub-folders and their files located inside of `agent-os/standards/frontend/`.
   c. If a file ends in `.md` then it means this is one specific file you must include in your list of files. For example `backend/api.md` means you must include the file located at `agent-os/standards/backend/api.md`.
   d. De-duplicate files in your list of file references.

### Step 2: Generate File References

The compiled list of standards should look something like this, where each file reference is on its own line and begins with `@`. The exact list of files will vary:

```
@agent-os/standards/global/coding-style.md
@agent-os/standards/global/conventions.md
@agent-os/standards/global/tech-stack.md
@agent-os/standards/backend/api.md
@agent-os/standards/backend/models.md
@agent-os/standards/backend/queries.md
@agent-os/standards/frontend/css.md
@agent-os/standards/frontend/responsive.md
```

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Standards compiled.
📁 Data: [X] standard files referenced
📊 Categories: [list of categories included, e.g., global, backend, frontend]
⏱️ Ready: Pass references to implementer
```

**Do NOT include** the full list of file references in the conversation response. The file references should be passed internally to the implementing agent.

## Important Constraints

- Always de-duplicate file references
- Use `@` prefix for all file references
- Include all files in subfolders when using `*` wildcard
- `global/*` standards should typically be included for all task types

## Pre-conditions

Before running this workflow:
- [ ] `orchestration.yml` exists with task group configuration
- [ ] Standards folder exists at `agent-os/standards/`

## Error Recovery

If standards compilation encounters issues:
1. **orchestration.yml not found:** Use default standards (global/*)
2. **Standards folder missing:** Proceed without standards, notify user
3. **Invalid standards path:** Skip invalid entries, document skipped items

For other errors, refer to `{{workflows/implementation/error-recovery}}`
