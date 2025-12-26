# React Validation

## Zod Schema Validation

```typescript
import { z } from 'zod'

// ✅ Good: Comprehensive schema
const userSchema = z.object({
  email: z.string().email('Invalid email').toLowerCase(),
  password: z.string().min(8, 'Must be at least 8 chars').regex(
    /[A-Z]/,
    'Must have uppercase'
  ),
  age: z.number().min(18).max(150).optional(),
  terms: z.boolean().refine((val) => val, {
    message: 'Must accept terms',
  }),
})

type User = z.infer<typeof userSchema>

// ✅ Good: Async validation (DB checks)
const emailSchema = z.string().email().refine(
  async (email) => {
    const exists = await checkEmailExists(email)
    return !exists
  },
  { message: 'Email already registered' }
)
```

## Client-Side with React Hook Form

```typescript
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'

function RegistrationForm() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<User>({
    resolver: zodResolver(userSchema),
    mode: 'onChange',
  })

  return (
    <form onSubmit={handleSubmit((data) => submitForm(data))}>
      <input {...register('email')} />
      {errors.email && <span>{errors.email.message}</span>}

      <input type="password" {...register('password')} />
      {errors.password && <span>{errors.password.message}</span>}

      <button type="submit">Register</button>
    </form>
  )
}
```

## Server-Side Validation

```typescript
// Backend (Express example)
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

app.post('/users', (req, res) => {
  // Validate with same schema as frontend
  const result = userSchema.safeParse(req.body)

  if (!result.success) {
    return res.status(400).json({ errors: result.error.flatten() })
  }

  // Process valid data
  createUser(result.data)
})
```

## Validation Patterns

```typescript
// ✅ Good: Conditional validation
const formSchema = z
  .object({
    accountType: z.enum(['personal', 'business']),
    businessName: z.string().optional(),
  })
  .refine(
    (data) => {
      if (data.accountType === 'business') {
        return !!data.businessName
      }
      return true
    },
    {
      message: 'Business name required for business accounts',
      path: ['businessName'],
    }
  )

// ✅ Good: Array validation
const tagsSchema = z.object({
  tags: z
    .array(z.string().min(1))
    .min(1, 'At least one tag required')
    .max(5, 'Maximum 5 tags'),
})

// ✅ Good: Discriminated union
type Shape =
  | { type: 'circle'; radius: number }
  | { type: 'rectangle'; width: number; height: number }

const shapeSchema: z.ZodType<Shape> = z.discriminatedUnion('type', [
  z.object({ type: z.literal('circle'), radius: z.number() }),
  z.object({
    type: z.literal('rectangle'),
    width: z.number(),
    height: z.number(),
  }),
])
```

## Custom Validators

```typescript
// ✅ Good: Custom validation function
function validatePasswordStrength(password: string): boolean {
  const hasUpperCase = /[A-Z]/.test(password)
  const hasLowerCase = /[a-z]/.test(password)
  const hasNumbers = /\d/.test(password)
  const hasSpecialChar = /[!@#$%^&*]/.test(password)

  return hasUpperCase && hasLowerCase && hasNumbers && hasSpecialChar
}

const passwordSchema = z
  .string()
  .min(8)
  .refine(validatePasswordStrength, {
    message: 'Password must contain uppercase, lowercase, number, and special char',
  })

// ✅ Good: Reusable validators
const emailSchema = z.string().email().refine(
  async (email) => {
    const exists = await db.user.findUnique({ where: { email } })
    return !exists
  },
  { message: 'Email already registered' }
)
```

## Form-Level Validation

```typescript
// ✅ Good: Validate entire form
const formSchema = z
  .object({
    password: z.string(),
    confirmPassword: z.string(),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: 'Passwords must match',
    path: ['confirmPassword'],
  })

// ✅ Good: Handle validation errors in form
function handleValidationError(error: z.ZodError) {
  const fieldErrors = error.flatten().fieldErrors
  return fieldErrors // { field: ['error message'] }
}
```

## Dynamic Validation

```typescript
// ✅ Good: Build schema based on conditions
function getProductSchema(productType: 'digital' | 'physical') {
  const baseSchema = z.object({
    name: z.string(),
    price: z.number().positive(),
  })

  if (productType === 'physical') {
    return baseSchema.extend({
      weight: z.number(),
      dimensions: z.object({
        length: z.number(),
        width: z.number(),
        height: z.number(),
      }),
    })
  }

  return baseSchema.extend({
    downloadUrl: z.string().url(),
  })
}
```

## Related Standards

- {{standards/frontend/forms}} - Form patterns
- {{standards/global/error-handling}} - Error handling
- {{standards/backend/api}} - API validation
