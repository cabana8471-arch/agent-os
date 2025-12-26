# WordPress Multisite Development

Developing for WordPress multisite networks.

## Network vs Site

- **Network**: Collection of WordPress sites
- **Site**: Individual WordPress site in network
- **Blog**: Term still used but now refers to "site"

## Network Activation

```php
// ✅ Good: Plugin works on single AND network
if ( is_multisite() ) {
    // Network-wide functionality
} else {
    // Single-site functionality
}

// ✅ Good: Register network activation hook
register_activation_hook( __FILE__, function() {
    if ( is_multisite() ) {
        // Network-wide setup
        foreach ( get_sites() as $site ) {
            switch_to_blog( $site->blog_id );
            // Setup for this site
            restore_current_blog();
        }
    } else {
        // Single site setup
    }
} );
```

## Site Switching

```php
// ✅ Good: Switch to different site
switch_to_blog( $site_id );
// Code here runs in context of site_id
update_option( 'my_setting', 'value' );
restore_current_blog();
// Back to original site

// ✅ Good: Get current site ID
$current_site_id = get_current_blog_id();

// ✅ Good: Loop through all sites
foreach ( get_sites() as $site ) {
    switch_to_blog( $site->blog_id );
    do_something();
    restore_current_blog();
}
```

## Network Options

```php
// ✅ Good: Network-wide options (stored in main wp_options)
$value = get_site_option( 'my_network_setting' );
update_site_option( 'my_network_setting', 'value' );
delete_site_option( 'my_network_setting' );

// Single-site options (stored in wp_{site_id}_options)
get_option( 'my_site_setting' );
```

## Network Admin Pages

```php
// ✅ Good: Add network admin menu
add_action( 'network_admin_menu', function() {
    add_menu_page(
        'Network Settings',
        'My Plugin',
        'manage_network',
        'my-plugin-network',
        'render_network_page'
    );
} );

// ✅ Good: Network admin page
function render_network_page() {
    if ( ! current_user_can( 'manage_network' ) ) {
        wp_die( 'Not authorized' );
    }

    // Render network settings
}

// ✅ Good: Network-specific capabilities
if ( ! current_user_can( 'manage_network' ) ) {
    // User can't manage network
}
```

## Multisite Hooks

```php
// ✅ Good: Network-related hooks
add_action( 'wp_initialize_site', 'on_site_created' );
add_action( 'wp_delete_site', 'on_site_deleted' );
add_action( 'add_user_to_blog', 'on_user_added_to_site', 10, 3 );
add_action( 'remove_user_from_blog', 'on_user_removed_from_site', 10, 2 );

function on_site_created( WP_Site $site ) {
    // Setup for newly created site
    update_blog_option( $site->blog_id, 'my_setting', 'value' );
}

function on_site_deleted( WP_Site $site ) {
    // Cleanup when site deleted
}
```

## Cross-Site Queries

```php
// ✅ Good: Query across sites
foreach ( get_sites() as $site ) {
    $posts = get_posts( [
        'blog_id' => $site->blog_id,
        'post_type' => 'post'
    ] );
}

// ✅ Good: Get user meta from specific site
$value = get_user_meta( $user_id, 'site_specific_key', true );

// ✅ Good: Multisite-aware option retrieval
function get_multisite_option( $option, $default = false ) {
    if ( is_multisite() ) {
        return get_site_option( $option, $default );
    }
    return get_option( $option, $default );
}
```

## Multisite Considerations

```php
// ❌ Avoid: Assuming single site
define( 'MY_CONSTANT', get_option( 'my_option' ) );
// In multisite, this value is site-specific and might differ per site

// ✅ Good: Use get_site_option for network settings
define( 'MY_CONSTANT', get_site_option( 'my_network_option' ) );

// ❌ Avoid: Hardcoding site ID
update_blog_option( 1, 'setting', 'value' );

// ✅ Good: Get specific site first
foreach ( get_sites() as $site ) {
    update_blog_option( $site->blog_id, 'setting', 'value' );
}
```

## Testing Multisite

```php
// Enable multisite in wp-config.php for testing
define( 'MULTISITE', true );
define( 'SUBDOMAIN_INSTALL', false );

// Or programmatically in tests
if ( ! is_multisite() ) {
    // Multisite not enabled
}
```

## Related Standards

- {{standards/backend/plugins}} - Plugin development
- {{standards/backend/hooks}} - Multisite hooks
- {{standards/global/security}} - Multisite security
