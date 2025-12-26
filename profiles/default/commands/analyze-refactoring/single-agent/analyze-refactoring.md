# Refactoring Analysis Process

You are performing a code quality analysis to identify technical debt, code smells, and refactoring opportunities. This helps prioritize improvements and maintain code health.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Define analysis scope

Determine what code to analyze:

**If working within a spec context:**
Focus on files created/modified for `agent-os/specs/[spec-path]/`.

**If no spec context:**
Ask the user by outputting the following request and WAIT for their response:

```
What would you like me to analyze for refactoring opportunities?

Options:
1. Full codebase analysis (may take longer)
2. Specific directory or module (e.g., `src/services/`)
3. Specific spec implementation (provide spec folder path)
4. Files changed in recent commits

Please specify your preference.
```

### PHASE 2: Execute refactoring analysis

Perform the comprehensive code quality analysis:

{{workflows/maintenance/refactoring-analysis}}

{{UNLESS standards_as_claude_code_skills}}
## User Standards & Preferences Compliance

IMPORTANT: Evaluate code against the user's preferred conventions and patterns as detailed in:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 3: Present findings and recommendations

{{UNLESS compiled_single_command}}
After completing the analysis, output the following summary to the user:

```
Refactoring analysis complete!

Issues Found by Severity:
- Critical: [X] (actively causing problems)
- High: [X] (slowing development)
- Medium: [X] (maintainability concerns)
- Low: [X] (nice to have)

Top 3 Recommendations:
1. [Most impactful quick win]
2. [Second recommendation]
3. [Third recommendation]

Quick Wins Available: [X] items ([estimated hours] total)

Key Areas of Concern:
- [Area 1]: [Brief description]
- [Area 2]: [Brief description]

Full report: `agent-os/reports/refactoring-analysis-[date].md`

NEXT STEP:
- Review the full report for detailed recommendations
- Prioritize quick wins for immediate improvement
- Plan larger refactorings for upcoming sprints
- Consider addressing critical issues before new features
```
{{ENDUNLESS compiled_single_command}}

## Error Recovery

If any phase fails:

1. **Large Codebase**: Focus on high-traffic areas first, note what wasn't analyzed
2. **Permission Issues**: Flag files that couldn't be accessed
3. **Unknown Patterns**: Document unfamiliar code patterns for manual review
4. **Complex Dependencies**: Note circular dependencies or tight coupling for deeper analysis
