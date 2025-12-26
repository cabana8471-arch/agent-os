# React Hooks

## Hook Rules

1. **Call Hooks at Top Level**: Only call hooks in function body, not in conditionals/loops/nested functions
2. **Call Only in React Functions**: Call hooks only in functional components or custom hooks
3. **ESLint Rule**: Use `eslint-plugin-react-hooks` to enforce rules
4. **Exhaustive Dependencies**: All used values must be in dependency array

## Custom Hook Conventions

```typescript
// ✅ Good: Clear responsibility, documented dependencies
function useUserData(userId: string) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchUser(userId).then(setUser)
  }, [userId]) // userId is a dependency

  return { user, loading }
}

// ❌ Avoid: Multiple unrelated concerns in one hook
function useEverything(userId, formId, settingsId) { }
```

- **Naming**: Always prefix with `use` (useUserData, useForm, useDebounce)
- **Single Responsibility**: One primary purpose per hook
- **Return Values**: Return object with descriptive keys or tuple if ordered
- **Documentation**: JSDoc comment for parameters and return type

## useState Hook

```typescript
// ✅ Good: Explicit typing, clear initial value
const [count, setCount] = useState<number>(0)
const [user, setUser] = useState<User | null>(null)

// ✅ Acceptable: Let TypeScript infer for simple cases
const [isOpen, setIsOpen] = useState(false)

// ❌ Avoid: useState with object if you update pieces separately
const [state, setState] = useState({ name: '', age: 0 })
setState({ ...state, name: 'John' }) // Use useReducer instead
```

- **Primitive Values**: Use useState for simple values
- **Objects**: Consider useReducer if updating multiple related fields
- **Typing**: Explicitly type if not obvious from initial value
- **Setter Functions**: Can pass updater function for previous state

## useEffect Hook

```typescript
// ✅ Good: Clear purpose, proper cleanup
useEffect(() => {
  const subscription = event.subscribe(() => { })

  return () => {
    subscription.unsubscribe() // Cleanup
  }
}, [event]) // Dependency array

// ❌ Avoid: Missing dependencies
useEffect(() => {
  const interval = setInterval(() => {
    setCount(count + 1) // count should be in deps
  }, 1000)
}, []) // Missing count dependency

// ❌ Avoid: Missing cleanup
useEffect(() => {
  const timer = setTimeout(() => { }, 1000)
  // Should return cleanup function
}, [])
```

- **Single Concern**: Each useEffect should do one thing
- **Cleanup Functions**: Always clean up subscriptions/timers/event listeners
- **Dependencies**: List all used values from component scope
- **Empty Array**: Dependencies `[]` means run once on mount
- **No Array**: Runs after every render (usually wrong)

## useCallback Hook

```typescript
// ✅ Good: Memoize callbacks passed to memoized children
const handleSubmit = useCallback((data: FormData) => {
  submitForm(data)
}, []) // No dependencies = stable reference

const handler = useCallback((e: React.ChangeEvent) => {
  setValue(e.target.value)
}, []) // Even if no deps, can still use useCallback

// ❌ Avoid: useCallback with inline function
<MemoChild onClick={() => handleClick()} /> // Creates new function each render

// ❌ Avoid: useCallback when not needed
const name = useCallback(() => 'John', []) // Overkill for simple value
```

- **When to Use**: Functions passed to memoized children or in dependency arrays
- **Benefits**: Prevents unnecessary child re-renders
- **Pairing**: Usually paired with React.memo on child component
- **Cost**: useCallback has overhead; profile before using

## useMemo Hook

```typescript
// ✅ Good: Expensive calculation, same inputs often
const expensiveResult = useMemo(() => {
  return calculateComplexMetrics(data, filters)
}, [data, filters])

// ❌ Avoid: useMemo for simple operations
const doubled = useMemo(() => count * 2, [count]) // Just compute in render

// ❌ Avoid: useMemo for object literals
const config = useMemo(() => ({ theme: 'dark' }), []) // Already fast
```

- **When to Use**: Expensive calculations, prevent object re-creation
- **Dependency Array**: Include all values used in computation
- **Profile First**: Measure before optimizing with useMemo
- **Cost vs Benefit**: useMemo has memory overhead; only use when beneficial

## useRef Hook

```typescript
// ✅ Good: Persistent value that doesn't cause re-render
const inputRef = useRef<HTMLInputElement>(null)
const countRef = useRef(0)

// Usage
<input ref={inputRef} />
inputRef.current?.focus()

// ❌ Avoid: useRef as replacement for useState
const [name, setName] = useRef('') // Wrong: changes don't trigger re-render
```

- **DOM References**: Store DOM element references for imperative operations
- **Mutable Values**: Store values that persist across renders without causing re-renders
- **Persistence**: Value persists for component's lifetime
- **No Re-render**: Mutating ref doesn't trigger re-render

## useContext Hook

```typescript
// ✅ Good: Consume context value
const theme = useContext(ThemeContext)
const { user } = useContext(AuthContext)

// Context provider pattern (define separately)
export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)

  return (
    <AuthContext.Provider value={{ user, setUser }}>
      {children}
    </AuthContext.Provider>
  )
}
```

- **Context Creation**: Create with `React.createContext<Type>()`
- **Provider Wrapper**: Create provider component with children
- **Consumer Hook**: Create custom hook to consume context (useAuth, useTheme)
- **Avoid Overuse**: Don't create mega-context; split by concern

## useReducer Hook

```typescript
// ✅ Good: Complex state with multiple related fields
interface State {
  count: number
  error: string | null
}

type Action =
  | { type: 'INCREMENT' }
  | { type: 'DECREMENT' }
  | { type: 'SET_ERROR'; payload: string }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'INCREMENT':
      return { ...state, count: state.count + 1 }
    case 'SET_ERROR':
      return { ...state, error: action.payload }
    default:
      return state
  }
}

const [state, dispatch] = useReducer(reducer, { count: 0, error: null })
```

- **When to Use**: Multiple related state fields, complex state logic
- **Action Types**: Use discriminated unions for type safety
- **TypeScript**: Explicitly type State and Action
- **Testing**: Easier to test reducer logic separately

## Custom Hook Patterns

### useAsync

```typescript
function useAsync<T, E = string>(
  asyncFunction: () => Promise<T>,
  immediate = true,
) {
  const [state, setState] = useState<{
    status: 'idle' | 'pending' | 'success' | 'error'
    value: T | null
    error: E | null
  }>({ status: 'idle', value: null, error: null })

  const execute = useCallback(async () => {
    setState({ status: 'pending', value: null, error: null })
    try {
      const response = await asyncFunction()
      setState({ status: 'success', value: response, error: null })
    } catch (error) {
      setState({ status: 'error', value: null, error: error as E })
    }
  }, [asyncFunction])

  useEffect(() => {
    if (immediate) execute()
  }, [execute, immediate])

  return { ...state, execute }
}
```

### useDebounce

```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => clearTimeout(handler)
  }, [value, delay])

  return debouncedValue
}
```

## Hook Testing

```typescript
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

test('increments counter', () => {
  const { result } = renderHook(() => useCounter())

  act(() => {
    result.current.increment()
  })

  expect(result.current.count).toBe(1)
})
```

- **renderHook**: Test hooks in isolation
- **act**: Wrap state updates
- **waitFor**: Wait for async operations
- **rerender**: Update hook props in test

## Related Standards

- {{standards/frontend/components}} - Component structure
- {{standards/frontend/state-management}} - State architecture patterns
- {{standards/testing/test-writing}} - Testing hooks and components
