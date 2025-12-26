# React Server Components

## Overview

Server Components are the default in Next.js 13+. They run ONLY on the server, never sent to the client. This is a paradigm shift from traditional React.

**Key Benefits:**
- Access databases directly (no API layer)
- Secure server-only operations (auth tokens, API keys)
- Reduced JavaScript bundle size
- Better SEO (HTML rendered server-side)
- Sequential data fetching

## Server Components (Default)

Components without `"use client"` are Server Components.

### Basic Server Component

```typescript
// app/blog/page.tsx
import { fetchPosts } from '@/lib/db'

// This is a Server Component by default (no "use client")
export default async function BlogPage() {
  const posts = await fetchPosts()

  return (
    <div>
      <h1>Blog Posts</h1>
      {posts.map((post) => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.excerpt}</p>
        </article>
      ))}
    </div>
  )
}
```

### Server Component Features

```typescript
// ✅ Server Components CAN do:

// 1. Async functions
export default async function Page() {
  const data = await fetch('https://api.example.com/data')
  return <div>{data}</div>
}

// 2. Direct database access
import { db } from '@/lib/db'

export default async function Users() {
  const users = await db.user.findMany()
  return <ul>{users.map((u) => <li key={u.id}>{u.name}</li>)}</ul>
}

// 3. Server-only secrets
export default async function Page() {
  const apiKey = process.env.SECRET_API_KEY
  const data = await fetch(`https://api.example.com?key=${apiKey}`)
  return <div>{data}</div>
}

// 4. Direct database queries without API layer
export default async function Dashboard() {
  const stats = await db.query('SELECT COUNT(*) FROM users')
  return <div>Total users: {stats.count}</div>
}
```

### Server Component Limitations

```typescript
// ❌ Server Components CANNOT do:

// Event listeners
export default function Button() {
  // ❌ ERROR - onClick handler requires "use client"
  return <button onClick={() => alert('clicked')}>Click me</button>
}

// Hooks (useState, useEffect)
export default function Counter() {
  // ❌ ERROR - useState requires "use client"
  const [count, setCount] = useState(0)
  return <div>{count}</div>
}

// Context
import { createContext } from 'react'
const ThemeContext = createContext()

// ❌ ERROR - Context only works in Client Components
export default function App() {
  return <ThemeContext.Provider value="dark">...</ThemeContext.Provider>
}

// Browser APIs (localStorage, window, etc.)
export default function Page() {
  // ❌ ERROR - window is undefined on server
  localStorage.setItem('key', 'value')
  return <div></div>
}
```

## Client Components

Mark with `"use client"` at the top of the file:

```typescript
"use client"

import { useState } from 'react'

export default function Counter() {
  const [count, setCount] = useState(0)

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  )
}
```

### Client Component Features

```typescript
"use client"

// Event handlers
export function Button() {
  return <button onClick={() => alert('clicked')}>Click me</button>
}

// Hooks
export function Counter() {
  const [count, useState] = useState(0)
  return <div>{count}</div>
}

// Context
const ThemeContext = createContext()

export function App() {
  return <ThemeContext.Provider value="dark">...</ThemeContext.Provider>
}

// Browser APIs
export function Storage() {
  const data = localStorage.getItem('key')
  return <div>{data}</div>
}

// Client-side data fetching
export function UserList() {
  const [users, setUsers] = useState([])

  useEffect(() => {
    fetch('/api/users')
      .then((r) => r.json())
      .then(setUsers)
  }, [])

  return <ul>{users.map((u) => <li key={u.id}>{u.name}</li>)}</ul>
}
```

### Client Component Limitations

```typescript
"use client"

// ❌ CANNOT use async directly in component
export default async function Page() {
  // ERROR - "use client" components cannot be async
  const data = await fetch('...')
  return <div>{data}</div>
}

// Workaround: Fetch data in parent Server Component
// or use useEffect + client-side fetch
```

## Server Actions

Functions that run exclusively on the server, callable from Server or Client Components:

### Basic Server Action

```typescript
// app/actions.ts
"use server"

import { db } from '@/lib/db'

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string
  const email = formData.get('email') as string

  const user = await db.user.create({
    data: { name, email },
  })

  return user
}
```

### Call from Client Component

```typescript
"use client"

import { createUser } from '@/app/actions'

export function SignupForm() {
  return (
    <form action={createUser}>
      <input name="name" type="text" />
      <input name="email" type="email" />
      <button type="submit">Sign up</button>
    </form>
  )
}
```

### Call Programmatically

```typescript
"use client"

import { createUser } from '@/app/actions'
import { useTransition } from 'react'

export function SignupForm() {
  const [pending, startTransition] = useTransition()

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    startTransition(() => createUser(formData))
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" />
      <button disabled={pending}>{pending ? 'Saving...' : 'Save'}</button>
    </form>
  )
}
```

## Mixing Server & Client Components

The optimal pattern: Server Component at top level, Client Components inside:

```typescript
// app/dashboard/page.tsx - SERVER COMPONENT
import { fetchUserData } from '@/lib/db'
import DashboardClient from './dashboard-client'

export default async function DashboardPage() {
  const userData = await fetchUserData()

  // Pass data to Client Component
  return <DashboardClient user={userData} />
}
```

```typescript
// app/dashboard/dashboard-client.tsx - CLIENT COMPONENT
"use client"

import { useState } from 'react'

interface DashboardClientProps {
  user: User
}

export default function DashboardClient({ user }: DashboardClientProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false)

  return (
    <div>
      <header>
        <button onClick={() => setSidebarOpen(!sidebarOpen)}>
          Toggle Sidebar
        </button>
      </header>
      <main>
        <h1>Welcome, {user.name}</h1>
      </main>
    </div>
  )
}
```

## Decision Tree

Use this to decide Server vs Client Component:

```
Does this component need to:

  ├─ Access databases or secrets? → Server Component ✅
  ├─ Handle user interactions (click, form)? → Client Component ✅
  ├─ Use hooks (useState, useEffect)? → Client Component ✅
  ├─ Use browser APIs (localStorage, window)? → Client Component ✅
  ├─ Use context or reducers? → Client Component ✅
  └─ Just render data? → Server Component ✅
```

## Best Practices

1. **Default to Server Components** - Use Client Components only when needed
2. **Fetch in Server Components** - Not in useEffect
3. **Keep Client Components small** - Move interactivity to leaf components
4. **Pass data via props** - From Server to Client Component
5. **Use Server Actions** - For mutations from Client Components
6. **Separate concerns** - Server and Client components in separate files

## Common Mistakes

```typescript
// ❌ WRONG - Async Client Component
"use client"
export default async function Page() {
  const data = await fetchData()  // ERROR
  return <div>{data}</div>
}

// ✅ CORRECT - Fetch in Server Component
export default async function Page() {
  const data = await fetchData()
  return <PageClient data={data} />
}

// ❌ WRONG - Inefficient data fetching
"use client"
export function UserList() {
  const [users, setUsers] = useState([])
  useEffect(() => {
    fetch('/api/users').then((r) => r.json()).then(setUsers)
  }, [])
  return <ul>{users.map((u) => <li>{u.name}</li>)}</ul>
}

// ✅ CORRECT - Fetch server-side
export async function UserList() {
  const users = await db.user.findMany()
  return <ul>{users.map((u) => <li>{u.name}</li>)}</ul>
}
```

## Related Standards

- {{standards/backend/server-actions}} - Server Actions patterns
- {{standards/frontend/components}} - Component composition
- {{standards/frontend/data-fetching}} - Data fetching strategies
