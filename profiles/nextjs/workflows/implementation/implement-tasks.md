# Next.js Task Implementation Workflow

Guide for implementing Next.js features following specifications.

## Pre-Implementation Checklist

Before starting implementation:

- [ ] Specification reviewed and approved
- [ ] Tasks broken down into atomic units
- [ ] Tech stack decisions made
- [ ] Database schema finalized
- [ ] Team agrees on architecture
- [ ] Testing strategy documented

## Implementation Process

### 1. Setup & Structure

Create file structure matching specification:

```bash
# Create route structure
mkdir -p app/blog/[slug]/edit

# Create component directory
mkdir -p src/components/blog

# Create actions file
touch app/actions.ts

# Create API routes if needed
mkdir -p app/api/blog
```

Verify structure follows `{{standards/global/project-structure}}`

### 2. Database Setup

If schema changes needed:

```bash
# Create Prisma migration
npx prisma migrate dev --name add_feature_name

# Verify schema compiles
npx prisma generate
```

Verify schema follows `{{standards/backend/database}}`

### 3. Server Components & Data Fetching

Implement data fetching layer first:

```typescript
// app/blog/[slug]/page.tsx
import { db } from '@/lib/db'
import { notFound } from 'next/navigation'

export const revalidate = 3600 // ISR strategy

export async function generateStaticParams() {
  const posts = await db.post.findMany({
    select: { slug: true },
  })
  return posts.map((p) => ({ slug: p.slug }))
}

export default async function BlogPost({
  params,
}: {
  params: { slug: string }
}) {
  const post = await db.post.findUnique({
    where: { slug: params.slug },
  })

  if (!post) {
    notFound()
  }

  return <article>{post.content}</article>
}
```

Verify follows `{{standards/frontend/server-components}}` and `{{standards/frontend/data-fetching}}`

### 4. Create Schemas & Types

Define validation and types:

```typescript
// lib/schemas.ts
import { z } from 'zod'

export const createPostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(1),
  slug: z.string().regex(/^[a-z0-9-]+$/),
})

export type CreatePostInput = z.infer<typeof createPostSchema>
```

Verify follows `{{standards/global/validation}}`

### 5. Implement Server Actions

Add mutation logic:

```typescript
// app/actions.ts
'use server'

import { db } from '@/lib/db'
import { createPostSchema } from '@/lib/schemas'
import { revalidatePath } from 'next/cache'

export async function createPost(formData: FormData) {
  try {
    const data = {
      title: formData.get('title'),
      content: formData.get('content'),
      slug: generateSlug(formData.get('title') as string),
    }

    const validated = createPostSchema.parse(data)
    const post = await db.post.create({ data: validated })

    revalidatePath('/blog')
    return { success: true, post }
  } catch (error) {
    return { success: false, error: 'Failed to create post' }
  }
}
```

Verify follows `{{standards/backend/server-actions}}`

### 6. Implement Client Components

Build interactive UI:

```typescript
// app/blog/new/page.tsx
'use client'

import { createPost } from '@/app/actions'
import { useFormStatus } from 'react-dom'

function SubmitButton() {
  const { pending } = useFormStatus()
  return <button disabled={pending}>{pending ? 'Creating...' : 'Create'}</button>
}

export function NewPostForm() {
  return (
    <form action={createPost}>
      <input name="title" placeholder="Title" required />
      <textarea name="content" placeholder="Content" required />
      <SubmitButton />
    </form>
  )
}
```

Verify follows `{{standards/frontend/forms-actions}}` and `{{standards/frontend/components}}`

### 7. Add Error Handling

Implement error boundaries and handling:

```typescript
// app/blog/error.tsx
'use client'

interface ErrorProps {
  error: Error & { digest?: string }
  reset: () => void
}

export default function Error({ error, reset }: ErrorProps) {
  return (
    <div>
      <h2>Something went wrong</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

Verify follows `{{standards/global/error-handling}}`

### 8. Optimize Performance

Apply performance patterns:

```typescript
import Image from 'next/image'
import { Inter } from 'next/font/google'

const inter = Inter({ subsets: ['latin'] })

