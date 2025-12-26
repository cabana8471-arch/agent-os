# WordPress Task Implementation

## Pre-Implementation Setup

Before starting implementation:

- ✅ Local WordPress running (Local.app or Docker)
- ✅ WP-CLI installed for commands
- ✅ Code editor with WordPress plugins installed
- ✅ PHPCS configured with WordPress standards
- ✅ Database backed up
- ✅ Understand the task requirements completely

## Plugin/Theme Implementation Pattern

### 1. Create File Structure

```bash
# Plugin structure
mkdir wp-content/plugins/my-plugin
touch wp-content/plugins/my-plugin/my-plugin.php
mkdir wp-content/plugins/my-plugin/includes
mkdir wp-content/plugins/my-plugin/assets
```

### 2. Create Main Plugin File

```php
<?php
/**
 * Plugin Name: My Plugin
 * Description: What it does
 * Version: 1.0.0
 * Author: Your Name
 * Text Domain: my-plugin
 */

defined( 'ABSPATH' ) || exit;

// Define constants
define( 'MY_PLUGIN_VERSION', '1.0.0' );
define( 'MY_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );
define( 'MY_PLUGIN_URL', plugin_dir_url( __FILE__ ) );

// Load main class
require_once MY_PLUGIN_DIR . 'includes/class-plugin.php';

// Initialize
add_action( 'plugins_loaded', function() {
    My_Plugin::get_instance();
} );

// Activation hook
register_activation_hook( __FILE__, function() {
    flush_rewrite_rules();
} );
```

### 3. Implement Functionality

```php
// includes/class-plugin.php
class My_Plugin {
    private static $instance = null;

    public static function get_instance() {
        if ( is_null( self::$instance ) ) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    private function __construct() {
        add_action( 'init', [ $this, 'register_post_types' ] );
        add_action( 'init', [ $this, 'register_hooks' ] );
    }

    public function register_post_types() {
        // Register custom post types
    }

    public function register_hooks() {
        // Register custom hooks and actions
    }
}
```

### 4. Test Implementation

```bash
# Check for errors
wp --allow-root eval 'echo "WordPress OK";'

# Verify custom post types
wp --allow-root post-type list

# Check for PHP errors
php -l wp-content/plugins/my-plugin/my-plugin.php

# Run PHPCS
phpcs wp-content/plugins/my-plugin/ --standard=WordPress
```

## Self-Verification Checklist

After implementation:

- ✅ **Plugin Activation**: Plugin activates without errors
- ✅ **No PHP Errors**: `wp --allow-root eval 'echo PHP_VERSION;'`
- ✅ **PHPCS Check**: No WordPress standard violations
- ✅ **Functionality**: Feature works as specified
- ✅ **Database**: Custom tables created if needed
- ✅ **Rewrite Rules**: Flushed with `flush_rewrite_rules()`
- ✅ **Permissions**: Tested with different user roles
- ✅ **Security**: Nonces, sanitization, escaping in place

## Useful WP-CLI Commands

```bash
# Post types
wp post-type list
wp post-type get my_custom_type

# Taxonomies
wp taxonomy list

# Plugins
wp plugin list
wp plugin activate my-plugin
wp plugin test-unknown-plugins

# Options
wp option get my_option
wp option update my_option "value"

# Meta
wp post meta list 1
wp user meta list 1

# Flush rewrites
wp rewrite flush

# Run SQL
wp db query "SELECT * FROM wp_posts LIMIT 1"
```

## Common Implementation Tasks

### Register Custom Post Type

```php
add_action( 'init', function() {
    register_post_type( 'book', [
        'label' => 'Books',
        'public' => true,
        'show_in_rest' => true,
        'supports' => [ 'title', 'editor', 'thumbnail' ]
    ] );
} );
```

### Register Custom Taxonomy

```php
add_action( 'init', function() {
    register_taxonomy( 'book_genre', 'book', [
        'label' => 'Genres',
        'hierarchical' => true,
        'show_in_rest' => true
    ] );
} );
```

### Create Admin Page

```php
add_action( 'admin_menu', function() {
    add_menu_page(
        'My Plugin Settings',
        'My Plugin',
        'manage_options',
        'my-plugin',
        'my_plugin_page'
    );
} );

function my_plugin_page() {
    if ( ! current_user_can( 'manage_options' ) ) {
        wp_die();
    }
    echo '<div class="wrap"><h1>My Plugin</h1></div>';
}
```

### Add Custom Meta Box

```php
add_action( 'add_meta_boxes', function() {
    add_meta_box(
        'my_meta_box',
        'Custom Data',
        function( $post ) {
            $value = get_post_meta( $post->ID, '_custom_field', true );
            echo '<input type="text" name="custom_field" value="' . esc_attr( $value ) . '" />';
        },
        'post'
    );
} );

add_action( 'save_post', function( $post_id ) {
    if ( isset( $_POST['custom_field'] ) ) {
        update_post_meta( $post_id, '_custom_field', sanitize_text_field( $_POST['custom_field'] ) );
    }
} );
```

## Debugging Tips

```php
// Log to debug.log
error_log( print_r( $data, true ) );

// Check if in debug mode
if ( defined( 'WP_DEBUG' ) && WP_DEBUG ) {
    wp_die( 'Something wrong' );
}

// Debug query
global $wpdb;
error_log( $wpdb->last_query );
error_log( $wpdb->last_error );
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Class not found" | Check `require_once` paths |
| Rewrite rules not working | Run `wp rewrite flush` |
| Meta not saving | Check `save_post` nonce |
| Permission denied | Verify `current_user_can()` |
| Blank admin page | Enable WP_DEBUG in wp-config |
| Hook not firing | Check action hook name spelling |

## Related Standards

- {{standards/backend/plugins}} - Plugin architecture
- {{standards/backend/hooks}} - Hook patterns
- {{standards/global/security}} - Security checklist
- {{standards/global/coding-style}} - Code standards
