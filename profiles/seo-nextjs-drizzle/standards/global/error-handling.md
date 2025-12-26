# Error Handling Standards

This standard documents error handling patterns for Next.js App Router, Drizzle ORM, BetterAuth, Inngest, and external APIs in the SEO Optimization application.

## I. Next.js Error Boundaries

### App Router Error Pages

```typescript
// app/error.tsx - Segment-level error boundary
'use client'

import { useEffect } from 'react'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log error to monitoring service
    console.error('Segment error:', error)
  }, [error])

  return (
    <div className="flex flex-col items-center justify-center min-h-screen gap-4">
      <h1 className="text-2xl font-bold">Something went wrong</h1>
      <p className="text-gray-600">{error.message}</p>
      <button
        onClick={() => reset()}
        className="px-4 py-2 bg-blue-500 text-white rounded"
      >
        Try again
      </button>
    </div>
  )
}
```

### Global Error Handler

```typescript
// app/global-error.tsx - Catches all unhandled errors
'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <div className="flex flex-col items-center justify-center min-h-screen gap-4">
          <h1 className="text-3xl font-bold">Critical Error</h1>
          <p className="text-gray-600">
            An unexpected error occurred. Our team has been notified.
          </p>
          <p className="text-sm text-gray-400">Error ID: {error.digest}</p>
          <button
            onClick={() => reset()}
            className="px-4 py-2 bg-blue-500 text-white rounded"
          >
            Reload page
          </button>
        </div>
      </body>
    </html>
  )
}
```

### Not Found Handler

```typescript
// app/not-found.tsx
import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen gap-4">
      <h1 className="text-3xl font-bold">404 Not Found</h1>
      <p className="text-gray-600">The page you are looking for does not exist</p>
      <Link href="/" className="px-4 py-2 bg-blue-500 text-white rounded">
        Return home
      </Link>
    </div>
  )
}
```

---

## II. Database Error Handling (Drizzle + PostgreSQL)

### PostgreSQL Error Codes

```typescript
import { db } from '@/db'
import { user } from '@/db/schema'

// PostgreSQL error code constants
const PG_ERROR_CODES = {
  UNIQUE_VIOLATION: '23505',
  FOREIGN_KEY_VIOLATION: '23503',
  NOT_NULL_VIOLATION: '23502',
  CHECK_VIOLATION: '23514',
  INVALID_TEXT_REPRESENTATION: '22P02',
  DUPLICATE_SCHEMA: '42P06',
  UNDEFINED_TABLE: '42P01',
} as const

type PostgresError = Error & {
  code?: string
  detail?: string
  constraint?: string
}

// Handle database errors
async function createUser(email: string, name: string) {
  try {
    const [newUser] = await db.insert(user).values({
      id: crypto.randomUUID(),
      email,
      name,
    }).returning()

    return { success: true, user: newUser }
  } catch (error) {
    const pgError = error as PostgresError

    switch (pgError.code) {
      case PG_ERROR_CODES.UNIQUE_VIOLATION:
        return {
          success: false,
          error: 'Email already exists',
          userMessage: 'An account with this email already exists. Please use a different email.',
        }

      case PG_ERROR_CODES.NOT_NULL_VIOLATION:
        return {
          success: false,
          error: 'Missing required field',
          userMessage: 'Please provide all required information.',
        }

      case PG_ERROR_CODES.FOREIGN_KEY_VIOLATION:
        return {
          success: false,
          error: 'Referenced record not found',
          userMessage: 'The referenced record no longer exists.',
        }

      default:
        console.error('Unhandled database error:', pgError)
        return {
          success: false,
          error: 'Database operation failed',
          userMessage: 'An unexpected error occurred. Please try again.',
        }
    }
  }
}
```

### Transaction Error Handling

```typescript
import { db } from '@/db'

async function complexDatabaseOperation() {
  try {
    await db.transaction(async (tx) => {
      // Multiple operations in transaction
      const [newProject] = await tx.insert(project).values({
        // ...
      }).returning()

      await tx.insert(projectSettings).values({
        projectId: newProject.id,
        // ...
      })

      // Transaction automatically commits if no errors
    })

    return { success: true }
  } catch (error) {
    // Entire transaction is automatically rolled back
    console.error('Transaction failed, rolled back:', error)
    return {
      success: false,
      error: 'Operation failed. All changes have been reverted.',
    }
  }
}
```

### Connection and Timeout Errors

