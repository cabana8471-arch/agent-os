# Comandă: /agent-os:audit-deps

## 📋 Ce Face

Security audit și health check pentru dependențe. Detectează vulnerabilities, outdated packages, license issues.

Output: `dependency-audit.md` + vulnerability report + update recommendations

---

## ✅ Când să Folosești

- Proiect existent (periodic audit)
- Pre-deployment security check
- Onboarding nou dependency manager
- When upgrading major version

---

## ❌ Când SĂ NU Folosești

- Proiect nou fără dependencies
- Hotfix urgent

---

## 📤 Output Generat

- `dependency-audit.md` - All findings with severity
- Vulnerabilities: critical/high/medium/low
- Outdated packages: which ones, latest version
- License compliance: compatible?, GPL?, proprietary?

---

## 💡 Exemplu

```markdown
# Dependency Audit Report

## Vulnerabilities: 7

### CRITICAL (1)
- lodash@4.17.15: Prototype pollution (CVE-2018-3806)
  Fix: Update to 4.17.21+

### HIGH (2)
- express@4.16.0: Multiple issues (CVE-2019-...)
  Fix: Update to 4.18.0+

[...]

## Outdated Packages
- react: 17.0 → 18.0 (major)
- typescript: 4.0 → 5.0 (major)
- jest: 26.0 → 29.0 (major)

## License Compliance
- ✅ All MIT/Apache/BSD compatible
- ⚠️ GPL dependency: check compatibility

## Recommendations
1. Update critical vulnerabilities immediately
2. Plan major version upgrades (React 18, TypeScript 5)
3. Review GPL dependency for project compatibility
```

---

## 🔗 Comenzi Legate

**On**: Proiecte existente (maintenance)

**Before**: Deployment

---

## 💭 Best Practices

- ✅ Audit monthly
- ✅ Fix critical vulnerabilities immediately
- ✅ Plan major upgrades quarterly
- ❌ Ignore critical vulnerabilities
- ❌ Use unknown/sketchy packages

---

**Gata? Update dependencies și deploy!** 🚀
