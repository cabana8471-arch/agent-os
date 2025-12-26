# Image Optimization with next/image

## Overview

The `next/image` component optimizes images automatically:
- Responsive images (srcset)
- Lazy loading
- Format conversion (WebP, AVIF)
- Prevents layout shift

## Basic Usage

```typescript
import Image from 'next/image'

export function ProfilePicture() {
  return (
    <Image
      src="/profile.jpg"
      alt="My profile picture"
      width={200}
      height={200}
    />
  )
}
```

### Required Props

- **src**: Path or URL
- **alt**: Descriptive text (required for accessibility)
- **width** & **height**: Dimensions in pixels

## Static Images

Import images as modules for type safety:

```typescript
import Image from 'next/image'
import myImage from '@/public/hero.jpg'

export function Hero() {
  return (
    <Image
      src={myImage}
      alt="Hero section"
      priority // Load immediately
    />
  )
}

// Width & height automatically inferred from imported image
```

## Responsive Images

### Fill Container

```typescript
import Image from 'next/image'

export function ResponsiveImage() {
  return (
    <div style={{ position: 'relative', width: '100%', height: 'auto' }}>
      <Image
        src="/landscape.jpg"
        alt="Beautiful landscape"
        fill
        style={{ objectFit: 'cover' }}
      />
    </div>
  )
}
```

### Sizes Attribute

Tell Next.js which sizes to generate:

```typescript
import Image from 'next/image'

export function HeroImage() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero"
      width={1200}
      height={400}
      sizes="(max-width: 640px) 100vw,
             (max-width: 1024px) 80vw,
             1200px"
      priority
    />
  )
}

// For mobile: 100vw
// For tablet: 80vw
// For desktop: 1200px
```

## Remote Images

For images from external URLs:

```typescript
import Image from 'next/image'

export function ExternalImage() {
  return (
    <Image
      src="https://example.com/image.jpg"
      alt="External image"
      width={800}
      height={600}
    />
  )
}
```

Configure allowed domains in `next.config.ts`:

```typescript
// next.config.ts
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'example.com',
        pathname: '/images/**',
      },
      {
        protocol: 'https',
        hostname: '*.cloudinary.com',
      },
      {
        protocol: 'https',
        hostname: 'cdn.example.com',
        port: '443',
      },
    ],
  },
}

export default nextConfig
```

## Performance Features

### Priority Loading

Load above-the-fold images immediately:

```typescript
import Image from 'next/image'

export function Header() {
  return (
    <Image
      src="/logo.jpg"
      alt="Logo"
      width={200}
      height={100}
      priority // Loads immediately, no lazy loading
    />
  )
}
```

Only use `priority` for images visible in the initial viewport.

### Lazy Loading

Images below the fold load on demand:

```typescript
import Image from 'next/image'

export function ProductGallery() {
  return (
    <div>
      {products.map((product) => (
        <Image
          key={product.id}
          src={product.image}
          alt={product.name}
          width={300}
          height={300}
          // Lazy loading is default
          loading="lazy"
        />
      ))}
    </div>
  )
}
```

### Placeholder/Blur

Show a blur while loading:

```typescript
import Image from 'next/image'
import myImage from '@/public/hero.jpg'

export function HeroWithBlur() {
  return (
    <Image
      src={myImage}
      alt="Hero"
      placeholder="blur" // Blur-up effect
      blurDataURL="data:image/..." // Custom blur
    />
  )
}
```

For remote images, provide a blurDataURL:

```typescript
<Image
  src="https://example.com/image.jpg"
  alt="Image"
  width={800}
  height={600}
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAA..."
/>
```

## Sizing & Styling

### Fixed Dimensions

```typescript
import Image from 'next/image'

export function Avatar() {
  return (
    <Image
      src="/avatar.jpg"
      alt="User avatar"
      width={64}
      height={64}
    />
  )
}
```

### Responsive with CSS

```typescript
import Image from 'next/image'
import styles from './image.module.css'

export function ResponsiveImage() {
  return (
    <Image
      src="/image.jpg"
      alt="Image"
      width={1200}
      height={400}
      className={styles.image}
    />
  )
}
```

```css
/* image.module.css */
.image {
  width: 100%;
  height: auto;
  object-fit: cover;
}
```

### Container Query

