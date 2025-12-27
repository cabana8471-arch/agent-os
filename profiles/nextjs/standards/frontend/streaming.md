# Next.js Streaming and Suspense

> **Related Standards**: See `frontend/data-fetching.md` for data loading patterns, `frontend/components.md` for component architecture, `frontend/server-components.md` for Server Component patterns.

## Overview

Streaming allows progressive rendering of UI as data becomes available, improving perceived performance by showing content incrementally rather than waiting for all data.

## React Suspense Basics

### Basic Suspense Boundary

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>

      <Suspense fallback={<StatsSkeleton />}>
        <Stats />
      </Suspense>

      <Suspense fallback={<ChartSkeleton />}>
        <Chart />
      </Suspense>
    </div>
  )
}

async function Stats() {
  const stats = await fetchStats() // Async operation
  return <StatsDisplay data={stats} />
}
```

### Nested Suspense Boundaries

```typescript
export default function Page() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Header />

      <main>
        <Suspense fallback={<SidebarSkeleton />}>
          <Sidebar />
        </Suspense>

        <Suspense fallback={<ContentSkeleton />}>
          <MainContent />
        </Suspense>
      </main>
    </Suspense>
  )
}
```

## Loading UI with loading.tsx

### Route-Level Loading

```typescript
// app/dashboard/loading.tsx
export default function DashboardLoading() {
  return (
    <div className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-1/4 mb-4" />
      <div className="h-64 bg-gray-200 rounded" />
    </div>
  )
}
```

The `loading.tsx` file automatically wraps the page in a Suspense boundary.

### Instant Loading States

```
app/
├── dashboard/
│   ├── page.tsx       # Async data fetching
│   └── loading.tsx    # Shows immediately while page loads
```

## Streaming with Server Components

### Parallel Data Loading

```typescript
// app/page.tsx
import { Suspense } from 'react'

export default function HomePage() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {/* These load in parallel */}
      <Suspense fallback={<CardSkeleton />}>
        <RevenueCard />
      </Suspense>

      <Suspense fallback={<CardSkeleton />}>
        <UsersCard />
      </Suspense>

      <Suspense fallback={<CardSkeleton />}>
        <OrdersCard />
      </Suspense>
    </div>
  )
}

async function RevenueCard() {
  const revenue = await fetchRevenue() // 2s
  return <Card title="Revenue" value={revenue} />
}

async function UsersCard() {
  const users = await fetchUsers() // 1s
  return <Card title="Users" value={users} />
}

async function OrdersCard() {
  const orders = await fetchOrders() // 3s
  return <Card title="Orders" value={orders} />
}
```

### Sequential with Dependencies

```typescript
export default function UserPage({ params }: { params: { id: string } }) {
  return (
    <div>
      {/* User details load first */}
      <Suspense fallback={<UserSkeleton />}>
        <UserDetails userId={params.id} />
      </Suspense>

      {/* Posts wait for user, but stream independently */}
      <Suspense fallback={<PostsSkeleton />}>
        <UserPosts userId={params.id} />
      </Suspense>
    </div>
  )
}
```

## Skeleton Components

### Basic Skeleton

```typescript
// components/skeletons.tsx
export function CardSkeleton() {
  return (
    <div className="rounded-lg border p-4 animate-pulse">
      <div className="h-4 bg-gray-200 rounded w-1/2 mb-2" />
      <div className="h-8 bg-gray-200 rounded w-3/4" />
    </div>
  )
}

export function TableSkeleton({ rows = 5 }: { rows?: number }) {
  return (
    <div className="space-y-2">
      {Array.from({ length: rows }).map((_, i) => (
        <div key={i} className="h-12 bg-gray-200 rounded animate-pulse" />
      ))}
    </div>
  )
}

