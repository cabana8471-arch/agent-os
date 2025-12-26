# Documentation Generation Process

You are generating technical documentation for a recently implemented feature. This ensures that APIs, configurations, and usage are properly documented.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Identify what needs documentation

First, determine what needs to be documented:

**If working within a spec context:**
Read `agent-os/specs/[spec-path]/spec.md` and `agent-os/specs/[spec-path]/tasks.md` to understand what was implemented.

**If no spec context:**
Ask the user by outputting the following request and WAIT for their response:

```
What would you like me to document?

Options:
1. Provide a spec folder path (e.g., `agent-os/specs/2024-01-15-feature-name`)
2. Provide specific files or features to document
3. Generate documentation for the entire project (README, API docs)

Please specify which option and provide any necessary paths or details.
```

### PHASE 2: Execute documentation generation

Once you know what to document, generate the comprehensive documentation:

{{workflows/documentation/generate-docs}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Follow the user's documentation style and conventions as detailed in:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 3: Present results and next steps

{{UNLESS compiled_single_command}}
After completing documentation generation, output the following summary to the user:

```
Documentation generation complete!

Created/Updated:
- [List of documentation files created or updated]

Documentation Summary:
- API endpoints documented: [X]
- Components documented: [X]
- Configuration options documented: [X]

Changelog entry added: [Yes/No]

Gaps Identified:
- [Any areas needing additional developer input]

Documentation saved to: `agent-os/specs/[spec-path]/implementation/`

NEXT STEP:
- Review the generated documentation for accuracy
- Fill in any gaps marked with [TODO] or placeholders
- Run `/implement-tasks` to continue with verification if not done
```
{{ENDUNLESS compiled_single_command}}

## Error Recovery

If any phase fails:

1. **Missing Code Context**: Document based on available information, mark gaps clearly
2. **No Existing Docs Structure**: Create recommended structure from scratch
3. **Incomplete Spec**: Generate partial documentation, note missing areas
4. **Unknown API Patterns**: Use generic documentation format, flag for review
