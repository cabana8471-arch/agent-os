# Verification Checklist Protocol

This protocol defines quality gates and verification checklists for each phase of the Agent OS development workflow.

## Purpose

Use these checklists to ensure completeness and quality before moving to the next phase. Each checklist acts as a quality gate that must pass before proceeding.

---

## Phase Checklists

### 1. Spec Verification Checklist

Before implementation begins, verify the spec is complete:

```markdown
## Spec Completeness Checklist

- [ ] **Problem Statement**: Clear description of what problem this solves
- [ ] **User Stories**: At least 2-3 user stories defined
- [ ] **Requirements**: Functional requirements are specific and testable
- [ ] **Acceptance Criteria**: Clear criteria for "done"
- [ ] **Out of Scope**: Explicitly states what is NOT included
- [ ] **Technical Constraints**: Any known limitations documented
- [ ] **Dependencies**: External dependencies identified
- [ ] **Risk Assessment**: Major risks identified with mitigations
```

### 2. Tasks List Verification Checklist

Before starting implementation, verify tasks are well-defined:

```markdown
## Tasks List Checklist

- [ ] **Complete Coverage**: All spec requirements mapped to tasks
- [ ] **Atomic Tasks**: Each task is independently completable
- [ ] **Clear Scope**: Each task has defined start/end boundaries
- [ ] **Dependencies Noted**: Task dependencies are explicit
- [ ] **Priority Assigned**: Tasks are prioritized (P0, P1, P2)
- [ ] **Effort Estimated**: Rough complexity noted (S, M, L)
- [ ] **No Gaps**: No missing tasks for full spec implementation
```

### 3. Implementation Verification Checklist

Before marking implementation complete:

```markdown
## Implementation Checklist

### Core Completion
- [ ] **All Tasks Complete**: Every task checkbox is marked in tasks.md
- [ ] **Code Compiles**: No build/compilation errors
- [ ] **Tests Pass**: All existing tests still pass
- [ ] **Linter Passes**: No linting errors or warnings

### Quality Assurance
- [ ] **New Tests Added**: New functionality has test coverage
- [ ] **Edge Cases Handled**: Error states and boundary conditions implemented
- [ ] **Input Validation**: All user inputs properly validated
- [ ] **Error Messages**: User-friendly error messages for failures

### Security Verification
- [ ] **No Hardcoded Secrets**: No API keys, passwords, or tokens in code
- [ ] **Authentication Checked**: Protected routes/actions require auth
- [ ] **Authorization Verified**: Permission checks in place

### Documentation & Cleanup
- [ ] **Documentation Updated**: README/docs reflect changes
- [ ] **No Console Errors**: Browser/runtime logs clean
- [ ] **Debug Code Removed**: No console.log, print statements, or debug flags
- [ ] **Unused Code Removed**: No commented-out or dead code

### Standards Compliance
- [ ] **Code Reviewed**: Self-review completed or peer review done
- [ ] **Naming Conventions**: Variables, functions, files follow project standards
- [ ] **File Organization**: New files placed in correct directories
```

### 4. Code Review Verification Checklist

During code review, verify:

```markdown
## Code Review Checklist

### Security
- [ ] No hardcoded secrets or credentials
- [ ] Input validation on all user inputs
- [ ] SQL/NoSQL injection prevented
- [ ] XSS vulnerabilities addressed
- [ ] Authentication/authorization correct
- [ ] Sensitive data properly handled

### Quality
- [ ] Code follows project conventions
- [ ] No obvious bugs or logic errors
- [ ] No code duplication (DRY)
- [ ] Functions are focused (single responsibility)
- [ ] Error handling is appropriate
- [ ] Logging is meaningful

### Performance
- [ ] No obvious N+1 queries
- [ ] No blocking operations in UI thread
- [ ] Large data sets handled efficiently
- [ ] Caching considered where appropriate

### Maintainability
- [ ] Code is readable without extensive comments
- [ ] Complex logic is documented
- [ ] Magic numbers have constants
- [ ] Names are descriptive and consistent
```

### 5. Test Strategy Verification Checklist

Before considering testing complete:

```markdown
## Test Coverage Checklist

- [ ] **Unit Tests**: Core logic has unit test coverage
- [ ] **Integration Tests**: Key workflows tested end-to-end
- [ ] **Edge Cases**: Boundary conditions tested
- [ ] **Error Paths**: Error handling tested
- [ ] **Regression Tests**: Existing functionality still works
- [ ] **Coverage Target**: Met minimum coverage threshold (e.g., 80%)
```

### 6. Final Verification Checklist

Before marking spec as complete:

```markdown
## Final Verification Checklist

- [ ] **Spec Requirements Met**: All acceptance criteria satisfied
- [ ] **All Tests Pass**: Full test suite green
- [ ] **Code Review Passed**: No blocking issues from review
- [ ] **Documentation Complete**: User-facing docs updated
- [ ] **No Open Issues**: All CRITICAL/HIGH issues resolved
- [ ] **Performance Acceptable**: No major performance regressions
- [ ] **Stakeholder Approval**: Demo/review with stakeholders done
```

---

## Usage Instructions

### In Workflow Files

Reference this protocol when verification is needed:

```markdown
> Before proceeding, complete the verification checklist.
> See `{{protocols/verification-checklist}}` for the relevant checklist.
```

### In Reports

Include checklist status in reports:

