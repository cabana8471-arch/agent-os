# Comandă: /agent-os:plan-product

## 📋 Ce Face

Comanda `/agent-os:plan-product` creează **fundația strategică a unui proiect** prin definirea mission-ului, roadmap-ului și tech stack-ului. Aceasta este **comanda de pornire** pentru orice proiect nou.

După execuție, vor exista 3 documente:
- `mission.md` - Cine ești, ce faci, de ce contează
- `roadmap.md` - Phasing feature-uri, milestones, timeline
- `tech-stack.md` - Decizia tehnică (framework, limbaj, baze date, etc.)

---

## ✅ Când să Folosești

- **Proiect complet NOU**: Construiești o aplicație de la zero
- **Strategie nouă**: Pivot sau reorientare a unui proiect existent
- **Team onboarding**: Pentru a califica toți membrii pe vision
- **Documentare reverse-engineering**: Pe proiect existent, pentru a documenta starea curentă

### Exemple Concrete

1. **TaskFlow App (Proiect Nou)**
   - Scop: Build task management app
   - Input: Idee + preferințe tech
   - Output: mission.md + roadmap (6 feature-uri + 3 faze) + tech-stack

2. **Reorientare Existentă**
   - Scop: Schimbă tech stack (Vue → React)
   - Input: Proiect existent + plan nou
   - Output: mission actualizată + roadmap migrationfor timeline

---

## ❌ Când SĂ NU Folosești

