# Test Strategy Process

You are designing a comprehensive test strategy for a feature before implementation begins. This ensures proper test coverage planning and identifies testing requirements upfront.

This process will follow 3 main phases:

PHASE 1. Identify feature to create test strategy for
PHASE 2. Delegate strategy design to the test-strategist subagent
PHASE 3. Present strategy and next steps

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Identify feature to create test strategy for

First, determine which feature needs a test strategy:

**If working within a spec context:**
Use the spec folder path provided or from context.

**If no spec context:**
Ask the user by outputting the following request and WAIT for their response:

```
What feature would you like me to create a test strategy for?

Options:
1. Provide a spec folder path (e.g., `agent-os/specs/2024-01-15-feature-name`)
2. Describe the feature you want to test

If you haven't created a spec yet, consider running:
- `/shape-spec` to define requirements
- `/write-spec` to create detailed specification
```

### PHASE 2: Delegate to test-strategist subagent

Use the **test-strategist** subagent to design the comprehensive test strategy.

Provide the test-strategist with:
- The spec file: `agent-os/specs/[spec-path]/spec.md`
- The tasks file: `agent-os/specs/[spec-path]/tasks.md` (if exists)
- The tech stack: `agent-os/product/tech-stack.md` (if exists)

Instruct the subagent to:
1. Analyze the feature's testing needs
2. Identify current coverage gaps in the codebase
3. Design a balanced testing approach (unit, integration, E2E)
4. Create prioritized test cases
5. Generate the test plan at `agent-os/specs/[spec-path]/implementation/test-plan.md`
6. Return a summary of the strategy

### PHASE 3: Present strategy and next steps

After the test-strategist completes, inform the user:

```
Test strategy complete!

Test Plan Summary:
- Unit tests planned: [X]
- Integration tests planned: [X]
- E2E tests planned: [X]
- Total test cases: [X]

Coverage Gaps Identified:
- [X] files/areas without existing tests
- [X] critical paths needing coverage

Priority Breakdown:
- Must have: [X] tests
- Should have: [X] tests
- Nice to have: [X] tests

Test plan saved to: `agent-os/specs/[spec-path]/implementation/test-plan.md`

NEXT STEP:
- If ready for implementation: Run `/implement-tasks` to start building
- If tasks not created yet: Run `/create-tasks` to break down the work
- Review the test plan and adjust priorities as needed
```

## Error Recovery

If any phase fails:

1. **Subagent Failure**: Report the error to user and offer to retry or proceed manually
2. **No Existing Tests**: Subagent will create strategy from scratch
3. **Missing Test Framework**: Subagent will recommend appropriate framework
