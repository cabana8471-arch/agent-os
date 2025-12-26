# React State Management

## State Location Decision Tree

Choose the appropriate state location based on scope and frequency of updates:

```
1. Is state only used in ONE component?
   → Component State (useState)

2. Is state shared between 2-3 sibling components?
   → Lift to common parent + useState

3. Is state shared by distant/many components?
   → STOP. Is it low-frequency, accessed rarely? (theme, auth, user settings)
     → YES: Context API
     → NO: Is it server data from API?
       → YES: Tanstack Query (server state)
       → NO: Global state library (Zustand)

4. Is it volatile, changing frequently?
   → Global state library (Zustand)

5. Is it server-synced data from API?
   → Tanstack Query (react-query)
```

## Component State (useState)

```typescript
// ✅ Good: Local, isolated state
function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}

// ✅ Good: Multiple related values
const [name, setName] = useState('')
const [email, setEmail] = useState('')

// ❌ Avoid: Updating pieces of object separately
const [user, setUser] = useState({ name: '', email: '' })
setUser({ ...user, name: 'John' }) // Use useReducer instead
```

- **Scope**: Single component only
- **Frequency**: Any (not a factor at component level)
- **Typing**: Always provide explicit type
- **Initial Value**: Can be lazy with function: `useState(() => expensiveInit())`

## Lifted State (Parent Component)

```typescript
// ✅ Good: Share state between siblings by lifting to parent
function UserForm() {
  const [name, setName] = useState('')

  return (
    <>
      <NameInput value={name} onChange={setName} />
      <NamePreview value={name} />
    </>
  )
}

// ❌ Avoid: Drilling through too many levels
// If props pass through >2 levels, use Context instead
```

- **When to Use**: State shared by 2-3 sibling components
- **Prop Drilling**: Max 2 levels deep; use Context beyond that
- **Benefit**: Simple, no external dependencies
- **Limitation**: Doesn't scale beyond immediate children

## Context API

```typescript
// ✅ Good: Separate context, provider, and custom hook
interface Theme {
  mode: 'light' | 'dark'
}

const ThemeContext = React.createContext<Theme | undefined>(undefined)

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [mode, setMode] = useState<'light' | 'dark'>('light')

  return (
    <ThemeContext.Provider value={{ mode }}>
      {children}
    </ThemeContext.Provider>
  )
}

export function useTheme() {
  const theme = useContext(ThemeContext)
  if (!theme) throw new Error('useTheme must be used within ThemeProvider')
  return theme
}

// ❌ Avoid: Large monolithic context
const MegaContext = React.createContext({
  theme, user, preferences, notifications, forms, ...
})
```

- **Use Cases**: Theme, authentication, user preferences, app-wide settings
- **Frequency**: Low-frequency updates (theme changes rarely)
- **Split by Concern**: Create separate contexts (AuthContext, ThemeContext, etc.)
- **Provider Wrapper**: Always create provider component
- **Custom Hook**: Always create `useXxx` hook for consuming
- **Optimization**: Wrap value in useMemo to prevent unnecessary re-renders

```typescript
// ✅ Good: Memoize context value
export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [mode, setMode] = useState<'light' | 'dark'>('light')

  const value = useMemo(() => ({ mode }), [mode])

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  )
}
```

## Zustand (Global State)

```typescript
import { create } from 'zustand'

// ✅ Good: Simple, slice-based store
interface UserStore {
  user: User | null
  setUser: (user: User | null) => void
}

export const useUserStore = create<UserStore>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}))

// Usage
function UserProfile() {
  const user = useUserStore((state) => state.user)
  return <div>{user?.name}</div>
}

// ✅ Good: Selector for optimized subscriptions
const user = useUserStore((state) => state.user) // Only re-render if user changes

// ❌ Avoid: Subscribing to whole store
const store = useUserStore() // Re-renders on any state change
```

- **When to Use**: Global state that changes frequently, needs many consumers
- **Simplicity**: Much simpler than Redux
- **Selectors**: Always use selectors to avoid unnecessary re-renders
- **Slices**: Organize stores into logical slices
- **DevTools**: Use Zustand DevTools middleware for debugging

```typescript
// ✅ Good: Store slices
const useAuthStore = create<AuthStore>((set) => ({
  // Auth state...
}))

const usePreferencesStore = create<PreferencesStore>((set) => ({
  // Preferences state...
}))
```

## Tanstack Query (Server State)

```typescript
import { useQuery, useMutation } from '@tanstack/react-query'

// ✅ Good: Query for fetching data
function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading, error } = useQuery({
    queryKey: ['user', userId], // Unique key for this query
    queryFn: () => api.getUser(userId),
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>
  return <div>{user?.name}</div>
}

// ✅ Good: Mutation for modifying data
function UserForm({ userId }: { userId: string }) {
  const mutation = useMutation({
    mutationFn: (data: UserData) => api.updateUser(userId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user', userId] })
    },
  })

  return (
    <form onSubmit={(e) => {
      e.preventDefault()
      mutation.mutate(formData)
    }}>
      {/* ... */}
    </form>
  )
}
```

- **Use Cases**: API data fetching, caching, synchronization
- **Automatic Caching**: Caches data by queryKey
- **Automatic Refetching**: Refetch on window focus, interval
- **Query Keys**: Use unique, hierarchical keys (e.g., ['user', userId])
- **Mutations**: For POST/PUT/DELETE operations
- **Query Invalidation**: Invalidate related queries after mutation

## React Hook Form (Forms)

```typescript
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

// ✅ Good: Type-safe form with validation
const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

type FormData = z.infer<typeof schema>

function LoginForm() {
  const { register, handleSubmit, formState } = useForm<FormData>({
    resolver: zodResolver(schema),
  })

  return (
    <form onSubmit={handleSubmit((data) => {
      console.log(data)
    })}>
      <input {...register('email')} />
      {formState.errors.email && <span>{formState.errors.email.message}</span>}

      <button disabled={!formState.isValid}>Submit</button>
    </form>
  )
}
```

- **Use Cases**: Complex forms with validation
- **Integration**: Works with Zod for schema validation
- **Performance**: Uncontrolled components = better performance
- **Field-Level Errors**: Automatic error handling per field

## State Update Patterns

### Avoiding Prop Drilling

```typescript
// ❌ Bad: Drilling through 3+ levels
<Level1 user={user}>
  <Level2 user={user}>
    <Level3 user={user}>
      <Level4 user={user} />
    </Level3>
  </Level2>
</Level1>

// ✅ Good: Use Context to skip levels
<UserProvider>
  <Level1>
    <Level2>
      <Level3>
        <Level4 /> {/* Can access user from context */}
      </Level3>
    </Level2>
  </Level1>
</UserProvider>
```

### Batch Updates (React 18+)

```typescript
// ✅ Good: Automatic batching in React 18+
function handleClick() {
  setState1(val1) // Both updates batch together
  setState2(val2) // Single re-render
}

// Works even in async
async function handleAsync() {
  await api.call()
  setState1(val1) // Still batched in React 18+
  setState2(val2)
}
```

### Immutable Updates

```typescript
// ✅ Good: Always create new objects/arrays
const newUser = { ...user, name: 'John' }
const newArray = [...items, newItem]

// ❌ Avoid: Mutating objects
user.name = 'John' // Wrong: React won't detect change
items.push(newItem) // Wrong: Array mutation
```

## Related Standards

- {{standards/frontend/components}} - Component design
- {{standards/frontend/hooks}} - Custom hooks
- {{standards/testing/test-writing}} - Testing state
- {{standards/frontend/forms}} - Form-specific state patterns
