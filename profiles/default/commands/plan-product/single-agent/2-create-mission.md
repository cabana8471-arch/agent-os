Now that you've gathered information about this product, use that info to create the mission document in `agent-os/product/mission.md` by following these instructions:

{{workflows/planning/create-product-mission}}

{{UNLESS compiled_single_command}}
## Display confirmation and next step

Once you've created mission.md, output the following message:

```
✅ I have documented the product mission at `agent-os/product/mission.md`.

Review it to ensure it matches your vision and strategic goals for this product.

NEXT STEP 👉 Run `3-create-roadmap.md` to create the product roadmap.
```
{{ENDUNLESS compiled_single_command}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Ensure the product mission is ALIGNED and DOES NOT CONFLICT with the user's preferences and standards as detailed in the following files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

## Error Recovery

If this step fails:

1. **Missing product info**: Return to `1-product-concept.md` to gather missing information
2. **File write error**: Check permissions, try alternative location, or output to user for manual save
3. **Unclear vision**: Ask user for clarification on product goals before creating mission
