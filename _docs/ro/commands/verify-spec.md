# Comandă: /agent-os:verify-spec

## 📋 Ce Face

Verifică completitudine și calitate specification **înainte de implementare**. Detectează goluri, ambiguități, missing acceptance criteria.

---

## ✅ Când să Folosești

- După `/agent-os:write-spec`, înainte de `/agent-os:create-tasks`
- Complex features cu multi-part requirements
- Team alignment (validate cu toți stakeholders)

---

## ❌ Când SĂ NU Folosești

- Spec simplu (< 5 acceptance criteria)
- Hotfix urgent

---

## 📤 Output Generat

- `verification-report.md` - Issues, suggestions, gaps found

---

## 💡 Exemplu

**Input**: Spec Task CRUD API

**Output**:
```markdown
# Verification Report

## Quality Score: 8/10

### Missing Items
- ❌ No rate limiting specification
- ❌ No CORS strategy
- ⚠️ Soft delete logic incomplete

### Suggestions
- Add webhook/event system for task changes
- Document data retention policy
- Add load testing requirements

### Ready to Implement
- ✅ Acceptance criteria clear
- ✅ Data model complete
- ✅ Error handling strategy defined
```

---

## 🔗 Comenzi Legate

**Înainte**: [`/agent-os:write-spec`](./agent-os:write-spec.md)

**După**: [`/agent-os:create-tasks`](./agent-os:create-tasks.md) (adjust per findings)

---

## 💭 Best Practices

- ✅ Always verify before dev (catch gaps early)
- ✅ Fix gaps before implementing
- ✅ Update spec per verification findings

---

**Gata? Continuă cu [`/agent-os:create-tasks`](./agent-os:create-tasks.md)!** 🚀
