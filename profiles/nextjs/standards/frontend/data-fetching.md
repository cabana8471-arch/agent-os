# Next.js Data Fetching

## Server Component Data Fetching

The preferred approach in Next.js 13+: Fetch in Server Components, avoid useEffect.

### Basic Server Component Fetch

```typescript
// app/blog/page.tsx
export default async function BlogPage() {
  const response = await fetch('https://api.example.com/posts', {
    next: { revalidate: 3600 }, // Cache for 1 hour
  })
  const posts = await response.json()

  return (
    <div>
      {posts.map((post) => (
        <article key={post.id}>{post.title}</article>
      ))}
    </div>
  )
}
```

### Fetch with Error Handling

```typescript
export default async function BlogPage() {
  try {
    const response = await fetch('https://api.example.com/posts', {
      next: { revalidate: 3600 },
    })

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`)
    }

    const posts = await response.json()
    return <BlogList posts={posts} />
  } catch (error) {
    return <div>Failed to load posts. Please try again later.</div>
  }
}
```

## Caching Strategies

### Time-Based Revalidation (ISR)

Cache data for a set time, then revalidate:

```typescript
// Cache for 1 hour
export default async function Page() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 3600 },
  }).then((r) => r.json())

  return <div>{data}</div>
}

// No cache (always fresh)
export default async function Page() {
  const data = await fetch('https://api.example.com/data', {
    cache: 'no-store',
  }).then((r) => r.json())

  return <div>{data}</div>
}

// Cache indefinitely (until manual revalidation)
export default async function Page() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: false },
  }).then((r) => r.json())

  return <div>{data}</div>
}
```

### On-Demand Revalidation

Revalidate specific data when an event happens:

```typescript
// lib/db.ts
import { revalidatePath } from 'next/cache'

export async function updatePost(id: string, data: PostData) {
  // Update in database
  await db.post.update({ where: { id }, data })

  // Revalidate the post page
  revalidatePath(`/blog/${id}`)

  // Or revalidate all blog pages
  revalidatePath('/blog', 'layout')
}
```

### Tag-Based Revalidation

Revalidate multiple paths with a single tag:

```typescript
// app/blog/page.tsx
export default async function BlogPage() {
  const posts = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] },
  }).then((r) => r.json())

  return <BlogList posts={posts} />
}

// app/blog/[id]/page.tsx
export default async function BlogPost({ params }: { params: { id: string } }) {
  const post = await fetch(`https://api.example.com/posts/${params.id}`, {
    next: { tags: ['posts', `post-${params.id}`] },
  }).then((r) => r.json())

  return <Article post={post} />
}
```

```typescript
// app/actions.ts
"use server"

import { revalidateTag } from 'next/cache'

export async function updatePost(id: string, data: PostData) {
  await db.post.update({ where: { id }, data })
  revalidateTag('posts') // Invalidate all 'posts' tagged fetches
}
```

## Parallel Data Fetching

Fetch multiple resources concurrently:

```typescript
// ✅ Good - Parallel requests
export default async function DashboardPage() {
  const [users, posts, stats] = await Promise.all([
    fetch('/api/users').then((r) => r.json()),
    fetch('/api/posts').then((r) => r.json()),
    fetch('/api/stats').then((r) => r.json()),
  ])

  return (
    <div>
      <UserCount count={users.length} />
      <PostCount count={posts.length} />
      <Stats data={stats} />
    </div>
  )
}
```

## Sequential Data Fetching (With Suspense)

Fetch data sequentially when one depends on another:

```typescript
// ✅ Good - Sequential with Suspense for loading UI
import { Suspense } from 'react'

async function UserDetails({ userId }: { userId: string }) {
  const user = await fetch(`/api/users/${userId}`).then((r) => r.json())
  return <div>{user.name}</div>
}

async function UserPosts({ userId }: { userId: string }) {
  // This waits for UserDetails to finish
  const posts = await fetch(`/api/users/${userId}/posts`).then((r) => r.json())
  return <ul>{posts.map((p) => <li key={p.id}>{p.title}</li>)}</ul>
}

