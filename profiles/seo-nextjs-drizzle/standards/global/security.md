# Security Standards

This standard documents security best practices for OAuth 2.0, BetterAuth, Next.js middleware, Server Actions, and API routes in the SEO Optimization application.

## I. OAuth 2.0 Security

### PKCE (Proof Key for Code Exchange)

BetterAuth implements PKCE by default, but understand the flow:

```typescript
// BetterAuth handles PKCE automatically
// No manual implementation needed

// lib/auth.ts
export const auth = betterAuth({
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      // PKCE is enabled by default
    },
  },
})
```

### State Parameter Validation

BetterAuth validates state parameter automatically:

```typescript
// lib/auth-client.ts
// Client-side OAuth sign-in - state is managed automatically
import { authClient } from '@/lib/auth-client'

export async function signInWithGoogle() {
  await authClient.signIn.social({
    provider: 'google',
    // BetterAuth generates and validates state automatically
  })
}
```

### Redirect URI Validation

```typescript
// lib/auth.ts
export const auth = betterAuth({
  appName: 'SEO Optimization',
  baseURL: process.env.BETTER_AUTH_URL || 'http://localhost:3000',
  // BetterAuth validates redirect URIs based on baseURL

  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      // Only allows redirects to /api/auth/callback/google under baseURL
    },
  },
})

// Environment Configuration
// .env.local
BETTER_AUTH_URL=https://yourdomain.com  // Production
// localhost:3000                         // Development

// Configure redirect URIs in OAuth provider (Google, GitHub):
// https://yourdomain.com/api/auth/callback/google
// https://yourdomain.com/api/auth/callback/github
// http://localhost:3000/api/auth/callback/google (dev only)
```

### Token Storage Security

```typescript
// lib/auth.ts
export const auth = betterAuth({
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 days
    updateAge: 60 * 60 * 24,     // Refresh daily

    cookieName: 'better-auth.session_token',
    cookieAttributes: {
      httpOnly: true,    // Not accessible from JavaScript
      sameSite: 'lax',   // CSRF protection
      secure: process.env.NODE_ENV === 'production', // HTTPS only in production
      path: '/',
    },
  },
})

// NEVER store tokens in localStorage
// localStorage is vulnerable to XSS attacks
// Use httpOnly cookies instead (BetterAuth default)
```

---

## II. BetterAuth Session Security

### Server-Side Session Validation

```typescript
import { auth } from '@/lib/auth'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  // Always validate session on server
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    )
  }

  // Check user still exists and isn't banned
  if (!session.user) {
    return NextResponse.json(
      { error: 'Invalid session' },
      { status: 401 }
    )
  }

  // Proceed with authenticated operation
  return NextResponse.json({ user: session.user })
}
```

### Session Expiration Handling

```typescript
// Components must handle session expiry
'use client'

import { useSession } from '@/lib/auth-client'
import { useEffect } from 'react'
import { useRouter } from 'next/navigation'

export function ProtectedComponent() {
  const { data: session, isPending, error } = useSession()
  const router = useRouter()

  // Redirect if session expired or missing
  useEffect(() => {
    if (!isPending && !session) {
      // Session missing - redirect to login
      router.push('/login')
    }
  }, [session, isPending, router])

  if (isPending) return <div>Loading...</div>
  if (error) {
    console.error('Session error:', error)
    return <div>Session error - please sign in again</div>
  }
  if (!session) return null // Will redirect

  return <div>Protected content for {session.user.email}</div>
}
```

### CORS Configuration for Auth Endpoints

```typescript
// lib/auth.ts
export const auth = betterAuth({
  appName: 'SEO Optimization',
  baseURL: process.env.BETTER_AUTH_URL,

  // CORS is automatically configured for baseURL
  // For cross-domain requests, configure explicitly
  // Only allow requests from trusted domains
})

// middleware.ts - Additional CORS protection
import { NextRequest, NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  // Protect auth endpoints
  if (request.nextUrl.pathname.startsWith('/api/auth')) {
    const origin = request.headers.get('origin')
    const allowedOrigins = [
      process.env.NEXT_PUBLIC_APP_URL,
      process.env.NEXT_PUBLIC_STAGING_URL,
    ].filter(Boolean)

    if (origin && !allowedOrigins.includes(origin)) {
      return NextResponse.json(
        { error: 'CORS error' },
        { status: 403 }
      )
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!_next/static|favicon.ico).*)'],
}
```

