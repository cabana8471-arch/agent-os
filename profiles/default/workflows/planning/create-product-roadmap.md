# Create Product Roadmap

## Purpose

Generate an ordered feature checklist that guides development from MVP to complete product, based on the product mission.

## Pre-conditions

Before running this workflow:
- [ ] Product mission exists at `agent-os/product/mission.md`
- [ ] User has confirmed the mission document is ready for roadmap creation

## Workflow

### Step 1: Review the Mission

Read `agent-os/product/mission.md` to understand the product's goals, target users, and success criteria.

### Step 2: Identify Features

Based on the mission, determine the list of concrete features needed to achieve the product vision.

Do not include any tasks for initializing a new codebase or bootstrapping a new application. Assume the user is already inside the project's codebase and has a bare-bones application initialized.

### Step 3: Strategic Ordering

Order features based on:
- Technical dependencies (foundational features first)
- Most direct path to achieving the mission
- Building incrementally from MVP to full product

### Step 4: Create the Roadmap

Generate `agent-os/product/roadmap.md` with an ordered feature checklist.

Use the structure below as your template. Replace all bracketed placeholders (e.g., `[FEATURE_NAME]`, `[DESCRIPTION]`, `[EFFORT]`) with real content that you create based on the mission.

#### Roadmap Structure:
```markdown
# Product Roadmap

1. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
2. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
3. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
4. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
5. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
6. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
7. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`
8. [ ] [FEATURE_NAME] — [1-2 SENTENCE DESCRIPTION OF COMPLETE, TESTABLE FEATURE] `[EFFORT]`

> Notes
> - Order items by technical dependencies and product architecture
> - Each item should represent an end-to-end (frontend + backend) functional and testable feature
```

Effort scale:
- `XS`: 1 day
- `S`: 2-3 days
- `M`: 1 week
- `L`: 2 weeks
- `XL`: 3+ weeks

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

After creating the roadmap, return ONLY this summary:

```
✅ Product roadmap created.
📁 Report: agent-os/product/roadmap.md
📊 Summary: [X] features planned | Effort: [X] XS, [X] S, [X] M, [X] L
⏱️ Next: Ready for specification phase
```

**Do NOT include** full feature list or detailed descriptions in the conversation response.

## Important Constraints

- **Make roadmap actionable** - include effort estimates and dependencies
- **Priorities guided by mission** - When deciding on order, aim for the most direct path to achieving the mission as documented in mission.md
- **Ensure phases are achievable** - start with MVP, build incrementally

## Error Recovery

If roadmap creation encounters issues:
1. **Missing mission.md:** Prompt user to run `/plan-product` first or create mission manually
2. **Unclear feature scope:** Ask user for clarification on product boundaries
3. **Conflicting priorities:** Present options to user and let them decide feature order
4. **Too many features:** Suggest splitting into phases (MVP, v1.1, v2.0)

For other errors, refer to `{{workflows/implementation/error-recovery}}`
