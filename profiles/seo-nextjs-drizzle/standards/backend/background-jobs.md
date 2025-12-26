# Background Jobs Standards - Inngest

This standard documents serverless background job processing patterns using Inngest for the SEO Optimization application.

## I. Installation & Setup

### Install Dependencies

```bash
pnpm install inngest
```

### File Structure

```
src/inngest/
├── client.ts                    # Inngest client
└── functions/
    ├── scan-page.ts            # Page scan job
    ├── batch-scan.ts           # Batch scanning
    ├── analyze-page.ts         # AI analysis job
    └── send-notification.ts    # Notification sending
```

---

## II. Inngest Client

### Initialize Client

```typescript
// src/inngest/client.ts
import { Inngest } from 'inngest'

export const inngest = new Inngest({
  id: 'seo-optimization-app',
  eventKey: process.env.INNGEST_EVENT_KEY!,
})
```

### Environment Variables

```bash
INNGEST_EVENT_KEY=
INNGEST_SIGNING_KEY=
```

---

## III. Function Definitions

### Basic Job - Single Step

```typescript
// src/inngest/functions/send-notification.ts
import { inngest } from '../client'
import { pusher } from '@/lib/pusher'
import { db } from '@/db'
import { notification } from '@/db/schema'

export const sendNotification = inngest.createFunction(
  { id: 'send-notification', name: 'Send Notification' },
  { event: 'notification/send' },
  async ({ event }) => {
    const { userId, title, message, type } = event.data

    // Save notification to database
    const [notif] = await db.insert(notification).values({
      id: crypto.randomUUID(),
      userId,
      title,
      message,
      type: type as any,
      read: false,
    }).returning()

    // Push real-time notification
    await pusher.trigger(`user-${userId}`, 'notification-received', {
      notification: notif,
    })

    return { success: true, notificationId: notif.id }
  }
)
```

### Multi-Step Job

```typescript
// src/inngest/functions/scan-page.ts
import { inngest } from '../client'
import { scanUrl } from '@/lib/scanner'
import { db } from '@/db'
import { scannedPage } from '@/db/schema'
import { eq } from 'drizzle-orm'

export const scanPage = inngest.createFunction(
  { id: 'scan-page', name: 'Scan Single Page' },
  { event: 'page/scan.requested' },
  async ({ event, step }) => {
    const { pageId, url, userId } = event.data

    // Step 1: Fetch and parse
    const scanData = await step.run('fetch-and-parse', async () => {
      return await scanUrl(url)
    })

    // Step 2: Save to database
    const updated = await step.run('save-scan-data', async () => {
      const [page] = await db
        .update(scannedPage)
        .set({
          status: 'completed',
          htmlLength: scanData.htmlLength,
          headings: scanData.headings,
          images: scanData.images,
          links: scanData.links,
          metaDescription: scanData.metaDescription,
          metaKeywords: scanData.metaKeywords,
          scannedAt: new Date(),
        })
        .where(eq(scannedPage.id, pageId))
        .returning()

      return page
    })

    // Step 3: Trigger analysis
    await step.sendEvent('trigger-analysis', {
      name: 'page/analyze.requested',
      data: {
        pageId,
        url,
        userId,
        scanData,
      },
    })

    // Step 4: Notify user
    await step.sendEvent('notify-scan-complete', {
      name: 'notification/send',
      data: {
        userId,
        title: 'Scan Complete',
        message: `Page scan for ${url} has completed`,
        type: 'success',
      },
    })

    return { success: true, pageId, scanData: updated }
  }
)
```

### Batch Job with Concurrency

```typescript
// src/inngest/functions/batch-scan.ts
import { inngest } from '../client'
import { db } from '@/db'
import { project } from '@/db/schema'
import { eq } from 'drizzle-orm'

export const batchScan = inngest.createFunction(
  { id: 'batch-scan', name: 'Batch Scan Project Pages' },
  { event: 'project/batch.scan' },
  async ({ event, step }) => {
    const { projectId, userId, urls } = event.data

    // Create page records
    const pages = await step.run('create-page-records', async () => {
      const records = urls.map(url => ({
        id: crypto.randomUUID(),
        projectId,
        url,
        status: 'pending' as const,
      }))

      const created = await db.insert(scannedPage).values(records).returning()
      return created
    })

    // Trigger individual scans in parallel
    const scanEvents = pages.map(page => ({
      name: 'page/scan.requested',
      data: {
        pageId: page.id,
        url: page.url,
        userId,
      },
    }))

    await step.sendEvent('trigger-scans', scanEvents)

    // Track batch progress
    await step.sendEvent('update-batch-status', {
      name: 'batch/progress.updated',
      data: {
        projectId,
        userId,
        totalPages: pages.length,
        status: 'in-progress',
      },
    })

    return { success: true, pageCount: pages.length }
  }
)
```

