# Code Review Workflow

## Pre-conditions

- [ ] Implementation has been completed for assigned tasks
- [ ] Tasks marked as done in `agent-os/specs/[spec-path]/tasks.md`
- [ ] Spec exists at `agent-os/specs/[spec-path]/spec.md`
- [ ] Tech stack documented at `agent-os/product/tech-stack.md`

## Quality Gates

Use the Code Review Checklist from the verification protocol before marking review complete:

> See `{{protocols/verification-checklist}}` for the Code Review Checklist covering Security, Quality, Performance, and Maintainability.

## Workflow

### Step 1: Understand Review Context

Gather context for the review:

1. **Read the spec and tasks**: Load `agent-os/specs/[spec-path]/spec.md` and `agent-os/specs/[spec-path]/tasks.md` to understand what was implemented
2. **Identify changed files**: Determine which files were created or modified for this implementation
3. **Load tech stack**: Read `agent-os/product/tech-stack.md` to understand project technologies

### Step 2: Perform Code Quality Review

For each file changed/created, analyze:

**Readability & Maintainability:**
- Clear naming conventions (variables, functions, classes)
- Appropriate function/method length (flag functions > 50 lines)
- Single responsibility principle adherence
- Consistent formatting and indentation
- Meaningful comments where logic is complex

**Code Structure:**
- Proper separation of concerns
- Appropriate use of abstractions
- No code duplication (DRY principle)
- Correct error handling patterns
- Appropriate logging

### Step 3: Security Analysis

Check for common security vulnerabilities:

**Input Validation:**
- User input sanitization
- SQL injection prevention (parameterized queries)
- XSS prevention (output encoding)
- Command injection risks

**Authentication & Authorization:**
- Proper auth checks on protected routes
- Session management security
- Password handling (hashing, no plaintext)
- API key/secret exposure

**Data Protection:**
- Sensitive data exposure in logs
- Proper encryption usage
- Secure communication (HTTPS)
- CORS configuration

### Step 4: Performance Review

Identify potential performance issues:

- N+1 query problems
- Missing database indexes (based on query patterns)
- Unnecessary re-renders (frontend)
- Memory leaks potential
- Large payload transfers
- Missing caching opportunities
- Blocking operations that should be async

### Step 5: Standards Compliance Check

Verify adherence to project standards:

- Naming conventions match project style
- File organization follows project structure
- Import/export patterns are consistent
- Error handling matches project patterns
- Logging follows project conventions

### Step 6: Create Review Report

Write your review to `agent-os/specs/[spec-path]/implementation/code-review.md`:

```markdown
# Code Review Report

## Review Summary
- **Spec**: [Spec name]
- **Date**: [Current date]
- **Files Reviewed**: [count]
- **Overall Status**: Approved / Approved with Comments / Changes Required

## Files Reviewed

| File | Status | Issues |
|------|--------|--------|
| `path/to/file.ts` | Approved | None |
| `path/to/other.ts` | Changes Required | 2 critical, 1 minor |

## Critical Issues
[Must be fixed before merge]

### Issue 1: [Title]
- **File**: `path/to/file.ts:42`
- **Severity**: Critical
- **Category**: Security / Performance / Bug
- **Description**: [What's wrong]
- **Recommendation**: [How to fix]

## Major Issues
[Should be fixed]

### Issue 1: [Title]
- **File**: `path/to/file.ts:15`
- **Severity**: Major
- **Category**: Code Quality / Standards
- **Description**: [What's wrong]
- **Recommendation**: [How to fix]

## Minor Issues
[Nice to fix]

- `file.ts:10` - Consider renaming `x` to something more descriptive
- `file.ts:25` - Could extract this logic to a helper function

## Positive Observations
[What was done well]

- Good use of existing patterns from [reference]
- Clean separation of concerns in [component]
- Comprehensive error handling in [function]

## Recommendations for Future
[Optional improvements for later]

1. Consider adding caching for [feature]
2. Could benefit from additional logging in [area]

## Conclusion

[Overall assessment and recommendation: ready for verification, needs minor fixes, needs significant rework]
```

### Step 7: Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

After writing the full report to file, return ONLY this summary to the conversation:

```
✅ Code review complete.
📁 Report: agent-os/specs/[spec-path]/implementation/code-review.md
📊 Summary: [X] critical, [X] major, [X] minor issues | [X] files reviewed
⏱️ Status: [Approved / Approved with Comments / Changes Required]
```

**Do NOT include** the full report content, detailed issue descriptions, or code snippets in the conversation response.

## What Happens Next

Based on the review status, the following actions should occur:

### If "Approved"
- Implementation can proceed to verification phase
- No changes required from implementer

### If "Approved with Comments"
- Implementation can proceed to verification phase
- Minor issues can be addressed in follow-up or future iterations
- Implementer should acknowledge comments

### If "Changes Required"
1. **Implementer must address critical issues** before proceeding
2. Implementer should:
   - Read the code review report thoroughly
   - Fix all critical issues listed
   - Address major issues where feasible
   - Update tasks.md if implementation changes
3. Once fixes are complete, **request re-review** by running code review workflow again
4. Do NOT proceed to verification until status changes to "Approved" or "Approved with Comments"

### Re-Review Process
When re-reviewing after changes:
1. Focus primarily on previously identified issues
2. Verify each critical/major issue has been addressed
3. Update the code-review.md report with re-review results
4. Add a "Re-Review" section documenting what was fixed

```markdown
## Re-Review: [Date]

### Issues Addressed
- [x] Issue 1: [Description of fix]
- [x] Issue 2: [Description of fix]

### Remaining Concerns
[Any issues that still need work, or "None"]

### Updated Status
[New status after re-review]
```

## Checklist Integration Note

This workflow includes its own detailed Code Review Checklist (Step 3) that maps closely to the Code Review section of the general verification-checklist protocol. The inline checklist in Step 3 is specialized for code review and includes specific categories (Readability, Code Structure, Security, etc.) while the protocol provides a more general framework for quality gates across all development phases.

Both can be used together: follow this workflow's Step 3 checklist for detailed code analysis, then reference the verification-checklist protocol for the broader quality gate framework.

## Important Constraints

- Focus on actionable feedback, not stylistic preferences
- Be specific about file locations and line numbers
- Provide concrete recommendations, not vague suggestions
- Distinguish between critical issues (must fix) and suggestions (nice to have)
- Reference existing patterns when recommending changes
- Don't rewrite code; describe what needs to change
- Prioritize security and correctness over style
- Assign Issue IDs to all findings using `{{protocols/issue-tracking}}`
- **Do NOT skip the re-review process** when changes are required

## Error Recovery

If code review encounters issues:
1. **Cannot identify changed files:** Ask implementer to provide list of modified files
2. **Missing spec or tasks:** Cannot perform proper review without context; request spec documentation first
3. **Security vulnerability found:** Mark as Critical issue, block proceeding to verification
4. **Implementer disputes finding:** Document disagreement in review, escalate to user for decision

For other errors, refer to `{{workflows/implementation/error-recovery}}`
