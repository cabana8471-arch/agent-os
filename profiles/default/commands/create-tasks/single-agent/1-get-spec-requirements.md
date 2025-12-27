The FIRST STEP is to make sure you have ONE OR BOTH of these files to inform your tasks breakdown:
- `agent-os/specs/[spec-path]/spec.md`
- `agent-os/specs/[spec-path]/planning/requirements.md`

IF you don't have ONE OR BOTH of those files in your current conversation context, then ask user to provide direction on where to you can find them by outputting the following request then wait for user's response:

"I'll need a spec.md or requirements.md (or both) in order to build a tasks list.

Please direct me to where I can find those.  If you haven't created them yet, you can run /shape-spec or /write-spec."

{{UNLESS compiled_single_command}}
## Display confirmation and next step

Once you've confirmed you have the spec and/or requirements, output the following message (replace `[spec-path]` with the folder name for this spec)

```
✅ I have the spec and requirements `[spec and requirements path]`.

NEXT STEP 👉 Proceed to the next phase to create the tasks list.
```
{{ENDUNLESS compiled_single_command}}

## Error Recovery

If this step fails:

1. **Spec files not found**: Verify path is correct, or suggest running `/shape-spec` or `/write-spec` first
2. **Incomplete spec**: Proceed with available information, note gaps in tasks for clarification
3. **Path confusion**: Ask user to confirm the spec folder path
