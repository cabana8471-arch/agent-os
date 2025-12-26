# React Error Handling

## Error Boundaries

```typescript
import { ReactNode, Component, ReactElement } from 'react'

interface Props {
  children: ReactNode
  fallback?: (error: Error) => ReactElement
}

interface State {
  hasError: boolean
  error: Error | null
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught:', error, errorInfo)
    logErrorToService(error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback?.(this.state.error!) || (
          <div>
            <h1>Something went wrong</h1>
            <p>{this.state.error?.message}</p>
          </div>
        )
      )
    }

    return this.props.children
  }
}

// Usage
<ErrorBoundary fallback={(error) => <ErrorPage error={error} />}>
  <Dashboard />
</ErrorBoundary>
```

## Async Error Handling

```typescript
// ✅ Good: Try-catch in async functions
async function fetchData() {
  try {
    const response = await api.get('/data')
    return response.data
  } catch (error) {
    if (axios.isAxiosError(error)) {
      if (error.response?.status === 404) {
        throw new Error('Data not found')
      }
      if (error.response?.status === 401) {
        redirectToLogin()
      }
    }
    throw error
  }
}

// ✅ Good: Error handling in Tanstack Query
export function useData() {
  return useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
    retry: 3, // Retry failed requests
    onError: (error) => {
      if (error instanceof Error) {
        showErrorToast(error.message)
      }
    },
  })
}
```

## User-Facing Errors

```typescript
// ✅ Good: Toast notifications for errors
import { useToast } from '@/hooks/useToast'

function UserForm() {
  const { showToast } = useToast()
  const mutation = useMutation({
    mutationFn: saveUser,
    onError: (error) => {
      showToast({
        type: 'error',
        title: 'Failed to save',
        message: error.message,
        duration: 5000,
      })
    },
  })

  return <form onSubmit={async (e) => {
    e.preventDefault()
    await mutation.mutateAsync(formData)
  }}>
    {/* form content */}
  </form>
}

// ✅ Good: Modal for critical errors
function CriticalError({ error, onRetry }: { error: Error; onRetry: () => void }) {
  return (
    <Dialog open>
      <DialogContent>
        <h2>Critical Error</h2>
        <p>{error.message}</p>
        <DialogFooter>
          <button onClick={onRetry}>Retry</button>
          <button onClick={() => window.location.reload()}>Reload Page</button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
```

## Router-Level Errors

```typescript
import { useRouteError, isRouteErrorResponse } from 'react-router-dom'

// ✅ Good: Error route
<Route
  path="*"
  element={<ErrorPage />}
/>

function ErrorPage() {
  const error = useRouteError()

  if (isRouteErrorResponse(error)) {
    return (
      <div>
        <h1>{error.status}</h1>
        <p>{error.statusText}</p>
        {error.data?.message && <p>{error.data.message}</p>}
      </div>
    )
  }

  if (error instanceof Error) {
    return (
      <div>
        <h1>Error</h1>
        <p>{error.message}</p>
      </div>
    )
  }

  return <div>Unknown error occurred</div>
}
```

## Error Monitoring

```typescript
// ✅ Good: Send errors to monitoring service
import * as Sentry from '@sentry/react'

Sentry.init({
  dsn: import.meta.env.VITE_SENTRY_DSN,
  environment: import.meta.env.MODE,
  tracesSampleRate: 1.0,
})

// Automatic error capture
function App() {
  return (
    <Sentry.ErrorBoundary
      fallback={<ErrorPage />}
      showDialog
      dialogOptions={{
        title: 'Something went wrong',
      }}
    >
      <Routes>
        {/* routes */}
      </Routes>
    </Sentry.ErrorBoundary>
  )
}

// Manual error logging
Sentry.captureException(new Error('Custom error'), {
  tags: {
    feature: 'user_dashboard',
  },
})
```

## Error Types

```typescript
// ✅ Good: Type safe errors
class ValidationError extends Error {
  constructor(
    message: string,
    public field: string
  ) {
    super(message)
    this.name = 'ValidationError'
  }
}

class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public code?: string
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

// Usage
try {
  validateForm(data)
} catch (error) {
  if (error instanceof ValidationError) {
    setFieldError(error.field, error.message)
  } else if (error instanceof ApiError && error.status === 409) {
    showWarning('Resource already exists')
  }
}
```

## Related Standards

- {{standards/global/error-handling}} - General error patterns
- {{standards/backend/api}} - API error handling
- {{standards/frontend/components}} - Component error states
