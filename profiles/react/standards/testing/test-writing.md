# React Testing

## Testing Philosophy

- **Test Behavior**: Test what users do, not implementation details
- **React Testing Library**: Encourage testing library best practices
- **Avoid Snapshot Tests**: Brittle and don't test behavior
- **Comprehensive Coverage**: Critical flows 90%+, UI components 70%+, utilities 80%+

## Testing Framework

### Unit & Integration
- **Vitest**: Fast, Vite-native, ESM-first test runner
- **React Testing Library**: Behavior-focused component testing
- **@testing-library/react-hooks**: Testing custom hooks in isolation

### E2E Testing
- **Playwright**: Cross-browser, API-first, reliable
- Run in CI before deploy

### API Mocking
- **MSW (Mock Service Worker)**: Intercept HTTP requests at network level

## Component Testing

### Setup

```typescript
// ✅ Good: Render with providers if needed
import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'

function renderWithRouter(component: React.ReactNode) {
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  )
}

// Usage
test('renders user profile', () => {
  renderWithRouter(<UserProfile userId="123" />)
  // ...
})
```

### Query Priority

Use queries in this priority order:

1. **getByRole** (preferred): Accessible, human-readable
2. **getByLabelText**: For form inputs
3. **getByPlaceholderText**: For inputs without labels
4. **getByText**: For text content
5. **getByTestId** (last resort): Only when above don't work

```typescript
// ✅ Good: Query by role (most accessible)
const button = screen.getByRole('button', { name: /click me/i })
const input = screen.getByRole('textbox', { name: /email/i })
const heading = screen.getByRole('heading', { level: 1 })

// ✅ Good: Query by label for inputs
const emailInput = screen.getByLabelText(/email/i)

// ✅ Last resort: Query by test ID
const dialog = screen.getByTestId('confirm-dialog')

// ❌ Avoid: Querying by class or tag
screen.getByClassName('user-card') // No
screen.querySelector('div.card') // No
```

## Test Structure

### Arrange-Act-Assert Pattern

```typescript
// ✅ Good: Clear test structure
test('displays user profile with correct name', () => {
  // Arrange: Set up component with props
  const user = { id: '1', name: 'John Doe', email: 'john@example.com' }

  // Act: Render component
  render(<UserProfile user={user} />)

  // Assert: Check expected behavior
  expect(screen.getByText('John Doe')).toBeInTheDocument()
})
```

### User-Centric Testing

```typescript
// ✅ Good: Test user interactions
import userEvent from '@testing-library/user-event'

test('submits form when user clicks submit', async () => {
  const user = userEvent.setup()
  const handleSubmit = vi.fn()

  render(<LoginForm onSubmit={handleSubmit} />)

  // User types email
  await user.type(
    screen.getByLabelText(/email/i),
    'user@example.com'
  )

  // User types password
  await user.type(
    screen.getByLabelText(/password/i),
    'password123'
  )

  // User clicks submit
  await user.click(screen.getByRole('button', { name: /submit/i }))

  // Form submitted
  expect(handleSubmit).toHaveBeenCalledWith({
    email: 'user@example.com',
    password: 'password123'
  })
})

// ❌ Avoid: fireEvent (doesn't simulate real user behavior)
fireEvent.click(button) // Use userEvent instead
```

### Async Operations

```typescript
// ✅ Good: Wait for async updates
test('displays user data after loading', async () => {
  render(<UserProfile userId="1" />)

  // Initially loading
  expect(screen.getByRole('status')).toHaveTextContent(/loading/i)

  // Wait for data to load
  expect(await screen.findByText('John Doe')).toBeInTheDocument()
})

// ✅ Good: Use waitFor for complex conditions
test('shows error when fetch fails', async () => {
  vi.stubFetch().mockRejectedValueOnce(new Error('API Error'))

  render(<UserProfile userId="1" />)

  await waitFor(() => {
    expect(screen.getByText(/error/i)).toBeInTheDocument()
  })
})

// ❌ Avoid: Using setTimeout
// test('loads data', async () => {
//   render(<UserProfile userId="1" />)
//   await new Promise(r => setTimeout(r, 1000)) // Bad
// })
```

## Hook Testing

