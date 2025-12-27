# Error Recovery Workflow

## Pre-conditions

- [ ] An error or failure has occurred during implementation, testing, or verification
- [ ] Error details are available (error message, logs, or failure report)
- [ ] Spec path is known for the affected feature

## Core Responsibilities

1. **Identify Error Type**: Categorize the error to determine recovery strategy
2. **Assess Impact**: Understand what was affected and what work might be lost
3. **Execute Recovery**: Apply appropriate recovery steps
4. **Document and Prevent**: Record the error and update processes to prevent recurrence

## When to Use This Workflow

Use this workflow when:
- A task implementation fails or produces errors
- Tests fail during implementation
- Code review returns "Changes Required"
- Spec verification identifies critical issues
- Build or deployment fails
- An agent encounters an unrecoverable state

## Error Categories and Recovery Strategies

### Category 1: Test Failures

**Symptoms:**
- Unit tests fail after implementation
- Integration tests fail
- Test suite shows regressions

**Recovery Steps:**
1. **Identify failing tests**
   ```bash
   # Run tests and capture failures
   npm test 2>&1 | grep -A 5 "FAIL\|Error"
   ```

2. **Categorize failures:**
   - **New test fails**: Bug in implementation or test
   - **Existing test fails**: Regression introduced
   - **Flaky test**: Intermittent failure

3. **For new test failures:**
   - Review test expectations vs implementation
   - Fix implementation if test is correct
   - Fix test if implementation is correct
   - Mark task as incomplete until tests pass

4. **For regressions:**
   - Identify which change caused the regression
   - Revert problematic change if necessary
   - Fix the underlying issue
   - Run full test suite to verify fix

5. **Update tasks.md:**
   - Uncheck the affected task `- [ ]`
   - Add note about the failure and fix

### Category 2: Code Review Rejection

**Symptoms:**
- Code review status is "Changes Required"
- Critical or major issues identified

**Recovery Steps:**
1. **Read code review report thoroughly**
   ```bash
   cat agent-os/specs/[spec-path]/implementation/code-review.md
   ```

2. **Create remediation plan:**
   - List all critical issues
   - List all major issues
   - Prioritize by severity

3. **Address issues:**
   - Fix critical issues first
   - Address major issues
   - Document why any issue is deferred (if applicable)

4. **Request re-review:**
   - Run code review workflow again
   - Do NOT proceed to verification until approved

5. **Update tasks.md:**
   - Add subtask for each issue addressed
   - Mark original tasks as incomplete until re-reviewed

### Category 3: Spec Verification Failures

**Symptoms:**
- Spec verification report shows critical issues
- Tasks don't align with requirements
- Missing implementation elements

**Recovery Steps:**
1. **Review verification report**
   ```bash
   cat agent-os/specs/[spec-path]/verification/spec-verification.md
   ```

2. **Categorize issues:**
   - **Missing features**: Not implemented
   - **Extra features**: Over-engineering
   - **Misaligned features**: Implementation differs from spec

3. **For missing features:**
   - Add tasks to tasks.md
   - Implement missing functionality
   - Re-run spec verification

4. **For extra features:**
   - Assess if features should be kept or removed
   - If removing: Create rollback tasks
   - Update spec if features should be kept

5. **For misaligned features:**
   - Determine correct interpretation (spec vs implementation)
   - Fix implementation OR update spec (via update-spec workflow)
   - Document decision

### Category 4: Build/Deployment Failures

**Symptoms:**
- Build process fails
- Deployment scripts error
- Environment issues

**Recovery Steps:**
1. **Capture error output**
   ```bash
   # Capture build errors
   npm run build 2>&1 | tail -50
   ```

2. **Identify root cause:**
   - Syntax errors
   - Missing dependencies
   - Configuration issues
   - Environment problems

3. **Fix and verify:**
   - Address the specific error
   - Run build again
   - Verify successful completion

4. **If caused by implementation:**
   - Mark affected task incomplete
   - Fix the issue
   - Re-verify task completion

### Category 5: Agent State Errors

**Symptoms:**
- Agent reports being stuck
- Unexpected state encountered
- Missing prerequisite files

**Recovery Steps:**
1. **Verify file system state**
   ```bash
   ls -la agent-os/specs/[spec-path]/
   ls -la agent-os/specs/[spec-path]/planning/
   ls -la agent-os/specs/[spec-path]/implementation/
   ls -la agent-os/specs/[spec-path]/verification/
   ```

2. **Identify missing prerequisites:**
   - Check if required files exist
   - Check if previous workflows completed

3. **Recover missing state:**
   - Re-run previous workflow if needed
   - Create missing files manually if appropriate
   - Document what was missing

4. **Resume from valid state:**
   - Determine last known good state
   - Continue from that point

## Recovery Documentation

After any recovery, document the incident in `[spec-path]/verification/error-log.md`:

```markdown
# Error Log

## Incident: [Date] - [Brief Title]

### Error Type
[Test Failure / Code Review Rejection / Spec Verification / Build Failure / Agent Error]

### Description
[What happened]

### Root Cause
[Why it happened]

### Resolution
[What was done to fix it]

### Prevention
[How to prevent this in the future]

### Affected Tasks
- Task X.Y: [Status after recovery]
- Task X.Z: [Status after recovery]

### Time Impact
[Estimated time spent on recovery]
```

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Error recovery complete.
📁 Report: [spec-path]/verification/error-log.md
📊 Summary: [X] tasks affected | [Y] recovered | Type: [Category]
⏱️ Status: [Ready to continue / Partially blocked - see report]
```

**Do NOT include** detailed root cause analysis, resolution steps, or remaining issues in the conversation response.

## Important Constraints

- **Don't panic** - Most errors are recoverable with methodical approach
- **Document everything** - Future debugging depends on good records
- **Don't hide errors** - Transparent reporting helps improve the system
- **Preserve work** - Avoid losing completed work during recovery
- **Verify recovery** - Always confirm the error is actually resolved
- **Learn from errors** - Update workflows to prevent recurrence
- **Ask for help** - If stuck, escalate to user rather than making bad assumptions
- **One error at a time** - Resolve errors sequentially, not in parallel
