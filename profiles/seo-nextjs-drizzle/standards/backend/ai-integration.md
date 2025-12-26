# AI Integration Standards - OpenRouter + Vercel AI SDK

This standard documents AI integration patterns using OpenRouter API with Vercel AI SDK for the SEO Optimization application.

## I. Installation & Setup

### Install Dependencies

```bash
pnpm install ai @ai-sdk/react @openrouter/ai-sdk-provider
```

### Environment Variables

```bash
OPENROUTER_API_KEY=
```

---

## II. AI Client Configuration

### Initialize OpenRouter Client

```typescript
// lib/ai.ts
import { createOpenRouter } from '@openrouter/ai-sdk-provider'

export const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY!,
})
```

### Available Models

```typescript
// Common models on OpenRouter
export const AI_MODELS = {
  // Fast, cost-effective (default)
  fast: 'openai/gpt-5-mini',

  // Balanced
  balanced: 'openai/gpt-4-turbo',

  // Advanced reasoning
  advanced: 'anthropic/claude-3.5-sonnet',

  // Code-specific
  code: 'openai/gpt-4',
} as const
```

---

## III. Streaming Responses from Server Actions

### Basic Streaming

```typescript
// app/actions.ts
'use server'

import { streamText } from 'ai'
import { openrouter } from '@/lib/ai'
import { createStreamableValue } from 'ai/rsc'

export async function analyzeSEO(pageData: string) {
  // Create streamable value for RSC
  const stream = createStreamableValue('')

  ;(async () => {
    const { textStream } = await streamText({
      model: openrouter('openai/gpt-5-mini'),
      messages: [
        {
          role: 'system',
          content: 'You are an SEO expert. Analyze the page and provide specific, actionable recommendations.',
        },
        {
          role: 'user',
          content: `Analyze this page data:\n\n${pageData}`,
        },
      ],
    })

    // Stream the response as it's generated
    for await (const delta of textStream) {
      stream.update(delta)
    }

    stream.done()
  })()

  return { output: stream.value }
}
```

### Using Streamable in Client

```typescript
// app/components/seo-analyzer.tsx
'use client'

import { useState } from 'react'
import { readStreamableValue } from 'ai/rsc'
import { analyzeSEO } from '@/app/actions'

export function SEOAnalyzer({ pageData }: { pageData: string }) {
  const [analysis, setAnalysis] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleAnalyze() {
    setLoading(true)
    setAnalysis('')

    try {
      const { output } = await analyzeSEO(pageData)

      // Read the stream
      for await (const delta of readStreamableValue(output)) {
        setAnalysis((prev) => prev + (delta || ''))
      }
    } catch (error) {
      setAnalysis('Analysis failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      <button onClick={handleAnalyze} disabled={loading}>
        {loading ? 'Analyzing...' : 'Analyze'}
      </button>
      <pre className="mt-4 p-4 bg-gray-100 rounded">
        {analysis || 'Click Analyze to start...'}
      </pre>
    </div>
  )
}
```

---

## IV. Streaming from Route Handlers

### API Streaming Response

```typescript
// app/api/copilot/chat/route.ts
import { streamText } from 'ai'
import { openrouter } from '@/lib/ai'
import { auth } from '@/lib/auth'

export async function POST(request: Request) {
  const session = await auth.api.getSession({
    headers: request.headers,
  })

  if (!session) {
    return new Response('Unauthorized', { status: 401 })
  }

  try {
    const { messages } = await request.json()

    const result = await streamText({
      model: openrouter('openai/gpt-5-mini'),
      system: `You are a helpful SEO optimization assistant. You help users optimize their websites for search engines.`,
      messages,
    })

    // Return streaming response
    return result.toDataStreamResponse()
  } catch (error) {
    console.error('Chat failed:', error)
    return new Response('Chat failed', { status: 500 })
  }
}
```

### Client-Side Chat

```typescript
// app/components/copilot-chat.tsx
'use client'

import { useChat } from '@ai-sdk/react'

export function CopilotChat() {
  const { messages, input, handleInputChange, handleSubmit } = useChat({
    api: '/api/copilot/chat',
  })

  return (
    <div className="flex flex-col gap-4">
      <div className="flex-1 overflow-auto space-y-4">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`p-4 rounded ${
              msg.role === 'user' ? 'bg-blue-100' : 'bg-gray-100'
            }`}
          >
            {msg.content}
          </div>
        ))}
      </div>

      <form onSubmit={handleSubmit} className="flex gap-2">
        <input
          value={input}
          onChange={handleInputChange}
          placeholder="Ask about SEO..."
          className="flex-1 border p-2 rounded"
        />
        <button type="submit" className="bg-blue-500 text-white px-4 rounded">
          Send
        </button>
      </form>
    </div>
  )
}
```

