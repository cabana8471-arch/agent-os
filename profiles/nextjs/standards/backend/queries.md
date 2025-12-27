# Next.js Prisma Queries

> **Related Standards**: See `backend/models.md` for schema design, `backend/database.md` for complete database patterns, `global/performance.md` for optimization thresholds.

## Query Basics

### CRUD Operations

```typescript
import { db } from '@/lib/db'

// Create
const user = await db.user.create({
  data: { email: 'user@example.com', name: 'John' }
})

// Read
const user = await db.user.findUnique({ where: { id: 1 } })
const users = await db.user.findMany()

// Update
const user = await db.user.update({
  where: { id: 1 },
  data: { name: 'Jane' }
})

// Delete
await db.user.delete({ where: { id: 1 } })
```

### Finding Records

```typescript
// Find unique (by unique field)
const user = await db.user.findUnique({
  where: { email: 'user@example.com' }
})

// Find first matching
const admin = await db.user.findFirst({
  where: { role: 'ADMIN' }
})

// Find or throw
const user = await db.user.findUniqueOrThrow({
  where: { id: userId }
})

// Check existence
const exists = await db.user.findFirst({
  where: { email },
  select: { id: true }
})
```

## Filtering

### Basic Filters

```typescript
const users = await db.user.findMany({
  where: {
    // Equality
    role: 'ADMIN',

    // Not equal
    status: { not: 'DELETED' },

    // In list
    role: { in: ['ADMIN', 'MODERATOR'] },

    // Not in list
    status: { notIn: ['BANNED', 'SUSPENDED'] },

    // Comparison
    age: { gte: 18 },        // >= 18
    score: { lt: 100 },      // < 100
    balance: { lte: 1000 },  // <= 1000
    views: { gt: 0 },        // > 0
  }
})
```

### String Filters

```typescript
const users = await db.user.findMany({
  where: {
    // Contains
    name: { contains: 'John' },

    // Case-insensitive contains
    email: { contains: 'gmail', mode: 'insensitive' },

    // Starts with
    name: { startsWith: 'Dr.' },

    // Ends with
    email: { endsWith: '@company.com' },
  }
})
```

### Combining Filters

```typescript
const posts = await db.post.findMany({
  where: {
    // AND (implicit)
    published: true,
    authorId: userId,

    // AND (explicit)
    AND: [
      { published: true },
      { views: { gte: 100 } }
    ],

    // OR
    OR: [
      { title: { contains: 'prisma' } },
      { content: { contains: 'prisma' } }
    ],

    // NOT
    NOT: {
      status: 'DRAFT'
    }
  }
})
```

### Relation Filters

```typescript
// Posts by users with specific role
const posts = await db.post.findMany({
  where: {
    author: {
      role: 'ADMIN'
    }
  }
})

// Users with at least one post
const activeAuthors = await db.user.findMany({
  where: {
    posts: { some: {} }
  }
})

// Users with no posts
const inactiveUsers = await db.user.findMany({
  where: {
    posts: { none: {} }
  }
})

// Users where all posts are published
const users = await db.user.findMany({
  where: {
    posts: {
      every: { published: true }
    }
  }
})
```

## Selecting Fields

### Select Specific Fields

```typescript
const users = await db.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
    // Excludes password, createdAt, etc.
  }
})
```

### Include Relations

```typescript
const user = await db.user.findUnique({
  where: { id: userId },
  include: {
    posts: true,
    profile: true,
  }
})

// Nested include
const user = await db.user.findUnique({
  where: { id: userId },
  include: {
    posts: {
      include: {
        comments: true
      }
    }
  }
})
```

### Select with Relations

```typescript
const user = await db.user.findUnique({
  where: { id: userId },
  select: {
    id: true,
    name: true,
    posts: {
      select: {
        id: true,
        title: true,
      },
      where: { published: true },
      take: 5,
    }
  }
})
```

## Pagination

### Offset Pagination

```typescript
const page = 1
const pageSize = 10

const [users, total] = await db.$transaction([
  db.user.findMany({
    skip: (page - 1) * pageSize,
    take: pageSize,
    orderBy: { createdAt: 'desc' },
  }),
  db.user.count(),
])

const totalPages = Math.ceil(total / pageSize)
```

### Cursor Pagination (Recommended for Large Datasets)

```typescript
const users = await db.user.findMany({
  take: 10,
  skip: 1,  // Skip the cursor itself
  cursor: { id: lastUserId },
  orderBy: { id: 'asc' },
})

const nextCursor = users.length > 0 ? users[users.length - 1].id : null
```

## Sorting

