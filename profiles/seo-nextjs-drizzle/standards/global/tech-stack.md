# Tech Stack - SEO Optimization Application

This standard documents the complete technology stack for the SEO Optimization application, a full-stack Next.js application with Drizzle ORM, BetterAuth, and advanced AI integration.

## I. Core Framework & Runtime

### Next.js
- **Version**: 16.0.7 (latest with App Router)
- **Features**: Server Components, Server Actions, App Router, Edge Runtime support
- **Key**: `next` in package.json

### React
- **Version**: 19.2.1 (latest stable)
- **Use cases**: Component library, hooks (useClient), interactive components
- **Features**: Concurrent rendering, automatic batching

### TypeScript
- **Version**: 5.9.3 (latest stable)
- **Configuration**: Strict mode enabled, path aliases (@/ for src/)
- **Benefits**: Full type safety across backend and frontend

### Node.js Runtime
- **Version**: 18+ (required by Next.js 16)
- **Environment**: Vercel deployment with Edge Runtime support

---

## II. Database & ORM

### PostgreSQL
- **Version**: 8.16.3+ (production database)
- **Purpose**: Relational database for all application data
- **Hosted**: Typically on Vercel Postgres or external PostgreSQL provider

### Drizzle ORM
- **Version**: 0.44.7 (type-safe ORM)
- **Why Drizzle**:
  - Full TypeScript support with type inference
  - No code generation step (unlike Prisma)
  - SQL-first approach with type safety
  - Excellent performance and flexibility
- **Adapter**: Built-in PostgreSQL support via `drizzle-orm/postgres-js`

### Database Drivers
- **postgres**: 3.4.7 (primary JavaScript PostgreSQL client)
- **pg**: 8.16.3 (alternative Node.js PostgreSQL client)

### Schema Structure
Database includes 12+ tables:
- **Auth**: `user`, `session`, `account`, `verification`
- **Data**: `project`, `scanned_page`, `scan_history`
- **Content**: `prompt_template`, `recommendation`
- **Support**: `notification`, `audit_log`

---

## III. Authentication

### BetterAuth
- **Version**: 1.4.5 (modern authentication framework)
- **Advantages over NextAuth**:
  - Simpler API and configuration
  - Better TypeScript support
  - Drizzle adapter built-in
  - Smaller bundle size
  - Better customization options

### OAuth Providers
- **Google**: OAuth 2.0 with Google sign-in
- **GitHub**: OAuth 2.0 with GitHub sign-in
- Both configured via environment variables

### Session Management
- **Type**: Session-based (not JWT by default)
- **Storage**: BetterAuth tables in PostgreSQL via Drizzle
- **Client Hook**: `useSession()` from auth-client
- **Server**: `auth.api.getSession()` with request headers

---

## IV. Background Jobs & Task Queue

### Inngest
- **Version**: 3.27.0 (serverless job queue)
- **Purpose**: Asynchronous job processing without infrastructure
- **Deployment**: Webhook-based integration with Inngest platform

### Job Types
- **page/scan.requested** - Triggered when user requests page scan
- **page/batch.scan** - Batch scanning multiple pages
- **page/analyze** - AI-powered SEO analysis
- **notification/send** - Real-time user notifications

### Integration
- **Client**: Inngest SDK initialized with API key
- **Handler**: `/api/inngest/route.ts` webhook endpoint
- **Functions**: Located in `src/inngest/functions/`

---

## V. Real-Time Communication

### Pusher
- **Server SDK**: 5.2.0 (`pusher` package)
- **Client SDK**: 8.4.0 (`pusher-js` package)
- **Purpose**: WebSocket-based real-time updates

### Event Types
- **analysis-complete** - Analysis finished, display results
- **scan-progress** - Batch scan progress (25%, 50%, 75%, 100%)
- **notification-received** - User notifications in real-time
- **collaboration-update** - Multi-user workspace updates

### Channels
- Private channels: `page-{pageId}` for page-specific updates
- User channels: `user-{userId}` for user-specific notifications

