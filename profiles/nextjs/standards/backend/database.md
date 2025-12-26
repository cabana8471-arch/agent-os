# Database Integration

## Prisma ORM (Recommended)

Prisma is the recommended ORM for Next.js. It provides type-safe database access.

### Setup

```bash
npm install @prisma/client
npm install -D prisma
npx prisma init
```

### Schema Definition

```prisma
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id    Int     @id @default(autoincrement())
  email String  @unique
  name  String?
  posts Post[]

  @@index([email])
}

model Post {
  id    Int     @id @default(autoincrement())
  title String
  content String
  published Boolean @default(false)
  author    User    @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId  Int
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
  @@fulltext([title, content]) // MySQL fulltext index
}
```

### Creating Database Singleton

```typescript
// lib/db.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = global as unknown as { prisma: PrismaClient }

export const db =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: ['error', 'warn'], // Only log errors in production
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db
```

### Using in Server Components

```typescript
// app/users/page.tsx
import { db } from '@/lib/db'

export default async function UsersPage() {
  const users = await db.user.findMany({
    select: { id: true, name: true, email: true },
    orderBy: { createdAt: 'desc' },
    take: 10,
  })

  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

### Using in Server Actions

```typescript
// app/actions.ts
'use server'

import { db } from '@/lib/db'
import { revalidatePath } from 'next/cache'

export async function createUser(formData: FormData) {
  const email = formData.get('email') as string
  const name = formData.get('name') as string

  const user = await db.user.create({
    data: { email, name },
  })

  revalidatePath('/users')
  return user
}
```

### Using in Route Handlers

```typescript
// app/api/users/route.ts
import { db } from '@/lib/db'

export async function GET(request: Request) {
  const users = await db.user.findMany()
  return Response.json(users)
}

export async function POST(request: Request) {
  const { email, name } = await request.json()

  const user = await db.user.create({
    data: { email, name },
  })

  return Response.json(user, { status: 201 })
}
```

## Common Query Patterns

### Create

```typescript
const user = await db.user.create({
  data: {
    email: 'user@example.com',
    name: 'John Doe',
  },
})

// With relations
const post = await db.post.create({
  data: {
    title: 'My Post',
    content: 'Content here',
    author: {
      connect: { id: userId },
    },
  },
})
```

### Read

```typescript
// Find one
const user = await db.user.findUnique({
  where: { id: userId },
})

// Find first matching
const user = await db.user.findFirst({
  where: { email: 'user@example.com' },
})

// Find many
const users = await db.user.findMany({
  where: { NOT: { posts: { none: {} } } }, // Users with posts
  select: { id: true, name: true, posts: true },
  orderBy: { createdAt: 'desc' },
  skip: 0,
  take: 10,
})
```

### Update

```typescript
const user = await db.user.update({
  where: { id: userId },
  data: { name: 'Updated Name' },
})

// Update many
await db.user.updateMany({
  where: { role: 'OLD_ROLE' },
  data: { role: 'NEW_ROLE' },
})
```

### Delete

```typescript
await db.user.delete({
  where: { id: userId },
})

// Delete many
await db.user.deleteMany({
  where: { createdAt: { lt: thirtyDaysAgo } },
})
```

## Advanced Patterns

### Transactions

```typescript
'use server'

import { db } from '@/lib/db'

export async function transferFunds(
  fromUserId: string,
  toUserId: string,
  amount: number
) {
  const result = await db.$transaction([
    db.account.update({
      where: { userId: fromUserId },
      data: { balance: { decrement: amount } },
    }),
    db.account.update({
      where: { userId: toUserId },
      data: { balance: { increment: amount } },
    }),
  ])

  return result
}
```

### Raw SQL

```typescript
const users = await db.$queryRaw`SELECT * FROM User WHERE email = ${email}`

// Parameterized query
await db.$executeRaw`UPDATE User SET name = ${name} WHERE id = ${id}`
```

### Aggregations

```typescript
const count = await db.post.count()

const stats = await db.post.aggregate({
  _count: true,
  _avg: { likes: true },
  _max: { createdAt: true },
})
```

### Distinct

```typescript
const categories = await db.post.findMany({
  distinct: ['category'],
  select: { category: true },
})
```

### Group By

```typescript
const postsByAuthor = await db.post.groupBy({
  by: ['authorId'],
  _count: true,
  orderBy: {
    _count: {
      id: 'desc',
    },
  },
})
```

## Connection Pool Configuration

For production, use connection pooling:

```env
# .env.production
DATABASE_URL="postgresql://user:password@host:5432/db?schema=public&sslmode=require&connection_limit=5"
```

### PgBouncer Configuration

```
pool_mode = transaction
max_client_conn = 100
default_pool_size = 25
reserve_pool_size = 5
reserve_pool_timeout = 3
```

## Migrations

### Create Migration

```bash
npx prisma migrate dev --name add_posts_table
```

### Deploy Migrations

```bash
npx prisma migrate deploy
```

### Reset Database (Development Only)

```bash
npx prisma migrate reset
```

## Error Handling

```typescript
import { Prisma } from '@prisma/client'

'use server'

export async function createUser(data: unknown) {
  try {
    const user = await db.user.create({
      data: data as Prisma.UserCreateInput,
    })
    return { success: true, user }
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      if (error.code === 'P2002') {
        // Unique constraint failed
        return { error: 'Email already in use' }
      }
      if (error.code === 'P2025') {
        // Record not found
        return { error: 'User not found' }
      }
    }

    console.error('Database error:', error)
    return { error: 'Database error' }
  }
}
```

## Drizzle ORM (Alternative)

More lightweight alternative to Prisma:

### Setup

```bash
npm install drizzle-orm postgres
npm install -D drizzle-kit
```

### Schema

```typescript
// lib/schema.ts
import { pgTable, serial, text, boolean, timestamp } from 'drizzle-orm/pg-core'

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').unique(),
  name: text('name'),
  createdAt: timestamp('created_at').defaultNow(),
})

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title'),
  content: text('content'),
  authorId: serial('author_id').references(() => users.id),
  published: boolean('published').default(false),
  createdAt: timestamp('created_at').defaultNow(),
})
```

### Database Client

```typescript
// lib/db.ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

const client = postgres(process.env.DATABASE_URL!)
export const db = drizzle(client)
```

### Queries

```typescript
import { db } from '@/lib/db'
import { users, posts } from '@/lib/schema'
import { eq } from 'drizzle-orm'

// Find user
const user = await db.select().from(users).where(eq(users.id, 1))

// Create
await db.insert(users).values({
  email: 'user@example.com',
  name: 'John',
})

// Update
await db.update(users).set({ name: 'Jane' }).where(eq(users.id, 1))

// Delete
await db.delete(users).where(eq(users.id, 1))
```

## Best Practices

1. **Use transactions for related operations** - Ensures consistency
2. **Index foreign keys** - Speeds up joins
3. **Use select to fetch only needed fields** - Reduces data transfer
4. **Implement pagination** - Avoid loading entire tables
5. **Cache frequently accessed data** - Reduce database hits
6. **Monitor query performance** - Use query logs
7. **Use prepared statements** - Prevents SQL injection
8. **Handle errors gracefully** - Provide user-friendly messages
9. **Soft deletes for important data** - Don't permanently delete
10. **Regular backups** - Critical for production

## Related Standards

- {{standards/backend/api}} - API endpoints consuming data
- {{standards/backend/server-actions}} - Server Actions querying data
- {{standards/global/error-handling}} - Error handling patterns
