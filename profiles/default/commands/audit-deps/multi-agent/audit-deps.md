# Dependency Audit Process

You are performing a security and health audit of the project's dependencies. This identifies vulnerabilities, outdated packages, and license compliance issues.

This process will follow 3 main phases:

PHASE 1. Confirm audit scope
PHASE 2. Delegate audit to the dependency-manager subagent
PHASE 3. Present findings and recommendations

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

### PHASE 2: Delegate to dependency-manager subagent

Use the **dependency-manager** subagent to perform the comprehensive audit.

Provide the dependency-manager with:
- The directory to audit (project root or specified path)
- Any specific concerns the user mentioned

Instruct the subagent to:
1. Detect the package manager and load dependencies
2. Run security vulnerability scans
3. Check for available updates
4. Analyze update risk levels
5. Check for unused dependencies
6. Verify license compliance
7. Create the audit report at `agent-os/reports/dependency-audit-[date].md`
8. Return a summary of findings

### PHASE 3: Present findings and recommendations

After the dependency-manager completes, inform the user:

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

## Error Recovery

If any phase fails:

1. **Subagent Failure**: Report the error to user and offer to retry or proceed manually
2. **Missing Package Manager**: Report which package managers were checked
3. **Audit Tool Not Available**: Subagent will provide manual audit results where possible
