# WordPress Internationalization (i18n)

Translation support for themes and plugins.

## Text Domain

Unique identifier for translations:

```php
// Plugin header
<?php
/**
 * Plugin Name: My Plugin
 * Text Domain: my-plugin
 * Domain Path: /languages
 */

// Theme style.css header
/*
Theme Name: My Theme
Text Domain: my-theme
Domain Path: /languages
*/
```

## Translation Functions

```php
// Simple string translation
__( 'Hello World', 'my-plugin' )

// Echo translation
_e( 'Hello World', 'my-plugin' )

// Escaped output
esc_html__( 'Hello World', 'my-plugin' )
esc_attr__( 'Hello World', 'my-plugin' )
esc_html_e( 'Hello World', 'my-plugin' )
esc_attr_e( 'Hello World', 'my-plugin' )

// With context (for disambiguation)
_x( 'Post', 'singular noun', 'my-plugin' )

// Pluralization
_n( 'One item', '%s items', $count, 'my-plugin' )
sprintf( _n( 'One item', '%s items', $count, 'my-plugin' ), $count )

// With context and pluralization
_nx( 'One post', '%s posts', $count, 'context', 'my-plugin' )
```

## Loading Translations

```php
// ✅ Good: Load plugin translations
add_action( 'plugins_loaded', function() {
    load_plugin_textdomain(
        'my-plugin',
        false,
        dirname( plugin_basename( __FILE__ ) ) . '/languages'
    );
} );

// ✅ Good: Load theme translations
add_action( 'after_setup_theme', function() {
    load_theme_textdomain(
        'my-theme',
        get_template_directory() . '/languages'
    );
} );
```

## Creating Translation Files

Generate POT (Portable Object Template) file:

```bash
# Using WP-CLI
wp i18n make-pot . languages/my-plugin.pot

# Using Poedit or other tools
# Select source files and generate POT
```

File structure:
```
languages/
  my-plugin.pot        # Template (for translators)
  my-plugin-es_ES.po   # Spanish translation source
  my-plugin-es_ES.mo   # Spanish translation compiled
  my-plugin-fr_FR.po   # French translation source
  my-plugin-fr_FR.mo   # French translation compiled
```

## JavaScript Translations

```php
// ✅ Good: Pass strings to JavaScript
wp_localize_script( 'my-script', 'MyStrings', [
    'hello' => __( 'Hello', 'my-plugin' ),
    'goodbye' => __( 'Goodbye', 'my-plugin' ),
] );
```

```javascript
// In JavaScript
console.log( MyStrings.hello ); // 'Hello' or translated version
```

**Better: Use wp_set_script_translations for block editor:**

```php
add_action( 'enqueue_block_editor_assets', function() {
    wp_set_script_translations(
        'my-block-script',
        'my-plugin',
        get_template_directory() . '/languages'
    );
} );
```

## Escaping Translated Strings

```php
// ✅ Good: Escape after translation
echo wp_kses_post( __( 'The <strong>best</strong> plugin', 'my-plugin' ) );

// ✅ Good: HTML-safe translation
wp_kses_post( __( 'Welcome back <em>%s</em>!', 'my-plugin' ) );

// ✅ Good: URL in translated string
echo esc_url( sprintf(
    __( 'Visit %s for more info', 'my-plugin' ),
    'https://example.com'
) );
```

## Variable Strings

```php
// ✅ Good: Dynamic strings
$message = sprintf(
    __( 'Hello %s, you have %d items', 'my-plugin' ),
    $name,
    $count
);

// ✅ Good: Pluralization with variable
echo sprintf(
    _n( 'You have %d item', 'You have %d items', $count, 'my-plugin' ),
    $count
);
```

## Common Patterns

```php
// ✅ Good: Form labels
<label for="email">
    <?php esc_html_e( 'Email Address', 'my-plugin' ); ?>
</label>

// ✅ Good: Admin messages
if ( $saved ) {
    echo '<div class="updated"><p>';
    esc_html_e( 'Settings saved successfully.', 'my-plugin' );
    echo '</p></div>';
}

// ✅ Good: Navigation items
wp_nav_menu( [
    'theme_location' => 'primary',
    'fallback_cb'    => function() {
        echo esc_html_e( 'No menu found', 'my-theme' );
    }
] );
```

## Related Standards

- {{standards/global/coding-style}} - PHP conventions
- {{standards/frontend/themes}} - Theme translation
- {{standards/backend/plugins}} - Plugin translation
