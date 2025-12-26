# Feature Analysis Workflow

## Pre-conditions

Before running this workflow:
- [ ] Codebase is accessible and readable
- [ ] (Optional) Product documentation exists for context: `agent-os/product/`
- [ ] (Optional) Specific area to analyze is identified
- [ ] (Optional) Proposed feature description available (for duplicate checking)

## Workflow

### Step 1: Define Analysis Scope

Determine what to analyze:

1. **If analyzing full codebase**: Start with entry points (routes, main files, index files)
2. **If analyzing specific module**: Focus on the specified directory
3. **If checking for duplicates**: Focus on the proposed feature area

**Analysis Modes:**
- **Discover** - Catalog all existing features
- **Propose** - Suggest new features based on patterns
- **Check Duplicate** - Verify a proposed feature doesn't already exist
- **Full Analysis** - All of the above

```bash
# Identify entry points and route definitions
find . -type f \( -name "routes.*" -o -name "router.*" -o -name "index.*" \) -not -path "*/node_modules/*" | head -30

# Find controller/handler/service files
find . -type f \( -name "*controller*" -o -name "*handler*" -o -name "*service*" \) -not -path "*/node_modules/*" | head -50

# Find page/view components (frontend)
find . -type f \( -name "*page*" -o -name "*view*" \) -not -path "*/node_modules/*" | head -30
```

### Step 2: Discover Existing Features

Analyze codebase to identify features:

**Route-Based Discovery (Backend):**
- Scan route definitions for endpoints
- Map routes to handlers/controllers
- Identify CRUD patterns and resource types

```bash
# Find API routes patterns
grep -r "router\.\|app\.\(get\|post\|put\|delete\|patch\)" --include="*.ts" --include="*.js" src/ | head -50

# Find Next.js API routes
find . -path "*/api/*" -name "*.ts" -o -name "*.js" | head -30
```

**Component-Based Discovery (Frontend):**
- Identify page components and views
- Catalog reusable UI components
- Map navigation structure

```bash
# Find React/Vue/Svelte components
find . -type f \( -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" \) -not -path "*/node_modules/*" | head -50
```

**Service-Based Discovery:**
- Identify service classes and modules
- Map business logic boundaries
- Catalog external integrations

**Database Model Discovery:**
- Identify database models/schemas
- Map relationships between entities
- Catalog migrations

```bash
# Find model/schema definitions
find . -type f \( -name "*model*" -o -name "*schema*" -o -name "*entity*" \) -not -path "*/node_modules/*" | head -30
```

### Step 3: Catalog Features

Create a structured catalog of discovered features:

**Feature Catalog Format:**

| Feature Name | Type | Location | Description | Status | Related Features |
|--------------|------|----------|-------------|--------|------------------|
| User Auth | Backend | src/auth/ | Login, register, password reset | Complete | User Profile |
| Product List | Frontend | src/pages/products/ | Display product catalog | Complete | Cart, Search |
| Payment | Full-Stack | src/payment/ | Stripe integration | Partial | Orders |

**Feature Types:**
- **Backend** - API endpoints, services, database operations
- **Frontend** - UI components, pages, client-side logic
- **Full-Stack** - Features spanning both layers
- **Infrastructure** - DevOps, CI/CD, monitoring

**Feature Status:**
- **Complete** - Fully implemented and functional
- **Partial** - Some functionality missing
- **Stub** - Placeholder or minimal implementation
- **Deprecated** - Marked for removal

### Step 4: Pattern Recognition

Identify recurring patterns:

**Architecture Patterns:**
- MVC, MVVM, Clean Architecture, Hexagonal
- Service Layer, Repository Pattern
- Event-driven, Request-Response
- Microservices vs Monolith

**Code Patterns:**
- Naming conventions for features (kebab-case, PascalCase, etc.)
- File organization structure
- Common libraries and utilities used
- Error handling approach
- Authentication/Authorization patterns

**Feature Patterns:**
- CRUD operations structure
- Validation approaches
- API response formats
- State management patterns

### Step 5: Duplicate Check (for proposed features)

If checking a proposed feature against existing:

**Semantic Analysis:**
1. Compare feature intent with existing features
2. Identify functional overlap
3. Check for partial implementations

**Code Pattern Matching:**
```bash
# Search for similar route patterns
grep -r "proposed_endpoint_pattern" --include="*.ts" --include="*.js" src/

# Search for similar component names
find . -iname "*proposed_name*" -not -path "*/node_modules/*"

# Search for similar service/model names
grep -r "ProposedClassName\|proposed_function" --include="*.ts" --include="*.js" src/
```

**Duplicate Categories:**
| Category | Code | Action |
|----------|------|--------|
| EXACT_MATCH | DUP-XXX | Feature already exists - use existing |
| PARTIAL_OVERLAP | DUP-XXX | Some functionality exists - extend instead |
| NAMING_CONFLICT | DUP-XXX | Different feature with similar name - rename |
| NO_CONFLICT | - | Proposed feature is unique - proceed |

### Step 6: Propose New Features (if requested)

Based on patterns found, propose features that:
- Fill gaps in existing functionality
- Extend current patterns naturally
- Follow established conventions
- Complement existing features

