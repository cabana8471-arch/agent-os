# Database Standards - Drizzle ORM

This standard documents all database patterns and practices for the SEO Optimization application using Drizzle ORM with PostgreSQL.

## I. Installation & Setup

### Install Dependencies
```bash
pnpm install drizzle-orm postgres pg
pnpm install -D drizzle-kit
```

### File Structure
```
src/db/
├── index.ts                 # Database client export
├── schema/
│   ├── index.ts            # Re-export all schemas
│   ├── user.ts             # User, session, account tables
│   ├── project.ts          # Project and relations
│   ├── scanned-page.ts     # Scanned pages and scan history
│   ├── recommendation.ts   # SEO recommendations
│   └── notification.ts     # Notifications
└── queries/                # Optional: reusable query functions
```

---

## II. Database Connection

### Initialize Drizzle Client

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

// Create postgres client
const client = postgres(process.env.DATABASE_URL!)

// Initialize Drizzle
export const db = drizzle(client, { schema })
```

### Environment Configuration

```bash
# .env.local
DATABASE_URL=postgresql://user:password@host:port/database
```

### Using with Vercel Postgres

```typescript
// For Vercel Postgres
import { sql } from '@vercel/postgres'

const client = sql
export const db = drizzle(client, { schema })
```

---

## III. Schema Definition

### Basic Table Definition

```typescript
// src/db/schema/user.ts
import { pgTable, text, varchar, timestamp, serial } from 'drizzle-orm/pg-core'
import { InferSelectModel, InferInsertModel } from 'drizzle-orm'

