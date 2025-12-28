# Task Verification Workflow

## Core Responsibilities

1. **Verify Task Completion**: Ensure all tasks in tasks.md are properly completed
2. **Spot-Check Implementation**: Verify code evidence for each task
3. **Check Documentation**: Verify implementation reports exist
4. **Flag Incomplete Work**: Identify and document any gaps

## Pre-conditions

Before running this workflow, verify:
- [ ] `[spec-path]/tasks.md` exists
- [ ] `[spec-path]/spec.md` exists
- [ ] Implementation phase has been declared complete by implementer

**Important:** All verification outputs use the `verification/` folder (singular, not `verifications/`).

## Workflow

### Step 1: Load Task List

Read `agent-os/specs/[spec-path]/tasks.md` and create an inventory of all tasks and their current status.

```bash
# Count total tasks vs completed tasks
echo "Total tasks:"
grep -c "\- \[" agent-os/specs/[spec-path]/tasks.md

echo "Completed tasks:"
grep -c "\- \[x\]" agent-os/specs/[spec-path]/tasks.md

echo "Incomplete tasks:"
grep -c "\- \[ \]" agent-os/specs/[spec-path]/tasks.md
```

### Step 2: Verify Each Task Group

For each task group in tasks.md:

#### 2.1 Check Checkbox Status
- All subtasks should be marked `[x]`
- Parent task should be marked `[x]` only if ALL subtasks are complete

#### 2.2 Spot-Check Code Evidence

For each task marked complete, run a brief verification:

1. **For model/database tasks**: Check if model file exists and has expected fields
2. **For API tasks**: Check if controller/route file exists with expected endpoints
3. **For UI tasks**: Check if component files exist
4. **For test tasks**: Check if test files exist and contain expected test count

```bash
# Example: Verify a model exists
ls -la app/models/[expected_model].rb 2>/dev/null || echo "Model not found"

# Example: Verify tests exist
find . -name "*[feature]*.test.*" -o -name "*[feature]*.spec.*" | wc -l
```

#### 2.3 Check Implementation Documentation

Verify implementation report exists for each task group:
```bash
ls -la agent-os/specs/[spec-path]/implementation/ 2>/dev/null
```

### Step 3: Evaluate Findings

For each task, assign one of these statuses:

| Status | Meaning | Action |
|--------|---------|--------|
| ✅ Complete | Task complete with evidence | None |
| ⚠️ Uncertain | Checkbox marked but evidence unclear | Note for review and assign Issue ID |
| ❌ Incomplete | Task not done or evidence missing | Must be addressed - assign Issue ID |

When documenting uncertain or incomplete tasks, use the Issue Tracking Protocol:

> See `{{protocols/issue-tracking}}` for ID format and severity levels.

### Step 4: Handle Incomplete Tasks

IF a task is marked incomplete (`- [ ]`) but should be complete:

1. Run spot-check to verify if implementation exists
2. Check for implementation report in `implementation/` folder
3. IF evidence found: Mark checkbox as `[x]`
4. IF evidence NOT found: Mark with ⚠️ and note in report

IF a task is marked complete (`- [x]`) but evidence is missing:

1. Mark the checkbox with ⚠️: `- [⚠️]`
2. Document the discrepancy in verification report
3. Flag for implementer follow-up

### Step 5: Update Task List

Update `agent-os/specs/[spec-path]/tasks.md`:

```markdown
# Before
- [ ] 1.2 Create User model

# After (if verified complete)
- [x] 1.2 Create User model

# After (if incomplete/uncertain)
- [⚠️] 1.2 Create User model <!-- NEEDS VERIFICATION -->
```

### Step 6: Create Verification Summary

Add task verification results to the final verification report at `[spec-path]/verification/final-verification.md`:

```markdown
## Task Verification Results

### Summary
- **Total Tasks**: [count]
- **Verified Complete**: [count]
- **Uncertain/Needs Review**: [count]
- **Incomplete**: [count]

### Task Group Status

| Task Group | Status | Issues |
|------------|--------|--------|
| 1. Database Layer | ✅ Complete | None |
| 2. API Layer | ⚠️ Partial | Task 2.3 missing tests |
| 3. UI Layer | ✅ Complete | None |

### Incomplete Tasks
[List any tasks that are genuinely incomplete]

### Tasks Needing Review
[List tasks where status is uncertain]
```

### Step 7: Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Task verification complete.
📁 Report: [spec-path]/verification/final-verification.md
📊 Summary: ✅ [X] verified | ⚠️ [Y] review | ❌ [Z] incomplete
⏱️ Status: [Ready for final verification / Issues require attention]
```

**Do NOT include** detailed task lists, issue descriptions, or verification steps in the conversation response.

## Quality Gates

Before marking task verification as complete, ensure all items in the Tasks List Checklist are verified:

> See `{{protocols/verification-checklist}}` for the Tasks List Checklist.

## Important Constraints

- **Do NOT implement missing features** - Only verify and document
- Spot-checks should be quick (30 seconds per task max)
- When in doubt, mark as ⚠️ for human review
- Always update tasks.md with your findings
- Create evidence trail in verification report
- Focus on existence of implementation, not quality (that's for code review)
- Assign Issue IDs to uncertain or incomplete tasks using `{{protocols/issue-tracking}}`

## Error Recovery

If task verification encounters issues:
1. **Tasks.md not found:** Check if spec path is correct, prompt for correct path
2. **Implementation folder missing:** Implementation phase may not be complete - verify with user
3. **Inconsistent checkbox states:** Document discrepancies, assign Issue IDs, flag for manual review
4. **Cannot access codebase files:** Document which files couldn't be verified - assign Issue IDs

For other errors, refer to `{{workflows/implementation/error-recovery}}`
