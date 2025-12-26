# Rollback Workflow

## Core Responsibilities

1. **Assess Rollback Need**: Determine if rollback is necessary and what scope
2. **Preserve Work**: Ensure any salvageable work is saved before rollback
3. **Execute Rollback**: Safely revert changes to a known-good state
4. **Document**: Record what was rolled back and why

## When to Use This Workflow

Use this workflow when:
- Implementation has corrupted existing functionality
- Failed deployment requires reverting to previous version
- Spec changes invalidate significant completed work
- User requests reverting recent changes
- Critical bugs are discovered that cannot be quickly fixed

## Pre-conditions

Before running this workflow:
- [ ] Identify the target state to roll back to (commit hash, backup, or clean state)
- [ ] Understand what will be lost in the rollback
- [ ] Confirm rollback with user if significant work will be lost

## Rollback Scenarios

### Scenario 1: Code Rollback (Git-based)

**When**: Need to revert code changes to a previous commit.

**Steps:**

1. **Identify rollback target**
   ```bash
   # View recent commits
   git log --oneline -20

   # Find last known good state
   git log --oneline --before="YYYY-MM-DD"
   ```

2. **Create safety branch**
   ```bash
   # Save current state before rollback
   git branch backup-before-rollback
   ```

3. **Execute rollback**

   **Option A: Soft rollback (preserve history)**
   ```bash
   # Create revert commit(s)
   git revert HEAD~N..HEAD --no-commit
   git commit -m "Revert: [reason for rollback]"
   ```

   **Option B: Hard reset (local only, not pushed)**
   ```bash
   git reset --hard <commit-hash>
   ```

4. **Verify rollback**
   ```bash
   # Run tests to confirm working state
   npm test  # or appropriate test command

   # Verify application runs
   npm start  # or appropriate start command
   ```

### Scenario 2: Spec Rollback

**When**: Need to revert specification documents to a previous version.

**Steps:**

1. **Check spec history** (if using git)
   ```bash
   git log --oneline agent-os/specs/[spec-path]/
   ```

2. **Restore previous spec version**
   ```bash
   # Restore specific file to previous version
   git checkout <commit-hash> -- agent-os/specs/[spec-path]/spec.md
   ```

3. **Update related documents**
   - Reset `tasks.md` to match restored spec
   - Clear or update `change-log.md` to reflect rollback
   - Remove invalidated implementation reports

4. **Document in change-log.md**
   ```markdown
   ## Rollback: [Date]

   ### Reason
   [Why rollback was necessary]

   ### Rolled Back To
   [Previous version/date]

   ### Affected Documents
   - spec.md: Reverted to [version]
   - tasks.md: Reset to match spec

   ### Next Steps
   [What to do after rollback]
   ```

### Scenario 3: Partial Rollback

**When**: Only specific files or features need to be reverted.

**Steps:**

1. **Identify affected files**
   ```bash
   # List files changed since target commit
   git diff --name-only <target-commit> HEAD
   ```

2. **Selective restore**
   ```bash
   # Restore specific files
   git checkout <commit-hash> -- path/to/file1 path/to/file2
   ```

3. **Update tasks.md**
   - Mark rolled-back tasks as incomplete `- [ ]`
   - Add note about rollback

### Scenario 4: Database/State Rollback

**When**: Application state or data needs to be reverted.

**Steps:**

1. **Identify backup source**
   - Database backup file
   - Migration down script
   - State snapshot

2. **Execute state rollback**
   ```bash
   # Run down migrations (if applicable)
   npm run migrate:down  # or equivalent

   # Restore from backup (if applicable)
   # [Project-specific restore command]
   ```

3. **Verify data integrity**
   - Check critical data is preserved
   - Verify application functions with restored state

## Rollback Documentation

After any rollback, create or update `[spec-path]/verification/rollback-log.md`:

```markdown
# Rollback Log

## Rollback: [Date] - [Brief Title]

### Trigger
[What caused the need for rollback]

### Scope
- [ ] Full code rollback
- [ ] Partial code rollback (files: [list])
- [ ] Spec rollback
- [ ] Database/state rollback

### Target State
[Commit hash, backup ID, or description of target state]

### What Was Lost
- [Work that was reverted]
- [Time invested: approximately X hours]

### What Was Preserved
- [Any work saved before rollback]
- [Backup branch: backup-before-rollback]

### Verification
- [ ] Tests pass after rollback
- [ ] Application runs correctly
- [ ] No data loss beyond expected scope

### Root Cause Analysis
[Brief analysis of why rollback was needed]

### Prevention
[How to prevent needing rollback in future]

### Next Steps
1. [First action after rollback]
2. [Second action]
```

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Rollback complete.
📁 Report: [spec-path]/verification/rollback-log.md
📊 Summary: Scope: [Full/Partial/Spec/DB] | Target: [commit or state]
⏱️ Status: Verified - tests pass | Backup: [branch name]
```

**Do NOT include** detailed work lost/preserved descriptions, verification checklists, or next steps in the conversation response.

## Important Constraints

- **Always create backup before rollback** - Use a backup branch or export
- **Confirm with user** before rolling back significant work
- **Never force push** without explicit user approval
- **Document everything** - Future debugging depends on good records
- **Verify after rollback** - Always run tests and check application
- **Communicate clearly** - Ensure user understands what was lost/preserved
- **Consider partial rollback first** - Full rollback is last resort
- **Preserve history when possible** - Use revert commits over hard resets
