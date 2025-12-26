# React Components

## Component Philosophy

- **Functional Components Only**: No class components
- **Hooks-Based**: Use React hooks for state and side effects
- **Pure Functions**: Components should be pure (same input → same output)
- **Single Responsibility**: One primary purpose per component

## Component Structure

- **One Component Per File**: Single component per .tsx file
- **Co-Located Tests**: Place .test.tsx file next to component
- **Related Files**: Place styles/hooks together if component-specific
- **Nested Components**: Only for internal-only subcomponents (non-exported)

## Props & TypeScript

```typescript
// ✅ Good: Explicit props interface with TypeScript
interface UserProfileProps {
  userId: string
  onUpdate?: (user: User) => void
  variant?: 'compact' | 'full'
}

export function UserProfile({ userId, onUpdate, variant = 'full' }: UserProfileProps) {
  // ...
}

// ❌ Avoid: Implicit props typing
export function UserProfile(props) { }
```

- **Props Interface**: Always define interface/type for component props
- **Destructure Props**: Destructure in function signature for clarity
- **Default Values**: Use destructuring defaults for optional props
- **Children**: Type children explicitly as `React.ReactNode`

## File Naming

- **Components**: PascalCase (`UserProfile.tsx`, `NavBar.tsx`)
- **Hooks**: camelCase with `use` prefix (`useUserData.ts`, `useAuth.ts`)
- **Utilities**: camelCase (`formatDate.ts`, `calculateTotal.ts`)
- **Constants**: UPPER_SNAKE_CASE (`API_BASE_URL.ts`)

## Component Organization

### Component Categories

1. **UI Components**: Atomic, reusable UI elements (Button, Input, Card)
2. **Feature Components**: Domain-specific business logic (UserForm, Dashboard)
3. **Page Components**: Route-level components rendering full pages
4. **Layout Components**: App shell, navigation, sidebars

### Directory Structure

```
components/
  ui/                    # Shared UI components
    Button.tsx
    Input.tsx
  forms/                 # Form components
    LoginForm.tsx
  layout/                # Layout components
    Header.tsx
    Sidebar.tsx
features/
  users/
    UserProfile.tsx
    UserForm.tsx
  dashboard/
    Dashboard.tsx
```

## Props Patterns

### Composition Over Configuration

```typescript
// ✅ Good: Composition with children
interface CardProps {
  children: React.ReactNode
}
export function Card({ children }: CardProps) {
  return <div className="rounded border">{children}</div>
}

// ❌ Avoid: Too many boolean props
export function Card({ title, hasFooter, showBorder, ... }) { }
```

### Compound Components

Use for tightly-coupled component families:

```typescript
export function Dialog({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>
}

Dialog.Header = function ({ children }) { return <div>{children}</div> }
Dialog.Body = function ({ children }) { return <div>{children}</div> }
Dialog.Footer = function ({ children }) { return <div>{children}</div> }

// Usage: <Dialog><Dialog.Header>...</Dialog.Header></Dialog>
```

## Component Size & Splitting

- **Max ~250 lines**: Extract subcomponents if larger
- **Single Concern**: If component does multiple things, split it
- **Testability**: Easier to test smaller components
- **Reusability**: Smaller components are more reusable

## Exports

- **Named Exports**: For components used in multiple places
- **Default Exports**: Optional for route/page components only
- **Type Exports**: Export prop interfaces for consumers

```typescript
// ✅ Good: Named export with type
export interface UserCardProps { }
export function UserCard({ }: UserCardProps) { }

// ✅ Acceptable: Default export for page components
export default function HomePage() { }
```

## Error Boundaries

```typescript
// ✅ Wrap route-level components with error boundaries
export function AppLayout() {
  return (
    <ErrorBoundary>
      <Header />
      <Outlet />
    </ErrorBoundary>
  )
}
```

- **Route Level**: Wrap route/page components
- **Feature Level**: Wrap complex feature sections (optional)
- **Fallback UI**: Show user-friendly error message

## Memoization

```typescript
// ✅ Memoize expensive pure components
const UserCard = React.memo(({ user }: UserCardProps) => (
  <div>{user.name}</div>
))

// ❌ Don't memoize every component
const Button = React.memo(({ label }: ButtonProps) => (
  <button>{label}</button>
))
```

- **When to Use**: Expensive to render, receive same props often
- **Avoid Premature**: Profile first, then memoize if needed
- **useCallback Deps**: Pair with useCallback for callback props

## Event Handlers

- **Naming**: Prefix with `handle` (`handleClick`, `handleSubmit`)
- **Typing**: Explicit event type from React (e.g., `React.MouseEvent`)
- **Arrow Functions**: Use arrow functions or useCallback, not bind()

```typescript
function Button({ onClick }: ButtonProps) {
  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault()
    onClick?.()
  }
  return <button onClick={handleClick} />
}
```

## Fragment Usage

```typescript
// ✅ Use shorthand fragment for simple cases
export function App() {
  return (
    <>
      <Header />
      <Main />
      <Footer />
    </>
  )
}
```

## Related Standards

- {{standards/frontend/hooks}} - Custom hook patterns
- {{standards/frontend/state-management}} - State architecture
- {{standards/testing/test-writing}} - Component testing
- {{standards/global/coding-style}} - React naming conventions