---

## III. Next.js Middleware Route Protection

### Protected Route Middleware

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@/lib/auth'

const protectedRoutes = [
  '/dashboard',
  '/projects',
  '/settings',
  '/api/projects',
  '/api/recommendations',
]

export async function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname

  // Check if route requires authentication
  if (protectedRoutes.some(route => path.startsWith(route))) {
    const session = await auth.api.getSession({
      headers: request.headers,
    })

    if (!session) {
      // Redirect to login for browser requests
      if (path.startsWith('/api')) {
        return NextResponse.json(
          { error: 'Unauthorized' },
          { status: 401 }
        )
      }

      // Preserve the originally requested URL
      const loginUrl = new URL('/login', request.url)
      loginUrl.searchParams.set('from', request.nextUrl.pathname)
      return NextResponse.redirect(loginUrl)
    }

    // Check user role if needed
    if (path.startsWith('/admin')) {
      if (session.user.role !== 'admin') {
        return NextResponse.json(
          { error: 'Forbidden - admin access required' },
          { status: 403 }
        )
      }
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
}
```

### Public vs Protected Routes

```typescript
// middleware.ts - More explicit approach
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@/lib/auth'

const publicRoutes = ['/login', '/signup', '/', '/privacy', '/terms']

export async function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname
  const isPublic = publicRoutes.includes(path)

  if (!isPublic) {
    const session = await auth.api.getSession({
      headers: request.headers,
    })

    if (!session) {
      const url = new URL('/login', request.url)
      url.searchParams.set('redirectTo', path)
      return NextResponse.redirect(url)
    }
  }

  return NextResponse.next()
}
```

---

## IV. Server Actions Security

### Authentication in Server Actions

```typescript
'use server'

import { auth } from '@/lib/auth'
import { headers } from 'next/headers'

export async function updateProjectAction(projectId: string, data: unknown) {
  // Always validate session first
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { error: 'Unauthorized' }
  }

  // Verify user owns the resource
  const project = await db.query.project.findFirst({
    where: (fields) => eq(fields.id, projectId),
  })

  if (!project) {
    return { error: 'Project not found' }
  }

  if (project.userId !== session.user.id) {
    return { error: 'Forbidden - you do not own this project' }
  }

  // Validate and process
  try {
    const validated = mySchema.parse(data)
    // Update project
    return { success: true }
  } catch (error) {
    return { error: 'Validation failed' }
  }
}
```

### CSRF Protection in Server Actions

```typescript
// Server Actions have built-in CSRF protection from Next.js
// No additional setup needed

'use client'

import { updateProjectAction } from '@/app/actions'
import { useActionState } from 'react'

export function ProjectForm() {
  // Next.js automatically includes CSRF token
  // No manual token handling required
  const [state, formAction, isPending] = useActionState(
    updateProjectAction,
    null
  )

  return (
    <form action={formAction}>
      <input name="projectId" value="123" hidden />
      <input name="name" required />
      <button disabled={isPending}>Update</button>
    </form>
  )
}
```

### Input Validation in Server Actions

```typescript
'use server'

import { z } from 'zod'

const updateProjectSchema = z.object({
  name: z.string().min(1).max(100),
  url: z.string().url(),
  description: z.string().max(500).optional(),
})

