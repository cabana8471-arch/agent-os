# Testing Standards - Vitest & Playwright

This standard documents unit, integration, and end-to-end testing patterns using Vitest and Playwright for the SEO Optimization application.

## I. Vitest Configuration

### Install Dependencies

```bash
pnpm install -D vitest @vitejs/plugin-react @testing-library/react @testing-library/jest-dom happy-dom
```

### Setup File

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    // Use happy-dom for faster tests (instead of jsdom)
    environment: 'happy-dom',

    // Enable global test functions (describe, it, expect)
    globals: true,

    // Setup file runs before all tests
    setupFiles: ['./vitest.setup.ts'],

    // Coverage options
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'dist/',
        '.next/',
      ],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

### Setup File

```typescript
// vitest.setup.ts
import '@testing-library/jest-dom/vitest'
import { cleanup } from '@testing-library/react'
import { afterEach, vi } from 'vitest'

// Cleanup after each test
afterEach(() => {
  cleanup()
})

// Mock next/router
vi.mock('next/router', () => ({
  useRouter: () => ({
    push: vi.fn(),
    pathname: '/',
    query: {},
  }),
}))

// Mock next/navigation
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: vi.fn(),
  }),
  useSearchParams: () => new URLSearchParams(),
  usePathname: () => '/',
}))
```

### Package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest run --coverage"
  }
}
```

---

## II. Unit Tests

### Component Testing

```typescript
// __tests__/components/score-ring.test.tsx
import { render, screen } from '@testing-library/react'
import { ScoreRing } from '@/components/ui/score-ring'
import { describe, it, expect } from 'vitest'

describe('ScoreRing', () => {
  it('renders score correctly', () => {
    render(<ScoreRing score={85} maxScore={100} />)
    expect(screen.getByText('85')).toBeInTheDocument()
  })

  it('renders percentage', () => {
    render(<ScoreRing score={85} maxScore={100} />)
    expect(screen.getByText('85%')).toBeInTheDocument()
  })

  it('applies correct color for high score', () => {
    const { container } = render(<ScoreRing score={90} maxScore={100} />)
    const ring = container.querySelector('circle')
    expect(ring).toHaveClass('text-green-500')
  })

  it('applies correct color for low score', () => {
    const { container } = render(<ScoreRing score={30} maxScore={100} />)
    const ring = container.querySelector('circle')
    expect(ring).toHaveClass('text-red-500')
  })

  it('applies correct color for medium score', () => {
    const { container } = render(<ScoreRing score={60} maxScore={100} />)
    const ring = container.querySelector('circle')
    expect(ring).toHaveClass('text-yellow-500')
  })
})
```

### Function Testing

```typescript
// __tests__/lib/scanner.test.ts
import { scanUrl, parseHeadings, extractMetaTags } from '@/lib/scanner'
import { describe, it, expect, vi } from 'vitest'

describe('Scanner Functions', () => {
  describe('parseHeadings', () => {
    it('extracts all headings', () => {
      const html = `
        <h1>Main Title</h1>
        <h2>Subtitle 1</h2>
        <h3>Subtitle 2</h3>
      `
      const headings = parseHeadings(html)
      expect(headings).toHaveLength(3)
      expect(headings[0].text).toBe('Main Title')
    })

    it('returns empty array for no headings', () => {
      const html = '<p>No headings here</p>'
      const headings = parseHeadings(html)
      expect(headings).toHaveLength(0)
    })
  })

  describe('extractMetaTags', () => {
    it('extracts meta description', () => {
      const html = '<meta name="description" content="Test description">'
      const meta = extractMetaTags(html)
      expect(meta.description).toBe('Test description')
    })

    it('extracts keywords', () => {
      const html = '<meta name="keywords" content="seo, optimization">'
      const meta = extractMetaTags(html)
      expect(meta.keywords).toBe('seo, optimization')
    })
  })
})
```

---

## III. Server Action Testing

### Mocking Auth

```typescript
// __tests__/actions/create-project.test.ts
import { createProject } from '@/app/actions'
import { describe, it, expect, vi, beforeEach } from 'vitest'

// Mock BetterAuth
vi.mock('@/lib/auth', () => ({
  auth: {
    api: {
      getSession: vi.fn(),
    },
  },
}))

// Mock database
vi.mock('@/db', () => ({
  db: {
    insert: vi.fn(),
  },
}))

import { auth } from '@/lib/auth'
import { db } from '@/db'

