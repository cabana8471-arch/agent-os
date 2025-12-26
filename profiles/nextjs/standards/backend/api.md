# Next.js Route Handlers (API Routes)

## Overview

Route Handlers are the Next.js way to build API endpoints. They run on the server and handle HTTP requests.

**Note:** Many operations that previously required Route Handlers can now be done with Server Actions, which is often simpler.

## Basic Route Handler

File naming: `app/api/[path]/route.ts`

```typescript
// app/api/hello/route.ts
export async function GET(request: Request) {
  return Response.json({ message: 'Hello, world!' })
}

// GET /api/hello → { message: 'Hello, world!' }
```

## HTTP Methods

```typescript
// app/api/posts/route.ts
export async function GET(request: Request) {
  const posts = await db.post.findMany()
  return Response.json(posts)
}

export async function POST(request: Request) {
  const data = await request.json()
  const post = await db.post.create({ data })
  return Response.json(post, { status: 201 })
}

// app/api/posts/[id]/route.ts
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const post = await db.post.findUnique({ where: { id: params.id } })
  return post ? Response.json(post) : Response.json(null, { status: 404 })
}

export async function PATCH(
  request: Request,
  { params }: { params: { id: string } }
) {
  const data = await request.json()
  const post = await db.post.update({ where: { id: params.id }, data })
  return Response.json(post)
}

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  await db.post.delete({ where: { id: params.id } })
  return Response.json(null, { status: 204 })
}
```

## Reading Request Data

### URL Parameters

```typescript
export async function GET(
  request: Request,
  { params }: { params: { userId: string; postId: string } }
) {
  console.log(params.userId) // "123"
  console.log(params.postId) // "456"
  return Response.json({})
}

// GET /api/users/123/posts/456
```

### Query String Parameters

```typescript
export async function GET(request: Request) {
  const searchParams = request.nextUrl.searchParams
  const page = searchParams.get('page') // "1"
  const limit = searchParams.get('limit') // "10"

  return Response.json({ page, limit })
}

// GET /api/posts?page=1&limit=10
```

### Request Body (JSON)

```typescript
export async function POST(request: Request) {
  const body = await request.json()
  console.log(body) // { name: 'John', email: 'john@example.com' }

  return Response.json({ id: '123', ...body }, { status: 201 })
}
```

### Request Body (Form Data)

```typescript
export async function POST(request: Request) {
  const formData = await request.formData()
  const name = formData.get('name') // 'John'
  const file = formData.get('file') // File object

  return Response.json({ success: true })
}
```

### Headers

```typescript
export async function GET(request: Request) {
  const authHeader = request.headers.get('authorization') // "Bearer token123"
  const contentType = request.headers.get('content-type')

  return Response.json({})
}
```

## Sending Responses

### JSON Response

```typescript
export async function GET() {
  return Response.json({ status: 'ok' })
}

// Also acceptable
export async function GET() {
  return Response.json({ status: 'ok' }, { status: 200 })
}
```

### Custom Status Codes

```typescript
export async function POST(request: Request) {
  const data = await request.json()
  const created = await db.user.create({ data })

  // 201 Created
  return Response.json(created, { status: 201 })
}

export async function DELETE(request: Request) {
  // 204 No Content
  return new Response(null, { status: 204 })
}

export async function GET() {
  // 404 Not Found
  return Response.json({ error: 'Not found' }, { status: 404 })
}
```

### Custom Headers

```typescript
export async function GET() {
  return Response.json(
    { data: [] },
    {
      headers: {
        'X-Custom-Header': 'value',
        'Cache-Control': 'no-store',
      },
    }
  )
}
```

### Redirects

```typescript
import { redirect } from 'next/navigation'

export async function POST(request: Request) {
  const data = await request.json()
  const user = await db.user.create({ data })

  // Redirect after creation
  redirect(`/users/${user.id}`)
}
```

## Route Handler Configuration

Control caching and dynamic behavior:

```typescript
// Cache responses for 1 hour
export const revalidate = 3600

export async function GET() {
  const data = await fetchData()
  return Response.json(data)
}

// Disable caching for this route
export const revalidate = 0

export async function GET() {
  return Response.json({ timestamp: Date.now() })
}

// Mark route as dynamic (don't cache)
export const dynamic = 'force-dynamic'
```

## Error Handling

```typescript
export async function POST(request: Request) {
  try {
    const data = await request.json()

    if (!data.name) {
      return Response.json({ error: 'Name is required' }, { status: 400 })
    }

    const user = await db.user.create({ data })
    return Response.json(user, { status: 201 })
  } catch (error) {
    console.error('Creation failed:', error)
    return Response.json(
      { error: 'Failed to create user' },
      { status: 500 }
    )
  }
}
```

## Authentication & Authorization

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  const token = request.headers.get('authorization')

  if (!token) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/api/:path*'],
}

// Or in individual routes:
// app/api/protected/route.ts
export async function GET(request: Request) {
  const token = request.headers.get('authorization')

  if (!token) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // Verify token
  const user = await verifyToken(token)
  if (!user) {
    return Response.json({ error: 'Invalid token' }, { status: 401 })
  }

  const data = await db.user.findUnique({ where: { id: user.id } })
  return Response.json(data)
}
```

## CORS Configuration

```typescript
// app/api/cors-example/route.ts
export async function POST(request: Request) {
  const data = await request.json()
  return Response.json({ success: true }, {
    headers: {
      'Access-Control-Allow-Origin': 'https://example.com',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  })
}

export async function OPTIONS(request: Request) {
  return new Response(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': 'https://example.com',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  })
}
```

## Validation

```typescript
import { z } from 'zod'

const createUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

export async function POST(request: Request) {
  const body = await request.json()

  try {
    const data = createUserSchema.parse(body)
    const user = await db.user.create({ data })
    return Response.json(user, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return Response.json({ errors: error.errors }, { status: 400 })
    }
    return Response.json({ error: 'Server error' }, { status: 500 })
  }
}
```

## Route Grouping

Organize API routes by feature:

```
app/api/
├── auth/
│   ├── login/route.ts         → POST /api/auth/login
│   ├── logout/route.ts        → POST /api/auth/logout
│   └── refresh/route.ts       → POST /api/auth/refresh
│
├── users/
│   ├── route.ts               → GET, POST /api/users
│   └── [id]/route.ts          → GET, PATCH, DELETE /api/users/[id]
│
└── webhooks/
    ├── stripe/route.ts        → POST /api/webhooks/stripe
    └── github/route.ts        → POST /api/webhooks/github
```

## When to Use Route Handlers vs Server Actions

**Use Route Handlers for:**
- Public APIs consumed by external services
- Webhooks (Stripe, GitHub, etc.)
- Complex request processing
- Custom CORS/headers requirements

**Use Server Actions for:**
- Form submissions
- Mutations within your own app
- Simple CRUD operations
- When you can avoid API layer

## Related Standards

- {{standards/backend/server-actions}} - Alternative to Route Handlers for forms
- {{standards/global/environment}} - Environment variables in API
- {{standards/frontend/data-fetching}} - Fetching from these routes
