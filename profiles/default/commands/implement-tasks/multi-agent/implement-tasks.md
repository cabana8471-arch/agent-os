# Spec Implementation Process

Now that we have a spec and tasks list ready for implementation, we will proceed with implementation of this spec by following this multi-phase process:

PHASE 1: Determine which task group(s) from tasks.md should be implemented
PHASE 2: Delegate implementation to the implementer subagent
PHASE 3: Delegate code review to the code-reviewer subagent
PHASE 4: After ALL task groups have been implemented, delegate to implementation-verifier to produce the final verification report.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Determine which task group(s) to implement

First, check if the user has already provided instructions about which task group(s) to implement.

**If the user HAS provided instructions:** Proceed to PHASE 2 to delegate implementation of those specified task group(s) to the **implementer** subagent.

**If the user has NOT provided instructions:**

Read `agent-os/specs/[spec-path]/tasks.md` to review the available task groups, then output the following message to the user and WAIT for their response:

```
Should we proceed with implementation of all task groups in tasks.md?

If not, then please specify which task(s) to implement.
```

### PHASE 2: Delegate implementation to the implementer subagent

Delegate to the **implementer** subagent to implement the specified task group(s):

Provide to the subagent:
- The specific task group(s) from `agent-os/specs/[spec-path]/tasks.md` including the parent task, all sub-tasks, and any sub-bullet points
- The path to this spec's documentation: `agent-os/specs/[spec-path]/spec.md`
- The path to this spec's requirements: `agent-os/specs/[spec-path]/planning/requirements.md`
- The path to this spec's visuals (if any): `agent-os/specs/[spec-path]/planning/visuals`

Instruct the subagent to:
1. Analyze the provided spec.md, requirements.md, and visuals (if any)
2. Analyze patterns in the codebase according to its built-in workflow
3. Implement the assigned task group according to requirements and standards
4. Update `agent-os/specs/[spec-path]/tasks.md` to mark completed tasks with `- [x]`
5. Return a list of files created or modified during implementation

### PHASE 3: Code Review

After implementation completes, delegate to the **code-reviewer** subagent to review the implemented code.

Provide to the subagent:
- The list of files created/modified during implementation (from PHASE 2)
- The spec context: `agent-os/specs/[spec-path]/spec.md`
- The tasks completed: `agent-os/specs/[spec-path]/tasks.md`

Instruct the subagent to:
1. Perform quality, security, and performance analysis
2. Check standards compliance
3. Create the review report at `agent-os/specs/[spec-path]/implementation/code-review.md`
4. Return a summary with status: Approved / Approved with Comments / Changes Required

**If code-reviewer returns "Changes Required" with Critical issues:**
- Present the critical issues to the user
- Ask: "Would you like to fix these issues before verification? [Y/n]"
- If yes: Return to PHASE 2 with specific fixes needed
- If no: Proceed to PHASE 4 (note issues in verification)

**If code-reviewer returns "Approved" or "Approved with Comments":**
- Proceed to PHASE 4

### PHASE 4: Produce the final verification report

IF ALL task groups in tasks.md are marked complete with `- [x]`, then proceed with this step.  Otherwise, return to PHASE 1.

Assuming all tasks are marked complete, then delegate to the **implementation-verifier** subagent to do its implementation verification and produce its final verification report.

Provide to the subagent the following:
- The path to this spec: `agent-os/specs/[spec-path]`
Instruct the subagent to do the following:
  1. Run all of its final verifications according to its built-in workflow
  2. Produce the final verification report in `agent-os/specs/[spec-path]/verification/final-verification.md`.
