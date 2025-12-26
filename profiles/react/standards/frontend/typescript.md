# React TypeScript

## Configuration

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "resolveJsonModule": true,
    "jsx": "react-jsx",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

## React Component Props

```typescript
// ✅ Good: Type component props
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
  isLoading?: boolean
}

export function Button({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  children,
  ...props
}: ButtonProps) {
  return <button {...props}>{isLoading ? 'Loading...' : children}</button>
}

// ✅ Good: Children typing
interface CardProps {
  children: React.ReactNode
  title: string
}

// ✅ Good: Function children
interface WrapperProps {
  children: (value: string) => React.ReactNode
}

// ✅ Good: Multiple children
interface LayoutProps {
  header: React.ReactNode
  main: React.ReactNode
  sidebar?: React.ReactNode
}
```

## Event Handler Types

```typescript
// ✅ Good: Typed event handlers
function Form() {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    console.log(e.target.value)
  }

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    console.log('Submit')
  }

  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    console.log('Clicked')
  }

  return (
    <form onSubmit={handleSubmit}>
      <input onChange={handleChange} />
      <button onClick={handleClick}>Submit</button>
    </form>
  )
}
```

## Generic Components

```typescript
// ✅ Good: Generic list component
interface ListProps<T> {
  items: T[]
  renderItem: (item: T, index: number) => React.ReactNode
  keyExtractor: (item: T, index: number) => string | number
}

export function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item, index) => (
        <li key={keyExtractor(item, index)}>
          {renderItem(item, index)}
        </li>
      ))}
    </ul>
  )
}

// Usage
<List
  items={users}
  renderItem={(user) => <div>{user.name}</div>}
  keyExtractor={(user) => user.id}
/>

// ✅ Good: Generic async data hook
function useAsync<T, E = string>(
  fn: () => Promise<T>,
  immediate = true,
): { status: 'idle' | 'pending' | 'success' | 'error'; value: T | null; error: E | null } {
  // Implementation
  return { status: 'idle', value: null, error: null }
}
```

## API Response Types

```typescript
// ✅ Good: Type API responses
interface User {
  id: string
  name: string
  email: string
  role: 'admin' | 'user' | 'guest'
}

interface ApiResponse<T> {
  success: boolean
  data: T | null
  error: string | null
}

interface PaginatedResponse<T> {
  items: T[]
  total: number
  page: number
  pageSize: number
}

// Usage in components
const { data: user } = useQuery<ApiResponse<User>>(['user', userId], () =>
  api.getUser(userId)
)

const { data: users } = useQuery<PaginatedResponse<User>>(['users'], () =>
  api.listUsers()
)
```

## Utility Types

```typescript
// ✅ Good: Use utility types
type UserWithoutId = Omit<User, 'id'>
type UserNameAndEmail = Pick<User, 'name' | 'email'>
type PartialUser = Partial<User>
type ReadonlyUser = Readonly<User>

// ✅ Good: Extract component props
type ButtonProps = React.ComponentProps<typeof Button>
type InputProps = React.ComponentProps<'input'>

// ✅ Good: Union types vs enums
type Status = 'idle' | 'loading' | 'success' | 'error'

// NOT: enum Status { Idle, Loading, Success, Error }
// Enums have overhead in transpiled JavaScript
```

## Type Inference

```typescript
// ✅ Good: Let TypeScript infer types
const user = { name: 'John', age: 30 } // Inferred as { name: string; age: number }

// ✅ Good: Zod with type inference
const schema = z.object({
  email: z.string().email(),
  age: z.number().min(18)
})

type FormData = z.infer<typeof schema>

// FormData is { email: string; age: number }
```

## Avoid Common Pitfalls

```typescript
// ❌ Avoid: any type
function process(data: any) { } // Type safety lost

// ✅ Good: unknown with type guard
function process(data: unknown) {
  if (typeof data === 'string') {
    // data is string here
  }
}

// ❌ Avoid: Overusing interfaces
interface ButtonProps {
  label: string
  onClick: () => void
}
// Use type for simple object shapes

// ✅ Good: Type for object literals
type ButtonProps = {
  label: string
  onClick: () => void
}
```

## Related Standards

- {{standards/global/coding-style}} - Naming conventions
- {{standards/frontend/components}} - Component architecture