export default function UserPage({ params }: { params: { userId: string } }) {
  return (
    <div>
      <Suspense fallback={<div>Loading user...</div>}>
        <UserDetails userId={params.userId} />
      </Suspense>

      <Suspense fallback={<div>Loading posts...</div>}>
        <UserPosts userId={params.userId} />
      </Suspense>
    </div>
  )
}
```

## Client-Side Data Fetching (When Necessary)

Use in Client Components when you need real-time updates:

```typescript
"use client"

import { useEffect, useState } from 'react'
import { useSearchParams } from 'next/navigation'

export function SearchResults() {
  const searchParams = useSearchParams()
  const [results, setResults] = useState([])
  const [loading, setLoading] = useState(false)

  const query = searchParams.get('q')

  useEffect(() => {
    if (!query) return

    setLoading(true)
    fetch(`/api/search?q=${encodeURIComponent(query)}`)
      .then((r) => r.json())
      .then(setResults)
      .finally(() => setLoading(false))
  }, [query])

  if (loading) return <div>Loading...</div>
  return <div>{results.map((r) => <div key={r.id}>{r.title}</div>)}</div>
}
```

## Using TanStack Query (Advanced)

For complex client-side data management:

```typescript
"use client"

import { useQuery } from '@tanstack/react-query'

export function UserList() {
  const { data: users, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const response = await fetch('/api/users')
      if (!response.ok) throw new Error('Failed to fetch users')
      return response.json()
    },
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {users?.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

## Streaming (Progressive Rendering)

Load content progressively with Suspense boundaries:

```typescript
// app/page.tsx
import { Suspense } from 'react'
import { HeaderComponent, MainContent, SidebarContent } from '@/components'

export default function HomePage() {
  return (
    <div>
      {/* Render immediately */}
      <Suspense fallback={<HeaderSkeleton />}>
        <HeaderComponent />
      </Suspense>

      <div className="flex">
        {/* Load main content with skeleton */}
        <Suspense fallback={<MainSkeleton />}>
          <MainContent />
        </Suspense>

        {/* Load sidebar independently */}
        <Suspense fallback={<SidebarSkeleton />}>
          <SidebarContent />
        </Suspense>
      </div>
    </div>
  )
}

async function HeaderComponent() {
  const data = await fetch('...').then((r) => r.json())
  return <header>...</header>
}
```

## Database Queries in Server Components

Direct database access without API layer:

```typescript
// app/users/page.tsx
import { db } from '@/lib/db'

export default async function UsersPage() {
  const users = await db.user.findMany({
    select: { id: true, name: true, email: true },
    orderBy: { createdAt: 'desc' },
  })

  return (
    <div>
      {users.map((user) => (
        <div key={user.id}>{user.name}</div>
      ))}
    </div>
  )
}
```

## Error Handling Best Practices

```typescript
export default async function Page() {
  try {
    const data = await fetch('https://api.example.com/data', {
      next: { revalidate: 3600 },
    })

    if (!data.ok) {
      // Don't throw in render, handle in error.tsx
      return <ErrorBoundary />
    }

    const json = await data.json()
    return <SuccessComponent data={json} />
  } catch (error) {
    // This triggers nearest error.tsx
    throw error
  }
}
```

## Performance Tips

1. **Server-side fetch when possible** - Reduces client-side JavaScript
2. **Use parallel fetching** - `Promise.all()` for independent requests
3. **Cache aggressively** - Set appropriate `revalidate` times
4. **Implement Suspense** - Show UI progressively, don't wait for all data
5. **Avoid N+1 queries** - Batch database queries, use JOINs
6. **Optimize images** - Use `next/image` for automatic optimization
7. **Use CDN** - Cache static content close to users

## Related Standards

- `backend/api.md` - API route implementation
- `frontend/server-components.md` - Server Component patterns
- `frontend/streaming.md` - Suspense and streaming patterns