```typescript
import { db } from '@/db'

async function queryWithTimeout() {
  try {
    const results = await Promise.race([
      db.select().from(project),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('Query timeout')), 5000)
      ),
    ])

    return results
  } catch (error) {
    if (error instanceof Error && error.message === 'Query timeout') {
      console.error('Database query timeout after 5s')
      return {
        success: false,
        error: 'Database request timed out',
        userMessage: 'The request took too long. Please try again.',
      }
    }

    console.error('Unexpected query error:', error)
    return {
      success: false,
      error: 'Database query failed',
    }
  }
}
```

---

## III. API Route Error Handling

### Basic Error Response Pattern

```typescript
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  try {
    // Validate request
    const id = request.nextUrl.searchParams.get('id')
    if (!id) {
      return NextResponse.json(
        { error: 'Missing required parameter: id' },
        { status: 400 }
      )
    }

    // Process request
    const data = await fetchData(id)

    if (!data) {
      return NextResponse.json(
        { error: 'Resource not found' },
        { status: 404 }
      )
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('API error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

### Structured Error Responses

```typescript
interface ErrorResponse {
  error: string
  code: string
  details?: Record<string, unknown>
  timestamp: string
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    if (!body.name) {
      return NextResponse.json<ErrorResponse>(
        {
          error: 'Validation failed',
          code: 'VALIDATION_ERROR',
          details: { missingFields: ['name'] },
          timestamp: new Date().toISOString(),
        },
        { status: 400 }
      )
    }

    // Process...
    return NextResponse.json({ success: true })
  } catch (error) {
    if (error instanceof SyntaxError) {
      return NextResponse.json<ErrorResponse>(
        {
          error: 'Invalid JSON',
          code: 'INVALID_JSON',
          timestamp: new Date().toISOString(),
        },
        { status: 400 }
      )
    }

    console.error('Unhandled error:', error)
    return NextResponse.json<ErrorResponse>(
      {
        error: 'Internal server error',
        code: 'INTERNAL_ERROR',
        timestamp: new Date().toISOString(),
      },
      { status: 500 }
    )
  }
}
```

---

## IV. BetterAuth Error Handling

### Session Validation Errors

```typescript
import { auth } from '@/lib/auth'

