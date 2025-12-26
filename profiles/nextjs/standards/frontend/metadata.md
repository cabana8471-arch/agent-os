# Next.js Metadata & SEO

## Static Metadata Export

Define metadata for a page or layout:

### In Pages

```typescript
// app/page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Home | My App',
  description: 'Welcome to my awesome app',
}

export default function HomePage() {
  return <h1>Home</h1>
}
```

### In Layouts

Metadata in layouts is inherited by all nested pages:

```typescript
// app/blog/layout.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: {
    template: '%s | My Blog',
    default: 'Blog',
  },
  description: 'Read my latest blog posts',
}

export default function BlogLayout({ children }: { children: React.ReactNode }) {
  return <>{children}</>
}

// app/blog/first-post/page.tsx
export const metadata: Metadata = {
  title: 'My First Post', // Becomes "My First Post | My Blog"
}

export default function PostPage() {
  return <article>...</article>
}
```

## Dynamic Metadata with generateMetadata

Generate metadata based on dynamic data:

### Basic Example

```typescript
// app/posts/[id]/page.tsx
import type { Metadata } from 'next'

interface PostPageProps {
  params: { id: string }
}

export async function generateMetadata({
  params,
}: PostPageProps): Promise<Metadata> {
  const post = await fetchPost(params.id)

  if (!post) {
    return {
      title: 'Post not found',
    }
  }

  return {
    title: post.title,
    description: post.excerpt,
    authors: [{ name: post.author }],
    keywords: post.tags,
  }
}

export default async function PostPage({ params }: PostPageProps) {
  const post = await fetchPost(params.id)
  return <Article post={post} />
}
```

### Product Page Example

```typescript
// app/products/[id]/page.tsx
import type { Metadata } from 'next'

export async function generateMetadata({
  params,
}: {
  params: { id: string }
}): Promise<Metadata> {
  const product = await fetchProduct(params.id)

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      title: product.name,
      description: product.description,
      images: [
        {
          url: product.imageUrl,
          width: 1200,
          height: 630,
          alt: product.name,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: product.name,
      description: product.description,
      images: [product.imageUrl],
    },
  }
}

export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await fetchProduct(params.id)
  return <Product product={product} />
}
```

## Open Graph & Social Media

### Open Graph Meta Tags

Used by Facebook, LinkedIn, and other social platforms:

```typescript
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'My Blog Post',
  description: 'An amazing blog post about Next.js',
  openGraph: {
    type: 'article',
    url: 'https://example.com/blog/my-post',
    title: 'My Blog Post',
    description: 'An amazing blog post about Next.js',
    siteName: 'My Blog',
    images: [
      {
        url: 'https://example.com/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Blog post cover',
      },
    ],
    authors: ['https://twitter.com/myhandle'],
    publishedTime: '2024-01-15T00:00:00Z',
    tags: ['nextjs', 'web development', 'react'],
  },
}
```

### Twitter Card Meta Tags

Used when sharing on Twitter/X:

```typescript
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'My Awesome Project',
  twitter: {
    card: 'summary_large_image', // or 'summary'
    title: 'My Awesome Project',
    description: 'Check out this incredible project',
    images: ['https://example.com/twitter-image.jpg'],
    creator: '@myhandle',
    site: '@mysite',
  },
}
```

## Structured Data (JSON-LD)

Add structured data for search engines:

```typescript
// app/article/[id]/page.tsx
import type { Metadata } from 'next'

export async function generateMetadata({
  params,
}: {
  params: { id: string }
}): Promise<Metadata> {
  const article = await fetchArticle(params.id)

  return {
    title: article.title,
    description: article.excerpt,
    // Structured data will be injected as script
  }
}

export default async function ArticlePage({
  params,
}: {
  params: { id: string }
}) {
  const article = await fetchArticle(params.id)

  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'NewsArticle',
    headline: article.title,
    description: article.excerpt,
    image: article.imageUrl,
    author: {
      '@type': 'Person',
      name: article.author,
    },
    datePublished: article.publishedAt,
    dateModified: article.updatedAt,
  }

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <article>{/* ... */}</article>
    </>
  )
}
```

### Organization Schema

```typescript
// app/layout.tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  const organizationSchema = {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'My Company',
    url: 'https://example.com',
    logo: 'https://example.com/logo.png',
    sameAs: [
      'https://twitter.com/mycompany',
      'https://linkedin.com/company/mycompany',
    ],
    contactPoint: {
      '@type': 'ContactPoint',
      contactType: 'Customer Support',
      telephone: '+1-555-123-4567',
      email: 'support@example.com',
    },
  }

  return (
    <html>
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationSchema) }}
        />
      </head>
      <body>{children}</body>
    </html>
  )
}
```