describe('createProject', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('creates project successfully', async () => {
    // Mock session
    vi.mocked(auth.api.getSession).mockResolvedValue({
      user: { id: '123', email: 'test@example.com', name: 'Test User' },
      session: { expiresAt: new Date() },
    })

    // Mock insert
    vi.mocked(db.insert).mockReturnValue({
      values: vi.fn().mockReturnValue({
        returning: vi.fn().mockResolvedValue([
          {
            id: '456',
            name: 'Test Project',
            url: 'https://example.com',
            userId: '123',
          },
        ]),
      }),
    })

    const formData = new FormData()
    formData.append('name', 'Test Project')
    formData.append('url', 'https://example.com')

    const result = await createProject(formData)

    expect(result.success).toBe(true)
    expect(result.project.name).toBe('Test Project')
  })

  it('returns error when not authenticated', async () => {
    vi.mocked(auth.api.getSession).mockResolvedValue(null)

    const formData = new FormData()
    formData.append('name', 'Test Project')
    formData.append('url', 'https://example.com')

    const result = await createProject(formData)

    expect(result.error).toBe('Unauthorized')
  })
})
```

---

## IV. API Route Testing

### Route Handler Testing

```typescript
// __tests__/api/projects.test.ts
import { GET, POST } from '@/app/api/projects/route'
import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('@/lib/auth', () => ({
  auth: {
    api: {
      getSession: vi.fn(),
    },
  },
}))

vi.mock('@/db', () => ({
  db: {
    query: {
      project: {
        findMany: vi.fn(),
      },
    },
    insert: vi.fn(),
  },
}))

import { auth } from '@/lib/auth'
import { db } from '@/db'

describe('Projects API', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('GET /api/projects', () => {
    it('returns projects for authenticated user', async () => {
      // Mock session
      vi.mocked(auth.api.getSession).mockResolvedValue({
        user: { id: '123', email: 'test@example.com', name: 'Test User' },
        session: { expiresAt: new Date() },
      })

      // Mock query
      vi.mocked(db.query.project.findMany).mockResolvedValue([
        {
          id: '456',
          name: 'Project 1',
          url: 'https://example1.com',
          userId: '123',
        },
      ])

      const request = new Request('http://localhost:3000/api/projects')
      const response = await GET(request)

      expect(response.status).toBe(200)
      const data = await response.json()
      expect(Array.isArray(data)).toBe(true)
      expect(data).toHaveLength(1)
    })

    it('returns 401 when not authenticated', async () => {
      vi.mocked(auth.api.getSession).mockResolvedValue(null)

      const request = new Request('http://localhost:3000/api/projects')
      const response = await GET(request)

      expect(response.status).toBe(401)
    })
  })

  describe('POST /api/projects', () => {
    it('creates project successfully', async () => {
      vi.mocked(auth.api.getSession).mockResolvedValue({
        user: { id: '123', email: 'test@example.com', name: 'Test User' },
        session: { expiresAt: new Date() },
      })

      const body = JSON.stringify({
        name: 'New Project',
        url: 'https://example.com',
      })

      const request = new Request('http://localhost:3000/api/projects', {
        method: 'POST',
        body,
      })

      const response = await POST(request)

      expect(response.status).toBe(201)
    })
  })
})
```

---

## V. Database Testing

### Mock Database Setup

```typescript
// __tests__/lib/mock-db.ts
import { vi } from 'vitest'

export const mockDb = {
  query: {
    project: {
      findFirst: vi.fn(),
      findMany: vi.fn(),
    },
    user: {
      findFirst: vi.fn(),
    },
    scannedPage: {
      findMany: vi.fn(),
    },
  },
  insert: vi.fn(),
  update: vi.fn(),
  delete: vi.fn(),
  transaction: vi.fn((cb) => cb(mockDb)),
}

export function resetMockDb() {
  Object.values(mockDb).forEach((mock) => {
    if (typeof mock === 'object' && 'mockClear' in mock) {
      mock.mockClear()
    }
  })
}
```

### Database Integration Tests

```typescript
// __tests__/db/queries.test.ts
import { getProjectWithPages, createProjectWithPages } from '@/db/queries'
import { mockDb, resetMockDb } from '@/test/lib/mock-db'
import { describe, it, expect, beforeEach, vi } from 'vitest'

vi.mock('@/db', () => ({
  db: mockDb,
}))

