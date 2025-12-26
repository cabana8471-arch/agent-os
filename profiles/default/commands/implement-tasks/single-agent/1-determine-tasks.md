First, check if the user has already provided instructions about which task group(s) to implement.

**If the user HAS provided instructions:** Proceed to PHASE 2 to delegate implementation of those specified task group(s) to the **implementer** subagent.

**If the user has NOT provided instructions:**

Read `agent-os/specs/[spec-path]/tasks.md` to review the available task groups, then output the following message to the user and WAIT for their response:

```
Should we proceed with implementation of all task groups in tasks.md?

If not, then please specify which task(s) to implement.
```

## Error Recovery

If this step fails:

1. **tasks.md not found**: Suggest running `/create-tasks` first to generate the tasks list
2. **Empty tasks.md**: Verify spec exists, suggest running `/create-tasks` to populate tasks
3. **User unclear about scope**: Help them review task groups and make a selection
