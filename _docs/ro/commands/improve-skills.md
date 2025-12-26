# Comandă: /agent-os:improve-skills

## Ce Face

Comanda `/agent-os:improve-skills` **îmbunătățește descrierile Claude Code Skills** din proiectul tău pentru a fi mai ușor de descoperit și utilizat de Claude Code în timpul sarcinilor de programare.

Aceasta comandă:
- Analizează fiecare fișier `SKILL.md` din `.claude/skills/`
- Rescrie descrierile pentru discoverability maximă
- Adaugă secțiuni "When to use this skill" cu exemple concrete
- Oferă recomandări pentru îmbunătățiri ulterioare

---

## Când să Folosești

- **După instalarea Agent OS**: Pentru a optimiza skills-urile generate automat
- **Când skills-urile nu se activează**: Claude Code nu folosește skills-urile când ar trebui
- **Periodic (lunar)**: Pentru a menține skills-urile actualizate cu best practices
- **După adăugarea de skills noi**: Pentru a le optimiza pentru discoverability

### Exemple Concrete

1. **Skills neglijate**
   - Simptom: Claude Code nu folosește skill-ul "api-design" când scrii endpoints
   - Soluție: `/agent-os:improve-skills` rescrie descrierea cu exemple clare

2. **Skills noi instalate**
   - Scenariu: Tocmai ai adăugat skills pentru Tailwind CSS
   - Acțiune: Rulează comanda pentru a optimiza descrierile

---

## Când SĂ NU Folosești

- ❌ Dacă nu ai skills în `.claude/skills/` (comanda va raporta acest lucru)
- ❌ Dacă skills-urile funcționează deja bine
- ❌ Pentru a crea skills noi (folosește Claude Code direct pentru asta)

---

## Variante Disponibile

### Single-Agent Mode (Default)

**Proces**: Analizează toate skills-urile secvențial, rescrie fiecare

**Timp**: 5-15 minute (depinde de numărul de skills)

---

## Input Necesar

### Pre-condiții Checklist

- [ ] Agent OS instalat în proiect
- [ ] Folder `.claude/skills/` există
- [ ] Cel puțin un skill în folder
- [ ] Claude Code activ

### Informații Cerute

Comanda va întreba:
- Confirmarea că vrei să îmbunătățești TOATE skills-urile
- Sau specificarea skills-urilor de inclus/exclus

---

## Output Generat

### Modificări per Skill

Fiecare `SKILL.md` va fi rescris cu:

1. **Descriere îmbunătățită** (în frontmatter)
   - Prima propoziție: ce face skill-ul
   - Propoziții următoare: exemple când să fie folosit
   - Tipuri de fișiere relevante

2. **Secțiune nouă**: "When to use this skill"
   - Liste cu cazuri de utilizare
   - Exemple descriptive

### Mesaj Final

```
All Claude Code Skills have been analyzed and revised!

RECOMMENDATION: Review and revise them further using these tips:
- Make Skills as descriptive as possible
- Use their 'description' frontmatter to tell Claude Code when to use
- Include all relevant instructions within the content
- You can link to other files using markdown links
- Consolidate similar skills where it makes sense
```

---

## Exemplu Complet

### Context: Proiect cu 5 Skills

**Skills existente**:
- `api-design/SKILL.md`
- `css-tailwind/SKILL.md`
- `testing-unit/SKILL.md`
- `error-handling/SKILL.md`
- `database-queries/SKILL.md`

### Execuție Pas-cu-Pas

**Pasul 1: Lansare Comandă**

```bash
/agent-os:improve-skills
```

**Pasul 2: Confirmare**

> **Agent**: Before I proceed with improving your Claude Code Skills, can you confirm that you want me to revise and improve ALL Skills in your .claude/skills/ folder?
>
> If not, please specify which Skills I should include or exclude.

> **Tu**: Yes, improve all skills

**Pasul 3: Agent Procesează**

Agentul pentru fiecare skill:
1. Citește conținutul curent
2. Analizează ce face skill-ul
3. Rescrie descrierea cu exemple concrete
4. Adaugă secțiunea "When to use this skill"

### Exemplu Transformare

**Înainte** (`api-design/SKILL.md`):
```yaml
---
description: "API design standards"
---
Follow the API design guidelines...
```

**După** (`api-design/SKILL.md`):
```yaml
---
description: "Design RESTful APIs following best practices for naming, HTTP methods, and response formats. Use when writing or editing API route files (.ts, .js), controller files, endpoint handlers, or any backend code that handles HTTP requests. Apply when creating new endpoints, refactoring existing APIs, or reviewing API-related pull requests."
---

## When to use this skill:

- When creating new API endpoints or routes
- When editing files in `/api/`, `/routes/`, or `/controllers/`
- When working with Express.js, Fastify, or similar frameworks
- When designing request/response schemas
- When implementing REST or GraphQL endpoints
- When reviewing API-related code changes

Follow the API design guidelines...
```

**Pasul 4: Review Final**

```
All Claude Code Skills have been analyzed and revised!

Skills improved: 5
- api-design ✅
- css-tailwind ✅
- testing-unit ✅
- error-handling ✅
- database-queries ✅

RECOMMENDATION: Review and revise them further...
```

---

## Opțiuni Avansate

### Specificare Skills Selectate

```bash
# Doar anumite skills
/agent-os:improve-skills --include "api-design,css-tailwind"

# Exclude anumite skills
/agent-os:improve-skills --exclude "legacy-code"
```

---

## Troubleshooting

### Problema: "Skills folder not found"

**Cauză**: Nu există `.claude/skills/` în proiect

**Soluție**:
1. Creează folderul: `mkdir -p .claude/skills`
2. Adaugă primul skill folosind Claude Code
3. Rulează din nou comanda

---

### Problema: "Empty skills folder"

**Cauză**: Folderul există dar nu conține skills

**Soluție**:
1. Creează skills folosind Claude Code's skill creation feature
2. Sau copiază skills din alt proiect
3. Rulează din nou comanda

---

### Problema: "Skills tot nu se activează"

**Cauză**: Descrierile pot fi încă prea vagi pentru context-ul tău

**Soluție**:
1. Editează manual descrierile după ce comanda termină
2. Adaugă exemple și mai specifice pentru proiectul tău
3. Include file patterns specifice (ex: `*.controller.ts`)

---

## Comenzi Legate

### Înainte de această comandă

- **Instalare Agent OS** - Skills-urile sunt generate la instalare
- **Crearea manuală de skills** - Folosind Claude Code direct

### După această comandă

- **Review manual** - Verifică și ajustează descrierile
- **Test skills** - Verifică dacă Claude Code le folosește corect

---

## Resurse Tehnice

- **Documentație Claude Code Skills**: [https://docs.claude.com/en/docs/claude-code/skills](https://docs.claude.com/en/docs/claude-code/skills)
- **Locație skills**: `.claude/skills/[skill-name]/SKILL.md`

---

## Best Practices

### Practici Recomandate

- Rulează periodic (lunar) pentru menținere
- Review manual după execuție pentru ajustări fine
- Consolidează skills similare unde are sens
- Include file extensions relevante în descrieri

### Anti-Practici (Evită)

- ❌ Nu rula dacă nu ai skills definite
- ❌ Nu ignora mesajele de eroare
- ❌ Nu te baza doar pe această comandă - review manual e important

---

**Gata cu `/agent-os:improve-skills`? Skills-urile tale sunt acum optimizate pentru discoverability!**
