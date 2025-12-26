# Font Optimization with next/font

## Overview

`next/font` optimizes fonts automatically:
- Zero layout shift
- No external requests during render
- Works offline
- Subset to only needed characters
- Preload automatically

## Google Fonts

Import fonts from Google Fonts:

### Basic Usage

```typescript
// app/layout.tsx
import { Inter, Roboto_Mono } from 'next/font/google'

const inter = Inter({ subsets: ['latin'] })
const robotoMono = Roboto_Mono({
  subsets: ['latin'],
  weight: '400',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.className}>
      <body>{children}</body>
    </html>
  )
}
```

### Variable Fonts

```typescript
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
})

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={inter.variable}>
      <body style={{ fontFamily: 'var(--font-inter)' }}>
        {children}
      </body>
    </html>
  )
}
```

Then in CSS:

```css
body {
  font-family: var(--font-inter);
}

h1 {
  font-family: var(--font-serif);
}
```

### Multiple Fonts

```typescript
import { Inter, Playfair_Display } from 'next/font/google'

const inter = Inter({ subsets: ['latin'] })
const playfair = Playfair_Display({ subsets: ['latin'] })

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${inter.className} ${playfair.className}`}>
        {children}
      </body>
    </html>
  )
}
```

Use in components:

```typescript
// components/header.tsx
import { Playfair_Display } from 'next/font/google'

const playfair = Playfair_Display({ subsets: ['latin'] })

export function Header() {
  return <h1 className={playfair.className}>Welcome</h1>
}
```

### Font Weight Selection

```typescript
import { Roboto } from 'next/font/google'

const roboto = Roboto({
  weight: ['400', '700'], // Regular and bold
  subsets: ['latin'],
})

// Or variable:
const robotoVariable = Roboto({
  weight: 'variable',
  subsets: ['latin'],
})
```

### Subset Selection

Reduce file size by selecting only needed languages:

```typescript
import { Noto_Sans } from 'next/font/google'

// Latin only (smallest)
const notoSansLatin = Noto_Sans({
  subsets: ['latin'],
})

// Latin + Cyrillic (for Russian, Ukrainian, etc.)
const notoSansCyrillic = Noto_Sans({
  subsets: ['latin', 'cyrillic'],
})

// Latin + CJK (for Chinese, Japanese, Korean)
const notoSansCJK = Noto_Sans({
  subsets: ['latin', 'cyrillic', 'greek', 'vietnamese'],
})
```

Common subsets:
- `latin` - English, Western European
- `cyrillic` - Russian, Ukrainian, etc.
- `greek` - Greek
- `vietnamese` - Vietnamese
- `arabic` - Arabic
- `hebrew` - Hebrew
- `devanagari` - Hindi
- `thai` - Thai
- `chinese-simplified` - Simplified Chinese
- `chinese-traditional` - Traditional Chinese
- `japanese` - Japanese
- `korean` - Korean

## Local Fonts

Use your own font files:

### Single Font File

```typescript
// lib/fonts.ts
import localFont from 'next/font/local'

export const myFont = localFont({
  src: '/fonts/my-font.woff2',
  variable: '--font-my-font',
})
```

```typescript
// app/layout.tsx
import { myFont } from '@/lib/fonts'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={myFont.variable}>
      <body>{children}</body>
    </html>
  )
}
```

### Multiple Font Files

```typescript
import localFont from 'next/font/local'

export const myFont = localFont({
  src: [
    {
      path: '/fonts/my-font-regular.woff2',
      weight: '400',
      style: 'normal',
    },
    {
      path: '/fonts/my-font-bold.woff2',
      weight: '700',
      style: 'normal',
    },
    {
      path: '/fonts/my-font-italic.woff2',
      weight: '400',
      style: 'italic',
    },
  ],
  variable: '--font-my-font',
})
```

### Font Fallbacks

```typescript
import localFont from 'next/font/local'

export const myFont = localFont({
  src: '/fonts/my-font.woff2',
  fallback: ['system-ui', 'arial'],
})

// CSS fallback: my-font, system-ui, arial
```

## Font Display

Control how fonts load:

```typescript
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap', // Show fallback immediately, swap when ready
})

// display options:
// 'auto' - Default browser behavior
// 'block' - Hide text until font loads
// 'swap' - Show fallback immediately
// 'fallback' - Short timeout, then fallback
// 'optional' - No swap after timeout
```

Use `swap` for most cases - shows content immediately.

## Variable Fonts (Advanced)

Use single file for all weights:

```typescript
import { Raleway } from 'next/font/google'