```markdown
## Verification Status

| Checklist | Status | Notes |
|-----------|--------|-------|
| Spec Completeness | ✅ PASS | All items verified |
| Implementation | ⚠️ PARTIAL | 2 items pending |
| Code Review | ❌ FAIL | Security issues found |
```

### Failure Handling

When a checklist fails:

1. **Document Failures**: Note which items failed and why
2. **Create Action Items**: Log issues with Issue IDs using the Issue Tracking Protocol:
   > See `{{protocols/issue-tracking}}` for ID format, severity levels, and tracking procedures.
3. **Block Progression**: Do not proceed until CRITICAL items pass
4. **Track Resolution**: Update checklist as items are resolved

### AOS-0035 Fix: Error-to-Category Mapping

When a checklist item fails, assign the appropriate Issue ID category:

| Checklist Section | Primary Category | Secondary Category |
|-------------------|------------------|-------------------|
| Spec Completeness | QUAL | ARCH |
| Tasks List | QUAL | GAP |
| Core Completion (build/tests) | BUG | TEST |
| Quality Assurance | QUAL | BUG |
| Security Verification | SEC | - |
| Documentation & Cleanup | DOC | QUAL |
| Standards Compliance | QUAL | ARCH |
| Code Review - Security | SEC | - |
| Code Review - Quality | QUAL | BUG |
| Code Review - Performance | PERF | - |
| Code Review - Maintainability | QUAL | ARCH |
| Test Coverage | TEST | GAP |
| Test Limit Violations | TEST | QUAL |
| Final Verification | QUAL | - |

**Category Definitions (see `{{protocols/issue-tracking}}` for full list):**
- SEC: Security vulnerabilities
- BUG: Code defects and bugs
- PERF: Performance issues
- QUAL: Code quality concerns
- DOC: Documentation gaps
- TEST: Test-related issues
- ARCH: Architectural concerns
- GAP: Missing functionality

---

## Quality Gate Thresholds

| Gate | Minimum Pass Rate | Blocking Items |
|------|-------------------|----------------|
| Spec Verification | 100% | All items |
| Tasks Verification | 100% | All items |
| Implementation | 90% | Tests Pass, No Console Errors |
| Code Review | 85% | All Security items |
| Test Strategy | 80% | Unit Tests, Integration Tests |
| Final Verification | 100% | All items |

---

## Best Practices

1. **Don't Skip Items**: Every checkbox matters
2. **Document Exceptions**: If an item doesn't apply, note why
3. **Verify Early**: Run checklists frequently, not just at the end
4. **Be Honest**: A failed checklist now prevents bigger problems later
5. **Update Checklists**: Add project-specific items as needed

---

## AOS-0100: Standardized Status Terminology

Use consistent status terminology across all verification workflows:

| Context | Success | Partial | Failure |
|---------|---------|---------|---------|
| Task Verification | ✅ Complete | ⚠️ Uncertain | ❌ Incomplete |
| Test Execution | ✅ PASS | ⚠️ FLAKY | ❌ FAIL |
| Overall Report | ✅ Passed | ⚠️ Passed with Issues | ❌ Failed |
| Roadmap Update | ✅ Updated | ⚠️ Partial | ❌ Not Updated |

---

## AOS-0037: Exception Protocol for Quality Gates

In rare circumstances, quality gates may need to be bypassed. This section defines the rules for doing so safely.

### When Exceptions Are Allowed

Exceptions to quality gates are ONLY permitted when:
1. **Time-Critical Fixes**: Production is down and immediate hotfix is needed
2. **Non-Applicable Items**: Checklist item doesn't apply to this change type
3. **Deferred Resolution**: Issue is documented and will be fixed in follow-up

### Exception Requirements

To bypass a quality gate item, you MUST:

1. **Document the Exception**:
   ```markdown
   ## Quality Gate Exception

   - **Item Bypassed**: [checklist item]
   - **Reason**: [why exception is needed]
   - **Risk Assessment**: [what could go wrong]
   - **Mitigation**: [how risk is managed]
   - **Follow-up Issue**: [issue ID if deferred]
   - **Approved By**: [stakeholder/reviewer]
   ```

2. **Create Follow-up Issue** (if deferring):
   - Use Issue Tracking Protocol (`{{protocols/issue-tracking}}`)
   - Assign severity based on bypassed item
   - Add to next sprint/iteration

3. **Limit Scope**:
   - NEVER bypass Security (SEC) items without explicit approval
   - NEVER bypass multiple CRITICAL items in same change
   - Prefer partial deployments over complete gate bypass

### Items That Cannot Be Bypassed

| Category | Items | Reason |
|----------|-------|--------|
| Security | All SEC-prefixed items | Risk of vulnerability |
| Data Safety | Database migrations, data validation | Risk of data loss |
| Authentication | Auth/permission checks | Risk of unauthorized access |

### Tracking Exceptions

Maintain an exception log in `agent-os/product/exceptions.md`:

```markdown
| Date | Item Bypassed | Reason | Follow-up Issue | Resolved |
|------|---------------|--------|-----------------|----------|
| 2024-01-15 | Test Coverage 80% | Hotfix | TEST-042 | ✅ |
```

### Escalation Path

1. **Developer**: Can bypass LOW severity items with documentation
2. **Tech Lead**: Can approve MEDIUM severity bypasses
3. **Security Team**: Must approve any SEC-related bypasses
4. **Management**: Required for multiple CRITICAL bypasses
