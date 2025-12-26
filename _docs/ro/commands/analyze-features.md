# Comandă: /agent-os:analyze-features

## 📋 Ce Face

Descoperă features existente într-un codebase, propune noi funcționalități bazate pe pattern-uri, și verifică dacă un feature propus există deja (prevenire duplicate).

**Output**: `feature-analysis.md` + catalog features + propuneri + gap analysis

---

## 🎯 Cele 4 Moduri de Utilizare

Această comandă are **4 moduri distincte** pe care le poți alege la runtime:

### 1. 🔍 Discover Mode

**Când să folosești:**
- Vrei să înțelegi ce features există deja în aplicație
- Onboarding pe un proiect nou
- Documentare codebase existent
- Înainte de planning pentru a evita munca duplicată

**Ce face:**
- Scanează codebase (routes, components, services, models)
- Identifică toate features existente
- Cataloghează în categorii (User Management, Payments, etc.)
- Identifică pattern-uri arhitecturale

**Output:**
```markdown
Features Found: 23 total
- Backend: 12 (APIs, services, models)
- Frontend: 8 (pages, components)
- Full-Stack: 3 (end-to-end features)

Architecture Pattern: MVC with Service Layer
```

---

### 2. 💡 Propose Mode

**Când să folosești:**
- Vrei idei pentru features noi
- Brainstorming înainte de roadmap
- Identificare oportunități de extindere

**Ce face:**
- Analizează features existente și pattern-uri
- Identifică gaps (ce lipsește)
- Propune features noi care se potrivesc cu arhitectura
- Estimează complexitate și dependențe

**Output:**
```markdown
Top 3 Proposed Features:
1. [FEAT-001] User Activity Dashboard - Track user engagement
2. [FEAT-002] Bulk Export - Export data in CSV/PDF
3. [FEAT-003] Notification Preferences - User settings for alerts

Gap Analysis:
- [GAP-001] No analytics/reporting features
- [GAP-002] Missing bulk operations
```

---

### 3. ✅ Check Duplicate Mode

**Când să folosești:**
- Vrei să implementezi un feature nou
- Verifici dacă ideea există deja
- Înainte de a scrie spec pentru un feature

**Ce face:**
- Primește descrierea feature-ului propus
- Caută funcționalitate similară în codebase
- Returnează verdict: NO_CONFLICT, PARTIAL_OVERLAP, EXACT_MATCH

**Input necesar:**
```
Feature propus: "User activity dashboard"
Descriere: Show user login history, actions, and engagement metrics
```

**Output:**
```markdown
Proposed Feature: User Activity Dashboard
Result: PARTIAL_OVERLAP

Issue ID: DUP-001
Existing Feature: User Profile at src/users/
Overlap: Login history already tracked in UserSession model
Recommendation: Extend existing UserProfile component
```

---

### 4. 🔄 Full Analysis Mode

**Când să folosești:**
- Audit complet înainte de planning major
- Quarterly review al codebase
- Înainte de refactoring mare
- Când preiei un proiect existent

**Ce face:**
- Discover (catalogare completă)
- Pattern recognition (arhitectură, convenții)
- Gap analysis (ce lipsește)
- Propose (sugestii îmbunătățiri)
- Toate într-un singur raport

**Output:**
```markdown
Full Feature Analysis Report

Features Discovered: 23 total
Patterns Identified: 5
Proposals Generated: 8
Gaps Found: 4

Summary:
- Architecture: Clean Architecture
- Code Quality: Good (consistent patterns)
- Feature Coverage: 70% (missing analytics, notifications)
```

---

## ✅ Când să Folosești

- **Proiect existent** (feature discovery înainte de development)
- **Onboarding** (înțelegere rapidă a codebase)
- **Planning** (identificare oportunități, evitare duplicate)
- **Before spec writing** (verificare că feature-ul nu există deja)
- **Quarterly review** (audit periodic features)

---

## ❌ Când SĂ NU Folosești

- **Proiect brand new** (nu există features de analizat)
- **Hotfix urgent** (nu e timp pentru analiză)
- **Feature clar definit** (știi exact ce vrei, nu ai nevoie de propuneri)

---

## 📤 Output Generat

| Fișier | Conținut |
|--------|----------|
| `feature-analysis.md` | Raport complet cu toate findings |
| Catalog Features | Tabel structurat pe categorii |
| Gap Analysis | Ce lipsește + recomandări |
| Propuneri | FEAT-XXX cu justificare |
| Duplicate Check | DUP-XXX sau NO_CONFLICT |

**Locații posibile:**
- `agent-os/reports/feature-analysis-[date].md` (analiză generală)
- `agent-os/specs/[spec]/planning/feature-analysis.md` (context spec)

---

## 💡 Exemple Complete

### Exemplu 1: Discover pe Proiect E-Commerce

```
User: /agent-os:analyze-features
Agent: Ce tip de analiză dorești?
User: Discover - full codebase

Output:
Feature discovery complete!

Features Found: 45 total
- Backend: 22 (APIs, services)
- Frontend: 18 (pages, components)
- Full-Stack: 5 (checkout flow, user auth, etc.)

Feature Categories:
- User Management: 8 features (auth, profile, settings)
- Products: 12 features (catalog, search, filters)
- Cart & Checkout: 10 features (cart, payment, shipping)
- Orders: 8 features (order history, tracking)
- Admin: 7 features (dashboard, reports)

Architecture: Next.js App Router + tRPC + Drizzle ORM
Patterns: Feature-based folder structure, Server Components

Full report: agent-os/reports/feature-analysis-2025-01-15.md
```