export async function updateProjectAction(
  projectId: string,
  formData: FormData
) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { error: 'Unauthorized' }
  }

  try {
    // Convert FormData to object for validation
    const data = Object.fromEntries(formData)

    // Validate against schema (see {{standards/global/validation}})
    const validated = updateProjectSchema.parse(data)

    // Verify ownership and update
    return { success: true }
  } catch (error) {
    if (error instanceof z.ZodError) {
      return {
        error: 'Validation failed',
        errors: error.flatten().fieldErrors,
      }
    }

    return { error: 'Operation failed' }
  }
}
```

---

## V. API Route Security

### Request Authentication

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@/lib/auth'

export async function GET(request: NextRequest) {
  // Validate session
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    )
  }

  if (!session.user) {
    return NextResponse.json(
      { error: 'Invalid session' },
      { status: 401 }
    )
  }

  // Proceed with authenticated request
  return NextResponse.json({ user: session.user })
}
```

### Request Validation

```typescript
import { z } from 'zod'

const querySchema = z.object({
  projectId: z.string().uuid(),
  page: z.coerce.number().positive().default(1),
})

export async function GET(request: NextRequest) {
  try {
    // Validate query parameters
    const params = querySchema.parse({
      projectId: request.nextUrl.searchParams.get('projectId'),
      page: request.nextUrl.searchParams.get('page'),
    })

    // Verify user owns project (see {{standards/global/validation}})
    // ...

    return NextResponse.json(/* results */)
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Invalid parameters' },
        { status: 400 }
      )
    }

    return NextResponse.json(
      { error: 'Server error' },
      { status: 500 }
    )
  }
}
```

### Rate Limiting

```typescript
// lib/rate-limit.ts
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

// Initialize rate limiter
const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '1 h'), // 10 requests per hour
})

// Use in API route
import { ratelimit } from '@/lib/rate-limit'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // Rate limit by user ID
  const { success } = await ratelimit.limit(session.user.id)

  if (!success) {
    return NextResponse.json(
      { error: 'Too many requests' },
      { status: 429 }
    )
  }

  // Process request
  return NextResponse.json({ success: true })
}
```

---

## VI. Environment Variable Security

### Secret Management

```bash
# .env.local (NEVER commit to git)
# Add to .gitignore

# OAuth Secrets
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

# Database
DATABASE_URL=

# BetterAuth
BETTER_AUTH_SECRET=your-random-secret-key
BETTER_AUTH_URL=https://yourdomain.com

# External Services
OPENROUTER_API_KEY=
BLOB_READ_WRITE_TOKEN=
PUSHER_APP_ID=
PUSHER_KEY=
PUSHER_SECRET=
PUSHER_CLUSTER=

# Public Environment Variables (prefixed with NEXT_PUBLIC_)
NEXT_PUBLIC_APP_URL=https://yourdomain.com
NEXT_PUBLIC_PUSHER_KEY=
NEXT_PUBLIC_PUSHER_CLUSTER=
NEXT_PUBLIC_SENTRY_DSN=
```

### Secure Secret Generation

```bash
# Generate BETTER_AUTH_SECRET
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Or use openssl
openssl rand -hex 32
```

### Vercel Deployment Secrets

```bash
# Set secrets in Vercel dashboard:
# Settings > Environment Variables

# Production secrets:
GOOGLE_CLIENT_ID=prod-id
GOOGLE_CLIENT_SECRET=prod-secret
DATABASE_URL=prod-db-url
BETTER_AUTH_SECRET=prod-secret-key
BETTER_AUTH_URL=https://yourdomain.com

# Staging can use different credentials for testing

# Never commit .env.local to git
# Add to .gitignore:
.env.local
.env.*.local
```

---

## VII. Data Protection

### Sensitive Data in Databases

```typescript
import { db } from '@/db'
import { user } from '@/db/schema'

// DO: Encrypt sensitive data
import { hash } from '@node-rs/argon2'

async function createUser(email: string, password: string) {
  const hashedPassword = await hash(password)

  const [newUser] = await db.insert(user).values({
    email,
    // Store hashed password, never plain text
    password: hashedPassword,
  }).returning()

  return newUser
}

// DON'T: Store passwords in plain text
// DON'T: Store API keys in database
```

### Vercel Blob Signed URLs

