# Next.js Navigation & Routing

## Overview

Navigation in Next.js App Router uses:
- **`next/link`** - Client-side navigation (recommended)
- **`useRouter`** hook - Programmatic navigation
- **`usePathname`** hook - Get current path
- **`useSearchParams`** hook - Get query parameters

All hooks require `"use client"`.

## Link Component

The recommended way to navigate between routes:

### Basic Usage

```typescript
// app/page.tsx
import Link from 'next/link'

export default function HomePage() {
  return (
    <nav>
      <Link href="/">Home</Link>
      <Link href="/about">About</Link>
      <Link href="/blog">Blog</Link>
    </nav>
  )
}
```

### With Dynamic Routes

```typescript
import Link from 'next/link'

export default function UserList({ users }: { users: User[] }) {
  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>
          <Link href={`/users/${user.id}`}>
            {user.name}
          </Link>
        </li>
      ))}
    </ul>
  )
}
```

### With Query Parameters

```typescript
import Link from 'next/link'

export default function SearchPage() {
  return (
    <div>
      <Link href="/products?category=electronics&sort=price">
        Electronics (sorted by price)
      </Link>

      <Link href="/products?category=books&sort=rating">
        Books (sorted by rating)
      </Link>
    </div>
  )
}
```

### Link Component Props

```typescript
import Link from 'next/link'

export default function Example() {
  return (
    <>
      {/* Basic */}
      <Link href="/about">About</Link>

      {/* With className */}
      <Link href="/products" className="btn btn-primary">
        Shop Products
      </Link>

      {/* With children as function (for conditional rendering) */}
      <Link href="/dashboard">
        {({ isActive }) => (
          <span className={isActive ? 'active' : ''}>Dashboard</span>
        )}
      </Link>

      {/* Scroll to top (default: true) */}
      <Link href="/page" scroll={false}>
        No scroll to top
      </Link>

      {/* Prefetch (default: true for pages, false for dynamic routes) */}
      <Link href="/slow-page" prefetch={false}>
        Slow page (no prefetch)
      </Link>

      {/* Replace history instead of push */}
      <Link href="/login" replace>
        Go to login
      </Link>
    </>
  )
}
```

## useRouter Hook

Programmatic navigation in Client Components:

### Basic Navigation

```typescript
"use client"

import { useRouter } from 'next/navigation'

export function LoginForm() {
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    // Handle login...
    router.push('/dashboard')
  }

  return (
    <form onSubmit={handleSubmit}>
      {/* form fields */}
    </form>
  )
}
```

### Navigation Methods

```typescript
"use client"

import { useRouter } from 'next/navigation'

export function NavigationButtons() {
  const router = useRouter()

  return (
    <div>
      {/* Push new entry to history stack */}
      <button onClick={() => router.push('/about')}>
        Go to About
      </button>

      {/* Replace current history entry */}
      <button onClick={() => router.replace('/login')}>
        Replace with Login
      </button>

      {/* Go back in history */}
      <button onClick={() => router.back()}>
        Go Back
      </button>

      {/* Go forward in history */}
      <button onClick={() => router.forward()}>
        Go Forward
      </button>

      {/* Refresh current page */}
      <button onClick={() => router.refresh()}>
        Refresh
      </button>

      {/* Navigate with prefix */}
      <button onClick={() => router.prefetch('/slow-page')}>
        Prefetch Slow Page
      </button>
    </div>
  )
}
```

### Redirects After Server Action

```typescript
"use client"

import { useRouter } from 'next/navigation'
import { updateUser } from '@/app/actions'

export function UserForm({ user }: { user: User }) {
  const router = useRouter()

  const handleSubmit = async (formData: FormData) => {
    const result = await updateUser(formData)
    if (result.success) {
      router.push(`/users/${result.id}`)
    }
  }

  return (
    <form action={handleSubmit}>
      {/* form fields */}
    </form>
  )
}
```

## usePathname Hook

Get the current path:

```typescript
"use client"

import { usePathname } from 'next/navigation'

export function Navigation() {
  const pathname = usePathname()

  return (
    <nav>
      <Link
        href="/"
        className={pathname === '/' ? 'active' : ''}
      >
        Home
      </Link>
      <Link
        href="/about"
        className={pathname === '/about' ? 'active' : ''}
      >
        About
      </Link>
      <Link
        href="/blog"
        className={pathname.startsWith('/blog') ? 'active' : ''}
      >
        Blog
      </Link>
    </nav>
  )
}
```

### Detecting Nested Routes

```typescript
"use client"

import { usePathname } from 'next/navigation'

export function Header() {
  const pathname = usePathname()
  const isAdminSection = pathname.startsWith('/admin')
  const isDashboard = pathname.startsWith('/dashboard')

  return (
    <header>
      {isAdminSection && <AdminHeader />}
      {isDashboard && <DashboardHeader />}
      {!isAdminSection && !isDashboard && <PublicHeader />}
    </header>
  )
}
```

## useSearchParams Hook

Access and use URL query parameters:

