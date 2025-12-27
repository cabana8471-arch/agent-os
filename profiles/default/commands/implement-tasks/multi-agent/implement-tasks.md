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

**Context to provide to the subagent:**

| Context Item | Path | Purpose |
|--------------|------|---------|
| Task group(s) | `agent-os/specs/[spec-path]/tasks.md` | The parent task, all sub-tasks, and sub-bullet points to implement |
| Spec document | `agent-os/specs/[spec-path]/spec.md` | Full specification with requirements and acceptance criteria |
| Requirements | `agent-os/specs/[spec-path]/planning/requirements.md` | Detailed functional requirements |
| Visual assets | `agent-os/specs/[spec-path]/planning/visuals/` | UI mockups, diagrams, screenshots (if any) |
| Tech stack | `agent-os/product/tech-stack.md` | Project technology choices and patterns (if exists) |

**Subagent instructions:**

Instruct the subagent to:
1. **Read all context files** - Analyze spec.md, requirements.md, and visuals before coding
2. **Analyze codebase patterns** - Scan existing code for conventions, naming, and architecture
3. **Implement tasks sequentially** - Complete each sub-task according to spec requirements
4. **Follow project standards** - Adhere to coding style, security, and performance standards
5. **Update tasks.md** - Mark completed tasks with `- [x]` checkboxes
6. **Return implementation summary** - List all files created/modified with brief descriptions

**Subagent expected output format:**

```
Implementation complete for [task group name].

Files created:
- src/components/Feature.tsx - Main feature component
- src/hooks/useFeature.ts - Feature logic hook

Files modified:
- src/App.tsx - Added feature route
- src/types/index.ts - Added new types

Tasks completed: 5/5
```

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
