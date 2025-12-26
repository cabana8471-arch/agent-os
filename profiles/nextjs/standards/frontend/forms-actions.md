# Forms & Server Actions

## Server Actions

Server Actions are asynchronous functions that run on the server and can be called from Server or Client Components.

### Basic Server Action

```typescript
// app/actions.ts
'use server'

import { db } from '@/lib/db'
import { revalidatePath } from 'next/cache'

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string
  const email = formData.get('email') as string

  if (!name || !email) {
    throw new Error('Name and email are required')
  }

  const user = await db.user.create({
    data: { name, email },
  })

  revalidatePath('/users')
  return user
}
```

### Form with Server Action

```typescript
// app/users/new/page.tsx
import { createUser } from '@/app/actions'

export default function NewUserPage() {
  return (
    <form action={createUser}>
      <div>
        <label htmlFor="name">Name:</label>
        <input
          id="name"
          name="name"
          type="text"
          required
        />
      </div>

      <div>
        <label htmlFor="email">Email:</label>
        <input
          id="email"
          name="email"
          type="email"
          required
        />
      </div>

      <button type="submit">Create User</button>
    </form>
  )
}
```

## Form Validation with Zod

Validate form data with Zod schema:

```typescript
// app/actions.ts
'use server'

import { z } from 'zod'
import { db } from '@/lib/db'
import { revalidatePath } from 'next/cache'

const createUserSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100),
  email: z.string().email('Invalid email address'),
  age: z.number().min(18).optional(),
})

export async function createUser(formData: FormData) {
  const data = {
    name: formData.get('name'),
    email: formData.get('email'),
    age: formData.get('age') ? Number(formData.get('age')) : undefined,
  }

  try {
    const validated = createUserSchema.parse(data)
    const user = await db.user.create({ data: validated })
    revalidatePath('/users')
    return { success: true, user }
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, errors: error.flatten().fieldErrors }
    }
    return { success: false, error: 'Database error' }
  }
}
```

## useFormStatus Hook

Show loading state during form submission:

```typescript
// app/users/new/page.tsx
'use client'

import { createUser } from '@/app/actions'
import { useFormStatus } from 'react-dom'

function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Creating...' : 'Create User'}
    </button>
  )
}

export default function NewUserPage() {
  return (
    <form action={createUser}>
      <input name="name" placeholder="Name" required />
      <input name="email" placeholder="Email" type="email" required />
      <SubmitButton />
    </form>
  )
}
```

## useFormState Hook

Handle form submission with state:

```typescript
// app/actions.ts
'use server'

import { db } from '@/lib/db'

interface FormState {
  message?: string
  error?: string
  user?: any
}

export async function createUserAction(
  prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const name = formData.get('name') as string
  const email = formData.get('email') as string

  if (!name || !email) {
    return { error: 'Name and email are required' }
  }

  try {
    const user = await db.user.create({
      data: { name, email },
    })
    return {
      message: 'User created successfully',
      user,
    }
  } catch (error) {
    return {
      error: 'Failed to create user',
    }
  }
}
```

```typescript
// app/users/new/page.tsx
'use client'

import { createUserAction } from '@/app/actions'
import { useFormState } from 'react-dom'

export default function NewUserPage() {
  const [state, formAction] = useFormState(createUserAction, {})

  return (
    <div>
      <form action={formAction}>
        <input name="name" placeholder="Name" required />
        <input name="email" placeholder="Email" type="email" required />
        <button type="submit">Create User</button>
      </form>

      {state.error && <p className="error">{state.error}</p>}
      {state.message && <p className="success">{state.message}</p>}
    </div>
  )
}
```

## useTransition Hook

Show loading state for programmatic actions:

```typescript
'use client'

import { updateUser } from '@/app/actions'
import { useTransition } from 'react'

export function UserForm({ user }: { user: User }) {
  const [isPending, startTransition] = useTransition()

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)

    startTransition(async () => {
      await updateUser(user.id, formData)
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        name="name"
        defaultValue={user.name}
        disabled={isPending}
      />
      <input
        name="email"
        defaultValue={user.email}
        disabled={isPending}
      />
      <button disabled={isPending}>
        {isPending ? 'Saving...' : 'Save'}
      </button>
    </form>
  )
}
```

## Progressive Enhancement

Forms work even without JavaScript:

