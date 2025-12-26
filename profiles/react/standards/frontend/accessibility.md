# React Accessibility (a11y)

## Semantic HTML

```typescript
// ❌ Avoid: Non-semantic divs
<div onClick={handleClick} role="button">Delete</div>

// ✅ Good: Semantic elements
<button onClick={handleClick}>Delete</button>

// ✅ Good: Proper heading hierarchy
<h1>Page Title</h1>
<section>
  <h2>Section Title</h2>
  <h3>Subsection</h3>
</section>

// ✅ Good: Use semantic containers
<header>{/* Header */}</header>
<nav>{/* Navigation */}</nav>
<main>{/* Main content */}</main>
<footer>{/* Footer */}</footer>
```

## ARIA Attributes

```typescript
// ✅ Good: ARIA for interactive elements
<button aria-label="Close menu" onClick={close}>×</button>

// ✅ Good: ARIA live regions for dynamic updates
<div aria-live="polite" aria-atomic="true">
  {message && <p>{message}</p>}
</div>

// ✅ Good: ARIA expanded state
<button aria-expanded={isOpen} onClick={toggle}>
  Menu
</button>
<nav aria-hidden={!isOpen}>{/* Menu items */}</nav>

// ✅ Good: ARIA invalid for form fields
<input
  type="email"
  aria-invalid={!!error}
  aria-describedby={error ? 'email-error' : undefined}
/>
{error && <span id="email-error">{error}</span>}
```

## Focus Management

```typescript
// ✅ Good: Focus trap in modals
function Modal({ isOpen, onClose }: Props) {
  const firstButtonRef = useRef<HTMLButtonElement>(null)
  const lastButtonRef = useRef<HTMLButtonElement>(null)

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key !== 'Tab') return

    if (e.shiftKey) {
      if (document.activeElement === firstButtonRef.current) {
        lastButtonRef.current?.focus()
        e.preventDefault()
      }
    } else {
      if (document.activeElement === lastButtonRef.current) {
        firstButtonRef.current?.focus()
        e.preventDefault()
      }
    }
  }

  return (
    <div role="dialog" onKeyDown={handleKeyDown}>
      <button ref={firstButtonRef}>First</button>
      {/* content */}
      <button ref={lastButtonRef}>Last</button>
    </div>
  )
}

// ✅ Good: Return focus after modal
const [lastFocused, setLastFocused] = useState<HTMLElement | null>(null)

const openModal = () => {
  setLastFocused(document.activeElement as HTMLElement)
}

const closeModal = () => {
  lastFocused?.focus()
}
```

## Keyboard Navigation

```typescript
// ✅ Good: Keyboard handlers
function Dropdown({ items }: Props) {
  const [selectedIndex, setSelectedIndex] = useState(0)

  const handleKeyDown = (e: React.KeyboardEvent) => {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        setSelectedIndex((i) => (i + 1) % items.length)
        break
      case 'ArrowUp':
        e.preventDefault()
        setSelectedIndex((i) => (i - 1 + items.length) % items.length)
        break
      case 'Enter':
        selectItem(items[selectedIndex])
        break
      case 'Escape':
        close()
        break
    }
  }

  return <div onKeyDown={handleKeyDown}>{/* items */}</div>
}

// ✅ Good: Skip links
<div className="sr-only">
  <a href="#main">Skip to main content</a>
</div>

<main id="main">{/* Main content */}</main>

// CSS to hide skip link until focused
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
}

.sr-only:focus {
  position: relative;
  width: auto;
  height: auto;
  overflow: visible;
}
```

## Color & Contrast

```typescript
// ✅ Good: Don't rely on color alone
<div className="text-green-600 flex items-center">
  <CheckIcon /> {/* Also use icon */}
  Success
</div>

// ✅ Good: Sufficient contrast (4.5:1 minimum)
// Use Tailwind classes that meet WCAG AA standards
<p className="text-gray-900 bg-white">{/* Good contrast */}</p>
<p className="text-gray-500 bg-white">{/* Bad contrast */}</p>

// ✅ Good: Test with tools
// - Browser DevTools accessibility inspector
// - axe DevTools extension
// - WebAIM contrast checker
```

## Testing Accessibility

```typescript
import { render, screen } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'

expect.extend(toHaveNoViolations)

test('has no accessibility violations', async () => {
  const { container } = render(<Component />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})

test('button is accessible', () => {
  render(<button>Submit</button>)
  const button = screen.getByRole('button', { name: /submit/i })
  expect(button).toBeInTheDocument()
})

test('form has accessible labels', () => {
  render(
    <form>
      <label htmlFor="email">Email</label>
      <input id="email" type="email" />
    </form>
  )
  const input = screen.getByLabelText('Email')
  expect(input).toBeInTheDocument()
})
```

## Screen Reader Testing

```typescript
// ✅ Good: Use screen reader text for icons
<button aria-label="Close dialog">
  <CloseIcon aria-hidden="true" />
</button>

// ✅ Good: Announce form errors
<input
  aria-invalid={!!error}
  aria-describedby={error ? 'error-msg' : undefined}
/>
{error && (
  <span id="error-msg" role="alert">
    {error}
  </span>
)}

// ✅ Good: Hide decorative content
<span aria-hidden="true">→</span> Next Page
```

## Related Standards

- {{standards/frontend/components}} - Component structure
- {{standards/frontend/css}} - Color contrast
- {{standards/testing/test-writing}} - Testing patterns