### AI Analysis Job

```typescript
// src/inngest/functions/analyze-page.ts
import { inngest } from '../client'
import { streamText } from 'ai'
import { openrouter } from '@/lib/ai'
import { db } from '@/db'
import { recommendation, scannedPage } from '@/db/schema'
import { eq } from 'drizzle-orm'
import { pusher } from '@/lib/pusher'

export const analyzePage = inngest.createFunction(
  { id: 'analyze-page', name: 'Analyze Page for SEO' },
  { event: 'page/analyze.requested' },
  async ({ event, step }) => {
    const { pageId, url, userId, scanData } = event.data

    // Fetch prompt template
    const template = await step.run('fetch-prompt', async () => {
      // Get template from database
      const [tmpl] = await db.query.promptTemplate.findMany({
        where: (fields) => fields.active,
        limit: 1,
      })
      return tmpl
    })

    // Generate AI analysis
    const analysis = await step.run('run-analysis', async () => {
      const prompt = interpolatePrompt(template.content, {
        url,
        ...scanData,
      })

      const { text } = await streamText({
        model: openrouter('openai/gpt-5-mini'),
        messages: [
          {
            role: 'system',
            content: 'You are an SEO expert. Analyze the page and provide specific, actionable recommendations.',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
      })

      return text
    })

    // Save recommendations
    const recommendations = await step.run('save-recommendations', async () => {
      const parsed = parseAnalysisResults(analysis)

      const saved = await Promise.all(
        parsed.map(rec =>
          db.insert(recommendation).values({
            id: crypto.randomUUID(),
            pageId,
            title: rec.title,
            description: rec.description,
            priority: rec.priority,
            category: rec.category,
          })
        )
      )

      return saved
    })

    // Notify user via Pusher
    await step.sendEvent('notify-analysis-complete', {
      name: 'notification/send',
      data: {
        userId,
        title: 'Analysis Complete',
        message: `AI analysis for ${url} generated ${recommendations.length} recommendations`,
        type: 'success',
      },
    })

    // Broadcast to connected clients
    await step.run('broadcast-results', async () => {
      await pusher.trigger(`page-${pageId}`, 'analysis-complete', {
        pageId,
        recommendationCount: recommendations.length,
        status: 'complete',
      })
    })

    return {
      success: true,
      pageId,
      recommendationCount: recommendations.length,
    }
  }
)
```

---

## IV. Event Triggering

### From Route Handler

```typescript
// app/api/projects/[id]/scan/route.ts
import { inngest } from '@/inngest/client'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    // Trigger scan job
    await inngest.send({
      name: 'page/scan.requested',
      data: {
        pageId: crypto.randomUUID(),
        url: 'https://example.com',
        userId: session.user.id,
      },
    })

    return NextResponse.json({ message: 'Scan queued' })
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to queue scan' },
      { status: 500 }
    )
  }
}
```

### From Server Action

```typescript
// app/actions.ts
'use server'

import { inngest } from '@/inngest/client'
import { auth } from '@/lib/auth'
import { headers } from 'next/headers'

export async function startProjectScan(projectId: string, urls: string[]) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return { error: 'Unauthorized' }
  }

  try {
    await inngest.send({
      name: 'project/batch.scan',
      data: {
        projectId,
        userId: session.user.id,
        urls,
      },
    })

    return { success: true }
  } catch (error) {
    return { error: 'Failed to start scan' }
  }
}
```

### Event Data Types

```typescript
// Define event types for type safety
type EventDefs = {
  'page/scan.requested': {
    data: {
      pageId: string
      url: string
      userId: string
    }
  }
  'page/analyze.requested': {
    data: {
      pageId: string
      url: string
      userId: string
      scanData: any
    }
  }
  'project/batch.scan': {
    data: {
      projectId: string
      userId: string
      urls: string[]
    }
  }
  'notification/send': {
    data: {
      userId: string
      title: string
      message: string
      type: 'info' | 'success' | 'warning' | 'error'
    }
  }
}

export const inngest = new Inngest<EventDefs>({
  id: 'seo-optimization-app',
  eventKey: process.env.INNGEST_EVENT_KEY!,
})
```

