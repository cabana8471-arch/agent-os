# Feature Analysis Process

You are performing a feature discovery and analysis to identify existing functionality, propose new features, and prevent duplicate implementations. This helps understand the codebase and plan future development.

This process will follow 3 main phases:

PHASE 1. Define analysis scope and mode
PHASE 2. Delegate analysis to the feature-analyst subagent
PHASE 3. Present findings and recommendations

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Define analysis scope and mode

Determine what to analyze and how:

**Ask the user by outputting the following request and WAIT for their response:**

```
What type of feature analysis would you like me to perform?

Analysis Modes:
1. **Discover** - Catalog all existing features in the codebase
2. **Propose** - Suggest new features based on existing patterns
3. **Check Duplicate** - Verify a proposed feature doesn't already exist
4. **Full Analysis** - Discover features, analyze patterns, and propose improvements

Scope Options:
- Full codebase (recommended for first analysis)
- Specific directory or module (e.g., `src/features/`)
- Specific area (e.g., "user management", "payments")

Please specify your preferred mode and scope.
```

**If checking for duplicates, also ask:**

```
Please describe the feature you're planning to implement:
- Feature name
- Brief description of functionality
- Key components it would include (routes, services, models, etc.)
```

### PHASE 2: Delegate to feature-analyst subagent

Use the **feature-analyst** subagent to perform the comprehensive analysis.

Provide the feature-analyst with:
- The analysis mode (discover/propose/duplicate-check/full)
- The scope (directory, files, or full codebase)
- Any proposed feature description (if checking duplicates)
- The tech stack: `agent-os/product/tech-stack.md` (if exists)
- Product mission: `agent-os/product/mission.md` (if exists)

Instruct the subagent to:
1. Scan the codebase based on the specified scope
2. Identify and catalog existing features
3. Analyze patterns and conventions used
4. Check for duplicates (if proposed feature provided)
5. Generate feature proposals (if requested)
6. Create the analysis report at `agent-os/reports/feature-analysis-[date].md`
7. Return a summary of findings

### PHASE 3: Present findings and recommendations

After the feature-analyst completes, inform the user with appropriate summary based on mode:

**For Discover mode:**
```
Feature discovery complete!

Features Found: [X] total
- Backend: [X] (APIs, services, models)
- Frontend: [X] (pages, components)
- Full-Stack: [X] (end-to-end features)

Architecture Pattern: [Detected pattern]
Code Organization: [Observed structure]

Feature Categories:
- [Category 1]: [X] features
- [Category 2]: [X] features
- [Category 3]: [X] features

Gaps Identified: [X] missing/incomplete features

Full report: `agent-os/reports/feature-analysis-[date].md`

NEXT STEPS:
- Review the feature catalog for accuracy
- Use this as baseline for new feature planning
- Consider addressing identified gaps
```

**For Propose mode:**
```
Feature proposals ready!

Based on [X] existing features and [Y] patterns identified:

Top 3 Proposed Features:
1. [FEAT-001] [Feature Name] - [Brief description]
2. [FEAT-002] [Feature Name] - [Brief description]
3. [FEAT-003] [Feature Name] - [Brief description]

Gap Analysis:
- [GAP-001] [Missing functionality]
- [GAP-002] [Missing functionality]

Extension Opportunities: [X] existing features could be enhanced

Full report: `agent-os/reports/feature-analysis-[date].md`

NEXT STEPS:
- Review proposed features with stakeholders
- Prioritize based on business value
- Create specs for approved features using /shape-spec
```

**For Check Duplicate mode:**
```
Duplicate check complete!

Proposed Feature: [Feature Name]
Result: [NO_CONFLICT / PARTIAL_OVERLAP / EXACT_MATCH / NAMING_CONFLICT]

[If conflict found:]
Issue ID: [DUP-XXX]
Existing Feature: [Name] at [location]
Overlap: [Description of overlap]
Recommendation: [Proceed / Modify / Use Existing / Extend]

[If no conflict:]
The proposed feature is unique and does not overlap with existing functionality.
Proceed with creating the spec.

Full report: `agent-os/reports/feature-analysis-[date].md`

NEXT STEPS:
[Based on result - proceed with spec, modify proposal, or extend existing]
```

**For Full Analysis mode:**
```
Full feature analysis complete!

Features Discovered: [X] total
Patterns Identified: [Y]
Proposals Generated: [Z]
Gaps Found: [W]

Summary:
- Architecture: [Pattern detected]
- Code Quality: [Assessment]
- Feature Coverage: [Assessment]

Top Recommendations:
1. [Most impactful recommendation]
2. [Second recommendation]
3. [Third recommendation]

Full report: `agent-os/reports/feature-analysis-[date].md`

NEXT STEPS:
- Review complete feature catalog
- Prioritize proposed features
- Address identified gaps
- Consider extending existing features
```

## Error Recovery

If any phase fails:

1. **Subagent Failure**: Report the error to user and offer to retry or proceed manually
2. **Large Codebase**: Subagent will focus on entry points and routes first
3. **Unfamiliar Framework**: Analysis will focus on universal patterns
4. **No Clear Architecture**: This is noted as a finding in the report
