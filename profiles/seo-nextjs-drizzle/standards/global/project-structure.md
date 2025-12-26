# Next.js Project Structure (Drizzle + BetterAuth)

## App Directory Structure

Next.js 15+ uses the App Router with the `app/` directory.

```
project-root/
├── src/
│   ├── app/                          # App Router
│   │   ├── layout.tsx                # Root layout (required)
│   │   ├── page.tsx                  # Home page (/)
│   │   ├── error.tsx                 # Error boundary for root
│   │   ├── not-found.tsx             # 404 page
│   │   ├── loading.tsx               # Loading UI with Suspense
│   │   │
│   │   ├── (marketing)/              # Route group - doesn't affect URL
│   │   │   ├── layout.tsx            # Group-specific layout
│   │   │   ├── page.tsx              # /
│   │   │   └── pricing/
│   │   │       └── page.tsx          # /pricing
│   │   │
│   │   ├── (auth)/                   # Auth route group
│   │   │   ├── layout.tsx
│   │   │   ├── login/
│   │   │   │   └── page.tsx          # /login
│   │   │   └── signup/
│   │   │       └── page.tsx          # /signup
│   │   │
│   │   ├── dashboard/                # Nested route
│   │   │   ├── layout.tsx            # Dashboard layout
│   │   │   ├── page.tsx              # /dashboard
│   │   │   ├── loading.tsx           # Loading UI for /dashboard
│   │   │   ├── error.tsx             # Error boundary for /dashboard
│   │   │   │
│   │   │   └── [projectId]/          # Dynamic route segment
│   │   │       ├── layout.tsx
│   │   │       ├── page.tsx          # /dashboard/[projectId]
│   │   │       └── settings/
│   │   │           └── page.tsx      # /dashboard/[projectId]/settings
│   │   │
│   │   └── api/                      # API routes (Route Handlers)
│   │       ├── auth/
│   │       │   └── [...all]/
│   │       │       └── route.ts      # BetterAuth catch-all handler
│   │       │
│   │       ├── inngest/
│   │       │   └── route.ts          # Inngest webhook handler
│   │       │
│   │       ├── pusher/
│   │       │   └── auth/
│   │       │       └── route.ts      # Pusher private channel auth
│   │       │
│   │       └── projects/
│   │           ├── route.ts          # GET /api/projects, POST /api/projects
│   │           └── [id]/
│   │               └── route.ts      # GET, PATCH, DELETE /api/projects/[id]
│   │
│   ├── components/                   # Reusable components
│   │   ├── common/                   # Shared components
│   │   ├── layout/                   # Layout components
│   │   ├── forms/                    # Form components
│   │   └── ui/                       # shadcn/ui components
│   │
│   ├── db/                           # Drizzle ORM (database)
│   │   ├── index.ts                  # Database client export
│   │   ├── schema/                   # Schema definitions
│   │   │   ├── index.ts              # Re-export all schemas
│   │   │   ├── user.ts               # User, session, account tables
│   │   │   ├── project.ts            # Project and relations
│   │   │   ├── scanned-page.ts       # Scanned pages and scan history
│   │   │   ├── recommendation.ts     # SEO recommendations
│   │   │   └── notification.ts       # Notifications
│   │   └── queries/                  # Optional: reusable query functions
│   │
│   ├── lib/                          # Utilities and helpers
│   │   ├── auth.ts                   # BetterAuth client
│   │   ├── auth-server.ts            # BetterAuth server config
│   │   ├── inngest/
│   │   │   ├── client.ts             # Inngest client
│   │   │   └── functions/            # Inngest job functions
│   │   │       ├── scan-pages.ts
│   │   │       ├── analyze-seo.ts
│   │   │       └── send-notification.ts
│   │   ├── pusher/
│   │   │   ├── server.ts             # Pusher server instance
│   │   │   └── client.ts             # Pusher client hooks
│   │   ├── ai/
│   │   │   ├── client.ts             # OpenRouter client
│   │   │   └── prompts.ts            # Prompt templates
│   │   └── storage.ts                # Vercel Blob utilities
│   │
│   ├── hooks/                        # Custom hooks
│   │   ├── use-session.ts            # BetterAuth session hook
│   │   ├── use-pusher.ts             # Pusher subscription hook
│   │   └── use-form.ts               # Form handling
│   │
│   ├── types/                        # TypeScript types
│   │   ├── index.ts
│   │   └── database.ts               # Drizzle inferred types
│   │
│   ├── actions/                      # Server Actions
│   │   ├── projects.ts               # Project-related actions
│   │   ├── scans.ts                  # Scan-related actions
│   │   └── auth.ts                   # Auth-related actions
│   │
│   ├── validations/                  # Zod schemas
│   │   ├── project.ts
│   │   ├── scan.ts
│   │   └── user.ts
│   │
│   ├── styles/                       # Global styles
│   │   └── globals.css
│   │
│   └── middleware.ts                 # Next.js middleware (route protection)
│
├── drizzle/                          # Drizzle migrations
│   ├── 0000_initial.sql
│   ├── 0001_add_projects.sql
│   └── meta/
│       └── _journal.json
│
├── public/                           # Static assets
│   ├── images/
│   ├── fonts/
│   └── favicon.ico
│
├── .env.local                        # Local environment variables
├── .env.example                      # Template for team
├── drizzle.config.ts                 # Drizzle Kit configuration
├── next.config.ts                    # Next.js configuration
├── tsconfig.json                     # TypeScript configuration
├── tailwind.config.ts                # Tailwind CSS config
├── vitest.config.ts                  # Vitest configuration
├── playwright.config.ts              # Playwright E2E config
├── package.json
└── README.md
```

