# Refactoring Analysis Workflow

## Pre-conditions

Before running this workflow:
- [ ] Codebase is accessible and readable
- [ ] (Optional) Specific area/module to focus on is identified
- [ ] (Optional) Spec path known if analyzing for a specific feature

## Workflow

### Step 1: Define Analysis Scope

Determine what to analyze:

1. **If analyzing a specific spec**: Focus on files changed/created for that spec
2. **If general analysis**: Start with high-traffic areas (entry points, core logic)
3. **If user-specified**: Focus on the area the user indicated

```bash
# Get overview of codebase structure
find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.rb" \) | head -50

# Identify large files (potential refactoring candidates)
find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) -exec wc -l {} \; | sort -rn | head -20
```

### Step 2: Detect Code Smells

Analyze code for common anti-patterns:

**Function/Method Level:**
- Long methods (>50 lines)
- Too many parameters (>4)
- Deep nesting (>3 levels)
- Duplicate code blocks
- Feature envy (method uses another class's data excessively)

**Class/Module Level:**
- God classes (too many responsibilities)
- Data classes (only getters/setters, no logic)
- Large classes (>300 lines)
- Inappropriate intimacy (classes too tightly coupled)

**Architecture Level:**
- Circular dependencies
- Missing abstraction layers
- Shotgun surgery (changes require touching many files)
- Divergent change (class changes for multiple reasons)

### Step 3: Assess Technical Debt

Categorize findings by impact and effort:

**Technical Debt Categories:**
1. **Critical**: Actively causing bugs or blocking features
2. **High**: Significantly slowing development velocity
3. **Medium**: Makes code harder to understand/maintain
4. **Low**: Minor improvements, nice to have

**Effort Estimation:**
- **Quick Win**: < 1 hour, low risk
- **Small**: 1-4 hours, low-medium risk
- **Medium**: 1-2 days, medium risk
- **Large**: 1+ weeks, high risk

### Step 4: Analyze Dependencies and Coupling

Map component relationships:

```bash
# Find import patterns (adjust for your language)
grep -r "^import\|^from\|require(" --include="*.ts" --include="*.js" --include="*.py" src/ | head -50
```

Look for:
- Circular dependency chains
- Components with too many dependents
- Tightly coupled modules
- Missing interfaces/abstractions

### Step 5: Generate Refactoring Recommendations

For each issue found, provide:

1. **What**: Specific code smell or problem
2. **Where**: File and line numbers
3. **Why**: Impact on maintainability/development
4. **How**: Specific refactoring technique to apply
5. **Risk**: What could go wrong
6. **Effort**: Time estimate

**Common Refactoring Techniques:**
- Extract Method/Function
- Extract Class/Module
- Introduce Parameter Object
- Replace Conditional with Polymorphism
- Move Method
- Inline Method (for over-abstraction)
- Introduce Interface
- Compose Method

### Step 6: Create Refactoring Report

Write to `agent-os/specs/[spec-path]/implementation/refactoring-analysis.md` or `agent-os/reports/refactoring-analysis-[date].md`:

```markdown
# Refactoring Analysis Report

## Analysis Summary
- **Date**: [Current date]
- **Scope**: [What was analyzed]
- **Files Analyzed**: [count]
- **Issues Found**: [count by severity]

## Critical Issues

### Issue 1: [Descriptive Name]
- **Location**: `path/to/file.ts:42-85`
- **Type**: [Code Smell Type]
- **Description**: [What's wrong and why it matters]
- **Impact**: [How this affects development/maintenance]
- **Recommended Refactoring**: [Specific technique]
  ```
  // Before (conceptual)
  [problematic pattern]

  // After (conceptual)
  [improved pattern]
  ```
- **Effort**: [Quick Win / Small / Medium / Large]
- **Risk**: [Low / Medium / High] - [explanation]

## High Priority Issues

[Same format as Critical]

## Medium Priority Issues

[Same format, can be more condensed]

## Low Priority / Nice to Have

- `file.ts:10` - Consider extracting [logic] to separate function
- `module/` - Could benefit from interface extraction

## Architecture Observations

### Coupling Analysis
[Description of coupling issues]

### Dependency Graph Concerns
[Circular dependencies or problematic patterns]

### Missing Abstractions
[Where interfaces or abstract classes could help]

## Refactoring Roadmap

### Phase 1: Quick Wins (Immediate)
1. [ ] [Specific refactoring task]
2. [ ] [Specific refactoring task]

### Phase 2: High Impact (This Sprint)
1. [ ] [Specific refactoring task with more detail]

### Phase 3: Strategic (Plan for Future)
1. [ ] [Larger refactoring initiative]

## Metrics

| Metric | Current | Target | Notes |
|--------|---------|--------|-------|
| Avg function length | 45 lines | <30 lines | [files to focus on] |
| Max class size | 500 lines | <300 lines | [classes to split] |
| Circular deps | 3 chains | 0 | [modules involved] |

## Recommendations

### Do Now
- [Immediate actions with clear ROI]

### Do Soon
- [Important but less urgent]

### Consider
- [Long-term improvements]

### Avoid
- [Refactorings that aren't worth the risk/effort right now]
```

### Step 7: Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Refactoring analysis complete.
📁 Report: agent-os/specs/[spec-path]/implementation/refactoring-analysis.md
📊 Issues: [X] critical | [Y] high | [Z] medium | [W] low
⏱️ Quick wins: [N] items available
```

**Do NOT include** detailed recommendations, code examples, or refactoring roadmaps in the conversation response.

## Important Constraints

- Focus on actionable improvements, not theoretical perfection
- Recommend incremental changes over big rewrites
- Consider the team's capacity and current priorities
- Don't recommend refactoring stable, working code without clear benefit
- Balance idealism with pragmatism
- Always assess risk alongside benefit
- Provide concrete examples, not vague suggestions
- Respect existing architectural decisions unless clearly problematic

## Error Recovery

If you encounter issues during refactoring analysis:

1. **Large Codebase Timeout**: Narrow scope to specific modules, document areas not analyzed
2. **Complex Dependency Graph**: Focus on module-level analysis, note complexity as finding
3. **Unfamiliar Language/Framework**: Note limitations, focus on universal patterns (DRY, coupling)
4. **No Clear Architecture**: Document this as primary finding, recommend architecture definition first
5. **Generated/Vendored Code**: Exclude from analysis, note in report

For implementation-related errors, refer to `{{workflows/implementation/error-recovery}}`
