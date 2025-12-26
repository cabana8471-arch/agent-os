# Validation Standards - Zod Integration

This standard documents Zod schema definition and validation patterns for the SEO Optimization application, covering API routes, Server Actions, forms, and database operations.

## I. Zod Schema Basics

### Installing Zod

```bash
pnpm add zod
```

### Schema Definition Patterns

```typescript
import { z } from 'zod'

// Basic types
const stringSchema = z.string().min(1, 'Required').max(255)
const emailSchema = z.string().email('Invalid email')
const urlSchema = z.string().url('Invalid URL')
const numberSchema = z.number().positive('Must be positive')
const boolSchema = z.boolean()

// Optional and nullable
const optionalString = z.string().optional()
const nullableString = z.string().nullable()
const defaultString = z.string().default('default-value')

// Arrays
const stringArray = z.array(z.string()).min(1, 'At least one required')
const numberArray = z.array(z.number())

// Union types
const status = z.enum(['pending', 'active', 'archived'])
const idOrNull = z.union([z.number(), z.null()])
```

### Object Schemas

```typescript
import { z } from 'zod'

// Basic object
const createProjectSchema = z.object({
  name: z.string().min(1, 'Project name is required').max(100),
  url: z.string().url('Invalid project URL'),
  description: z.string().max(500).optional(),
})

// Type inference from schema
type CreateProjectInput = z.infer<typeof createProjectSchema>

// Strict schema - rejects unknown fields
const strictProjectSchema = createProjectSchema.strict()

// Extending schemas
const updateProjectSchema = createProjectSchema.extend({
  id: z.string().uuid(),
})

// Picking/omitting fields
const partialSchema = createProjectSchema.pick({ name: true })
const withoutNameSchema = createProjectSchema.omit({ name: true })
```

---

## II. API Route Validation

### Route Handler Pattern

```typescript
// app/api/projects/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'
import { auth } from '@/lib/auth'
import { db } from '@/db'
import { project } from '@/db/schema'

const createProjectSchema = z.object({
  name: z.string().min(1, 'Name required').max(100),
  url: z.string().url('Invalid URL'),
  description: z.string().max(500).optional(),
})

export async function POST(request: NextRequest) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    )
  }

  try {
    const body = await request.json()
    const data = createProjectSchema.parse(body)

    const [newProject] = await db.insert(project).values({
      id: crypto.randomUUID(),
      userId: session.user.id,
      ...data,
    }).returning()

    return NextResponse.json(newProject, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        {
          error: 'Validation failed',
          errors: error.errors.map(e => ({
            path: e.path.join('.'),
            message: e.message,
          })),
        },
        { status: 400 }
      )
    }

    console.error('Server error:', error)
    return NextResponse.json(
      { error: 'Server error' },
      { status: 500 }
    )
  }
}
```

### Query Parameter Validation

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

const querySchema = z.object({
  page: z.coerce.number().positive().default(1),
  limit: z.coerce.number().positive().max(100).default(20),
  search: z.string().optional(),
  sort: z.enum(['name', 'date', 'relevance']).default('date'),
})

export async function GET(request: NextRequest) {
  try {
    const searchParams = Object.fromEntries(request.nextUrl.searchParams)
    const params = querySchema.parse(searchParams)

    // Use validated params
    const offset = (params.page - 1) * params.limit
    // ... query database with offset, limit, search, sort

    return NextResponse.json({ /* results */ })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Invalid query parameters' },
        { status: 400 }
      )
    }
    throw error
  }
}
```

### Refining Validation with .refine() and .superRefine()

```typescript
import { z } from 'zod'

// Single refinement
const passwordSchema = z.string()
  .min(8, 'Password must be 8+ characters')
  .refine(
    (password) => /[A-Z]/.test(password),
    'Password must contain uppercase'
  )
  .refine(
    (password) => /[0-9]/.test(password),
    'Password must contain number'
  )

// Cross-field validation
const passwordChangeSchema = z.object({
  currentPassword: z.string(),
  newPassword: z.string().min(8),
  confirmPassword: z.string(),
}).refine(
  (data) => data.newPassword === data.confirmPassword,
  {
    message: 'Passwords do not match',
    path: ['confirmPassword'], // Which field to attach error to
  }
)

