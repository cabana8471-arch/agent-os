# Spec Initialization

## Core Responsibilities

1. **Get the description of the feature:** Receive it from the user or check the product roadmap
2. **Initialize Spec Structure**: Create the spec folder with date prefix
3. **Save Raw Idea**: Document the user's exact description without modification
4. **Create Create Implementation & Verification Folders**: Setup folder structure for tracking implementation of this spec.
5. **Prepare for Requirements**: Set up structure for next phase

## Workflow

### Step 1: Get the description of the feature

IF you were given a description of the feature, then use that to initiate a new spec.

OTHERWISE follow these steps to get the description:

1. Check `agent-os/product/roadmap.md` to find the next feature in the roadmap.
2. OUTPUT the following to user and WAIT for user's response:

```
Which feature would you like to initiate a new spec for?

- The roadmap shows [feature description] is next. Go with that?
- Or provide a description of a feature you'd like to initiate a spec for.
```

**If you have not yet received a description from the user, WAIT until user responds.**

### Step 2: Initialize Spec Structure

Determine a kebab-case spec name from the user's description, then create the spec folder:

```bash
# Get today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)

# Determine kebab-case spec name from user's description
SPEC_NAME="[kebab-case-name]"

# Create dated folder name
DATED_SPEC_NAME="${TODAY}-${SPEC_NAME}"

# Store this path for output
SPEC_PATH="agent-os/specs/$DATED_SPEC_NAME"

# Create folder structure following architecture
mkdir -p $SPEC_PATH/planning
mkdir -p $SPEC_PATH/planning/visuals

echo "Created spec folder: $SPEC_PATH"
```

### Step 3: Create Implementation and Verification Folders

Create folders for implementation and verification:
- `$SPEC_PATH/implementation/`
- `$SPEC_PATH/verification/`

```bash
mkdir -p $SPEC_PATH/implementation
mkdir -p $SPEC_PATH/verification
```

Leave these folders empty for now. Later, they will be populated with reports documented by implementation and verification agents.

### Step 4: Save Raw Idea

Create `$SPEC_PATH/planning/initialization.md` with the user's description:

```markdown
# Feature Initialization

## Date
[Current date - use format YYYY-MM-DD]

## Raw Description
[User's exact description of the feature without modification]

## Source
- [ ] User provided directly
- [ ] From roadmap item: [roadmap item reference if applicable]

## Initial Notes
[Any additional context or notes gathered during initialization]
```

**Important:** Save the user's exact words without interpretation. This document serves as the source of truth for what the user originally requested.

### Step 5: Output Confirmation

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Spec initialized.
📁 Path: [spec-path]
📊 Structure: planning/, implementation/, verification/ created
⏱️ Next: Run requirements research phase
```

**Do NOT include** detailed folder structure or file descriptions in the conversation response.

## Important Constraints

- Always use dated folder names (YYYY-MM-DD-spec-name)
- Pass the exact spec path back to the orchestrator
- Follow folder structure exactly
- Implementation and verification folders should be empty for now
- **Always create initialization.md** with the raw feature description - this is critical for downstream workflows

## Pre-conditions

- [ ] Product roadmap exists at `agent-os/product/roadmap.md` (if selecting from roadmap)
- [ ] User has provided feature description OR roadmap contains next feature

## Error Recovery

If initialization fails:
1. **Folder already exists:** Check if spec with same name exists for today's date. If so, ask user for a different name or confirm overwrite
2. **Permission denied:** Verify write permissions to `agent-os/specs/` directory
3. **Missing roadmap:** If user wants to select from roadmap but it doesn't exist, prompt user to provide description directly or run `/plan-product` first

For other errors, refer to `{{workflows/implementation/error-recovery}}`
