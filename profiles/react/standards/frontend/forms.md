# React Forms

## React Hook Form + Zod

Best practice: type-safe forms with runtime validation:

```typescript
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

// ✅ Good: Define schema and infer types
const loginSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Must be at least 8 characters'),
})

type LoginFormData = z.infer<typeof loginSchema>

// ✅ Good: Form component
function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isValid, isSubmitting },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    mode: 'onChange', // Validate on change
  })

  const onSubmit = async (data: LoginFormData) => {
    const result = await login(data)
    if (result.success) {
      navigate('/dashboard')
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="email">Email</label>
        <input id="email" {...register('email')} />
        {errors.email && <span>{errors.email.message}</span>}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input id="password" type="password" {...register('password')} />
        {errors.password && <span>{errors.password.message}</span>}
      </div>

      <button disabled={!isValid || isSubmitting}>
        {isSubmitting ? 'Signing in...' : 'Sign In'}
      </button>
    </form>
  )
}
```

## Validation

```typescript
// ✅ Good: Comprehensive validation
const userSchema = z.object({
  email: z.string().email(),
  password: z
    .string()
    .min(8)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[0-9]/, 'Must contain number'),
  confirmPassword: z.string(),
  age: z.number().min(18).max(150),
  bio: z.string().max(500).optional(),
}).refine(
  (data) => data.password === data.confirmPassword,
  {
    message: 'Passwords must match',
    path: ['confirmPassword'],
  }
)

// ✅ Good: Server validation integration
async function onSubmit(data: UserFormData) {
  try {
    const response = await api.createUser(data)
    setSuccess('Account created')
  } catch (error) {
    if (error.code === 'EMAIL_EXISTS') {
      setError('email', {
        message: 'Email already registered'
      })
    }
  }
}

// ✅ Good: Async validation
const emailSchema = z.string().email().refine(
  async (email) => {
    const exists = await checkEmailExists(email)
    return !exists
  },
  { message: 'Email already registered' }
)
```

## Complex Forms

```typescript
// ✅ Good: Dynamic field arrays
import { useFieldArray } from 'react-hook-form'

const schema = z.object({
  name: z.string(),
  experiences: z.array(z.object({
    company: z.string(),
    years: z.number(),
  }))
})

function ResumeForm() {
  const { control, register } = useForm({ resolver: zodResolver(schema) })
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'experiences'
  })

  return (
    <form>
      <input {...register('name')} />

      {fields.map((field, index) => (
        <div key={field.id}>
          <input {...register(`experiences.${index}.company`)} />
          <input {...register(`experiences.${index}.years`)} />
          <button onClick={() => remove(index)}>Remove</button>
        </div>
      ))}

      <button onClick={() => append({ company: '', years: 0 })}>
        Add Experience
      </button>
    </form>
  )
}
```

## Controlled vs Uncontrolled

```typescript
// ❌ Avoid: Fully controlled (verbose, re-renders on every keystroke)
const [email, setEmail] = useState('')
const [password, setPassword] = useState('')

<input value={email} onChange={(e) => setEmail(e.target.value)} />

// ✅ Good: Uncontrolled with React Hook Form (performant)
const { register } = useForm()

<input {...register('email')} />
// React Hook Form manages state internally
```

## Form State Management

```typescript
// ✅ Good: Track form state
const {
  register,
  handleSubmit,
  formState: {
    errors,        // Field errors
    isValid,       // Is entire form valid
    isDirty,       // Has form been modified
    isSubmitting,  // Is form submitting
    touchedFields, // Which fields user interacted with
  },
  watch,           // Watch field values
  setValue,        // Programmatically set values
  reset,           // Reset form
} = useForm()

// ✅ Good: Watch specific fields for dependent inputs
const watchCountry = watch('country')

// Show states/provinces based on selected country
const states = getStates(watchCountry)

// ✅ Good: Programmatic updates
const handlePreFill = (user) => {
  setValue('email', user.email)
  setValue('name', user.name)
}

// ✅ Good: Reset after successful submit
const onSubmit = async (data) => {
  await api.save(data)
  reset() // Clear form
  setSuccess('Saved')
}
```

## Accessibility

```typescript
// ✅ Good: Proper labels and error association
function FormField({
  name,
  label,
  error,
  ...props
}: FormFieldProps) {
  return (
    <div>
      <label htmlFor={name}>{label}</label>
      <input
        id={name}
        aria-invalid={!!error}
        aria-describedby={error ? `${name}-error` : undefined}
        {...props}
      />
      {error && (
        <span id={`${name}-error`} role="alert" className="text-red-600">
          {error.message}
        </span>
      )}
    </div>
  )
}

// ✅ Good: Required field indication
<label htmlFor="email">
  Email <span aria-label="required">*</span>
</label>
```

## Auto-Save & Drafts

```typescript
// ✅ Good: Auto-save with debounce
const { watch } = useForm<FormData>()
const formData = watch()

useEffect(() => {
  const timer = setTimeout(() => {
    saveDraft(formData)
  }, 1000) // Wait 1 second after last change

  return () => clearTimeout(timer)
}, [formData])

// ✅ Good: Confirm before leaving with unsaved changes
useEffect(() => {
  const handleBeforeUnload = (e) => {
    if (isDirty) {
      e.preventDefault()
      e.returnValue = ''
    }
  }

  window.addEventListener('beforeunload', handleBeforeUnload)
  return () => window.removeEventListener('beforeunload', handleBeforeUnload)
}, [isDirty])
```

## Best Practices

```typescript
// ❌ Avoid: Mixing validation libraries
// Don't use multiple validation libraries together

// ✅ Good: Consistent error display
function FormField({ error }) {
  return (
    <>
      <input />
      {error?.message && (
        <p className="text-sm text-red-600 mt-1">
          {error.message}
        </p>
      )}
    </>
  )
}

// ✅ Good: Success feedback
{success && (
  <div role="status" className="text-green-600 p-4">
    {success}
  </div>
)}

// ✅ Good: Loading state during submit
<button disabled={isSubmitting}>
  {isSubmitting ? 'Saving...' : 'Save'}
</button>
```

## Related Standards

- {{standards/global/validation}} - Server-side validation
- {{standards/frontend/accessibility}} - Accessible forms
- {{standards/frontend/state-management}} - Form state
