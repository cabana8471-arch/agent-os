# Create Verification Report

## Purpose

This workflow guides the creation of the final verification report that summarizes all implementation and verification results.

## Pre-conditions

- [ ] All tasks from `tasks.md` have been implemented
- [ ] Code review has been completed (if applicable)
- [ ] All tests have been executed via `run-all-tests.md`
- [ ] Task verification has been completed via `verify-tasks.md`

## Workflow

### Step 1: Gather Verification Data

Collect results from:
1. `agent-os/specs/[spec-path]/tasks.md` - task completion status
2. `agent-os/specs/[spec-path]/implementation/` - implementation docs
3. `agent-os/specs/[spec-path]/verification/` - any existing verification docs
4. Test run results (from test suite output)

### Step 2: Determine Overall Status

Based on gathered data, determine the report status:
- **✅ Passed** - All tasks complete, all tests passing, no critical issues
- **⚠️ Passed with Issues** - All tasks complete but minor issues or warnings exist
- **❌ Failed** - Tasks incomplete OR tests failing OR critical issues found

### Step 3: Create Report

Create your final verification report in `agent-os/specs/[spec-path]/verification/final-verification.md`.

**Note:** The folder is `verification/` (singular), not `verifications/`.

The content of this report should follow this structure:

```markdown
# Verification Report: [Spec Title]

**Spec:** `[spec-path]`
**Date:** [Current Date]
**Verifier:** implementation-verifier
**Status:** ✅ Passed | ⚠️ Passed with Issues | ❌ Failed

---

## Executive Summary

[Brief 2-3 sentence overview of the verification results and overall implementation quality]

---

## 1. Tasks Verification

**Status:** ✅ All Complete | ⚠️ Issues Found

### Completed Tasks
- [x] Task Group 1: [Title]
  - [x] Subtask 1.1
  - [x] Subtask 1.2
- [x] Task Group 2: [Title]
  - [x] Subtask 2.1

### Incomplete or Issues
[List any tasks that were found incomplete or have issues, or note "None" if all complete]

---

## 2. Documentation Verification

**Status:** ✅ Complete | ⚠️ Issues Found

### Implementation Documentation
- [x] Task Group 1 Implementation: `implementations/1-[task-name]-implementation.md`
- [x] Task Group 2 Implementation: `implementations/2-[task-name]-implementation.md`

### Verification Documentation
[List verification documents from area verifiers if applicable]

### Missing Documentation
[List any missing documentation, or note "None"]

---

## 3. Roadmap Updates

**Status:** ✅ Updated | ⚠️ No Updates Needed | ❌ Issues Found

### Updated Roadmap Items
- [x] [Roadmap item that was marked complete]

### Notes
[Any relevant notes about roadmap updates, or note if no updates were needed]

---

## 4. Test Suite Results

**Status:** ✅ All Passing | ⚠️ Some Failures | ❌ Critical Failures

### Test Summary
- **Total Tests:** [count]
- **Passing:** [count]
- **Failing:** [count]
- **Errors:** [count]

### Failed Tests
[List any failing tests with their descriptions, or note "None - all tests passing"]

### Notes
[Any additional context about test results, known issues, or regressions]
```

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Verification report created.
📁 Report: [spec-path]/verification/final-verification.md
📊 Summary: Tasks: [status] | Tests: [status] | Docs: [status]
⏱️ Next: Run update-roadmap workflow to mark feature complete
```

**Do NOT include** detailed verification results, task lists, or test summaries in the conversation response.

## Important Constraints

- Report MUST be created in `verification/` folder (singular), not `verifications/`
- All status indicators must match actual verification results
- Do not mark tasks as complete unless they are fully verified

## Error Recovery

If verification report cannot be created:
1. **Missing verification data:** Run `verify-tasks.md` and `run-all-tests.md` first
2. **Conflicting results:** Document discrepancies in the report and mark as "⚠️ Passed with Issues"
3. **Critical failures found:** Mark report as "❌ Failed" and list required fixes
4. **Code review not completed:** Run code-review workflow before creating final verification report
5. **Missing implementation documentation:** Some implementation reports may be missing - document as gaps in the verification report

For other errors, refer to `{{workflows/implementation/error-recovery}}`
