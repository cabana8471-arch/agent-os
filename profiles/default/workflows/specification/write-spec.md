# Spec Writing

## Pre-conditions

- [ ] Requirements documented at `agent-os/specs/[spec-path]/planning/requirements.md`
- [ ] Spec folder structure exists at `agent-os/specs/[spec-path]/`
- [ ] Product tech stack documented at `agent-os/product/tech-stack.md`

## Core Responsibilities

1. **Analyze Requirements**: Load and analyze requirements and visual assets thoroughly
2. **Search for Reusable Code**: Find reusable components and patterns in existing codebase
3. **Create Specification**: Write comprehensive specification document

## Workflow

### Step 1: Analyze Requirements and Context

Read and understand all inputs and THINK HARD:
```bash
# Read the requirements document
cat agent-os/specs/[spec-path]/planning/requirements.md

# Check for visual assets
ls -la agent-os/specs/[spec-path]/planning/visuals/ 2>/dev/null | grep -v "^total" | grep -v "^d"
```

Parse and analyze:
- User's feature description and goals
- Requirements gathered by spec-shaper
- Visual mockups or screenshots (if present)
- Any constraints or out-of-scope items mentioned

### Step 2: Search for Reusable Code

Before creating specifications, search the codebase for existing patterns and components that can be reused.

Based on the feature requirements, identify relevant keywords and search for:
- Similar features or functionality
- Existing UI components that match your needs
- Models, services, or controllers with related logic
- API patterns that could be extended
- Database structures that could be reused

Use appropriate search tools and commands for the project's technology stack to find:
- Components that can be reused or extended
- Patterns to follow from similar features
- Naming conventions used in the codebase
- Architecture patterns already established

Document your findings for use in the specification.

### Step 3: Create Core Specification

Write the main specification to `agent-os/specs/[spec-path]/spec.md`.

DO NOT write actual code in the spec.md document. Just describe the requirements clearly and concisely.

Keep it short and include only essential information for each section.

Follow this structure exactly when creating the content of `spec.md`:

```markdown
# Specification: [Feature Name]

## Goal
[1-2 sentences describing the core objective]

## User Stories
- As a [user type], I want to [action] so that [benefit]
- [repeat for up to 2 max additional user stories]

## Specific Requirements

**Specific requirement name**
- [Up to 8 CONCISE sub-bullet points to clarify specific sub-requirements, design or architectual decisions that go into this requirement, or the technical approach to take when implementing this requirement]

[repeat for up to a max of 10 specific requirements]

## Visual Design
[If mockups provided]

**`planning/visuals/[filename]`**
- [up to 8 CONCISE bullets describing specific UI elements found in this visual to address when building]

[repeat for each file in the `planning/visuals` folder]

## Existing Code to Leverage

**Code, component, or existing logic found**
- [up to 5 bullets that describe what this existing code does and how it should be re-used or replicated when building this spec]

[repeat for up to 5 existing code areas]

## Out of Scope
- [up to 10 concise descriptions of specific features that are out of scope and MUST NOT be built in this spec]
```

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

After writing the specification, return ONLY this summary:

```
✅ Specification written.
📁 Report: agent-os/specs/[spec-path]/spec.md
📊 Summary: [X] requirements | [Y] user stories | [Z] reuse items
⏱️ Next: Ready for task creation
```

**Do NOT include** detailed requirements, user stories, or specification content in the conversation response.

## Important Constraints

1. **Always search for reusable code** before specifying new components
2. **Reference visual assets** when available
3. **Do NOT write actual code** in the spec
4. **Keep each section short**, with clear, direct, skimmable specifications
5. **Do NOT deviate from the template above** and do not add additional sections

## Error Recovery

If spec writing encounters issues:
1. **Missing requirements.md:** Run research-spec workflow first to gather requirements
2. **No reusable code found:** Document that implementation should create new patterns
3. **Conflicting requirements:** Flag in spec and recommend running `/verify-spec` after completion
4. **Visual assets not found:** Document feature without visual references; recommend user add visuals

For other errors, refer to `{{workflows/implementation/error-recovery}}`