```typescript
import { put } from '@vercel/blob'

export async function uploadProjectFile(
  file: File,
  projectId: string,
  userId: string
) {
  try {
    const blob = await put(
      `projects/${projectId}/files/${file.name}`,
      file,
      {
        access: 'private', // Only owner can access
        addRandomSuffix: true,
        token: process.env.BLOB_READ_WRITE_TOKEN,
      }
    )

    // Store blob URL in database with proper permissions check
    return {
      success: true,
      url: blob.url, // This is a signed URL
    }
  } catch (error) {
    return { error: 'Upload failed' }
  }
}

// When serving:
export async function getProjectFile(projectId: string, fileId: string) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { error: 'Unauthorized' }
  }

  // Verify user owns project
  const file = await db.query.projectFile.findFirst({
    where: (fields) => eq(fields.id, fileId),
  })

  if (!file || file.projectId !== projectId) {
    return { error: 'Not found' }
  }

  // Return signed URL (Blob automatically validates access)
  return { url: file.blobUrl }
}
```

### Pusher Private Channels

```typescript
import { pusher } from '@/lib/pusher'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const { socket_id, channel_name } = await request.json()

  // Verify user can access this channel
  // Example: only allow users to access their own project channels
  const [, projectId] = channel_name.split('-')

  const project = await db.query.project.findFirst({
    where: (fields) => eq(fields.id, projectId),
  })

  if (!project || project.userId !== session.user.id) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }

  // Authenticate channel subscription
  const authResponse = pusher.authorizeChannel(socket_id, channel_name)

  return NextResponse.json(authResponse)
}
```

---

## VIII. Headers and Security Policies

### Security Headers

```typescript
// middleware.ts - Add security headers
import { NextRequest, NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  // Prevent clickjacking
  response.headers.set('X-Frame-Options', 'DENY')

  // Prevent MIME type sniffing
  response.headers.set('X-Content-Type-Options', 'nosniff')

  // Enable XSS protection
  response.headers.set('X-XSS-Protection', '1; mode=block')

  // Content Security Policy
  response.headers.set(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-inline'; connect-src 'self' *.pusher.com *.openrouter.ai"
  )

  // Referrer Policy
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')

  return response
}

export const config = {
  matcher: '/((?!_next/static|favicon.ico).*)',
}
```

### HTTPS Enforcement

```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  if (
    process.env.NODE_ENV === 'production' &&
    request.headers.get('x-forwarded-proto') !== 'https'
  ) {
    return NextResponse.redirect(
      `https://${request.headers.get('host')}${request.nextUrl.pathname}`,
      { status: 301 }
    )
  }

  return NextResponse.next()
}
```

---

## IX. Third-Party API Security

### API Key Management

```typescript
// NEVER hardcode API keys
// NEVER log API keys
// Always use environment variables

const openrouterKey = process.env.OPENROUTER_API_KEY
if (!openrouterKey) {
  throw new Error('Missing OPENROUTER_API_KEY')
}

// When making requests
export async function generateAnalysis(data: string) {
  try {
    const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        // Use env var for auth
        'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`,
      },
      body: JSON.stringify({ /* ... */ }),
    })

    return await response.json()
  } catch (error) {
    console.error('API error') // Don't log the error details
    return { error: 'Request failed' }
  }
}
```

---

## X. Best Practices Checklist

- ✅ Use httpOnly cookies for session storage
- ✅ Validate sessions on every protected request
- ✅ Verify resource ownership before access
- ✅ Use HTTPS in production
- ✅ Validate all user input (see {{standards/global/validation}})
- ✅ Use strong environment variable secrets
- ✅ Implement rate limiting for sensitive endpoints
- ✅ Add security headers to responses
- ✅ Use middleware for route protection
- ✅ Never log sensitive data (passwords, tokens)
- ✅ Use parameterized queries (Drizzle does this)
- ✅ Implement CSRF protection in forms
- ✅ Keep dependencies updated
- ✅ Monitor and log security events
- ✅ Test OAuth flows with both providers

---

## Related Standards

- {{standards/backend/auth}} - BetterAuth implementation details
- {{standards/backend/api}} - API route handlers
- {{standards/global/validation}} - Input validation
- {{standards/global/error-handling}} - Error handling and logging