---

## V. Structured Output with Zod

### Define Schema

```typescript
import { z } from 'zod'
import { generateObject } from 'ai'
import { openrouter } from '@/lib/ai'

const recommendationSchema = z.object({
  recommendations: z.array(
    z.object({
      title: z.string(),
      description: z.string(),
      priority: z.enum(['low', 'medium', 'high', 'critical']),
      category: z.string(),
      estimatedImpact: z.number().min(0).max(100),
    })
  ),
})

type Recommendation = z.infer<typeof recommendationSchema>
```

### Generate Structured Output

```typescript
export async function analyzePageStructured(pageData: string) {
  const { object } = await generateObject({
    model: openrouter('openai/gpt-5-mini'),
    schema: recommendationSchema,
    messages: [
      {
        role: 'system',
        content: 'You are an SEO expert. Analyze the page and provide structured recommendations.',
      },
      {
        role: 'user',
        content: `Analyze this page:\n\n${pageData}`,
      },
    ],
  })

  return object
}
```

---

## VI. Prompt Template System

### Database Schema

```typescript
// src/db/schema/prompt.ts
import { pgTable, text, varchar, boolean, jsonb } from 'drizzle-orm/pg-core'

export const promptTemplate = pgTable('prompt_template', {
  id: text('id').primaryKey(),
  name: varchar('name').notNull(),
  category: varchar('category').notNull(), // 'analysis', 'optimization', 'content'
  content: text('content').notNull(), // Template with {{variables}}
  variables: jsonb('variables'), // ['url', 'title', 'description']
  active: boolean('active').default(true),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
})

export type PromptTemplate = InferSelectModel<typeof promptTemplate>
```

### Template Interpolation

```typescript
// lib/prompts.ts
export function interpolatePrompt(
  template: string,
  variables: Record<string, any>
): string {
  let result = template

  for (const [key, value] of Object.entries(variables)) {
    const placeholder = `{{${key}}}`
    result = result.replace(new RegExp(placeholder, 'g'), String(value))
  }

  return result
}

// Example template:
// "Analyze this website:\nURL: {{url}}\nTitle: {{title}}\nDescription: {{metaDescription}}\n\nProvide 5 optimization recommendations."

// Usage:
const prompt = interpolatePrompt(template, {
  url: 'https://example.com',
  title: 'Example Website',
  metaDescription: 'This is an example website',
})
```

### Use in Analysis

```typescript
export async function analyzeWithTemplate(
  templateId: string,
  pageData: Record<string, any>
) {
  // Fetch template
  const template = await db.query.promptTemplate.findFirst({
    where: eq(promptTemplate.id, templateId),
  })

  if (!template) {
    throw new Error('Template not found')
  }

  // Interpolate variables
  const prompt = interpolatePrompt(template.content, pageData)

  // Generate with template
  const { text } = await streamText({
    model: openrouter('openai/gpt-5-mini'),
    messages: [
      {
        role: 'user',
        content: prompt,
      },
    ],
  })

  return text
}
```

---

## VII. Advanced Patterns

### Vision Analysis (with images)

```typescript
import { generateObject } from 'ai'

export async function analyzeScreenshot(imageBase64: string) {
  const { object } = await generateObject({
    model: openrouter('openai/gpt-4-vision'),
    schema: z.object({
      issues: z.array(
        z.object({
          description: z.string(),
          severity: z.enum(['low', 'medium', 'high']),
        })
      ),
    }),
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'image',
            image: imageBase64,
          },
          {
            type: 'text',
            text: 'Analyze this screenshot for SEO issues',
          },
        ],
      },
    ],
  })

  return object
}
```

### Multi-turn Conversation

```typescript
'use server'

import { streamText } from 'ai'
import { openrouter } from '@/lib/ai'

export async function conversationAnalysis(messages: any[]) {
  const { textStream } = await streamText({
    model: openrouter('openai/gpt-5-mini'),
    system: 'You are an SEO expert assistant. Help users optimize their websites.',
    messages,
  })

  return { stream: textStream }
}
```

### Batch Processing

```typescript
// Process multiple pages efficiently
export async function analyzeMultiplePages(pages: string[]) {
  const results = await Promise.all(
    pages.map(pageData =>
      streamText({
        model: openrouter('openai/gpt-5-mini'),
        messages: [
          {
            role: 'user',
            content: `Analyze: ${pageData}`,
          },
        ],
      })
    )
  )

  return results
}
```

