# Create Product Mission

## Purpose

Create the product mission document that defines the core product vision, target users, problems solved, and key features.

## Workflow

### Step 1: Create Mission Document

Create `agent-os/product/mission.md` with comprehensive product definition following this structure for its content:

#### Mission Structure:
```markdown
# Product Mission

## Pitch
[PRODUCT_NAME] is a [PRODUCT_TYPE] that helps [TARGET_USERS] [SOLVE_PROBLEM]
by providing [KEY_VALUE_PROPOSITION].

## Users

### Primary Customers
- [CUSTOMER_SEGMENT_1]: [DESCRIPTION]
- [CUSTOMER_SEGMENT_2]: [DESCRIPTION]

### User Personas
**[USER_TYPE]** ([AGE_RANGE])
- **Role:** [JOB_TITLE/CONTEXT]
- **Context:** [BUSINESS/PERSONAL_CONTEXT]
- **Pain Points:** [SPECIFIC_PROBLEMS]
- **Goals:** [DESIRED_OUTCOMES]

## The Problem

### [PROBLEM_TITLE]
[PROBLEM_DESCRIPTION]. [QUANTIFIABLE_IMPACT].

**Our Solution:** [SOLUTION_APPROACH]

## Differentiators

### [DIFFERENTIATOR_TITLE]
Unlike [COMPETITOR/ALTERNATIVE], we provide [SPECIFIC_ADVANTAGE].
This results in [MEASURABLE_BENEFIT].

## Key Features

### Core Features
- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]

### Collaboration Features
- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]

### Advanced Features
- **[FEATURE_NAME]:** [USER_BENEFIT_DESCRIPTION]
```

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

After creating the mission document, return ONLY this summary:

```
✅ Product mission created.
📁 Report: agent-os/product/mission.md
📊 Summary: Pitch, [X] personas, [X] problems, [X] differentiators, [X] features
⏱️ Next: Run roadmap workflow
```

**Do NOT include** full mission content, detailed personas, or feature descriptions in the conversation response.

## Important Constraints

- **Focus on user benefits** in feature descriptions, not technical details
- **Keep it concise** and easy for users to scan and get the more important concepts quickly
- All placeholders in brackets must be replaced with actual product information

## Pre-conditions

Before running this workflow:
- [ ] Product information has been gathered (via gather-product-info workflow or user input)
- [ ] User has provided: product idea, key features, target users, and tech stack confirmation

## Error Recovery

If mission creation encounters issues:
1. **Missing product information:** Prompt user to provide missing details or run gather-product-info first
2. **Unclear value proposition:** Ask user to clarify the main problem being solved
3. **Too many personas:** Ask user to prioritize 1-2 primary user types
4. **Conflicting differentiators:** Ask user to identify the single most important advantage

For other errors, refer to `{{workflows/implementation/error-recovery}}`
