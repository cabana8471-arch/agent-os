# Dependency Audit Process

You are performing a security and health audit of the project's dependencies. This identifies vulnerabilities, outdated packages, and license compliance issues.

Follow each of these phases and their individual workflows IN SEQUENCE:

## Multi-Phase Process

### PHASE 1: Confirm audit scope

Ask the user to confirm the audit scope by outputting the following request and WAIT for their response:

```
I'm ready to audit the project's dependencies.

This audit will:
1. Check for security vulnerabilities
2. Identify outdated packages
3. Find potentially unused dependencies
4. Review license compliance

Would you like me to proceed with a full audit of the project root, or focus on a specific directory?

Options:
1. Full project audit (default)
2. Specific directory: [provide path]
```

If the user confirms or doesn't respond with a specific path, proceed with the project root.

### PHASE 2: Execute dependency audit

Perform the comprehensive dependency audit:

{{workflows/maintenance/dependency-audit}}

### PHASE 3: Present findings and recommendations

{{UNLESS compiled_single_command}}
After completing the audit, output the following summary to the user:

```
Dependency audit complete!

Security Status:
- Critical vulnerabilities: [X]
- High vulnerabilities: [X]
- Medium/Low vulnerabilities: [X]

Update Status:
- Patch updates available: [X] (low risk)
- Minor updates available: [X] (medium risk)
- Major updates available: [X] (high risk - breaking changes)

Immediate Action Required: [Yes/No]

[If yes, list critical items:]
Critical items to address:
1. [Package] - [Vulnerability CVE] - Update to [version]
2. [Package] - [Vulnerability CVE] - Update to [version]

Unused Dependencies Found: [X]

License Concerns: [None / List any GPL or restrictive licenses]

Full report: `agent-os/reports/dependency-audit-[date].md`

NEXT STEP:
- Review the full report for detailed recommendations
- Address critical vulnerabilities immediately
- Plan updates for high-priority packages
- Consider removing unused dependencies
```
{{ENDUNLESS compiled_single_command}}

## Error Recovery

If any phase fails:

1. **Missing Package Manager**: Report which package managers were checked and not found
2. **Audit Tool Not Available**: Note which tools are missing, provide manual audit results where possible
3. **Network Issues**: Report connectivity problems, suggest running with cached data
4. **Permission Issues**: Flag files/directories that couldn't be accessed
