# Process for Orchestrating a Spec's Implementation

<!-- Reference Syntax Note:
  - `agent-os/path` or `@agent-os/path`: Runtime file paths agents read using the Read tool
  - `{{workflows/...}}`: Template syntax processed at compile/install time
-->

Now that we have a spec and tasks list ready for implementation, we will proceed with orchestrating implementation of each task group by a dedicated agent using the following MULTI-PHASE process.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Get tasks.md for this spec

IF you already know which spec we're working on and IF that spec folder has a `tasks.md` file, then use that and skip to PHASE 2.

IF you don't already know which spec we're working on OR that spec folder doesn't yet have a `tasks.md`, THEN output the following request to the user:

```
Please point me to a spec's `tasks.md` that you want to orchestrate implementation for.

If you don't have one yet, then run any of these commands first:
/shape-spec
/write-spec
/create-tasks
```

### PHASE 2: Create orchestration.yml with smart agent assignment

In this spec's folder, create: `agent-os/specs/[spec-path]/orchestration.yml`.

#### Smart Agent Assignment

Analyze each task group name and content to auto-assign the appropriate agent and standards:

**Assignment Rules:**
- Task contains "API", "endpoint", "backend", "database", "server", "auth" → `implementer` + `backend/*` + `global/*` standards
- Task contains "component", "UI", "style", "layout", "frontend", "page", "view" → `implementer` + `frontend/*` + `global/*` standards
- Task contains "test", "spec", "coverage", "quality" → `test-strategist` + `testing/*` standards
- Default → `implementer` + `global/*` standards

Create `orchestration.yml` with auto-assigned values:

```yaml
# Auto-generated orchestration plan
# Review and modify assignments as needed

spec_path: agent-os/specs/[spec-path]
created_at: [current-date]

task_groups:
  - name: [task-group-name]
    agent: [auto-assigned-agent]
    standards: [auto-assigned-standards]
    status: pending

  - name: [task-group-name]
    agent: [auto-assigned-agent]
    standards: [auto-assigned-standards]
    status: pending

  # Repeat for each task group
```

#### User Review

After creating orchestration.yml, present it to the user:

```
I've created an orchestration plan with auto-assigned agents and standards:

[Show task groups with assignments]

Would you like to:
1. Proceed with these assignments (default)
2. Modify specific assignments

Reply with your choice or specify changes (e.g., "Task 2 should use test-strategist").
```

If user requests changes, update orchestration.yml accordingly.

{{IF use_claude_code_subagents}}
### PHASE 3: Execute orchestrated implementation

Loop through each task group in order and delegate to the assigned agent.

**For each task group:**

1. **Update status to in_progress** in orchestration.yml:
   ```yaml
   - name: [task-group-name]
     status: in_progress
     started_at: [timestamp]
   ```

2. **Delegate to the assigned agent subagent**

   Provide to the subagent:
   - The task group (parent task + all sub-tasks)
   - The spec file: `agent-os/specs/[spec-path]/spec.md`
   - Requirements: `agent-os/specs/[spec-path]/planning/requirements.md`
   - Visuals: `agent-os/specs/[spec-path]/planning/visuals` (if exists)
   {{UNLESS standards_as_claude_code_skills}}
   - Standards files based on assignment in orchestration.yml:
     {{workflows/implementation/compile-implementation-standards}}
   {{ENDUNLESS standards_as_claude_code_skills}}

   Instruct the subagent to:
   1. Implement the assigned tasks
   2. Mark completed tasks with `- [x]` in tasks.md
   3. Return list of files created/modified

3. **Code review for this task group**

   Delegate to the **code-reviewer** subagent with files modified in this task group.
   - If "Changes Required": Fix issues before proceeding
   - Update review status in orchestration.yml:
   ```yaml
   - name: [task-group-name]
     review_status: approved  # or "changes_required" → "fixed"
   ```

4. **Update status on completion**:
   ```yaml
   - name: [task-group-name]
     status: completed  # or "failed" if errors occurred
     completed_at: [timestamp]
     files_modified: [list from subagent]
   ```

