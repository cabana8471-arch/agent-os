# Next.js Project Structure

## App Directory Structure (Recommended)

Next.js 13+ uses the App Router with the `app/` directory. This is the modern approach.

```
project-root/
├── app/                          # App Router (mandatory)
│   ├── layout.tsx                # Root layout (required)
│   ├── page.tsx                  # Home page (/)
│   ├── error.tsx                 # Error boundary for root
│   ├── not-found.tsx             # 404 page
│   ├── loading.tsx               # Loading UI with Suspense
│   │
│   ├── (marketing)/              # Route group - doesn't affect URL
│   │   ├── layout.tsx            # Group-specific layout
│   │   ├── page.tsx              # /
│   │   └── about/
│   │       └── page.tsx          # /about
│   │
│   ├── (auth)/                   # Auth route group
│   │   ├── layout.tsx
│   │   ├── login/
│   │   │   └── page.tsx          # /login
│   │   └── signup/
│   │       └── page.tsx          # /signup
│   │
│   ├── dashboard/                # Nested route
│   │   ├── layout.tsx            # Dashboard layout
│   │   ├── page.tsx              # /dashboard
│   │   ├── loading.tsx           # Loading UI for /dashboard
│   │   ├── error.tsx             # Error boundary for /dashboard
│   │   │
│   │   └── [id]/                 # Dynamic route segment
│   │       ├── layout.tsx
│   │       ├── page.tsx          # /dashboard/[id]
│   │       └── settings/
│   │           └── page.tsx      # /dashboard/[id]/settings
│   │
│   ├── api/                      # API routes (Route Handlers)
│   │   ├── auth/
│   │   │   ├── route.ts          # POST /api/auth
│   │   │   └── callback/
│   │   │       └── route.ts      # GET /api/auth/callback
│   │   │
│   │   └── users/
│   │       ├── route.ts          # GET /api/users, POST /api/users
│   │       └── [id]/
│   │           └── route.ts      # GET /api/users/[id], PATCH, DELETE
│   │
│   └── @modal/                   # Parallel route (intercepting)
│       ├── layout.tsx
│       └── settings/
│           └── page.tsx
│
├── src/                          # Optional source directory
│   ├── app/                      # Move app/ here if preferred
│   ├── components/               # Reusable components
│   ├── lib/                      # Utilities and helpers
│   ├── hooks/                    # Custom hooks
│   ├── types/                    # TypeScript types
│   ├── styles/                   # Global styles
│   └── utils/                    # Utility functions
│
├── public/                       # Static assets
│   ├── images/
│   ├── fonts/
│   └── favicon.ico
│
├── prisma/                       # Database (if using Prisma)
│   ├── schema.prisma
│   └── migrations/
│
├── .env.local                    # Local environment variables
├── .env.example                  # Template for team
├── next.config.ts                # Next.js configuration
├── tsconfig.json                 # TypeScript configuration
├── tailwind.config.ts            # Tailwind CSS (if used)
├── package.json
└── README.md
```

## Alternative: src/ Directory Variant

Many teams prefer code in `src/`:

```
project-root/
├── src/
│   ├── app/                      # App Router goes here
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── ...
│   │
│   ├── components/
│   │   ├── common/               # Shared components
│   │   ├── layout/               # Layout components
│   │   ├── forms/                # Form components
│   │   └── ui/                   # Basic UI elements
│   │
│   ├── lib/                      # Utilities
│   │   ├── db.ts                 # Database client/connection
│   │   ├── auth.ts               # Auth utilities
│   │   └── api.ts                # API client
│   │
│   ├── hooks/                    # Custom hooks
│   │   ├── useAuth.ts
│   │   └── useForm.ts
│   │
│   ├── types/                    # Type definitions
│   │   ├── index.ts
│   │   ├── user.ts
│   │   └── database.ts
│   │
│   ├── styles/                   # Global styles
│   │   ├── globals.css
│   │   └── variables.css
│   │
│   └── middleware.ts             # Next.js middleware
│
├── public/
├── prisma/
├── .env.local
├── next.config.ts
└── ...
```

## Route Organization

### Route Groups for Layout Variants

Use route groups `(groupname)/` to share layouts without affecting URLs:

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
└── (admin)/
    ├── layout.tsx                # Admin header/sidebar
    ├── page.tsx                  # /admin (or /dashboard)
    └── users/
        └── page.tsx              # /admin/users
