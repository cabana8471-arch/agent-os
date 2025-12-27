# Run All Tests - Final Verification Only

**IMPORTANT**: This workflow is for FINAL VERIFICATION ONLY, after all implementation tasks are complete.

During implementation, agents should run ONLY their specific tests (2-8 per task group). This workflow runs the ENTIRE test suite as a final quality gate.

## Pre-conditions

Before running this workflow, verify:
- [ ] All tasks in `[spec-path]/tasks.md` are checked `[x]`
- [ ] Code review status is "Approved" or "Approved with Comments"
- [ ] All task-group-specific tests are passing

**Important:** All verification outputs use the `verification/` folder (singular, not `verifications/`).

## When to Use This Workflow

- After ALL task groups are marked complete
- After code review is approved
- Before marking roadmap item as complete
- As part of final implementation verification

## Workflow

### Step 1: Verify Prerequisites

Before running the full test suite, confirm prerequisites are met:

```bash
# Check tasks.md for incomplete tasks
grep -c "\- \[ \]" agent-os/specs/[spec-path]/tasks.md || echo "0"
```

If any tasks are incomplete (count > 0), STOP and report which tasks need completion.

Check for code review status:
```bash
# Check if code review exists and its status
cat agent-os/specs/[spec-path]/implementation/code-review.md 2>/dev/null | grep "Overall Status" || echo "No code review found"
```

If code review shows "Changes Required", STOP and report that code review issues must be addressed first.

### Step 2: Run Full Test Suite

Run the entire test suite for the application:

```bash
# Adjust command based on project's test framework
# Examples:
# npm test
# pytest
# bundle exec rspec
# go test ./...
```

Capture:
- Total number of tests
- Number of passing tests
- Number of failing tests
- Number of errors/skipped tests

### Step 3: Analyze Results

Compare current test results with baseline (if available):

1. **New failures**: Tests that were passing before this implementation
2. **Pre-existing failures**: Tests that were already failing
3. **New tests**: Tests added as part of this implementation

### Step 4: Document Results

Include in your final verification report (`[spec-path]/verification/final-verification.md`):

```markdown
## Test Suite Results

### Summary
- **Total Tests**: [count]
- **Passing**: [count] ([percentage]%)
- **Failing**: [count]
- **Errors**: [count]
- **Skipped**: [count]

### New Failures (Regressions)
[List any tests that were passing before this implementation but are now failing]

### Pre-existing Failures
[List tests that were already failing before this implementation]

### New Tests Added
[List tests added as part of this implementation - should match the 16-34 expected range]
```

### Step 5: Determine Pass/Fail Status

**PASS criteria:**
- All new tests pass
- No regressions (no new failures in pre-existing tests)
- Implementation-specific tests (16-34 tests) all pass

**FAIL criteria:**
- Any new test fails
- Any regression detected
- Critical functionality tests fail

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Test suite complete.
📁 Report: [spec-path]/verification/final-verification.md
📊 Summary: [X] total | [Y] pass | [Z] fail | [W] new tests
⏱️ Status: [PASS - no regressions / FAIL - regressions found]
```

**Do NOT include** detailed test results, failure descriptions, or analysis in the conversation response.

## Important Constraints

- **DO NOT attempt to fix failing tests** - Document them for follow-up
- This workflow is for verification, not remediation
- Pre-existing failures should be documented but do not block approval
- New failures (regressions) MUST be investigated before marking implementation complete
- Always run the full suite, even if it takes time - this is the final quality gate

## Error Recovery

If test execution encounters issues:
1. **Test suite fails to start:** Check test framework installation and configuration
2. **Timeout during tests:** Document timeout location, consider running tests in batches
3. **Environment issues:** Verify test database, API keys, and dependencies are available
4. **Pre-conditions not met:** Run verify-tasks and code-review workflows first

For other errors, refer to `{{workflows/implementation/error-recovery}}`
