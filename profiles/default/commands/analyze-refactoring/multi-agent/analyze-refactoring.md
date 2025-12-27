# Refactoring Analysis Process

You are performing a code quality analysis to identify technical debt, code smells, and refactoring opportunities. This helps prioritize improvements and maintain code health.

This process will follow 3 main phases:

PHASE 1. Define analysis scope
PHASE 2. Delegate analysis to the refactoring-advisor subagent
PHASE 3. Present findings and recommendations

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Define analysis scope

Determine what code to analyze:

**If working within a spec context:**
Use files created/modified for the current spec.

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

### PHASE 2: Delegate to refactoring-advisor subagent

Use the **refactoring-advisor** subagent to perform the comprehensive analysis.

Provide the refactoring-advisor with:
- The scope of analysis (directory, files, or full codebase)
- Any specific concerns the user mentioned
- The tech stack: `agent-os/product/tech-stack.md` (if exists)

Instruct the subagent to:
1. Analyze code for common anti-patterns and code smells
2. Assess technical debt by impact and effort
3. Map component dependencies and coupling
4. Generate specific refactoring recommendations
5. Create the analysis report at `agent-os/reports/refactoring-analysis-[date].md`
6. Return a summary of findings with prioritized recommendations

{{UNLESS standards_as_claude_code_skills}}
## Standards for Subagent

IMPORTANT: When delegating to the refactoring-advisor subagent, ensure you pass the following standards context so the analysis aligns with the user's preferred tech stack and conventions:

{{standards/*}}
{{ENDUNLESS standards_as_claude_code_skills}}

### PHASE 3: Present findings and recommendations

After the refactoring-advisor completes, inform the user:

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

## Error Recovery

If any phase fails:

1. **Subagent Failure**: Report the error to user and offer to retry or proceed manually
2. **Large Codebase**: Subagent will focus on high-traffic areas first
3. **Complex Dependencies**: Subagent will flag areas needing deeper manual analysis