---

## VI. File Storage

### Vercel Blob
- **Version**: 2.0.0 (serverless file storage)
- **Purpose**: Persistent file storage for reports and uploads
- **Access**: Public URLs for reports, private for sensitive files

### Use Cases
- PDF report exports
- CSV data downloads
- Temporary file processing
- Asset hosting

---

## VII. AI Integration

### Vercel AI SDK
- **Package**: `@ai-sdk/react` v2.0.106
- **Purpose**: React hooks and utilities for AI features
- **Features**: useStream, useChat, readStreamableValue
- **Benefits**: Streaming responses, real-time UI updates

### OpenRouter Provider
- **Package**: `@openrouter/ai-sdk-provider` v1.3.0
- **Purpose**: Access to 200+ AI models through single API
- **Default Model**: `openai/gpt-5-mini` (fast, cost-effective)
- **Fallback Model**: `anthropic/claude-3.5-sonnet` (complex analysis)

### AI Features
- **SEO Analysis**: Analyze pages for optimization opportunities
- **Content Suggestions**: Generate optimization recommendations
- **Copilot Chat**: Interactive assistant for users
- **Prompt Templates**: 30+ customizable prompt templates with variables

---

## VIII. Frontend Stack

### Styling Framework
- **Tailwind CSS**: 4.1.17 (utility-first CSS framework)
- **Mode**: JIT compilation with PostCSS

### Component Library
- **shadcn/ui**: 3.5.1 (headless UI components)
- **Radix UI**: Headless components via shadcn/ui
- **lucide-react**: 0.539.0 (icon library with 539+ icons)

### Data Visualization
- **Recharts**: 3.6.0 (React charts and graphs)
- **Use cases**: Score ring charts, trend graphs, data tables

### Content Rendering
- **react-markdown**: 10.1.0 (Markdown to React components)
- **Prism.js**: Code syntax highlighting for analysis reports

---

## IX. Testing Framework

### Unit & Integration Testing
- **Vitest**: 4.0.15 (Vite-native test runner, faster than Jest)
- **React Testing Library**: 16.3.0 (DOM testing utilities)
- **Happy DOM**: 20.0.11 (lightweight DOM implementation)

### End-to-End Testing
- **Playwright**: 1.57.0 (cross-browser E2E testing)
- **Use cases**: User flows, OAuth integration, real-time features
- **Browsers**: Chrome (primary), Firefox and Safari for compatibility

### Test Organization
- Unit tests: `__tests__/` next to source files
- E2E tests: `e2e/` directory at root
- Mocks and fixtures: `__tests__/fixtures/`

---

## X. Development Tools

### Package Manager
- **pnpm**: Latest version (fast, disk-efficient)
- **Node Package Registry**: npm registry

### Code Quality
- **ESLint**: 9.39.1 (JavaScript linting)
- **Prettier**: 3.7.4 (code formatting)
- **Configuration**: Unified config for frontend and backend

### Build & Dev Server
- **Turbopack**: Development bundler (faster than Webpack)
- **Next.js Compiler**: TypeScript compilation and JSX transformation
- **Dev Server**: `next dev` with HMR

---

## XI. Environment & Configuration

