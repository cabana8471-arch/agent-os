# Next.js Prisma Models

> **Related Standards**: See `backend/migrations.md` for schema change workflow, `backend/queries.md` for query optimization, `backend/database.md` for complete database patterns.

## Schema File Location

```
prisma/
├── schema.prisma      # Main schema file
└── migrations/        # Generated migrations
```

## Model Definition Patterns

### Basic Model Structure

```prisma
// prisma/schema.prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  role      Role     @default(USER)
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@map("users")  // Table name in database
}

enum Role {
  USER
  ADMIN
  MODERATOR
}
```

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Model names | PascalCase, singular | `User`, `BlogPost` |
| Field names | camelCase | `createdAt`, `firstName` |
| Enum names | PascalCase | `Role`, `Status` |
| Enum values | SCREAMING_SNAKE_CASE | `USER`, `PENDING_APPROVAL` |
| Table mapping | snake_case, plural | `@@map("blog_posts")` |
| Column mapping | snake_case | `@map("first_name")` |

## Field Types

### Scalar Types

```prisma
model Example {
  // Identifiers
  id        Int      @id @default(autoincrement())
  uuid      String   @id @default(uuid())
  cuid      String   @id @default(cuid())

  // Strings
  name      String
  bio       String?  // Optional
  content   String   @db.Text  // Long text

  // Numbers
  age       Int
  price     Decimal  @db.Decimal(10, 2)
  rating    Float

  // Boolean
  isActive  Boolean  @default(true)

  // Dates
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  birthDate DateTime @db.Date

  // JSON (PostgreSQL)
  metadata  Json?
}
```

### ID Strategies

```prisma
// Auto-increment (default for PostgreSQL)
model Post {
  id Int @id @default(autoincrement())
}

// UUID (recommended for distributed systems)
model Order {
  id String @id @default(uuid())
}

// CUID (collision-resistant, URL-safe)
model Session {
  id String @id @default(cuid())
}

// Composite primary key
model PostTag {
  postId Int
  tagId  Int
  @@id([postId, tagId])
}
```

## Relationships

### One-to-Many

```prisma
model User {
  id    Int    @id @default(autoincrement())
  posts Post[]
}

model Post {
  id       Int  @id @default(autoincrement())
  author   User @relation(fields: [authorId], references: [id])
  authorId Int

  @@index([authorId])
}
```

### One-to-One

```prisma
model User {
  id      Int      @id @default(autoincrement())
  profile Profile?
}

model Profile {
  id     Int  @id @default(autoincrement())
  user   User @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId Int  @unique

  @@index([userId])
}
```

### Many-to-Many (Implicit)

```prisma
model Post {
  id    Int    @id @default(autoincrement())
  tags  Tag[]
}

model Tag {
  id    Int    @id @default(autoincrement())
  posts Post[]
}
```

### Many-to-Many (Explicit - Recommended)

```prisma
model Post {
  id       Int       @id @default(autoincrement())
  postTags PostTag[]
}

model Tag {
  id       Int       @id @default(autoincrement())
  postTags PostTag[]
}

model PostTag {
  post      Post     @relation(fields: [postId], references: [id], onDelete: Cascade)
  postId    Int
  tag       Tag      @relation(fields: [tagId], references: [id], onDelete: Cascade)
  tagId     Int
  createdAt DateTime @default(now())

  @@id([postId, tagId])
  @@index([tagId])
}
```

### Self-Relations

```prisma
model Category {
  id       Int        @id @default(autoincrement())
  name     String
  parent   Category?  @relation("CategoryToCategory", fields: [parentId], references: [id])
  parentId Int?
  children Category[] @relation("CategoryToCategory")

  @@index([parentId])
}
```

## Cascade Behaviors

```prisma
model Post {
  author   User @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId Int
}

// Options:
// Cascade    - Delete related records
// Restrict   - Prevent deletion if related records exist
// NoAction   - Similar to Restrict (database-level)
// SetNull    - Set foreign key to null
// SetDefault - Set foreign key to default value
```

## Indexes and Constraints

### Single Column Index

```prisma
model User {
  email String

  @@index([email])
}
```

### Composite Index

```prisma
model Order {
  userId    Int
  status    String
  createdAt DateTime

  @@index([userId, status])
  @@index([createdAt])
}
```

### Unique Constraints

```prisma
model User {
  email String @unique

  // Composite unique
  @@unique([tenantId, email])
}
```

### Full-Text Search (PostgreSQL)

```prisma
model Post {
  title   String
  content String

  @@fulltext([title, content])
}
```

## Soft Deletes Pattern

```prisma
model Post {
  id        Int       @id @default(autoincrement())
  title     String
  deletedAt DateTime?

  @@index([deletedAt])
}
```

```typescript
// Query active records only
const posts = await db.post.findMany({
  where: { deletedAt: null }
})

// Soft delete
await db.post.update({
  where: { id },
  data: { deletedAt: new Date() }
})
```

## Multi-Tenancy Pattern

```prisma
model Tenant {
  id    Int     @id @default(autoincrement())
  name  String
  users User[]
  posts Post[]
}

model User {
  id       Int    @id @default(autoincrement())
  tenant   Tenant @relation(fields: [tenantId], references: [id])
  tenantId Int

  @@index([tenantId])
}

model Post {
  id       Int    @id @default(autoincrement())
  tenant   Tenant @relation(fields: [tenantId], references: [id])
  tenantId Int

  @@index([tenantId])
}
```

## TypeScript Types

Prisma generates TypeScript types automatically:

```typescript
import { User, Post, Prisma } from '@prisma/client'

// Use generated types
function createUser(data: Prisma.UserCreateInput): Promise<User> {
  return db.user.create({ data })
}

// Type for user with posts
type UserWithPosts = Prisma.UserGetPayload<{
  include: { posts: true }
}>
```

## Best Practices

1. **Index foreign keys** - Always add `@@index` on foreign key columns
2. **Use explicit many-to-many** - Allows adding metadata to join tables
3. **Map to database conventions** - Use `@map` and `@@map` for snake_case
4. **Add timestamps** - Include `createdAt` and `updatedAt` on all models
5. **Use enums** - Define allowed values in schema, not application code
6. **Cascade carefully** - Consider data retention needs before using Cascade
7. **Document relationships** - Use comments for complex relationships
8. **Avoid nullable where possible** - Prefer defaults over optional fields
