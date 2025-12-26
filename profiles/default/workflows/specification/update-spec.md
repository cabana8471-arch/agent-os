# Spec Update Workflow

## Core Responsibilities

1. **Understand Change Request**: Clarify what needs to be updated and why
2. **Assess Impact**: Determine which documents and tasks are affected
3. **Update Documents**: Modify spec, requirements, and tasks as needed
4. **Maintain Traceability**: Document all changes for audit trail

## When to Use This Workflow

Use this workflow when:
- User requests changes to requirements after spec is written
- New requirements are discovered during implementation
- Spec verification identifies issues that require spec changes
- Scope needs to be adjusted (expand or reduce)
- Technical constraints require specification modifications

## Pre-conditions

Before running this workflow:
- [ ] Original spec exists at `[spec-path]/spec.md`
- [ ] Change request is clearly defined (from user or from verification)
- [ ] Understand the source of the change (user request, technical constraint, verification finding)

## Workflow

### Step 1: Document the Change Request

Create or update `[spec-path]/planning/change-log.md`:

```markdown
# Spec Change Log

## Change Request: [Date]

### Source
- [ ] User request
- [ ] Implementation discovery
- [ ] Spec verification finding
- [ ] Technical constraint
- [ ] Code review feedback

### Description
[Detailed description of what needs to change and why]

### Requested By
[User / Agent name / Workflow name]
```

### Step 2: Assess Impact

Analyze which documents are affected:

```bash
# List all spec documents
ls -la agent-os/specs/[spec-path]/
ls -la agent-os/specs/[spec-path]/planning/
```

Determine impact on:

| Document | Likely Affected? | Check For |
|----------|------------------|-----------|
| `requirements.md` | Yes if scope changes | New requirements, removed requirements |
| `spec.md` | Usually yes | Goal, user stories, requirements sections |
| `tasks.md` | Yes if implementation changes | New tasks, removed tasks, modified tasks |
| `initialization.md` | Rarely | Only if original idea changes |

### Step 3: Update Requirements (if needed)

If the change affects requirements, update `[spec-path]/planning/requirements.md`:

1. **Add new requirements** in appropriate section
2. **Mark removed requirements** with strikethrough and note:
   ```markdown
   ~~Original requirement~~ *[Removed: Date - Reason]*
   ```
3. **Modify existing requirements** and add change note:
   ```markdown
   Updated requirement text *[Modified: Date - Reason]*
   ```

### Step 4: Update Specification

Modify `[spec-path]/spec.md`:

1. **Update affected sections** (Goal, User Stories, Requirements, etc.)
2. **Add change note** at the top of the file:
   ```markdown
   > **Last Updated**: [Date]
   > **Changes**: [Brief description of what changed]
   ```
3. **Maintain consistency** with requirements.md

### Step 5: Update Tasks (if needed)

If implementation is affected, update `[spec-path]/tasks.md`:

1. **Add new tasks** for new requirements
2. **Remove or mark tasks** that are no longer needed:
   ```markdown
   - [REMOVED] ~~Task description~~ *[Reason]*
   ```
3. **Modify existing tasks** to reflect new requirements
4. **Re-evaluate dependencies** between task groups
5. **Update task counts** in Overview section

### Step 6: Handle In-Progress Implementation

If implementation has already started:

1. **Check tasks.md for completed tasks**
   ```bash
   grep -c "\- \[x\]" agent-os/specs/[spec-path]/tasks.md
   ```

2. **Assess if completed work needs to be modified**
   - If yes: Create follow-up tasks for modifications
   - If no: Continue with remaining tasks

3. **Notify implementer** of changes via output message

### Step 7: Document Changes

Add entry to `[spec-path]/planning/change-log.md`:

```markdown
## Change Applied: [Date]

### Documents Updated
- [x] requirements.md - [Brief description]
- [x] spec.md - [Brief description]
- [x] tasks.md - [Brief description]

### Summary of Changes
- Added: [List new items]
- Removed: [List removed items]
- Modified: [List modified items]

### Implementation Impact
- [ ] No implementation impact (spec not yet implemented)
- [ ] Implementation in progress - [X] tasks affected
- [ ] Implementation complete - follow-up tasks created

### Verification Required
- [ ] Re-run spec verification
- [ ] Update any existing verification reports
```

### Step 8: Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Spec update complete.
📁 Report: [spec-path]/planning/change-log.md
📊 Summary: +[X] added | -[Y] removed | ~[Z] modified
⏱️ Next: Run /verify-spec to validate changes
```

**Do NOT include** detailed change lists, affected documents, or next steps in the conversation response.

## Important Constraints

- **Never delete original content** - Use strikethrough and notes for removed items
- **Maintain audit trail** - All changes must be documented in change-log.md
- **Preserve completed work** - Don't invalidate already-completed tasks unless absolutely necessary
- **Re-verify after significant changes** - Run spec verification if changes are substantial
- **Communicate impact clearly** - Ensure implementers understand what changed
- **Keep changes focused** - Each update session should address one change request
- **Version awareness** - Note which version of spec documents were modified

## Error Recovery

If you encounter issues during spec update:

1. **Conflicting Changes**: Document both versions, ask user to clarify intent
2. **Missing Original Spec**: Cannot update; recommend running write-spec workflow first
3. **Broken Dependencies**: Note which tasks depend on changed requirements, flag for review
4. **Implementation Already Complete**: Create follow-up modification tasks rather than invalidating completed work
5. **User Unavailable for Clarification**: Document ambiguity, proceed with safest interpretation, flag for review
6. **Large Scope Change**: Consider if this should be a new spec rather than an update

For implementation-related errors, refer to `{{workflows/implementation/error-recovery}}`
