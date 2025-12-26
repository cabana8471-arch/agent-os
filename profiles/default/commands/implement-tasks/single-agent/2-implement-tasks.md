Now that you have the task group(s) to be implemented, proceed with implementation by following these instructions:

{{workflows/implementation/implement-tasks}}

## Display confirmation and next step

Display a summary of what was implemented.

IF all tasks are now marked as done (with `- [x]`) in tasks.md, display this message to user:

```
All tasks have been implemented: `agent-os/specs/[spec-path]/tasks.md`.

NEXT STEP 👉 Run `3-code-review.md` to review the code before verification.
```

IF there are still tasks in tasks.md that have yet to be implemented (marked unfinished with `- [ ]`) then display this message to user:

```
Would you like to proceed with implementation of the remaining tasks in tasks.md?

If not, please specify which task group(s) to implement next.
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that the tasks list is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

## Error Recovery

If this step fails:

1. **Build/compile errors**: Fix errors iteratively, check standards compliance
2. **Test failures**: Review test requirements, fix implementation or adjust tests if spec changed
3. **Stuck on task**: Break into smaller sub-tasks, or ask user for clarification
4. **Need rollback**: Run `/rollback` to revert to a known-good state
