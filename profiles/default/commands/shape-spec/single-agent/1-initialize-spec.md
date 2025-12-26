The FIRST STEP is to initialize the spec by following these instructions:

{{workflows/specification/initialize-spec}}

{{UNLESS compiled_single_command}}
## Display confirmation and next step

Once you've initialized the spec folder, output the following message (replace `[spec-path]` with the folder name for this spec)

```
✅ I have initialized the spec folder at `agent-os/specs/[spec-path]`.

NEXT STEP 👉 Run the command `2-shape-spec.md` to shape the spec requirements.
```
{{ENDUNLESS compiled_single_command}}

## Error Recovery

If this step fails:

1. **Folder creation error**: Check parent directory permissions, verify `agent-os/specs/` exists
2. **Feature description unclear**: Ask user for more details about what they want to build
3. **Naming conflict**: Suggest alternative folder name or ask user for preference
