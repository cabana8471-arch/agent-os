# Spec Writing Process

You are creating a comprehensive specification for a new feature.

This process will follow 3 main phases:

PHASE 1. Identify the spec path
PHASE 2. Delegate specification writing to the spec-writer subagent
PHASE 3. Present results and next steps

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Identify Spec Path

First, determine the spec folder to write the specification for:

**If working within a spec context:**
Use the spec folder path provided or from context.

**If no spec context:**
Look for the most recent spec folder in `agent-os/specs/*/` or ask the user:

```
Which spec would you like me to write the specification for?

Please provide the spec folder path (e.g., `agent-os/specs/2024-01-15-feature-name`)
```

### PHASE 2: Delegate to spec-writer subagent

Use the **spec-writer** subagent to create the specification document.

Provide the spec-writer with:
- The spec folder path (found in PHASE 1)
- The requirements from `agent-os/specs/[spec-path]/planning/requirements.md`
- Any visual assets in `agent-os/specs/[spec-path]/planning/visuals/`
- The tech stack: `agent-os/product/tech-stack.md` (if exists)
- Standards context (see Standards section below)

Instruct the subagent to:
1. Read and analyze the requirements document
2. Review any visual assets provided
3. Create a comprehensive `spec.md` inside the spec folder
4. Return a summary of the specification created

{{UNLESS standards_as_claude_code_skills}}
## Standards for Subagent

IMPORTANT: When delegating to the spec-writer subagent, ensure you pass the following standards context so the specification aligns with the user's preferred tech stack and conventions:

{{standards/global/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 3: Present results and next steps

After the spec-writer completes, inform the user:

```
Your spec.md is ready!

Spec document created: `agent-os/specs/[spec-path]/spec.md`

Summary:
- [Brief summary of what was specified]
- [Key features/components covered]

RECOMMENDED: Run `/verify-spec` to validate the specification before creating tasks.

NEXT STEP 👉 Run `/create-tasks` to generate your tasks list for this spec.
```

## Error Recovery

If any phase fails:

1. **Subagent Failure**: Report the error to user and offer to retry or proceed manually
2. **Missing Requirements**: Ask user to run `/shape-spec` first to gather requirements
3. **Missing Spec Folder**: Ask user to provide the correct path or run `/shape-spec` to initialize
