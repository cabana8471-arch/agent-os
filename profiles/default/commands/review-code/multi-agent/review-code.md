# Code Review Process

You are performing a code review for recent implementation work. This process ensures code quality, security, and standards compliance before final verification.

This process will follow 3 main phases:

PHASE 1. Identify code to review
PHASE 2. Delegate review to the code-reviewer subagent
PHASE 3. Present findings and next steps

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Identify code to review

First, determine which code needs to be reviewed:

**If working within a spec context:**
Read `agent-os/specs/[spec-path]/tasks.md` to identify completed tasks and their associated files.

**If no spec context:**
Ask the user what code to review by outputting the following request and WAIT for their response:

```
What code would you like me to review?

Options:
1. Provide a spec folder path (e.g., `agent-os/specs/2024-01-15-feature-name`)
2. Provide specific file paths to review
3. Review recent git changes (I'll check the last commit)

Please specify which option and provide the necessary paths.
```

### PHASE 2: Delegate to code-reviewer subagent

Use the **code-reviewer** subagent to perform the comprehensive code review.

Provide the code-reviewer with:
- The list of files to review (from PHASE 1)
- The spec context if available: `agent-os/specs/[spec-path]/spec.md`
- The tasks context if available: `agent-os/specs/[spec-path]/tasks.md`
- The tech stack: `agent-os/product/tech-stack.md` (if exists)

Instruct the subagent to:
1. Perform quality, security, and performance analysis
2. Check standards compliance
3. Create the review report at `agent-os/specs/[spec-path]/implementation/code-review.md`
4. Return a summary of findings

### PHASE 3: Present findings and next steps

After the code-reviewer completes, inform the user:

```
Code review complete!

Review Summary:
- Files reviewed: [X]
- Critical issues: [X]
- Major issues: [X]
- Minor issues: [X]

Overall Status: [Approved / Approved with Comments / Changes Required]

Report saved to: `agent-os/specs/[spec-path]/implementation/code-review.md`

[If changes required]
The following must be addressed before proceeding:
- [Critical issue 1 summary]
- [Critical issue 2 summary]

NEXT STEP:
- If "Approved" or "Approved with Comments": Run `/implement-tasks` to verify implementation
- If "Changes Required": Address the critical issues, then run `/review-code` again
```

## Error Recovery

If any phase fails:

1. **Subagent Failure**: Report the error to user and offer to retry or proceed manually
2. **File Access Errors**: Document which files couldn't be accessed and continue with available files
3. **Missing Spec Context**: Proceed with file-level review without spec-specific context
