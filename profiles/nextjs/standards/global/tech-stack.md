# Next.js Tech Stack

## Framework & Runtime

- **Next.js**: 15.x (App Router, latest)
- **React**: 19.x (Server Components by default)
- **Node.js**: 20+ LTS
- **TypeScript**: 5.x (strict mode enabled)

## Build & Development

- **Package Manager**: npm/pnpm/yarn (pnpm preferred for monorepos)
- **Bundler**: Next.js built-in (Webpack 5 or Turbopack)
- **Transpiler**: SWC (built-in, optional Babel)

## Frontend Libraries

### Styling (Pick One)
- **Tailwind CSS**: 4.x (utility-first, recommended)
- **CSS Modules**: For component-scoped styling (built-in)
- **Styled Components**: For CSS-in-JS (if preferred)

### UI Component Library (Optional)
- **shadcn/ui**: Headless, copy-paste components (Tailwind-first)
- **Radix UI**: Unstyled, accessible primitives
- Custom component library

### Forms & Validation
- **React Hook Form**: 7.x (performance-first form library)
- **Zod**: Schema validation with TypeScript inference
- **Server Actions**: Built-in form submission handling

### State Management (Pick One)
- **React Context API**: For simple, co-located state
- **Zustand**: Lightweight global state
- **TanStack Query**: Server state management and caching (primary choice)
- **Redux**: Only if complexity demands it (uncommon for Next.js)

### Data Fetching
- **fetch()**: Native, with Next.js caching built-in (recommended)
- **TanStack Query**: For client-side data fetching
- **SWR**: Lightweight alternative to TanStack Query
- **GraphQL**: Apollo Client (if using GraphQL backend)

## Backend (Full-Stack)

### Database (Pick One)
- **PostgreSQL**: Type-safe queries with Prisma/Drizzle (recommended)
- **MongoDB**: Document database with Mongoose/Prisma
- **SQLite**: Development/lightweight deployments

### ORM/Query Builder (Pick One)
- **Prisma**: Type-safe ORM with migrations and introspection (recommended)
- **Drizzle**: Lightweight, SQL-first approach with great TypeScript support
- **TypeORM**: For complex enterprise applications (less common with Next.js)

### Authentication
- **NextAuth.js** (v5, Auth.js): OpenSource, self-hosted auth
- **Clerk**: Modern alternative with built-in UI
- **Auth0**: Enterprise authentication
- **Custom OAuth**: With Server Actions

### API Communication
- **Server Actions**: Type-safe mutations from Server Components (recommended)
- **Route Handlers**: REST API endpoints (when needed)
- **GraphQL**: Apollo Server (if mature query language needed)

## Testing

### Unit & Integration
- **Jest**: Test runner with Next.js support
- **Vitest**: Fast alternative to Jest (optional)
- **React Testing Library**: Behavior-focused component testing
- **@testing-library/react-hooks**: Hook testing utilities

### E2E Testing
- **Playwright**: Modern, cross-browser, API-first (recommended)
- **Cypress**: Alternative with UI runner

### API Testing
- **Testing Library + Playwright**: For Route Handlers
- **Supertest**: API endpoint testing (if using Express-like routing)

## Linting & Formatting

- **ESLint**: 9.x with Next.js plugin
- **Prettier**: Code formatter
- **@typescript-eslint/parser**: TypeScript parsing for ESLint
- **@next/eslint-plugin-next**: Next.js-specific rules

## Deployment

### Platform (Pick One)
- **Vercel**: Optimal for Next.js (recommended, free tier available)
- **Self-hosted**: Docker container on any VPS
- **Netlify**: Alternative with good DX
- **Railway**: Managed platform with PostgreSQL
- **AWS/Azure**: For enterprise deployments

### Hosting Configuration
- **Vercel**: Zero-config, handles Edge Runtime, ISR, Streaming
- **Self-hosted**: Docker image, environment variables, npm start
- **Edge Runtime** (Vercel): For lightweight API routes
- **Node.js Runtime**: Default for Server Components and Route Handlers

## Environment Configuration

### Variables
- **NEXT_PUBLIC_*** : Client-side accessible variables (bundled)
- **Server-only**: Sensitive variables in .env.local
- **.env.local**: Local development (git-ignored)
- **.env.production**: Production-specific (often in CI/CD)
- **.env.example**: Template for team

### Access Patterns
- **Client Components**: `process.env.NEXT_PUBLIC_*` only
- **Server Components**: All environment variables via `process.env`
- **Route Handlers**: All environment variables via `process.env`
- **Middleware**: NEXT_PUBLIC_* only

## Development Tools

- **Next.js DevTools**: Browser extension for debugging
- **React DevTools**: Component inspector and profiler
- **Chrome DevTools**: Network, performance profiling
- **VS Code Extensions**: ESLint, Prettier, Tailwind CSS IntelliSense

## Related Standards

- {{standards/global/project-structure}} - App directory organization
- {{standards/frontend/server-components}} - React 19 Server Components
- {{standards/backend/api}} - Route Handlers and API design
- {{standards/testing/test-writing}} - Testing patterns
