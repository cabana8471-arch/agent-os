# Next.js Testing Strategies

## Unit Testing Setup

### Jest Configuration

```typescript
// jest.config.ts
import type { Config } from 'jest'
import nextJest from 'next/jest.js'

const createJestConfig = nextJest({
  dir: './',
})

const config: Config = {
  coverageProvider: 'v8',
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
  ],
}

export default createJestConfig(config)
```

### Jest Setup

```typescript
// jest.setup.ts
import '@testing-library/jest-dom'
```

### Test Utilities

```typescript
// lib/test-utils.tsx
import { ReactElement } from 'react'
import { render, RenderOptions } from '@testing-library/react'

const AllTheProviders = ({ children }: { children: React.ReactNode }) => {
  return <>{children}</>
}

const customRender = (ui: ReactElement, options?: Omit<RenderOptions, 'wrapper'>) =>
  render(ui, { wrapper: AllTheProviders, ...options })

export * from '@testing-library/react'
export { customRender as render }
```

## Component Testing

### Server Component Testing

For Server Components, render and test the output:

```typescript
// app/components/user-card.tsx
import { User } from '@/types'

interface UserCardProps {
  user: User
}

export async function UserCard({ user }: UserCardProps) {
  return (
    <div data-testid="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
    </div>
  )
}
```

```typescript
// __tests__/components/user-card.test.tsx
import { render } from '@/lib/test-utils'
import { UserCard } from '@/app/components/user-card'

const mockUser = {
  id: '1',
  name: 'John Doe',
  email: 'john@example.com',
}

describe('UserCard', () => {
  it('renders user information', async () => {
    const { getByTestId, getByText } = render(await UserCard({ user: mockUser }))

    expect(getByTestId('user-card')).toBeInTheDocument()
    expect(getByText('John Doe')).toBeInTheDocument()
    expect(getByText('john@example.com')).toBeInTheDocument()
  })
})
```

### Client Component Testing

```typescript
// app/components/counter.tsx
'use client'

import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  )
}
```

```typescript
// __tests__/components/counter.test.tsx
import { render, screen, fireEvent } from '@/lib/test-utils'
import { Counter } from '@/app/components/counter'

describe('Counter', () => {
  it('increments count when button is clicked', () => {
    render(<Counter />)

    const button = screen.getByRole('button', { name: /increment/i })
    const countText = screen.getByText(/count: 0/i)

    fireEvent.click(button)

    expect(screen.getByText(/count: 1/i)).toBeInTheDocument()
  })

  it('starts at 0', () => {
    render(<Counter />)
    expect(screen.getByText(/count: 0/i)).toBeInTheDocument()
  })
})
```

## Testing Forms & Server Actions

### Testing Server Actions

```typescript
// app/actions.ts
'use server'

import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
})

export async function createUser(formData: FormData) {
  const data = {
    email: formData.get('email'),
    name: formData.get('name'),
  }

  try {
    const validated = schema.parse(data)
    // Mock database call
    return { success: true, user: validated }
  } catch (error) {
    return { success: false, error: 'Invalid data' }
  }
}
```

```typescript
// __tests__/actions.test.ts
import { createUser } from '@/app/actions'

describe('createUser Server Action', () => {
  it('creates user with valid data', async () => {
    const formData = new FormData()
    formData.append('email', 'user@example.com')
    formData.append('name', 'John')

    const result = await createUser(formData)

    expect(result).toEqual({
      success: true,
      user: { email: 'user@example.com', name: 'John' },
    })
  })

  it('returns error with invalid email', async () => {
    const formData = new FormData()
    formData.append('email', 'invalid-email')
    formData.append('name', 'John')

    const result = await createUser(formData)

    expect(result.success).toBe(false)
    expect(result.error).toBeDefined()
  })
})
```

### Testing Forms with Components

```typescript
// components/user-form.tsx
'use client'

import { createUser } from '@/app/actions'
import { useFormStatus } from 'react-dom'

function SubmitButton() {
  const { pending } = useFormStatus()
  return <button disabled={pending}>{pending ? 'Creating...' : 'Create'}</button>
}

export function UserForm() {
  return (
    <form action={createUser}>
      <input name="email" type="email" required />
      <input name="name" required />
      <SubmitButton />
    </form>
  )
}
```