```

### Dynamic Routes

```
app/
├── posts/
│   └── [slug]/
│       └── page.tsx              # /posts/[slug]
│
└── users/
    └── [id]/
        ├── page.tsx              # /users/[id]
        ├── posts/
        │   └── page.tsx          # /users/[id]/posts
        └── settings/
            └── page.tsx          # /users/[id]/settings
```

### Catch-All Routes

```
app/
├── docs/
│   └── [...slug]/                # /docs/any/path/here
│       └── page.tsx
```

## Component Organization

### By Feature (Feature-Based)

Recommended for most applications:

```
src/components/
├── dashboard/                    # Feature: Dashboard
│   ├── DashboardLayout.tsx
│   ├── DashboardHeader.tsx
│   └── DashboardStats.tsx
│
├── users/                        # Feature: Users
│   ├── UserList.tsx
│   ├── UserCard.tsx
│   └── UserForm.tsx
│
├── auth/                         # Feature: Authentication
│   ├── LoginForm.tsx
│   ├── SignupForm.tsx
│   └── AuthGuard.tsx
│
└── common/                       # Shared components
    ├── Button.tsx
    ├── Card.tsx
    └── Modal.tsx
```

### By Type (Alternative)

Use if your app is small or follows strict separation:

```
src/components/
├── forms/
│   ├── LoginForm.tsx
│   ├── UserForm.tsx
│   └── ContactForm.tsx
│
├── layout/
│   ├── Header.tsx
│   ├── Sidebar.tsx
│   └── Footer.tsx
│
└── ui/
    ├── Button.tsx
    ├── Card.tsx
    └── Modal.tsx
```

## Special Files

These files have special meaning in Next.js and should be named exactly:

- **layout.tsx**: Wraps child routes, required at root
- **page.tsx**: Route page component (creates a route)
- **loading.tsx**: Suspense fallback UI
- **error.tsx**: Error boundary for this segment
- **not-found.tsx**: 404 page
- **route.ts**: Route Handler (API endpoint)
- **middleware.ts**: Request middleware at root level
- **instrumentation.ts**: Analytics/monitoring setup
- **opengraph-image.tsx**: Dynamic OG image generation
- **robots.ts**: Robots.txt generation
- **sitemap.ts**: Sitemap generation

## Naming Conventions

### Page Files
- **page.tsx** for route pages (not `index.tsx`)
- **layout.tsx** for layouts (not `root-layout.tsx`)

### Components
- PascalCase: `UserCard.tsx`, `BlogHeader.tsx`
- Compound components: `Dialog/DialogTrigger.tsx`, `Dialog/DialogContent.tsx`

### Utilities & Helpers
- camelCase: `formatDate.ts`, `validateEmail.ts`

### Hooks
- Prefix with `use`: `useAuth.ts`, `useForm.ts`, `useLocalStorage.ts`

### Types
- PascalCase: `User.ts`, `BlogPost.ts`
- File per type recommended for larger types

## API Routes Organization

```
app/api/
├── auth/
│   ├── route.ts                  # POST /api/auth
│   └── callback/
│       └── route.ts              # GET /api/auth/callback
│
├── users/
│   ├── route.ts                  # GET, POST /api/users
│   └── [id]/
│       └── route.ts              # GET, PATCH, DELETE /api/users/[id]
│
└── webhooks/
    ├── stripe/
    │   └── route.ts              # POST /api/webhooks/stripe
    └── github/
        └── route.ts              # POST /api/webhooks/github
```

## Environment & Configuration Files

Keep at project root:

```
.env.local                        # Local secrets (git-ignored)
.env.example                      # Public template
.env.production                   # Production defaults (optional)
.env.development                  # Dev defaults (optional)
next.config.ts                    # Next.js configuration
tsconfig.json                     # TypeScript configuration
tailwind.config.ts                # Tailwind CSS config
postcss.config.js                 # PostCSS plugins
.eslintrc.json                    # ESLint rules
.prettierrc                        # Prettier rules
```

## Related Standards

- {{standards/global/coding-style}} - File naming and conventions
- {{standards/frontend/server-components}} - When to use Server vs Client Components
- {{standards/backend/api}} - API route organization
