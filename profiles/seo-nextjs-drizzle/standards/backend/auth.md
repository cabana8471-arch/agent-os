# Authentication Standards - BetterAuth

This standard documents the complete authentication setup and patterns using BetterAuth with OAuth providers.

## I. Installation & Setup

### Install Dependencies

```bash
pnpm install better-auth
```

---

## II. Server Configuration

### Initialize BetterAuth

```typescript
// lib/auth.ts
import { betterAuth } from 'better-auth'
import { drizzleAdapter } from 'better-auth/adapters/drizzle'
import { db } from '@/db'

export const auth = betterAuth({
  // Database adapter
  database: drizzleAdapter(db, {
    provider: 'pg', // PostgreSQL
  }),

  // Basic email/password (optional)
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: false,
  },

  // OAuth providers
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
    github: {
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    },
  },

  // Session configuration
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 days
    updateAge: 60 * 60 * 24, // Update every day
    cookieName: 'better-auth.session_token',
    cookieAttributes: {
      httpOnly: true,
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production',
    },
  },

  // Trust host for OAuth redirects
  appName: 'SEO Optimization',
  baseURL: process.env.BETTER_AUTH_URL || 'http://localhost:3000',
})

// Export for type safety
export type Session = typeof auth.$Infer.Session
```

### Auth Route Handler

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from '@/lib/auth'

export const { GET, POST } = auth.handler
```

---

## III. Client Configuration

### Create Auth Client

```typescript
// lib/auth-client.ts
import { createAuthClient } from 'better-auth/react'

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL,
})

export const {
  signIn,
  signOut,
  signUp,
  useSession,
  useAtom,
} = authClient
```

### Client Hook Usage

```typescript
// components/session-display.tsx
'use client'

import { useSession } from '@/lib/auth-client'

export function SessionDisplay() {
  const { data: session, isPending, error } = useSession()

  if (isPending) return <div>Loading...</div>
  if (error) return <div>Error loading session</div>
  if (!session) return <div>No session</div>

  return (
    <div>
      <p>User: {session.user.name}</p>
      <p>Email: {session.user.email}</p>
      <p>Role: {session.user.role}</p>
    </div>
  )
}
```

---

## IV. OAuth Flows

### Google OAuth Setup

#### 1. Create OAuth Credentials
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable Google+ API
4. Create OAuth 2.0 credentials (Web application)
5. Add authorized redirect URIs:
   - Development: `http://localhost:3000/api/auth/callback/google`
   - Production: `https://yourdomain.com/api/auth/callback/google`

#### 2. Environment Variables
```bash
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

#### 3. Usage
```typescript
'use client'

import { signIn } from '@/lib/auth-client'

export function GoogleSignIn() {
  return (
    <button onClick={() => signIn.social({ provider: 'google' })}>
      Sign in with Google
    </button>
  )
}
```

### GitHub OAuth Setup

#### 1. Create OAuth App
1. Go to GitHub Settings > Developer settings > OAuth Apps
2. Create a new OAuth App
3. Set Authorization callback URL:
   - Development: `http://localhost:3000/api/auth/callback/github`
   - Production: `https://yourdomain.com/api/auth/callback/github`

#### 2. Environment Variables
```bash
GITHUB_CLIENT_ID=your-github-app-id
GITHUB_CLIENT_SECRET=your-github-app-secret
```

#### 3. Usage
```typescript
'use client'

import { signIn } from '@/lib/auth-client'

export function GitHubSignIn() {
  return (
    <button onClick={() => signIn.social({ provider: 'github' })}>
      Sign in with GitHub
    </button>
  )
}
```

### OAuth Redirect Handling

```typescript
// app/auth/callback/page.tsx
'use client'

import { useEffect } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { useSession } from '@/lib/auth-client'

export default function AuthCallback() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const { data: session } = useSession()

  useEffect(() => {
    if (session) {
      const redirectTo = searchParams.get('redirect') || '/dashboard'
      router.push(redirectTo)
    }
  }, [session, router, searchParams])

  return (
    <div className="flex items-center justify-center min-h-screen">
      <p>Processing authentication...</p>
    </div>
  )
}
```

