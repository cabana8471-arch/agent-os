# Next.js Coding Style

## TypeScript Configuration

### Compiler Options

Always use strict mode:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "esModuleInterop": true,
    "module": "ESNext",
    "target": "ES2020",
    "moduleResolution": "bundler"
  }
}
```

## File Naming

### React Components (PascalCase)

```typescript
// ✅ Good
function UserProfile() {}
function BlogPostCard() {}
function DashboardLayout() {}

// ❌ Bad
function userProfile() {}
function blog-post-card() {}
```

### Utilities & Functions (camelCase)

```typescript
// ✅ Good
export const formatDate = (date: Date) => {}
export const calculateTotal = (items: Item[]) => {}
export const validateEmail = (email: string) => {}

// ❌ Bad
export const FormatDate = (date: Date) => {}
export const calculate_total = (items: Item[]) => {}
```

### Custom Hooks (use + camelCase)

```typescript
// ✅ Good
export const useAuth = () => {}
export const useLocalStorage = (key: string) => {}
export const useDebounce = (value: unknown, delay: number) => {}

// ❌ Bad
export const auth = () => {}
export const useAuth_v2 = () => {}
export const AuthHook = () => {}
```

### Types & Interfaces (PascalCase)

```typescript
// ✅ Good
export type User = {
  id: string
  name: string
  email: string
}

export interface BlogPost {
  title: string
  content: string
  authorId: string
}

// ❌ Bad
export type user = {}
export interface blog_post {}
```

### Constants (UPPER_SNAKE_CASE)

```typescript
// ✅ Good
export const API_BASE_URL = "https://api.example.com"
export const MAX_RETRIES = 3
export const DEFAULT_TIMEOUT = 5000

// ❌ Bad
export const apiBaseUrl = "https://api.example.com"
export const maxRetries = 3
```

## Component Conventions

### Server Components (Default)

```typescript
// ✅ Good - Server Component (default, no "use client")
export default async function UserPage({ params }: { params: { id: string } }) {
  const user = await fetchUser(params.id)

  return (
    <div>
      <h1>{user.name}</h1>
      <UserCard user={user} />
    </div>
  )
}
```

### Client Components (Explicitly Marked)

```typescript
"use client" // ← Must be at top of file

import { useState } from "react"

export default function UserForm() {
  const [name, setName] = useState("")

  return (
    <form onSubmit={(e) => e.preventDefault()}>
      <input value={name} onChange={(e) => setName(e.target.value)} />
    </form>
  )
}
```

### Async Server Components

```typescript
// ✅ Good
export default async function BlogLayout({ children }: { children: React.ReactNode }) {
  const posts = await fetchPosts()

  return (
    <div>
      <Sidebar posts={posts} />
      <main>{children}</main>
    </div>
  )
}

// ❌ Bad - Use async in Server Components, not Client Components
"use client"
export default function BlogLayout({ children }: { children: React.ReactNode }) {
  const [posts, setPosts] = useState([])

  // This pattern should use Server Components + Suspense instead
  useEffect(() => {
    fetchPosts().then(setPosts)
  }, [])

  return <div>{children}</div>
}
```

## Naming Conventions for Special Files

### Page & Layout Files

```typescript
// app/dashboard/page.tsx
export default function DashboardPage() {
  return <Dashboard />
}

// app/dashboard/layout.tsx
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return <div className="dashboard-layout">{children}</div>
}

// app/users/[id]/page.tsx
export default async function UserDetailPage({ params }: { params: { id: string } }) {
  const user = await fetchUser(params.id)
  return <UserDetail user={user} />
}
```

### Route Handlers

```typescript
// app/api/users/route.ts
export async function GET(request: Request) {
  const users = await fetchUsers()
  return Response.json(users)
}

export async function POST(request: Request) {
  const data = await request.json()
  const user = await createUser(data)
  return Response.json(user, { status: 201 })
}

// app/api/users/[id]/route.ts
export async function GET(request: Request, { params }: { params: { id: string } }) {
  const user = await fetchUser(params.id)
  return Response.json(user)
}
```

### Layout File Naming

Avoid prefixes like `root-` or suffixes. Use standard names:

```typescript
// ✅ Good
app/layout.tsx           // Root layout
app/dashboard/layout.tsx // Dashboard layout

// ❌ Bad
app/root-layout.tsx
app/dashboard-layout.tsx
app/DashboardLayout.tsx
```

## Component Structure

### Functional Components with Props

```typescript
"use client"

interface UserCardProps {
  user: User
  onDelete?: (id: string) => void
}

