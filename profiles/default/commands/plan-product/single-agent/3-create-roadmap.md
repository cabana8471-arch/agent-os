Now that you've created this product's mission.md, use that to guide your creation of the roadmap in `agent-os/product/roadmap.md` by following these instructions:

{{workflows/planning/create-product-roadmap}}

{{UNLESS compiled_single_command}}
## Display confirmation and next step

Once you've created roadmap.md, output the following message:

```
✅ I have documented the product roadmap at `agent-os/product/roadmap.md`.

Review it to ensure it aligns with how you see this product roadmap going forward.

NEXT STEP 👉 Run `4-create-tech-stack.md` to document the tech stack.
```
{{ENDUNLESS compiled_single_command}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure the product roadmap is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

## Error Recovery

If this step fails:

1. **Missing mission.md**: Return to `2-create-mission.md` first
2. **File write error**: Check permissions, try alternative location, or output to user for manual save
3. **Roadmap scope unclear**: Ask user about feature priorities and timeline expectations
