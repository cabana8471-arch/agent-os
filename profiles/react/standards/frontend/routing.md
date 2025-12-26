# React Router

## Route Configuration

```typescript
// ✅ Good: Centralized route config with React Router v7
import { BrowserRouter, Routes, Route } from 'react-router-dom'

export function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public routes */}
        <Route path="/" element={<HomePage />} />
        <Route path="/about" element={<AboutPage />} />
        <Route path="/contact" element={<ContactPage />} />

        {/* Auth routes */}
        <Route element={<AuthLayout />}>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
        </Route>

        {/* Protected routes */}
        <Route element={<ProtectedLayout />}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/profile" element={<Profile />} />
        </Route>

        {/* 404 */}
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  )
}
```

## Route Components

```typescript
// ✅ Good: Error boundary on routes
import { Outlet, useParams } from 'react-router-dom'

function UserLayout() {
  return (
    <ErrorBoundary>
      <header>{/* header */}</header>
      <main>
        <Outlet /> {/* Renders child route component */}
      </main>
    </ErrorBoundary>
  )
}

// ✅ Good: Lazy load route components
import { lazy, Suspense } from 'react'

const Dashboard = lazy(() => import('./pages/Dashboard'))
const Analytics = lazy(() => import('./pages/Analytics'))

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
    </Routes>
  )
}
```

## Route Parameters & Query Strings

```typescript
// ✅ Good: Access URL parameters
import { useParams, useSearchParams } from 'react-router-dom'

function UserProfile() {
  const { userId } = useParams<{ userId: string }>()
  const [searchParams] = useSearchParams()

  const tab = searchParams.get('tab') || 'overview'
  const sort = searchParams.get('sort') || 'name'

  return <div>User {userId}, Tab: {tab}</div>
}

// ✅ Good: Validate parameters with Zod
import { z } from 'zod'

const userParamsSchema = z.object({
  userId: z.string().regex(/^\d+$/)
})

function UserProfile() {
  const params = useParams()
  const validated = userParamsSchema.safeParse(params)

  if (!validated.success) {
    return <div>Invalid user ID</div>
  }

  return <div>User {validated.data.userId}</div>
}
```

## Navigation

```typescript
// ✅ Good: Link component for client-side navigation
import { Link } from 'react-router-dom'

<Link to="/profile" className="link">
  My Profile
</Link>

// ✅ Good: Programmatic navigation
import { useNavigate } from 'react-router-dom'

function LoginForm() {
  const navigate = useNavigate()

  const handleSubmit = async (data) => {
    await login(data)
    navigate('/dashboard', { replace: true }) // Replace in history
  }

  return <form onSubmit={handleSubmit}>{/* ... */}</form>
}

// ✅ Good: Navigation with state
navigate('/checkout', { state: { from: 'cart' } })

// Access in next component
import { useLocation } from 'react-router-dom'
const { state } = useLocation()
```

## Protected Routes

```typescript
// ✅ Good: Protected route component
import { ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { useAuth } from '@/hooks/useAuth'

interface ProtectedRouteProps {
  children: ReactNode
  requiredRole?: string
}

export function ProtectedRoute({ children, requiredRole }: ProtectedRouteProps) {
  const { user, isLoading } = useAuth()

  if (isLoading) {
    return <LoadingSpinner />
  }

  if (!user) {
    return <Navigate to="/login" replace />
  }

  if (requiredRole && !user.roles.includes(requiredRole)) {
    return <Navigate to="/unauthorized" replace />
  }

  return children
}

// Usage
<Route
  path="/admin"
  element={
    <ProtectedRoute requiredRole="admin">
      <AdminPanel />
    </ProtectedRoute>
  }
/>
```

## Route Metadata & Document Title

```typescript
// ✅ Good: Set page title per route
import { useEffect } from 'react'

function UserProfile() {
  useEffect(() => {
    document.title = `User Profile - MyApp`
  }, [])

  return <div>{/* ... */}</div>
}

// ✅ Better: Use react-helmet-async
import { Helmet } from 'react-helmet-async'

function UserProfile() {
  return (
    <>
      <Helmet>
        <title>User Profile - MyApp</title>
        <meta name="description" content="View user profile" />
        <meta property="og:title" content="User Profile" />
      </Helmet>
      {/* Content */}
    </>
  )
}
```

## Error Handling

```typescript
// ✅ Good: Error boundary per route
function ErrorBoundary({ children }: { children: ReactNode }) {
  return (
    <ErrorBoundaryWrapper>
      {children}
    </ErrorBoundaryWrapper>
  )
}

// ✅ Good: 404 and error pages
<Route path="*" element={<NotFoundPage />} />
<Route path="/error" element={<ErrorPage />} />

// ✅ Good: Handle route loader errors
function UserProfile() {
  const data = useLoaderData()

  if (data instanceof Error) {
    return <ErrorPage error={data} />
  }

  return <div>{/* ... */}</div>
}
```

## Related Standards

- {{standards/frontend/components}} - Route components
- {{standards/frontend/state-management}} - Auth state
- {{standards/global/error-handling}} - Error handling
