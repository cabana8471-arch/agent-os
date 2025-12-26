# WordPress Accessibility (WCAG 2.1 AA)

## Semantic HTML

```php
// ✅ Good: Use semantic elements
<header>
    <h1><?php the_title(); ?></h1>
</header>

<main id="main" role="main">
    <?php while ( have_posts() ) {
        the_post(); ?>
        <article <?php post_class(); ?>>
            <h2><?php the_title(); ?></h2>
            <?php the_content(); ?>
        </article>
    <?php } ?>
</main>

<aside role="complementary">
    <?php get_sidebar(); ?>
</aside>

<footer>
    <?php wp_footer(); ?>
</footer>

// ❌ Avoid: Non-semantic divs
<div class="header">
<div class="content">
<div class="sidebar">
```

## Keyboard Navigation

```php
// ✅ Good: Keyboard accessible menus
wp_nav_menu( [
    'container' => 'nav',
    'container_aria_label' => 'Main Navigation',
    'menu_class' => 'menu',
    'fallback_cb' => false
] );

// ✅ Good: Skip links
<div class="skip-link">
    <a href="#main"><?php esc_html_e( 'Skip to main content', 'my-theme' ); ?></a>
</div>

// CSS to show on focus
.skip-link a:focus {
    position: relative;
    z-index: 1;
}
```

## Form Accessibility

```php
// ✅ Good: Proper label association
<label for="email"><?php esc_html_e( 'Email Address', 'my-theme' ); ?></label>
<input type="email" id="email" name="email" required aria-required="true" />

// ✅ Good: Error messages linked
<input
    type="email"
    id="email"
    aria-invalid="<?php echo isset( $errors['email'] ) ? 'true' : 'false'; ?>"
    aria-describedby="<?php echo isset( $errors['email'] ) ? 'email-error' : ''; ?>"
/>
<?php if ( isset( $errors['email'] ) ) : ?>
    <span id="email-error" role="alert">
        <?php echo esc_html( $errors['email'] ); ?>
    </span>
<?php endif; ?>
```

## Images & Alt Text

```php
// ✅ Good: Always provide alt text
<?php
$image_id = get_post_thumbnail_id();
$alt_text = get_post_meta( $image_id, '_wp_attachment_image_alt', true );
?>
<img src="<?php the_post_thumbnail_url(); ?>" alt="<?php echo esc_attr( $alt_text ); ?>" />

// ✅ Good: Gutenberg image blocks auto-support alt text
// ✅ Good: Links with clear text
<a href="<?php the_permalink(); ?>"><?php the_title(); ?></a>

// ❌ Avoid: "Click here" links
<a href="<?php the_permalink(); ?>">Click here</a>
```

## Color & Contrast

```php
// ✅ Good: Don't rely on color alone
<div class="success">
    ✓ <?php esc_html_e( 'Success', 'my-theme' ); ?>
</div>

// ✅ Good: Sufficient contrast (4.5:1 for normal text)
// Use WebAIM contrast checker or browser tools

// CSS
.text-primary {
    color: #000; /* 21:1 contrast with white */
}

.text-secondary {
    color: #666; /* 7:1 contrast with white */
}
```

## Headings

```php
// ✅ Good: Proper heading hierarchy
<h1><?php the_title(); ?></h1>
<h2><?php the_content(); ?></h2>
<h3><?php esc_html_e( 'Related Posts', 'my-theme' ); ?></h3>

// ❌ Avoid: Skipping heading levels
<h1>Title</h1>
<h3>Subtitle</h3> <!-- Missing h2 -->

// ❌ Avoid: Multiple h1 tags
<h1>Site Title</h1>
<h1>Page Title</h1>
```

## Aria Landmarks

```php
// ✅ Good: Use landmark roles
<nav aria-label="Primary Navigation">
    <?php wp_nav_menu( [ 'menu' => 'main' ] ); ?>
</nav>

<main id="main" role="main">
    <?php the_content(); ?>
</main>

<aside role="complementary" aria-label="Sidebar">
    <?php get_sidebar(); ?>
</aside>

<footer>
    <?php wp_footer(); ?>
</footer>
```

## Testing Accessibility

```bash
# Browser tools
- Chrome DevTools > Lighthouse (Accessibility tab)
- axe DevTools browser extension
- WebAIM contrast checker

# Automated testing
- axe-core
- WAVE
- AccessibilityChecker

# Manual testing
- Keyboard-only navigation
- Screen reader (NVDA, JAWS)
- High contrast mode
```

## WCAG 2.1 Checklist

- ✅ Perceivable: Content must be perceivable
- ✅ Operable: Interface must be navigable
- ✅ Understandable: Content must be clear
- ✅ Robust: Works with assistive technologies

## Related Standards

- {{standards/frontend/themes}} - Theme accessibility
- {{standards/global/security}} - Secure ARIA implementation