const raleway = Raleway({
  weight: 'variable',
  subsets: ['latin'],
})

export default function Page() {
  return (
    <div>
      <h1 className={`${raleway.className} font-bold`}>Bold</h1>
      <p className={`${raleway.className} font-normal`}>Normal</p>
    </div>
  )
}
```

## CSS Custom Property

Export fonts as CSS variables:

```typescript
import { Poppins, IBM_Plex_Mono } from 'next/font/google'

const poppins = Poppins({
  weight: ['400', '600', '700'],
  variable: '--font-poppins',
  subsets: ['latin'],
})

const ibmPlexMono = IBM_Plex_Mono({
  weight: '400',
  variable: '--font-mono',
  subsets: ['latin'],
})

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${poppins.variable} ${ibmPlexMono.variable}`}>
      <body>{children}</body>
    </html>
  )
}
```

```css
/* styles/globals.css */
:root {
  --font-sans: var(--font-poppins);
  --font-mono: var(--font-mono);
}

body {
  font-family: var(--font-sans);
}

code, pre {
  font-family: var(--font-mono);
}

h1, h2, h3 {
  font-family: var(--font-sans);
  font-weight: 700;
}
```

## Performance Tips

### 1. Preload Critical Fonts

Critical fonts are automatically preloaded. Only the fonts you use are loaded.

```typescript
// This font is used in multiple places, automatically preloaded
import { Inter } from 'next/font/google'

const inter = Inter()
```

### 2. Limit Font Variants

```typescript
// ❌ Bad - Loads 9 weights (400-900)
const roboto = Roboto()

// ✅ Good - Only loads needed weights
const roboto = Roboto({
  weight: ['400', '700'],
})
```

### 3. Use Variable Fonts

One file for all weights is more efficient than multiple weighted files:

```typescript
// ✅ Good - Single file, all weights
const inter = Inter({ weight: 'variable' })

// More verbose but clearer intent:
const inter = Inter({
  variable: '--font-inter',
})
```

### 4. Optimize Subsets

```typescript
// ❌ Bad - Loads all supported languages
const notoSans = Noto_Sans()

// ✅ Good - Only load needed languages
const notoSans = Noto_Sans({
  subsets: ['latin'],
})
```

### 5. Use font-display: swap

```typescript
const inter = Inter({
  subsets: ['latin'],
  display: 'swap', // Don't hide text while loading
})
```

## Complete Example

```typescript
// lib/fonts.ts
import { Inter, Playfair_Display } from 'next/font/google'
import localFont from 'next/font/local'

export const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
})

export const playfair = Playfair_Display({
  weight: ['400', '700'],
  subsets: ['latin'],
  variable: '--font-playfair',
  display: 'swap',
})

export const mono = localFont({
  src: '/fonts/jetbrains-mono.woff2',
  weight: '400',
  variable: '--font-mono',
})
```

```typescript
// app/layout.tsx
import { inter, playfair, mono } from '@/lib/fonts'
import '@/styles/globals.css'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${playfair.variable} ${mono.variable}`}>
      <body className={inter.className}>{children}</body>
    </html>
  )
}
```

```css
/* styles/globals.css */
:root {
  --font-sans: var(--font-inter);
  --font-display: var(--font-playfair);
  --font-mono: var(--font-mono);
}

body {
  font-family: var(--font-sans);
  line-height: 1.6;
}

h1, h2, h3 {
  font-family: var(--font-display);
}

code, pre {
  font-family: var(--font-mono);
}
```

## Font Pairing Ideas

### Modern Sans-Serif + Serif
- **Inter** (sans) + **Lora** (serif)
- **Poppins** (sans) + **Playfair Display** (serif)

### Tech/Mono + Sans
- **JetBrains Mono** (mono) + **Inter** (sans)
- **IBM Plex Mono** (mono) + **IBM Plex Sans** (sans)

### Elegant Display + Text
- **Playfair Display** (display) + **Open Sans** (text)
- **Abril Fatface** (display) + **Lato** (text)

## Best Practices

1. **Use next/font** - Never self-host or load from CDN
2. **Limit to 2-3 fonts** - Avoid font bloat
3. **Use variable fonts** - Single file, all weights
4. **Use `display: swap`** - Don't hide content
5. **Specify weights** - Only load needed variants
6. **Subset for language** - Reduces file size
7. **Test on slow networks** - Ensure fast load
8. **Monitor Web Vitals** - Check LCP and CLS

## Related Standards

- {{standards/frontend/performance}} - Performance optimization
- {{standards/global/project-structure}} - Font file organization
- {{standards/frontend/metadata}} - Font in OG images