```typescript
import Image from 'next/image'

export function ResponsiveGallery() {
  return (
    <div className="gallery">
      {images.map((image) => (
        <div key={image.id} className="gallery-item">
          <Image
            src={image.src}
            alt={image.alt}
            width={400}
            height={300}
            sizes="(max-width: 600px) 100vw,
                   (max-width: 1200px) 50vw,
                   33vw"
            style={{ objectFit: 'cover' }}
          />
        </div>
      ))}
    </div>
  )
}
```

## Background Images

Use CSS with Image for backgrounds:

```typescript
import Image from 'next/image'

export function HeroSection() {
  return (
    <div className="hero">
      <Image
        src="/background.jpg"
        alt="Background"
        fill
        className="background-image"
        quality={60}
      />
      <div className="content">
        <h1>Welcome</h1>
      </div>
    </div>
  )
}
```

```css
.hero {
  position: relative;
  width: 100%;
  height: 400px;
  overflow: hidden;
}

.background-image {
  object-fit: cover;
  object-position: center;
}

.content {
  position: relative;
  z-index: 1;
  /* ... */
}
```

## Quality Control

Adjust image quality (0-100):

```typescript
import Image from 'next/image'

export function GalleryImage() {
  return (
    <Image
      src="/photo.jpg"
      alt="Photo"
      width={800}
      height={600}
      quality={85} // Default is 75
    />
  )
}

// quality={100} - Best quality, larger file
// quality={75} - Balanced (default)
// quality={50} - Lower quality, smaller file
```

## Common Patterns

### Product Image with Gallery

```typescript
import Image from 'next/image'
import { useState } from 'react'

interface ProductImageProps {
  images: string[]
  alt: string
}

export function ProductImage({ images, alt }: ProductImageProps) {
  const [selectedIndex, setSelectedIndex] = useState(0)

  return (
    <div>
      <div className="main-image">
        <Image
          src={images[selectedIndex]}
          alt={alt}
          width={500}
          height={500}
          priority
          quality={90}
        />
      </div>

      <div className="thumbnails">
        {images.map((image, index) => (
          <button
            key={index}
            onClick={() => setSelectedIndex(index)}
            className={selectedIndex === index ? 'active' : ''}
          >
            <Image
              src={image}
              alt={`${alt} thumbnail ${index + 1}`}
              width={100}
              height={100}
            />
          </button>
        ))}
      </div>
    </div>
  )
}
```

### Avatar Component

```typescript
import Image from 'next/image'

interface AvatarProps {
  src: string
  name: string
  size?: 'sm' | 'md' | 'lg'
}

export function Avatar({ src, name, size = 'md' }: AvatarProps) {
  const sizes = {
    sm: 32,
    md: 48,
    lg: 64,
  }

  const dimension = sizes[size]

  return (
    <Image
      src={src}
      alt={name}
      width={dimension}
      height={dimension}
      className="rounded-full"
    />
  )
}
```

## Image Optimization Configuration

```typescript
// next.config.ts
const nextConfig = {
  images: {
    // Supported image formats
    formats: ['image/avif', 'image/webp'],

    // Cache optimized images
    minimumCacheTTL: 60,

    // Responsive image breakpoints
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],

    // Disable static imports (advanced)
    disableStaticImages: false,
  },
}

export default nextConfig
```

## Best Practices

1. **Always use alt text** - Required for accessibility
2. **Set explicit dimensions** - Prevents layout shift
3. **Use priority for above-fold** - Only for visible images
4. **Optimize quality** - 75 is usually sufficient
5. **Use srcset** - Automatic with sizes prop
6. **Lazy load below-fold** - Default behavior
7. **Compress source images** - Pre-compress to reasonable size
8. **Use WebP/AVIF** - Next.js handles conversion
9. **Monitor Largest Contentful Paint** - LCP metric
10. **Test on slow networks** - Ensure fast load times

## Troubleshooting

### Image Not Showing

```typescript
// Check:
// 1. Image exists at path
// 2. Width & height are set correctly
// 3. src is absolute for static, relative for remote
// 4. Remote domain is configured

<Image
  src="/public/image.jpg" // ❌ Wrong
  alt="Image"
  width={800}
  height={600}
/>

<Image
  src="/image.jpg" // ✅ Correct (public/ is implicit)
  alt="Image"
  width={800}
  height={600}
/>
```

### Layout Shift

```typescript
// Always set width & height to prevent layout shift
<Image
  src="/image.jpg"
  alt="Image"
  width={800} // Required
  height={600} // Required
/>
```

## Related Standards

- {{standards/frontend/performance}} - Performance optimization
- {{standards/global/project-structure}} - Image file organization
- {{standards/frontend/metadata}} - Image SEO