## Canonical URLs

Prevent duplicate content issues:

```typescript
import type { Metadata } from 'next'

export const metadata: Metadata = {
  metadataBase: new URL('https://example.com'),
  alternates: {
    canonical: '/blog/my-post', // Becomes https://example.com/blog/my-post
  },
}
```

## Robots & Crawlers

### Robots.txt

```typescript
// app/robots.ts
import type { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: '/admin',
      },
      {
        userAgent: 'Googlebot',
        allow: '/',
      },
    ],
    sitemap: 'https://example.com/sitemap.xml',
  }
}
```

### Sitemap

```typescript
// app/sitemap.ts
import type { MetadataRoute } from 'next'

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: 'https://example.com',
      lastModified: new Date(),
      changeFrequency: 'yearly',
      priority: 1,
    },
    {
      url: 'https://example.com/about',
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.8,
    },
    {
      url: 'https://example.com/blog',
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.9,
    },
  ]
}
```

### Favicon & App Icons

```typescript
// app/layout.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  icons: {
    icon: '/favicon.ico',
    shortcut: '/favicon-16x16.png',
    apple: '/apple-touch-icon.png',
  },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <head>
        {/* Metadata icons are auto-injected */}
      </head>
      <body>{children}</body>
    </html>
  )
}
```

## Viewport Configuration

```typescript
// app/layout.tsx
import type { Metadata, Viewport } from 'next'

export const metadata: Metadata = {
  title: 'My App',
}

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  colorScheme: 'dark',
  themeColor: '#000000',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html>{children}</html>
}
```

## Verification Tags

Add verification for search console and other services:

```typescript
import type { Metadata } from 'next'

export const metadata: Metadata = {
  verification: {
    google: 'google-site-verification-string',
    yandex: 'yandex-verification-string',
  },
}
```

## Complete Metadata Example

```typescript
// app/blog/[slug]/page.tsx
import type { Metadata } from 'next'

interface BlogPostProps {
  params: { slug: string }
}

export async function generateMetadata({
  params,
}: BlogPostProps): Promise<Metadata> {
  const post = await getPost(params.slug)

  if (!post) {
    return {
      title: '404 - Post not found',
    }
  }

  const url = `${process.env.SITE_URL}/blog/${post.slug}`

  return {
    metadataBase: new URL(process.env.SITE_URL || 'https://example.com'),
    title: post.title,
    description: post.excerpt,
    authors: [{ name: post.author, url: post.authorUrl }],
    keywords: post.tags,
    alternates: {
      canonical: `/blog/${post.slug}`,
    },
    openGraph: {
      type: 'article',
      url,
      title: post.title,
      description: post.excerpt,
      siteName: 'My Blog',
      images: [
        {
          url: post.imageUrl,
          width: 1200,
          height: 630,
          alt: post.title,
        },
      ],
      authors: [post.author],
      publishedTime: post.publishedAt.toISOString(),
      tags: post.tags,
    },
    twitter: {
      card: 'summary_large_image',
      title: post.title,
      description: post.excerpt,
      images: [post.imageUrl],
      creator: post.twitterHandle,
    },
  }
}

export default async function BlogPost({ params }: BlogPostProps) {
  const post = await getPost(params.slug)

  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'BlogPosting',
    headline: post.title,
    description: post.excerpt,
    image: post.imageUrl,
    author: {
      '@type': 'Person',
      name: post.author,
      url: post.authorUrl,
    },
    datePublished: post.publishedAt.toISOString(),
    dateModified: post.updatedAt.toISOString(),
  }

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <article>{/* Post content */}</article>
    </>
  )
}
```

## SEO Best Practices

1. **Unique titles** - Each page should have unique, descriptive titles
2. **Meta descriptions** - Keep under 160 characters, include keywords
3. **Header structure** - Use H1, H2, H3 properly
4. **Internal links** - Link to related content
5. **Canonical URLs** - Prevent duplicate content issues
6. **Mobile-friendly** - Ensure responsive design
7. **Page speed** - Optimize images and bundle size
8. **Structured data** - Add JSON-LD for rich snippets
9. **Sitemap** - Help search engines discover pages
10. **robots.txt** - Control crawler access

## Related Standards

- {{standards/frontend/image-optimization}} - Image SEO
- {{standards/frontend/performance}} - Page speed optimization
- {{standards/global/project-structure}} - Clean URL structure
