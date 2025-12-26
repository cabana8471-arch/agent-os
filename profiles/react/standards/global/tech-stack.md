# React Tech Stack

## Framework & Runtime

- **React**: 19.x (latest with hooks and concurrent features)
- **Node.js**: 20+ LTS
- **TypeScript**: 5.x (strict mode enabled)

## Build & Development

- **Build Tool**: Vite 6.x with React plugin (@vitejs/plugin-react)
- **SWC**: Optional for faster transpilation
- **Package Manager**: npm/pnpm/yarn (pnpm preferred for monorepos)

## Frontend Libraries

### Routing (Optional)
- **React Router**: 7.x for SPA routing
- Lazy loading with React.lazy + Suspense

### Styling (Pick One)
- **Tailwind CSS**: 4.x (utility-first, recommended)
- **CSS Modules**: For component-scoped styling
- **Styled Components**: For CSS-in-JS (if preferred)

### Forms & Validation
- **React Hook Form**: 7.x (performance-first form library)
- **Zod**: Schema validation with TypeScript inference

### State Management (Pick One)
- **React Context API**: For simple, co-located state
- **Zustand**: Lightweight global state
- **Tanstack Query**: Server state management and caching
- **Redux**: Only if complexity demands it

### UI Component Library (Optional)
- **shadcn/ui**: Headless, copy-paste components
- Custom component library

## Backend (Full-Stack Support)

### Runtime & Framework
- **Express.js** (5.x) or **Fastify** (4.x) or **Hono** (serverless-ready)
- **Node.js** runtime

### Database
- **PostgreSQL** (recommended, with Postgres.js or node-postgres)
- **MongoDB** (with Mongoose or native driver)
- **SQLite** (development/lightweight deployments)

### ORM/Query Builder
- **Prisma**: Type-safe ORM with migrations
- **Drizzle**: Lightweight, SQL-first approach
- **TypeORM**: For complex enterprise applications

### API Communication
- **REST API**: Standard HTTP endpoints
- **tRPC**: End-to-end type safety (optional, requires backend support)
- **GraphQL**: Only if mature query language is needed

## Testing

### Unit & Integration
- **Vitest**: Fast, Vite-native test runner
- **React Testing Library**: Behavior-focused component testing
- **@testing-library/react-hooks**: Hook testing utilities

### E2E Testing
- **Playwright**: Modern, cross-browser, API-first
- **Cypress**: Alternative with UI runner

### API Mocking
- **MSW (Mock Service Worker)**: Intercept network requests

## Linting & Formatting

- **ESLint**: 9.x with React plugin, @typescript-eslint
- **Prettier**: Code formatter (pair with ESLint)
- **@typescript-eslint/parser**: TypeScript parsing for ESLint

## Deployment

### Frontend
- **Vercel**: Optimal for Next.js/Vite apps (recommended for React SPAs)
- **Netlify**: Alternative with good DX
- **Self-hosted**: Docker + Nginx

### Backend (if monorepo)
- **Railway**: Managed platform
- **Render**: Free tier available
- **Docker**: Self-hosted on any VPS

## Development Tools

- **Vite DevTools**: Browser extension for debugging
- **React DevTools**: Component inspector and profiler
- **Zustand DevTools**: State inspection (if using Zustand)
- **Chrome DevTools**: Network, performance profiling

## Environment Configuration

- **.env.local**: Local environment variables (git-ignored)
- **Vite env variables**: VITE_* prefix for client-side variables
- **import.meta.env**: Vite's env accessor

## Related Standards

- {{standards/global/coding-style}} - TypeScript/JSX conventions
- {{standards/frontend/components}} - Component architecture
- {{standards/testing/test-writing}} - Testing patterns