```typescript
const posts = await db.post.findMany({
  orderBy: { createdAt: 'desc' }
})

// Multiple sort fields
const posts = await db.post.findMany({
  orderBy: [
    { featured: 'desc' },
    { createdAt: 'desc' },
  ]
})

// Sort by relation
const users = await db.user.findMany({
  orderBy: {
    posts: { _count: 'desc' }  // By post count
  }
})

// Null handling
const posts = await db.post.findMany({
  orderBy: {
    publishedAt: { sort: 'desc', nulls: 'last' }
  }
})
```

## Aggregations

```typescript
// Count
const userCount = await db.user.count()
const publishedCount = await db.post.count({
  where: { published: true }
})

// Aggregate
const stats = await db.post.aggregate({
  _count: true,
  _avg: { views: true },
  _sum: { views: true },
  _min: { createdAt: true },
  _max: { views: true },
})

// Group by
const postsByAuthor = await db.post.groupBy({
  by: ['authorId'],
  _count: { id: true },
  _avg: { views: true },
  having: {
    id: { _count: { gte: 5 } }
  },
  orderBy: {
    _count: { id: 'desc' }
  }
})
```

## Avoiding N+1 Queries

### Problem: N+1 Query

```typescript
// BAD: N+1 - One query per user for posts
const users = await db.user.findMany()
for (const user of users) {
  const posts = await db.post.findMany({
    where: { authorId: user.id }
  })
}
```

### Solution: Eager Loading

```typescript
// GOOD: Single query with include
const users = await db.user.findMany({
  include: {
    posts: {
      where: { published: true },
      take: 5,
    }
  }
})
```

### Solution: Batch Loading

```typescript
// GOOD: Two queries instead of N+1
const users = await db.user.findMany()
const userIds = users.map(u => u.id)

const posts = await db.post.findMany({
  where: { authorId: { in: userIds } }
})

// Group posts by author
const postsByUser = posts.reduce((acc, post) => {
  acc[post.authorId] = acc[post.authorId] || []
  acc[post.authorId].push(post)
  return acc
}, {} as Record<number, typeof posts>)
```

## Transactions

### Sequential Operations

```typescript
const result = await db.$transaction([
  db.user.create({ data: userData }),
  db.profile.create({ data: profileData }),
  db.settings.create({ data: settingsData }),
])
```

### Interactive Transactions

```typescript
const transferResult = await db.$transaction(async (tx) => {
  const sender = await tx.account.update({
    where: { id: senderId },
    data: { balance: { decrement: amount } },
  })

  if (sender.balance < 0) {
    throw new Error('Insufficient funds')
  }

  const recipient = await tx.account.update({
    where: { id: recipientId },
    data: { balance: { increment: amount } },
  })

  return { sender, recipient }
})
```

## Raw Queries

```typescript
// Tagged template (safe from SQL injection)
const users = await db.$queryRaw`
  SELECT * FROM "User"
  WHERE email = ${email}
  AND role = ${role}
`

// Execute raw
await db.$executeRaw`
  UPDATE "User"
  SET "lastLoginAt" = NOW()
  WHERE id = ${userId}
`

// Using Prisma.sql for dynamic queries
const orderBy = Prisma.sql`ORDER BY "createdAt" DESC`
const users = await db.$queryRaw`
  SELECT * FROM "User"
  ${orderBy}
`
```

## Query Performance

### Use Indexes

```prisma
model Post {
  authorId  Int
  createdAt DateTime

  @@index([authorId])           // Filter by author
  @@index([createdAt])          // Sort by date
  @@index([authorId, createdAt]) // Combined filter and sort
}
```

### Select Only Needed Fields

```typescript
// BAD: Fetches all columns
const users = await db.user.findMany()

// GOOD: Fetches only needed columns
const users = await db.user.findMany({
  select: { id: true, name: true }
})
```

### Limit Results

```typescript
// Always use take for findMany
const recentPosts = await db.post.findMany({
  take: 20,
  orderBy: { createdAt: 'desc' }
})
```

### Use Exists Instead of Count

```typescript
// SLOW: Counts all matching records
const hasOrders = (await db.order.count({
  where: { userId }
})) > 0

// FAST: Stops at first match
const hasOrders = (await db.order.findFirst({
  where: { userId },
  select: { id: true }
})) !== null
```

## Best Practices

1. **Always include relations explicitly** - Avoid lazy loading patterns
2. **Use select for large tables** - Only fetch columns you need
3. **Implement pagination** - Never fetch unbounded results
4. **Index filtered/sorted columns** - Check query performance
5. **Use transactions for related writes** - Maintain data consistency
6. **Prefer cursor pagination** - Better performance for large datasets
7. **Monitor slow queries** - Enable Prisma query logging in development
8. **Batch related queries** - Use `$transaction` for multiple reads
