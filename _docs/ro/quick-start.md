# Quick Start - Agent OS în 5-10 minute

Bine venit! Iată cum să ajungi operațional cu Agent OS în 5-10 minute.

## Instalare Inițială - Pasul 1 (De facut O SINGURĂ DATĂ)

Agent OS folosește un proces de instalare în **2 pași**. Pasul 1 se face **o singură dată** pe mașina ta.

### Base Installation

```bash
curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/scripts/base-install.sh | bash
```

Aceasta creează `~/agent-os` cu profilurile și scripturile de bază.

**Pentru Windows**: Deschide [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) sau [Git Bash](https://git-scm.com/download/win), apoi rulează comanda de mai sus.

### Customizează Standards (Opțional Dar Recomandat)

Înainte de a instala Agent OS în proiectele tale, personalizează standardurile tale de codare:

1. Editează fișierele din `~/agent-os/profiles/default/standards/`
2. Adaptează-le la convențiile tale, framework-urile preferate și patternurile arhitecturale

**Sfat**: Creează un [profil personalizat](https://buildermethods.com/agent-os/profiles) care moștenește din profilel `default`, în loc să editezi direct profilel implicit.

---

## Alegere Rapid - Pasul 2 (Pentru Fiecare Proiect)

Selectează situația ta:

### 1. Proiect NOU de la zero?

**2 pași simpli:**

```bash
# 1. Clonează / creează proiectul
mkdir my-project && cd my-project
git init

# 2. Instalează Agent OS în proiect
~/agent-os/scripts/project-install.sh
```

Apoi execută:
```bash
/agent-os:plan-product
```

**Apoi urmărește**: [Workflow Proiecte Noi](./workflows/proiecte-noi.md)

**Timp**: ~5 minute pentru setup + 30 minute pentru prima comandă

---

### 2. Proiect EXISTENT cu cod?

**2 pași simpli:**

```bash
# 1. Mergi în proiectul existent
cd /path/to/existing-project

# 2. Instalează Agent OS în proiect
~/agent-os/scripts/project-install.sh --profile [your-tech-stack]
```

Apoi execută:
```bash
/agent-os:audit-deps
/agent-os:analyze-refactoring
/agent-os:review-code
```

**Apoi urmărește**: [Workflow Proiecte Existente](./workflows/proiecte-existente.md)

**Timp**: ~10 minute pentru audit + opțional pentru refactoring

---

## Comenzile Principale - Un Rând Fiecare

| Comandă | Ce Face | Tip | Fișier |
|---------|---------|-----|--------|
| **`/agent-os:plan-product`** | 🎯 Definiți mission, roadmap, tech stack | Planning | [plan-product.md](./commands/plan-product.md) |
| **`/agent-os:write-spec`** | 📋 Scrieți specification detaliat | Specification | [write-spec.md](./commands/write-spec.md) |
| **`/agent-os:create-tasks`** | ✂️ Descompuneți spec în task-uri | Implementation | [create-tasks.md](./commands/create-tasks.md) |
| **`/agent-os:implement-tasks`** | 💻 Implementați + code review automat | Implementation | [implement-tasks.md](./commands/implement-tasks.md) |
| **`/agent-os:orchestrate-tasks`** | 🚀 Paralelizare task-uri complexe | Advanced | [orchestrate-tasks.md](./commands/orchestrate-tasks.md) |

**Vezi restul**: [Toate comenzile](./commands/INDEX.md)

---

## Fluxul Tipic - "Hello World"

**Scenario**: Vrei să construiești o aplicație de task management (TaskFlow).

### Pasul 1: Planificare (5 min)
```
Execută: /agent-os:plan-product
Răspunde la întrebări despre mission/roadmap/tech stack
Output: mission.md, roadmap.md, tech-stack.md
```

### Pasul 2: Specification (10 min)
```
Execută: /agent-os:write-spec
Input: Ce feature vrei? (ex: "User Registration")
Output: specification.md detaliat
```

### Pasul 3: Task-uri (5 min)
```
Execută: /agent-os:create-tasks
Input: specification.md din pasul 2
Output: 8-15 task-uri gata de implementare
```

### Pasul 4: Implementare (30-60 min)
```
Execută: /agent-os:implement-tasks
Input: task-uri din pasul 3
Output: cod implementat + code review + verification
```

### Pasul 5: QA (15 min - opțional)
```
Execută: /agent-os:test-strategy (design plan teste)
Execută: /agent-os:generate-docs (auto-docs)
Output: plan teste + documentație
```

**Total**: ~75-130 minute pentru o feature completă.

---

## Fără Inexpriență? Nu-ți Face Griji!

Agent OS e gândit ca o cale de învățare. Fiecare comandă:

1. **Te întreabă** ce ai nevoie
2. **Te ghidează** pas cu pas
3. **Creează output** gata de folosit
4. **Explică decizii** în rapoarte

Nu trebuie să înțelegi tot de la început. Doar execută comenzile în ordine.

---

## Primii Pași - Ce Să Faci

### Opțiunea A: Proiect Nou (Recomandatat pentru început)
1. ✅ Instalează Agent OS (pasul 1 și 2 mai sus)
2. ✅ Execută `/agent-os:plan-product` (va dura 5-10 min)
3. ✅ Citește output-urile generate
4. ✅ Urmărește [workflow pentru proiecte noi](./workflows/proiecte-noi.md)

### Opțiunea B: Proiect Existent
1. ✅ Instalează Agent OS în proiect (pasul 1 și 2 mai sus)
2. ✅ Execută `/agent-os:audit-deps` (5 min)
3. ✅ Execută `/agent-os:review-code` (10-20 min)
4. ✅ Urmărește [workflow pentru proiecte existente](./workflows/proiecte-existente.md)

---

## Documentație Completă

Dacă vrei să înțelegi mai mult:

- **[Fiecare Comandă](./commands/INDEX.md)** - Referință detaliată pentru 16 comenzi
- **[Workflow-uri](./workflows/INDEX.md)** - Cum să folosești pentru proiecte noi/existente
- **[Concepte](./concepts/INDEX.md)** - Single-Agent vs Multi-Agent, Agenti, etc.
- **[Main Index](./INDEX.md)** - Overview complet

---

## Troubleshooting Rapid

### Comanda nu merge?
1. Verifică că `./scripts/project-install.sh` s-a încheiat fără erori
2. Verifică că `config.yml` e corect
3. Citește [troubleshooting din comanda specifică](./commands/INDEX.md)

### Nu știu care comandă să folosesc?
1. E **proiect nou**? Folosiți `/agent-os:plan-product` → `/agent-os:write-spec` → `/agent-os:create-tasks` → `/agent-os:implement-tasks`
2. E **proiect existent**? Folosiți `/agent-os:audit-deps` → `/agent-os:review-code` → `/agent-os:write-spec` → `/agent-os:implement-tasks`
3. Incert? Citește [Workflow-uri](./workflows/INDEX.md)

### Vreu să refactorizez?
1. Execută `/agent-os:analyze-refactoring`
2. Urmărește recomandări din raport
3. Folosiți `/agent-os:implement-tasks` pe refactoring task-uri

---

## Următorul Pas

Alege una din opțiuni și du-te înainte:

### Sunt pe Proiect Nou
➡️ [Workflow Proiecte Noi](./workflows/proiecte-noi.md) - Ghid pas-cu-pas complet

### Sunt pe Proiect Existent
➡️ [Workflow Proiecte Existente](./workflows/proiecte-existente.md) - Ghid pas-cu-pas complet

### Vreu Referință Comenzi
➡️ [Toate Comenzile](./commands/INDEX.md) - Fiecare comandă explicată detaliat

### Vreu Să Înțeleg Arhitectura
➡️ [Concepte](./concepts/INDEX.md) - Single-Agent, Multi-Agent, Agenti, Standards

---

**Gata? Du-te la comenzile tale și execută!** 🚀