// Complex validation with context
const updateProjectSchema = z.object({
  name: z.string().min(1).max(100),
  url: z.string().url(),
}).superRefine(async (data, ctx) => {
  // Check if URL is reachable
  try {
    const response = await fetch(data.url, { method: 'HEAD' })
    if (!response.ok) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['url'],
        message: 'URL is not accessible',
      })
    }
  } catch {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      path: ['url'],
      message: 'URL is not reachable',
    })
  }
})
```

---

## III. Server Action Validation

### Basic Server Action with Zod

```typescript
// app/actions.ts
'use server'

import { z } from 'zod'
import { auth } from '@/lib/auth'
import { db } from '@/db'
import { project } from '@/db/schema'
import { headers } from 'next/headers'

const createProjectSchema = z.object({
  name: z.string().min(1).max(100),
  url: z.string().url(),
  description: z.string().max(500).optional(),
})

export async function createProjectAction(data: unknown) {
  // Validate input
  const validated = createProjectSchema.safeParse(data)
  if (!validated.success) {
    return {
      error: 'Validation failed',
      errors: validated.error.flatten().fieldErrors,
    }
  }

  // Check authentication
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { error: 'Unauthorized' }
  }

  try {
    const [newProject] = await db.insert(project).values({
      id: crypto.randomUUID(),
      userId: session.user.id,
      ...validated.data,
    }).returning()

    return {
      success: true,
      project: newProject,
    }
  } catch (error) {
    console.error('Failed to create project:', error)
    return { error: 'Failed to create project' }
  }
}
```

### Returning Structured Validation Errors

```typescript
import { z } from 'zod'

export type ActionResult<T> =
  | { success: true; data: T }
  | { success: false; error: string; errors?: Record<string, string[]> }

export async function myAction(
  input: unknown
): Promise<ActionResult<{ id: string }>> {
  const schema = z.object({
    name: z.string().min(1),
    email: z.string().email(),
  })

  const validation = schema.safeParse(input)
  if (!validation.success) {
    return {
      success: false,
      error: 'Validation failed',
      errors: validation.error.flatten().fieldErrors as Record<string, string[]>,
    }
  }

  try {
    // Process validated data
    return {
      success: true,
      data: { id: '123' },
    }
  } catch (error) {
    return {
      success: false,
      error: 'Operation failed',
    }
  }
}
```

---

## IV. Form Validation with React Hook Form

### React Hook Form + Zod Integration

```typescript
// app/components/ProjectForm.tsx
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { createProjectAction } from '@/app/actions'

const createProjectSchema = z.object({
  name: z.string().min(1, 'Name required').max(100),
  url: z.string().url('Invalid URL'),
  description: z.string().max(500).optional(),
})

type CreateProjectInput = z.infer<typeof createProjectSchema>

export function ProjectForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<CreateProjectInput>({
    resolver: zodResolver(createProjectSchema),
  })

  const onSubmit = async (data: CreateProjectInput) => {
    const result = await createProjectAction(data)
    if (!result.success) {
      // Handle error
      console.error(result.error)
      return
    }
    // Handle success
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <input
          {...register('name')}
          placeholder="Project name"
        />
        {errors.name && <p>{errors.name.message}</p>}
      </div>

      <div>
        <input
          {...register('url')}
          placeholder="Project URL"
        />
        {errors.url && <p>{errors.url.message}</p>}
      </div>

      <div>
        <textarea
          {...register('description')}
          placeholder="Description"
        />
        {errors.description && <p>{errors.description.message}</p>}
      </div>

      <button disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create Project'}
      </button>
    </form>
  )
}
```

---

## V. Database Input Validation

### Pre-Drizzle Validation

```typescript
import { z } from 'zod'
import { db } from '@/db'
import { user } from '@/db/schema'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['user', 'admin']).default('user'),
})

export async function createUser(input: unknown) {
  const validation = createUserSchema.safeParse(input)
  if (!validation.success) {
    throw new Error('Validation failed')
  }

  try {
    const [newUser] = await db.insert(user).values({
      id: crypto.randomUUID(),
      ...validation.data,
    }).returning()

    return newUser
  } catch (error) {
    // See {{standards/global/error-handling}} for database error handling
    throw error
  }
}
```

### Validating Database Retrieved Data

```typescript
import { z } from 'zod'
import { db } from '@/db'
import { project } from '@/db/schema'

const projectSchema = z.object({
  id: z.string().uuid(),
  userId: z.string().uuid(),
  name: z.string(),
  url: z.string().url(),
  createdAt: z.date(),
})

