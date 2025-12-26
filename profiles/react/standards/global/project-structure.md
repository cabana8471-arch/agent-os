# React Project Structure

## Recommended Directory Organization

```
my-app/
├── src/
│   ├── features/              # Feature-based organization
│   │   ├── auth/
│   │   │   ├── components/
│   │   │   │   ├── LoginForm.tsx
│   │   │   │   └── LoginForm.test.tsx
│   │   │   ├── hooks/
│   │   │   │   └── useAuth.ts
│   │   │   ├── api/
│   │   │   │   └── authApi.ts
│   │   │   └── types.ts
│   │   ├── dashboard/
│   │   │   ├── Dashboard.tsx
│   │   │   ├── components/
│   │   │   └── hooks/
│   │   └── users/
│   │       ├── UserList.tsx
│   │       ├── UserProfile.tsx
│   │       └── hooks/
│   │
│   ├── components/            # Shared UI components
│   │   ├── ui/
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── Dialog.tsx
│   │   │   └── Badge.tsx
│   │   ├── forms/
│   │   │   ├── FormField.tsx
│   │   │   └── FormError.tsx
│   │   └── layout/
│   │       ├── Header.tsx
│   │       ├── Sidebar.tsx
│   │       └── Footer.tsx
│   │
│   ├── hooks/                 # Shared custom hooks
│   │   ├── useAsync.ts
│   │   ├── useDebounce.ts
│   │   ├── useFetch.ts
│   │   └── useLocalStorage.ts
│   │
│   ├── lib/                   # Utilities and helpers
│   │   ├── api.ts             # API client setup
│   │   ├── formatters.ts      # Date, number formatting
│   │   ├── validators.ts      # Validation functions
│   │   └── constants.ts       # App constants
│   │
│   ├── types/                 # Shared TypeScript types
│   │   ├── index.ts
│   │   ├── user.ts
│   │   └── api.ts
│   │
│   ├── pages/                 # Route pages
│   │   ├── HomePage.tsx
│   │   ├── NotFoundPage.tsx
│   │   └── ErrorPage.tsx
│   │
│   ├── routes/                # Route configuration
│   │   └── routes.tsx
│   │
│   ├── store/                 # Global state (if using Zustand)
│   │   ├── index.ts
│   │   └── slices/
│   │       └── userSlice.ts
│   │
│   ├── styles/                # Global styles
│   │   ├── globals.css
│   │   └── tailwind.css
│   │
│   ├── assets/                # Static assets
│   │   ├── images/
│   │   ├── fonts/
│   │   └── icons/
│   │
│   ├── App.tsx                # Main App component
│   └── main.tsx               # Entry point
│
├── public/                    # Public static files
├── tests/                     # Integration/E2E tests
│   └── e2e/
├── .env.local                 # Local environment vars
├── vite.config.ts
├── tsconfig.json
├── tailwind.config.ts
├── package.json
└── README.md
```

## Organization Principles

### Feature-Based (Recommended)

```
features/
  users/
    components/
    hooks/
    api/
    types.ts
```

**Benefits:**
- All related code in one place
- Easy to move/delete features
- Self-contained modules

### Type-Based (Avoid)

```
components/     # Don't organize like this
hooks/
utils/
```

**Problems:**
- Mixes unrelated features
- Hard to find related code
- Scales poorly

## File Naming Conventions

```
Components:        UserProfile.tsx
Hooks:            useAuth.ts
Utilities:        formatDate.ts
Types:            user.ts or User.ts
Tests:            UserProfile.test.tsx
API:              authApi.ts
Stores/State:     userStore.ts or userSlice.ts
```

## Import Path Aliases

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/features/*": ["./src/features/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/types/*": ["./src/types/*"]
    }
  }
}

// Usage
import Button from '@/components/ui/Button'
import { useAuth } from '@/features/auth/hooks/useAuth'
import { formatDate } from '@/lib/formatters'
```

## Monorepo Structure (if applicable)

```
monorepo/
├── packages/
│   ├── frontend/               # React app
│   │   └── src/
│   │       └── features/
│   ├── backend/                # Node.js backend
│   │   └── src/
│   │       └── routes/
│   ├── shared/                 # Shared types/utils
│   │   └── src/
│   │       ├── types/
│   │       └── utils/
│   └── cli/                    # CLI tools
│
├── package.json                # Root package.json
├── pnpm-workspace.yaml         # For pnpm workspaces
└── tsconfig.json               # Root tsconfig
```

## Scaling Patterns

**Small app (< 10 features):**
- Simple flat structure
- One features/ directory

**Medium app (10-50 features):**
- Organized features/
- Shared components/
- Central lib/

**Large app (50+ features):**
- Module structure (domains/modules)
- Shared layer
- Plugin architecture

```
src/
  modules/
    auth/
    users/
    products/
  shared/
    components/
    hooks/
    lib/
```

## Related Standards

- {{standards/global/coding-style}} - Naming conventions
- {{standards/frontend/components}} - Component organization