### Exemplu 2: Check Duplicate pentru "Wishlist"

```
User: /agent-os:analyze-features
Agent: Ce tip de analiză dorești?
User: Check Duplicate

Agent: Descrie feature-ul pe care vrei să-l implementezi:
User: Wishlist - users can save products for later

Output:
Duplicate check complete!

Proposed Feature: Wishlist
Result: PARTIAL_OVERLAP

Issue ID: DUP-002
Existing Feature: Favorites at src/features/favorites/
Overlap:
- FavoriteButton component exists
- favorites table in database
- Add/remove favorites API exists

Difference:
- No wishlist-specific UI (list view, share)
- No price alerts for wishlisted items

Recommendation: EXTEND existing favorites feature
- Rename to "Wishlist" (or keep both)
- Add wishlist page: src/app/wishlist/page.tsx
- Add price alert functionality

NEXT STEPS:
- Review src/features/favorites/
- Decide: extend vs rebuild
- Create spec with /agent-os:write-spec
```

### Exemplu 3: Propose Mode pentru Features Noi

```
User: /agent-os:analyze-features
Agent: Ce tip de analiză dorești?
User: Propose - am nevoie de idei pentru next sprint

Output:
Feature proposals ready!

Based on 45 existing features and 5 patterns identified:

Top 5 Proposed Features:

1. [FEAT-001] Product Reviews & Ratings
   - Pattern: Follows existing comment system pattern
   - Gap: No user feedback on products
   - Effort: Medium (1-2 weeks)
   - Files to create: src/features/reviews/

2. [FEAT-002] Order Notifications (Email/Push)
   - Pattern: Extends existing notification system
   - Gap: Users don't know order status changes
   - Effort: Small (3-5 days)
   - Integrate with: src/features/notifications/

3. [FEAT-003] Product Comparison
   - Pattern: Similar to cart comparison view
   - Gap: Users can't compare products side-by-side
   - Effort: Medium (1-2 weeks)

4. [FEAT-004] Saved Searches
   - Pattern: Follows favorites pattern
   - Gap: Users repeat same searches
   - Effort: Small (2-3 days)

5. [FEAT-005] Gift Cards
   - Pattern: Payment method extension
   - Gap: No gift functionality
   - Effort: Large (2-3 weeks)

Gap Analysis:
- [GAP-001] No social features (reviews, share)
- [GAP-002] No personalization (recommendations)
- [GAP-003] No loyalty program

Full report: agent-os/reports/feature-analysis-2025-01-15.md

NEXT STEPS:
- Prioritize with stakeholders
- Create specs with /agent-os:write-spec
```

---

## 🔗 Comenzi Legate

| Comandă | Relație |
|---------|---------|
| `/agent-os:write-spec` | După analyze-features, scrie spec pentru feature aprobat |
| `/agent-os:analyze-refactoring` | Complementar - analizează technical debt |
| `/agent-os:review-code` | Complementar - code quality review |
| `/agent-os:plan-product` | Înainte - definește roadmap, apoi analyze-features |

### Workflow Recomandat (Proiect Existent)

```
1. /agent-os:analyze-features (Full Analysis) ← START
      ↓
2. Review propuneri cu stakeholders
      ↓
3. /agent-os:write-spec (pentru feature aprobat)
      ↓
4. /agent-os:create-tasks
      ↓
5. /agent-os:implement-tasks
```

---

## 💭 Best Practices

### ✅ DO

- Rulează **Discover** la onboarding pe proiect nou
- Folosește **Check Duplicate** înainte de orice feature nou
- Rulează **Full Analysis** quarterly pentru audit
- Include output în documentația proiectului
- Validează propunerile cu stakeholders

### ❌ DON'T

- Nu ignora PARTIAL_OVERLAP - extinde în loc să duplici
- Nu implementa fără check duplicate mai întâi
- Nu te baza 100% pe propuneri - sunt sugestii, nu requirements
- Nu rula pe proiecte foarte mici (<5 features) - overhead prea mare

---

## ⚙️ Opțiuni Avansate

### Scope Specific

```
# Doar un director
/agent-os:analyze-features --scope src/features/payments/

# Doar backend
/agent-os:analyze-features --scope src/api/
```

### Focus Area

```
# Focus pe security features
/agent-os:analyze-features --focus security

# Focus pe user-facing features
/agent-os:analyze-features --focus user-facing
```

---

## 🔧 Troubleshooting

### "Prea multe features găsite"

**Soluție**: Folosește scope specific sau focus area

### "Nu găsește features"

**Soluție**: Verifică structura codebase, poate nu urmează pattern-uri standard

### "Propuneri irelevante"

**Soluție**: Oferă mai mult context despre domeniul aplicației

---

## 📚 Resurse Tehnice

| Resursă | Path |
|---------|------|
| Agent | `profiles/default/agents/feature-analyst.md` |
| Workflow | `profiles/default/workflows/analysis/feature-analysis.md` |
| Protocol Issue Tracking | `profiles/default/protocols/issue-tracking.md` |
| Output Protocol | `profiles/default/protocols/output-protocol.md` |

---

**Gata? Alege un mod și descoperă features!** 🚀