---

## V. Session Management

### Server-Side Session Validation

```typescript
// lib/get-session.ts
import { auth } from './auth'
import { headers } from 'next/headers'

export async function getSession() {
  return await auth.api.getSession({
    headers: await headers(),
  })
}
```

### Protected Server Component

```typescript
// app/components/protected-content.tsx
import { getSession } from '@/lib/get-session'
import { redirect } from 'next/navigation'

export async function ProtectedContent() {
  const session = await getSession()

  if (!session) {
    redirect('/login')
  }

  return (
    <div>
      <h1>Welcome, {session.user.name}</h1>
      <p>This content is protected</p>
    </div>
  )
}
```

### Client-Side Session Hook

```typescript
'use client'

import { useSession } from '@/lib/auth-client'
import { useRouter } from 'next/navigation'
import { useEffect } from 'react'

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { data: session, isPending } = useSession()
  const router = useRouter()

  useEffect(() => {
    if (!isPending && !session) {
      router.push('/login')
    }
  }, [session, isPending, router])

  if (isPending) {
    return <div>Loading...</div>
  }

  if (!session) {
    return null
  }

  return <>{children}</>
}
```

---

## VI. Protected Routes & Components

### Middleware Protection

```typescript
// middleware.ts
import { auth } from '@/lib/auth'
import { NextRequest, NextResponse } from 'next/server'

export async function middleware(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  // Protect dashboard routes
  if (request.nextUrl.pathname.startsWith('/dashboard')) {
    if (!session) {
      return NextResponse.redirect(new URL('/login', request.url))
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/protected/:path*'],
}
```

### Protected API Routes

```typescript
// app/api/protected/profile/route.ts
import { auth } from '@/lib/auth'
import { NextRequest, NextResponse } from 'next/server'
import { db } from '@/db'
import { user } from '@/db/schema'
import { eq } from 'drizzle-orm'

export async function GET(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    )
  }

  const userData = await db.query.user.findFirst({
    where: eq(user.id, session.user.id),
  })

  return NextResponse.json(userData)
}
```

### Protected Client Components

```typescript
// app/components/user-menu.tsx
'use client'

import { useSession, signOut } from '@/lib/auth-client'

export function UserMenu() {
  const { data: session } = useSession()

  if (!session) {
    return null
  }

  return (
    <div className="dropdown">
      <button>{session.user.name}</button>
      <ul className="dropdown-menu">
        <li><a href="/dashboard">Dashboard</a></li>
        <li><a href="/settings">Settings</a></li>
        <li>
          <button onClick={() => signOut()}>Sign Out</button>
        </li>
      </ul>
    </div>
  )
}
```

---

## VII. Database Schema

### BetterAuth Tables

```typescript
// lib/auth.ts automatically creates these tables:

// user - User accounts
// - id (primary key)
// - email
// - name
// - emailVerified
// - image
// - createdAt
// - updatedAt

// session - Active sessions
// - id (primary key)
// - userId (foreign key)
// - expiresAt
// - token
// - ipAddress
// - userAgent

// account - OAuth connections
// - id (primary key)
// - userId (foreign key)
// - provider (google, github, etc)
// - providerAccountId
// - accessToken
// - refreshToken
// - expiresAt

// verification - Email verification
// - id (primary key)
// - identifier (email)
// - token
// - expiresAt
```

### Drizzle Adapter Configuration

```typescript
// The drizzleAdapter automatically:
// 1. Creates tables if they don't exist
// 2. Uses snake_case column naming (database convention)
// 3. Maps to camelCase in TypeScript
// 4. Handles all CRUD operations

const adapter = drizzleAdapter(db, {
  provider: 'pg',
  usePlural: true, // Table names: users, sessions (not user, session)
})
```

---

## VIII. Sign-Up Flow

### Custom Sign-Up Page