**Proposal Template:**

```markdown
## Proposed Feature: [Name]

**Type:** [Backend/Frontend/Full-Stack]
**Category:** [Extension/New/Enhancement]
**Similar To:** [Existing feature it resembles]
**Priority:** [High/Medium/Low]

**Description:**
[What the feature does and why it's needed]

**Justification:**
- Pattern observed: [existing pattern this follows]
- Gap identified: [what's missing currently]
- User benefit: [value proposition]

**Implementation Hints:**
- Follow pattern from: [existing feature path]
- Use existing: [service/component/model to reuse]
- Location: [suggested file paths]

**Dependencies:**
- Requires: [existing features this depends on]
- Enables: [future features this unlocks]

**Duplicate Check Result:** NO_CONFLICT
```

### Step 7: Create Feature Analysis Report

Write to `agent-os/reports/feature-analysis-[date].md` or `agent-os/specs/[spec-path]/planning/feature-analysis.md`:

```markdown
# Feature Analysis Report

## Analysis Summary
- **Date**: [Current date]
- **Scope**: [What was analyzed]
- **Mode**: [Discover/Propose/Check Duplicate/Full]
- **Features Discovered**: [count]
- **Patterns Identified**: [count]
- **Proposals**: [count if applicable]

## Feature Catalog

### Category 1: User Management
| Feature | Type | Status | Location | Description |
|---------|------|--------|----------|-------------|
| User Registration | Backend | Complete | src/auth/register.ts | Email/password signup |
| User Profile | Full-Stack | Partial | src/users/ | View/edit profile |
| Password Reset | Backend | Complete | src/auth/reset.ts | Email-based reset flow |

### Category 2: E-Commerce
[Continue pattern for each category]

## Patterns Discovered

### Architecture
[Description of overall architecture pattern]

### Naming Conventions
- Files: [pattern observed]
- Functions: [pattern observed]
- Components: [pattern observed]
- Routes: [pattern observed]

### Common Utilities
- [Utility 1]: [usage pattern]
- [Utility 2]: [usage pattern]

### Code Organization
```
src/
├── [layer 1]/     # [purpose]
├── [layer 2]/     # [purpose]
└── [layer 3]/     # [purpose]
```

## Duplicate Analysis (if applicable)

### Proposed Feature: [Name]
**Verdict:** [EXACT_MATCH | PARTIAL_OVERLAP | NAMING_CONFLICT | NO_CONFLICT]
**Issue ID:** [DUP-XXX if duplicate found]
**Details:** [Explanation of finding]
**Recommendation:** [Proceed / Modify / Abandon / Extend existing]

## Feature Proposals (if applicable)

### FEAT-001: [Proposed Feature Name]
[Full proposal using template from Step 6]

### FEAT-002: [Another Proposed Feature]
[Full proposal]

## Gap Analysis

### Missing Features
| Gap ID | Description | Priority | Suggested Solution |
|--------|-------------|----------|-------------------|
| GAP-001 | [Missing functionality] | High | [How to address] |
| GAP-002 | [Missing functionality] | Medium | [How to address] |

### Incomplete Features
| Feature | Missing Parts | Effort to Complete |
|---------|---------------|-------------------|
| [Feature] | [What's missing] | [Small/Medium/Large] |

## Recommendations

### Immediate Opportunities
1. [Feature that fills obvious gap with high value]

### Extensions to Consider
1. [Enhancement to existing feature]

### Technical Debt Related to Features
1. [Feature-related tech debt to address]

## Next Steps

1. [ ] Review proposed features with stakeholders
2. [ ] Prioritize based on business value
3. [ ] Create specs for approved features
4. [ ] Plan implementation timeline
```

### Step 8: Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
Feature analysis complete.
Report: agent-os/reports/feature-analysis-[date].md
Summary: [X] features discovered | [Y] patterns | [Z] proposals
Duplicates: [None found / X potential overlaps identified]
Gaps: [N] missing features identified
Next: Review report and prioritize recommendations
```

**Do NOT include** detailed feature catalogs, pattern descriptions, full proposals, or gap analysis in the conversation response.

## Important Constraints

- Focus on user-facing features, not internal utilities
- Respect module boundaries when cataloging
- Consider both code structure AND runtime behavior
- Document assumptions about feature boundaries
- Provide actionable proposals, not theoretical suggestions
- Always verify proposed features against existing catalog
- Use issue tracking IDs (FEAT-XXX, DUP-XXX, GAP-XXX) for findings
- Exclude node_modules, vendor, and generated code from analysis

## Error Recovery

If you encounter issues during feature analysis:

1. **Large Codebase**: Focus on entry points, routes, and controllers first. Document areas not analyzed.
2. **Unfamiliar Framework**: Note limitations, analyze common patterns (routes, handlers, services)
3. **Generated Code**: Exclude from analysis, note in report
4. **Missing Documentation**: Use code structure as primary source of feature identification
5. **Ambiguous Boundaries**: Document assumptions about feature boundaries
6. **No Clear Architecture**: Note as finding, recommend architecture documentation first
7. **Monorepo Structure**: Analyze each package separately, note cross-package features
