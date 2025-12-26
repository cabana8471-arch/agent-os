# React Project Tech Stack Planning

## Framework & Build Tool

- **Framework**: React 19 with hooks
- **Build Tool**: Vite 6.x (modern, fast, supports HMR)
- **Runtime**: Node.js 20+ LTS
- **Package Manager**: npm / yarn / pnpm

## Frontend Stack

### UI & Styling (Pick one primary approach)

**Option 1: Tailwind CSS (Recommended)**
- Utility-first CSS framework
- Rapid UI development
- Design tokens built-in
- Great for consistency

**Option 2: CSS Modules**
- Component-scoped styling
- No naming conflicts
- CSS first approach

**Option 3: Styled Components / Emotion**
- CSS-in-JS
- Dynamic styling
- Component API
- Higher runtime overhead

### Routing

- **React Router v7**: Most popular, stable, feature-complete

### Forms & Validation

- **React Hook Form**: Performance-optimized form handling
- **Zod**: Type-safe schema validation
- **Combination**: RHF + Zod for best DX

### State Management (Pick one)

**Option 1: React Context + Hooks (Suitable for)**
- Small to medium apps
- Simple state needs
- Low-frequency updates

**Option 2: Zustand (Recommended for mid-size)**
- Lightweight (~2kb)
- Great DX
- Solves Context re-render issues
- Excellent for medium-large apps

**Option 3: Tanstack Query**
- For server/API state
- Caching, syncing
- Pairs well with other state managers

**Option 4: Redux**
- Large complex apps
- DevTools, middleware
- More boilerplate
- Learning curve

### Server State Management

- **Tanstack Query (React Query)**: Essential for API caching
- **Features**: Automatic caching, refetching, mutations

## Backend Stack (Full-Stack)

### Server Framework (Pick one)

**Express.js**
- Most popular
- Minimal, flexible
- Large ecosystem

**Fastify**
- Modern, fast
- Built-in features
- Type-safe (TypeScript)

**Hono**
- Lightweight
- Edge-runtime compatible
- Perfect for serverless

### Database (Pick one)

**PostgreSQL (Recommended)**
- Relational, mature
- Powerful, reliable
- Excellent ecosystem

**MongoDB**
- Document-based
- Flexible schema
- Good for rapid development

**SQLite**
- Simple, embedded
- Good for prototypes
- Limited scaling

### ORM/Query Builder (Pick one)

**Prisma (Recommended)**
- Type-safe, excellent DX
- Migrations built-in
- Works with all databases

**Drizzle**
- SQL-first
- Lightweight
- Strong TypeScript support

**TypeORM**
- Decorator-based
- Complex queries
- Learning curve

### API Strategy

- **REST API**: Standard HTTP endpoints
- **tRPC**: End-to-end type safety (recommended if using Node backend)
- **GraphQL**: Complex data requirements (overhead for simple apps)

## Testing

### Unit & Integration

- **Vitest**: Fast, Vite-native (recommended)
- **Jest**: Industry standard

### Component Testing

- **React Testing Library**: Behavior-focused (recommended)

### E2E Testing

- **Playwright**: Modern, reliable, cross-browser (recommended)
- **Cypress**: Popular, good DX

### Test Coverage Goals

- Critical user flows: 90%+
- UI components: 70%+
- Utilities: 80%+

## Development Tools

### Linting & Formatting

- **ESLint 9.x**: Code quality
- **Prettier**: Code formatting
- **@typescript-eslint**: TypeScript support

### IDE & Extensions

- **VSCode** (recommended)
- **ESLint extension**
- **Prettier extension**

### Environment Management

- **dotenv**: Environment variables
- **.env.local**: Local config (git-ignored)

## Deployment

### Frontend Deployment

- **Vercel**: Optimal for Vite/Next.js
- **Netlify**: Good alternative
- **Self-hosted**: Docker + Nginx

### Backend Deployment

- **Railway**: Easy deployment platform
- **Render**: Free tier available
- **Docker**: Self-hosted options
- **Serverless**: Vercel Functions, AWS Lambda

## Development Workflow

### Version Control

- **Git**: Always
- **GitHub/GitLab**: For repository hosting

### CI/CD

- **GitHub Actions**: Free, integrated
- **GitLab CI**: Also free
- Run tests and linting on each push

### Package Management

- **pnpm**: Fast, efficient (recommended for monorepos)
- **yarn**: Solid alternative
- **npm**: Default, always available

## Monorepo Consideration

If combining frontend + backend:

- **pnpm workspaces** (recommended)
- **Turborepo** for task orchestration
- **Shared types package** for type safety

## Summary Tech Stack (Recommended)

```
Frontend:
- React 19 + Vite
- TypeScript
- Tailwind CSS
- React Router v7
- React Hook Form + Zod
- Zustand
- Tanstack Query
- Vitest + RTL + Playwright

Backend (if applicable):
- Node.js + Express/Fastify
- PostgreSQL
- Prisma ORM
- tRPC or REST API

Development:
- pnpm
- ESLint + Prettier
- GitHub + GitHub Actions
```

## Related Standards

- {{standards/global/tech-stack}} - Tech stack details
- {{standards/backend/api}} - API patterns
- {{standards/testing/test-writing}} - Testing patterns
