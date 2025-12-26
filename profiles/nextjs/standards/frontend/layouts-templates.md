# Next.js Layouts & Templates

## Layouts (Persistent UI)

Layouts are persistent across navigation and don't re-render. Use for UI that stays constant:

### Root Layout (Required)

Every app needs one root layout:

```typescript
// app/layout.tsx
import type { Metadata } from 'next'
import '@/styles/globals.css'

export const metadata: Metadata = {
  title: 'My App',
  description: 'Welcome to my app',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <Header />
        {children}
        <Footer />
      </body>
    </html>
  )
}
```

### Nested Layouts

Layouts can be nested for sections:

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="dashboard">
      <Sidebar />
      <main>{children}</main>
    </div>
  )
}

// /dashboard and /dashboard/settings share this layout
```

### Layout Composition

```typescript
// app/layout.tsx
import { Provider } from '@/lib/provider'
import { ThemeProvider } from '@/lib/theme'
import { SessionProvider } from '@/lib/session'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <Provider>
          <SessionProvider>
            <ThemeProvider>
              {children}
            </ThemeProvider>
          </SessionProvider>
        </Provider>
      </body>
    </html>
  )
}
```

### Dynamic Layouts Based on Segment

```typescript
// app/layout.tsx
import { usePathname } from 'next/navigation'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const pathname = usePathname()
  const isAuthPage = pathname.startsWith('/login') || pathname.startsWith('/signup')

  return (
    <html>
      <body>
        {isAuthPage ? (
          <AuthLayout>{children}</AuthLayout>
        ) : (
          <MainLayout>{children}</MainLayout>
        )}
      </body>
    </html>
  )
}
```

## Templates (Re-render on Navigation)

Templates are like layouts but re-render on every navigation. Use for animations or state reset:

```typescript
// app/template.tsx
'use client'

import { motion } from 'framer-motion'

export default function Template({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
    >
      {children}
    </motion.div>
  )
}

// Page transitions with Framer Motion
```

### When to Use Templates

- **Page transitions/animations** - Re-animate each page load
- **State reset on navigation** - Always start fresh
- **Per-page effects** - Run useEffect for each page

```typescript
// app/search/template.tsx
'use client'

import { useEffect, useState } from 'react'

export default function SearchTemplate({
  children,
}: {
  children: React.ReactNode
}) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    // This runs every time you navigate to /search
    setMounted(true)
  }, [])

  if (!mounted) return null

  return <div>{children}</div>
}
```

## Layout vs Template

| Aspect | Layout | Template |
|--------|--------|----------|
| **Persistence** | Stays mounted across navigation | Remounts on each navigation |
| **State** | Persists across routes | Resets on navigation |
| **Re-render** | Only on prop change | On every navigation |
| **Use Case** | Headers, sidebars, navigation | Animations, state reset |
| **Performance** | Better (less re-renders) | Lower (more re-renders) |

## Loading UI with Suspense

Show loading state while data fetches:

```typescript
// app/dashboard/loading.tsx
export default function Loading() {
  return <div>Loading dashboard...</div>
}

// Automatically shown while /dashboard fetches data
```

More granular with Suspense boundaries:

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { DashboardStats, UsersList } from '@/components/dashboard'

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>

      <Suspense fallback={<div>Loading stats...</div>}>
        <DashboardStats />
      </Suspense>

      <Suspense fallback={<div>Loading users...</div>}>
        <UsersList />
      </Suspense>
    </div>
  )
}
```

## Error Handling

### Error Boundary

```typescript
// app/error.tsx
'use client'

import { useEffect } from 'react'

interface ErrorProps {
  error: Error & { digest?: string }
  reset: () => void
}

export default function Error({ error, reset }: ErrorProps) {
  useEffect(() => {
    console.error('Error caught:', error)
  }, [error])

  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

### Nested Error Boundaries

```typescript
// app/dashboard/error.tsx
'use client'

