Now that we've implemented the task group(s), we must perform a code review before final verification.

## Workflow

### Step 1: Identify files to review

Review the files that were created or modified during implementation in PHASE 2.

If you don't have a clear list, check:
- Git status for recent changes: `git status`
- The tasks that were just completed in `tasks.md`

### Step 2: Execute code review

{{workflows/review/code-review}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure your code review evaluates compliance with the user's preferred tech stack, coding conventions, and common patterns as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### Step 3: Handle review results

**If code review finds Critical issues:**

Output the following to the user:

```
Code review found critical issues that should be addressed before verification:

[List critical issues]

Would you like me to:
1. Fix these issues now (recommended)
2. Proceed to verification anyway (issues will be noted)

Reply with your choice.
```

If user chooses to fix: Return to PHASE 2 to implement the fixes, then repeat this code review.

**If code review passes (Approved or Approved with Comments):**

Save the code review report to `agent-os/specs/[spec-path]/implementation/code-review.md` and proceed to PHASE 4 (verification).
