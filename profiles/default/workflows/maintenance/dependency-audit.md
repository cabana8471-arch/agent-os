# Dependency Audit Workflow

## Pre-conditions

Before running this workflow:
- [ ] Project has a package manager configuration (package.json, requirements.txt, Gemfile, etc.)
- [ ] You have read access to dependency files
- [ ] (Optional) Spec path known if auditing for a specific feature

## Workflow

### Step 1: Identify Package Manager and Dependencies

Detect the project's package manager and load dependency files:

```bash
# Detect package manager
if [ -f "package.json" ]; then
    echo "Node.js project detected (npm/yarn/pnpm)"
    cat package.json | head -100
elif [ -f "requirements.txt" ]; then
    echo "Python project detected (pip)"
    cat requirements.txt
elif [ -f "Gemfile" ]; then
    echo "Ruby project detected (bundler)"
    cat Gemfile
elif [ -f "go.mod" ]; then
    echo "Go project detected"
    cat go.mod
elif [ -f "Cargo.toml" ]; then
    echo "Rust project detected"
    cat Cargo.toml
else
    echo "Unknown package manager"
fi
```

### Step 2: Run Security Audit

Run appropriate security audit based on package manager:

**For Node.js:**
```bash
npm audit --json 2>/dev/null || yarn audit --json 2>/dev/null || echo "Audit command failed"
```

**For Python:**
```bash
pip-audit 2>/dev/null || safety check 2>/dev/null || echo "No Python audit tool available"
```

**For Ruby:**
```bash
bundle audit check 2>/dev/null || echo "bundle-audit not installed"
```

### Step 3: Check for Updates

Identify available dependency updates:

**For Node.js:**
```bash
npm outdated --json 2>/dev/null || yarn outdated --json 2>/dev/null
```

**For Python:**
```bash
pip list --outdated --format=json 2>/dev/null
```

**For Ruby:**
```bash
bundle outdated 2>/dev/null
```

### Step 4: Analyze Update Risk

For each outdated dependency, assess:

1. **Semantic Version Change**:
   - Patch (x.x.X): Low risk, bug fixes
   - Minor (x.X.x): Medium risk, new features
   - Major (X.x.x): High risk, breaking changes

2. **Changelog Review**: Check for breaking changes in major updates

3. **Dependency Tree Impact**: Which other packages depend on this?

### Step 5: Check for Unused Dependencies

Identify potentially unused dependencies:

**For Node.js:**
```bash
npx depcheck 2>/dev/null || echo "depcheck not available"
```

### Step 6: License Check

Verify dependency licenses are compatible:

**For Node.js:**
```bash
npx license-checker --summary 2>/dev/null || echo "license-checker not available"
```

### Step 7: Create Audit Report

> **Issue Tracking**: Use issue tracking IDs for vulnerabilities (DEP-XXX for dependency issues, SEC-XXX for security findings).
> See `{{protocols/issue-tracking}}` for ID format and severity guidelines.

> **Quality Gate**: Verify all dependencies checked before finalizing report.
> See `{{protocols/verification-checklist}}` for quality gate guidelines.

Write report to `agent-os/specs/[spec-path]/implementation/dependency-audit.md` (or root if no active spec):

```markdown
# Dependency Audit Report

## Summary
- **Date**: [Current date]
- **Package Manager**: [npm/pip/bundler/etc.]
- **Total Dependencies**: [count]
- **Vulnerabilities Found**: [count by severity]
- **Updates Available**: [count]

## Security Vulnerabilities

### Critical
| Package | Current | Vulnerability | Fix Version |
|---------|---------|---------------|-------------|
| pkg-name | 1.0.0 | CVE-XXXX-XXXX | 1.0.1 |

### High
| Package | Current | Vulnerability | Fix Version |
|---------|---------|---------------|-------------|

### Medium/Low
[List or "None found"]

## Available Updates

### Recommended Updates (Low Risk)
| Package | Current | Latest | Type | Notes |
|---------|---------|--------|------|-------|
| pkg | 1.0.0 | 1.0.1 | patch | Bug fixes |

### Review Required (Medium Risk)
| Package | Current | Latest | Type | Breaking Changes |
|---------|---------|--------|------|------------------|
| pkg | 1.0.0 | 1.1.0 | minor | New API available |

### Major Updates (High Risk)
| Package | Current | Latest | Breaking Changes |
|---------|---------|--------|------------------|
| pkg | 1.0.0 | 2.0.0 | [List changes] |

## Unused Dependencies
[List of potentially unused packages]

- `package-name` - Last used: unknown

## License Summary
| License | Count | Packages |
|---------|-------|----------|
| MIT | 50 | ... |
| Apache-2.0 | 10 | ... |

### License Concerns
[Any GPL or restrictive licenses that may cause issues]

## Recommendations

### Immediate Actions
1. [ ] Update [package] to fix critical vulnerability
2. [ ] Remove unused dependency [package]

### Planned Updates
1. [ ] Schedule major update of [package] - requires testing
2. [ ] Review breaking changes in [package] 2.0

### No Action Required
- [Packages that are up to date and secure]
```

### Step 8: Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Dependency audit complete.
📁 Report: agent-os/specs/[spec-path]/implementation/dependency-audit.md
📊 Security: [X] critical | [Y] high | [Z] med/low | Updates: [W] available
⏱️ Action: [Immediate required / No immediate action]
```

**Do NOT include** vulnerability details, update lists, or license information in the conversation response.

## Important Constraints

- Never automatically update dependencies without user approval
- Document all security vulnerabilities regardless of severity
- Note when audit tools are unavailable
- Consider dependency tree when recommending updates
- Flag breaking changes prominently
- Keep the report actionable with clear next steps

## Error Recovery

If you encounter issues during dependency audit:

1. **Unknown Package Manager**: Document available files, recommend manual audit approach
2. **Audit Tool Not Installed**: Provide installation instructions, proceed with manual version check
3. **Network Errors**: Note CVE database unavailable, recommend retry later
4. **Private Packages**: Skip private registry audit, document as manual check required
5. **Monorepo Structure**: Audit each package separately, aggregate in summary

For implementation-related errors, refer to `{{workflows/implementation/error-recovery}}`