export default function DashboardError({
  error,
  reset,
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div>
      <h2>Dashboard Error</h2>
      <p>Something went wrong in the dashboard section.</p>
      <button onClick={reset}>Try again</button>
    </div>
  )
}

// Catches errors only in /dashboard and nested routes
```

### Root Error Boundary

```typescript
// app/global-error.tsx
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
        <h1>Critical Error</h1>
        <p>{error.message}</p>
        <button onClick={() => reset()}>Reset</button>
      </body>
    </html>
  )
}

// Catches errors in root layout or other critical places
```

## Not Found Pages

### Route-Specific Not Found

```typescript
// app/posts/[slug]/page.tsx
import { notFound } from 'next/navigation'

export default async function PostPage({ params }: { params: { slug: string } }) {
  const post = await fetchPost(params.slug)

  if (!post) {
    notFound()
  }

  return <Article post={post} />
}

// Will show app/not-found.tsx or nearest parent not-found.tsx
```

### Custom Not Found Page

```typescript
// app/not-found.tsx
import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-4xl font-bold">404</h1>
      <p className="text-lg text-gray-600">Page not found</p>
      <Link href="/" className="mt-4 text-blue-600">
        Go back home
      </Link>
    </div>
  )
}
```

### Nested Not Found

```typescript
// app/blog/not-found.tsx
export default function BlogNotFound() {
  return (
    <div>
      <h2>Blog post not found</h2>
      <p>The blog post you're looking for doesn't exist.</p>
    </div>
  )
}

// Only applies to /blog and /blog/* routes
```

## Special Layout Files

### Root Layout (Required)

```typescript
// app/layout.tsx
export const metadata = { title: 'My App' }

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html><body>{children}</body></html>
}
```

### Segment Layouts

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return <div className="dashboard">{children}</div>
}
```

### Loading UI

```typescript
// app/loading.tsx or app/section/loading.tsx
export default function Loading() {
  return <Skeleton />
}
```

### Error UI

```typescript
// app/error.tsx or app/section/error.tsx
'use client'

export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return <div>Error: {error.message}</div>
}
```

### Not Found UI

```typescript
// app/not-found.tsx or app/section/not-found.tsx
export default function NotFound() {
  return <h2>Not Found</h2>
}
```

## Layout Best Practices

1. **Root layout contains HTML** - Only one `<html>` tag
2. **Use layouts for persistent UI** - Headers, sidebars, navigation
3. **Use templates for animations** - Page transitions, effects
4. **Minimize layout complexity** - Keep layouts simple and fast
5. **Avoid passing children as props** - Use layout composition instead
6. **Use Suspense for async data** - Show loading states progressively
7. **Implement error boundaries** - Handle errors gracefully
8. **Keep metadata in layouts** - Shared SEO settings

## Layout Hierarchy Example

```
app/
├── layout.tsx (Root - HTML, Global styles, Providers)
├── loading.tsx (Loading for entire app)
├── error.tsx (Error boundary for entire app)
├── page.tsx (Home page /)
│
├── (marketing)/
│   ├── layout.tsx (Marketing layout - header, footer)
│   ├── page.tsx (/)
│   ├── about/page.tsx (/about)
│   └── pricing/page.tsx (/pricing)
│
├── (dashboard)/
│   ├── layout.tsx (Dashboard layout - sidebar, top nav)
│   ├── page.tsx (/dashboard)
│   ├── loading.tsx (Dashboard loading state)
│   ├── error.tsx (Dashboard error boundary)
│   ├── analytics/
│   │   └── page.tsx (/dashboard/analytics)
│   └── settings/
│       └── page.tsx (/dashboard/settings)
│
└── api/
    ├── users/route.ts (/api/users)
    └── posts/route.ts (/api/posts)
```

## Related Standards

- {{standards/frontend/server-components}} - Components in layouts
- {{standards/frontend/data-fetching}} - Fetching in layouts
- {{standards/global/project-structure}} - File organization
