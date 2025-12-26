# Server Actions Implementation (Drizzle + BetterAuth)

## Server Actions Overview

Server Actions are asynchronous functions that execute on the server. They are the recommended way to handle mutations in Next.js.

### Basic Server Action

```typescript
// src/actions/projects.ts
'use server'

import { db } from '@/db'
import { project } from '@/db/schema'
import { revalidatePath } from 'next/cache'

export async function createProject(formData: FormData) {
  const name = formData.get('name') as string
  const url = formData.get('url') as string

  const [newProject] = await db
    .insert(project)
    .values({ name, url })
    .returning()

  revalidatePath('/dashboard')
  return newProject
}
```

### Calling from Client Component

```typescript
'use client'

import { createProject } from '@/actions/projects'

export function NewProjectForm() {
  return (
    <form action={createProject}>
      <input name="name" placeholder="Project Name" required />
      <input name="url" placeholder="Website URL" required />
      <button type="submit">Create Project</button>
    </form>
  )
}
```

## Server Action Patterns

### With Validation

```typescript
'use server'

import { z } from 'zod'
import { db } from '@/db'
import { project } from '@/db/schema'

const projectSchema = z.object({
  name: z.string().min(1).max(200),
  url: z.string().url(),
  description: z.string().max(1000).optional(),
})

export async function createProject(formData: FormData) {
  const data = {
    name: formData.get('name'),
    url: formData.get('url'),
    description: formData.get('description') || undefined,
  }

  try {
    const validated = projectSchema.parse(data)

    const [newProject] = await db
      .insert(project)
      .values(validated)
      .returning()

    return { success: true, data: newProject }
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, errors: error.flatten().fieldErrors }
    }
    return { success: false, error: 'Database error' }
  }
}
```

### With Error Handling

```typescript
'use server'

import { revalidatePath } from 'next/cache'
import { db } from '@/db'
import { project } from '@/db/schema'
import { eq } from 'drizzle-orm'
import { auth } from '@/lib/auth-server'
import { headers } from 'next/headers'

export async function updateProject(
  projectId: string,
  data: { name?: string; url?: string }
) {
  try {
    // Validate user is authenticated
    const session = await auth.api.getSession({
      headers: await headers(),
    })

    if (!session) {
      return { success: false, error: 'Unauthorized', code: 'UNAUTHORIZED' }
    }

    // Check project exists and user owns it
    const existingProject = await db.query.project.findFirst({
      where: eq(project.id, projectId),
    })

    if (!existingProject) {
      return { success: false, error: 'Project not found', code: 'NOT_FOUND' }
    }

    if (existingProject.userId !== session.user.id) {
      return { success: false, error: 'Forbidden', code: 'FORBIDDEN' }
    }

    // Update project
    const [updatedProject] = await db
      .update(project)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(project.id, projectId))
      .returning()

    // Revalidate cache
    revalidatePath(`/dashboard/${projectId}`)
    revalidatePath('/dashboard')

    return { success: true, data: updatedProject }
  } catch (error) {
    console.error('Failed to update project:', error)
    return { success: false, error: 'Failed to update project', code: 'INTERNAL_ERROR' }
  }
}
```

### With Authentication (BetterAuth)

```typescript
'use server'

import { auth } from '@/lib/auth-server'
import { headers } from 'next/headers'
import { db } from '@/db'
import { project } from '@/db/schema'
import { eq, and } from 'drizzle-orm'
import { revalidatePath } from 'next/cache'

export async function deleteProject(projectId: string) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    throw new Error('Unauthorized')
  }

  // Find project and verify ownership
  const existingProject = await db.query.project.findFirst({
    where: and(
      eq(project.id, projectId),
      eq(project.userId, session.user.id)
    ),
  })

  if (!existingProject) {
    throw new Error('Project not found')
  }

  // Delete project
  await db
    .delete(project)
    .where(eq(project.id, projectId))

  revalidatePath('/dashboard')
  return { success: true }
}
```

### With File Upload (Vercel Blob)

```typescript
'use server'

import { put } from '@vercel/blob'
import { db } from '@/db'
import { file } from '@/db/schema'
import { auth } from '@/lib/auth-server'
import { headers } from 'next/headers'

export async function uploadImage(formData: FormData) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { success: false, error: 'Unauthorized' }
  }

  const imageFile = formData.get('image') as File

  if (!imageFile) {
    return { success: false, error: 'No file provided' }
  }

  // Validate file
  const maxSize = 5 * 1024 * 1024 // 5MB
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp']

  if (imageFile.size > maxSize) {
    return { success: false, error: 'File too large (max 5MB)' }
  }

  if (!allowedTypes.includes(imageFile.type)) {
    return { success: false, error: 'Invalid file type' }
  }

  try {
    // Upload to Vercel Blob
    const blob = await put(imageFile.name, imageFile, {
      access: 'public',
      contentType: imageFile.type,
    })

    // Save metadata to database
    const [savedFile] = await db
      .insert(file)
      .values({
        filename: imageFile.name,
        url: blob.url,
        size: imageFile.size,
        mimeType: imageFile.type,
        userId: session.user.id,
      })
      .returning()

    return { success: true, data: savedFile }
  } catch (error) {
    console.error('Upload failed:', error)
    return { success: false, error: 'Upload failed' }
  }
}
```

