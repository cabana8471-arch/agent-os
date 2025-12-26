# Implement Tasks

## Purpose

Execute implementation of assigned tasks following specifications, standards, and existing codebase patterns.

## Pre-conditions

- [ ] Spec exists at `agent-os/specs/[spec-path]/spec.md`
- [ ] Requirements documented at `agent-os/specs/[spec-path]/planning/requirements.md`
- [ ] Tasks list exists at `agent-os/specs/[spec-path]/tasks.md`
- [ ] Implementation standards have been compiled (if using orchestration)

## Workflow

### Step 1: Analyze Requirements

1. Read the provided `spec.md`, `requirements.md`, and visuals (if any)
2. Analyze patterns in the codebase according to its built-in workflow
3. Identify the specific task group assigned to you

### Step 2: Implement Tasks

Implement the assigned task group according to requirements and standards.

**Guide your implementation using:**
- **The existing patterns** that you've found and analyzed in the codebase
- **Specific notes provided in requirements.md, spec.md AND/OR tasks.md**
- **Visuals provided (if any)** which would be located in `agent-os/specs/[spec-path]/planning/visuals/`
- **User Standards & Preferences** which are defined below

### Step 3: Update Task Status

Update `agent-os/specs/[spec-path]/tasks.md` to mark implemented tasks as done by updating their checkbox to checked state: `- [x]`

### Step 4: Self-Verify

Self-verify and test your work by:
- Running ONLY the tests you've written (if any) and ensuring those tests pass
- IF your task involves user-facing UI, and IF you have access to browser testing tools, open a browser and use the feature you've implemented as if you are a user to ensure a user can use the feature in the intended way
  - Take screenshots of the views and UI elements you've tested and store those in `agent-os/specs/[spec-path]/verification/screenshots/`. Do not store screenshots anywhere else in the codebase other than this location
  - Analyze the screenshot(s) you've taken to check them against your current requirements

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

After completing implementation, write a detailed summary to `agent-os/specs/[spec-path]/implementation/summary.md`, then return ONLY this to the conversation:

```
✅ Implementation complete.
📁 Report: agent-os/specs/[spec-path]/implementation/summary.md
📊 Summary: [X] tasks completed | [X] files modified
⏱️ Status: Ready for code review
```

**Do NOT include** full task lists, file contents, or detailed descriptions in the conversation response.

## Important Constraints

- Implement ONLY the tasks assigned to you
- Follow existing codebase patterns
- Store screenshots only in `verification/screenshots/`
- Mark tasks complete in `tasks.md` immediately after implementation

## Error Recovery

If implementation encounters issues:
1. **Missing requirements:** Check `spec.md` and `requirements.md` for clarification
2. **Conflicting patterns:** Follow the most recent pattern in the codebase
3. **Test failures:** Fix implementation before marking task complete
4. **Blocked by dependencies:** Document blocker and notify orchestrator

For other errors, refer to `{{workflows/implementation/error-recovery}}`