---

## VIII. Error Handling

### API Error Handling

```typescript
import { generateObject } from 'ai'

export async function analyzeWithFallback(pageData: string) {
  try {
    // Try primary model
    return await generateObject({
      model: openrouter('openai/gpt-5-mini'),
      schema: recommendationSchema,
      messages: [
        {
          role: 'user',
          content: `Analyze: ${pageData}`,
        },
      ],
    })
  } catch (error) {
    console.error('Primary model failed, trying fallback:', error)

    try {
      // Fallback to alternative model
      return await generateObject({
        model: openrouter('anthropic/claude-3.5-sonnet'),
        schema: recommendationSchema,
        messages: [
          {
            role: 'user',
            content: `Analyze: ${pageData}`,
          },
        ],
      })
    } catch (fallbackError) {
      console.error('Both models failed:', fallbackError)
      throw new Error('Analysis service unavailable')
    }
  }
}
```

### Rate Limiting

```typescript
import { RateLimiter } from 'limiter'

const limiter = new RateLimiter({
  tokensPerInterval: 10,
  interval: 'minute',
})

export async function analyzeWithRateLimit(pageData: string) {
  await limiter.removeTokens(1)
  return await streamText({
    model: openrouter('openai/gpt-5-mini'),
    messages: [
      {
        role: 'user',
        content: pageData,
      },
    ],
  })
}
```

---

## IX. Cost Optimization

### Token Counting

```typescript
// Estimate costs before running
function estimateTokenCost(prompt: string, model: string): number {
  const tokenEstimate = prompt.length / 4 // Rough estimate
  const modelCosts = {
    'openai/gpt-5-mini': 0.00015, // per input token
    'openai/gpt-4': 0.03,
    'anthropic/claude-3.5-sonnet': 0.003,
  }

  const costPerToken = modelCosts[model as keyof typeof modelCosts] || 0.001
  return tokenEstimate * costPerToken
}
```

### Caching Results

```typescript
import { unstable_cache } from 'next/cache'

// Cache analysis results for 24 hours
const cachedAnalyze = unstable_cache(
  async (pageId: string) => {
    return await streamText({
      model: openrouter('openai/gpt-5-mini'),
      messages: [
        {
          role: 'user',
          content: `Analyze page ${pageId}`,
        },
      ],
    })
  },
  ['analyze'],
  { revalidate: 86400 } // 24 hours
)
```

---

## X. Best Practices

1. **Use appropriate models** - Balance cost vs quality
2. **Stream responses** - Better UX, faster perceived response
3. **Implement rate limiting** - Prevent abuse and control costs
4. **Cache results** - Avoid re-analyzing same content
5. **Handle errors gracefully** - Provide fallbacks
6. **Monitor token usage** - Track costs
7. **Use structured output** - Get parseable results
8. **Validate inputs** - Prevent injection attacks
9. **Implement timeouts** - Prevent hanging requests
10. **Log conversations** - For debugging and auditing

---

## XI. Example: Complete Analysis Flow

```typescript
// app/api/analyze/route.ts
'use server'

import { streamText } from 'ai'
import { openrouter } from '@/lib/ai'
import { db } from '@/db'
import { auth } from '@/lib/auth'
import { headers } from 'next/headers'

export async function POST(request: Request) {
  const session = await auth.api.getSession({
    headers: await headers(),
  })

  if (!session) {
    return new Response('Unauthorized', { status: 401 })
  }

  const { pageData, templateId } = await request.json()

  // Fetch template
  const template = await db.query.promptTemplate.findFirst({
    where: eq(promptTemplate.id, templateId),
  })

  if (!template) {
    return new Response('Template not found', { status: 404 })
  }

  // Interpolate prompt
  const prompt = interpolatePrompt(template.content, pageData)

  // Stream analysis
  const result = await streamText({
    model: openrouter('openai/gpt-5-mini'),
    messages: [
      {
        role: 'system',
        content: 'You are an SEO expert.',
      },
      {
        role: 'user',
        content: prompt,
      },
    ],
  })

  return result.toDataStreamResponse()
}
```

---

## Related Standards

- {{standards/backend/api}} - API routes for AI endpoints
- {{standards/backend/background-jobs}} - Async AI analysis jobs
- {{standards/backend/realtime}} - Real-time AI updates via Pusher
- {{standards/global/validation}} - Input validation before AI calls
- {{standards/global/error-handling}} - Error handling in AI flows
