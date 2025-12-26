# /rollback - Revert Changes to a Known-Good State (Multi-Agent)

## Overview

This command helps you safely revert changes when implementation has gone wrong, a deployment has failed, or spec changes have invalidated work.

{{IF use_claude_code_subagents}}
## Delegation

Delegate this task to a **implementer** subagent.

**Provide to the subagent:**
- The target state to roll back to (commit hash, backup description, or "last known good")
- What triggered the need for rollback
- Any work that should be preserved if possible

**Instruct the subagent to:**
1. Follow the rollback workflow: `{{workflows/implementation/rollback}}`
2. Create a backup branch before any destructive operations
3. Verify the rollback was successful (tests pass, app runs)
4. Document the rollback in `agent-os/specs/[spec-path]/verification/rollback-log.md`
5. Return a summary of what was rolled back and what was preserved

{{UNLESS standards_as_claude_code_skills}}
**Include these standards for the subagent:**

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
{{ENDIF use_claude_code_subagents}}

{{UNLESS use_claude_code_subagents}}
## Workflow

{{workflows/implementation/rollback}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure rollback procedures follow the user's conventions:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
{{ENDUNLESS use_claude_code_subagents}}

## Output Summary

After the rollback completes, display:

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

Recommended next steps:
1. Review what caused the need for rollback
2. Update spec or tasks if requirements changed
3. Re-implement with lessons learned
```

## Error Recovery

If rollback fails:

1. **Git conflicts during revert** - Resolve manually or use `git revert --abort`
2. **Backup branch missing** - Check `git reflog` for lost commits
3. **Tests fail after rollback** - Target state may have been unstable, try earlier target
4. **Database state mismatch** - Run migrations down/up as needed

For complex scenarios, consider running `/implement-tasks` with a targeted fix task.
