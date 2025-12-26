# React Performance

## Code Splitting

Lazy load code for faster initial page load:

```typescript
// ✅ Good: Route-based code splitting
import { lazy, Suspense } from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'

const Dashboard = lazy(() => import('./pages/Dashboard'))
const Analytics = lazy(() => import('./pages/Analytics'))
const Settings = lazy(() => import('./pages/Settings'))

export function App() {
  return (
    <Routes>
      <Route
        path="/dashboard"
        element={
          <Suspense fallback={<LoadingSpinner />}>
            <Dashboard />
          </Suspense>
        }
      />
      <Route
        path="/analytics"
        element={
          <Suspense fallback={<LoadingSpinner />}>
            <Analytics />
          </Suspense>
        }
      />
    </Routes>
  )
}

// ✅ Good: Component-level code splitting
const HeavyChart = lazy(() => import('./components/HeavyChart'))

export function Dashboard() {
  const [showChart, setShowChart] = useState(false)

  return (
    <div>
      <button onClick={() => setShowChart(true)}>Load Chart</button>
      {showChart && (
        <Suspense fallback={<div>Loading chart...</div>}>
          <HeavyChart />
        </Suspense>
      )}
    </div>
  )
}
```

## Memoization

Optimize components to prevent unnecessary re-renders:

```typescript
// ✅ Good: Memoize expensive pure components
const UserCard = React.memo(({ user }: { user: User }) => (
  <div className="card">
    <h3>{user.name}</h3>
    <p>{user.email}</p>
  </div>
))

// ✅ Good: Pair memo with useCallback for function props
function ParentComponent() {
  const handleUpdate = useCallback((userId: string) => {
    updateUser(userId)
  }, []) // No dependencies

  return <UserCard onUpdate={handleUpdate} user={user} />
}

// ✅ Good: Use useMemo for expensive calculations
function Dashboard() {
  const data = useMemo(() => {
    return complexCalculation(largeDataset)
  }, [largeDataset])

  return <div>{data}</div>
}

// ❌ Avoid: Memoizing simple components
const Button = React.memo(({ label }: { label: string }) => (
  <button>{label}</button>
)) // Overhead not worth it

// ❌ Avoid: useCallback without memoized children
function Parent() {
  const handler = useCallback(() => {}, []) // But children not memoized
  return <Child onHandle={handler} /> // Will re-render anyway
}
```

## Rendering Performance

```typescript
// ✅ Good: Virtualize long lists
import { FixedSizeList } from 'react-window'

export function LargeList({ items }: { items: Item[] }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={35}
    >
      {({ index, style }) => (
        <div style={style}>{items[index].name}</div>
      )}
    </FixedSizeList>
  )
}

// ✅ Good: Prevent re-renders with proper key prop
{items.map((item) => (
  <div key={item.id}>{item.name}</div> // Use stable ID, not index
))}

// ❌ Avoid: Using index as key (causes issues when list changes)
{items.map((item, index) => (
  <div key={index}>{item.name}</div> // Bad - causes re-renders
))}

// ✅ Good: Pagination instead of rendering all
const [page, setPage] = useState(1)
const itemsPerPage = 20
const paginatedItems = items.slice(
  (page - 1) * itemsPerPage,
  page * itemsPerPage
)
```

## Bundle Optimization

```typescript
// ✅ Good: Vite configuration
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import compression from 'vite-plugin-compression'

export default defineConfig({
  plugins: [react(), compression()],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['react', 'react-dom'],
          'router': ['react-router-dom'],
          'utils': ['lodash', 'date-fns'],
        }
      }
    }
  }
})

// ✅ Good: Named imports (enable tree-shaking)
import { debounce } from 'lodash-es' // Tree-shaken
// NOT: import _ from 'lodash' (entire library imported)

// ✅ Good: Check bundle size
// npm install -g webpack-bundle-analyzer
// Then analyze in build process
```

## Image Optimization

```typescript
// ✅ Good: Responsive images with srcset
<img
  src="/images/avatar-medium.jpg"
  srcSet="
    /images/avatar-small.jpg 400w,
    /images/avatar-medium.jpg 800w,
    /images/avatar-large.jpg 1200w
  "
  sizes="(max-width: 600px) 100vw, (max-width: 1200px) 50vw, 33vw"
  alt="User avatar"
/>

// ✅ Good: Lazy loading
<img src="/image.jpg" alt="Description" loading="lazy" />

// ✅ Good: Modern image formats
<picture>
  <source srcSet="/image.webp" type="image/webp" />
  <source srcSet="/image.jpg" type="image/jpeg" />
  <img src="/image.jpg" alt="Description" />
</picture>

// ✅ Good: Image optimization service
<img
  src={`https://image.example.com/v1/images/${id}?w=400&q=80`}
  srcSet={`https://image.example.com/v1/images/${id}?w=800&q=80 2x`}
  alt="Description"
/>
```

## Monitoring Performance

```typescript
// ✅ Good: React DevTools Profiler
// Use React DevTools > Profiler tab to identify slow renders

// ✅ Good: Measure performance
useEffect(() => {
  const startTime = performance.now()

  return () => {
    const duration = performance.now() - startTime
    console.log(`Component mounted/updated in ${duration}ms`)
  }
}, [])

// ✅ Good: Web Vitals monitoring
import { getCLS, getFID, getLCP } from 'web-vitals'

getCLS(console.log) // Cumulative Layout Shift
getFID(console.log) // First Input Delay
getLCP(console.log) // Largest Contentful Paint
```

## State Management Performance

```typescript
// ✅ Good: Zustand selectors prevent unnecessary renders
const userName = useUserStore((state) => state.user.name)
// Only re-renders if user.name changes

// ❌ Avoid: Subscribing to entire store
const { user, preferences, settings } = useUserStore()
// Re-renders on any property change

// ✅ Good: Split contexts by frequency
// Frequently-changing context
<FrequentUpdateContext.Provider value={frequentValue}>
  {/* Only affected components re-render */}
</FrequentUpdateContext.Provider>
```

## Related Standards

- {{standards/frontend/components}} - Component optimization
- {{standards/frontend/hooks}} - Hook performance patterns
- {{standards/global/coding-style}} - Code quality
