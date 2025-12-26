# Code Review Process

You are performing a code review for recent implementation work. This process ensures code quality, security, and standards compliance before final verification.

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

### PHASE 2: Execute the code review

Once you know what to review, perform the comprehensive code review:

{{workflows/review/code-review}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure your code review evaluates compliance with the user's preferred tech stack, coding conventions, and common patterns as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 3: Present findings and next steps

{{UNLESS compiled_single_command}}
After completing the review, output the following summary to the user:

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
{{ENDUNLESS compiled_single_command}}

## Error Recovery

If any phase fails:

1. **File Access Errors**: Document which files couldn't be accessed and continue with available files
2. **Large Codebase**: Focus on changed files first, then expand review scope if time permits
3. **Missing Spec Context**: Proceed with file-level review without spec-specific context
4. **Ambiguous Standards**: Flag areas where standards are unclear and recommend clarification
