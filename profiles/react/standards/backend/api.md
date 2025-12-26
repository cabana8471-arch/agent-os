# React Backend API Integration

## API Client Setup

```typescript
// lib/api.ts
import axios, { AxiosError } from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

const client = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor - add auth token
client.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Response interceptor - handle errors
client.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('authToken')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default client
```

## Tanstack Query Integration

```typescript
// lib/api.ts continued
import { useMutation, useQuery } from '@tanstack/react-query'

// ✅ Good: Query hook pattern
export function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: async () => {
      const { data } = await client.get(`/users/${id}`)
      return data
    },
  })
}

export function useUsers(page: number = 1) {
  return useQuery({
    queryKey: ['users', page],
    queryFn: async () => {
      const { data } = await client.get('/users', {
        params: { page, limit: 10 },
      })
      return data
    },
  })
}

// ✅ Good: Mutation hook pattern
export function useCreateUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (userData) => {
      const { data } = await client.post('/users', userData)
      return data
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })
}

export function useUpdateUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async ({ id, ...data }) => {
      const response = await client.put(`/users/${id}`, data)
      return response.data
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['user', data.id] })
    },
  })
}
```

## tRPC for End-to-End Type Safety

```typescript
// server/routers/users.ts
import { router, publicProcedure } from '@/server/trpc'
import { z } from 'zod'

export const usersRouter = router({
  getById: publicProcedure
    .input(z.string())
    .query(async ({ input }) => {
      return db.user.findUnique({ where: { id: input } })
    }),

  list: publicProcedure
    .input(z.object({ page: z.number().default(1) }))
    .query(async ({ input }) => {
      return db.user.findMany({ skip: (input.page - 1) * 10, take: 10 })
    }),

  create: publicProcedure
    .input(z.object({ name: z.string(), email: z.string().email() }))
    .mutation(async ({ input }) => {
      return db.user.create({ data: input })
    }),
})
```

```typescript
// client/hooks/useUser.ts
import { trpc } from '@/lib/trpc'

export function useUser(id: string) {
  return trpc.users.getById.useQuery(id)
}

export function useCreateUser() {
  const utils = trpc.useUtils()

  return trpc.users.create.useMutation({
    onSuccess: () => {
      utils.users.list.invalidate()
    },
  })
}
```

## REST API with Vite Proxy

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
})

// Use in code
fetch('/api/users') // Proxied to http://localhost:3001/users
```

## Error Handling

```typescript
// ✅ Good: Typed error handling
interface ApiError {
  code: string
  message: string
  details?: Record<string, unknown>
}

export function useUserWithErrorHandling(id: string) {
  const { data, error, isLoading } = useQuery<User, ApiError>({
    queryKey: ['user', id],
    queryFn: () => fetchUser(id),
  })

  const handleError = () => {
    if (error?.code === 'NOT_FOUND') {
      return 'User not found'
    }
    if (error?.code === 'UNAUTHORIZED') {
      return 'You do not have permission'
    }
    return error?.message || 'An error occurred'
  }

  return { data, error: handleError(), isLoading }
}
```

## Request/Response Types

```typescript
// types/api.ts
export interface CreateUserRequest {
  name: string
  email: string
  password: string
}

export interface UserResponse {
  id: string
  name: string
  email: string
  createdAt: string
}

export interface PaginatedResponse<T> {
  items: T[]
  total: number
  page: number
}

// Usage
export function useCreateUser() {
  return useMutation({
    mutationFn: (data: CreateUserRequest) =>
      client.post<UserResponse>('/users', data),
  })
}
```

## Related Standards

- {{standards/global/validation}} - Input validation
- {{standards/global/error-handling}} - Error patterns
- {{standards/frontend/state-management}} - State patterns
