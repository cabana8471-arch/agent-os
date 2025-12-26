# Specification Verification Process

You are verifying a spec and its associated tasks list to ensure accuracy, completeness, and alignment with user requirements before implementation begins.

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

### PHASE 2: Gather verification context

Before running verification, collect the necessary context:

1. **Read the spec folder structure**:
   - `agent-os/specs/[spec-path]/spec.md`
   - `agent-os/specs/[spec-path]/planning/requirements.md`
   - `agent-os/specs/[spec-path]/tasks.md` (if exists)
   - `agent-os/specs/[spec-path]/planning/visuals/` (check for any files)

2. **Load Q&A context** (if available):
   - Original questions asked during requirements gathering
   - User's responses to those questions

### PHASE 3: Execute specification verification

Perform the comprehensive specification verification:

{{workflows/specification/verify-spec}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that the spec and tasks list are ALIGNED and DO NOT CONFLICT with any of user's preferred tech stack, coding conventions, or common patterns as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 4: Present findings and next steps

{{UNLESS compiled_single_command}}
After completing the verification, output the following summary to the user:

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
{{ENDUNLESS compiled_single_command}}

## Error Recovery

If any phase fails:

1. **Missing Spec Files**: Document which files are missing, recommend running `/shape-spec` or `/write-spec`
2. **Incomplete Q&A Data**: Flag as verification gap, recommend re-running requirements gathering
3. **Visual Analysis Failure**: Proceed with text verification, note visual check was skipped
4. **Conflicting Information**: Document all conflicts in verification report with recommendations