- ❌ Doar pentru a scrie o feature mică (folosiți `/agent-os:write-spec` direct)
- ❌ Dacă ai deja mission/roadmap/tech-stack documentat bine
- ❌ Pentru task-uri ad-hoc fără strategie (foloseștinoasă `vou implement asta")

---

## 🔀 Variante Disponibile

### Single-Agent Mode

**Când**: Pentru proiecte mici-medii (<10 feature-uri) sau personal project

**Avantaje**:
- ✅ Mai simplu, mai puțini parametri
- ✅ Un singur agent (product-planner) ștergător rapid
- ✅ Ideal pentru MVP

**Dezavantaje**:
- ❌ Mai lent pentru proiecte mari/complexe
- ❌ Menos perspectivă (doar 1 agent vs multi-perspective)

**Timp**: 20-40 minuter

---

### Multi-Agent Mode

**Când**: Pentru proiecte mari (10+ feature-uri), team project, sau când vrei multiple perspectives

**Avantaje**:
- ✅ Perspective multiple: product, tech, execution
- ✅ Mai rapid (parallelization)
- ✅ Mai robust (sanity checks între agenti)

**Dezavantaje**:
- ❌ Mai complex, mai mulți parametri
- ❌ Timp similiar datorită paralelizării

**Timp**: 20-40 minute (paralel, nu mai lung)

---

## 📥 Input Necesar

### Pre-condiții Checklist

- [ ] Agent OS instalat în proiect (`./scripts/project-install.sh` executat)
- [ ] `config.yml` configurat
- [ ] Decizii inițiale luate (limbaj, framework, DB)
- [ ] Accesul la Claude Code / Claude Web Interface

### Informații Cerute (Agentul va întreba)

**Pasul 1: Concept**
- Ce problemă rezolvi?
- Cine sunt utilizatorii?
- De ce e diferit de competitori?

**Pasul 2: Roadmap**
- Core features (care 3-5 sunt MVP)?
- Nice-to-have features?
- Timeline aspirate?
- Dependențe/risk-uri?

**Pasul 3: Tech Stack**
- Limbaj principal?
- Frontend framework?
- Backend framework?
- Bază de date?
- Deployment platform?

---

## 📤 Output Generat

### Fișiere Create

- **`agent-os/product/mission.md`** (~500 cuvinte)
  - Problema + Soluție
  - Target audience + Use cases
  - Success metrics

- **`agent-os/product/roadmap.md`** (~800 cuvinte)
  - MVP Phase (week 1-4)
  - Growth Phase (month 1-3)
  - Scale Phase (quarter 2+)
  - Milestones și dependencies
  - Risk mitigation

- **`agent-os/product/tech-stack.md`** (~600 cuvinte)
  - Architecture overview (diagram text)
  - Technology choices cu justificare
  - Development workflow
  - Deployment strategy
  - Scalability notes

### Informații Returnate în Conversație

- ✅ Summary of mission (1 paragraf)
- ✅ Overview of roadmap phases (3-4 feature-uri pe fază)
- ✅ Tech stack selected (limbaj, frameworks, DB)
- ✅ Next steps recommendation

---

## 💡 Exemplu Complet

### Context: TaskFlow App (Noul Proiect)

**Scenariu**: Vrei să construiești o aplicație de task management cu colaborare în echipă.

### Execuție Pas-cu-Pas

**Pasul 1: Lansare Comanda**

```bash
cd /path/to/project
/agent-os:plan-product
```

**Pasul 2: Răspunzi Întrebări (Agentul Întreabă)**

> **Agent**: Ce problemă vrei să rezolvi?
> **Tu**: Task management care nu sucks - integrat cu Slack, simple UI, real-time collab

> **Agent**: Cine sunt utilizatorii?
> **Tu**: Small teams (2-10 persoane), software developers, mostly remote

> **Agent**: Care sunt core features MVP?
> **Tu**:
> - Task creation + assignment + due dates
> - Comments/updates
> - Slack notifications
> - Dashboard overview

> **Agent**: Tech preferences?
> **Tu**:
> - Frontend: React + TypeScript
> - Backend: Node.js/Express
> - Database: PostgreSQL
> - Hosting: Vercel + Railway

---

### Pasul 3: Agent Creează Documente

Agentul lucreaza și creează 3 fișiere:

#### `mission.md` (generiert)

```markdown
# TaskFlow - Mission

## The Problem
Task management tools sunt fie prea complexe fie prea simple.
Teams pierd context, notificări nu merg, UI e clunky.

## The Solution
TaskFlow: Simple, beautiful task management cu Slack integration.
- Minimal UI (learn in 5 min)
- Real-time collaboration
- Slack notifications (no app switching)

## Target Users
Remote software teams (2-10 people)

## Success Metrics
- < 2 min onboarding
- > 80% task update via Slack
- 4.5+ star rating
```

#### `roadmap.md` (generat)

```markdown
# TaskFlow - Product Roadmap

## MVP (Week 1-4)
- Task CRUD (create, update, assign, delete)
- Assignment + due dates
- Comments/activity log
- Dashboard overview
- Slack post (notify on task updates)

## Growth (Month 1-3)
- Recurring tasks
- Priority/custom fields
- Task templates
- Slack slash commands
- Mobile app (React Native)

## Scale (Q2+)
- Calendar integrations (Google, Outlook)
- AI-powered task suggestions
- Analytics + reporting
- Team capacity planning
- Enterprise SSO
```

#### `tech-stack.md` (generat)

```markdown
# TaskFlow - Tech Stack

## Frontend
- React 18 + TypeScript
- UI Library: shadcn/ui
- State: Zustand
- Data fetching: TanStack Query
- Styling: Tailwind CSS

## Backend
- Runtime: Node.js 20
- Framework: Express.js
- Database: PostgreSQL 15
- ORM: Prisma
- Auth: JWT + NextAuth

## Deployment
- Frontend: Vercel
- Backend: Railway
- Database: Railway Postgres
- Storage: AWS S3

## Tools
- Version Control: Git + GitHub
- CI/CD: GitHub Actions
- Monitoring: Sentry
- Logging: Pino
- Testing: Vitest (frontend), Jest (backend)
```

### Pasul 4: Review Output

Agentul revine cu:

```
✅ Planning complete
📁 Reports:
   - agent-os/product/mission.md
   - agent-os/product/roadmap.md
   - agent-os/product/tech-stack.md
🎯 Mission: Simple, collaborative task management for remote teams
🛣️ Roadmap: 4-week MVP → 3-month growth → scale
⚙️ Tech: React/TypeScript + Node/Express + PostgreSQL
➡️ Next: /agent-os:write-spec for first feature (Task CRUD)
```

### Pasul 5: Continuă la Următoarea Comandă

Acum ești gata pentru:

```bash
# Opțional (doar dacă cerințe neclare):
/agent-os:shape-spec

# Mandatory:
/agent-os:write-spec --feature "Task CRUD API"
```

---

## ⚙️ Opțiuni Avansate

### Configurare în config.yml

```yaml
product:
  name: TaskFlow
  version: 0.0.1
  description: Task management with Slack integration

roadmap:
  phases: 3  # MVP, Growth, Scale
  include_risks: true

tech_stack:
  frontend_framework: react
  backend_framework: express
  database: postgresql
  include_ai: false  # AI features in roadmap?
```

### Flags Disponibile

```bash
/agent-os:plan-product --include-competitors   # Includ competitive analysis
/agent-os:plan-product --aggressive-roadmap    # 6+ feature-uri pe fază
/agent-os:plan-product --minimal-roadmap       # 2-3 feature-uri pe fază (MVP first)
/agent-os:plan-product --focus-team-size 5     # Optimize for team size
/agent-os:plan-product --include-budget        # Include cost estimates
```

---

## 🔧 Troubleshooting

### Problema: "Agentul nu înțelege businessul meu"

**Cauză**: Descrieri prea vagi sau ambigue

**Soluție**:
1. Fii **specific** - nu "app for productivity", ci "task management for remote dev teams"
2. Descrie **users concreti** - "freelance designers" vs "enterprise IT teams"
3. Incluzi **diferențiatoare** - "unlike Jira because..."
4. Dai **exemple** - "users spend 5 min/day, currently use Slack + spreadsheet"

---

### Problema: "Roadmap e prea ambitious"

**Cauză**: MVP prea mare sau timeline nerealist

**Soluție**:
1. Reduces MVP to 3-4 features (not 10+)
2. Request `/agent-os:plan-product --minimal-roadmap`
3. Move nice-to-haves to Growth phase
4. Extend timeline (8 weeks vs 4 weeks MVP)

---

### Problema: "Tech stack choices nu-mi plac"

**Cauză**: Agentul alege bazat pe best practices, nu pe preferințe personale

**Soluție**:
1. Comunică **restricții explicitamente**:
   - "We must use Java" → mention upfront
   - "Avoid cloud infrastructure" → say so
   - "Team knows only Python" → critical info
2. Re-run cu context: `I prefer Python over Node. I know Django well.`

---

### Problema: "Output-urile sunt prea scurte / prea lungi"

**Cauză**: Agentul alege detaliu level default

**Soluție**:
1. **Prea scurt** → Request `/agent-os:plan-product --include-risks --include-budget`
2. **Prea lung** → Request `/agent-os:plan-product --minimal-roadmap`

---

## 🔗 Comenzi Legate

### Înainte de această comandă

**Nimic** - aceasta e comanda de START pentru orice proiect.

### După această comandă

- **[`/agent-os:shape-spec`](./agent-os:shape-spec.md)** - Dacă cerințe neclare pentru prima feature
- **[`/agent-os:write-spec`](./agent-os:write-spec.md)** - Pentru a scrie specification prima feature
- **[`/agent-os:update-spec`](./agent-os:update-spec.md)** - După planning, dacă schimbi mission

---

## 📚 Resurse Tehnice

- **Workflow folosit**:
  - [`workflows/gather-product-info`](../../profiles/default/workflows/planning/gather-product-info.md)
  - [`workflows/create-product-mission`](../../profiles/default/workflows/planning/create-product-mission.md)
  - [`workflows/create-product-roadmap`](../../profiles/default/workflows/planning/create-product-roadmap.md)
  - [`workflows/create-product-tech-stack`](../../profiles/default/workflows/planning/create-product-tech-stack.md)

- **Agent principal**: [`product-planner`](../../profiles/default/agents/product-planner.md)

- **Standards aplicabile**:
  - `global/tech-stack` - pentru aligning tech decisions
  - `global/conventions` - pentru coding standards în roadmap

---

## 💭 Best Practices

### ✅ Practici Recomandată

- ✅ **Start with WHY** - Răspunde ce problemă rezolvi înainte de tech
- ✅ **MVP First** - Minimum Viable Product, not full product
- ✅ **User Centric** - Definii users/personas konkret, nu generic
- ✅ **Realistic Roadmap** - 4 weeks MVP, nu 2 weeks pentru feature mare
- ✅ **Tech Aligned with Team** - Alege tehnologie care echipa cunoaște/suporta
- ✅ **Review with Team** - Share mission/roadmap, validate cu team înainte de dev
- ✅ **Revisit Quarterly** - Roadmap e document viu, update pe progress

### ❌ Anti-Practici (Evita)

- ❌ **Vague Missions** - "We build software" e prea vag
- ❌ **Unrealistic MVP** - 15+ features in MVP e MVP (e Production Readiness)
- ❌ **Tech for Tech Sake** - Alege trendy framework, nu ala care team-ul suporta
- ❌ **Missing Roadmap** - No milestones = no accountability
- ❌ **Set and Forget** - Roadmap change pe bază de learnings, nu fixed
- ❌ **No Risk Discussion** - Ignoring dependencies/risks = surprises late

---

## 📝 Exemplu Conversație

```
🤖 Agent: What problem are you solving?
👤 You: Slack is chaotic for teams. Todos get lost. Trying to centralize task tracking for dev teams.

🤖 Agent: What's your target user?
👤 You: Small dev teams (5-15 people). Mostly startup engineers. Remote-first.

🤖 Agent: Top 3 features for MVP?
👤 You:
1. Create/assign/update tasks in simple interface
2. Slack notifications (don't leave Slack to check)
3. Recurring tasks (daily standup, sprint cleanup)

🤖 Agent: Frontend/backend preferences?
👤 You: React frontend, Python backend (Flask). We know Python well.

✅ Agent creează mission.md, roadmap.md, tech-stack.md
```

---

**Gata cu `/agent-os:plan-product`? Next step: [`/agent-os:write-spec`](./agent-os:write-spec.md) pentru prima feature!** 🚀
