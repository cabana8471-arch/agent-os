# API Standards - BetterAuth Integration

This standard documents API route patterns with BetterAuth authentication for the SEO Optimization application.

## I. Route Handler Basics

### File Structure
```
app/api/
├── auth/[...all]/route.ts      # BetterAuth handler
├── projects/
│   ├── route.ts                # GET (list), POST (create)
│   └── [id]/
│       ├── route.ts            # GET, PATCH, DELETE
│       ├── scan/route.ts       # POST scan trigger
│       └── analyze/route.ts    # POST AI analysis
├── pages/
│   ├── route.ts
│   └── [id]/route.ts
├── recommendations/route.ts    # Get recommendations
├── copilot/
│   └── chat/route.ts          # POST streaming chat
└── inngest/route.ts           # Inngest webhook
```

### Basic Route Handler

```typescript
// app/api/projects/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@/lib/auth'
import { db } from '@/db'
import { project } from '@/db/schema'
import { eq } from 'drizzle-orm'

// GET /api/projects - List user's projects
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

  const projects = await db.query.project.findMany({
    where: eq(project.userId, session.user.id),
    orderBy: (fields) => [desc(fields.createdAt)],
  })

  return NextResponse.json(projects)
}

// POST /api/projects - Create project
export async function POST(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    )
  }

  try {
    const body = await request.json()
    const { name, url, description } = body

    // Validate input
    if (!name || !url) {
      return NextResponse.json(
        { error: 'Name and URL are required' },
        { status: 400 }
      )
    }

    // Create project
    const [newProject] = await db.insert(project).values({
      id: crypto.randomUUID(),
      userId: session.user.id,
      name,
      url,
      description,
    }).returning()

    return NextResponse.json(newProject, { status: 201 })
  } catch (error) {
    console.error('Failed to create project:', error)
    return NextResponse.json(
      { error: 'Failed to create project' },
      { status: 500 }
    )
  }
}
```

---

## II. BetterAuth Integration

### BetterAuth Handler Route

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from '@/lib/auth'

// Serve BetterAuth endpoints
export const { GET, POST } = auth.handler
```

### Server-Side Auth Configuration

```typescript
// lib/auth.ts
import { betterAuth } from 'better-auth'
import { drizzleAdapter } from 'better-auth/adapters/drizzle'
import { db } from '@/db'

export const auth = betterAuth({
  database: drizzleAdapter(db, { provider: 'pg' }),

  // Basic auth methods
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

  // Session options
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 days
    updateAge: 60 * 60 * 24, // Update every day
  },
})

// Export session type for use in app
export type Session = typeof auth.$Infer.Session
```

---

## III. Protected Route Patterns

### Route Handler Protection

```typescript
// app/api/projects/[id]/route.ts
import { auth } from '@/lib/auth'
import { db } from '@/db'
import { project } from '@/db/schema'
import { eq, and } from 'drizzle-orm'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  // Get session from request headers
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  // Check authentication
  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    )
  }

  // Fetch project with ownership check
  const proj = await db.query.project.findFirst({
    where: and(
      eq(project.id, params.id),
      eq(project.userId, session.user.id)
    ),
  })

  if (!proj) {
    return NextResponse.json(
      { error: 'Not found' },
      { status: 404 }
    )
  }

  return NextResponse.json(proj)
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const body = await request.json()
    const { name, description } = body

    // Update only user's own project
    const [updated] = await db
      .update(project)
      .set({ name, description, updatedAt: new Date() })
      .where(
        and(
          eq(project.id, params.id),
          eq(project.userId, session.user.id)
        )
      )
      .returning()

    if (!updated) {
      return NextResponse.json(
        { error: 'Project not found' },
        { status: 404 }
      )
    }

    return NextResponse.json(updated)
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to update project' },
      { status: 500 }
    )
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const [deleted] = await db
      .delete(project)
      .where(
        and(
          eq(project.id, params.id),
          eq(project.userId, session.user.id)
        )
      )
      .returning()

    if (!deleted) {
      return NextResponse.json(
        { error: 'Project not found' },
        { status: 404 }
      )
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to delete project' },
      { status: 500 }
    )
  }
}
```

### Server Action Protection

```typescript
// app/actions.ts
'use server'

import { auth } from '@/lib/auth'
import { headers } from 'next/headers'
import { db } from '@/db'
import { project } from '@/db/schema'

