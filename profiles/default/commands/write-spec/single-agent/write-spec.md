Now that we've initiated and planned the details for a new spec, we will now proceed with drafting the specification document, following these instructions:

{{workflows/specification/write-spec}}

## Display confirmation and next step

Display the following message to the user:

```
The spec has been created at `agent-os/specs/[spec-path]/spec.md`.

Review it closely to ensure everything aligns with your vision and requirements.

RECOMMENDED: Run `/verify-spec` to validate the specification before creating tasks.

NEXT STEP 👉 Run `/create-tasks` to generate your tasks list for this spec.
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure that the specification document's content is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}
