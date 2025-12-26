# Next.js Components

## Component Patterns

### Server Components (Default)

For displaying data without interactivity:

```typescript
// components/UserCard.tsx
import { User } from '@/types'

interface UserCardProps {
  user: User
  featured?: boolean
}

export async function UserCard({ user, featured }: UserCardProps) {
  const userStats = await fetchUserStats(user.id)

  return (
    <div className={featured ? 'featured' : ''}>
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <p>Posts: {userStats.postCount}</p>
    </div>
  )
}
```

### Client Components

For interactive components:

```typescript
"use client"

import { useState } from 'react'
import { updateUser } from '@/app/actions'

interface UserFormProps {
  userId: string
  initialName: string
}

export function UserForm({ userId, initialName }: UserFormProps) {
  const [name, setName] = useState(initialName)

  const handleSave = async () => {
    await updateUser(userId, name)
  }

  return (
    <div>
      <input value={name} onChange={(e) => setName(e.target.value)} />
      <button onClick={handleSave}>Save</button>
    </div>
  )
}
```

## Shared Components

Components used across multiple features:

```typescript
// src/components/common/Button.tsx
"use client"

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
}

export function Button({
  variant = 'primary',
  size = 'md',
  children,
  ...props
}: ButtonProps) {
  const baseStyles = 'font-semibold rounded transition'
  const variants = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300',
  }
  const sizes = {
    sm: 'px-2 py-1 text-sm',
    md: 'px-4 py-2',
    lg: 'px-6 py-3 text-lg',
  }

  return (
    <button className={`${baseStyles} ${variants[variant]} ${sizes[size]}`} {...props}>
      {children}
    </button>
  )
}
```

## Component Composition

### Server Component with Client Child

```typescript
// app/dashboard/page.tsx (Server)
import { DashboardClient } from '@/components/dashboard-client'
import { fetchDashboardData } from '@/lib/db'

export default async function DashboardPage() {
  const data = await fetchDashboardData()

  return <DashboardClient data={data} />
}
```

```typescript
// components/dashboard-client.tsx (Client)
"use client"

import { useState } from 'react'

export function DashboardClient({ data }: { data: DashboardData }) {
  const [selectedTab, setSelectedTab] = useState('overview')

  return (
    <div>
      <nav>
        {['overview', 'analytics', 'reports'].map((tab) => (
          <button
            key={tab}
            onClick={() => setSelectedTab(tab)}
            className={selectedTab === tab ? 'active' : ''}
          >
            {tab}
          </button>
        ))}
      </nav>
      <main>{renderTabContent(selectedTab, data)}</main>
    </div>
  )
}
```

### Compound Components

Group related components together:

```typescript
// components/Dialog/index.tsx
"use client"

import { createContext, useContext, useState, ReactNode } from 'react'

interface DialogContextType {
  open: boolean
  setOpen: (open: boolean) => void
}

const DialogContext = createContext<DialogContextType | null>(null)

interface DialogProps {
  children: ReactNode
}

export function Dialog({ children }: DialogProps) {
  const [open, setOpen] = useState(false)

  return (
    <DialogContext.Provider value={{ open, setOpen }}>
      {children}
    </DialogContext.Provider>
  )
}

export function DialogTrigger({ children }: { children: ReactNode }) {
  const context = useContext(DialogContext)
  if (!context) throw new Error('DialogTrigger must be used inside Dialog')

  return (
    <button onClick={() => context.setOpen(true)}>
      {children}
    </button>
  )
}

export function DialogContent({ children }: { children: ReactNode }) {
  const context = useContext(DialogContext)
  if (!context) throw new Error('DialogContent must be used inside Dialog')

  return (
    context.open && (
      <div onClick={() => context.setOpen(false)}>
        <div onClick={(e) => e.stopPropagation()}>
          {children}
        </div>
      </div>
    )
  )
}

// Usage
<Dialog>
  <DialogTrigger>Open Settings</DialogTrigger>
  <DialogContent>
    <h2>Settings</h2>
    <p>Your settings here</p>
  </DialogContent>
</Dialog>
```

## Feature-Based Organization

Organize components by feature, not by type:

```
src/components/
├── dashboard/
│   ├── DashboardLayout.tsx
│   ├── StatsCard.tsx
│   ├── ChartSection.tsx
│   └── RecentActivity.tsx
│
├── auth/
│   ├── LoginForm.tsx
│   ├── SignupForm.tsx
│   └── PasswordReset.tsx
│
├── users/
│   ├── UserList.tsx
│   ├── UserCard.tsx
│   └── UserProfile.tsx
│
└── common/
    ├── Button.tsx
    ├── Card.tsx
    ├── Modal.tsx
    └── Loading.tsx
```

## Props Type Definition

Use interfaces for component props:

```typescript
// ✅ Good
interface UserCardProps {
  user: User
  onDelete?: (id: string) => void
  featured?: boolean
}

export function UserCard({ user, onDelete, featured }: UserCardProps) {
  return <div>...</div>
}

// ✅ Good - Extending HTML elements
interface CustomButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary'
}

export function CustomButton({ variant, ...props }: CustomButtonProps) {
  return <button {...props} />
}
```

## Reusable Patterns

### Controlled Component

```typescript
"use client"

interface ControlledInputProps {
  value: string
  onChange: (value: string) => void
  placeholder?: string
}

export function ControlledInput({
  value,
  onChange,
  placeholder,
}: ControlledInputProps) {
  return (
    <input
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder={placeholder}
    />
  )
}
```

### Render Prop Pattern

```typescript
"use client"

interface ListProps<T> {
  items: T[]
  renderItem: (item: T, index: number) => React.ReactNode
  emptyMessage?: string
}

export function List<T>({
  items,
  renderItem,
  emptyMessage = 'No items',
}: ListProps<T>) {
  return items.length > 0 ? (
    <ul>{items.map((item, i) => <li key={i}>{renderItem(item, i)}</li>)}</ul>
  ) : (
    <p>{emptyMessage}</p>
  )
}

// Usage
<List
  items={users}
  renderItem={(user) => <div>{user.name}</div>}
  emptyMessage="No users found"
/>
```

## Naming Conventions

- **Page components**: No suffix (e.g., `HomePage.tsx` not `HomePageComponent.tsx`)
- **Reusable components**: Short, descriptive names (`Button.tsx`, `Card.tsx`)
- **Feature containers**: Feature name (`UserList.tsx`, `DashboardLayout.tsx`)
- **Single responsibility**: One component per file (in most cases)

## Performance

### Lazy Loading Components

```typescript
// app/page.tsx
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <p>Loading chart...</p>,
})

export default function Page() {
  return (
    <div>
      <HeavyChart />
    </div>
  )
}
```

### Memoization

```typescript
"use client"

import { memo } from 'react'

interface UserItemProps {
  user: User
}

export const UserItem = memo(function UserItem({ user }: UserItemProps) {
  return <div>{user.name}</div>
}, (prevProps, nextProps) => prevProps.user.id === nextProps.user.id)
```

## Related Standards

- {{standards/frontend/server-components}} - When to use Server vs Client
- {{standards/global/coding-style}} - Naming conventions
- {{standards/frontend/performance}} - Component optimization
