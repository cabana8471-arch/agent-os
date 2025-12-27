## Test coverage best practices

### Testing Philosophy
- **Test Behavior, Not Implementation**: Focus tests on what the code does, not how it does it; tests should survive refactoring
- **Quality Over Quantity**: Write meaningful tests for critical paths rather than chasing coverage metrics

### When to Write Tests
- **Critical User Flows**: Always test core user journeys and business-critical functionality
- **Bug Fixes**: Add regression tests when fixing bugs to prevent recurrence
- **API Contracts**: Test API endpoints to ensure contract stability
- **Complex Business Logic**: Unit test non-trivial calculations, transformations, and decision logic

### When to Skip Tests
- **During Initial Development**: Focus on completing feature implementation first; add strategic tests at completion points
- **Trivial Code**: Skip tests for simple getters/setters, pass-through functions, and framework boilerplate
- **Non-Critical Edge Cases**: Defer edge case testing unless business-critical; address in dedicated testing phases

### Test Structure
- **Clear Test Names**: Use descriptive names that explain the scenario: "should [expected behavior] when [condition]"
- **Arrange-Act-Assert**: Structure tests clearly with setup, execution, and verification phases
- **One Assertion Per Test**: Prefer focused tests with single assertions for clear failure messages

### Test Isolation
- **Mock External Dependencies**: Isolate tests from databases, APIs, file systems, and external services
- **Independent Tests**: Each test should run independently without relying on other tests' state
- **Fast Execution**: Unit tests should run in milliseconds; integration tests under 5 seconds

### Coverage Guidelines
- **Minimum Requirement**: Critical paths and business logic must have tests before merging
- **Target Range**: Aim for 70-80% coverage on business logic; 100% coverage is not a goal
- **Exclude from Coverage**: Configuration files, type definitions, and generated code

### Frontend Testing
- **Component Testing**: Use React Testing Library, Vue Test Utils, or framework-specific tools to test component behavior
- **E2E Testing**: Use Playwright or Cypress for critical user flows; run E2E tests in CI before deploy
- **Visual Regression**: Consider visual snapshot testing (Percy, Chromatic) for UI-heavy applications
- **Accessibility Testing**: Use axe-core or similar in unit tests; manual testing with screen readers for critical flows (see `frontend/accessibility.md`)
- **Error Boundary Testing**: Test that error boundaries catch and display component failures gracefully (see `global/error-handling.md`)

## Related Standards
- `frontend/accessibility.md` - Accessibility testing with axe-core
- `global/error-handling.md` - Error boundary testing