export async function GET(request: NextRequest) {
  try {
    const session = await auth.api.getSession({
      headers: request.headers,
    })

    if (!session) {
      return NextResponse.json(
        { error: 'Unauthorized - no active session' },
        { status: 401 }
      )
    }

    if (!session.user) {
      return NextResponse.json(
        { error: 'Invalid session - missing user' },
        { status: 401 }
      )
    }

    // Use session
    return NextResponse.json({ user: session.user })
  } catch (error) {
    console.error('Session error:', error)
    return NextResponse.json(
      { error: 'Failed to verify session' },
      { status: 401 }
    )
  }
}
```

### OAuth Error Handling

```typescript
import { auth } from '@/lib/auth'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { code, provider } = body

    if (!code || !provider) {
      return NextResponse.json(
        { error: 'Missing OAuth parameters' },
        { status: 400 }
      )
    }

    try {
      const session = await auth.api.signInWithOAuth({
        provider,
        code,
        redirectURL: process.env.NEXT_PUBLIC_APP_URL,
      })

      return NextResponse.json(session)
    } catch (oauthError) {
      console.error('OAuth error:', oauthError)

      if (oauthError instanceof Error) {
        if (oauthError.message.includes('invalid_code')) {
          return NextResponse.json(
            { error: 'Invalid OAuth code - please try signing in again' },
            { status: 400 }
          )
        }

        if (oauthError.message.includes('invalid_grant')) {
          return NextResponse.json(
            { error: 'OAuth token expired - please try signing in again' },
            { status: 400 }
          )
        }
      }

      return NextResponse.json(
        { error: 'OAuth authentication failed' },
        { status: 500 }
      )
    }
  } catch (error) {
    console.error('Endpoint error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

### Sign Out Error Handling

```typescript
export async function POST(request: NextRequest) {
  try {
    const session = await auth.api.getSession({
      headers: request.headers,
    })

    if (!session) {
      return NextResponse.json(
        { error: 'Not signed in' },
        { status: 400 }
      )
    }

    await auth.api.signOut({
      headers: request.headers,
    })

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Sign out error:', error)
    return NextResponse.json(
      { error: 'Failed to sign out' },
      { status: 500 }
    )
  }
}
```

---

## V. Server Action Error Handling

### Action Result Pattern

```typescript
'use server'

export type ActionResult<T> =
  | { success: true; data: T }
  | {
      success: false
      error: string
      code?: string
      errors?: Record<string, string[]>
    }

export async function exampleAction(
  input: unknown
): Promise<ActionResult<{ id: string }>> {
  try {
    // Validate auth
    const session = await auth.api.getSession({
      headers: await headers(),
    })

    if (!session) {
      return {
        success: false,
        error: 'Unauthorized',
        code: 'UNAUTHORIZED',
      }
    }

    // Validate input (see {{standards/global/validation}})
    const validation = mySchema.safeParse(input)
    if (!validation.success) {
      return {
        success: false,
        error: 'Validation failed',
        code: 'VALIDATION_ERROR',
        errors: validation.error.flatten().fieldErrors as Record<
          string,
          string[]
        >,
      }
    }

    // Process action
    const result = await performOperation(validation.data)

    return {
      success: true,
      data: result,
    }
  } catch (error) {
    console.error('Action error:', error)

    if (error instanceof Error) {
      if (error.message.includes('unique')) {
        return {
          success: false,
          error: 'Resource already exists',
          code: 'ALREADY_EXISTS',
        }
      }
    }

    return {
      success: false,
      error: 'Action failed',
      code: 'INTERNAL_ERROR',
    }
  }
}
```

### Streaming Error Handling

```typescript
'use server'

import { createStreamableValue } from 'ai/rsc'

export async function streamingAction() {
  const stream = createStreamableValue('')

  ;(async () => {
    try {
      const session = await auth.api.getSession({
        headers: await headers(),
      })

      if (!session) {
        stream.error('Unauthorized')
        return
      }

      const { textStream } = await streamText({
        model: openrouter('openai/gpt-5-mini'),
        messages: [{ role: 'user', content: 'Generate response' }],
      })

      for await (const chunk of textStream) {
        stream.update(chunk)
      }

      stream.done()
    } catch (error) {
      console.error('Streaming error:', error)
      stream.error(
        error instanceof Error ? error.message : 'Stream processing failed'
      )
    }
  })()

  return stream.value
}
```

---

## VI. Background Job Error Handling (Inngest)

### Inngest Error Handling with Retries

```typescript
import { inngest } from '@/inngest/client'
import { log } from '@/lib/logging'

export const processProjectScan = inngest.createFunction(
  {
    id: 'process-project-scan',
    retries: 3, // Retry up to 3 times
    timeout: '30m',
  },
  { event: 'project/scan.requested' },
  async ({ event, step }) => {
    try {
      const scanResult = await step.run('scan-pages', async () => {
        try {
          return await scanProjectPages(event.data.projectId)
        } catch (error) {
          log.error('Scan failed', { projectId: event.data.projectId, error })
          throw error
        }
      })

      // Process results
      await step.run('analyze-results', async () => {
        return await analyzeResults(scanResult)
      })

      return { success: true }
    } catch (error) {
      // Log final failure after all retries exhausted
      await step.run('log-final-failure', async () => {
        console.error('Scan job failed permanently:', error)
        // Send failure notification to user
        await notifyUserOfFailure(event.data.userId, event.data.projectId)
      })

      throw error
    }
  }
)
```

### Step Error Handling with Retry Strategy

```typescript
export const analyzePageWithRetry = inngest.createFunction(
  {
    id: 'analyze-page-retry',
    retries: 5,
    timeout: '10m',
  },
  { event: 'page/analyze.requested' },
  async ({ event, step }) => {
    let lastError: Error | null = null

    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        return await step.run(`analyze-attempt-${attempt}`, async () => {
          const response = await analyzePageWithAI(event.data.pageId)
          return response
        })
      } catch (error) {
        lastError = error as Error
        console.warn(`Analysis attempt ${attempt} failed:`, error)

        if (attempt < 3) {
          // Wait before retry (exponential backoff)
          await step.sleep(`backoff-${attempt}`, 1000 * Math.pow(2, attempt))
        }
      }
    }

    throw new Error(
      `Page analysis failed after 3 attempts: ${lastError?.message}`
    )
  }
)
```

### Job Failure Notifications

```typescript
export const jobWithErrorNotification = inngest.createFunction(
  {
    id: 'job-with-notifications',
  },
  { event: 'project/scan.requested' },
  async ({ event, step }) => {
    try {
      return await step.run('main-task', async () => {
        // Main operation
      })
    } catch (error) {
      // Notify user of failure
      await step.run('notify-failure', async () => {
        const session = await db.query.user.findFirst({
          where: (fields) => eq(fields.id, event.data.userId),
        })

        if (session) {
          await sendNotification({
            userId: event.data.userId,
            title: 'Scan Failed',
            message: 'The project scan could not be completed. Please try again.',
            type: 'error',
          })
        }
      })

      throw error
    }
  }
)
```

---

## VII. External API Error Handling

### OpenRouter AI Errors

```typescript
'use server'

import { streamText } from 'ai'
import { openrouter } from '@/lib/ai'

export async function generateAnalysis(data: string) {
  try {
    const { textStream } = await streamText({
      model: openrouter('openai/gpt-5-mini'),
      messages: [
        {
          role: 'user',
          content: `Analyze: ${data}`,
        },
      ],
    })

    return { stream: textStream }
  } catch (error) {
    console.error('AI generation error:', error)

    if (error instanceof Error) {
      if (error.message.includes('429')) {
        return {
          error: 'Rate limited - please try again in a few minutes',
          code: 'RATE_LIMITED',
        }
      }

      if (error.message.includes('authentication')) {
        return {
          error: 'AI service authentication failed',
          code: 'AUTH_ERROR',
        }
      }

      if (error.message.includes('timeout')) {
        return {
          error: 'AI service timed out - please try again',
          code: 'TIMEOUT',
        }
      }
    }

    return {
      error: 'Failed to generate analysis',
      code: 'GENERATION_ERROR',
    }
  }
}
```

### Vercel Blob Upload Errors

```typescript
import { put } from '@vercel/blob'

export async function uploadFile(
  file: File,
  userId: string
): Promise<{ url: string } | { error: string }> {
  try {
    const blob = await put(`uploads/${userId}/${file.name}`, file, {
      access: 'private',
      token: process.env.BLOB_READ_WRITE_TOKEN,
    })

    return { url: blob.url }
  } catch (error) {
    console.error('Upload error:', error)

    if (error instanceof Error) {
      if (error.message.includes('413')) {
        return { error: 'File too large' }
      }

      if (error.message.includes('401')) {
        return { error: 'Upload authentication failed' }
      }
    }

    return { error: 'File upload failed' }
  }
}
```

### Pusher Connection Errors

```typescript
import { pusher } from '@/lib/pusher'

export async function broadcastUpdate(channel: string, data: unknown) {
  try {
    await pusher.trigger(channel, 'update', data)
    return { success: true }
  } catch (error) {
    console.error('Pusher error:', error)

    if (error instanceof Error) {
      if (error.message.includes('Invalid channel')) {
        return { error: 'Channel configuration error' }
      }

      if (error.message.includes('authentication')) {
        return { error: 'Pusher authentication failed' }
      }
    }

    return { error: 'Failed to broadcast update' }
  }
}
```

---

## VIII. Error Logging and Monitoring

### Logging Errors

```typescript
// lib/logging.ts
export const log = {
  error: (message: string, context?: Record<string, unknown>) => {
    console.error(message, context)
    // Send to monitoring service (Sentry, etc.)
  },

  warn: (message: string, context?: Record<string, unknown>) => {
    console.warn(message, context)
  },

  info: (message: string, context?: Record<string, unknown>) => {
    console.log(message, context)
  },
}

// Usage
try {
  // operation
} catch (error) {
  log.error('Operation failed', {
    operation: 'createProject',
    userId: session.user.id,
    error: error instanceof Error ? error.message : 'Unknown error',
  })
}
```

### Error Monitoring Service Integration

```typescript
// lib/sentry.ts
import * as Sentry from '@sentry/nextjs'

export function initSentry() {
  Sentry.init({
    dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
    environment: process.env.NODE_ENV,
    beforeSend(event) {
      // Filter out non-production errors
      if (process.env.NODE_ENV !== 'production') {
        return null
      }
      return event
    },
  })
}

// Capture errors
try {
  // operation
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      component: 'ProjectForm',
      action: 'create',
    },
  })
}
```

---

## IX. Best Practices

1. **Always try-catch async operations** - Database, API, external service calls
2. **Provide user-friendly error messages** - Never expose internal details
3. **Log errors with context** - Include user ID, operation, relevant state
4. **Distinguish error types** - Validation, auth, server, external API
5. **Use structured error responses** - Consistent format across API
6. **Implement error recovery** - Retry logic, fallbacks where appropriate
7. **Validate input at boundaries** - See {{standards/global/validation}}
8. **Handle async errors in Server Actions** - Return ActionResult type
9. **Monitor production errors** - Use Sentry or similar service
10. **Test error scenarios** - Include error cases in test suite

---

## Related Standards

- {{standards/global/validation}} - Input validation to prevent errors
- {{standards/backend/api}} - API error response patterns
- {{standards/backend/database}} - Database operation error handling
- {{standards/backend/auth}} - Authentication error scenarios
- {{standards/backend/background-jobs}} - Inngest job error handling
