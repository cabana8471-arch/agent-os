# Concept: Profiles - Configurații pentru Tipuri de Proiecte

Agent OS suportă **multiple profiles** - pachete complete de configurare pentru diferite tech stacks și project types.

---

## 📋 Ce Sunt Profiles?

Un **profile** este o pachet completă de configurare pentru Agent OS care conține:

- **Standards** (coding style, conventions, security, testing)
- **Workflows** (planning, specification, implementation, review)
- **Agents** (cei 14 AI specialists cu configurări specifice)
- **Commands** (cele 16 comenzi Agent OS)

**Exemplu structură**:
```
~/agent-os/profiles/default/
├── standards/
│   ├── global/      (conventions, error-handling, logging)
│   ├── backend/     (api, models, queries, migrations)
│   ├── frontend/    (components, css, responsive)
│   └── testing/     (test-writing strategies)
├── workflows/       (planning, specification, implementation)
├── agents/          (product-planner, spec-writer, implementer)
└── commands/        (/agent-os:plan-product, /agent-os:write-spec, /agent-os:implement-tasks)
```

---

## 🎯 Profilul Default

Fiecare instalare Agent OS start cu **`default` profile** - foundation pentru toate proiectele.

### Ce Conține Default Profile?

Default profile include:
- **Global Standards** - Naming conventions, error handling, logging, comments
- **Backend Standards** - API design, data models, database queries
- **Frontend Standards** - Component structure, CSS/styling, responsive design, accessibility
- **Testing Standards** - Unit tests, integration tests, test structure
- **All Workflows** - Planning, specification, implementation, review
- **All Agents** - 14 AI specialists configured
- **All Commands** - 16 Agent OS commands

### Best Practice: NU Modifica `default` Direct!

**✅ RECOMMENDED APPROACH**:
1. Keep `default` profile **unchanged**
2. Create custom profile (ex: `general`, `main`, `custom`)
3. Inherit from `default`
4. Override **only what's different**

