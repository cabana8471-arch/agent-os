# WordPress Hooks

## Hooks Overview

WordPress extends functionality through **hooks**: points where code can attach custom behavior.

- **Actions**: Do something at a specific moment (send email, save data)
- **Filters**: Modify data before it's used or saved
- **Both use same attachment mechanism**: add_action(), add_filter()

## Actions (Doing Things)

Execute code at specific points in WordPress execution:

```php
// ✅ Good: Add action hook
add_action( 'init', 'register_custom_post_type' );

function register_custom_post_type() {
    register_post_type( 'book', [
        'label' => 'Books',
        'supports' => [ 'title', 'editor' ]
    ] );
}

// ✅ Good: Hook with priority and parameters
add_action( 'wp_enqueue_scripts', 'enqueue_styles', 10, 1 );

function enqueue_styles() {
    wp_enqueue_style( 'my-style', get_template_directory_uri() . '/style.css' );
}

// ✅ Good: Action with callback object method
add_action( 'init', [ $this, 'register_hooks' ] );

public function register_hooks() {
    // Initialize plugin
}

// ❌ Avoid: No action hook prefix for plugins
do_action( 'my_action' ); // Should prefix: do_action( 'my_plugin_my_action' )
```

### Common Action Hooks

```php
// WordPress initialization sequence (all plugins loaded)
add_action( 'plugins_loaded', 'my_init' );

// After WordPress setup (themes loaded)
add_action( 'after_setup_theme', 'my_setup' );

// WordPress initialization complete
add_action( 'init', 'my_init' );

// Admin initialization
add_action( 'admin_init', 'my_admin_init' );

// Admin menu setup
add_action( 'admin_menu', 'add_admin_menu' );

// Frontend template rendering
add_action( 'wp_head', 'add_custom_head' );
add_action( 'wp_footer', 'add_custom_footer' );

// Post save/update
add_action( 'save_post_post', 'on_post_save' );
add_action( 'wp_insert_post_data', 'filter_post_data' );

// User actions
add_action( 'user_register', 'on_user_register' );
add_action( 'profile_update', 'on_profile_update' );

// AJAX
add_action( 'wp_ajax_my_action', 'handle_my_ajax' );
add_action( 'wp_ajax_nopriv_my_action', 'handle_my_ajax' ); // Unauthenticated
```

## Filters (Modifying Data)

Transform data before it's used or saved:

```php
// ✅ Good: Add filter hook
add_filter( 'the_title', 'add_icon_to_title' );

function add_icon_to_title( $title ) {
    return '★ ' . $title;
}

// ✅ Good: Filter with multiple parameters
add_filter( 'wp_insert_post_data', 'sanitize_post_title', 10, 2 );

function sanitize_post_title( $data, $postarr ) {
    if ( isset( $data['post_title'] ) ) {
        $data['post_title'] = strtoupper( $data['post_title'] );
    }
    return $data;
}

// ✅ Good: Return modified data
add_filter( 'the_content', 'add_footer_to_content' );

function add_footer_to_content( $content ) {
    if ( is_singular( 'post' ) ) {
        $content .= '<footer>Article footer</footer>';
    }
    return $content;
}

// ❌ Avoid: Forgetting to return value
add_filter( 'the_title', function( $title ) {
    $title = strtoupper( $title );
    // Missing: return $title;
} );
```

### Common Filter Hooks

```php
// Post/Page content filters
add_filter( 'the_title', 'modify_title' );
add_filter( 'the_content', 'modify_content' );
add_filter( 'the_excerpt', 'modify_excerpt' );
add_filter( 'wp_insert_post_data', 'pre_save_post' );

// Post meta filters
add_filter( 'get_post_metadata', 'override_meta_value', 10, 4 );

// User data filters
add_filter( 'get_the_author_meta', 'modify_author_meta' );
add_filter( 'user_registration_email', 'modify_registration_email' );

// Query filters
add_filter( 'posts_where', 'add_custom_where_clause' );
add_filter( 'posts_orderby', 'modify_query_order' );

// Settings/Options
add_filter( 'option_siteurl', 'override_site_url' );
add_filter( 'pre_option_blogname', 'set_blog_name' );

// Admin/UI filters
add_filter( 'admin_body_class', 'add_admin_css_class' );
add_filter( 'post_row_actions', 'remove_post_actions', 10, 2 );
```

## Hook Naming Conventions

Always prefix plugin/theme hooks with unique identifier:

```php
// ✅ Good: Plugin-prefixed action
add_action( 'my_plugin_after_setup', 'initialize' );
do_action( 'my_plugin_after_setup' );

// ✅ Good: Plugin-prefixed filter
add_filter( 'my_plugin_allowed_post_types', 'get_post_types' );
apply_filters( 'my_plugin_allowed_post_types', $types );

// ❌ Avoid: Generic names (conflict with other plugins)
do_action( 'process_data' ); // Too generic
apply_filters( 'modify_output', $output ); // Too generic
```

**Naming Pattern**: `{plugin_slug}_{action_type}_{subject}`

Examples:
- `my_plugin_init_complete`
- `my_plugin_before_post_save`
- `my_plugin_filter_title`
- `my_plugin_allow_cpt`

## Hook Priority

Execute hooks in specific order using priority (default: 10):