export default function BlogPost() {
  return (
    <article className={inter.className}>
      <Image
        src="/hero.jpg"
        alt="Hero"
        width={1200}
        height={600}
        quality={75}
      />
      {/* content */}
    </article>
  )
}
```

Verify follows `{{standards/frontend/performance}}`, `{{standards/frontend/image-optimization}}`, `{{standards/frontend/fonts}}`

### 9. Add Metadata & SEO

Implement metadata:

```typescript
// app/blog/[slug]/page.tsx
import { Metadata } from 'next'

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const post = await db.post.findUnique({
    where: { slug: params.slug },
  })

  if (!post) return { title: 'Not found' }

  return {
    title: post.title,
    description: post.excerpt,
  }
}
```

Verify follows `{{standards/frontend/metadata}}`

### 10. Write Tests

Implement unit and E2E tests:

```typescript
// __tests__/actions.test.ts
import { createPost } from '@/app/actions'

describe('createPost', () => {
  it('creates post with valid data', async () => {
    const formData = new FormData()
    formData.append('title', 'My Post')
    formData.append('content', 'Content here')

    const result = await createPost(formData)

    expect(result.success).toBe(true)
    expect(result.post?.title).toBe('My Post')
  })
})
```

```typescript
// e2e/blog.spec.ts
import { test, expect } from '@playwright/test'

test('can create blog post', async ({ page }) => {
  await page.goto('/blog/new')
  await page.fill('input[name="title"]', 'My Post')
  await page.fill('textarea[name="content"]', 'Content')
  await page.click('button:has-text("Create")')
  await expect(page).toHaveURL(/\/blog\/.*/)
})
```

Verify follows `{{standards/testing/test-writing}}`

### 11. Code Review & Polish

Before merging:

- [ ] Code follows `{{standards/global/coding-style}}`
- [ ] All tests pass
- [ ] Type checking passes (`tsc`)
- [ ] Linting passes (`eslint`)
- [ ] Performance metrics acceptable
- [ ] Accessibility checks passed
- [ ] No console errors/warnings
- [ ] Database migrations tested
- [ ] Security reviewed

### 12. Deployment Verification

Before deploying:

```bash
# Test production build
npm run build

# Run full test suite
npm run test

# Check bundle size
npm run analyze
```

Verify follows `{{standards/global/deployment}}`

## Common Implementation Patterns

### Form with Validation

```typescript
// 1. Define schema
const schema = z.object({...})

// 2. Create Server Action
export async function submitForm(formData: FormData) {
  const validated = schema.safeParse(Object.fromEntries(formData))
  if (!validated.success) return { errors: validated.error.flatten() }
  // Process...
}

// 3. Build Client Form
export function Form() {
  return <form action={submitForm}>...</form>
}
```

### Fetching & Displaying Data

```typescript
// 1. Server Component fetches data
export default async function Page() {
  const data = await db.item.findMany()
  return <ItemList items={data} />
}

// 2. Client Component for interactivity
'use client'
export function ItemList({ items }) {
  const [selected, setSelected] = useState<string | null>(null)
  return (...)
}
```

### Authentication Check

```typescript
import { getSession } from '@/lib/auth'

export async function ProtectedPage() {
  const session = await getSession()

  if (!session) {
    redirect('/login')
  }

  return <div>Protected content for {session.user.name}</div>
}
```

## Debugging Tips

### Server Component Issues

```typescript
// Add logging to understand data flow
console.log('Fetched data:', data)

// Check that component is actually server-side
// No 'use client' at top of file
```

### Form Submission Issues

```typescript
// Log form data
export async function submitForm(formData: FormData) {
  console.log('Form data:', Object.fromEntries(formData))
  // Process...
}
```

### Caching Issues

```bash
# Clear Next.js cache
rm -rf .next

# Rebuild
npm run build
```

### Type Errors

```bash
# Run TypeScript check
npx tsc --noEmit

# Fix errors before committing
```

## Post-Implementation Checklist

After implementation completes:

- [ ] All tests passing
- [ ] No TypeScript errors
- [ ] No ESLint errors
- [ ] Code reviewed
- [ ] Performance metrics acceptable
- [ ] Accessibility verified
- [ ] Documentation updated
- [ ] Deployed successfully
- [ ] Monitored in production
- [ ] Team trained if needed

## Related Standards

- {{standards/global/coding-style}} - Code style guide
- {{standards/frontend/components}} - Component patterns
- {{standards/backend/server-actions}} - Server Action details
- {{standards/frontend/forms-actions}} - Form patterns
- {{standards/testing/test-writing}} - Testing patterns
