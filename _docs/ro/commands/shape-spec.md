# Comandă: /agent-os:shape-spec

## 📋 Ce Face

Comanda `/agent-os:shape-spec` **clarifiază și structurează cerințele** înainte de a scrie specification detaliată. Foloseșteți aceasta dacă ideea e vag sau au multe ambiguități.

După execuție, veți avea:
- `requirements-analysis.md` - Feature requirements clarificat
- `questions-answered.md` - Răspunsuri la ambiguități
- `spec-structure.md` - Schelet pentru `/agent-os:write-spec`

---

## ✅ Când să Folosești

- **Feature vagi**: "Improve search" fără detaliu
- **Complex features**: Multi-part features cu dependency-uri
- **Stakeholder alignment**: Pentru a valida understanding cu toți
- **Requirement clarification**: Ceva pe roadmap dar nu clar ce exact

### Exemple

1. **"Improve user search"** → Ce înseamnă improve? Faster? Better results? UI change?
2. **"Payment integration"** → Care payment processor? Refunds? Webhooks?

---

## ❌ Când SĂ NU Folosești

- ❌ Feature e deja clar (direct `/agent-os:write-spec`)
- ❌ Feature e simpla (1-2 endpoints)
- ❌ Spec deja exists (use `/agent-os:update-spec`)

---

## 🔀 Variante Disponibile

### Single-Agent Mode
**Când**: Feature mică, clar-ish

**Avantaje**: Rapid (10-15 min), suficient pentru simple cases

**Dezavantaje**: Overkill pentru feature vagi, reaskat mai mult info

**Timp**: 10-15 minute

---

### Multi-Agent Mode
**Când**: Feature complexă, multi-stakeholder

**Avantaje**: Multiple perspective, mai bun coverage

**Dezavantaje**: Mai complex output

**Timp**: 15-20 minute

---

## 📥 Input Necesar

- [ ] `/agent-os:plan-product` executat
- [ ] Feature e pe roadmap
- [ ] Rough ideea ce vrei (even dacă vag)

---

## 📤 Output Generat

- `requirements-analysis.md` - Clarificări
- `questions-answered.md` - Q&A
- `spec-structure.md` - Skeleton pentru `/agent-os:write-spec`

---

## 💡 Exemplu Complet

**Input**: "Improve search feature"

**Output**:
```markdown
## Requirements Clarification

### What's Broken?
- Current search: keyword matching only, slow on 10k+ tasks
- Users: can't filter by assignee/status together
- Need: faceted search

### AC1: Faceted Search
- Filter by status (todo, in-progress, done)
- Filter by assignee
- Filter by due date range
- Combine filters

### AC2: Search Speed
- Results in < 500ms (was 2s)
- Index on title, description, tags

### Data Model Changes
- Add search index (Elasticsearch or DB indexes)
- Add tags table (many-to-many)
```

---

## 🔗 Comenzi Legate

**După**: [`/agent-os:write-spec`](./agent-os:write-spec.md)

**Înainte**: [`/agent-os:plan-product`](./agent-os:plan-product.md)

---

## 💭 Best Practices

- ✅ Ask clarifying questions early
- ✅ Document ambiguities discovered
- ✅ Align with stakeholders before writing detailed spec
- ❌ Skip this if requirements already clear

---

**Gata? Continuă cu [`/agent-os:write-spec`](./agent-os:write-spec.md)!** 🚀
