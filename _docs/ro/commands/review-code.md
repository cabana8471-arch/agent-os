# Comandă: /agent-os:review-code

## 📋 Ce Face

Deep code review pentru security, quality, standards compliance. Detectează vulnerabilități, bugs, design issues.

Output: Detailed `code-review.md` cu issue IDs (SEC-001, BUG-015, QUAL-003, etc.)

---

## ✅ Când să Folosești

- Baseline review pe proiect existent
- Security audit (pre-production)
- Code quality baseline
- After feature implementation (detailed audit)

---

## ❌ Când SĂ NU Folosești

- Code review e inclus în `/agent-os:implement-tasks` (use that instead)
- Hotfix urgent

---

## 📤 Output Generat

- `code-review.md` - All issues with severity (CRITICAL/HIGH/MEDIUM/LOW)
- Issue categorization: SEC, BUG, PERF, QUAL, DOC, TEST, ARCH
- Remediation recommendations

---

## 💡 Exemplu

```markdown
# Code Review Report

## Issues Found: 12

### CRITICAL (1)
- SEC-001: SQL injection in task search (line 245)
  Fix: Use parameterized queries

### HIGH (3)
- BUG-001: Memory leak in task polling (line 512)
- PERF-001: N+1 query in list tasks (line 189)
- ARCH-001: Circular dependency between modules

### MEDIUM (5)
- QUAL-001: Inconsistent error handling
- [...]

### LOW (3)
- DOC-001: Missing function documentation
- [...]

## Summary
- Code quality: C+ (issues found, must fix)
- Security: D (critical vulnerability)
- Standards compliance: B
```

---

## 🔗 Comenzi Legate

**Independent** - can run anytime on existing code

**Best with**: `/agent-os:implement-tasks` (internal review)

---

## 💭 Best Practices

- ✅ Fix CRITICAL + HIGH issues before merge
- ✅ MEDIUM issues: fix in next sprint
- ✅ LOW issues: technical debt backlog
- ❌ Ignore security issues
- ❌ Ship with CRITICAL bugs

---

**Gata? Remediază issues și merge!** 🚀