export async function getProject(id: string) {
  const row = await db.query.project.findFirst({
    where: (fields) => eq(fields.id, id),
  })

  if (!row) {
    throw new Error('Project not found')
  }

  // Validate shape even though from database
  return projectSchema.parse(row)
}
```

---

## VI. Custom Validators

### Reusable Custom Validators

```typescript
import { z } from 'zod'

// Custom string validators
export const slugSchema = z.string()
  .toLowerCase()
  .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, 'Invalid slug format')

export const phoneSchema = z.string()
  .regex(/^\+?[1-9]\d{1,14}$/, 'Invalid phone number')

export const colorHexSchema = z.string()
  .regex(/^#[0-9a-f]{6}$/i, 'Invalid hex color')

// Preset schemas
export const UUIDSchema = z.string().uuid()
export const isoDateSchema = z.string().datetime()
export const positiveIntSchema = z.number().int().positive()

// Compose validators
const userSchema = z.object({
  id: UUIDSchema,
  username: slugSchema,
  phone: phoneSchema.optional(),
  createdAt: isoDateSchema,
  age: positiveIntSchema.max(150),
})
```

### Custom Error Messages

```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string()
    .email('Please provide a valid email address')
    .transform(val => val.toLowerCase()),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number'),
  terms: z.boolean()
    .refine(val => val === true, 'You must accept the terms'),
})
```

---

## VII. Type Inference

### Inferring Types from Schemas

```typescript
import { z } from 'zod'

const projectSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  status: z.enum(['active', 'archived']),
  createdAt: z.date(),
})

// Automatically infer TypeScript type
type Project = z.infer<typeof projectSchema>

// Infer partial types
type ProjectInput = z.infer<typeof projectSchema.omit({ id: true, createdAt: true }))

// Use in function signatures
function updateProject(
  data: z.infer<typeof projectSchema.partial()>
): Promise<Project> {
  // ...
}
```

---

## VIII. Best Practices

### General Principles

1. **Validate at boundaries** - Always validate at API routes, Server Actions, and form submissions
2. **Define once, reuse many** - Create reusable schema definitions in a schemas directory
3. **Use type inference** - Leverage `z.infer<typeof schema>` for TypeScript types
4. **Fail early** - Return validation errors immediately without processing
5. **Provide helpful messages** - Use clear, field-specific error messages
6. **Test schemas** - Write tests for validation logic
7. **Document requirements** - Include validation rules in API documentation

### File Organization

```
src/
├── lib/
│   └── validations/
│       ├── user.ts        # User-related schemas
│       ├── project.ts     # Project-related schemas
│       ├── page.ts        # Page scanning schemas
│       └── index.ts       # Export all schemas
├── app/
│   ├── api/
│   │   └── projects/
│   │       └── route.ts   # Use validations from lib/
│   ├── actions.ts         # Server Actions with validation
│   └── components/
│       └── ProjectForm.tsx # Form with validation
```

### Using a Validations Directory

```typescript
// lib/validations/index.ts
export * as projectSchemas from './project'
export * as userSchemas from './user'
export * as pageSchemas from './page'

// lib/validations/project.ts
import { z } from 'zod'

export const createProjectSchema = z.object({
  name: z.string().min(1).max(100),
  url: z.string().url(),
})

export const updateProjectSchema = createProjectSchema.partial()

// app/api/projects/route.ts
import { projectSchemas } from '@/lib/validations'

export async function POST(request: NextRequest) {
  const body = await request.json()
  const data = projectSchemas.createProjectSchema.parse(body)
  // ...
}
```

### Error Handling with Zod

```typescript
import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

function validateData(data: unknown) {
  const result = schema.safeParse(data)

  if (!result.success) {
    // Access validation errors
    console.log(result.error.errors)      // Raw error objects
    console.log(result.error.flatten())   // Flattened by field

    // Get field errors
    const fieldErrors = result.error.flatten().fieldErrors
    // { name: ['Required'], email: ['Invalid email'] }

    return { error: true, errors: fieldErrors }
  }

  // Use validated data with type safety
  const validData = result.data
  return { error: false, data: validData }
}
```

---

## Related Standards

- {{standards/backend/api}} - API route handlers using validation
- {{standards/backend/database}} - Database operations after validation
- {{standards/frontend/forms-actions}} - Form submission with validation
- {{standards/global/error-handling}} - Handling validation errors
