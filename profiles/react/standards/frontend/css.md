# React CSS & Styling

## Primary Approach: Tailwind CSS

Utility-first CSS framework (recommended for React):

```jsx
// ✅ Good: Tailwind utility classes
export function UserCard({ user }) {
  return (
    <div className="rounded-lg border border-gray-200 p-6 shadow-md">
      <img
        src={user.avatar}
        alt={user.name}
        className="mb-4 h-12 w-12 rounded-full"
      />
      <h3 className="mb-2 text-lg font-semibold">{user.name}</h3>
      <p className="text-gray-600">{user.bio}</p>
    </div>
  )
}

// ✅ Good: Responsive design with Tailwind
<div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
  {items.map((item) => <div key={item.id}>{item.name}</div>)}
</div>

// ✅ Good: Dark mode support
<div className="bg-white text-black dark:bg-gray-900 dark:text-white">
  Content
</div>

// ❌ Avoid: @apply overuse (defeats utility-first purpose)
// .card { @apply rounded-lg border border-gray-200 p-6; }
// Better to extract as component instead
```

### Tailwind Configuration

```javascript
// tailwind.config.js
export default {
  content: ['./index.html', './src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#f0f9ff',
          500: '#0ea5e9',
          900: '#0c2340',
        },
      },
      spacing: {
        '128': '32rem',
      },
      fontSize: {
        xs: ['12px', { lineHeight: '16px' }],
      },
    },
  },
  plugins: [require('@tailwindcss/typography')],
}
```

### Class Merging with clsx

```jsx
import { clsx } from 'clsx'

// ✅ Good: Merge conditional classes
function Button({ variant = 'primary', disabled, ...props }) {
  return (
    <button
      className={clsx(
        'px-4 py-2 rounded font-semibold transition',
        {
          'bg-blue-600 text-white hover:bg-blue-700': variant === 'primary',
          'bg-gray-200 text-gray-800 hover:bg-gray-300': variant === 'secondary',
          'opacity-50 cursor-not-allowed': disabled,
        }
      )}
      disabled={disabled}
      {...props}
    />
  )
}

// ✅ Better: Use cn() utility for Tailwind conflicts
import { cn } from '@/lib/utils' // shadcn utility

<div className={cn('px-2 py-1', 'px-4 py-2')} /> // Second wins
```

## Alternative: CSS Modules

Scoped CSS for component isolation:

```jsx
// UserCard.tsx
import styles from './UserCard.module.css'

export function UserCard({ user }) {
  return (
    <div className={styles.card}>
      <img src={user.avatar} alt={user.name} className={styles.avatar} />
      <h3 className={styles.title}>{user.name}</h3>
      <p className={styles.bio}>{user.bio}</p>
    </div>
  )
}

// UserCard.module.css
.card {
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  margin-bottom: 16px;
}

.title {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 8px;
}

.bio {
  color: #4b5563;
}
```

### Composition with CSS Modules

```jsx
// Button.module.css
.button {
  padding: 8px 16px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: all 200ms;
}

.primary {
  composes: button;
  background-color: #0ea5e9;
  color: white;
}

.primary:hover {
  background-color: #0284c7;
}

// Button.tsx
import styles from './Button.module.css'

export function Button({ variant = 'primary', ...props }) {
  const className = styles[variant] || styles.primary
  return <button className={className} {...props} />
}
```

## Component-Scoped Styling Patterns

### Inline Styles (Limited Use)

```jsx
// ✅ Good: Dynamic values only
export function ProgressBar({ percentage }) {
  return (
    <div className="h-4 bg-gray-200 rounded-full overflow-hidden">
      <div
        className="bg-blue-600 h-full transition-all"
        style={{ width: `${percentage}%` }}
      />
    </div>
  )
}

// ❌ Avoid: All styles inline
<div style={{ backgroundColor: '#fff', padding: '16px' }}>Content</div>
```

### CSS Variables for Theming

