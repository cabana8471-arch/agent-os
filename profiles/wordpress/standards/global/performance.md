# WordPress Performance

## Caching

### Object Cache

```php
// ✅ Good: Cache query results
$cache_key = 'my_plugin_users_' . $page;
$users = wp_cache_get( $cache_key );

if ( false === $users ) {
    $users = get_users( [ 'number' => 20, 'offset' => ( $page - 1 ) * 20 ] );
    wp_cache_set( $cache_key, $users, 'my_plugin', HOUR_IN_SECONDS );
}

return $users;

// Invalidate cache when data changes
wp_cache_delete( 'my_plugin_users_1' );
wp_cache_delete_group( 'my_plugin' ); // Clear entire group
```

### Transients API

```php
// ✅ Good: Cache expensive operations
$cache_key = 'my_plugin_expensive_data';
$data = get_transient( $cache_key );

if ( false === $data ) {
    $data = expensive_operation();
    set_transient( $cache_key, $data, 12 * HOUR_IN_SECONDS );
}

return $data;

// Clear transient when needed
delete_transient( $cache_key );
```

## Query Optimization

```php
// ❌ Avoid: N+1 queries
$posts = get_posts();
foreach ( $posts as $post ) {
    $author = get_the_author_meta( 'display_name', $post->post_author );
    echo $author;
}

// ✅ Good: Warm up caches
$posts = get_posts( [ 'posts_per_page' => 50 ] );
update_post_meta_cache( wp_list_pluck( $posts, 'ID' ) );
update_post_term_cache( wp_list_pluck( $posts, 'ID' ) );

foreach ( $posts as $post ) {
    $author = get_the_author_meta( 'display_name', $post->post_author );
    echo $author; // No extra query
}

// ✅ Good: Use efficient query arguments
$posts = get_posts( [
    'posts_per_page' => 20,
    'update_post_meta_cache' => false, // Skip if not needed
    'no_found_rows' => true            // Skip count query
] );
```

## Asset Optimization

```php
// ✅ Good: Conditional script loading
add_action( 'wp_enqueue_scripts', function() {
    // Load only on specific pages
    if ( is_singular( 'post' ) ) {
        wp_enqueue_script( 'my-post-script', get_template_directory_uri() . '/js/post.js' );
    }

    // Load in footer
    wp_enqueue_script( 'my-script', get_template_directory_uri() . '/js/main.js', [], '1.0', true );

    // Async/defer loading
    add_filter( 'script_loader_tag', function( $tag, $handle ) {
        if ( 'my-async-script' === $handle ) {
            return str_replace( ' src', ' async src', $tag );
        }
        return $tag;
    }, 10, 2 );
} );

// ✅ Good: Minify CSS
wp_enqueue_style( 'my-style', get_template_directory_uri() . '/css/style.min.css' );
```

## Database Performance

```php
// ✅ Good: Limit query results
$recent_posts = get_posts( [ 'numberposts' => 5 ] );

// ✅ Good: Query only needed fields
global $wpdb;
$posts = $wpdb->get_results(
    "SELECT ID, post_title, post_date FROM {$wpdb->posts} LIMIT 10"
);

// ✅ Good: Index frequently-queried meta keys
add_action( 'init', function() {
    add_post_meta( $post_id, '_indexed_key', $value, true );
    // Prefix with underscore to mark as meta key
} );
```

## Lazy Loading

```php
// ✅ Good: Native lazy loading
<img src="image.jpg" loading="lazy" alt="Description" />

// ✅ Good: Lazy load iframes
<iframe src="video.html" loading="lazy"></iframe>
```

## Cron Jobs

```php
// ✅ Good: Schedule recurring task
add_action( 'init', function() {
    if ( ! wp_next_scheduled( 'my_daily_event' ) ) {
        wp_schedule_event( time(), 'daily', 'my_daily_event' );
    }
} );

add_action( 'my_daily_event', function() {
    // Do expensive operation
    cleanup_old_data();
    regenerate_cache();
} );

// Remove on deactivation
register_deactivation_hook( __FILE__, function() {
    wp_clear_scheduled_hook( 'my_daily_event' );
} );
```

## Related Standards

- {{standards/backend/queries}} - Query optimization
- {{standards/global/security}} - Secure caching
- {{standards/frontend/themes}} - Theme performance