```typescript
// app/auth/signup/page.tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { signUp, signIn } from '@/lib/auth-client'

export default function SignUpPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [name, setName] = useState('')
  const [error, setError] = useState('')

  async function handleSignUp(e: React.FormEvent) {
    e.preventDefault()
    setError('')

    try {
      await signUp.email({
        email,
        password,
        name,
      })
      router.push('/dashboard')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Sign up failed')
    }
  }

  return (
    <div className="max-w-md mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">Sign Up</h1>

      <form onSubmit={handleSignUp} className="space-y-4">
        {error && <div className="text-red-500">{error}</div>}

        <input
          type="text"
          placeholder="Name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          className="w-full border p-2 rounded"
        />

        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full border p-2 rounded"
        />

        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full border p-2 rounded"
        />

        <button
          type="submit"
          className="w-full bg-blue-500 text-white p-2 rounded"
        >
          Sign Up
        </button>
      </form>

      <div className="mt-4 space-y-2">
        <button
          onClick={() => signIn.social({ provider: 'google' })}
          className="w-full border p-2 rounded"
        >
          Sign up with Google
        </button>
        <button
          onClick={() => signIn.social({ provider: 'github' })}
          className="w-full border p-2 rounded"
        >
          Sign up with GitHub
        </button>
      </div>
    </div>
  )
}
```

---

## IX. Sign-In Flow

### Custom Sign-In Page

```typescript
// app/auth/signin/page.tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { signIn } from '@/lib/auth-client'

export default function SignInPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  async function handleSignIn(e: React.FormEvent) {
    e.preventDefault()
    setError('')

    try {
      await signIn.email({
        email,
        password,
        callbackURL: '/dashboard',
      })
      router.push('/dashboard')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Sign in failed')
    }
  }

  return (
    <div className="max-w-md mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">Sign In</h1>

      <form onSubmit={handleSignIn} className="space-y-4">
        {error && <div className="text-red-500">{error}</div>}

        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full border p-2 rounded"
        />

        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full border p-2 rounded"
        />

        <button
          type="submit"
          className="w-full bg-blue-500 text-white p-2 rounded"
        >
          Sign In
        </button>
      </form>

      <div className="mt-4 space-y-2">
        <button
          onClick={() => signIn.social({ provider: 'google' })}
          className="w-full border p-2 rounded"
        >
          Sign in with Google
        </button>
        <button
          onClick={() => signIn.social({ provider: 'github' })}
          className="w-full border p-2 rounded"
        >
          Sign in with GitHub
        </button>
      </div>

      <p className="mt-4 text-center">
        Don't have an account? <a href="/auth/signup" className="text-blue-500">Sign up</a>
      </p>
    </div>
  )
}
```

---

## X. Sign Out

### Sign Out Function

```typescript
'use client'

import { signOut } from '@/lib/auth-client'
import { useRouter } from 'next/navigation'

export function SignOutButton() {
  const router = useRouter()

  async function handleSignOut() {
    await signOut({
      fetchOptions: {
        onSuccess: () => {
          router.push('/login')
        },
      },
    })
  }

  return (
    <button onClick={handleSignOut}>
      Sign Out
    </button>
  )
}
```

---

## XI. Environment Variables

```bash
# OAuth Providers
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

# Database
DATABASE_URL=

# Auth
BETTER_AUTH_URL=http://localhost:3000
BETTER_AUTH_SECRET=your-secret-key

# Public (client-side)
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

---

## XII. Best Practices

1. **Always use HTTPS in production** - OAuth requires HTTPS
2. **Store secrets in environment variables** - Never hardcode credentials
3. **Use session hooks for client auth** - Cleaner than manual API calls
4. **Validate sessions in protected routes** - Check auth before processing
5. **Handle OAuth errors gracefully** - Show user-friendly messages
6. **Use redirect for unauthorized access** - Redirect to login page
7. **Keep session tokens secure** - Use httpOnly cookies
8. **Refresh sessions periodically** - Maintain security over time
9. **Log auth events** - Track sign-ins for security
10. **Test OAuth flows** - Use OAuth sandbox/development apps

---

## Related Standards

- {{standards/backend/database}} - User schema and database integration
- {{standards/backend/api}} - Protected API routes
- {{standards/global/security}} - Security best practices
- {{standards/global/error-handling}} - Error handling in auth flows
