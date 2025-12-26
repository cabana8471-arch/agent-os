# Specification Update Process

You are updating an existing specification to incorporate changes, corrections, or new requirements discovered after the initial spec was written.

This process will follow 3 main phases:

PHASE 1: Identify spec and change request
PHASE 2: Delegate update to the spec-writer subagent
PHASE 3: Present changes and next steps

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

### PHASE 2: Delegate update to the spec-writer subagent

Use the **spec-writer** subagent to perform the comprehensive specification update.

Provide to the **spec-writer** subagent:
- The spec folder path: `agent-os/specs/[spec-path]/`
- The change request details (what needs to be updated and why)
- The source of change (user request, implementation discovery, verification finding, code review feedback)
- Any visual assets or reference materials if applicable

Instruct the subagent to:
1. Document the change request in `planning/change-log.md`
2. Assess impact on requirements, spec, and tasks
3. Update `requirements.md` if scope changes
4. Update `spec.md` with change notes
5. Update `tasks.md` if implementation affected
6. Handle any in-progress implementation considerations
7. Return a summary of changes applied

### PHASE 3: Present changes and next steps

After the spec-writer completes, inform the user:

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

## Error Recovery

If any phase fails:

1. **Subagent Failure**: Report the error to user and offer to retry or proceed with single-agent mode
2. **Spec Files Not Found**: Verify spec folder exists, suggest running `/shape-spec` or `/write-spec` first
3. **Conflicting Changes**: Document conflicts clearly, ask user for resolution preference
4. **Implementation Already Complete**: Create follow-up tasks for modifications instead of changing spec
