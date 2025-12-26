# Next.js Performance Optimization

## Web Vitals & Metrics

### Core Web Vitals

Three key metrics for user experience:

1. **LCP (Largest Contentful Paint)** - 2.5s or less
   - Time to load largest visible element

2. **FID (First Input Delay)** - 100ms or less
   - Time from user input to response

3. **CLS (Cumulative Layout Shift)** - 0.1 or less
   - Visual stability during page load

### Monitoring with Next.js

```typescript
// app/layout.tsx
'use client'

import { useReportWebVitals } from 'next/web-vitals'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  useReportWebVitals((metric) => {
    console.log(`${metric.name}: ${metric.value}`)

    // Send to analytics
    if (process.env.NEXT_PUBLIC_ANALYTICS_ID) {
      fetch('/api/analytics', {
        method: 'POST',
        body: JSON.stringify(metric),
      })
    }
  })

  return <html>{children}</html>
}
```

## Code Splitting

Automatically done by Next.js, but optimize with dynamic imports:

### Dynamic Component Loading

```typescript
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/heavy-chart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // Don't render on server if not needed
})

export default function Page() {
  return (
    <div>
      <h1>Dashboard</h1>
      <HeavyChart />
    </div>
  )
}
```

### Route-Based Code Splitting

Routes are automatically code-split:

```
app/
├── page.tsx           (chunk: page)
├── dashboard/
│   └── page.tsx       (chunk: dashboard)
└── admin/
    └── page.tsx       (chunk: admin)
```

Each route only loads its code - not other routes' code.

## Image Optimization

Use `next/image` for automatic optimization:

```typescript
import Image from 'next/image'

export function HeroImage() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero"
      width={1200}
      height={600}
      priority // Only for above-fold images
      quality={75} // Adjust based on use case
      sizes="(max-width: 640px) 100vw,
             (max-width: 1024px) 80vw,
             1200px"
    />
  )
}
```

Benefits:
- Automatic WebP/AVIF conversion
- Responsive images (srcset)
- Lazy loading below-fold
- Prevents layout shift

## Font Optimization

Use `next/font` to avoid layout shift:

```typescript
// lib/fonts.ts
import { Inter } from 'next/font/google'

export const inter = Inter({
  subsets: ['latin'],
  weight: ['400', '700'],
  display: 'swap',
})
```

```typescript
// app/layout.tsx
import { inter } from '@/lib/fonts'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={inter.className}>
      <body>{children}</body>
    </html>
  )
}
```

## Data Fetching Optimization

### Parallel Data Fetching

Fetch independent data concurrently:

```typescript
// ✅ Good - Parallel requests
export default async function Page() {
  const [users, posts, stats] = await Promise.all([
    db.user.findMany(),
    db.post.findMany(),
    db.stats.findOne(),
  ])

  return (...)
}

// ❌ Bad - Sequential requests
export default async function Page() {
  const users = await db.user.findMany()
  const posts = await db.post.findMany() // Waits for users
  const stats = await db.stats.findOne() // Waits for posts

  return (...)
}
```

### Streaming with Suspense

Progressive rendering:

```typescript
import { Suspense } from 'react'

async function Sidebar() {
  const data = await fetch('/api/sidebar', { next: { revalidate: 60 } })
  return <div>{data}</div>
}

async function MainContent() {
  const data = await fetch('/api/content', { next: { revalidate: 10 } })
  return <article>{data}</article>
}

export default function Page() {
  return (
    <div>
      <Suspense fallback={<SidebarSkeleton />}>
        <Sidebar />
      </Suspense>

      <Suspense fallback={<MainSkeleton />}>
        <MainContent />
      </Suspense>
    </div>
  )
}
```

User sees content progressively instead of waiting for everything.

## Rendering Optimization

### Static Generation (SSG)

For content that doesn't change often:

```typescript
// app/blog/[slug]/page.tsx
export const revalidate = 3600 // Revalidate every hour

export async function generateStaticParams() {
  const posts = await db.post.findMany()
  return posts.map((post) => ({ slug: post.slug }))
}

export default async function BlogPost({ params }: { params: { slug: string } }) {
  const post = await db.post.findUnique({ where: { slug: params.slug } })
  return <article>{post.content}</article>
}
```

Benefits:
- Pre-rendered HTML (served from CDN)
- Instant page load
- Lower server load

### ISR (Incremental Static Regeneration)

Update static pages without full rebuild:

```typescript
export const revalidate = 3600 // Revalidate every 1 hour

export default async function Page() {
  const data = await fetchData()
  return <div>{data}</div>
}
```

When `revalidate` time expires, Next.js:
1. Serves stale page to users
2. Regenerates page in background
3. Serves new page to next visitors

### Dynamic Rendering

For personalized or frequently-changing content:

```typescript
export const dynamic = 'force-dynamic' // Always fresh

export default async function Page() {
  const userData = await getCurrentUser() // Fresh every time
  return <div>{userData}</div>
}
```

