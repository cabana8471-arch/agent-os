# Comandă: /agent-os:update-spec

## 📋 Ce Face

Actualizează specification după planning/changes. Modify cerințe, add feature-uri, remove deprecated parts.

Output: Updated `specification.md` + changelog

---

## ✅ Când să Folosești

- User feedback post-planning
- Scope change request
- Deprecated features to remove
- Clarifications based on development progress

---

## ❌ Când SĂ NU Folosești

- Spec nu exists yet (use `/agent-os:write-spec`)
- Minor clarifications (update locally)

---

## 📤 Output Generat

- Updated `specification.md`
- `changelog.md` (what changed)

---

## 🔗 Comenzi Legate

**După**: `/agent-os:write-spec`

**Înainte**: `/agent-os:create-tasks` (if major change)

---

**Gata? Continuă cu development!** 🚀
