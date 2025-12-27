# Issue Tracking Protocol

This protocol defines how to track, identify, and manage issues discovered during code review, testing, and analysis phases.

## Issue ID Format

All issues MUST have a unique identifier following this format:

```
[CATEGORY]-[NUMBER]
```

### Categories

| Category | Code | Description | Example |
|----------|------|-------------|---------|
| Security | SEC | Security vulnerabilities, auth issues | SEC-001 |
| Bug | BUG | Functional bugs, logic errors | BUG-015 |
| Performance | PERF | Performance issues, bottlenecks | PERF-003 |
| Code Quality | QUAL | Code smells, maintainability | QUAL-022 |
| Documentation | DOC | Missing or incorrect documentation | DOC-007 |
| Test | TEST | Missing tests, test failures | TEST-011 |
| Architecture | ARCH | Architectural issues, design flaws | ARCH-004 |
| Dependency | DEP | Dependency issues, version conflicts | DEP-002 |
| Feature | FEAT | Feature proposals and opportunities | FEAT-001 |
| Duplicate | DUP | Duplicate functionality detected | DUP-003 |
| Gap | GAP | Missing or incomplete features | GAP-007 |

### Number Assignment

- Numbers are assigned sequentially per category
- Numbers start at 001 and increment
- Numbers are unique within their category
- Format: 3-digit zero-padded (001, 002, ... 999)

## Issue Severity Levels

| Level | Label | Description | Response Time |
|-------|-------|-------------|---------------|
| 1 | CRITICAL | Immediate security risk or data loss | Immediate |
| 2 | HIGH | Major functionality broken | Same sprint |
| 3 | MEDIUM | Functionality degraded | Next sprint |
| 4 | LOW | Minor issues, nice to have | Backlog |

### Severity Examples

**CRITICAL (Level 1):**
- SQL injection vulnerability allowing database access
- Authentication bypass exposing user data
- Unencrypted storage of passwords or API keys
- Production data loss or corruption

**HIGH (Level 2):**
- Core feature completely non-functional
- Security issue requiring user action to exploit
- Data integrity issues affecting multiple users
- Performance degradation causing timeouts

**MEDIUM (Level 3):**
- Feature works but with significant limitations
- UI/UX issues affecting user workflow
- Code quality issues increasing maintenance burden
- Missing input validation on non-critical fields

**LOW (Level 4):**
- Minor cosmetic issues
- Code style inconsistencies
- Missing optional documentation
- Performance optimizations for edge cases

## Issue Documentation Format

When documenting an issue, use this format:

```markdown
### [ID]: [Brief Title]

**Severity:** [CRITICAL/HIGH/MEDIUM/LOW]
**Location:** `path/to/file.ts:42-58`
**Type:** [Category description]

**Description:**
[Detailed description of the issue]

**Impact:**
[What could happen if not fixed]

**Recommendation:**
[Specific fix or approach]

**Code Example (if applicable):**
```language
// Before
problematic_code()

// After
fixed_code()
```
```

## Tracker File Structure

Issue trackers are stored in `agent-os/.issue-tracker/`:

```
agent-os/.issue-tracker/
├── SEC-tracker.txt      # Security issues
├── BUG-tracker.txt      # Bug issues
├── PERF-tracker.txt     # Performance issues
├── QUAL-tracker.txt     # Code quality issues
├── DOC-tracker.txt      # Documentation issues
├── TEST-tracker.txt     # Test issues
├── ARCH-tracker.txt     # Architecture issues
├── DEP-tracker.txt      # Dependency issues
├── FEAT-tracker.txt     # Feature proposals
├── DUP-tracker.txt      # Duplicate functionality
└── GAP-tracker.txt      # Missing/incomplete features
```

### Tracker File Format

Each line in a tracker file:
```
[ID]|[STATUS]|[FILE:LINE]|[TITLE]|[TIMESTAMP]
```

Example:
```
SEC-001|OPEN|src/auth/login.ts:42|SQL injection vulnerability|2025-01-15T10:30:00Z
SEC-002|FIXED|src/api/users.ts:128|Missing CSRF token validation|2025-01-15T11:45:00Z
```

### Status Values

- `OPEN` - Issue identified, not yet addressed
- `IN_PROGRESS` - Being actively worked on
- `FIXED` - Fix implemented, pending verification
- `VERIFIED` - Fix verified working
- `WONTFIX` - Intentionally not fixing (document reason)
- `DUPLICATE` - Duplicate of another issue (note original ID)

## Duplicate Prevention

Before creating a new issue:

1. **Search existing trackers** for similar issues
2. **Check file:line** - Same location often means same issue
3. **Compare descriptions** - Similar symptoms may be the same root cause
4. **Link duplicates** - If duplicate found, note the original ID

## Integration with Workflows

### Code Review Integration

When using `{{workflows/review/code-review}}`:
- Assign Issue IDs to all findings
- Update relevant tracker files
- Include Issue IDs in the review report summary

### Verification Integration

When using `{{workflows/implementation/verification/*}}`:
- Reference Issue IDs for any failures
- Track resolution status
- Update tracker on verification pass

## Commands for Issue Management

```bash
# List all open issues
grep "|OPEN|" agent-os/.issue-tracker/*.txt

# List all critical issues
grep "CRITICAL" agent-os/specs/*/implementation/code-review.md

# Count issues by category
wc -l agent-os/.issue-tracker/*.txt

# Find issues in specific file
grep "src/auth/" agent-os/.issue-tracker/*.txt
```

## Best Practices

1. **Be Specific** - Include exact file paths and line numbers
2. **Be Actionable** - Provide clear recommendations
3. **Prioritize Correctly** - Only mark CRITICAL what truly is
4. **Update Promptly** - Keep tracker files current
5. **Link Related Issues** - Note when issues are connected
6. **Document False Positives** - Help improve future analysis
