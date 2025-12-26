# Gather Product Info

## Purpose

Collect comprehensive product information from the user to establish the foundation for product planning.

## Workflow

### Step 1: Check Existing Documentation

```bash
# Check if product folder already exists
if [ -d "agent-os/product" ]; then
    echo "Product documentation already exists. Review existing files or start fresh?"
    # List existing product files
    ls -la agent-os/product/
fi
```

### Step 2: Gather Required Information

Collect from user the following required information:
- **Product Idea**: Core concept and purpose (required)
- **Key Features**: Minimum 3 features with descriptions
- **Target Users**: At least 1 user segment with use cases
- **Tech stack**: Confirmation or info regarding the product's tech stack choices

### Step 3: Prompt for Missing Information

If any required information is missing, prompt user:
```
Please provide the following to create your product plan:
1. Main idea for the product
2. List of key features (minimum 3)
3. Target users and use cases (minimum 1)
4. Will this product use your usual tech stack choices or deviate in any way?
```

**Wait for user response before proceeding.**

## Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

After gathering all required information, return ONLY this summary:

```
✅ Product info gathered.
📁 Data: Ready for mission creation
📊 Summary: [X] features | [X] user segments | Tech: [confirmed/custom]
⏱️ Next: Run product mission workflow
```

**Do NOT include** detailed feature descriptions or full user segment analysis in the conversation response.

## Important Constraints

- All 4 information categories are required before proceeding
- If product folder exists, confirm with user whether to overwrite or update
- Keep gathered information concise but comprehensive

## Pre-conditions

Before running this workflow:
- [ ] User is ready to provide product information
- [ ] No active implementation is in progress (or user confirms it's safe to update product info)

## Error Recovery

If information gathering encounters issues:
1. **User provides incomplete info:** List specific missing items and prompt again
2. **Conflicting tech stack:** Ask user to clarify priorities
3. **Unclear product scope:** Ask probing questions to narrow down the vision
4. **Existing product folder conflict:** Present options: overwrite, merge, or cancel

For other errors, refer to `{{workflows/implementation/error-recovery}}`