export function ArticleSkeleton() {
  return (
    <article className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-3/4 mb-4" />
      <div className="space-y-2">
        <div className="h-4 bg-gray-200 rounded" />
        <div className="h-4 bg-gray-200 rounded" />
        <div className="h-4 bg-gray-200 rounded w-5/6" />
      </div>
    </article>
  )
}
```

### Matching Layout Skeletons

```typescript
// Skeleton should match the actual component layout
function DashboardSkeleton() {
  return (
    <div className="grid grid-cols-12 gap-6">
      <div className="col-span-8">
        <ChartSkeleton />
      </div>
      <div className="col-span-4">
        <StatsSkeleton />
      </div>
    </div>
  )
}
```

## Streaming Patterns

### Progressive Enhancement

```typescript
export default function ProductPage({ params }: { params: { id: string } }) {
  return (
    <div>
      {/* Critical info first */}
      <Suspense fallback={<ProductInfoSkeleton />}>
        <ProductInfo id={params.id} />
      </Suspense>

      {/* Reviews can wait */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <ProductReviews productId={params.id} />
      </Suspense>

      {/* Recommendations lowest priority */}
      <Suspense fallback={<RecommendationsSkeleton />}>
        <Recommendations productId={params.id} />
      </Suspense>
    </div>
  )
}
```

### Shared Loading State

```typescript
// Group related content under single boundary
export default function Page() {
  return (
    <Suspense fallback={<FullPageSkeleton />}>
      <Header />
      <MainContent />
      <Footer />
    </Suspense>
  )
}
```

### Independent Loading States

```typescript
// Each section loads independently
export default function Page() {
  return (
    <>
      <Suspense fallback={<HeaderSkeleton />}>
        <Header />
      </Suspense>

      <Suspense fallback={<MainSkeleton />}>
        <MainContent />
      </Suspense>

      <Suspense fallback={<FooterSkeleton />}>
        <Footer />
      </Suspense>
    </>
  )
}
```

## Error Handling with Streaming

### Error Boundaries

```typescript
// app/dashboard/error.tsx
'use client'

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div className="p-4 bg-red-50 rounded-lg">
      <h2 className="text-red-800 font-bold">Something went wrong!</h2>
      <p className="text-red-600">{error.message}</p>
      <button
        onClick={reset}
        className="mt-2 px-4 py-2 bg-red-600 text-white rounded"
      >
        Try again
      </button>
    </div>
  )
}
```

### Granular Error Handling

```typescript
// Wrap each section with its own error boundary
import { ErrorBoundary } from 'react-error-boundary'

export default function Page() {
  return (
    <div>
      <ErrorBoundary fallback={<StatsError />}>
        <Suspense fallback={<StatsSkeleton />}>
          <Stats />
        </Suspense>
      </ErrorBoundary>

      <ErrorBoundary fallback={<ChartError />}>
        <Suspense fallback={<ChartSkeleton />}>
          <Chart />
        </Suspense>
      </ErrorBoundary>
    </div>
  )
}
```

## Optimizing Streaming

### Prefetching Data

```typescript
// Start fetching early, consume later
async function ProductPage({ params }: { params: { id: string } }) {
  // Start fetching immediately
  const productPromise = fetchProduct(params.id)
  const reviewsPromise = fetchReviews(params.id)

  return (
    <div>
      <Suspense fallback={<ProductSkeleton />}>
        <Product promise={productPromise} />
      </Suspense>

      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews promise={reviewsPromise} />
      </Suspense>
    </div>
  )
}

async function Product({ promise }: { promise: Promise<ProductData> }) {
  const product = await promise
  return <ProductDisplay product={product} />
}
```

### Caching Considerations

```typescript
// Cache data to prevent refetching on navigation
async function Stats() {
  const stats = await fetch('/api/stats', {
    next: { revalidate: 60 } // Cache for 60 seconds
  }).then(r => r.json())

  return <StatsDisplay data={stats} />
}
```

## Client-Side Streaming

### Using useTransition

```typescript
'use client'

import { useTransition } from 'react'

export function SearchResults() {
  const [isPending, startTransition] = useTransition()
  const [results, setResults] = useState([])

  function handleSearch(query: string) {
    startTransition(async () => {
      const data = await searchApi(query)
      setResults(data)
    })
  }

  return (
    <div>
      <SearchInput onChange={handleSearch} />
      {isPending ? <ResultsSkeleton /> : <Results data={results} />}
    </div>
  )
}
```

### Using useDeferredValue

```typescript
'use client'

import { useDeferredValue, useMemo } from 'react'

export function FilteredList({ items, filter }: Props) {
  // Deferred value for expensive filtering
  const deferredFilter = useDeferredValue(filter)

  const filteredItems = useMemo(
    () => items.filter(item => item.name.includes(deferredFilter)),
    [items, deferredFilter]
  )

  const isStale = filter !== deferredFilter

  return (
    <div className={isStale ? 'opacity-50' : ''}>
      {filteredItems.map(item => (
        <Item key={item.id} item={item} />
      ))}
    </div>
  )
}
```

## Best Practices

1. **Granular boundaries** - Wrap smallest meaningful units with Suspense
2. **Match skeleton to content** - Skeletons should match final layout
3. **Prioritize critical content** - Load important content first
4. **Use loading.tsx** - Automatic Suspense for route segments
5. **Handle errors gracefully** - Use error.tsx alongside loading.tsx
6. **Avoid layout shift** - Skeletons should reserve correct space
7. **Test slow connections** - Throttle network to see loading states
8. **Consider mobile** - Simpler skeletons for smaller screens
