# Specification Update Process

You are updating an existing specification to incorporate changes, corrections, or new requirements discovered after the initial spec was written.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Identify spec and change request

First, determine which spec needs to be updated and what changes are required:

**If you already know which spec and what changes:**
Use the spec folder path and change details provided or from context.

**If no spec context:**
Ask the user by outputting the following request and WAIT for their response:

```
Which spec would you like me to update?

Please provide:
1. The spec folder path (e.g., `agent-os/specs/2024-01-15-feature-name`)
2. Description of the changes needed (new requirements, corrections, scope changes)

If you haven't created a spec yet, run one of these commands first:
- `/shape-spec` to initialize and shape a new spec
- `/write-spec` to create a detailed specification
```

### PHASE 2: Execute spec update

Once you know what spec to update and what changes are required, perform the comprehensive update:

{{workflows/specification/update-spec}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that any updates to the specification remain ALIGNED and DO NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 3: Present changes and next steps

{{UNLESS compiled_single_command}}
After completing the spec update, output the following summary to the user:

```
Spec update complete!

Changes Applied:
- Requirements: [X added / X removed / X modified]
- Spec document: [Updated sections listed]
- Tasks: [X added / X removed / X modified]

Change Source: [User request / Implementation discovery / Verification finding / Code review feedback]

Implementation Status:
- [Not started / In progress / Complete]
- [If in progress: X tasks may need review]

Change documented in: `agent-os/specs/[spec-path]/planning/change-log.md`

NEXT STEP:
- If spec not yet verified: Run `/verify-spec` to validate changes
- If tasks affected: Review updated `tasks.md` before continuing implementation
- If implementation in progress: Communicate changes to implementer agent
```
{{ENDUNLESS compiled_single_command}}

## Error Recovery

If any phase fails:

1. **Spec Files Not Found**: Verify spec folder exists, suggest running `/shape-spec` or `/write-spec` first
2. **Conflicting Changes**: Document conflicts clearly, ask user for resolution preference
3. **Implementation Already Complete**: Create follow-up tasks for modifications instead of changing spec
4. **Change Log Creation Failed**: Create minimal change record in spec.md header as fallback