## Revalidation Strategies

### Path-Based Revalidation

```typescript
'use server'

import { revalidatePath } from 'next/cache'
import { db } from '@/db'
import { project } from '@/db/schema'
import { eq } from 'drizzle-orm'

export async function updateProjectName(projectId: string, name: string) {
  await db
    .update(project)
    .set({ name, updatedAt: new Date() })
    .where(eq(project.id, projectId))

  // Revalidate specific project page
  revalidatePath(`/dashboard/${projectId}`)

  // Revalidate project listing
  revalidatePath('/dashboard')

  // Revalidate layout (regenerates for all routes in layout)
  revalidatePath('/dashboard', 'layout')
}
```

### Tag-Based Revalidation

```typescript
'use server'

import { revalidateTag } from 'next/cache'
import { db } from '@/db'
import { recommendation } from '@/db/schema'

export async function createRecommendation(
  projectId: string,
  content: string,
  priority: 'high' | 'medium' | 'low'
) {
  const [newRecommendation] = await db
    .insert(recommendation)
    .values({ projectId, content, priority })
    .returning()

  // Revalidate all queries tagged with this project
  revalidateTag(`project-${projectId}`)
  revalidateTag('recommendations')

  return newRecommendation
}
```

```typescript
// app/dashboard/[projectId]/page.tsx
async function ProjectPage({ params }: { params: { projectId: string } }) {
  const projectData = await fetch(`/api/projects/${params.projectId}`, {
    next: { tags: [`project-${params.projectId}`] },
  }).then((r) => r.json())

  return <article>{projectData.name}</article>
}
```

## Server Action Best Practices

### 1. Always Validate Input

```typescript
'use server'

import { z } from 'zod'
import { db } from '@/db'
import { user } from '@/db/schema'

const updateProfileSchema = z.object({
  name: z.string().min(1).max(100),
  bio: z.string().max(500).optional(),
})

export async function updateProfile(formData: FormData) {
  const data = {
    name: formData.get('name'),
    bio: formData.get('bio') || undefined,
  }

  const result = updateProfileSchema.safeParse(data)
  if (!result.success) {
    return {
      success: false,
      errors: result.error.flatten().fieldErrors,
    }
  }

  // Proceed with validated data
}
```

### 2. Check Authentication

```typescript
'use server'

import { auth } from '@/lib/auth-server'
import { headers } from 'next/headers'
import { db } from '@/db'
import { user } from '@/db/schema'
import { eq } from 'drizzle-orm'

export async function deleteAccount() {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session?.user) {
    throw new Error('Unauthorized')
  }

  // Delete user account
  await db
    .delete(user)
    .where(eq(user.id, session.user.id))

  return { success: true }
}
```

### 3. Use Transactions

```typescript
'use server'

import { db } from '@/db'
import { project, scannedPage, recommendation } from '@/db/schema'
import { eq } from 'drizzle-orm'

export async function deleteProjectWithData(projectId: string) {
  try {
    // Drizzle transaction
    await db.transaction(async (tx) => {
      // Delete recommendations first (foreign key)
      await tx
        .delete(recommendation)
        .where(eq(recommendation.projectId, projectId))

      // Delete scanned pages
      await tx
        .delete(scannedPage)
        .where(eq(scannedPage.projectId, projectId))

      // Delete project
      await tx
        .delete(project)
        .where(eq(project.id, projectId))
    })

    return { success: true }
  } catch (error) {
    console.error('Transaction failed:', error)
    return { success: false, error: 'Failed to delete project' }
  }
}
```

### 4. Log Important Actions

```typescript
'use server'

import { auth } from '@/lib/auth-server'
import { headers } from 'next/headers'
import { db } from '@/db'
import { user } from '@/db/schema'
import { eq } from 'drizzle-orm'

export async function updateUserRole(userId: string, role: string) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  // Log the change
  console.info('User role updated', {
    targetUserId: userId,
    newRole: role,
    updatedBy: session?.user?.id,
    timestamp: new Date().toISOString(),
  })

  await db
    .update(user)
    .set({ role })
    .where(eq(user.id, userId))

  return { success: true }
}
```

### 5. Return User-Friendly Errors

```typescript
'use server'

import { db } from '@/db'
import { project } from '@/db/schema'
import { eq } from 'drizzle-orm'

export async function triggerScan(projectId: string) {
  try {
    // Check project exists
    const existingProject = await db.query.project.findFirst({
      where: eq(project.id, projectId),
    })

    if (!existingProject) {
      return { success: false, error: 'Project not found' }
    }

    // Trigger scan...
    return { success: true }
  } catch (error) {
    // Handle specific database errors
    if (error instanceof Error && error.message.includes('unique')) {
      return { success: false, error: 'A scan is already in progress' }
    }

    // Don't expose internal errors
    console.error('Unexpected error:', error)
    return { success: false, error: 'An unexpected error occurred' }
  }
}
```

