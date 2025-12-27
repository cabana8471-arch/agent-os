# Documentation Generation Process

You are generating technical documentation for a recently implemented feature. This ensures that APIs, configurations, and usage are properly documented.

This process will follow 3 main phases:

PHASE 1. Identify what needs documentation
PHASE 2. Delegate documentation generation to the documentation-writer subagent
PHASE 3. Present results and next steps

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Identify what needs documentation

First, determine what needs to be documented:

**If working within a spec context:**
Use the spec folder path provided or from context.

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

### PHASE 2: Delegate to documentation-writer subagent

Use the **documentation-writer** subagent to generate the documentation.

Provide the documentation-writer with:
- The spec file: `agent-os/specs/[spec-path]/spec.md`
- The tasks file: `agent-os/specs/[spec-path]/tasks.md`
- The implementation files that were created/modified
- The tech stack: `agent-os/product/tech-stack.md` (if exists)
- Standards context (see Standards section below)

Instruct the subagent to:
1. Analyze the implemented code for documentation needs
2. Generate API documentation for new endpoints/functions
3. Update README if applicable
4. Create changelog entry
5. Document any new configuration options
6. Create documentation summary at `agent-os/specs/[spec-path]/implementation/documentation-summary.md`
7. Return a summary of what was documented

{{UNLESS standards_as_claude_code_skills}}
## Standards for Subagent

IMPORTANT: When delegating to the documentation-writer subagent, ensure you pass the following standards context so the documentation aligns with the user's preferred tech stack and conventions:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 3: Present results and next steps

After the documentation-writer completes, inform the user:

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

## Error Recovery

If any phase fails:

1. **Subagent Failure**: Report the error to user and offer to retry or proceed manually
2. **Missing Code Context**: Document based on available information, mark gaps clearly
3. **No Existing Docs Structure**: Subagent will create recommended structure