export function UserCard({ user, onDelete }: UserCardProps) {
  return (
    <div>
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      {onDelete && <button onClick={() => onDelete(user.id)}>Delete</button>}
    </div>
  )
}
```

### Extracting Props Type

```typescript
// ✅ Good
interface DialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  children: React.ReactNode
}

export function Dialog({ open, onOpenChange, children }: DialogProps) {
  return open ? <div>{children}</div> : null
}

// Alternative: use React.ComponentProps for extending existing components
type ButtonProps = React.ComponentProps<"button">

export function CustomButton({ className, ...props }: ButtonProps) {
  return <button className={`btn ${className}`} {...props} />
}
```

### Default Exports for Pages

```typescript
// ✅ Good - Pages use default export
export default function HomePage() {
  return <HomePage />
}

// ✅ Good - Components use named export
export function UserCard() {}

// ❌ Bad - Mixed exports
export default function HomePage() {}
export function UserCard() {}
```

## Server Actions

### Basic Server Action

```typescript
// app/actions.ts
"use server"

import { db } from "@/lib/db"

export async function createUser(formData: FormData) {
  const name = formData.get("name") as string

  const user = await db.user.create({
    data: { name },
  })

  return user
}
```

### Server Action in Forms

```typescript
"use client"

import { createUser } from "@/app/actions"

export function UserForm() {
  return (
    <form action={createUser}>
      <input name="name" type="text" required />
      <button type="submit">Create User</button>
    </form>
  )
}
```

## Import Organization

### Order of Imports

```typescript
// 1. React and Next.js imports
"use client"
import { useEffect, useState } from "react"
import Link from "next/link"
import Image from "next/image"

// 2. External library imports
import { useQuery } from "@tanstack/react-query"
import clsx from "clsx"

// 3. Internal imports - src root (@/...)
import { useAuth } from "@/hooks/useAuth"
import { formatDate } from "@/lib/date"
import type { User } from "@/types"

// 4. Relative imports (./..): avoid when using @ alias
import { Button } from "../button"

// 5. Type imports separated (optional but clean)
import type { Props } from "./types"
```

### Aliasing with @

Use `@` alias in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

## Code Style Rules

### Variable Declaration

```typescript
// ✅ Good - const by default
const user: User = await fetchUser()
const count = 0

// Use let only when needed
let retries = 0
while (retries < 3) {
  // retry logic
  retries++
}

// ❌ Bad - var is deprecated
var user = await fetchUser()
```

### Function Declaration

```typescript
// ✅ Good - arrow functions, typed
const fetchUser = async (id: string): Promise<User> => {
  const response = await fetch(`/api/users/${id}`)
  return response.json()
}

// ✅ Good - regular functions for components
function UserCard({ user }: UserCardProps) {
  return <div>{user.name}</div>
}

// ❌ Bad - untyped, using function keyword unnecessarily
function fetchUser(id) {
  // ...
}
```

### Optional Properties

```typescript
// ✅ Good - explicit optional
interface CardProps {
  title: string
  description?: string
  onDelete?: (id: string) => void
}

// ✅ Good - use union with null
type User = {
  id: string
  bio: string | null
}
```

### Error Handling

```typescript
// ✅ Good - typed error handling
async function fetchUser(id: string) {
  try {
    const response = await fetch(`/api/users/${id}`)
    if (!response.ok) {
      throw new Error(`User not found: ${response.status}`)
    }
    return response.json()
  } catch (error) {
    if (error instanceof Error) {
      console.error("Fetch failed:", error.message)
    }
    throw error
  }
}

// ❌ Bad - swallowing errors
async function fetchUser(id: string) {
  try {
    return await fetch(`/api/users/${id}`).then((r) => r.json())
  } catch (error) {
    // error silently ignored
  }
}
```

## Comments & Documentation

### Only Comment Why, Not What

```typescript
// ✅ Good
// Rate limit to prevent abuse from single IP
const MAX_REQUESTS_PER_MINUTE = 60

// ❌ Bad
// Set max requests per minute
const MAX_REQUESTS_PER_MINUTE = 60
```

### JSDoc for Public APIs

```typescript
/**
 * Fetches a user by ID from the database.
 *
 * @param id - The user's unique identifier
 * @returns The user object or null if not found
 * @throws {Error} If database connection fails
 */
export async function fetchUser(id: string): Promise<User | null> {
  // implementation
}
```

## Related Standards

- {{standards/frontend/server-components}} - When to use "use client"
- {{standards/frontend/components}} - Component composition patterns
- {{standards/backend/api}} - Route Handler conventions
