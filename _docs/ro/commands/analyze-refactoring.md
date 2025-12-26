# Comandă: /agent-os:analyze-refactoring

## 📋 Ce Face

Identifies technical debt, code smells, refactoring opportunities. Prioritizes what to fix.

Output: `refactoring-analysis.md` + priority matrix + effort estimates

---

## ✅ Când să Folosești

- Proiect existent (code health baseline)
- Pre-migration analysis (e.g., JS → TypeScript)
- When codebase feels "slow to develop"
- Regular maintenance (quarterly)

---

## ❌ Când SĂ NU Folosești

- Brand new project (no tech debt yet)
- Hotfix urgent

---

## 📤 Output Generat

- `refactoring-analysis.md` - All opportunities with priority
- Effort estimate (1-3 days, 1-2 weeks, 1-2 months)
- Impact assessment (what improves: speed? quality? both?)
- Roadmap: which to do first

---

## 💡 Exemplu

```markdown
# Refactoring Analysis Report

## High Priority (DO FIRST)
- [1-2 days] Extract common task logic → util function
- [3-5 days] Reduce circular dependencies (auth ↔ models)
- [2 days] Add missing type annotations (TypeScript)

## Medium Priority (next sprint)
- [1 week] Extract database connection pooling
- [3-5 days] Reduce component prop drilling (React)
- [2-3 days] Move hardcoded config → env vars

## Low Priority (later)
- [2 weeks] Migrate to async/await (currently Promises)
- [1 week] Add error boundary components (React)
- [2-3 days] Simplify validation logic

## Impact Matrix
- Most impact + least effort: Extract task logic, type annotations
- Most impact + most effort: Dependency refactor, config management
- Least impact: Async/await migration, error boundaries

## Recommended Order
1. Type annotations (2 days, enables better dev)
2. Common task logic (1-2 days, reduces bugs)
3. Dependency refactor (3-5 days, enables scaling)
4. Rest as capacity allows
```

---

## 🔗 Comenzi Legate

**On**: Proiecte existente

**Result**: Feed into `/agent-os:create-tasks` + `/agent-os:implement-tasks` for refactoring work

---

## 💭 Best Practices

- ✅ Do high priority refactoring early
- ✅ Balance feature dev + refactoring (80/20)
- ✅ Refactor incrementally, don't rewrite
- ❌ Accumulate tech debt indefinitely
- ❌ Big-bang refactors (too risky)

---

**Gata? Create refactoring tasks și fix!** 🚀
