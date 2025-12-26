# WordPress Coding Style

## WordPress Coding Standards

Follow WordPress Coding Standards for consistency across plugins and themes.

```php
// ✅ Good: WordPress indentation (tabs)
function wp_hello_world() {
    if ( true ) {
        echo 'Hello World';
    }
}

// ✅ Good: Yoda conditions (constant first)
if ( 'yes' === $option ) {
    echo 'Option is yes';
}

if ( 10 > $count ) {
    echo 'Count is less than 10';
}

// ✅ Good: Brace style (opening brace on same line)
if ( $condition ) {
    // Code
} elseif ( $other_condition ) {
    // Code
} else {
    // Code
}

// ❌ Avoid: Opening brace on new line
if ( $condition )
{
    // Code
}
```

## Naming Conventions

```php
// Functions: lowercase with underscores, plugin/theme prefixed
function my_plugin_process_data() { }

// Constants: UPPERCASE
define( 'MY_PLUGIN_VERSION', '1.0.0' );
define( 'MY_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );

// Classes: PascalCase with plugin prefix
class My_Plugin_Handler { }

// Variables & array keys: lowercase with underscores
$post_author = get_post_field( 'post_author' );
$options = [ 'post_type' => 'post', 'per_page' => 10 ];

// Hook names: lowercase with underscores, plugin/theme prefixed
do_action( 'my_plugin_after_save' );
add_filter( 'my_plugin_format_output', 'format_function' );

// Meta keys: lowercase with underscores, plugin/theme prefixed
add_post_meta( $post_id, 'my_plugin_featured', true );

// File names: lowercase with hyphens
my-plugin-admin.php
my-plugin-functions.php
```

## Code Organization

```php
// ✅ Good: Logical organization
// 1. Plugin/theme constants
define( 'MY_PLUGIN_DIR', dirname( __FILE__ ) );

// 2. Includes
require_once MY_PLUGIN_DIR . '/includes/admin.php';
require_once MY_PLUGIN_DIR . '/includes/frontend.php';

// 3. Activation/deactivation
register_activation_hook( __FILE__, 'my_plugin_activate' );
register_deactivation_hook( __FILE__, 'my_plugin_deactivate' );

// 4. Main hooks
add_action( 'init', 'my_plugin_init' );
add_action( 'wp_enqueue_scripts', 'my_plugin_enqueue_scripts' );

// 5. Helper functions
function my_plugin_init() { }
function my_plugin_enqueue_scripts() { }
```

## Documentation Standards

```php
// ✅ Good: PHPDoc block required for all functions
/**
 * Process post data and save to database.
 *
 * This function sanitizes input, validates, and saves post data
 * using WordPress update functions.
 *
 * @since 1.0.0
 *
 * @param int   $post_id The post ID to update.
 * @param array $data    Array of post data to save.
 *
 * @return int|WP_Error Post ID on success, WP_Error on failure.
 */
function my_plugin_save_post( $post_id, $data ) {
    // Function body
}

// ✅ Good: PHPDoc for classes
/**
 * Main plugin handler class.
 *
 * @since 1.0.0
 */
class My_Plugin_Handler {
    /**
     * Initialize hooks.
     *
     * @since 1.0.0
     *
     * @return void
     */
    public function init() {
        add_action( 'init', [ $this, 'register_post_types' ] );
    }
}

// ✅ Good: Plugin file header
<?php
/**
 * Plugin Name: My Plugin Name
 * Description: Brief description of what plugin does
 * Version: 1.0.0
 * Author: Your Name
 * License: GPL v2 or later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: my-plugin-name
 */
```

## Type Hints (PHP 7+)

```php
// ✅ Good: Add type hints where possible
function get_user_by_email( string $email ): ?WP_User {
    return get_user_by( 'email', $email );
}

// ✅ Good: Multiple return types (PHP 8)
function save_data( array $data ): int|WP_Error {
    if ( empty( $data ) ) {
        return new WP_Error( 'empty_data' );
    }
    return insert_data( $data );
}

// ✅ Good: Union types for arguments
function process_value( int|float|string $value ): string {
    return (string) $value;
}
```

## Array Formatting

```php
// ✅ Good: Short array syntax with aligned arguments
$args = [
    'post_type'      => 'post',
    'posts_per_page' => 10,
    'orderby'        => 'date',
    'order'          => 'DESC',
];

// ✅ Good: Multiline for complex arrays
$post_type_args = [
    'labels'    => [
        'name'          => 'Books',
        'singular_name' => 'Book',
    ],
    'supports'  => [
        'title',
        'editor',
        'thumbnail',
    ],
    'taxonomies' => [ 'category', 'post_tag' ],
];
```

## PHPCS Configuration

```xml
<!-- .phpcs.xml.dist -->
<?xml version="1.0"?>
<ruleset name="My Plugin Coding Standards">
    <description>Coding standards for My Plugin</description>

    <!-- Use WordPress-Core and WordPress-Extra standards -->
    <rule ref="WordPress-Core" />
    <rule ref="WordPress-Extra" />

    <!-- Adjust minimum PHP version -->
    <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
        <properties>
            <property name="prefixes" value="my_plugin" />
        </properties>
    </rule>

    <!-- Exclude certain rules if needed -->
    <rule ref="WordPress.DB.SlowDBQuery.slow_db_query_meta_query">
        <severity>0</severity>
    </rule>
</ruleset>
```

## Running PHPCS

```bash
# Install globally or locally
composer require --dev phpcs

# Run on specific file
./vendor/bin/phpcs my-plugin-file.php --standard=WordPress-Core

# Run on entire plugin
./vendor/bin/phpcs . --standard=WordPress-Core --ignore=vendor,node_modules

# Auto-fix issues
./vendor/bin/phpcbf . --standard=WordPress-Core
```

## Common Pitfalls

```php
// ❌ Avoid: Using global variables without prefix
global $count; // Too generic

// ✅ Good: Prefixed globals
global $my_plugin_count;

// ❌ Avoid: Direct database queries without prepare
$results = $wpdb->get_results( "SELECT * FROM posts WHERE ID = {$_GET['id']}" );

// ✅ Good: Prepared statements
$results = $wpdb->get_results( $wpdb->prepare(
    "SELECT * FROM posts WHERE ID = %d",
    $_GET['id']
) );

// ❌ Avoid: Magic numbers without explanation
if ( count( $posts ) > 5 ) {

// ✅ Good: Named constants
define( 'MY_PLUGIN_MAX_POSTS', 5 );
if ( count( $posts ) > MY_PLUGIN_MAX_POSTS ) {
```

## Related Standards

- {{standards/global/security}} - Secure coding practices
- {{standards/backend/hooks}} - Hook naming conventions
- {{standards/global/commenting}} - PHPDoc documentation
