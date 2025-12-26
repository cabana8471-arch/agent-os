# Update Roadmap Workflow

## Core Responsibilities

1. **Verify Completion Prerequisites**: Ensure all verification steps have passed
2. **Match Spec to Roadmap**: Find the roadmap item(s) that correspond to this spec
3. **Update Roadmap Status**: Mark completed items appropriately
4. **Document the Update**: Record when and why the roadmap was updated

## Pre-conditions

Before running this workflow, ALL of the following must be true:

- [ ] All tasks in `[spec-path]/tasks.md` are marked complete `[x]`
- [ ] Code review status is "Approved" or "Approved with Comments"
- [ ] Full test suite has been run (via run-all-tests workflow)
- [ ] No critical issues remain unresolved
- [ ] Final verification report exists at `[spec-path]/verification/final-verification.md`

**IMPORTANT**: Do NOT mark roadmap items complete if any pre-condition is not met.

## Workflow

### Step 1: Verify Pre-conditions

Check that all prerequisites are satisfied:

```bash
# Check tasks completion
echo "Incomplete tasks:"
grep -c "\- \[ \]" agent-os/specs/[spec-path]/tasks.md || echo "0"

# Check code review exists and status
cat agent-os/specs/[spec-path]/implementation/code-review.md 2>/dev/null | grep "Overall Status" || echo "No code review found"

# Check final verification report exists
ls agent-os/specs/[spec-path]/verification/final-verification.md 2>/dev/null || echo "No verification report"
```

IF any check fails:
- STOP the workflow
- Report which pre-condition is not met
- Do NOT update the roadmap

### Step 2: Load Spec Information

Read the spec to understand what feature was implemented:

```bash
# Get spec title and goal
head -20 agent-os/specs/[spec-path]/spec.md
```

Extract:
- Feature name
- Goal/objective
- Key deliverables

### Step 3: Match with Roadmap Items

Open `agent-os/product/roadmap.md` and find items that match:

```bash
cat agent-os/product/roadmap.md
```

Look for:
- Items with matching feature name
- Items with matching description
- Items that are currently unchecked `[ ]`

### Step 4: Validate Match

Before marking complete, verify the match is accurate:

1. **Feature name** matches or is clearly related
2. **Scope** of implementation covers the roadmap item's requirements
3. **No partial completion** - the entire roadmap item should be complete

IF the spec only partially implements a roadmap item:
- Do NOT mark the item complete
- Add a note about progress made
- Document what remains to be done

### Step 5: Update Roadmap

For each matching roadmap item that is FULLY implemented:

```markdown
# Before
1. [ ] User Authentication — Implement login, registration, and session management `M`

# After
1. [x] User Authentication — Implement login, registration, and session management `M`
```

### Step 6: Add Completion Notes

Add a note at the bottom of the roadmap (or in a separate section) documenting the update:

```markdown
## Completion Log

| Date | Item | Spec |
|------|------|------|
| YYYY-MM-DD | User Authentication | [spec-path] |
```

### Step 7: Output Confirmation

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Roadmap updated.
📁 Report: agent-os/product/roadmap.md
📊 Summary: [X] item(s) marked complete
⏱️ Status: All pre-conditions verified
```

OR if no update was made:

```
⚠️ Roadmap NOT updated.
📁 Report: agent-os/product/roadmap.md
📊 Reason: [Pre-condition not met / No matching item / Partial only]
⏱️ Action: [What needs to happen first]
```

**Do NOT include** detailed pre-condition checks, item descriptions, or completion logs in the conversation response.

## Important Constraints

- **NEVER mark roadmap items complete prematurely** - All pre-conditions must be met
- **NEVER mark partial implementations complete** - The entire feature must be done
- **Always verify the match** between spec and roadmap item before updating
- **Document all updates** for audit trail
- **If uncertain**, leave the item unchecked and note the uncertainty
- This workflow should only be run AFTER all other verification workflows

## Error Recovery

If roadmap update encounters issues:
1. **Pre-conditions not met:** Document which pre-condition failed and stop
2. **Roadmap.md not found:** Check if `/plan-product` was run, prompt user to create roadmap
3. **No matching roadmap item:** The feature may have been ad-hoc - document completion separately
4. **Partial implementation only:** Do not update roadmap, create follow-up tasks for remaining work

For other errors, refer to `{{workflows/implementation/error-recovery}}`
