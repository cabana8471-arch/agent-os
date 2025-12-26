# Test Strategy Workflow

## Workflow

### Step 1: Understand Testing Context

Gather context about the feature and existing tests:

1. **Read the spec**: Load `agent-os/specs/[spec-path]/spec.md` and `agent-os/specs/[spec-path]/tasks.md`
2. **Identify test framework**: Detect existing test setup

```bash
# Detect test framework and existing tests
ls -la test/ tests/ spec/ __tests__/ 2>/dev/null | head -20

# Check for test configuration
cat jest.config.* pytest.ini .rspec vitest.config.* 2>/dev/null | head -30

# Count existing tests
find . -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" 2>/dev/null | wc -l
```

3. **Check current coverage** (if available):
```bash
# Look for coverage reports
ls -la coverage/ .coverage htmlcov/ 2>/dev/null
```

### Step 2: Analyze Feature Testing Needs

Based on the spec, identify what needs testing:

**Test Categories:**
1. **Unit Tests**: Individual functions/methods in isolation
2. **Integration Tests**: Component interactions, API calls
3. **End-to-End Tests**: Complete user workflows
4. **Edge Cases**: Boundary conditions, error states

**For each feature requirement, determine:**
- What's the happy path?
- What are the error cases?
- What are the edge cases?
- What external dependencies need mocking?

### Step 3: Assess Current Coverage Gaps

If existing tests exist, analyze gaps:

```bash
# Find untested files (files without corresponding test files)
for f in $(find src -name "*.ts" -o -name "*.js" | head -20); do
    testfile="${f%.ts}.test.ts"
    if [ ! -f "$testfile" ] && [ ! -f "${f%.js}.test.js" ]; then
        echo "No test: $f"
    fi
done
```

**Coverage Gap Categories:**
- Files with no tests
- Functions with no test coverage
- Error paths not tested
- Edge cases not covered
- Integration points not tested

### Step 4: Design Test Strategy

Create a balanced testing approach:

**Testing Pyramid Guidance:**
- **Unit Tests (70%)**: Fast, isolated, test logic
- **Integration Tests (20%)**: API calls, database, external services
- **E2E Tests (10%)**: Critical user journeys only

**Test Prioritization:**
1. **Must Have**: Core functionality, security-related, data integrity
2. **Should Have**: Main user flows, error handling
3. **Nice to Have**: Edge cases, performance, accessibility

### Step 5: Create Test Plan

Write detailed test plan to `agent-os/specs/[spec-path]/implementation/test-plan.md`:

```markdown
# Test Plan: [Feature Name]

## Overview
- **Feature**: [Feature name from spec]
- **Date**: [Current date]
- **Test Framework**: [jest/pytest/rspec/etc.]
- **Estimated Tests**: [count]

## Test Strategy

### Testing Approach
[Brief description of testing strategy for this feature]

### Test Distribution
| Type | Count | Coverage Target |
|------|-------|-----------------|
| Unit | [X] | Core logic, utilities |
| Integration | [X] | API endpoints, services |
| E2E | [X] | Critical user flows |

## Test Cases

### Unit Tests

#### [Component/Module Name]
**File**: `tests/unit/[component].test.ts`

| ID | Test Case | Input | Expected Output | Priority |
|----|-----------|-------|-----------------|----------|
| U1 | [describe test] | [input] | [output] | Must |
| U2 | [describe test] | [input] | [output] | Should |

**Edge Cases:**
- [ ] Empty input handling
- [ ] Maximum length validation
- [ ] Invalid type handling

### Integration Tests

#### [API/Service Name]
**File**: `tests/integration/[service].test.ts`

| ID | Test Case | Setup | Action | Expected | Priority |
|----|-----------|-------|--------|----------|----------|
| I1 | [describe] | [setup] | [action] | [result] | Must |

**Mock Requirements:**
- [ ] [External service to mock]
- [ ] [Database state needed]

### End-to-End Tests

#### [User Flow Name]
**File**: `tests/e2e/[flow].test.ts`

| ID | Scenario | Steps | Expected Outcome | Priority |
|----|----------|-------|------------------|----------|
| E1 | [scenario] | 1. [step]<br>2. [step] | [outcome] | Must |

## Test Data Requirements

### Fixtures Needed
- [ ] [Fixture 1]: [description]
- [ ] [Fixture 2]: [description]

### Mock Services
- [ ] [Service]: [mock behavior]

## Coverage Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Line Coverage | >80% | For new code |
| Branch Coverage | >70% | Critical paths |
| Function Coverage | >90% | Public APIs |

## Test Environment

### Prerequisites
- [ ] [Requirement 1]
- [ ] [Requirement 2]

### Configuration
```
[Any special test configuration needed]
```

## Quality Gates

### Before Merge
- [ ] All new tests pass
- [ ] No regression in existing tests
- [ ] Coverage targets met for new code

### Acceptance Criteria
- [ ] [Criteria 1]
- [ ] [Criteria 2]

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk] | [Impact] | [Mitigation] |

## Notes

### Areas Requiring Manual Testing
- [Area 1]: [Why manual]

### Known Limitations
- [Limitation 1]
```

### Step 6: Generate Test Scaffolding (Optional)

If requested, create test file templates:

```typescript
// Example test structure
describe('[Component/Feature]', () => {
  describe('[Function/Method]', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange
      // Act
      // Assert
    });

    it('should handle [error case]', () => {
      // Test error handling
    });
  });
});
```

### Step 7: Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Test strategy complete.
📁 Report: agent-os/specs/[spec-path]/implementation/test-plan.md
📊 Summary: [X] unit | [Y] integration | [Z] e2e | [W] total tests
⏱️ Priority: [A] must | [B] should | [C] nice-to-have
```

**Do NOT include** detailed test cases, coverage gaps, or test distributions in the conversation response.

## Important Constraints

- Focus on meaningful tests, not arbitrary coverage numbers
- Prioritize testing behavior over implementation details
- Don't test framework code or third-party libraries
- Keep tests maintainable - avoid over-mocking
- Each test should test one thing
- Test names should describe the expected behavior
- Follow the existing test patterns in the codebase
- Balance thoroughness with pragmatism (2-8 focused tests per component)
- Consider test execution time in strategy

## Error Recovery

If you encounter issues during test strategy creation:

1. **Missing Spec Files**: Request spec creation first, or create minimal strategy based on available code
2. **No Existing Tests**: Document test infrastructure needs, recommend test framework setup
3. **Coverage Tool Unavailable**: Skip coverage analysis step, note in report as "Manual coverage check required"
4. **Large Codebase**: Focus on specific modules/components, document scope limitations
5. **Unknown Test Framework**: Recommend framework based on project type, document setup steps needed

For implementation-related errors, refer to `{{workflows/implementation/error-recovery}}`
