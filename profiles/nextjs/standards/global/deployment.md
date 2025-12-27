# Next.js Deployment

## Vercel Deployment (Recommended)

Vercel is the company behind Next.js and provides optimal platform:

### Setup

1. Connect GitHub repository to Vercel
2. Vercel auto-detects Next.js and configures build settings
3. Push to main branch to deploy automatically

### Environment Variables

Set in Vercel dashboard under Project > Settings > Environment Variables:

```
DATABASE_URL=postgresql://...
NEXTAUTH_SECRET=your-secret
STRIPE_SECRET_KEY=sk_live_...
```

Client-side variables (`NEXT_PUBLIC_*`) are automatically available.

### Build & Preview

- **Preview**: Automatically created for pull requests
- **Production**: Main branch deployments
- **Staging**: Optional environment for testing

### Advantages

- Zero-config deployment
- Automatic HTTPS and custom domains
- Edge Runtime support for API routes
- ISR and Streaming out-of-the-box
- Built-in analytics and monitoring
- Free tier available

### Vercel Configuration

Optional `vercel.json` for custom settings:

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "env": {
    "NODE_ENV": "production"
  }
}
```

## Self-Hosted Deployment

Deploy Next.js to any Node.js server.

### Docker Setup

Create `Dockerfile`:

```dockerfile
FROM node:20-alpine AS base

WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM base AS builder
COPY . .
RUN npm run build

FROM node:20-alpine AS production
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./next.config.ts
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]
```

### Build & Run

```bash
# Build Docker image
docker build -t myapp:latest .

# Run container locally
docker run -p 3000:3000 myapp:latest

# Deploy to production
docker push myregistry/myapp:latest
```

### next.config.ts Settings for Self-Hosted

```typescript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone', // Reduce image size, faster startup
  typescript: {
    tsconfigPath: './tsconfig.json',
  },
}

export default nextConfig
```

### Hosting Providers

Popular options:

- **Railway**: Simple deployment with PostgreSQL included
- **Render**: Free tier, auto-deploys from GitHub
- **DigitalOcean**: VPS with Docker support
- **AWS EC2/ECS**: Enterprise deployments
- **Azure App Service**: Microsoft's managed platform

## Static Export (Limited Use)

If you don't need Server Components or dynamic routes:

```typescript
// next.config.ts
const nextConfig = {
  output: 'export', // Static HTML export
}

export default nextConfig
```

Limitations:
- No Server Components
- No Route Handlers
- No dynamic routes with server-side generation
- No ISR (incremental static regeneration)

Use only for fully static sites (blogs, landing pages).

## Environment-Specific Configuration

### next.config.ts Patterns

```typescript
const nextConfig = {
  // Development
  ...(process.env.NODE_ENV === 'development' && {
    productionBrowserSourceMaps: true,
  }),

  // Production
  ...(process.env.NODE_ENV === 'production' && {
    productionBrowserSourceMaps: false,
    compress: true,
    poweredByHeader: false,
  }),

  // Redirects
  async redirects() {
    return [
      {
        source: '/old-page',
        destination: '/new-page',
        permanent: true,
      },
    ]
  },

  // Rewrites
  async rewrites() {
    return {
      beforeFiles: [
        {
          source: '/api/:path*',
          destination: 'http://localhost:8080/api/:path*',
        },
      ],
    }
  },
}

export default nextConfig
```

## Monitoring & Observability

### Logging

```typescript
// lib/logger.ts
export function log(level: 'info' | 'error' | 'warn', message: string, data?: any) {
  const timestamp = new Date().toISOString()
  console.log(JSON.stringify({ timestamp, level, message, ...data }))
}

// Usage
log('info', 'User created', { userId: '123' })
log('error', 'Database error', { error: err.message })
```

### Error Tracking

Integrate Sentry or similar:

```typescript
// lib/sentry.ts
import * as Sentry from "@sentry/nextjs"

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
})

export default Sentry
```

### Performance Monitoring

Use Vercel Analytics (automatic on Vercel) or:

```typescript
// lib/analytics.ts
export function trackPageView(pathname: string) {
  if (typeof window === 'undefined') return // Server-side

  navigator.sendBeacon('/api/analytics', JSON.stringify({ pathname }))
}
```

## Security Best Practices

1. **HTTPS Only** - All connections encrypted
2. **CORS Configuration** - Restrict API access
3. **Security Headers** - Added by middleware

```typescript
// middleware.ts
import { NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  // Security headers
  response.headers.set('X-Content-Type-Options', 'nosniff')
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-XSS-Protection', '1; mode=block')
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')

  return response
}
```

4. **Rate Limiting** - Prevent abuse
5. **Input Validation** - Sanitize all inputs
6. **Secrets Management** - Never hardcode secrets

## Deployment Checklist

- [ ] All environment variables set and validated
- [ ] Database migrations run in production
- [ ] Error tracking configured (Sentry, etc.)
- [ ] Logging configured
- [ ] Performance monitoring enabled
- [ ] Security headers configured
- [ ] Backups configured
- [ ] SSL/HTTPS enabled
- [ ] DNS configured
- [ ] Custom domain configured
- [ ] Email service configured (if needed)
- [ ] Webhook endpoints verified
- [ ] Rate limiting configured
- [ ] CORS properly configured
- [ ] Analytics setup
- [ ] Monitoring and alerting configured

## Related Standards

- `global/environment.md` - Environment variable management
- `backend/api.md` - API configuration
- `frontend/performance.md` - Performance optimization before deploy