## Database Structure (Drizzle ORM)

```
src/db/
├── index.ts                 # Database client export
├── schema/
│   ├── index.ts            # Re-export all schemas
│   ├── user.ts             # User, session, account tables (BetterAuth)
│   ├── project.ts          # Project and relations
│   ├── scanned-page.ts     # Scanned pages
│   ├── recommendation.ts   # SEO recommendations
│   └── notification.ts     # User notifications
└── queries/                # Optional: reusable query functions
    ├── users.ts
    └── projects.ts

drizzle/                    # Migrations (generated by Drizzle Kit)
├── 0000_initial.sql
├── 0001_add_projects.sql
└── meta/
    └── _journal.json
```

## Inngest Job Organization

```
src/lib/inngest/
├── client.ts               # Inngest client initialization
└── functions/
    ├── index.ts            # Export all functions
    ├── scan-pages.ts       # Page scanning job
    ├── analyze-seo.ts      # AI analysis job
    ├── send-notification.ts # Notification job
    └── batch-process.ts    # Batch processing job
```

## Route Organization

### Route Groups for Layout Variants

```
app/
├── (marketing)/
│   ├── layout.tsx                # Marketing header/footer
│   ├── page.tsx                  # /
│   ├── pricing/
│   │   └── page.tsx              # /pricing
│   └── blog/
│       └── page.tsx              # /blog
│
├── (auth)/
│   ├── layout.tsx                # Minimal auth layout
│   ├── login/
│   │   └── page.tsx              # /login
│   └── signup/
│       └── page.tsx              # /signup
│
└── (dashboard)/
    ├── layout.tsx                # Dashboard header/sidebar
    ├── dashboard/
    │   └── page.tsx              # /dashboard
    └── projects/
        └── [id]/
            └── page.tsx          # /projects/[id]
```

### API Routes Organization

```
app/api/
├── auth/
│   └── [...all]/
│       └── route.ts              # BetterAuth catch-all handler
│
├── inngest/
│   └── route.ts                  # POST /api/inngest (Inngest webhook)
│
├── pusher/
│   └── auth/
│       └── route.ts              # POST /api/pusher/auth (private channels)
│
├── projects/
│   ├── route.ts                  # GET, POST /api/projects
│   └── [id]/
│       ├── route.ts              # GET, PATCH, DELETE /api/projects/[id]
│       └── scan/
│           └── route.ts          # POST /api/projects/[id]/scan
│
└── webhooks/
    └── stripe/
        └── route.ts              # POST /api/webhooks/stripe
```

## Component Organization (Feature-Based)

```
src/components/
├── dashboard/                    # Feature: Dashboard
│   ├── DashboardLayout.tsx
│   ├── DashboardHeader.tsx
│   └── DashboardStats.tsx
│
├── projects/                     # Feature: Projects
│   ├── ProjectList.tsx
│   ├── ProjectCard.tsx
│   └── ProjectForm.tsx
│
├── analysis/                     # Feature: SEO Analysis
│   ├── AnalysisResults.tsx
│   ├── RecommendationCard.tsx
│   └── ScoreChart.tsx
│
├── auth/                         # Feature: Authentication
│   ├── LoginForm.tsx
│   ├── SignupForm.tsx
│   └── AuthGuard.tsx
│
└── ui/                           # shadcn/ui components
    ├── button.tsx
    ├── card.tsx
    ├── dialog.tsx
    └── ...
```

## Special Files

These files have special meaning in Next.js:

- **layout.tsx**: Wraps child routes, required at root
- **page.tsx**: Route page component (creates a route)
- **loading.tsx**: Suspense fallback UI
- **error.tsx**: Error boundary for this segment
- **not-found.tsx**: 404 page
- **route.ts**: Route Handler (API endpoint)
- **middleware.ts**: Request middleware at root level

## Environment & Configuration Files

```
.env.local                        # Local secrets (git-ignored)
.env.example                      # Public template
next.config.ts                    # Next.js configuration
drizzle.config.ts                 # Drizzle Kit config
tsconfig.json                     # TypeScript configuration
tailwind.config.ts                # Tailwind CSS config
vitest.config.ts                  # Vitest test runner
playwright.config.ts              # Playwright E2E tests
postcss.config.js                 # PostCSS plugins
.eslintrc.json                    # ESLint rules
.prettierrc                       # Prettier rules
```

## Naming Conventions

### Page Files
- **page.tsx** for route pages (not `index.tsx`)
- **layout.tsx** for layouts (not `root-layout.tsx`)

### Components
- PascalCase: `ProjectCard.tsx`, `DashboardHeader.tsx`
- Compound components: `Dialog/DialogTrigger.tsx`, `Dialog/DialogContent.tsx`

### Database Schema
- Lowercase table names: `user`, `project`, `scannedPage`
- camelCase column names in TypeScript, snake_case in SQL

### Utilities & Helpers
- camelCase: `formatDate.ts`, `validateEmail.ts`

### Hooks
- Prefix with `use`: `useSession.ts`, `usePusher.ts`

### Zod Schemas
- Suffix with `Schema`: `projectSchema`, `createProjectSchema`

## Related Standards

- {{standards/global/coding-style}} - File naming and conventions
- {{standards/backend/database}} - Drizzle ORM patterns
- {{standards/backend/api}} - API route organization
- {{standards/backend/auth}} - BetterAuth configuration
- {{standards/backend/background-jobs}} - Inngest job structure