```typescript
// app/users/new/page.tsx
import { createUser } from '@/app/actions'

export default function NewUserPage() {
  return (
    <form action={createUser} method="POST">
      <input
        name="name"
        type="text"
        placeholder="Name"
        required
      />
      <input
        name="email"
        type="email"
        placeholder="Email"
        required
      />
      <button type="submit">Create User</button>
    </form>
  )
}

// ✅ Works without JavaScript
// ✅ Works with JavaScript for better UX
```

## Complex Forms with React Hook Form

Combine React Hook Form with Server Actions:

```typescript
// app/users/new/page.tsx
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { createUser } from '@/app/actions'

const schema = z.object({
  name: z.string().min(1, 'Name required').max(100),
  email: z.string().email('Invalid email'),
  phone: z.string().optional(),
})

type FormData = z.infer<typeof schema>

export default function NewUserPage() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  })

  const onSubmit = async (data: FormData) => {
    const formData = new FormData()
    Object.entries(data).forEach(([key, value]) => {
      if (value) formData.append(key, value)
    })
    await createUser(formData)
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label>Name</label>
        <input {...register('name')} />
        {errors.name && <span>{errors.name.message}</span>}
      </div>

      <div>
        <label>Email</label>
        <input {...register('email')} type="email" />
        {errors.email && <span>{errors.email.message}</span>}
      </div>

      <div>
        <label>Phone</label>
        <input {...register('phone')} />
        {errors.phone && <span>{errors.phone.message}</span>}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create User'}
      </button>
    </form>
  )
}
```

## Handling File Uploads

```typescript
// app/actions.ts
'use server'

import { writeFile } from 'fs/promises'
import path from 'path'
import { db } from '@/lib/db'

export async function uploadDocument(formData: FormData) {
  const file = formData.get('document') as File

  if (!file || file.size === 0) {
    return { error: 'No file provided' }
  }

  // Validate file type
  if (!file.type.startsWith('application/pdf')) {
    return { error: 'Only PDF files are allowed' }
  }

  // Validate file size (max 10MB)
  if (file.size > 10 * 1024 * 1024) {
    return { error: 'File is too large' }
  }

  try {
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)

    // Save file
    const filename = `${Date.now()}-${file.name}`
    const filepath = path.join(process.cwd(), 'public/uploads', filename)
    await writeFile(filepath, buffer)

    // Save to database
    const document = await db.document.create({
      data: {
        filename: file.name,
        filepath: `/uploads/${filename}`,
        size: file.size,
      },
    })

    return { success: true, document }
  } catch (error) {
    return { error: 'Failed to upload file' }
  }
}
```

```typescript
// components/document-upload.tsx
'use client'

import { uploadDocument } from '@/app/actions'
import { useFormStatus } from 'react-dom'

function UploadButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Uploading...' : 'Upload Document'}
    </button>
  )
}

export function DocumentUpload() {
  return (
    <form action={uploadDocument}>
      <input
        name="document"
        type="file"
        accept=".pdf"
        required
      />
      <UploadButton />
    </form>
  )
}
```

## Form Accessibility

```typescript
// components/form-field.tsx
interface FormFieldProps {
  label: string
  name: string
  type?: string
  required?: boolean
  error?: string
  placeholder?: string
}

export function FormField({
  label,
  name,
  type = 'text',
  required = false,
  error,
  placeholder,
}: FormFieldProps) {
  const inputId = `${name}-input`

  return (
    <div className="form-group">
      <label htmlFor={inputId}>
        {label}
        {required && <span aria-label="required">*</span>}
      </label>

      <input
        id={inputId}
        name={name}
        type={type}
        placeholder={placeholder}
        required={required}
        aria-invalid={!!error}
        aria-describedby={error ? `${name}-error` : undefined}
      />

      {error && (
        <p id={`${name}-error`} className="error">
          {error}
        </p>
      )}
    </div>
  )
}
```

## Server Action Best Practices

1. **Always validate input** - Use Zod or similar
2. **Return errors gracefully** - Don't throw, return error state
3. **Revalidate cache** - Use `revalidatePath` or `revalidateTag`
4. **Handle files carefully** - Validate type, size, and scan
5. **Authenticate users** - Check session before mutations
6. **Log important actions** - For audit trails
7. **Rate limit** - Prevent abuse
8. **Use transactions** - For multi-step operations
9. **Optimize data** - Only fetch needed fields
10. **Monitor errors** - Use error tracking service

## Related Standards

- {{standards/backend/server-actions}} - Server Actions implementation details
- {{standards/global/validation}} - Validation schemas
- {{standards/global/error-handling}} - Error handling patterns
