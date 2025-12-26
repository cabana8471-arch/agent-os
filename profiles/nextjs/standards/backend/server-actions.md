# Server Actions Implementation

## Server Actions Overview

Server Actions are asynchronous functions that execute on the server. They are the recommended way to handle mutations in Next.js.

### Basic Server Action

```typescript
// app/actions.ts
'use server'

import { db } from '@/lib/db'
import { revalidatePath } from 'next/cache'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  const post = await db.post.create({
    data: { title, content },
  })

  revalidatePath('/blog')
  return post
}
```

### Calling from Client Component

```typescript
'use client'

import { createPost } from '@/app/actions'

export function NewPostForm() {
  return (
    <form action={createPost}>
      <input name="title" placeholder="Title" required />
      <textarea name="content" placeholder="Content" required />
      <button type="submit">Create Post</button>
    </form>
  )
}
```

## Server Action Patterns

### With Validation

```typescript
'use server'

import { z } from 'zod'
import { db } from '@/lib/db'

const postSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(10000),
  published: z.boolean().optional(),
})

export async function createPost(formData: FormData) {
  const data = {
    title: formData.get('title'),
    content: formData.get('content'),
    published: formData.get('published') === 'on',
  }

  try {
    const validated = postSchema.parse(data)
    const post = await db.post.create({ data: validated })
    return { success: true, post }
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
import { db } from '@/lib/db'
import { logger } from '@/lib/logger'

export async function updatePost(id: string, data: unknown) {
  try {
    // Validate user is authenticated
    const session = await getSession()
    if (!session) {
      return { error: 'Unauthorized', status: 401 }
    }

    // Validate data
    if (typeof data !== 'object' || data === null) {
      return { error: 'Invalid data', status: 400 }
    }

    // Update post
    const post = await db.post.update({
      where: { id },
      data,
    })

    // Revalidate cache
    revalidatePath(`/blog/${id}`)
    revalidatePath('/blog')

    logger.info('Post updated', { postId: id, userId: session.user.id })
    return { success: true, post }
  } catch (error) {
    logger.error('Failed to update post', { error, postId: id })
    return { error: 'Failed to update post', status: 500 }
  }
}
```

### With Authentication

```typescript
'use server'

import { getSession } from '@/lib/auth'
import { db } from '@/lib/db'

export async function deletePost(postId: string) {
  const session = await getSession()

  if (!session) {
    throw new Error('Unauthorized')
  }

  const post = await db.post.findUnique({ where: { id: postId } })

  if (!post) {
    throw new Error('Post not found')
  }

  // Verify user is post author
  if (post.authorId !== session.user.id) {
    throw new Error('Forbidden')
  }

  await db.post.delete({ where: { id: postId } })

  revalidatePath('/blog')
  return { success: true }
}
```

### With File Upload

```typescript
'use server'

import { writeFile } from 'fs/promises'
import path from 'path'
import { db } from '@/lib/db'
import { validateFile } from '@/lib/file-validation'

export async function uploadImage(formData: FormData) {
  const file = formData.get('image') as File

  if (!file) {
    return { error: 'No file provided' }
  }

  // Validate file
  const validation = validateFile(file, {
    maxSize: 5 * 1024 * 1024, // 5MB
    allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
  })

  if (!validation.valid) {
    return { error: validation.error }
  }

  try {
    // Save file
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)
    const filename = `${Date.now()}-${file.name}`
    const filepath = path.join(process.cwd(), 'public/uploads', filename)
    await writeFile(filepath, buffer)

    // Save metadata
    const image = await db.image.create({
      data: {
        filename: file.name,
        path: `/uploads/${filename}`,
        size: file.size,
        mimeType: file.type,
      },
    })

    return { success: true, image }
  } catch (error) {
    console.error('Upload failed:', error)
    return { error: 'Upload failed' }
  }
}
```

## Revalidation Strategies

### Path-Based Revalidation

```typescript
'use server'

import { revalidatePath } from 'next/cache'
import { db } from '@/lib/db'

export async function updateBlogPost(id: string, data: unknown) {
  await db.post.update({ where: { id }, data })

  // Revalidate specific post
  revalidatePath(`/blog/${id}`)

  // Revalidate blog listing
  revalidatePath('/blog')

  // Revalidate layout (regenerates for all routes in layout)
  revalidatePath('/blog', 'layout')
}
```

### Tag-Based Revalidation