## Bundle Size Optimization

### Tree Shaking

Remove unused code:

```typescript
// ✅ Good - Named import (tree-shakeable)
import { formatDate } from '@/lib/date-utils'

// ❌ Bad - Default import (includes all exports)
import dateUtils from '@/lib/date-utils'
```

### Package Analysis

```bash
npm install -D @next/bundle-analyzer

# next.config.ts
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

export default withBundleAnalyzer({
  // config
})
```

```bash
ANALYZE=true npm run build
```

### External Dependencies

Minimize dependencies:

```typescript
// ❌ Bad - Heavy library for simple task
import moment from 'moment'
const formatted = moment(date).format('YYYY-MM-DD')

// ✅ Good - Lightweight alternative
import { format } from 'date-fns'
const formatted = format(date, 'yyyy-MM-dd')

// ✅ Better - Use native JavaScript
const formatted = date.toISOString().split('T')[0]
```

## Memoization

Cache expensive computations:

### useMemo for Calculations

```typescript
'use client'

import { useMemo } from 'react'

export function DataTable({ data }: { data: Item[] }) {
  const sortedData = useMemo(() => {
    return data.sort((a, b) => a.price - b.price)
  }, [data])

  return <table>{/* ... */}</table>
}
```

### memo for Component Re-renders

```typescript
'use client'

import { memo } from 'react'

interface ItemProps {
  item: Item
  onSelect: (id: string) => void
}

export const ListItem = memo(function ListItem({ item, onSelect }: ItemProps) {
  return (
    <li onClick={() => onSelect(item.id)}>
      {item.name}
    </li>
  )
}, (prev, next) => prev.item.id === next.item.id && prev.onSelect === next.onSelect)
```

## Caching Strategy

### HTTP Caching

```typescript
// app/api/data/route.ts
export async function GET() {
  const data = await fetchData()

  return Response.json(data, {
    headers: {
      'Cache-Control': 'public, max-age=3600', // 1 hour
    },
  })
}
```

### Request Deduplication

Next.js automatically deduplicates identical requests:

```typescript
// Both fetch calls are deduplicated
const user1 = await fetch('/api/user/1')
const user2 = await fetch('/api/user/1') // Same request, cached result
```

### Response Caching

```typescript
export const revalidate = 60 // Cache for 60 seconds

export default async function Page() {
  const data = await fetch('/api/data', {
    next: { revalidate: 60 }, // Override global setting
  })

  return <div>{data}</div>
}
```

## Database Query Optimization

### N+1 Query Prevention

```typescript
// ❌ Bad - N+1 queries
const users = await db.user.findMany()
for (const user of users) {
  const posts = await db.post.findMany({ where: { authorId: user.id } })
}

// ✅ Good - Single query with join
const users = await db.user.findMany({
  include: { posts: true },
})
```

### Query Optimization

```typescript
// ❌ Bad - Fetches all fields
const users = await db.user.findMany()

// ✅ Good - Only needed fields
const users = await db.user.findMany({
  select: { id: true, name: true, email: true },
})

// ✅ Good - Pagination
const users = await db.user.findMany({
  take: 10,
  skip: (page - 1) * 10,
})
```

## Runtime Optimization

### Edge Runtime

Lighter weight runtime for API routes:

```typescript
// app/api/lightweight/route.ts
export const runtime = 'edge'

export async function GET(request: Request) {
  return Response.json({ hello: 'world' })
}
```

### Middleware Optimization

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // This runs before the request reaches your app
  // Keep it lightweight
  return NextResponse.next()
}

export const config = {
  matcher: '/admin/:path*', // Only run for admin routes
}
```

## Performance Checklist

- [ ] Images optimized with next/image
- [ ] Fonts loaded with next/font
- [ ] LCP < 2.5s
- [ ] FID < 100ms
- [ ] CLS < 0.1
- [ ] Code splitting enabled
- [ ] Bundle size < 200KB (initial)
- [ ] Static pages prerendered where possible
- [ ] Suspense boundaries for streaming
- [ ] Database queries optimized (no N+1)
- [ ] Unnecessary dependencies removed
- [ ] API routes cached appropriately
- [ ] Images lazy-loaded below fold
- [ ] No layout shift on font load
- [ ] Critical CSS inlined

## Monitoring Performance

```typescript
// app/layout.tsx
import { WebVitals } from '@/components/web-vitals'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {children}
        <WebVitals />
      </body>
    </html>
  )
}
```

```typescript
// components/web-vitals.tsx
'use client'

import { useReportWebVitals } from 'next/web-vitals'

export function WebVitals() {
  useReportWebVitals((metric) => {
    // Send to analytics service
    console.log(metric)
  })

  return null
}
```

## Related Standards

- {{standards/frontend/image-optimization}} - Image performance
- {{standards/frontend/fonts}} - Font optimization
- {{standards/frontend/data-fetching}} - Data fetching patterns
- {{standards/backend/database}} - Database optimization