```jsx
// App.tsx
export function App() {
  const [isDark, setIsDark] = useState(false)

  return (
    <div
      className={isDark ? 'dark' : 'light'}
      style={{
        '--bg-primary': isDark ? '#1f2937' : '#ffffff',
        '--text-primary': isDark ? '#f3f4f6' : '#111827',
        '--border-color': isDark ? '#374151' : '#e5e7eb',
      } as React.CSSProperties}
    >
      <Header onThemeChange={setIsDark} />
      <main>{/* ... */}</main>
    </div>
  )
}

// styles.css
:root {
  --bg-primary: #ffffff;
  --text-primary: #111827;
  --border-color: #e5e7eb;
}

.card {
  background-color: var(--bg-primary);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
}
```

## Responsive Design

### Mobile-First Approach

```jsx
// ✅ Good: Mobile-first with Tailwind breakpoints
<div className="flex flex-col md:flex-row lg:gap-8">
  {/* Mobile: column | Tablet+: row | Large: with gap */}
  <aside className="w-full md:w-1/4">
    {/* Mobile: full width | Tablet+: 25% */}
  </aside>
  <main className="w-full md:w-3/4">
    {/* Mobile: full width | Tablet+: 75% */}
  </main>
</div>

// ✅ Good: Tailwind breakpoints
// sm: 640px
// md: 768px (tablet)
// lg: 1024px (desktop)
// xl: 1280px
// 2xl: 1536px
```

### Responsive Images

```jsx
// ✅ Good: Responsive images
<img
  src={imageSmall}
  srcSet={`${imageSmall} 640w, ${imageMedium} 1024w, ${imageLarge} 1920w`}
  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 90vw, 1200px"
  alt="Description"
  className="w-full h-auto"
/>

// ✅ Good: Lazy loading
<img src={image} alt="Description" loading="lazy" />

// ✅ Good: Picture element for format selection
<picture>
  <source srcSet={imageWebp} type="image/webp" />
  <source srcSet={imagePng} type="image/png" />
  <img src={imagePng} alt="Description" />
</picture>
```

## Performance

### Code Splitting Styles

```jsx
// ✅ Good: Vite automatically code splits CSS
import Button from './Button.tsx' // CSS imported with component

// ✅ Good: Critical CSS in main bundle
// Tailwind purges unused classes in production

// ✅ Good: Lazy load component-specific styles
const HeavyChart = lazy(() => import('./HeavyChart.tsx'))
```

### Animations Performance

```jsx
// ✅ Good: Use transform/opacity (GPU-accelerated)
const animationVariants = {
  hidden: { opacity: 0, transform: 'translateY(10px)' },
  visible: { opacity: 1, transform: 'translateY(0)' },
}

// ❌ Avoid: Animating size/position (forces layout recalculation)
.animate {
  animation: slideIn 300ms;
}

@keyframes slideIn {
  from { width: 0; } // Expensive
  to { width: 100%; }
}
```

## Best Practices

### Component Styling Hierarchy

```jsx
// 1. Tailwind utilities (preferred)
<div className="flex items-center justify-between">

// 2. CSS Modules (for complex components)
<div className={styles.container}>

// 3. Inline styles (only for dynamic values)
<div style={{ width: `${percentage}%` }}>

// ❌ Never: Styled-components or emotion (adds runtime overhead)
```

### Avoiding Common Pitfalls

```jsx
// ❌ Avoid: Hardcoded colors (not in design system)
<div className="bg-#a1b2c3">

// ✅ Good: Use design system colors
<div className="bg-brand-600">

// ❌ Avoid: Arbitrary spacing values
<div className="mt-73">

// ✅ Good: Use defined spacing scale
<div className="mt-16"> // 4rem (64px)

// ❌ Avoid: Breaking responsive breakpoints
<div className="hidden md:block lg:hidden"> // Confusing

// ✅ Good: Clear responsive intent
<div className="block md:hidden"> // Show on mobile, hide on tablet+
```

## Related Standards

- {{standards/frontend/components}} - Component structure
- {{standards/frontend/responsive}} - Responsive design principles
- {{standards/frontend/accessibility}} - Color contrast, readability