---

## V. API Route (Webhook Handler)

### Inngest Webhook Route

```typescript
// app/api/inngest/route.ts
import { serve } from 'inngest/next'
import { inngest } from '@/inngest/client'
import { scanPage } from '@/inngest/functions/scan-page'
import { batchScan } from '@/inngest/functions/batch-scan'
import { analyzePage } from '@/inngest/functions/analyze-page'
import { sendNotification } from '@/inngest/functions/send-notification'

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [scanPage, batchScan, analyzePage, sendNotification],
})
```

### Serve Options

```typescript
export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [...allFunctions],

  // Development/debugging
  ...(process.env.NODE_ENV === 'development' && {
    logLevel: 'debug',
  }),
})
```

---

## VI. Job Patterns

### Retry Logic

```typescript
export const scanPageWithRetry = inngest.createFunction(
  {
    id: 'scan-page-retry',
    retries: 3, // Retry up to 3 times
  },
  { event: 'page/scan.requested' },
  async ({ event, step }) => {
    try {
      return await step.run('fetch-url', async () => {
        return await scanUrl(event.data.url)
      })
    } catch (error) {
      // Retries happen automatically
      throw error
    }
  }
)
```

### Timeouts

```typescript
export const longRunningJob = inngest.createFunction(
  {
    id: 'long-running',
    timeout: '1 hour', // Custom timeout
  },
  { event: 'long/task' },
  async ({ event, step }) => {
    // Must complete within 1 hour
    return await step.run('slow-operation', async () => {
      // Long-running work
    })
  }
)
```

### Throttling

```typescript
export const throttledJob = inngest.createFunction(
  {
    id: 'throttled',
    throttle: {
      limit: 10, // Max 10 concurrent executions
      period: '1 minute',
    },
  },
  { event: 'page/scan.requested' },
  async ({ event, step }) => {
    // Only 10 scans run concurrently
  }
)
```

### Error Handling

```typescript
export const jobWithErrorHandling = inngest.createFunction(
  { id: 'error-handling' },
  { event: 'task/requested' },
  async ({ event, step }) => {
    try {
      return await step.run('main-task', async () => {
        // Task work
      })
    } catch (error) {
      // Handle and log error
      await step.run('log-error', async () => {
        console.error('Task failed:', error)
        // Send error notification
      })

      throw error // Re-throw to trigger retry logic
    }
  }
)
```

---

## VII. Monitoring & Debugging

### Inngest Dashboard

```bash
# Access Inngest console at:
# https://app.inngest.com
```

### Local Development

```bash
# Run dev server to see job executions
pnpm run dev

# Jobs execute locally for development
```

### Job Logs

```typescript
export const jobWithLogging = inngest.createFunction(
  { id: 'with-logging' },
  { event: 'page/scan.requested' },
  async ({ event, step }) => {
    await step.run('log-start', async () => {
      console.log(`Scanning: ${event.data.url}`)
    })

    const result = await step.run('main-task', async () => {
      // Task work
      return { success: true }
    })

    await step.run('log-result', async () => {
      console.log('Scan completed:', result)
    })

    return result
  }
)
```

---

## VIII. Best Practices

1. **Use steps for atomic operations** - Each step is retried independently
2. **Chain events for dependencies** - Use `step.sendEvent()` for multi-stage workflows
3. **Handle failures gracefully** - Implement retry logic and error notifications
4. **Set appropriate timeouts** - Long-running tasks need longer timeouts
5. **Monitor job execution** - Use Inngest dashboard for visibility
6. **Test locally first** - Run jobs in development before production
7. **Log important events** - Track progress and debug failures
8. **Use event types** - TypeScript types for event data
9. **Implement rate limiting** - Prevent resource exhaustion
10. **Plan for scale** - Inngest auto-scales, but design efficient jobs

---

## IX. Environment Variables

```bash
# Inngest
INNGEST_EVENT_KEY=
INNGEST_SIGNING_KEY=

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

---

## Related Standards

- {{standards/backend/api}} - Triggering jobs from route handlers
- {{standards/backend/realtime}} - Real-time updates via Pusher
- {{standards/backend/ai-integration}} - AI analysis in jobs
- {{standards/global/error-handling}} - Error handling in jobs