## ActionResult Type Pattern

```typescript
// src/types/index.ts
export type ActionResult<T = void> =
  | { success: true; data: T }
  | { success: false; error: string; code?: string; errors?: Record<string, string[]> }
```

```typescript
'use server'

import type { ActionResult } from '@/types'
import { db } from '@/db'
import { project } from '@/db/schema'
import type { InferSelectModel } from 'drizzle-orm'

type Project = InferSelectModel<typeof project>

export async function createProject(
  formData: FormData
): Promise<ActionResult<Project>> {
  try {
    const [newProject] = await db
      .insert(project)
      .values({
        name: formData.get('name') as string,
        url: formData.get('url') as string,
      })
      .returning()

    return { success: true, data: newProject }
  } catch (error) {
    return { success: false, error: 'Failed to create project' }
  }
}
```

## Combining with useFormState

```typescript
'use server'

interface State {
  message?: string
  errors?: Record<string, string[]>
}

export async function submitForm(
  prevState: State,
  formData: FormData
): Promise<State> {
  const email = formData.get('email')

  if (!email) {
    return { errors: { email: ['Email is required'] } }
  }

  // Process...
  return { message: 'Success!' }
}
```

```typescript
'use client'

import { submitForm } from '@/actions/form'
import { useFormState } from 'react-dom'

export function Form() {
  const [state, formAction] = useFormState(submitForm, {})

  return (
    <form action={formAction}>
      <input name="email" />
      {state.errors?.email && <p className="text-red-500">{state.errors.email[0]}</p>}
      {state.message && <p className="text-green-500">{state.message}</p>}
      <button type="submit">Submit</button>
    </form>
  )
}
```

## Common Patterns

### Mutation with Redirect

```typescript
'use server'

import { redirect } from 'next/navigation'
import { db } from '@/db'
import { project } from '@/db/schema'

export async function createProject(formData: FormData) {
  const [newProject] = await db
    .insert(project)
    .values({
      name: formData.get('name') as string,
      url: formData.get('url') as string,
    })
    .returning()

  redirect(`/dashboard/${newProject.id}`)
}
```

### Conditional Action

```typescript
'use server'

import { db } from '@/db'
import { project } from '@/db/schema'
import { eq } from 'drizzle-orm'

export async function processRequest(formData: FormData) {
  const action = formData.get('_action')
  const projectId = formData.get('projectId') as string

  if (action === 'delete') {
    await db.delete(project).where(eq(project.id, projectId))
    return { success: true, action: 'deleted' }
  } else if (action === 'archive') {
    await db
      .update(project)
      .set({ archived: true })
      .where(eq(project.id, projectId))
    return { success: true, action: 'archived' }
  }

  return { success: false, error: 'Unknown action' }
}
```

```tsx
<form action={processRequest}>
  <input type="hidden" name="_action" value="delete" />
  <input type="hidden" name="projectId" value={project.id} />
  <button type="submit">Delete</button>
</form>
```

### Trigger Background Job

```typescript
'use server'

import { inngest } from '@/lib/inngest/client'
import { auth } from '@/lib/auth-server'
import { headers } from 'next/headers'
import { db } from '@/db'
import { project } from '@/db/schema'
import { eq } from 'drizzle-orm'

export async function triggerScan(projectId: string) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { success: false, error: 'Unauthorized' }
  }

  // Verify project ownership
  const existingProject = await db.query.project.findFirst({
    where: eq(project.id, projectId),
  })

  if (!existingProject || existingProject.userId !== session.user.id) {
    return { success: false, error: 'Project not found' }
  }

  // Trigger Inngest job
  await inngest.send({
    name: 'scan/pages.requested',
    data: {
      projectId,
      userId: session.user.id,
    },
  })

  return { success: true, message: 'Scan started' }
}
```

## Troubleshooting

### Server Action Not Executing

```typescript
// Wrong - Missing "use server"
export async function myAction() {}

// Correct
'use server'
export async function myAction() {}
```

### Accessing Client-Side State

```typescript
// Can't access client state directly
'use server'
export async function save(userId: string) {
  // Can't access useState values here
}

// Pass data from client
'use client'
export function SaveButton() {
  const [name, setName] = useState('')

  return (
    <button onClick={() => save(name)}>
      Save
    </button>
  )
}
```

### Session Not Available

```typescript
// Wrong - Missing headers
'use server'
export async function getUser() {
  const session = await auth.api.getSession() // Error!
}

// Correct - Pass headers
'use server'
import { headers } from 'next/headers'

export async function getUser() {
  const session = await auth.api.getSession({
    headers: await headers(),
  })
}
```

## Related Standards

- {{standards/frontend/forms-actions}} - Form handling with Server Actions
- {{standards/global/validation}} - Input validation with Zod
- {{standards/global/error-handling}} - Error handling patterns
- {{standards/backend/database}} - Drizzle ORM patterns
- {{standards/backend/auth}} - BetterAuth session management
- {{standards/backend/background-jobs}} - Triggering Inngest jobs