describe('Database Queries', () => {
  beforeEach(() => {
    resetMockDb()
  })

  describe('getProjectWithPages', () => {
    it('fetches project with all pages', async () => {
      const mockProject = {
        id: '456',
        name: 'Test Project',
        scannedPages: [
          { id: '789', url: 'https://example.com/page1' },
        ],
      }

      mockDb.query.project.findFirst.mockResolvedValue(mockProject)

      const result = await getProjectWithPages('456')

      expect(result).toEqual(mockProject)
      expect(mockDb.query.project.findFirst).toHaveBeenCalled()
    })
  })
})
```

---

## VI. Playwright E2E Tests

### Installation

```bash
pnpm install -D @playwright/test
```

### Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
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
  ],

  webServer: {
    command: 'pnpm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

### E2E Test Examples

```typescript
// e2e/authentication.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('user can sign in with Google', async ({ page }) => {
    await page.goto('/login')

    // Click Google sign-in
    await page.click('button:has-text("Sign in with Google")')

    // Wait for redirect to Google
    await page.waitForURL(/accounts\.google\.com/)

    // This would require actual Google credentials in CI
    // For local testing, mock the OAuth flow
  })

  test('user can sign out', async ({ page, context }) => {
    // Set auth cookie
    await context.addCookies([
      {
        name: 'auth-token',
        value: 'test-token',
        url: 'http://localhost:3000',
      },
    ])

    await page.goto('/dashboard')

    // Click sign out
    await page.click('button:has-text("Sign Out")')

    // Should redirect to login
    await expect(page).toHaveURL('/login')
  })
})
```

### Project Creation Flow

```typescript
// e2e/project-creation.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Project Creation', () => {
  test('user can create a new project', async ({ page, context }) => {
    // Setup: login first
    await context.addCookies([
      {
        name: 'auth-token',
        value: 'test-token',
        url: 'http://localhost:3000',
      },
    ])

    await page.goto('/dashboard')

    // Click "New Project" button
    await page.click('button:has-text("New Project")')

    // Fill form
    await page.fill('input[name="name"]', 'SEO Test Project')
    await page.fill('input[name="url"]', 'https://example.com')

    // Submit
    await page.click('button:has-text("Create")')

    // Verify project appears in list
    await expect(page.getByText('SEO Test Project')).toBeVisible()
  })

  test('validation shows for invalid URL', async ({ page, context }) => {
    await context.addCookies([
      {
        name: 'auth-token',
        value: 'test-token',
        url: 'http://localhost:3000',
      },
    ])

    await page.goto('/dashboard')
    await page.click('button:has-text("New Project")')

    // Enter invalid URL
    await page.fill('input[name="url"]', 'not-a-url')

    // Try to submit
    await page.click('button:has-text("Create")')

    // Should show error
    await expect(page.getByText(/invalid.*url/i)).toBeVisible()
  })
})
```

### Real-Time Feature Testing

```typescript
// e2e/realtime.spec.ts
import { test, expect } from '@playwright/test'

test('scan progress updates in real-time', async ({ page, context }) => {
  // Login
  await context.addCookies([
    {
      name: 'auth-token',
      value: 'test-token',
      url: 'http://localhost:3000',
    },
  ])

  await page.goto('/dashboard')

  // Start scan
  await page.click('button:has-text("Scan")')

  // Progress should appear
  await expect(page.getByText(/scanning/i)).toBeVisible()

  // Wait for completion (with timeout)
  await expect(page.getByText(/scan complete/i), {
    timeout: 30000,
  }).toBeVisible()
})
```

---

## VII. Fixtures & Helpers

### Test Fixtures

```typescript
// e2e/fixtures.ts
import { test as base, expect } from '@playwright/test'

type TestFixtures = {
  authenticatedPage: Page
}

export const test = base.extend<TestFixtures>({
  authenticatedPage: async ({ page, context }, use) => {
    // Setup authentication
    await context.addCookies([
      {
        name: 'auth-token',
        value: 'test-token',
        url: 'http://localhost:3000',
      },
    ])

    await page.goto('/dashboard')

    // Use authenticated page
    await use(page)

    // Cleanup
    await page.close()
  },
})
```

### Using Fixtures

```typescript
// e2e/authenticated-flow.spec.ts
import { test } from './fixtures'

test('authenticated user can access dashboard', async ({ authenticatedPage }) => {
  await expect(authenticatedPage.getByText('Dashboard')).toBeVisible()
})
```

---

## VIII. Running Tests

### Commands

```bash
# Run all tests
pnpm run test

# Run tests in UI mode
pnpm run test:ui

# Run with coverage
pnpm run test:coverage

# Run E2E tests
pnpm run test:e2e

# Watch mode
pnpm test -- --watch
```

### Coverage

```bash
pnpm run test:coverage
# Generates: coverage/index.html
```

---

## IX. Best Practices

1. **Test user behavior** - Test what users see and do
2. **Use semantic selectors** - getByRole, getByLabelText instead of getByTestId
3. **Keep tests isolated** - No dependencies between tests
4. **Mock external APIs** - Don't call real APIs in tests
5. **Test error cases** - Not just happy path
6. **Use factories** - Create test data consistently
7. **Avoid implementation details** - Test API contracts
8. **Test accessibility** - Use accessible queries
9. **Aim for 70%+ coverage** - Balance speed vs confidence
10. **Run in CI** - Catch regressions early

---

## X. Package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:all": "pnpm run test:run && pnpm run test:e2e"
  }
}
```

---

## Related Standards

- {{standards/frontend/components}} - Component testing
- {{standards/backend/api}} - API route testing
- {{standards/backend/database}} - Database mocking
- {{standards/global/error-handling}} - Testing error scenarios