```typescript
// __tests__/components/user-form.test.tsx
import { render, screen } from '@/lib/test-utils'
import { UserForm } from '@/components/user-form'

describe('UserForm', () => {
  it('renders form fields', () => {
    render(<UserForm />)

    expect(screen.getByRole('textbox', { name: /email/i })).toBeInTheDocument()
    expect(screen.getByRole('textbox', { name: /name/i })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /create/i })).toBeInTheDocument()
  })
})
```

## E2E Testing with Playwright

### Playwright Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],

  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

### E2E Test Examples

```typescript
// e2e/login.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Login Flow', () => {
  test('user can log in', async ({ page }) => {
    // Navigate to login
    await page.goto('/login')

    // Fill form
    await page.fill('input[name="email"]', 'user@example.com')
    await page.fill('input[name="password"]', 'password123')

    // Submit form
    await page.click('button:has-text("Log in")')

    // Check redirect to dashboard
    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByText('Welcome')).toBeVisible()
  })

  it('shows error with invalid credentials', async ({ page }) => {
    await page.goto('/login')
    await page.fill('input[name="email"]', 'wrong@example.com')
    await page.fill('input[name="password"]', 'wrongpass')
    await page.click('button:has-text("Log in")')

    await expect(page.getByText(/invalid credentials/i)).toBeVisible()
  })
})
```

```typescript
// e2e/navigation.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Navigation', () => {
  test('can navigate between pages', async ({ page }) => {
    await page.goto('/')

    // Click about link
    await page.click('a:has-text("About")')
    await expect(page).toHaveURL('/about')

    // Click back
    await page.goBack()
    await expect(page).toHaveURL('/')
  })
})
```

## API Testing

### Testing Route Handlers

```typescript
// app/api/users/route.ts
import { db } from '@/lib/db'

export async function GET() {
  const users = await db.user.findMany()
  return Response.json(users)
}

export async function POST(request: Request) {
  const data = await request.json()
  const user = await db.user.create({ data })
  return Response.json(user, { status: 201 })
}
```

```typescript
// __tests__/api/users.test.ts
import { GET, POST } from '@/app/api/users/route'

describe('Users API', () => {
  it('GET /api/users returns users', async () => {
    const request = new Request('http://localhost:3000/api/users')
    const response = await GET(request)

    expect(response.status).toBe(200)
    const data = await response.json()
    expect(Array.isArray(data)).toBe(true)
  })

  it('POST /api/users creates user', async () => {
    const request = new Request('http://localhost:3000/api/users', {
      method: 'POST',
      body: JSON.stringify({ email: 'test@example.com', name: 'Test' }),
    })

    const response = await POST(request)
    expect(response.status).toBe(201)

    const data = await response.json()
    expect(data.email).toBe('test@example.com')
  })
})
```

## Testing Utilities

### Mock Database

```typescript
// lib/mock-db.ts
import { vi } from 'vitest'

export const mockDb = {
  user: {
    findMany: vi.fn(),
    findUnique: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
  },
  post: {
    findMany: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
  },
}
```

### Test Data Factories

```typescript
// __tests__/factories.ts
export function createMockUser(overrides = {}) {
  return {
    id: '1',
    email: 'user@example.com',
    name: 'John Doe',
    ...overrides,
  }
}

export function createMockPost(overrides = {}) {
  return {
    id: '1',
    title: 'Test Post',
    content: 'Test content',
    authorId: '1',
    ...overrides,
  }
}
```

## Coverage Configuration

```typescript
// jest.config.ts
const config: Config = {
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.ts',
    '!src/**/__tests__/**',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
}
```

## Running Tests

```bash
# Unit & integration tests
npm run test

# Watch mode
npm run test:watch

# Coverage report
npm run test:coverage

# E2E tests
npm run test:e2e

# All tests
npm run test:all
```

## Best Practices

1. **Test behavior, not implementation** - Focus on what users see
2. **Use descriptive test names** - Clearly state what is tested
3. **Keep tests isolated** - No dependencies between tests
4. **Use factories for test data** - DRY principle
5. **Mock external services** - Don't hit real APIs
6. **Test happy path and errors** - Both success and failure cases
7. **Aim for 70%+ coverage** - Don't optimize for perfect coverage
8. **Test accessibility** - Use getByRole, getByLabelText
9. **Avoid testing implementation details** - Focus on user interactions
10. **Maintain tests** - Update when functionality changes

## Related Standards

- {{standards/frontend/components}} - Component testing patterns
- {{standards/backend/api}} - API testing patterns
- {{standards/backend/server-actions}} - Server Action testing
