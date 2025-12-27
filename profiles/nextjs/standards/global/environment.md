# Next.js Environment Variables

## File Structure

```
project-root/
├── .env.local              # Local development (git-ignored)
├── .env.production         # Production defaults (optional)
├── .env.development        # Development defaults (optional)
└── .env.example            # Template for team (git-committed)
```

## Environment Variable Naming

### Client-Side Variables (Bundled)

Prefix with `NEXT_PUBLIC_` - these are bundled into JavaScript:

```env
# ✅ Good - Client can access
NEXT_PUBLIC_API_BASE_URL=https://api.example.com
NEXT_PUBLIC_APP_NAME=MyApp
NEXT_PUBLIC_ENABLE_ANALYTICS=true

# ❌ Bad - Not prefixed, won't be available to client
API_KEY=secret123
```

### Server-Side Variables (Private)

No prefix - only accessible in Server Components, Route Handlers, API routes:

```env
# ✅ Good - Server-only
DATABASE_URL=postgresql://user:pass@localhost/db
STRIPE_SECRET_KEY=sk_live_...
NEXTAUTH_SECRET=your-secret-key
JWT_SECRET=jwt-secret
```

### .env.example Template

Commit a public template with example values (no secrets):

```env
# Client-side
NEXT_PUBLIC_API_BASE_URL=https://api.example.com
NEXT_PUBLIC_APP_ENV=development

# Server-side
DATABASE_URL=postgresql://user:pass@localhost/myapp
STRIPE_SECRET_KEY=sk_test_...
NEXTAUTH_SECRET=your-secret-key-here
```

## Accessing Variables

### In Server Components

```typescript
// app/dashboard/page.tsx
import { db } from "@/lib/db"

export default async function DashboardPage() {
  // All env variables accessible in Server Components
  console.log(process.env.DATABASE_URL)
  console.log(process.env.NEXT_PUBLIC_API_BASE_URL)

  const data = await db.query("SELECT * FROM users")
  return <div>{/* ... */}</div>
}
```

### In Client Components

```typescript
// components/ApiClient.tsx
"use client"

export function ApiClient() {
  // ✅ Works - NEXT_PUBLIC_ prefixed
  const apiUrl = process.env.NEXT_PUBLIC_API_BASE_URL
  console.log(apiUrl) // "https://api.example.com"

  // ❌ Fails - not NEXT_PUBLIC_, returns undefined
  const secret = process.env.DATABASE_URL
  console.log(secret) // undefined

  return <div>{apiUrl}</div>
}
```

### In Route Handlers

```typescript
// app/api/auth/route.ts
export async function POST(request: Request) {
  // All env variables accessible
  const secret = process.env.NEXTAUTH_SECRET
  const dbUrl = process.env.DATABASE_URL

  return Response.json({ ok: true })
}
```

### In Middleware

```typescript
// middleware.ts
import { NextResponse } from "next/server"

export function middleware(request: NextRequest) {
  // ✅ Works - NEXT_PUBLIC_ variables
  const appEnv = process.env.NEXT_PUBLIC_APP_ENV
  console.log(appEnv) // "development"

  // ❌ Fails - server-only variables not accessible
  const secret = process.env.NEXTAUTH_SECRET
  console.log(secret) // undefined

  return NextResponse.next()
}
```

### Using with import.meta.env (Avoid)

Don't use `import.meta.env` - use `process.env` instead:

```typescript
// ❌ Bad - Wrong pattern for Next.js
const apiUrl = import.meta.env.VITE_API_URL

// ✅ Good - Next.js pattern
const apiUrl = process.env.NEXT_PUBLIC_API_BASE_URL
```

## Environment Stages

### Development (.env.local)

```env
# Local machine development
NEXT_PUBLIC_API_BASE_URL=http://localhost:3001
NEXT_PUBLIC_APP_ENV=development
DATABASE_URL=postgresql://user:password@localhost:5432/myapp_dev
NEXTAUTH_URL=http://localhost:3000
STRIPE_PUBLIC_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
```

### Production

```env
NEXT_PUBLIC_API_BASE_URL=https://api.example.com
NEXT_PUBLIC_APP_ENV=production
DATABASE_URL=postgresql://user:secure@prod-db.aws.com/myapp
NEXTAUTH_URL=https://myapp.com
NEXTAUTH_SECRET=<secure-random-string>
STRIPE_PUBLIC_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
```

### Testing (.env.test)

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:3001
DATABASE_URL=postgresql://user:password@localhost/myapp_test
NEXTAUTH_SECRET=test-secret-key
```

## Validation

### Validate at Runtime

Create a validation schema for required variables:

```typescript
// lib/env.ts
const requiredEnvVars = [
  "DATABASE_URL",
  "NEXTAUTH_SECRET",
  "NEXT_PUBLIC_API_BASE_URL",
]

function validateEnv() {
  const missing = requiredEnvVars.filter((key) => !process.env[key])
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(", ")}`)
  }
}

validateEnv()

export const env = {
  databaseUrl: process.env.DATABASE_URL!,
  nextauthSecret: process.env.NEXTAUTH_SECRET!,
  apiBaseUrl: process.env.NEXT_PUBLIC_API_BASE_URL!,
}
```

### Using Zod for Type-Safe Validation

```typescript
// lib/env.ts
import { z } from "zod"

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  NEXTAUTH_SECRET: z.string().min(32),
  NEXT_PUBLIC_API_BASE_URL: z.string().url(),
  STRIPE_SECRET_KEY: z.string().startsWith("sk_"),
})

const env = envSchema.parse(process.env)

export default env
```

## Best Practices

1. **Commit `.env.example`** - Template with public values
2. **Never commit `.env.local`** - Add to `.gitignore`
3. **Use meaningful names** - `STRIPE_SECRET_KEY` not `SK`
4. **Prefix client variables** - `NEXT_PUBLIC_*` only
5. **Validate early** - Check env vars on app startup
6. **Document in README** - List required environment variables
7. **Use CI/CD secrets** - Never hardcode production secrets

## Related Standards

- `global/tech-stack.md` - Framework and runtime versions
- `global/deployment.md` - Production environment setup
- `backend/api.md` - API configuration and secrets