export async function createProjectAction(formData: FormData) {
  // Get session in server action
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { error: 'Unauthorized' }
  }

  try {
    const name = formData.get('name') as string
    const url = formData.get('url') as string

    if (!name || !url) {
      return { error: 'Missing required fields' }
    }

    const [newProject] = await db.insert(project).values({
      id: crypto.randomUUID(),
      userId: session.user.id,
      name,
      url,
    }).returning()

    return { success: true, project: newProject }
  } catch (error) {
    return { error: 'Failed to create project' }
  }
}
```

---

## IV. Session Management

### Client-Side Session Hook

```typescript
// lib/auth-client.ts
import { createAuthClient } from 'better-auth/react'

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL,
})

export const { signIn, signOut, signUp, useSession } = authClient
```

### Using Session in Components

```typescript
// app/components/user-profile.tsx
'use client'

import { useSession } from '@/lib/auth-client'

export function UserProfile() {
  const { data: session, isPending } = useSession()

  if (isPending) {
    return <div>Loading...</div>
  }

  if (!session) {
    return <div>Not logged in</div>
  }

  return (
    <div>
      <h1>Welcome, {session.user.name}</h1>
      <p>{session.user.email}</p>
    </div>
  )
}
```

### Sign In / Sign Out

```typescript
// app/components/auth-buttons.tsx
'use client'

import { signIn, signOut, useSession } from '@/lib/auth-client'

export function AuthButtons() {
  const { data: session } = useSession()

  if (!session) {
    return (
      <div className="flex gap-2">
        <button
          onClick={() => signIn.social({ provider: 'google' })}
          className="px-4 py-2 bg-blue-500 text-white rounded"
        >
          Sign in with Google
        </button>
        <button
          onClick={() => signIn.social({ provider: 'github' })}
          className="px-4 py-2 bg-gray-900 text-white rounded"
        >
          Sign in with GitHub
        </button>
      </div>
    )
  }

  return (
    <button
      onClick={() => signOut()}
      className="px-4 py-2 bg-red-500 text-white rounded"
    >
      Sign out
    </button>
  )
}
```

---

## V. API Route Organization

### Scan Trigger Endpoint

```typescript
// app/api/projects/[id]/scan/route.ts
import { inngest } from '@/inngest/client'
import { auth } from '@/lib/auth'
import { db } from '@/db'
import { project, scannedPage } from '@/db/schema'
import { eq, and } from 'drizzle-orm'

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    // Verify project ownership
    const proj = await db.query.project.findFirst({
      where: and(
        eq(project.id, params.id),
        eq(project.userId, session.user.id)
      ),
    })

    if (!proj) {
      return NextResponse.json({ error: 'Not found' }, { status: 404 })
    }

    // Create scanned page record
    const [page] = await db.insert(scannedPage).values({
      id: crypto.randomUUID(),
      projectId: proj.id,
      url: proj.url,
      status: 'pending',
    }).returning()

    // Trigger Inngest job
    await inngest.send({
      name: 'page/scan.requested',
      data: {
        pageId: page.id,
        url: proj.url,
        userId: session.user.id,
      },
    })

    return NextResponse.json({ message: 'Scan queued', pageId: page.id })
  } catch (error) {
    console.error('Scan failed:', error)
    return NextResponse.json(
      { error: 'Failed to start scan' },
      { status: 500 }
    )
  }
}
```

### AI Analysis Endpoint

```typescript
// app/api/projects/[id]/analyze/route.ts
import { streamText } from 'ai'
import { openrouter } from '@/lib/ai'
import { pusher } from '@/lib/pusher'

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const body = await request.json()
    const { pageData } = body

    // Stream text to client
    const result = await streamText({
      model: openrouter('openai/gpt-5-mini'),
      messages: [
        {
          role: 'system',
          content: 'You are an SEO expert. Analyze the page and provide optimization suggestions.',
        },
        {
          role: 'user',
          content: `Analyze this page:\n\n${JSON.stringify(pageData, null, 2)}`,
        },
      ],
    })

    // Notify client via Pusher when complete
    await pusher.trigger(`page-${params.id}`, 'analysis-complete', {
      pageId: params.id,
      status: 'complete',
    })

    return result.toDataStreamResponse()
  } catch (error) {
    console.error('Analysis failed:', error)
    return NextResponse.json(
      { error: 'Analysis failed' },
      { status: 500 }
    )
  }
}
```

### Copilot Chat Streaming

```typescript
// app/api/copilot/chat/route.ts
import { streamText } from 'ai'
import { openrouter } from '@/lib/ai'

