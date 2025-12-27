# /rollback - Revert Changes to a Known-Good State

## Overview

This command helps you safely revert changes when implementation has gone wrong, a deployment has failed, or spec changes have invalidated work.

## Pre-conditions

Before running this command:
- [ ] Identify the target state to roll back to (commit hash, backup, or clean state)
- [ ] Understand what will be lost in the rollback
- [ ] Confirm with user if significant work will be lost

## Workflow

{{workflows/implementation/rollback}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure rollback procedures follow the user's conventions and patterns as detailed in:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

## Output Protocol

Follow the output protocol for context optimization:

{{protocols/output-protocol}}

## Output Summary

After completing the rollback, display:

```
Rollback complete!

Scope: [Full / Partial / Spec-only / Database]
Target: [Commit hash or description]
Backup: [backup-before-rollback branch / none]

Verified:
- [x] Tests passing
- [x] Application runs
- [x] Data integrity confirmed

Work preserved: [Description of any saved work]
Work lost: [Description of reverted work]

Documentation: agent-os/specs/[spec-path]/verification/rollback-log.md

Next steps:
1. [Recommended first action]
2. [Recommended second action]
```

## Error Recovery

If rollback fails:

1. **Git conflicts during revert**
   - Resolve conflicts manually
   - Use `git revert --abort` if needed and try alternative approach

2. **Backup branch missing**
   - Check `git branch -a` for similar branches
   - Use `git reflog` to find lost commits

3. **Tests fail after rollback**
   - Target state may have been unstable
   - Try rolling back further or to a different target

4. **Database state mismatch**
   - Run migrations down/up as needed
   - Check for orphaned data

For complex rollback scenarios, consider running `/implement-tasks` with a fix task instead.
