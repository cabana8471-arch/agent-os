# Comandă: /agent-os:test-strategy

## 📋 Ce Face

Designează strategy de teste: unit, integration, E2E. Identifică coverage gaps.

Output: `test-strategy.md` + coverage analysis + test plan

---

## ✅ Când să Folosești

- După feature implementation
- Coverage analysis
- QA planning
- Before production deploy

---

## ❌ Când SĂ NU Folosești

- Feature very simple
- Tests already comprehensive

---

## 📤 Output Generat

- `test-strategy.md` - Test plan (unit/integration/E2E)
- Coverage report (what's tested, what's not)
- Recommendations (prioritize tests)

---

## 💡 Exemplu

**Input**: Task CRUD API implemented

**Output**:
```markdown
# Test Strategy - Task CRUD API

## Current Coverage: 73%

### Test Plan

#### Unit Tests (needed)
- [ ] Task validation (title, due_date, etc.)
- [ ] Permission checks
- [ ] Status transitions

#### Integration Tests (needed)
- [ ] Create task flow
- [ ] Update with concurrent requests
- [ ] Soft delete + hard delete

#### E2E Tests (needed)
- [ ] Full user flow (login → create → update → delete)
- [ ] Pagination + filtering
- [ ] Error scenarios

## Coverage Gaps
- ⚠️ Webhook triggers not tested
- ⚠️ Rate limiting not tested

## Priority
1. Integration tests (foundation)
2. Edge case handling (concurrent updates)
3. E2E tests (user workflows)
```

---

## 🔗 Comenzi Legate

**După**: `/agent-os:implement-tasks`

**Before**: Production deploy

---

**Gata? Write tests și deploy!** 🚀
