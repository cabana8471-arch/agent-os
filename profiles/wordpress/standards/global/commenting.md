# WordPress Code Commenting

## PHPDoc Blocks

```php
/**
 * Short description of the function.
 *
 * Longer description can go here and explain what the function does
 * in detail. This can span multiple lines and should be clear and complete.
 *
 * @since 1.0.0
 *
 * @param int    $post_id   The ID of the post to process.
 * @param string $data      The data to process.
 * @param bool   $force     Whether to force processing. Default false.
 *
 * @return bool|WP_Error True on success, WP_Error on failure.
 *
 * @throws InvalidArgumentException If post_id is invalid.
 */
function process_post_data( $post_id, $data, $force = false ) {
    // Code here
}

/**
 * User object for our application.
 *
 * @since 1.0.0
 */
class My_User {
    /**
     * User ID.
     *
     * @since 1.0.0
     * @var int
     */
    private $id;

    /**
     * Get user by ID.
     *
     * @since 1.0.0
     *
     * @param int $id User ID.
     *
     * @return My_User|null User object or null if not found.
     */
    public static function get_by_id( $id ) {
        // Code
    }
}
```

## Plugin File Header

```php
<?php
/**
 * Plugin Name: My Plugin
 * Description: What this plugin does
 * Version: 1.0.0
 * Author: Your Name
 * License: GPL v2 or later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: my-plugin
 * Domain Path: /languages
 * Requires at least: 5.0
 * Requires PHP: 7.4
 *
 * @package My_Plugin
 */
```

## Inline Comments

```php
// ✅ Good: Explain complex logic
// Use three-pass algorithm: first pass finds all valid posts,
// second pass filters by criteria, third pass applies transformations
$filtered = apply_transformations( filter_by_criteria( find_valid_posts() ) );

// ✅ Good: Document non-obvious decisions
// Must check both admin and frontend because custom post type
// permissions may differ based on context
if ( is_admin() ) {
    $cap = 'edit_items';
} else {
    $cap = 'read_items';
}

// ❌ Avoid: Obvious comments
$count = count( $items ); // Count items
$name = $user->name; // Get user name

// ❌ Avoid: Comments that contradict code
// This loop processes everything (but it actually skips items > 100)
foreach ( $items as $item ) {
    if ( $item->value > 100 ) continue;
}
```

## Hook Documentation

```php
/**
 * Fires after post is processed.
 *
 * @since 1.0.0
 * @hook my_plugin_after_post_process
 *
 * @param int   $post_id The post ID.
 * @param array $data    The processed data.
 */
do_action( 'my_plugin_after_post_process', $post_id, $data );

/**
 * Filters the user data before saving.
 *
 * @since 1.0.0
 * @hook my_plugin_filter_user_data
 *
 * @param array $user_data The user data.
 * @param int   $user_id   The user ID.
 *
 * @return array Filtered user data.
 */
$user_data = apply_filters( 'my_plugin_filter_user_data', $user_data, $user_id );
```

## Class & Method Documentation

```php
/**
 * Handles user authentication.
 *
 * This class provides methods for authenticating users, managing sessions,
 * and validating credentials against stored data.
 *
 * @since 1.0.0
 *
 * @package My_Plugin
 */
class My_Auth_Handler {
    /**
     * Instance of this class.
     *
     * @since 1.0.0
     * @var My_Auth_Handler
     */
    private static $instance = null;

    /**
     * Get or create singleton instance.
     *
     * @since 1.0.0
     *
     * @return My_Auth_Handler
     */
    public static function get_instance() {
        if ( is_null( self::$instance ) ) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Authenticate user credentials.
     *
     * @since 1.0.0
     *
     * @param string $username Username to authenticate.
     * @param string $password Password to check.
     *
     * @return int|false User ID on success, false on failure.
     */
    public function authenticate( $username, $password ) {
        // Code
    }
}
```

## Type Hints in Comments

```php
// For legacy PHP < 7, use PHPDoc type hints
/**
 * Get posts of a specific type.
 *
 * @since 1.0.0
 *
 * @param string[] $types Array of post type names.
 * @param int      $limit Maximum number of posts.
 *
 * @return WP_Post[] Array of post objects.
 */
function get_posts_of_types( $types, $limit = 10 ) {
    // PHP 7.4+ should use actual type hints instead:
    // function get_posts_of_types( array $types, int $limit = 10 ): array
}
```

## Changelog & TODO

```php
/**
 * Check if user can access resource.
 *
 * @since 1.0.0
 *
 * @todo Add support for custom post type permissions
 * @todo Refactor to use standard WordPress capabilities
 *
 * @param int $user_id    User ID.
 * @param int $resource_id Resource ID.
 *
 * @return bool True if user can access, false otherwise.
 */
function user_can_access( $user_id, $resource_id ) {
    // Code
}
```

## Related Standards

- {{standards/global/coding-style}} - Code conventions
- {{standards/backend/hooks}} - Hook documentation