**Benefits**:
- ✅ Easy to update Agent OS (updates don't break your customizations)
- ✅ Multiple projects can reference same `default`
- ✅ Clear what's customized vs what's standard

---

## 📦 Profile Predefinite

Agent OS vine cu **6 profile predefinite** pentru tech stacks comune:

| Profil | Moștenește din | Scop |
|--------|----------------|------|
| `default` | - | Profil de bază cu setup complet Agent OS |
| `nextjs` | default | Next.js App Router, standarde specifice |
| `react` | default | Frontend-only React library standards |
| `seo-nextjs-drizzle` | nextjs | Next.js + Drizzle ORM + BetterAuth |
| `wordpress` | default | WordPress plugin/theme development |
| `woocommerce` | wordpress | WooCommerce e-commerce development |

**Utilizare**:
```bash
# Next.js project
~/agent-os/scripts/project-install.sh --profile nextjs

# WordPress project
~/agent-os/scripts/project-install.sh --profile wordpress

# WooCommerce project
~/agent-os/scripts/project-install.sh --profile woocommerce
```

---

## ✅ Când să Folosești Multiple Profiles?

Crează profiles adiționale pentru:

### 1. Tech Stacks Diferite

Different backend/frontend frameworks = different conventions.

**Exemplu**:
```
profiles/
├── default/          (base, all projects)
├── django-api/       (Django ORM, Django views, Django tests)
├── rails-api/        (Rails models, Rails controllers, Rails migrations)
├── node-express/     (Node conventions, Express patterns)
├── react-app/        (React components, React hooks, React testing)
```

**When to use**: When your team or projects use different frameworks that have **significantly different conventions**.

---

### 2. Project Types Diferite

Different project types = different standards.

**Exemplu**:
```
profiles/
├── web-app/          (React frontend, full-stack conventions)
├── cli-tool/         (Command-line tool standards)
├── mobile-app/       (React Native, mobile-specific standards)
├── api-backend/      (Backend-only, API focus)
```

---

### 3. Teams Diferite

Different teams = different coding preferences.

**Exemplu**:
```
profiles/
├── backend-team/     (Backend specialists, their preferences)
├── frontend-team/    (Frontend specialists, their preferences)
├── devops-team/      (Deployment, infrastructure focus)
```

---

### 4. Client Projects

Each client = potentially different standards.

**Exemplu**:
```
profiles/
├── client-a-strict/  (Strict security, compliance requirements)
├── client-b-fast/    (Fast iteration, minimal docs)
├── client-c-docs/    (Heavy documentation, detailed specs)
```

---

## 🔄 Profile Inheritance

Instead of duplicating entire profiles, **inherit from parent** and override only what's different.

### Cum Funcționează Inheritance?

1. **Start with parent** (usually `default`)
2. **Inherit all standards, workflows, agents, commands**
3. **Override specific files** with your customizations
4. **Add new files** unique to this profile

### Exemplu: `django-api` Profile

**Step 1**: Create profile config

File: `~/agent-os/profiles/django-api/profile-config.yml`
```yaml
inherits_from: default
```

**Step 2**: Override doar ce e diferit

```
~/agent-os/profiles/django-api/
├── profile-config.yml
└── standards/
    └── backend/
        ├── django-models.md      (override: Django ORM specific)
        ├── django-views.md       (override: Django views specific)
        └── django-migrations.md  (override: Django migrations specific)
```

**Result**: `django-api` inherits EVERYTHING from `default` EXCEPT `backend/` standards (override with Django-specific conventions).

### Multi-Layer Inheritance

Inheritance poate continua prin multiple layers:

```
rails-api → rails → general → default
```

**What this means**:
- `rails-api` inherits from `rails`
- `rails` inherits from `general`
- `general` inherits from `default`
- Each level only defines what's **different** from its parent

**Benefit**: DRY - don't repeat yourself, hierarchy keeps things organized.

---

## ⚙️ Profile Configuration

### profile-config.yml

Fiecare profile are fișier `profile-config.yml`:

```yaml
inherits_from: default

exclude_inherited_files:
  - standards/backend/api.md
```

### Opțiuni Disponibile

**`inherits_from`**:
- `default` - Inherit from default profile
- `general` - Inherit from custom general profile
- `false` - No inheritance (standalone profile)

**`exclude_inherited_files`**:
- List of files to NOT inherit from parent
- Useful: parent has file you don't want
- Example: If parent has `api.md` but you don't use REST APIs

---

## 🛠️ Creating Custom Profiles

### Opțiunea 1: Using Script (RECOMMENDED)

```bash
~/agent-os/scripts/create-profile.sh
```

**Ce face**:
1. Prompts for profile name
2. Prompts for parent profile
3. Creates directory structure
4. Creates `profile-config.yml`
5. Creates placeholder directories

**Exemplu Interactive Session**:
```
? Profile name: django-api
? Parent profile (default): general
✓ Created ~/agent-os/profiles/django-api/
✓ Created profile-config.yml
✓ Created standards/ directories
```

---

### Opțiunea 2: Manual Creation

```bash
# 1. Create profile directory
mkdir -p ~/agent-os/profiles/my-profile

# 2. Create config
cat > ~/agent-os/profiles/my-profile/profile-config.yml <<EOF
inherits_from: default
EOF

# 3. Override specific files
mkdir -p ~/agent-os/profiles/my-profile/standards/backend
cp ~/agent-os/profiles/default/standards/backend/api.md \
   ~/agent-os/profiles/my-profile/standards/backend/api.md

# 4. Edit copy with your customizations
nano ~/agent-os/profiles/my-profile/standards/backend/api.md
```

---

## 🚀 Using Profiles

### Set Default Profile Globally

All project installations use default profile unless override with `--profile` flag.

Edit `~/agent-os/config.yml`:

```yaml
default_profile: general
```

**Result**: `project-install.sh` uses `general` profile by default.

---

### Install cu Specific Profile

Override default for specific project:

```bash
~/agent-os/scripts/project-install.sh --profile django-api
```

**Use cases**:
```bash
# Django project
~/agent-os/scripts/project-install.sh --profile django-api

# Rails project
~/agent-os/scripts/project-install.sh --profile rails-api

# React app
~/agent-os/scripts/project-install.sh --profile react-app

# Node CLI
~/agent-os/scripts/project-install.sh --profile node-cli
```

---

## 🔀 Switching Profiles on Project

If project initially used one profile, but want to switch to different profile:

### Re-run Installer

```bash
cd /path/to/project
~/agent-os/scripts/project-install.sh --profile react-app
```

**What happens**:
1. Script detectează current installation
2. Prezintă options:
   - ✅ Re-install with new profile
   - ✅ Update current profile
   - ✅ Keep current + add new
3. You choose what you want

**Safe**: Script asks before making changes, no data loss.

---

## 💡 Common Profiles Examples

### 1. `general` (Main Custom)

Most developers create this profile:

**File**: `~/agent-os/profiles/general/profile-config.yml`
```yaml
inherits_from: default
```

**What to override**:
- `standards/global/conventions.md` - Your preferred naming (camelCase vs snake_case)
- `standards/global/commenting.md` - Your comment style
- `standards/global/error-handling.md` - Your error handling patterns

**Use**: As default for all your projects

---

### 2. `django-api`

Django-specific backend:

**File**: `~/agent-os/profiles/django-api/profile-config.yml`
```yaml
inherits_from: general  # or default
```

**What to override**:
- `standards/backend/django-models.md` - Django ORM patterns
- `standards/backend/django-views.md` - Django views conventions
- `standards/backend/django-migrations.md` - Migration strategy

---

### 3. `rails-api`

Rails-specific backend:

**File**: `~/agent-os/profiles/rails-api/profile-config.yml`
```yaml
inherits_from: general
```

**What to override**:
- `standards/backend/rails-models.md` - Rails models (ActiveRecord)
- `standards/backend/rails-controllers.md` - Rails controllers
- `standards/backend/rails-migrations.md` - Migration conventions

---

### 4. `react-app`

React frontend:

**File**: `~/agent-os/profiles/react-app/profile-config.yml`
```yaml
inherits_from: general
```

**What to override**:
- `standards/frontend/react-components.md` - Component structure
- `standards/frontend/react-hooks.md` - Hooks conventions
- `standards/frontend/react-state.md` - State management (Redux, Zustand, etc.)

---

### 5. `node-cli`

Node.js CLI tools:

**File**: `~/agent-os/profiles/node-cli/profile-config.yml`
```yaml
inherits_from: general
```

**What to override**:
- `standards/global/cli-conventions.md` - CLI-specific standards
- `standards/testing/cli-testing.md` - CLI testing patterns

---

## ✅ Best Practices

### ✅ DO

- ✅ **Keep `default` unchanged** - Easy to update Agent OS
- ✅ **Create `general` as main custom** - Inherit from default
- ✅ **Inherit instead of duplicate** - DRY principle
- ✅ **Only override what's different** - Minimize customization
- ✅ **Document why overriding** - Comments in overridden files
- ✅ **Test profile before deploying** - Try on test project first
- ✅ **Version control profiles** - Git repo for your profiles

### ❌ DON'T

- ❌ **Don't modify `default` directly** - Updates overwrite changes
- ❌ **Don't create profile for tiny differences** - Use `general` + minor customizations
- ❌ **Don't duplicate entire profiles** - Waste + hard to maintain
- ❌ **Don't forget to set `inherits_from`** - Or you get empty profile
- ❌ **Don't use profiles for temporary changes** - Use `config.yml` flags instead
- ❌ **Don't have too many profiles** - Keep it manageable (3-5 profiles max)

---

## 🔗 Related Concepts

- **[Standards System](./standards.md)** - Standards are the core of profiles
- **[Best Practices](./best-practices.md)** - Profile management practices

---

## 🎓 Practical Workflow Examples

### Scenario 1: First Time Setup

```bash
# 1. Install Agent OS (will use default profile)
git clone https://github.com/.../agent-os ~/agent-os
cd ~/agent-os
./scripts/base-install.sh

# 2. Create your main custom profile
./scripts/create-profile.sh
# Interactive:
# ? Profile name: general
# ? Parent profile: default

# 3. Customize general profile
nano ~/agent-os/profiles/general/standards/global/conventions.md
# Update: our naming convention is camelCase everywhere

# 4. Set as default
nano ~/agent-os/config.yml
# Change: default_profile: general

# 5. Install în new project (uses general automatically)
cd ~/new-project
~/agent-os/scripts/project-install.sh
# Uses general profile (from config.yml)
```

---

### Scenario 2: Django Project Setup

```bash
# 1. Create Django profile (inherits from general)
~/agent-os/scripts/create-profile.sh
# ? Profile name: django-api
# ? Parent profile: general

# 2. Add Django-specific standards
mkdir -p ~/agent-os/profiles/django-api/standards/backend

# Copy Django-specific from default, if exists:
cp ~/agent-os/profiles/default/standards/backend/api.md \
   ~/agent-os/profiles/django-api/standards/backend/django-models.md

# Edit for Django:
nano ~/agent-os/profiles/django-api/standards/backend/django-models.md
# Add Django ORM conventions, field types, validation patterns

# 3. Install în Django project
cd ~/django-project
~/agent-os/scripts/project-install.sh --profile django-api
```

---

### Scenario 3: Multiple Projects, Multiple Profiles

```bash
# Project A: Django API Backend
cd ~/projects/api-backend
~/agent-os/scripts/project-install.sh --profile django-api

# Project B: React App Frontend
cd ~/projects/web-frontend
~/agent-os/scripts/project-install.sh --profile react-app

# Project C: Node CLI Tool
cd ~/projects/cli-tool
~/agent-os/scripts/project-install.sh --profile node-cli

# Project D: General Project (uses default from config)
cd ~/projects/misc-project
~/agent-os/scripts/project-install.sh
# Uses 'general' profile (from config.yml default_profile setting)
```

Each project uses appropriate profile, all inherit from `general` → `default`. **Maintainability**: Update `general` once, all projects benefit.

---

### Scenario 4: Multi-Layer Inheritance - WordPress + WooCommerce

**Context**: Ai multiple proiecte WordPress cu WooCommerce pentru clienți diferiți.

**Challenge**: Vrei să păstrezi:
- Standards comune pentru toate proiectele tale (general)
- Standards WordPress pentru toate proiectele WP
- Standards WooCommerce specifice ecommerce
- Customizări per client individual

**Soluție**: 4-level inheritance chain

#### Chain Structure

```
default (Agent OS base)
  ↓ inherits
general (YOUR team conventions)
  ↓ inherits
wordpress (WordPress-specific standards)
  ↓ inherits
woocommerce (WooCommerce ecommerce standards)
  ↓ inherits
client-x-woo (Client X customizations)
```

**Ce moștenește fiecare**:
- `general` → moștenește tot din `default`, override team conventions
- `wordpress` → moștenește `general` + `default`, adaugă WordPress hooks/templates
- `woocommerce` → moștenește tot ce e deasupra, adaugă WooCommerce products/checkout
- `client-x-woo` → moștenește tot, adaugă doar customizări client specific

---

#### Step 1: Create Base WordPress Profile

```bash
# 1. Create wordpress profile
~/agent-os/scripts/create-profile.sh

# Interactive prompts:
# ? Profile name: wordpress
# ? Parent profile (default): general

# 2. Add WordPress-specific standards
mkdir -p ~/agent-os/profiles/wordpress/standards/backend
mkdir -p ~/agent-os/profiles/wordpress/standards/global

# 3. Override conventions pentru WordPress coding standards
cat > ~/agent-os/profiles/wordpress/standards/global/conventions.md <<EOF
# WordPress Coding Conventions

## Naming
- Functions: lowercase with underscores (WordPress style)
- Classes: PascalCase with prefix
- Constants: UPPERCASE with underscores

## File Organization
- Follow WordPress template hierarchy
- Use proper hook priorities

## Security
- Always sanitize input (sanitize_text_field, esc_html, etc.)
- Use nonces for forms
- Prepare SQL with $wpdb->prepare()
EOF

# 4. Create WordPress hooks standard
cat > ~/agent-os/profiles/wordpress/standards/backend/wordpress-hooks.md <<EOF
# WordPress Hooks & Actions

## Actions
- Use add_action() with proper priority
- Hook naming: prefix_action_name

## Filters
- Use add_filter() for data modification
- Always return filtered value

## Template Tags
- Create custom template tags in functions.php
EOF
```

**Ce am override**:
- `global/conventions.md` - WordPress coding standards (underscores, naming)
- `backend/wordpress-hooks.md` - Actions, filters, template tags (WordPress specific)

---

#### Step 2: Create WooCommerce Profile

```bash
# 1. Create woocommerce profile (inherits wordpress)
~/agent-os/scripts/create-profile.sh

# Interactive:
# ? Profile name: woocommerce
# ? Parent profile (default): wordpress

# 2. Add WooCommerce-specific standards
mkdir -p ~/agent-os/profiles/woocommerce/standards/backend

# 3. WooCommerce product standards
cat > ~/agent-os/profiles/woocommerce/standards/backend/woocommerce-products.md <<EOF
# WooCommerce Product Types

## Product Types
- Simple products
- Variable products (with variations)
- Grouped products
- External/Affiliate products

## Custom Product Types
- Register with wc_register_product_type()
- Extend WC_Product class

## Product Meta
- Use update_post_meta() for custom fields
- Register meta boxes properly
EOF

# 4. WooCommerce checkout standards
cat > ~/agent-os/profiles/woocommerce/standards/backend/woocommerce-checkout.md <<EOF
# WooCommerce Checkout & Cart

## Custom Checkout Fields
- Use woocommerce_checkout_fields filter
- Validate with woocommerce_checkout_process

## Cart Modifications
- woocommerce_before_calculate_totals for price changes
- woocommerce_add_to_cart_validation for validation
EOF
```

**Ce am override**:
- `backend/woocommerce-products.md` - Product types, custom products
- `backend/woocommerce-checkout.md` - Checkout flows, cart customization

---

#### Step 3: Create Client-Specific Profile

```bash
# 1. Create client profile (inherits woocommerce)
~/agent-os/scripts/create-profile.sh

# Interactive:
# ? Profile name: client-x-woo
# ? Parent profile (default): woocommerce

# 2. Add client-specific requirements ONLY
mkdir -p ~/agent-os/profiles/client-x-woo/standards/backend

# 3. Client X specific customizations
cat > ~/agent-os/profiles/client-x-woo/standards/backend/client-x-custom.md <<EOF
# Client X Custom Requirements

## Custom Payment Gateway
- Integrate Client X's payment provider
- Custom payment validation

## Custom Shipping
- Client X warehouse locations
- Custom shipping calculation logic

## Branding
- Client X color scheme
- Custom email templates
EOF
```

**Ce am override**:
- `backend/client-x-custom.md` - DOAR customizări specifice acestui client

---

#### Step 4: Install în Project

```bash
# Navigate to client's project
cd ~/projects/client-x-woocommerce-store

# Install Agent OS with client profile
~/agent-os/scripts/project-install.sh --profile client-x-woo
```

**Ce se întâmplă**:
1. Agent OS citește `client-x-woo` profile config
2. Vede că moștenește din `woocommerce`
3. Vede că `woocommerce` moștenește din `wordpress`
4. Vede că `wordpress` moștenește din `general`
5. Vede că `general` moștenește din `default`
6. **Combină toate standardele** în ordine:
   - default (base)
   - general (team conventions)
   - wordpress (WP standards)
   - woocommerce (WC standards)
   - client-x-woo (client specific)
7. Instaleaza în `agent-os/` folder

---

#### File Structure Per Level

```
~/agent-os/profiles/

default/                              # Agent OS base (NU modifica)
  ├─ standards/global/conventions.md (base conventions)
  ├─ standards/backend/api.md
  └─ ... (all base standards)

general/                              # YOUR team
  ├─ profile-config.yml
  │   inherits_from: default
  └─ standards/global/conventions.md (YOUR camelCase preference, etc.)

wordpress/                            # WordPress projects
  ├─ profile-config.yml
  │   inherits_from: general
  ├─ standards/global/conventions.md (WordPress underscores style)
  └─ standards/backend/wordpress-hooks.md (WP actions/filters)

woocommerce/                          # WooCommerce projects
  ├─ profile-config.yml
  │   inherits_from: wordpress
  ├─ standards/backend/woocommerce-products.md (WC product types)
  └─ standards/backend/woocommerce-checkout.md (WC checkout)

client-x-woo/                         # Client X specific
  ├─ profile-config.yml
  │   inherits_from: woocommerce
  └─ standards/backend/client-x-custom.md (payment, shipping, branding)
```

---

#### Benefits Explicat

**Maintainability**:

```
Update general/ conventions
  → Affects: wordpress, woocommerce, client-x-woo, ALL projects

Update wordpress/ standards
  → Affects: woocommerce, client-x-woo, ALL WP projects

Update woocommerce/ standards
  → Affects: client-x-woo, ALL WooCommerce projects

Update client-x-woo/ standards
  → Affects: DOAR proiectul Client X
```

**Exemplu concret**:
Găsești un security bug în `wordpress/standards/global/conventions.md` (sanitization pattern greșit).

✅ **Fix odată** în `wordpress/` profile
✅ **Propagă automat** la toate proiectele WooCommerce (moștenesc wordpress)
✅ **Re-run** `project-install.sh` în fiecare proiect pentru update

❌ **Fără profiles**: Trebuie să corectezi manual în fiecare proiect (5 proiecte = 5 fix-uri)

---

#### Practical Use Case

**Scenario real**: Agency cu 3 clienți WooCommerce

```bash
# Client A: Fashion store
~/projects/client-a-fashion/
  → Uses profile: client-a-woo (inherits woocommerce → wordpress → general → default)

# Client B: Electronics store
~/projects/client-b-electronics/
  → Uses profile: client-b-woo (inherits woocommerce → wordpress → general → default)

# Client C: Food delivery
~/projects/client-c-food/
  → Uses profile: client-c-woo (inherits woocommerce → wordpress → general → default)
```

**Benefits**:
- **Shared base**: Toți 3 clienți share WordPress + WooCommerce best practices
- **Client-specific**: Fiecare client are customizări proprii (payment, shipping, branding)
- **Easy updates**: Update WooCommerce standards → apply to all 3 clients
- **Consistency**: Coding style consistent across all projects

**Maintainability**: 1 developer poate gestiona 3+ clienți cu ease, standards centralizate

---

## 🔧 Troubleshooting

### Problema: "Profile not found"

**Cauză**: Profile name typo or doesn't exist

**Soluție**:
```bash
# List available profiles
ls ~/agent-os/profiles/

# Check what profiles you have
ls ~/agent-os/profiles/
# Output:
# default/
# general/
# django-api/
# rails-api/

# Verify profile exists before using
ls ~/agent-os/profiles/django-api/profile-config.yml
```

---

### Problema: "Inheritance not working"

**Cauză**: `inherits_from` not set correctly in `profile-config.yml`

**Soluție**:
```bash
# Check profile config
cat ~/agent-os/profiles/my-profile/profile-config.yml

# Should have:
# inherits_from: default
# (or another profile name)

# If missing, add it:
echo "inherits_from: default" > ~/agent-os/profiles/my-profile/profile-config.yml
```

---

### Problema: "Profile changes not reflecting in project"

**Cauză**: Need to re-run project install to apply new profile

**Soluție**:
```bash
cd /path/to/project

# Re-run with same profile to update
~/agent-os/scripts/project-install.sh --profile my-profile

# Script will detect update and ask:
# ? Re-install with profile? (y/n)
# Choose "y" to apply new profile changes
```

---

## 📊 Profile Decision Matrix

| Scenario | Action |
|----------|--------|
| **First setup** | Create `general` profile, inherit from `default` |
| **Multiple tech stacks** | Create tech-specific profiles (django-api, rails-api, etc.) |
| **Multiple teams** | Create team-specific profiles |
| **Client projects** | Create client-specific profiles |
| **Temporary customization** | Use `config.yml` flags, not profiles |
| **Standards change** | Update profile, re-run `project-install.sh` |

---

## 🚀 Why Profiles Matter

### Without Profiles

❌ Copy-paste standards between projects
❌ Inconsistent conventions across projects
❌ Hard to update standards globally
❌ No clear way to switch tech stacks

### With Profiles

✅ **One source of truth** - Standard per profile
✅ **Reusable** - Use same profile across projects
✅ **Flexible** - Easy to switch profiles
✅ **Maintainable** - Update once, affects all projects using that profile
✅ **Scalable** - Easy to add new profiles as you grow

---

**Profiles = flexibility pentru multiple tech stacks și teams!** 🚀

Start with `general` profile inheriting from `default`, create specialized profiles as needed.