export async function POST(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const { messages } = await request.json()

    const result = await streamText({
      model: openrouter('openai/gpt-5-mini'),
      system: 'You are a helpful SEO optimization assistant.',
      messages,
    })

    return result.toDataStreamResponse()
  } catch (error) {
    console.error('Chat failed:', error)
    return NextResponse.json(
      { error: 'Chat failed' },
      { status: 500 }
    )
  }
}
```

---

## VI. Validation & Error Handling

### Zod Validation

```typescript
import { z } from 'zod'

// Define schema
const createProjectSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  url: z.string().url('Invalid URL'),
  description: z.string().optional(),
})

type CreateProjectInput = z.infer<typeof createProjectSchema>

// Use in route handler
export async function POST(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const body = await request.json()
    const data = createProjectSchema.parse(body)

    // Process validated data
    const [newProject] = await db.insert(project).values({
      ...data,
      id: crypto.randomUUID(),
      userId: session.user.id,
    }).returning()

    return NextResponse.json(newProject, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { errors: error.errors },
        { status: 400 }
      )
    }

    console.error('Server error:', error)
    return NextResponse.json(
      { error: 'Server error' },
      { status: 500 }
    )
  }
}
```

### Error Response Pattern

```typescript
// Consistent error responses
const errorResponses = {
  unauthorized: () => NextResponse.json(
    { error: 'Unauthorized' },
    { status: 401 }
  ),

  notFound: (resource: string) => NextResponse.json(
    { error: `${resource} not found` },
    { status: 404 }
  ),

  badRequest: (message: string) => NextResponse.json(
    { error: message },
    { status: 400 }
  ),

  serverError: (message = 'Server error') => NextResponse.json(
    { error: message },
    { status: 500 }
  ),
}

// Usage
if (!session) {
  return errorResponses.unauthorized()
}

if (!proj) {
  return errorResponses.notFound('Project')
}
```

---

## VII. Response Patterns

### Success Response

```typescript
// Single resource
return NextResponse.json(project)

// List of resources
return NextResponse.json({ data: projects, count: projects.length })

// Created resource
return NextResponse.json(newProject, { status: 201 })

// Deleted resource
return NextResponse.json({ success: true, deletedId: project.id })
```

### Pagination Response

```typescript
export async function GET(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const page = Number(request.nextUrl.searchParams.get('page') ?? 1)
  const pageSize = Number(request.nextUrl.searchParams.get('pageSize') ?? 10)

  const offset = (page - 1) * pageSize

  const projects = await db.query.project.findMany({
    where: eq(project.userId, session.user.id),
    limit: pageSize,
    offset,
    orderBy: [desc(project.createdAt)],
  })

  const [{ count }] = await db
    .select({ count: count() })
    .from(project)
    .where(eq(project.userId, session.user.id))

  return NextResponse.json({
    data: projects,
    pagination: {
      page,
      pageSize,
      total: count,
      pages: Math.ceil(count / pageSize),
    },
  })
}
```

---

## VIII. Environment Variables

### Required Environment Variables

```bash
# BetterAuth
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

# Database
DATABASE_URL=postgresql://user:password@host/database

# Inngest
INNGEST_EVENT_KEY=
INNGEST_SIGNING_KEY=

# Pusher
PUSHER_APP_ID=
PUSHER_KEY=
PUSHER_SECRET=
PUSHER_CLUSTER=

# OpenRouter
OPENROUTER_API_KEY=

# Vercel Blob
BLOB_READ_WRITE_TOKEN=

# Public (client-side)
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_PUSHER_KEY=
NEXT_PUBLIC_PUSHER_CLUSTER=
```

---

## Related Standards

- {{standards/backend/database}} - Using database in API routes
- {{standards/backend/auth}} - BetterAuth complete guide
- {{standards/backend/ai-integration}} - AI streaming in routes
- {{standards/backend/background-jobs}} - Triggering Inngest jobs
- {{standards/global/validation}} - Input validation with Zod
- {{standards/global/error-handling}} - Error handling patterns
