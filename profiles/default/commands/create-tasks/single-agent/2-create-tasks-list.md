Now that you have the spec.md AND/OR requirements.md, please break those down into an actionable tasks list with strategic grouping and ordering, by following these instructions:

{{workflows/implementation/create-tasks-list}}

## Display confirmation and next step

Display the following message to the user:

```
The tasks list has been created at `agent-os/specs/[spec-path]/tasks.md`.

Review it closely to make sure it all looks good.

OPTIONAL: Run `/test-strategy` to design your test plan before implementation.

NEXT STEP 👉 Run `/implement-tasks` (simple) or `/orchestrate-tasks` (advanced) to start building!
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that the tasks list is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

## Error Recovery

If this step fails:

1. **Missing spec/requirements**: Return to `1-get-spec-requirements.md` or run `/shape-spec`
2. **File write error**: Check permissions, try alternative location, or output tasks to user for manual save
3. **Task scope too large**: Break down into smaller features, suggest splitting the spec