```typescript
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

// ✅ Good: Test hook in isolation
test('increments counter', () => {
  const { result } = renderHook(() => useCounter())

  expect(result.current.count).toBe(0)

  act(() => {
    result.current.increment()
  })

  expect(result.current.count).toBe(1)
})

// ✅ Good: Test hook with context provider
function renderHookWithAuth(hook: () => T) {
  return renderHook(hook, {
    wrapper: ({ children }) => (
      <AuthProvider>{children}</AuthProvider>
    )
  })
}

test('useAuth returns current user', () => {
  const { result } = renderHookWithAuth(() => useAuth())

  expect(result.current.user).toBeDefined()
})
```

## Mocking

### API Mocking with MSW

```typescript
import { setupServer } from 'msw/node'
import { http, HttpResponse } from 'msw'

// ✅ Good: Set up server with handlers
const server = setupServer(
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe'
    })
  })
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

test('fetches and displays user', async () => {
  render(<UserProfile userId="1" />)

  expect(await screen.findByText('John Doe')).toBeInTheDocument()
})

// ✅ Good: Override handler for specific test
test('shows error on API failure', async () => {
  server.use(
    http.get('/api/users/:id', () => {
      return HttpResponse.error()
    })
  )

  render(<UserProfile userId="1" />)

  expect(await screen.findByText(/error/i)).toBeInTheDocument()
})
```

### Mocking Context

```typescript
// ✅ Good: Create wrapper for context
function renderWithAuth(component: React.ReactNode, user?: User) {
  return render(
    <AuthProvider initialUser={user}>
      {component}
    </AuthProvider>
  )
}

test('shows admin panel when user is admin', () => {
  const adminUser = { id: '1', role: 'admin' }

  renderWithAuth(<Dashboard />, adminUser)

  expect(screen.getByText(/admin panel/i)).toBeInTheDocument()
})
```

## Accessibility Testing

```typescript
import { axe, toHaveNoViolations } from 'jest-axe'

expect.extend(toHaveNoViolations)

// ✅ Good: Test accessibility
test('UserCard has no accessibility violations', async () => {
  const { container } = render(<UserCard user={user} />)

  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

## Snapshot Testing

```typescript
// ❌ Avoid: Snapshot tests (brittle, don't test behavior)
test('renders correctly', () => {
  const { container } = render(<UserCard user={user} />)
  expect(container).toMatchSnapshot() // Bad
})

// ✅ Good: Test specific behavior instead
test('displays user name', () => {
  render(<UserCard user={user} />)
  expect(screen.getByText(user.name)).toBeInTheDocument()
})
```

## E2E Testing with Playwright

```typescript
import { test, expect } from '@playwright/test'

test('user can login', async ({ page }) => {
  // Navigate to app
  await page.goto('http://localhost:3000')

  // Fill form
  await page.fill('[aria-label="Email"]', 'user@example.com')
  await page.fill('[aria-label="Password"]', 'password123')

  // Submit
  await page.click('button:has-text("Login")')

  // Verify redirect to dashboard
  await expect(page).toHaveURL('/dashboard')
  await expect(page.locator('h1')).toContainText('Dashboard')
})

test('displays error on invalid credentials', async ({ page }) => {
  await page.goto('http://localhost:3000')

  await page.fill('[aria-label="Email"]', 'user@example.com')
  await page.fill('[aria-label="Password"]', 'wrong')

  await page.click('button:has-text("Login")')

  await expect(page.locator('[role="alert"]')).toContainText(/invalid/i)
})
```

## Test Organization

```
src/
  components/
    UserCard.tsx
    UserCard.test.tsx        # Test file next to component
  features/
    auth/
      components/
        LoginForm.tsx
        LoginForm.test.tsx    # Co-located with component
  lib/
    formatters.ts
    formatters.test.ts        # Test utilities separately

e2e/
  auth.spec.ts               # E2E tests in separate directory
  dashboard.spec.ts
```

## Coverage Targets

- **Critical User Flows**: 90%+ (login, purchase, core features)
- **UI Components**: 70%+ (visually verify manually, automate critical paths)
- **Utility Functions**: 80%+ (comprehensive branch coverage)
- **Edge Cases**: Test error states, empty states, boundary conditions

## Test File Naming

- **Unit/Integration**: `Component.test.tsx` or `utils.test.ts`
- **E2E**: `auth.spec.ts` or `login.spec.ts`
- **Keep Consistent**: One naming pattern across project

## Related Standards

- {{standards/frontend/components}} - Component architecture
- {{standards/frontend/hooks}} - Hook patterns
- {{standards/global/coding-style}} - Code quality
