Now that you've initialized the folder for this new spec, proceed with the research phase.

Follow these instructions for researching this spec's requirements:

{{workflows/specification/research-spec}}

## Display confirmation and next step

After all steps complete, inform the user:

```
Spec initialized successfully!

✅ Spec folder created: `[spec-path]`
✅ Requirements gathered
✅ Visual assets: [Found X files / No files provided]

👉 Run `/write-spec` to create the spec.md document.
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that your research questions and insights are ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

## Error Recovery

If this step fails:

1. **Spec folder not found**: Return to `1-initialize-spec.md` to create the folder first
2. **User doesn't respond to questions**: Wait politely, offer to simplify or skip optional questions
3. **Incomplete requirements**: Document what's available, note gaps for user to address later
