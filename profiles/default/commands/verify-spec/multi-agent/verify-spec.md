# Specification Verification Process

You are verifying a spec and its associated tasks list to ensure accuracy, completeness, and alignment with user requirements before implementation begins.

This process will follow 3 main phases:

PHASE 1. Identify spec to verify
PHASE 2. Delegate verification to the spec-verifier subagent
PHASE 3. Present findings and next steps

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Identify spec to verify

First, determine which spec needs to be verified:

**If you already know which spec:**
Use the spec folder path provided or from context.

**If no spec context:**
Ask the user by outputting the following request and WAIT for their response:

```
Which spec would you like me to verify?

Please provide:
1. The spec folder path (e.g., `agent-os/specs/2024-01-15-feature-name`)

Or if you haven't created a spec yet, run one of these commands first:
- `/shape-spec` to initialize and shape a new spec
- `/write-spec` to create a detailed specification
```

### PHASE 2: Delegate to the spec-verifier subagent

Use the **spec-verifier** subagent to perform the comprehensive specification verification.

Provide to the subagent:
- The spec folder path: `agent-os/specs/[spec-path]/`
- The original Q&A data from requirements gathering (if available in conversation context)
- Any visual assets context

Instruct the subagent to:
1. Verify requirements accuracy against original Q&A
2. Check structural integrity of all spec files
3. Validate visual alignment (if visuals exist)
4. Check reusability opportunities
5. Verify test writing limits compliance
6. Create the verification report at `agent-os/specs/[spec-path]/verification/spec-verification.md`
7. Return a summary of findings

{{UNLESS standards_as_claude_code_skills}}
## Standards for Subagent

IMPORTANT: When delegating to the spec-verifier subagent, ensure you pass the following standards context:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 3: Present findings and next steps

After the spec-verifier completes, inform the user:

```
Specification verification complete!

Verification Summary:
- Overall Status: [Passed / Issues Found / Failed]
- Requirements Accuracy: [Passed / Issues]
- Structural Integrity: [Passed / Issues]
- Visual Alignment: [Passed / N/A / Issues]
- Reusability Check: [Passed / Concerns / Failed]
- Test Writing Limits: [Compliant / Partial / Excessive]

[If passed]
All specifications accurately reflect requirements and are ready for implementation.

[If issues found]
Found [X] issues requiring attention:
- [Number] critical issues (must fix)
- [Number] minor issues (should fix)
- [Number] over-engineering concerns

Report saved to: `agent-os/specs/[spec-path]/verification/spec-verification.md`

NEXT STEP:
- If "Passed": Run `/create-tasks` (if no tasks.md) or `/implement-tasks` to begin implementation
- If "Issues Found": Run `/update-spec` to address critical issues, then run `/verify-spec` again
```

## Error Recovery

If any phase fails:

1. **Subagent Failure**: Report the error to user and offer to retry or proceed manually
2. **Missing Spec Files**: Document which files are missing, recommend running `/shape-spec` or `/write-spec`
3. **Incomplete Q&A Data**: Proceed with limited verification, note gaps in report