### Environment Variables
- **Database**: `DATABASE_URL` (PostgreSQL connection string)
- **Auth**: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GITHUB_CLIENT_ID`, `GITHUB_CLIENT_SECRET`
- **Inngest**: `INNGEST_EVENT_KEY`, `INNGEST_SIGNING_KEY`
- **Pusher**: `PUSHER_APP_ID`, `PUSHER_KEY`, `PUSHER_SECRET`, `PUSHER_CLUSTER`
- **OpenRouter**: `OPENROUTER_API_KEY`
- **Vercel Blob**: `BLOB_READ_WRITE_TOKEN`
- **Client**: `NEXT_PUBLIC_PUSHER_KEY`, `NEXT_PUBLIC_PUSHER_CLUSTER`, `NEXT_PUBLIC_APP_URL`

### Configuration Files
- `next.config.js` - Next.js configuration
- `drizzle.config.ts` - Drizzle ORM migration config
- `vitest.config.ts` - Test runner configuration
- `playwright.config.ts` - E2E test configuration
- `tailwind.config.ts` - Tailwind CSS customization
- `tsconfig.json` - TypeScript compiler options

---

## XII. Production Deployment

### Platform
- **Vercel**: Recommended for Next.js 16 (native support)
- **Alternatives**: AWS Amplify, Netlify, self-hosted Node.js

### Deployment Features
- **Edge Functions**: `app/api/` routes run on Edge (low latency)
- **Serverless Functions**: `/api/inngest`, `/api/copilot` for dynamic workloads
- **Static Generation**: Pages and API routes with ISR (Incremental Static Regeneration)
- **Environment Secrets**: Managed through Vercel dashboard

### Database
- **Vercel Postgres**: Integrated PostgreSQL (recommended)
- **Connection Pooling**: Handled by `postgres` client library

### File Storage
- **Vercel Blob**: Native integration, included with Vercel Pro

---

## XIII. Development Workflow

### Local Development
```bash
# Install dependencies
pnpm install

# Set up database (migrations)
pnpm run db:push

# Start development server
pnpm run dev

# Open in browser
# http://localhost:3000
```

### Development Commands
```bash
# Run tests
pnpm run test              # Watch mode
pnpm run test:run          # Single run
pnpm run test:coverage     # Coverage report

# E2E testing
pnpm run test:e2e

# Database
pnpm run db:generate       # Generate migrations
pnpm run db:migrate        # Apply migrations
pnpm run db:push           # Push schema (dev only)
pnpm run db:studio         # Drizzle Studio (visual database tool)

# Build for production
pnpm run build

# Format and lint
pnpm run format
pnpm run lint
```

---

## XIV. Architecture Principles

### Server-First
- **Server Components** by default for data fetching
- **Server Actions** for mutations and form submissions
- **Client Components** only where interaction is needed

### Type Safety
- **TypeScript** in strict mode across entire codebase
- **Drizzle** type inference for database operations
- **Zod** schemas for request validation and API contracts

### Performance
- **Image Optimization**: next/image with automatic sizing
- **Font Optimization**: next/font with subset loading
- **Code Splitting**: Automatic with dynamic imports
- **Caching Strategy**: ISR for static content, revalidation for dynamic

### Security
- **OAuth**: Industry-standard authentication
- **HTTPS Only**: Enforced in production
- **CORS**: Configured for BetterAuth endpoints
- **CSP Headers**: Content Security Policy for XSS prevention
- **Secrets**: All keys stored in environment variables

---

## XV. Scalability & Monitoring

### Performance Monitoring
- **Web Vitals**: Core Web Vitals tracking
- **Error Tracking**: Sentry integration (optional)
- **Analytics**: Vercel Analytics

### Database Performance
- **Indexes**: On foreign keys and frequently queried columns
- **Connection Pool**: Managed by `postgres` driver
- **Query Optimization**: Relational queries with Drizzle

### Job Queue Scalability
- **Inngest**: Auto-scales based on event volume
- **Retry Logic**: Built-in retry with exponential backoff
- **Monitoring**: Inngest dashboard for job tracking

---

## Related Standards

- {{standards/backend/database}} - Drizzle ORM patterns and examples
- {{standards/backend/api}} - API routes with BetterAuth
- {{standards/backend/auth}} - BetterAuth authentication guide
- {{standards/backend/background-jobs}} - Inngest job patterns
- {{standards/backend/realtime}} - Pusher real-time updates
- {{standards/backend/storage}} - Vercel Blob file operations
- {{standards/backend/ai-integration}} - OpenRouter and AI SDK usage
- {{standards/frontend/server-components}} - React Server Components patterns
- {{standards/frontend/forms-actions}} - Server Actions for forms
- {{standards/testing/test-writing}} - Vitest and Playwright testing