```typescript
'use server'

import { revalidateTag } from 'next/cache'
import { db } from '@/lib/db'

export async function createComment(postId: string, content: string) {
  const comment = await db.comment.create({
    data: { postId, content },
  })

  // Revalidate all queries tagged with this post
  revalidateTag(`post-${postId}`)
  revalidateTag('comments')

  return comment
}
```

```typescript
// app/blog/[id]/page.tsx
async function BlogPost({ params }: { params: { id: string } }) {
  const post = await fetch(`/api/posts/${params.id}`, {
    next: { tags: [`post-${params.id}`] },
  }).then((r) => r.json())

  return <article>{post.content}</article>
}
```

## Server Action Best Practices

### 1. Always Validate Input

```typescript
'use server'

import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
})

export async function createUser(formData: FormData) {
  const data = {
    email: formData.get('email'),
    name: formData.get('name'),
  }

  const result = schema.safeParse(data)
  if (!result.success) {
    return { error: 'Validation failed' }
  }

  // Proceed with validated data
}
```

### 2. Check Authentication

```typescript
'use server'

import { getSession } from '@/lib/auth'

export async function deleteAccount(userId: string) {
  const session = await getSession()

  if (!session?.user) {
    throw new Error('Unauthorized')
  }

  if (session.user.id !== userId) {
    throw new Error('Can only delete your own account')
  }

  // Proceed with deletion
}
```

### 3. Use Transactions

```typescript
'use server'

import { db } from '@/lib/db'

export async function transferFunds(from: string, to: string, amount: number) {
  try {
    await db.$transaction([
      db.account.update({
        where: { id: from },
        data: { balance: { decrement: amount } },
      }),
      db.account.update({
        where: { id: to },
        data: { balance: { increment: amount } },
      }),
    ])

    return { success: true }
  } catch (error) {
    return { error: 'Transfer failed' }
  }
}
```

### 4. Log Important Actions

```typescript
'use server'

import { logger } from '@/lib/logger'
import { getSession } from '@/lib/auth'
import { db } from '@/lib/db'

export async function updateUserRole(userId: string, role: string) {
  const session = await getSession()

  // Log the change
  logger.info('User role updated', {
    targetUserId: userId,
    newRole: role,
    updatedBy: session?.user?.id,
    timestamp: new Date().toISOString(),
  })

  await db.user.update({
    where: { id: userId },
    data: { role },
  })
}
```

### 5. Return User-Friendly Errors

```typescript
'use server'

export async function processPayment(amount: number) {
  try {
    // Process payment...
  } catch (error) {
    if (error instanceof PaymentError) {
      return { error: 'Payment failed. Please try again.' }
    }

    if (error instanceof InsufficientFundsError) {
      return { error: 'Insufficient funds in your account.' }
    }

    // Don't expose internal errors
    console.error('Unexpected error:', error)
    return { error: 'An unexpected error occurred.' }
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

export async function submitForm(prevState: State, formData: FormData): Promise<State> {
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

import { submitForm } from '@/app/actions'
import { useFormState } from 'react-dom'

export function Form() {
  const [state, formAction] = useFormState(submitForm, {})

  return (
    <form action={formAction}>
      <input name="email" />
      {state.errors?.email && <p>{state.errors.email[0]}</p>}
      {state.message && <p>{state.message}</p>}
      <button>Submit</button>
    </form>
  )
}
```

## Common Patterns

### Mutation with Redirect

```typescript
'use server'

import { redirect } from 'next/navigation'
import { db } from '@/lib/db'

export async function createPost(formData: FormData) {
  const post = await db.post.create({
    data: {
      title: formData.get('title') as string,
    },
  })

  redirect(`/blog/${post.id}`)
}
```

### Conditional Action

```typescript
'use server'

export async function processRequest(formData: FormData) {
  const action = formData.get('_action')

  if (action === 'delete') {
    return await deleteItem(formData)
  } else if (action === 'update') {
    return await updateItem(formData)
  }

  return { error: 'Unknown action' }
}
```

```typescript
<form action={processRequest}>
  <input type="hidden" name="_action" value="delete" />
  <button>Delete</button>
</form>
```

## Troubleshooting

### Server Action Not Executing

```typescript
// ❌ Wrong - Missing "use server"
export async function myAction() {}

// ✅ Correct
'use server'
export async function myAction() {}
```

### Accessing Client-Side State

```typescript
// ❌ Can't access client state directly
'use server'
export async function save(userId: string) {
  // Can't access useState values here
}

// ✅ Pass data from client
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

## Related Standards

- {{standards/frontend/forms-actions}} - Form handling with Server Actions
- {{standards/global/validation}} - Input validation
- {{standards/global/error-handling}} - Error handling patterns
