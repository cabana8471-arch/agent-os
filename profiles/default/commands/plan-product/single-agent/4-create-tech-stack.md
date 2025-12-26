The final part of our product planning process is to document this product's tech stack in `agent-os/product/tech-stack.md`.  Follow these instructions to do so:

{{workflows/planning/create-product-tech-stack}}

## Display confirmation and next step

Once you've created tech-stack.md, output the following message:

```
✅ I have documented the product's tech stack at `agent-os/product/tech-stack.md`.

Review it to ensure all of the tech stack details are correct for this product.

You're ready to start planning a feature spec! You can do so by running `shape-spec.md` or `write-spec.md`.
```

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

The user may provide information regarding their tech stack, which should take precidence when documenting the product's tech stack.  To fill in any gaps, find the user's usual tech stack information as documented in any of these files:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

## Error Recovery

If this step fails:

1. **Missing mission/roadmap**: Complete earlier steps first (`2-create-mission.md`, `3-create-roadmap.md`)
2. **File write error**: Check permissions, try alternative location, or output to user for manual save
3. **Tech stack unclear**: Default to common modern stack, note as "to be confirmed" for user review