export const user = pgTable('user', {
  id: text('id').primaryKey(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  name: varchar('name', { length: 255 }),
  image: text('image'),
  emailVerified: timestamp('email_verified', { mode: 'date' }),
  createdAt: timestamp('created_at', { mode: 'date' }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { mode: 'date' }).defaultNow().notNull(),
})

// Type exports
export type User = InferSelectModel<typeof user>
export type NewUser = InferInsertModel<typeof user>
```

### Table with Foreign Keys

```typescript
// src/db/schema/project.ts
import { pgTable, text, varchar, timestamp, relations } from 'drizzle-orm/pg-core'
import { user } from './user'

export const project = pgTable('project', {
  id: text('id').primaryKey(),
  name: varchar('name', { length: 255 }).notNull(),
  url: text('url').notNull(),
  userId: text('user_id').notNull().references(() => user.id, { onDelete: 'cascade' }),
  description: text('description'),
  createdAt: timestamp('created_at', { mode: 'date' }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { mode: 'date' }).defaultNow().notNull(),
})

export type Project = InferSelectModel<typeof project>
export type NewProject = InferInsertModel<typeof project>
```

### Table Relations

```typescript
// src/db/schema/project.ts (continued)
import { relations } from 'drizzle-orm'

export const projectRelations = relations(project, ({ one, many }) => ({
  user: one(user, {
    fields: [project.userId],
    references: [user.id],
  }),
  scannedPages: many(scannedPage),
  scanHistory: many(scanHistory),
}))
```

### Using Enums

```typescript
// src/db/schema/notification.ts
import { pgTable, pgEnum, text, varchar, boolean } from 'drizzle-orm/pg-core'

export const notificationTypeEnum = pgEnum('notification_type', ['info', 'success', 'warning', 'error'])
export const priorityEnum = pgEnum('priority', ['low', 'medium', 'high', 'critical'])

export const notification = pgTable('notification', {
  id: text('id').primaryKey(),
  userId: text('user_id').notNull().references(() => user.id, { onDelete: 'cascade' }),
  type: notificationTypeEnum('type').notNull(),
  priority: priorityEnum('priority').default('medium'),
  title: varchar('title', { length: 255 }).notNull(),
  message: text('message').notNull(),
  read: boolean('read').default(false),
})
```

---

## IV. Type Safety

### Inferred Types

```typescript
import type { InferSelectModel, InferInsertModel } from 'drizzle-orm'

// Select type (what you get from database)
export type User = InferSelectModel<typeof user>
// Equivalent to: { id: string; email: string; name: string | null; ... }

// Insert type (what you pass to insert)
export type NewUser = InferInsertModel<typeof user>
// Equivalent to: { id: string; email: string; name?: string; ... }

// Update type (partial of select type)
export type UpdateUser = Partial<User>
```

### Using Inferred Types

```typescript
// Type-safe function signatures
async function createUser(data: NewUser): Promise<User> {
  const [user] = await db.insert(user).values(data).returning()
  return user
}

async function updateUser(id: string, data: Partial<NewUser>): Promise<User> {
  const [user] = await db.update(user)
    .set(data)
    .where(eq(user.id, id))
    .returning()
  return user
}

async function getUser(id: string): Promise<User | undefined> {
  return await db.query.user.findFirst({
    where: eq(user.id, id),
  })
}
```

---

## V. CRUD Operations

### Create

```typescript
// Simple insert
async function createProject(data: NewProject) {
  const [project] = await db
    .insert(project)
    .values({
      ...data,
      id: crypto.randomUUID(),
    })
    .returning()

  return project
}

// Batch insert
async function insertMultipleProjects(projects: NewProject[]) {
  return await db
    .insert(project)
    .values(projects.map(p => ({ ...p, id: crypto.randomUUID() })))
    .returning()
}
```

### Read

```typescript
import { eq, and, or, like, gt, desc, asc } from 'drizzle-orm'

// Find first matching record
async function findUserByEmail(email: string) {
  return await db.query.user.findFirst({
    where: eq(user.email, email),
  })
}

// Find all with filters
async function getUserProjects(userId: string) {
  return await db.query.project.findMany({
    where: eq(project.userId, userId),
    orderBy: [desc(project.createdAt)],
    limit: 10,
  })
}

// Complex filters with AND/OR
async function searchProjects(userId: string, searchTerm: string) {
  return await db
    .select()
    .from(project)
    .where(
      and(
        eq(project.userId, userId),
        or(
          like(project.name, `%${searchTerm}%`),
          like(project.description, `%${searchTerm}%`)
        )
      )
    )
    .orderBy(desc(project.createdAt))
}

// Count records
async function countUserProjects(userId: string) {
  const [result] = await db
    .select({ count: count() })
    .from(project)
    .where(eq(project.userId, userId))

  return result.count
}
```

### Update

```typescript
// Update single record
async function updateProjectName(projectId: string, newName: string) {
  const [updated] = await db
    .update(project)
    .set({ name: newName, updatedAt: new Date() })
    .where(eq(project.id, projectId))
    .returning()

  return updated
}

// Update multiple records
async function markNotificationsAsRead(userId: string) {
  return await db
    .update(notification)
    .set({ read: true, updatedAt: new Date() })
    .where(eq(notification.userId, userId))
    .returning()
}
```

### Delete

```typescript
// Delete single record
async function deleteProject(projectId: string) {
  const [deleted] = await db
    .delete(project)
    .where(eq(project.id, projectId))
    .returning()

  return deleted
}

// Delete with condition
async function deleteOldNotifications(olderThanDate: Date) {
  return await db
    .delete(notification)
    .where(lt(notification.createdAt, olderThanDate))
    .returning()
}
```

---

## VI. Relational Queries

### Eager Loading with Relations

```typescript
// Fetch project with user and scanned pages
async function getProjectWithDetails(projectId: string) {
  return await db.query.project.findFirst({
    where: eq(project.id, projectId),
    with: {
      user: {
        columns: { id: true, name: true, email: true }, // Only select needed columns
      },
      scannedPages: {
        with: {
          recommendations: true,
        },
        orderBy: [desc(scannedPage.scannedAt)],
        limit: 50,
      },
    },
  })
}

// Complex nested relations
async function getUserDashboard(userId: string) {
  return await db.query.user.findFirst({
    where: eq(user.id, userId),
    with: {
      projects: {
        with: {
          scannedPages: {
            with: {
              recommendations: true,
            },
            limit: 5,
            orderBy: [desc(scannedPage.scannedAt)],
          },
        },
        limit: 10,
      },
    },
  })
}
```

### Selecting Specific Columns

```typescript
// Select only needed columns to reduce payload
async function getProjectsList(userId: string) {
  return await db
    .select({
      id: project.id,
      name: project.name,
      url: project.url,
      createdAt: project.createdAt,
    })
    .from(project)
    .where(eq(project.userId, userId))
    .orderBy(desc(project.createdAt))
}
```

---

## VII. Transactions

### Basic Transaction

```typescript
// Execute multiple operations atomically
async function createProjectWithInitialPage(
  userId: string,
  projectData: NewProject,
  pageData: NewScannedPage
) {
  const result = await db.transaction(async (tx) => {
    // Create project
    const [newProject] = await tx
      .insert(project)
      .values({ ...projectData, userId, id: crypto.randomUUID() })
      .returning()

    // Create initial scanned page
    await tx.insert(scannedPage).values({
      ...pageData,
      projectId: newProject.id,
      id: crypto.randomUUID(),
    })

    // Create notification
    await tx.insert(notification).values({
      userId,
      type: 'success',
      title: 'Project Created',
      message: `Project "${newProject.name}" has been created`,
      id: crypto.randomUUID(),
    })

    return newProject
  })

  return result
}
```

### Transaction with Rollback

```typescript
// Transactions automatically rollback on error
async function scanProjectPages(projectId: string, urls: string[]) {
  try {
    return await db.transaction(async (tx) => {
      const pages = urls.map(url => ({
        projectId,
        url,
        id: crypto.randomUUID(),
      }))

      const scanned = await tx.insert(scannedPage).values(pages).returning()

      // If this fails, entire transaction rolls back
      await tx.insert(scanHistory).values({
        projectId,
        scannedCount: scanned.length,
        id: crypto.randomUUID(),
      })

      return scanned
    })
  } catch (error) {
    console.error('Scan failed, all changes reverted:', error)
    throw error
  }
}
```

---

## VIII. Migrations

### Generate Migration

```bash
# Generate migration from schema changes
pnpm run db:generate
# Creates: drizzle/[timestamp]_[description].sql
```

### Apply Migrations

```bash
# Run all pending migrations
pnpm run db:migrate
```

### Push Schema (Development Only)

```bash
# Push schema directly to database (no migration files)
pnpm run db:push
# Use only in development, never in production
```

### Drizzle Configuration

```typescript
// drizzle.config.ts
import { defineConfig } from 'drizzle-kit'
import path from 'path'

export default defineConfig({
  schema: './src/db/schema/*',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  migrations: {
    prefix: 'timestamp',
  },
  introspect: {
    casing: 'snake_case',
  },
})
```

### package.json Scripts

```json
{
  "scripts": {
    "db:generate": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate",
    "db:push": "drizzle-kit push",
    "db:drop": "drizzle-kit drop",
    "db:studio": "drizzle-kit studio"
  }
}
```

---

## IX. Query Optimization

### Add Indexes

```typescript
import { pgTable, index, uniqueIndex } from 'drizzle-orm/pg-core'

export const project = pgTable(
  'project',
  {
    id: text('id').primaryKey(),
    userId: text('user_id').notNull(),
    email: varchar('email').notNull().unique(),
    createdAt: timestamp('created_at').defaultNow(),
  },
  (table) => [
    index('user_projects_idx').on(table.userId), // Speed up user lookups
    uniqueIndex('email_idx').on(table.email),    // Speed up email lookups
    index('created_at_idx').on(table.createdAt), // Speed up date filtering
  ]
)
```

### Use Pagination

```typescript
// Avoid fetching all records at once
async function getProjectsPaginated(userId: string, page: number = 1, pageSize: number = 10) {
  const offset = (page - 1) * pageSize

  const projects = await db.query.project.findMany({
    where: eq(project.userId, userId),
    limit: pageSize,
    offset,
    orderBy: [desc(project.createdAt)],
  })

  const [{ count }] = await db
    .select({ count: count() })
    .from(project)
    .where(eq(project.userId, userId))

  return {
    data: projects,
    total: count,
    pages: Math.ceil(count / pageSize),
    currentPage: page,
  }
}
```

### Use Column Selection

```typescript
// Bad: Select all columns
const all = await db.select().from(user)

// Good: Select only needed columns
const minimal = await db
  .select({
    id: user.id,
    name: user.name,
  })
  .from(user)
```

---

## X. Best Practices

### 1. Use Transactions for Multi-Step Operations
```typescript
// Groups related operations, automatic rollback on error
await db.transaction(async (tx) => {
  // Multiple operations atomically
})
```

### 2. Add Indexes on Foreign Keys
```typescript
export const project = pgTable(
  'project',
  { userId: text('user_id').notNull() },
  (table) => [index('user_id_idx').on(table.userId)]
)
```

### 3. Use `.returning()` to Get Inserted Data
```typescript
// Returns the inserted/updated rows
const [created] = await db.insert(user).values(data).returning()
```

### 4. Leverage Type Inference
```typescript
// Let Drizzle infer types automatically
export type User = InferSelectModel<typeof user>
// Don't manually write out all fields
```

### 5. Organize Schemas by Domain
```
src/db/schema/
├── user.ts        # User, session, account
├── project.ts     # Project and relations
├── content.ts     # Pages, recommendations
└── support.ts     # Notifications, logs
```

### 6. Use Enums for Fixed Value Sets
```typescript
export const statusEnum = pgEnum('status', ['pending', 'active', 'archived'])

export const project = pgTable('project', {
  status: statusEnum('status').default('active'),
})
```

### 7. Use Cascade Deletes for Related Data
```typescript
export const project = pgTable('project', {
  userId: text('user_id').references(() => user.id, { onDelete: 'cascade' }),
})
// Deleting user automatically deletes their projects
```

### 8. Use `db.query` for Relational Queries
```typescript
// Simple syntax with relations
const data = await db.query.project.findFirst({
  where: eq(project.id, id),
  with: { user: true },
})
```

### 9. Validate Input Before Database Operations
```typescript
import { z } from 'zod'

const createProjectSchema = z.object({
  name: z.string().min(1),
  url: z.string().url(),
})

async function createProject(input: unknown) {
  const data = createProjectSchema.parse(input) // Throws if invalid
  return await db.insert(project).values(data)
}
```

### 10. Handle Connection Pooling in Production
```typescript
// The `postgres` client handles pooling automatically
// Set max connections for production
const client = postgres(process.env.DATABASE_URL!, {
  max: 20, // Maximum 20 connections in pool
})
```

---

## XI. Error Handling

### Database Errors

```typescript
import { sql } from 'drizzle-orm'

try {
  await db.insert(user).values({
    email: 'test@example.com',
    name: 'Test User',
  })
} catch (error) {
  // PostgreSQL error codes
  const pgError = error as { code?: string; detail?: string }

  switch (pgError.code) {
    case '23505': // Unique violation
      throw new Error('Email already exists')
    case '23503': // Foreign key violation
      throw new Error('Referenced record not found')
    case '23502': // Not null violation
      throw new Error('Required field is missing')
    default:
      throw new Error('Database operation failed')
  }
}
```

### Transaction Rollback Handling

```typescript
async function complexOperation() {
  try {
    await db.transaction(async (tx) => {
      // Multiple operations
    })
  } catch (error) {
    console.error('Transaction rolled back:', error)
    // Entire transaction is automatically reverted
  }
}
```

---

## XII. Development Tools

### Drizzle Studio

```bash
# Open visual database explorer
pnpm run db:studio
# Access at http://local.drizzle.studio
```

### Inspect Generated SQL

```typescript
import { sql } from 'drizzle-orm'

const query = db
  .select()
  .from(user)
  .where(eq(user.email, 'test@example.com'))

// Log the generated SQL
console.log(query.toSQL())
```

---

## Related Standards

- {{standards/backend/api}} - Using database in API routes
- {{standards/backend/auth}} - BetterAuth database integration
- {{standards/global/validation}} - Input validation patterns
- {{standards/global/error-handling}} - Error handling strategies
