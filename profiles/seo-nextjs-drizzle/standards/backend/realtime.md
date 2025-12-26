# Real-Time Communication Standards - Pusher

This standard documents real-time WebSocket communication patterns using Pusher for the SEO Optimization application.

## I. Installation & Setup

### Install Dependencies

```bash
pnpm install pusher pusher-js
```

---

## II. Server Configuration

### Initialize Pusher

```typescript
// lib/pusher.ts
import Pusher from 'pusher'

export const pusher = new Pusher({
  appId: process.env.PUSHER_APP_ID!,
  key: process.env.PUSHER_KEY!,
  secret: process.env.PUSHER_SECRET!,
  cluster: process.env.PUSHER_CLUSTER!,
  useTLS: true,
})
```

### Environment Variables

```bash
PUSHER_APP_ID=
PUSHER_KEY=
PUSHER_SECRET=
PUSHER_CLUSTER=

# Public (for client)
NEXT_PUBLIC_PUSHER_KEY=
NEXT_PUBLIC_PUSHER_CLUSTER=
```

### Pusher Setup

1. Create account at [pusher.com](https://pusher.com)
2. Create new Channels app
3. Copy credentials to environment variables

---

## III. Server-Side Event Triggering

### Basic Event Trigger

```typescript
// app/api/projects/[id]/analyze/route.ts
import { pusher } from '@/lib/pusher'
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
    // Perform analysis...
    const analysis = await analyzePageData(params.id)

    // Notify connected clients
    await pusher.trigger(`page-${params.id}`, 'analysis-complete', {
      pageId: params.id,
      score: analysis.score,
      recommendations: analysis.recommendations.length,
      completedAt: new Date().toISOString(),
    })

    return NextResponse.json(analysis)
  } catch (error) {
    return NextResponse.json(
      { error: 'Analysis failed' },
      { status: 500 }
    )
  }
}
```

### Batch Event Triggering

```typescript
// Trigger events for multiple users
async function notifyBatchScanProgress(projectId: string, progress: number) {
  // Trigger event on shared channel
  await pusher.trigger(`project-${projectId}`, 'scan-progress', {
    progress,
    status: progress === 100 ? 'complete' : 'in-progress',
    updatedAt: new Date().toISOString(),
  })
}
```

### Private Channels for User Data

```typescript
// Notify specific user
async function notifyUser(userId: string, notification: any) {
  await pusher.trigger(
    `private-user-${userId}`, // Private channel
    'notification-received',
    {
      id: crypto.randomUUID(),
      ...notification,
      timestamp: new Date().toISOString(),
    }
  )
}
```

---

## IV. Client-Side Subscription

### Basic Subscription Hook

```typescript
// hooks/use-realtime-analysis.ts
'use client'

import { useEffect, useState } from 'react'
import Pusher from 'pusher-js'

export function useRealtimeAnalysis(pageId: string) {
  const [status, setStatus] = useState<'idle' | 'analyzing' | 'complete'>('idle')
  const [analysis, setAnalysis] = useState<any>(null)

  useEffect(() => {
    // Initialize Pusher client
    const pusher = new Pusher(process.env.NEXT_PUBLIC_PUSHER_KEY!, {
      cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
    })

    // Subscribe to channel
    const channel = pusher.subscribe(`page-${pageId}`)

    // Bind to event
    channel.bind('analysis-complete', (data: any) => {
      setStatus('complete')
      setAnalysis(data)
    })

    // Cleanup
    return () => {
      channel.unbind('analysis-complete')
      pusher.unsubscribe(`page-${pageId}`)
      pusher.disconnect()
    }
  }, [pageId])

  return { status, analysis }
}
```

### Using the Hook

```typescript
// app/components/analysis-viewer.tsx
'use client'

import { useRealtimeAnalysis } from '@/hooks/use-realtime-analysis'

export function AnalysisViewer({ pageId }: { pageId: string }) {
  const { status, analysis } = useRealtimeAnalysis(pageId)

  if (status === 'idle') {
    return <div>Waiting for analysis...</div>
  }

  if (status === 'analyzing') {
    return <div className="animate-pulse">Analyzing...</div>
  }

  return (
    <div>
      <h2>Analysis Results</h2>
      <p>Score: {analysis.score}</p>
      <p>Recommendations: {analysis.recommendations}</p>
    </div>
  )
}
```

---

## V. Advanced Patterns

### Multiple Event Listeners

```typescript
'use client'

import { useEffect } from 'react'
import Pusher from 'pusher-js'

export function useScanProgress(projectId: string) {
  useEffect(() => {
    const pusher = new Pusher(process.env.NEXT_PUBLIC_PUSHER_KEY!, {
      cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
    })

    const channel = pusher.subscribe(`project-${projectId}`)

    // Multiple event handlers
    channel.bind('scan-started', (data) => {
      console.log('Scan started:', data)
    })

    channel.bind('scan-progress', (data) => {
      console.log(`Scan progress: ${data.progress}%`)
    })

    channel.bind('scan-complete', (data) => {
      console.log('Scan complete:', data)
    })

    // Bind all events
    channel.bind_global((event, data) => {
      console.log(`Event: ${event}`, data)
    })

    return () => {
      channel.unbind_all()
      pusher.unsubscribe(`project-${projectId}`)
      pusher.disconnect()
    }
  }, [projectId])
}
```

### Private Channel Authentication

```typescript
// lib/pusher-auth.ts
import { pusher } from './pusher'
import { auth } from './auth'
import { headers } from 'next/headers'

export async function authorizePusherChannel(
  socketId: string,
  channel: string
) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    throw new Error('Unauthorized')
  }

  // Validate user can access channel
  if (channel.startsWith('private-user-')) {
    const userId = channel.replace('private-user-', '')
    if (userId !== session.user.id) {
      throw new Error('Unauthorized channel access')
    }
  }

  return pusher.authorizeChannel(socketId, channel)
}
```

### Auth Endpoint

```typescript
// app/api/pusher/auth/route.ts
import { authorizePusherChannel } from '@/lib/pusher-auth'

export async function POST(request: Request) {
  const body = await request.text()
  const params = new URLSearchParams(body)

  const socketId = params.get('socket_id')
  const channel = params.get('channel_name')

  if (!socketId || !channel) {
    return new Response('Invalid request', { status: 400 })
  }

  try {
    const auth = await authorizePusherChannel(socketId, channel)
    return new Response(JSON.stringify(auth))
  } catch (error) {
    return new Response('Unauthorized', { status: 403 })
  }
}
```

### Client Private Channel

```typescript
'use client'

import { useEffect } from 'react'
import Pusher from 'pusher-js'
import { useSession } from '@/lib/auth-client'

export function usePrivateUserChannel() {
  const { data: session } = useSession()

  useEffect(() => {
    if (!session) return

    const pusher = new Pusher(process.env.NEXT_PUBLIC_PUSHER_KEY!, {
      cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
      authEndpoint: '/api/pusher/auth',
      auth: {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      },
    })

    const channel = pusher.subscribe(`private-user-${session.user.id}`)

    channel.bind('notification-received', (data) => {
      console.log('Notification:', data)
      // Update UI
    })

    return () => {
      channel.unbind_all()
      pusher.unsubscribe(`private-user-${session.user.id}`)
      pusher.disconnect()
    }
  }, [session])
}
```

---

## VI. Event Types

### Scan Progress Events

```typescript
// Server sends progress updates
await pusher.trigger(`project-${projectId}`, 'scan-progress', {
  progress: 25,
  status: 'scanning',
  completedPages: 5,
  totalPages: 20,
  estimatedTimeRemaining: '2 minutes',
})
```

### Analysis Complete Event

```typescript
// When AI analysis finishes
await pusher.trigger(`page-${pageId}`, 'analysis-complete', {
  pageId,
  score: 82,
  recommendations: [
    { title: 'Add meta description', priority: 'high' },
    { title: 'Optimize images', priority: 'medium' },
  ],
  completedAt: new Date().toISOString(),
})
```

### Notification Events

```typescript
// Real-time notifications
await pusher.trigger(`private-user-${userId}`, 'notification-received', {
  id: crypto.randomUUID(),
  type: 'success',
  title: 'Scan Complete',
  message: 'Your page scan has finished',
  timestamp: new Date().toISOString(),
})
```

### Collaboration Events

```typescript
// Multi-user workspace updates
await pusher.trigger(`project-${projectId}`, 'collaboration-update', {
  action: 'user-joined',
  userId: session.user.id,
  userName: session.user.name,
  usersOnline: 3,
})
```

---

## VII. Error Handling

### Connection Errors

```typescript
'use client'

import { useEffect, useState } from 'react'
import Pusher from 'pusher-js'

export function usePusherWithErrorHandling(channelName: string) {
  const [isConnected, setIsConnected] = useState(false)

  useEffect(() => {
    const pusher = new Pusher(process.env.NEXT_PUBLIC_PUSHER_KEY!, {
      cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
    })

    // Connection events
    pusher.connection.bind('connected', () => {
      setIsConnected(true)
    })

    pusher.connection.bind('disconnected', () => {
      setIsConnected(false)
    })

    pusher.connection.bind('error', (error: any) => {
      console.error('Pusher error:', error)
    })

    const channel = pusher.subscribe(channelName)

    channel.bind('pusher:subscription_error', (error: any) => {
      console.error('Subscription error:', error)
    })

    return () => {
      pusher.unsubscribe(channelName)
      pusher.disconnect()
    }
  }, [channelName])

  return { isConnected }
}
```

### Retry Logic

```typescript
'use client'

import Pusher from 'pusher-js'

export function createPusherWithRetry() {
  return new Pusher(process.env.NEXT_PUBLIC_PUSHER_KEY!, {
    cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
    enableStats: false,
    activityTimeout: 30000, // 30 seconds
    pongTimeout: 10000, // 10 seconds
  })
}
```

---

## VIII. Performance & Limits

### Rate Limiting

```typescript
// Don't trigger too frequently
async function throttledTrigger(
  channel: string,
  event: string,
  data: any,
  minInterval: number = 1000
) {
  // Only trigger if enough time has passed
  const lastTrigger = globalThis._lastTrigger?.[`${channel}:${event}`] || 0
  const now = Date.now()

  if (now - lastTrigger >= minInterval) {
    await pusher.trigger(channel, event, data)
    globalThis._lastTrigger = globalThis._lastTrigger || {}
    globalThis._lastTrigger[`${channel}:${event}`] = now
  }
}
```

### Payload Size

```typescript
// Pusher limits payloads to 10KB
// Keep messages small

// Good: Minimal data
await pusher.trigger('channel', 'update', {
  id: '123',
  status: 'complete',
})

// Bad: Too much data
await pusher.trigger('channel', 'update', {
  id: '123',
  status: 'complete',
  entireUserData: veryLargeObject, // Don't do this
})
```

---

## IX. Best Practices

1. **Use private channels for user data** - `private-user-{id}`
2. **Unsubscribe on component unmount** - Prevent memory leaks
3. **Handle connection errors** - Show fallback UI
4. **Keep payloads small** - Stay under 10KB limit
5. **Rate limit triggers** - Don't spam events
6. **Validate on server** - Auth channel access
7. **Use appropriate channels** - Public vs private
8. **Monitor connection status** - Reconnection UI
9. **Implement fallbacks** - Polling for unreliable connections
10. **Test locally** - Pusher sandbox for testing

---

## X. Debugging

### Enable Debug Mode

```typescript
// Enable Pusher debugging
Pusher.logToConsole = true

const pusher = new Pusher(process.env.NEXT_PUBLIC_PUSHER_KEY!, {
  cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
})
```

### Monitor Events

```typescript
'use client'

export function useEventMonitor(channelName: string) {
  useEffect(() => {
    const pusher = new Pusher(process.env.NEXT_PUBLIC_PUSHER_KEY!, {
      cluster: process.env.NEXT_PUBLIC_PUSHER_CLUSTER!,
    })

    const channel = pusher.subscribe(channelName)

    // Log all events
    channel.bind_global((event, data) => {
      console.log(`[${channelName}] ${event}:`, data)
    })

    return () => {
      pusher.unsubscribe(channelName)
    }
  }, [channelName])
}
```

---

## Related Standards

- {{standards/backend/api}} - Triggering events from routes
- {{standards/backend/background-jobs}} - Events from background jobs
- {{standards/frontend/forms-actions}} - Real-time form updates
- {{standards/global/error-handling}} - Error handling in real-time
