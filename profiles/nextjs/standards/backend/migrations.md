# Next.js Prisma Migrations

> **Related Standards**: See `backend/models.md` for schema design, `backend/queries.md` for query optimization after schema changes, `backend/database.md` for complete database patterns.

## Migration Workflow

### Development Workflow

```bash
# 1. Modify prisma/schema.prisma
# 2. Create and apply migration
npx prisma migrate dev --name add_user_role

# 3. Prisma automatically:
#    - Creates migration SQL file
#    - Applies migration to database
#    - Regenerates Prisma Client
```

### Production Deployment

```bash
# Apply pending migrations (CI/CD)
npx prisma migrate deploy

# This command:
# - Applies all pending migrations
# - Does NOT create new migrations
# - Does NOT regenerate client (use npx prisma generate)
```

## Migration Commands

| Command | Purpose | Environment |
|---------|---------|-------------|
| `prisma migrate dev` | Create and apply migrations | Development |
| `prisma migrate deploy` | Apply pending migrations | Production |
| `prisma migrate reset` | Reset database and apply all migrations | Development |
| `prisma migrate status` | Check migration status | Any |
| `prisma db push` | Push schema without migrations | Prototyping |

## Migration File Structure

```
prisma/
├── schema.prisma
└── migrations/
    ├── 20240101120000_init/
    │   └── migration.sql
    ├── 20240102150000_add_user_role/
    │   └── migration.sql
    └── migration_lock.toml
```

## Creating Migrations

### Basic Migration

```bash
# Create migration with descriptive name
npx prisma migrate dev --name add_posts_table
```

### Create Migration Without Applying

```bash
# Create migration file only (for review)
npx prisma migrate dev --create-only --name add_posts_table

# Review the SQL, then apply
npx prisma migrate dev
```

### Skip Seed After Migration

```bash
npx prisma migrate dev --skip-seed
```

## Common Migration Patterns

### Adding a New Table

```prisma
// schema.prisma
model Comment {
  id        Int      @id @default(autoincrement())
  content   String
  post      Post     @relation(fields: [postId], references: [id])
  postId    Int
  createdAt DateTime @default(now())

  @@index([postId])
}
```

```bash
npx prisma migrate dev --name add_comments_table
```

### Adding a Column with Default

```prisma
model User {
  // existing fields...
  isVerified Boolean @default(false)  // New field
}
```

### Adding a Required Column (Data Migration)

```sql
-- migrations/xxx_add_required_field/migration.sql

-- 1. Add column as nullable
ALTER TABLE "User" ADD COLUMN "tenantId" INTEGER;

-- 2. Populate existing rows
UPDATE "User" SET "tenantId" = 1 WHERE "tenantId" IS NULL;

-- 3. Make column required
ALTER TABLE "User" ALTER COLUMN "tenantId" SET NOT NULL;

-- 4. Add foreign key
ALTER TABLE "User" ADD CONSTRAINT "User_tenantId_fkey"
  FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id");

-- 5. Add index
CREATE INDEX "User_tenantId_idx" ON "User"("tenantId");
```

### Renaming a Column

```bash
# 1. Create migration without applying
npx prisma migrate dev --create-only --name rename_user_name

# 2. Edit the migration SQL
```

```sql
-- Use RENAME instead of DROP/ADD to preserve data
ALTER TABLE "User" RENAME COLUMN "name" TO "fullName";
```

```bash
# 3. Update schema.prisma to match
# 4. Apply migration
npx prisma migrate dev
```

### Changing Column Type

```sql
-- Safe type changes (e.g., VARCHAR length increase)
ALTER TABLE "Product" ALTER COLUMN "description" TYPE TEXT;

-- Unsafe changes require data migration
ALTER TABLE "Order"
  ALTER COLUMN "amount" TYPE DECIMAL(12,2)
  USING amount::DECIMAL(12,2);
```

## Zero-Downtime Migrations

### Expand-Contract Pattern

For breaking changes, use multiple migrations:

**Step 1: Expand (add new structure)**
```prisma
model User {
  name     String   // Old field
  fullName String?  // New field (nullable initially)
}
```

**Step 2: Migrate data (application code)**
```typescript
// Dual-write during transition
await db.user.update({
  where: { id },
  data: {
    name: newName,
    fullName: newName  // Write to both
  }
})
```

**Step 3: Contract (remove old structure)**
```prisma
model User {
  fullName String  // Now required, old field removed
}
```

### Adding Index on Large Table

```sql
-- Use CONCURRENTLY to avoid locking (PostgreSQL)
CREATE INDEX CONCURRENTLY "Post_authorId_idx" ON "Post"("authorId");
```

```bash
# Skip Prisma's default index creation
npx prisma migrate dev --create-only
# Edit migration to use CONCURRENTLY
npx prisma migrate dev
```

## Handling Migration Conflicts

### When Multiple Developers Create Migrations

```bash
# 1. Pull latest changes
git pull origin main

# 2. Reset local database to apply all migrations
npx prisma migrate reset

# 3. Create your new migration
npx prisma migrate dev --name your_changes
```

### Resolving Failed Migration

```bash
# 1. Check migration status
npx prisma migrate status

# 2. Mark failed migration as rolled back
npx prisma migrate resolve --rolled-back 20240101120000_failed_migration

# 3. Fix the issue and create new migration
npx prisma migrate dev --name fix_migration
```

### Baselining Existing Database

```bash
# For existing databases not managed by Prisma
npx prisma migrate diff \
  --from-empty \
  --to-schema-datamodel prisma/schema.prisma \
  --script > prisma/migrations/0_init/migration.sql

# Mark as applied
npx prisma migrate resolve --applied 0_init
```

## Database Seeding

### Seed File

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client'

const db = new PrismaClient()

async function main() {
  // Create admin user
  await db.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      email: 'admin@example.com',
      name: 'Admin',
      role: 'ADMIN',
    },
  })

  // Create categories
  const categories = ['Technology', 'Design', 'Business']
  for (const name of categories) {
    await db.category.upsert({
      where: { name },
      update: {},
      create: { name },
    })
  }

  console.log('Seed completed')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await db.$disconnect()
  })
```

### Configure Seeding

```json
// package.json
{
  "prisma": {
    "seed": "ts-node --compiler-options {\"module\":\"CommonJS\"} prisma/seed.ts"
  }
}
```

```bash
# Run seed manually
npx prisma db seed

# Seed runs automatically after migrate reset
npx prisma migrate reset
```

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/deploy.yml
- name: Run migrations
  run: npx prisma migrate deploy
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}

- name: Generate Prisma Client
  run: npx prisma generate
```

### Pre-deployment Checklist

- [ ] Test migration locally with production data copy
- [ ] Check migration SQL for locking operations
- [ ] Verify rollback plan exists
- [ ] Ensure application handles both old and new schema during deployment
- [ ] Back up production database before applying

## Best Practices

1. **Descriptive names** - Use clear migration names: `add_user_role`, not `update`
2. **Small, focused changes** - One logical change per migration
3. **Never edit applied migrations** - Create new migrations to fix issues
4. **Review generated SQL** - Use `--create-only` for complex changes
5. **Test with production data** - Clone production for testing migrations
6. **Use transactions** - Prisma wraps migrations in transactions by default
7. **Handle rollbacks** - Plan how to undo each migration if needed
8. **Document breaking changes** - Note when application code must change