```typescript
"use client"

import { useSearchParams } from 'next/navigation'

export function SearchResults() {
  const searchParams = useSearchParams()
  const query = searchParams.get('q')
  const page = searchParams.get('page') || '1'
  const category = searchParams.get('category')

  return (
    <div>
      <h1>Search Results for: {query}</h1>
      <p>Page: {page}</p>
      {category && <p>Category: {category}</p>}
    </div>
  )
}

// Usage: /search?q=laptop&page=2&category=electronics
```

### Creating Query String URLs

```typescript
"use client"

import { useRouter } from 'next/navigation'

export function FilterProducts() {
  const router = useRouter()

  const handleFilterChange = (category: string) => {
    const params = new URLSearchParams()
    params.set('category', category)
    params.set('page', '1') // Reset to page 1 on filter change
    router.push(`/products?${params.toString()}`)
  }

  return (
    <div>
      <button onClick={() => handleFilterChange('electronics')}>
        Electronics
      </button>
      <button onClick={() => handleFilterChange('books')}>
        Books
      </button>
    </div>
  )
}
```

### Updating Search Params with useTransition

```typescript
"use client"

import { useRouter, useSearchParams } from 'next/navigation'
import { useTransition } from 'react'

export function Pagination({ totalPages }: { totalPages: number }) {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [isPending, startTransition] = useTransition()

  const currentPage = Number(searchParams.get('page')) || 1

  const goToPage = (page: number) => {
    startTransition(() => {
      const params = new URLSearchParams(searchParams)
      params.set('page', String(page))
      router.push(`?${params.toString()}`)
    })
  }

  return (
    <div>
      {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
        <button
          key={page}
          onClick={() => goToPage(page)}
          disabled={isPending || page === currentPage}
          className={page === currentPage ? 'active' : ''}
        >
          {page}
        </button>
      ))}
    </div>
  )
}
```

## Scroll Behavior

Control scroll on navigation:

```typescript
// app/layout.tsx
import { ScrollProvider } from '@/components/scroll-provider'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <ScrollProvider>{children}</ScrollProvider>
      </body>
    </html>
  )
}
```

```typescript
// components/scroll-provider.tsx
"use client"

import { usePathname } from 'next/navigation'
import { useEffect } from 'react'

export function ScrollProvider({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()

  useEffect(() => {
    // Scroll to top on route change
    window.scrollTo(0, 0)
  }, [pathname])

  return <>{children}</>
}
```

## Router.refresh()

Refresh Server Component data without full page reload:

```typescript
"use client"

import { useRouter } from 'next/navigation'

export function RefreshButton() {
  const router = useRouter()

  return (
    <button onClick={() => router.refresh()}>
      Refresh Data
    </button>
  )
}
```

Use when you have a Server Component that fetches data and you want to revalidate it:

```typescript
// app/posts/page.tsx
import { RefreshButton } from '@/components/refresh-button'
import { fetchPosts } from '@/lib/db'

export default async function PostsPage() {
  const posts = await fetchPosts()

  return (
    <div>
      <RefreshButton />
      {posts.map((post) => (
        <article key={post.id}>{post.title}</article>
      ))}
    </div>
  )
}
```

## Redirects (Server-Side)

Use in Server Components or Route Handlers:

```typescript
// app/old-page/page.tsx
import { redirect } from 'next/navigation'

export default function OldPage() {
  redirect('/new-page')
}
```

```typescript
// app/api/deprecated/route.ts
import { redirect } from 'next/navigation'

export async function GET() {
  redirect('/api/v2/endpoint')
}
```

### Conditional Redirects

```typescript
// app/dashboard/page.tsx
import { redirect } from 'next/navigation'
import { getSession } from '@/lib/auth'

export default async function DashboardPage() {
  const session = await getSession()

  if (!session) {
    redirect('/login')
  }

  return <Dashboard session={session} />
}
```

## notFound()

Render a 404 page:

```typescript
// app/posts/[slug]/page.tsx
import { notFound } from 'next/navigation'
import { fetchPost } from '@/lib/db'

export default async function PostPage({ params }: { params: { slug: string } }) {
  const post = await fetchPost(params.slug)

  if (!post) {
    notFound()
  }

  return <article>{post.title}</article>
}
```

Requires a `not-found.tsx` file:

```typescript
// app/not-found.tsx
export default function NotFound() {
  return (
    <div>
      <h1>404 - Page Not Found</h1>
      <p>The page you're looking for doesn't exist.</p>
      <Link href="/">Go Home</Link>
    </div>
  )
}
```

## Navigation Best Practices

1. **Use `<Link>` by default** - Prefetches and optimizes
2. **Use `useRouter` for programmatic navigation** - After form submission, etc.
3. **Maintain scroll position** - Only reset when intentional
4. **Prefetch intelligently** - Avoid prefetching slow pages
5. **Use query parameters for filters** - Keep state in URL
6. **Validate pathname before redirecting** - Prevent redirect loops

## Related Standards

- {{standards/frontend/app-router}} - Route structure
- {{standards/global/project-structure}} - Directory organization
- {{standards/frontend/data-fetching}} - Data refetch on navigation
