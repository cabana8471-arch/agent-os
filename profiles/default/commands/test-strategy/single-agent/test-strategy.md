# Test Strategy Process

You are designing a comprehensive test strategy for a feature before implementation begins. This ensures proper test coverage planning and identifies testing requirements upfront.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Identify feature to create test strategy for

First, determine which feature needs a test strategy:

**If working within a spec context:**
Use the spec folder path provided or from context. Read:
- `agent-os/specs/[spec-path]/spec.md`
- `agent-os/specs/[spec-path]/tasks.md` (if exists)

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

### PHASE 2: Execute test strategy design

Once you know what feature needs testing, design the comprehensive test strategy:

{{workflows/testing/test-strategy}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure your test strategy aligns with the user's preferred testing conventions and patterns as detailed in the following files:

{{standards/testing/test-writing}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 3: Present strategy and next steps

{{UNLESS compiled_single_command}}
After completing the test strategy, output the following summary to the user:

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
{{ENDUNLESS compiled_single_command}}

## Error Recovery

If any phase fails:

1. **No Existing Tests**: Start from scratch with recommended test structure for the tech stack
2. **Missing Test Framework**: Recommend appropriate framework based on tech stack
3. **Incomplete Coverage Data**: Use code analysis to estimate coverage needs
4. **Missing Spec Context**: Create strategy based on general best practices for the feature type