5. **Handle failures**:
   If a task group fails:
   - Update status to `failed` with error message
   - Ask user: "Task group [name] failed. Options: 1) Retry, 2) Skip, 3) Abort"
   - Log error to `agent-os/specs/[spec-path]/errors.log`

### PHASE 4: Final Verification

After ALL task groups are completed (with inline code reviews already done per task group):

1. **Generate consolidated code review report**:
   - Aggregate review results from each task group
   - Create summary at `agent-os/specs/[spec-path]/implementation/code-review.md`

2. **Delegate to the implementation-verifier subagent**

   Provide to the subagent:
   - The spec path: `agent-os/specs/[spec-path]`

   Instruct the subagent to:
   1. Run all final verifications according to its built-in workflow
   2. Produce the final verification report at `agent-os/specs/[spec-path]/verification/final-verification.md`

### PHASE 5: Output completion summary

```
Orchestration complete!

Task Groups:
[List each task group with status and completion time]

Code Review: [Approved / Approved with Comments / Changes Required]
Verification: [Passed / Issues Found]

Files Modified: [total count]

Reports:
- Code review: agent-os/specs/[spec-path]/implementation/code-review.md
- Verification: agent-os/specs/[spec-path]/verification/final-verification.md

Orchestration log: agent-os/specs/[spec-path]/orchestration.yml
```
{{ENDIF use_claude_code_subagents}}

{{UNLESS use_claude_code_subagents}}
### PHASE 3: Generate implementation prompts

For users without subagent support, generate prompt files for manual execution.

Loop through each task group and create a prompt file at:
`agent-os/specs/[spec-path]/implementation/prompts/[number]-[task-group-name].md`

**Prompt file template:**

```markdown
# Task Group [number]: [task-group-name]

## Tasks to Implement

[paste entire task group including parent task and all sub-tasks]

## Context

Read these files for context:
- @agent-os/specs/[spec-path]/spec.md
- @agent-os/specs/[spec-path]/planning/requirements.md
- @agent-os/specs/[spec-path]/planning/visuals (if exists)

## Implementation Instructions

{{workflows/implementation/implement-tasks}}

{{UNLESS standards_as_claude_code_skills}}
## Standards to Follow

Follow these standards during implementation:
[standards based on orchestration.yml assignment]
{{ENDUNLESS standards_as_claude_code_skills}}

## Completion

When done:
1. Mark tasks as complete with `- [x]` in tasks.md
2. Update orchestration.yml status to `completed`
```

### PHASE 4: Output prompt list

```
Ready to begin implementation of [spec-title]!

Prompt files created:
[list prompt files in order]

How to use:
1. Open each prompt file in order
2. Copy the content into your AI assistant
3. After each task group, update orchestration.yml status

Progress tracking:
- Tasks: agent-os/specs/[spec-path]/tasks.md
- Orchestration: agent-os/specs/[spec-path]/orchestration.yml

When all task groups are complete, run `/review-code` followed by `/implement-tasks` for verification.
```
{{ENDUNLESS use_claude_code_subagents}}

## Error Recovery

If any phase fails, follow the error recovery workflow for detailed guidance:

{{workflows/implementation/error-recovery}}

**Quick reference:**

1. **Task Group Failure**: Log to errors.log, update orchestration.yml status, ask user for action
2. **Agent Unavailable**: Fall back to default `implementer` agent
3. **Standards Not Found**: Proceed with `global/*` standards, warn user
4. **Partial Completion**: Can resume from last pending task group using orchestration.yml state
5. **Code Review Rejection**: Fix critical issues before proceeding to next task group
6. **Test Failures**: Run error recovery workflow Category 1, then retry verification

## NEXT STEP

After orchestration is complete:

1. **If all verifications passed**: The feature is ready for deployment or further testing
2. **If issues were found**: Review the verification report and address any CRITICAL or HIGH issues
3. **For additional features**: Run `/shape-spec` or `/create-tasks` for the next feature in the roadmap

**Related commands:**
- `/review-code` - For additional code review passes
- `/test-strategy` - For comprehensive test planning
- `/generate-docs` - To document the implemented features
