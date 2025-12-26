# React Coding Style

Extends default coding conventions with React and TypeScript specific guidelines.

## File Organization

- **Feature-Based**: Organize by feature/domain, not by file type
- **Shared Code**: Keep truly shared utilities in top-level `lib/`, `hooks/`, `types/` directories
- **Co-Location**: Place styles/hooks with components when component-specific

```typescript
// ✅ Good: Feature-based organization
src/
  features/
    auth/
      components/
        LoginForm.tsx
        LoginForm.test.tsx
      hooks/
        useAuth.ts
        useLogin.ts
      api/
        authApi.ts
    dashboard/
      Dashboard.tsx
      Dashboard.test.tsx
  lib/
    formatters.ts
    validators.ts
  types/
    index.ts

// ❌ Avoid: Type-based organization
src/
  components/
    LoginForm.tsx
    Dashboard.tsx
  hooks/
    useAuth.ts
    useDashboard.ts
  api/
    authApi.ts
    dashboardApi.ts
```

## Naming Conventions

### Components
- **PascalCase** for components: `UserProfile.tsx`, `NavBar.tsx`, `FormInput.tsx`
- **Exported Components**: Named export preferred for reusable components
- **Internal Components**: Suffix with trailing underscore if truly internal: `_DialogContent.tsx`

### Hooks
- **camelCase** with `use` prefix: `useUserData.ts`, `useAuth.ts`, `useForm.ts`
- **Always `use`**: Never create hook without `use` prefix (required by linter)
- **Descriptive**: `useUserProfile` not `useData`, `useFetchUser` not `useFetch`

### Files & Utilities
- **Constants**: `UPPER_SNAKE_CASE` → `API_BASE_URL.ts`, `DEFAULT_TIMEOUT.ts`
- **Utilities**: `camelCase` → `formatDate.ts`, `validateEmail.ts`, `calculateTotal.ts`
- **Types/Interfaces**: `PascalCase` → `User.ts`, `ApiResponse.ts`

### Variables & Functions
- **Variables**: `camelCase` → `userName`, `isLoading`, `handleClick`
- **Functions**: `camelCase` → `formatDate()`, `calculateTotal()`
- **Booleans**: Prefix with `is`, `has`, `should` → `isLoading`, `hasError`, `shouldUpdate`
- **Event Handlers**: Prefix with `handle` → `handleClick`, `handleSubmit`, `handleChange`

## TypeScript Configuration

### Strict Mode (Required)

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true
  }
}
```

- **strict**: Enables all type checks
- **noUnusedLocals/Parameters**: Catch dead code
- **exactOptionalPropertyTypes**: Prevent undefined in optional fields
- **noImplicitReturns**: Always explicit return types

### Type Annotations

```typescript
// ✅ Good: Explicit return types
function getUserName(id: string): string {
  return fetchUser(id).name
}

const formatted = (date: Date): string => date.toISOString()

// ✅ Good: Explicit variable types when not obvious
const users: User[] = []
const config: AppConfig = { ... }

// ✅ Acceptable: Infer when obvious
const isOpen = false // Clearly boolean
const count = 0 // Clearly number
const getName = () => 'John' // Return type obvious

// ❌ Avoid: any type
function process(data: any) { } // Never use any

// ✅ Use unknown instead
function process(data: unknown) {
  if (typeof data === 'string') { /* ... */ }
}
```

- **Function Returns**: Always annotate (even if obvious)
- **Complex Types**: Always annotate
- **Union Types**: Use `|` for unions, not overloaded functions
- **Avoid `any`**: Use `unknown` if type is truly unknown

### Type vs Interface

```typescript
// ✅ Use type for:
// - Union types
// - Intersections
// - Tuples
// - Function types
type Status = 'idle' | 'loading' | 'success' | 'error'
type Callback = (data: Data) => void
type Combined = User & Permissions

// ✅ Use interface for:
// - Object shapes that might be extended
// - Class implementation contracts
interface User {
  id: string
  name: string
}

interface UserWithRole extends User {
  role: 'admin' | 'user'
}

class UserImpl implements User {
  id = ''
  name = ''
}
```

## Import Organization

```typescript
// 1. React & library imports
import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'

// 2. Third-party library imports
import { api } from '@/lib/api'
import { useQuery } from '@tanstack/react-query'