```php
// ✅ Good: Lower priority runs first
add_action( 'wp_head', 'add_meta_tags', 5 );      // Runs first
add_action( 'wp_head', 'add_styles', 10 );         // Runs second
add_action( 'wp_head', 'add_scripts', 15 );        // Runs third

// ✅ Good: Priority ensures order
add_action( 'init', 'register_post_types', 5 );
add_action( 'init', 'register_taxonomies', 10 );
add_action( 'init', 'setup_hooks', 15 );
```

Use priorities strategically:
- **Very Early (0-5)**: Core setup
- **Default (10)**: Standard execution
- **Late (15-20)**: Final modifications

## Hook Parameters

Specify accepted arguments to pass to callback:

```php
// ✅ Good: Define accepted parameters
do_action( 'my_plugin_save_post', $post_id, $post, $update );

// Callback accepts same number of parameters
add_action( 'my_plugin_save_post', 'handle_post_save', 10, 3 );

function handle_post_save( $post_id, $post, $update ) {
    if ( $update ) {
        // Post was updated
    } else {
        // New post
    }
}

// ✅ Good: Filter with multiple parameters
apply_filters( 'my_plugin_format_title', $title, $post, $context );

add_filter( 'my_plugin_format_title', 'format_title_special', 10, 3 );

function format_title_special( $title, $post, $context ) {
    if ( 'admin' === $context ) {
        return '[' . $post->post_type . '] ' . $title;
    }
    return $title;
}

// ❌ Avoid: Wrong parameter count
do_action( 'my_action', $a, $b, $c ); // 3 params

add_action( 'my_action', function( $a ) { // Only accepts 1
    // Missing $b, $c
}, 10, 1 );
```

Count parameter tells WordPress how many args the callback accepts:
```php
add_filter( 'hook_name', 'callback', 10, 3 ); // callback accepts 3 params
```

## Removing Hooks

```php
// ✅ Good: Remove action
remove_action( 'wp_head', 'wp_generator' );

// ✅ Good: Remove with correct priority
add_action( 'init', 'my_function', 5 );
remove_action( 'init', 'my_function', 5 ); // Must match priority

// ✅ Good: Remove plugin hook (use class method)
remove_action( 'init', [ 'PluginClass', 'register_stuff' ], 10 );

// ❌ Avoid: Forgetting priority when removing
remove_action( 'init', 'my_function' ); // Wrong if added with different priority
```

## Creating Custom Hooks

```php
// ✅ Good: Allow plugins/themes to extend plugin
do_action( 'my_plugin_before_process', $data );

$data = apply_filters( 'my_plugin_process_data', $data );

do_action( 'my_plugin_after_process', $data );

// ✅ Good: Document hook in comment
/**
 * Fires before processing user data.
 *
 * @since 1.0.0
 *
 * @param array $user_data User data array.
 * @param int   $user_id   User ID.
 */
do_action( 'my_plugin_before_user_process', $user_data, $user_id );

/**
 * Filters user data before saving.
 *
 * @since 1.0.0
 *
 * @param array $user_data User data to save.
 * @param int   $user_id   User ID.
 *
 * @return array Modified user data.
 */
$user_data = apply_filters( 'my_plugin_save_user_data', $user_data, $user_id );
```

## Hook Best Practices

### Conditional Execution

```php
// ✅ Good: Only run on frontend
add_action( 'wp_enqueue_scripts', function() {
    wp_enqueue_script( 'my-script' );
} );

// ✅ Good: Only run in admin
add_action( 'admin_enqueue_scripts', function() {
    wp_enqueue_script( 'admin-script' );
} );

// ✅ Good: Check specific conditions
add_action( 'wp_footer', function() {
    if ( is_singular( 'post' ) ) {
        echo 'Post footer';
    }
} );
```

### Avoiding Infinite Loops

```php
// ❌ Avoid: Infinite loop
add_action( 'save_post', function( $post_id ) {
    wp_update_post( [ 'ID' => $post_id, 'post_title' => 'Modified' ] );
    // Triggers save_post again!
} );

// ✅ Good: Use flag to prevent recursion
$processing = false;

add_action( 'save_post', function( $post_id ) {
    global $processing;

    if ( $processing ) {
        return;
    }

    $processing = true;
    wp_update_post( [ 'ID' => $post_id, 'post_title' => 'Modified' ] );
    $processing = false;
} );

// ✅ Better: Use remove_action temporarily
add_action( 'save_post', function( $post_id ) {
    remove_action( 'save_post', __FUNCTION__ );
    wp_update_post( [ 'ID' => $post_id, 'post_title' => 'Modified' ] );
    add_action( 'save_post', __FUNCTION__ );
} );
```

## Performance Considerations

```php
// ❌ Avoid: Heavy operations in high-frequency hooks
add_action( 'wp_head', function() {
    $result = expensive_api_call(); // Runs on every page
} );

// ✅ Good: Cache expensive operations
add_action( 'wp_head', function() {
    $result = get_transient( 'my_cache_key' );
    if ( ! $result ) {
        $result = expensive_api_call();
        set_transient( 'my_cache_key', $result, HOUR_IN_SECONDS );
    }
    echo $result;
} );

// ✅ Good: Use cron for background tasks
add_action( 'wp_scheduled_delete', 'cleanup_old_data' );
```

## Related Standards

- {{standards/backend/post-types-taxonomies}} - Custom post type hooks
- {{standards/backend/rest-api}} - REST API hooks
- {{standards/global/security}} - Security in hooks
- {{standards/backend/plugins}} - Plugin activation hooks
