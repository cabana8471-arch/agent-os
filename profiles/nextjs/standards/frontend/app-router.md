# Next.js App Router

## Overview

The App Router (introduced in Next.js 13) is the modern routing system. It replaces the older Pages Router. Use App Router for all new Next.js projects.

## Basic Routing

### Simple Route

```
app/
├── page.tsx          → /
├── about/
│   └── page.tsx      → /about
└── blog/
    └── page.tsx      → /blog
```

Files named `page.tsx` create routes. The directory structure becomes the URL structure.

### Nested Routes

```
app/
├── dashboard/
│   ├── page.tsx      → /dashboard
│   └── settings/
│       └── page.tsx  → /dashboard/settings
```

## Dynamic Routes

Use square brackets for dynamic segments:

### Single Dynamic Segment

```
app/
└── users/
    └── [id]/
        └── page.tsx  → /users/123, /users/456, etc.
```

Access the dynamic parameter:

```typescript
// app/users/[id]/page.tsx
interface UserPageProps {
  params: {
    id: string
  }
}

export default async function UserPage({ params }: UserPageProps) {
  const user = await fetchUser(params.id)
  return <div>{user.name}</div>
}
```

### Multiple Dynamic Segments

```
app/
└── [organization]/
    └── [project]/
        └── page.tsx  → /acme-corp/web-app, /myco/mobile-app, etc.
```

Access both parameters:

```typescript
interface ProjectPageProps {
  params: {
    organization: string
    project: string
  }
}

export default async function ProjectPage({ params }: ProjectPageProps) {
  return <div>{params.organization}/{params.project}</div>
}
```

## Catch-All Routes

Use `[...slug]` to capture all remaining segments:

```
app/
└── docs/
    └── [...slug]/
        └── page.tsx  → /docs/getting-started, /docs/api/users, etc.
```

Access the slug array:

```typescript
interface DocsPageProps {
  params: {
    slug: string[]  // Array of segments
  }
}

export default async function DocsPage({ params }: DocsPageProps) {
  const path = params.slug.join('/')  // "getting-started" or "api/users"
  return <div>Documentation: {path}</div>
}
```

### Optional Catch-All

Use `[[...slug]]` to make it optional (match both `/docs` and `/docs/getting-started`):

```
app/
└── docs/
    └── [[...slug]]/
        └── page.tsx  → /docs, /docs/getting-started, /docs/api/users, etc.
```

## Route Groups

Use parentheses to create logical groupings without affecting the URL:

### Separate Layouts

```
app/
├── (marketing)/
│   ├── layout.tsx    # Marketing header/footer
│   ├── page.tsx      → /
│   ├── pricing/
│   │   └── page.tsx  → /pricing
│   └── blog/
│       └── page.tsx  → /blog
│
└── (admin)/
    ├── layout.tsx    # Admin header/sidebar
    ├── page.tsx      → /admin (custom routing)
    └── users/
        └── page.tsx  → /admin/users
```

The `(marketing)` and `(admin)` groups don't appear in the URL.

### Organize by Feature

```
app/
├── (checkout)/
│   ├── layout.tsx
│   ├── page.tsx      → /
│   ├── review/
│   │   └── page.tsx  → /review
│   └── thank-you/
│       └── page.tsx  → /thank-you
│
└── (shop)/
    ├── layout.tsx
    ├── page.tsx      → /
    └── products/
        └── page.tsx  → /products
```

## Parallel Routes

Use `@folder` syntax to render multiple pages in the same layout:

```
app/
├── layout.tsx
├── page.tsx
├── @modal/
│   ├── layout.tsx
│   └── settings/
│       └── page.tsx
└── @sidebar/
    ├── layout.tsx
    └── navigation.tsx
```

Render both in the root layout:

```typescript
interface RootLayoutProps {
  children: React.ReactNode
  modal: React.ReactNode
  sidebar: React.ReactNode
}

export default function RootLayout({
  children,
  modal,
  sidebar,
}: RootLayoutProps) {
  return (
    <html>
      <body>
        {sidebar}
        {children}
        {modal}
      </body>
    </html>
  )
}
```

## Intercepting Routes

Use `(.)`, `(..)`, or `(...)` to intercept routes from other segments:

### Intercepting Sibling Route

```
app/
├── layout.tsx
├── page.tsx           → /
├── photos/
│   └── [id]/
│       └── page.tsx   → /photos/123
│
└── (.)photos/         # Intercepts /photos routes
    └── [id]/
        └── page.tsx   # Shows modal instead of full page
```

When user visits `/photos/123`:
- If navigated from home, shows as modal
- If direct visit, shows full page

Use case: Modal galleries, product quick views.

## Route Parameters vs Query Strings

### Dynamic Routes (Parameters)

```typescript
// app/products/[id]/page.tsx
export default async function ProductPage({ params }: { params: { id: string } }) {
  // /products/123 → params.id = "123"
}
```

### Query Strings

Use `useSearchParams` hook in Client Components:

```typescript
"use client"

import { useSearchParams } from 'next/navigation'

export default function SearchResults() {
  const searchParams = useSearchParams()
  const query = searchParams.get('q')  // /search?q=laptop → "laptop"

  return <div>Search results for: {query}</div>
}
```

## generateStaticParams (Static Generation)

For dynamic routes, pre-generate pages at build time:

```typescript
// app/blog/[slug]/page.tsx
export async function generateStaticParams() {
  const posts = await fetchPosts()
  return posts.map((post) => ({
    slug: post.slug,
  }))
}

export default async function BlogPost({ params }: { params: { slug: string } }) {
  const post = await fetchPost(params.slug)
  return <article>{post.title}</article>
}
```

Without `generateStaticParams`, routes are dynamically generated (slower).

## Redirects & Rewrites

### Redirect (Permanent)

```typescript
// app/old-page/page.tsx
import { redirect } from 'next/navigation'

export default function OldPage() {
  redirect('/new-page')
}
```

### Rewrite (Internal)

```typescript
// next.config.ts
const nextConfig = {
  async rewrites() {
    return {
      beforeFiles: [
        {
          source: '/api/:path*',
          destination: 'http://internal-api:3000/:path*',
        },
      ],
    }
  },
}

export default nextConfig
```

## Related Standards

- {{standards/frontend/server-components}} - Server vs Client Components in routes
- {{standards/frontend/layouts-templates}} - Layout structure for routes
- {{standards/global/project-structure}} - Directory organization
