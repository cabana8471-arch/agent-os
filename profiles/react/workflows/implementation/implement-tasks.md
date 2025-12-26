# React Task Implementation

## Pre-Implementation Checklist

Before implementing React component or feature:

- ✅ Verify Vite dev server running: `npm run dev`
- ✅ Run TypeScript compiler: `npm run type-check`
- ✅ Check for ESLint errors: `npm run lint`
- ✅ Browser console open for warnings/errors
- ✅ Know the component's props interface
- ✅ Have test file created alongside component

## Component Implementation Pattern

### 1. Create Component File

```typescript
// src/features/users/components/UserProfile.tsx
import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { useUser } from '../hooks/useUser'
import styles from './UserProfile.module.css'

interface UserProfileProps {
  // Props if used as child component
}

export function UserProfile() {
  const { userId } = useParams<{ userId: string }>()
  const { data: user, isLoading, error } = useUser(userId!)

  if (isLoading) return <div>Loading...</div>
  if (error || !user) return <div>Error loading user</div>

  return (
    <div className={styles.container}>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  )
}
```

### 2. Create Matching Test File

```typescript
// src/features/users/components/UserProfile.test.tsx
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { UserProfile } from './UserProfile'
import * as userHooks from '../hooks/useUser'

vi.mock('../hooks/useUser')

describe('UserProfile', () => {
  it('renders user data when loaded', () => {
    vi.spyOn(userHooks, 'useUser').mockReturnValue({
      data: { id: '1', name: 'John', email: 'john@example.com' },
      isLoading: false,
      error: null,
    })

    render(
      <BrowserRouter>
        <UserProfile />
      </BrowserRouter>
    )

    expect(screen.getByText('John')).toBeInTheDocument()
  })
})
```

### 3. Create Types (if needed)

```typescript
// src/features/users/types.ts
export interface User {
  id: string
  name: string
  email: string
  role: 'admin' | 'user'
}
```

### 4. Create Hook (if needed)

```typescript
// src/features/users/hooks/useUser.ts
import { useQuery } from '@tanstack/react-query'
import { User } from '../types'

export function useUser(userId: string) {
  return useQuery<User>({
    queryKey: ['user', userId],
    queryFn: () => api.getUser(userId),
  })
}
```

## Self-Verification Checklist

After implementation, verify:

- ✅ **TypeScript**: Run `npm run type-check` - no errors
- ✅ **Linting**: Run `npm run lint` - no errors
- ✅ **Tests**: Run `npm test` - all pass
- ✅ **Browser**: Load page in browser, no console errors
- ✅ **Accessibility**: Check with axe DevTools
- ✅ **Responsive**: Test on mobile/tablet/desktop

## Commands

```bash
# Development
npm run dev          # Start Vite dev server

# Verification
npm run type-check   # Check TypeScript
npm run lint         # Check ESLint
npm test             # Run tests
npm run build        # Build for production
```

## Common Patterns

### Data Fetching Component

```typescript
// Pattern: Load data and display
function DataComponent() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['items'],
    queryFn: () => api.getItems(),
  })

  if (isLoading) return <Skeleton />
  if (error) return <ErrorMessage />
  return <ItemsList items={data} />
}
```

### Form Component

```typescript
// Pattern: React Hook Form + Zod
const schema = z.object({ name: z.string(), email: z.string().email() })

function MyForm() {
  const { register, formState } = useForm({ resolver: zodResolver(schema) })
  return (
    <form>
      <input {...register('name')} />
      {formState.errors.name && <span>{formState.errors.name.message}</span>}
    </form>
  )
}
```

## Debugging Tips

```typescript
// Log component renders
useEffect(() => {
  console.log('Component mounted/updated', props)
}, [])

// Check what's causing re-renders
const prevPropsRef = useRef()
useEffect(() => {
  console.log('Props changed:', prevPropsRef.current, props)
  prevPropsRef.current = props
}, [props])

// Test hooks in isolation
import { renderHook } from '@testing-library/react'
const { result } = renderHook(() => useMyHook())
```

## Related Standards

- {{standards/frontend/components}} - Component architecture
- {{standards/testing/test-writing}} - Testing patterns
- {{standards/global/coding-style}} - Code conventions