// 3. Local component imports
import { UserCard } from '@/components/UserCard'
import { LoginForm } from '@/features/auth/components/LoginForm'

// 4. Local hook imports
import { useAuth } from '@/features/auth/hooks/useAuth'
import { useDebounce } from '@/hooks/useDebounce'

// 5. Utility/lib imports
import { formatDate } from '@/lib/formatters'
import { validateEmail } from '@/lib/validators'

// 6. Type imports (grouped at bottom, or use `type` keyword)
import type { User, ApiResponse } from '@/types'

// 7. Style imports (if using CSS modules)
import styles from './Component.module.css'
```

- **Grouped**: Organize by type (react, third-party, local, types)
- **Alphabetical**: Within each group, alphabetize imports
- **`type` Keyword**: Use `import type { }` for type-only imports (TypeScript 5+)

## JSX Formatting

### Props Formatting

```typescript
// ✅ Good: Few props on one line
<Button label="Click me" onClick={handleClick} />

// ✅ Good: Many props on multiple lines
<UserForm
  user={user}
  onSubmit={handleSubmit}
  onCancel={handleCancel}
  loading={isLoading}
  validation={schema}
/>

// ✅ Good: Single child on one line
<Card><Title>Hello</Title></Card>

// ✅ Good: Multiple lines for multiple children
<Card>
  <Title>Hello</Title>
  <Description>This is a card</Description>
  <Actions>
    <Button>Save</Button>
    <Button>Cancel</Button>
  </Actions>
</Card>

// ❌ Avoid: Props on different lines unnecessarily
<Button
  label="Click me"
  onClick={handleClick}
/>
```

### Self-Closing Tags

```typescript
// ✅ Good: Self-close when no children
<Input placeholder="Name" />
<UserCard user={user} />

// ✅ Good: Open/close tags when has children
<Card>
  <Title>Hello</Title>
</Card>

// ❌ Avoid: Unnecessary self-close with children
<Card user={user} /> // But passes children? Use open/close syntax
```

### Destructuring Props

```typescript
// ✅ Good: Destructure in function signature
interface ButtonProps {
  label: string
  onClick?: () => void
  variant?: 'primary' | 'secondary'
}

function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return <button onClick={onClick}>{label}</button>
}

// ❌ Avoid: Don't destructure inside body
function Button(props: ButtonProps) {
  const { label, onClick } = props // Destructure in signature instead
}
```

## Arrow Functions

```typescript
// ✅ Good: Arrow functions for components and handlers
const UserCard = ({ user }: UserCardProps) => (
  <div>{user.name}</div>
)

const handleClick = (e: React.MouseEvent) => {
  e.preventDefault()
  onClick?.()
}

// ✅ Acceptable: Single-line implicit return
const double = (x: number) => x * 2

// ✅ Acceptable: Multi-line explicit return
const getUser = (id: string) => {
  const user = users[id]
  return user?.name ?? 'Unknown'
}

// ❌ Avoid: Function declarations for components
function UserCard(props: UserCardProps) { }

// ❌ Avoid: bind() method
onClick={this.handleClick.bind(this)} // Use arrow function instead
```

## Code Quality

### Comments

```typescript
// ✅ Good: Explain WHY, not WHAT
// Need to debounce to avoid excessive API calls
const debouncedSearch = useDebounce(query, 500)

// ✅ Good: Document complex logic
// Implements Levenshtein distance for fuzzy matching
// This handles typos up to edit distance of 2
function fuzzyMatch(a: string, b: string): number { }

// ❌ Avoid: Stating the obvious
const name = 'John' // Set name to John
const count = count + 1 // Increment count
```

### Complexity Limits

```typescript
// ✅ Good: Functions ~30-50 lines
function UserProfile() {
  // ...
}

// ✅ Good: Components ~100-150 lines
function Dashboard() {
  // ...
}

// ❌ Avoid: Functions/components > 250 lines
// Extract into smaller functions/components
```

## ESLint Configuration

Recommended ESLint rules for React/TypeScript:

```json
{
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "rules": {
    "react/react-in-jsx-scope": "off",
    "react/prop-types": "off",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-types": "warn"
  }
}
```

## Related Standards

- {{standards/frontend/components}} - Component design
- {{standards/global/conventions}} - General naming conventions
- {{standards/global/commenting}} - Documentation standards
