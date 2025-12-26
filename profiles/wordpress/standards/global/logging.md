# WordPress Logging

## Debug Mode Configuration

```php
// wp-config.php - Development
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false ); // Don't show errors to visitors
define( 'SCRIPT_DEBUG', true );      // Use unminified scripts

// wp-config.php - Production
define( 'WP_DEBUG', false );
define( 'WP_DEBUG_LOG', false );
define( 'WP_DEBUG_DISPLAY', false );
```

## error_log() Function

```php
// Basic logging
error_log( 'Simple message' );

// Log variables (use print_r for arrays/objects)
error_log( print_r( $data, true ) );

// Log with context
error_log( sprintf(
    '[%s] User %d performed action: %s',
    current_time( 'mysql' ),
    get_current_user_id(),
    $action
) );

// Conditional logging
if ( defined( 'WP_DEBUG' ) && WP_DEBUG ) {
    error_log( 'Debug info: ' . $message );
}
```

## Custom Logging Function

```php
/**
 * Log message to custom file
 *
 * @param string $message Log message
 * @param string $type    Log type (info, warning, error)
 */
function my_plugin_log( $message, $type = 'info' ) {
    if ( ! defined( 'WP_DEBUG' ) || ! WP_DEBUG ) {
        return;
    }

    $log_file = WP_CONTENT_DIR . '/my-plugin-debug.log';
    $timestamp = current_time( 'mysql' );
    $log_entry = sprintf( "[%s] [%s] %s\n", $timestamp, strtoupper( $type ), $message );

    // phpcs:ignore WordPress.WP.AlternativeFunctions.file_system_operations_file_put_contents
    file_put_contents( $log_file, $log_entry, FILE_APPEND | LOCK_EX );
}

// Usage
my_plugin_log( 'Processing started', 'info' );
my_plugin_log( 'Invalid data received', 'warning' );
my_plugin_log( 'Database connection failed', 'error' );
```

## Structured Logging

```php
/**
 * Structured log entry with context
 */
function my_plugin_structured_log( $event, $context = [] ) {
    if ( ! defined( 'WP_DEBUG' ) || ! WP_DEBUG ) {
        return;
    }

    $log_data = [
        'timestamp'  => current_time( 'c' ),
        'event'      => $event,
        'user_id'    => get_current_user_id(),
        'request_id' => wp_generate_uuid4(),
        'context'    => $context,
    ];

    error_log( wp_json_encode( $log_data ) );
}

// Usage
my_plugin_structured_log( 'order_created', [
    'order_id'   => 123,
    'total'      => 99.99,
    'items'      => 3,
] );
```

## Query Monitor Integration

```php
// Log to Query Monitor (if installed)
if ( function_exists( 'do_action' ) ) {
    do_action( 'qm/debug', $variable );
    do_action( 'qm/info', 'Informational message' );
    do_action( 'qm/warning', 'Warning message' );
    do_action( 'qm/error', 'Error message' );
}

// With context
do_action( 'qm/debug', [
    'user'   => $user_id,
    'action' => $action_name,
    'data'   => $data,
] );
```

## Database Query Logging

```php
// Enable query logging (wp-config.php)
define( 'SAVEQUERIES', true );

// Access logged queries
global $wpdb;
foreach ( $wpdb->queries as $query ) {
    $sql      = $query[0]; // SQL query
    $time     = $query[1]; // Execution time
    $caller   = $query[2]; // Function that called it

    if ( $time > 0.05 ) { // Log slow queries (>50ms)
        error_log( sprintf( 'Slow query (%.4fs): %s', $time, $sql ) );
    }
}
```

## Action/Filter Logging

```php
// Log hook execution (development only)
add_action( 'all', function( $hook ) {
    if ( strpos( $hook, 'my_plugin' ) === 0 ) {
        error_log( 'Hook fired: ' . $hook );
    }
}, 1 );

// Log specific hook with data
add_action( 'save_post', function( $post_id, $post ) {
    error_log( sprintf(
        'Post saved: ID=%d, Type=%s, Status=%s',
        $post_id,
        $post->post_type,
        $post->post_status
    ) );
}, 10, 2 );
```

## AJAX Debugging

```php
add_action( 'wp_ajax_my_action', function() {
    // Log incoming request
    error_log( 'AJAX my_action: ' . print_r( $_POST, true ) );

    try {
        $result = process_ajax_request();
        error_log( 'AJAX success: ' . print_r( $result, true ) );
        wp_send_json_success( $result );
    } catch ( Exception $e ) {
        error_log( 'AJAX error: ' . $e->getMessage() );
        wp_send_json_error( [ 'message' => $e->getMessage() ] );
    }
} );
```

## REST API Debugging

```php
// Log REST requests
add_filter( 'rest_pre_dispatch', function( $result, $server, $request ) {
    error_log( sprintf(
        'REST %s %s',
        $request->get_method(),
        $request->get_route()
    ) );
    return $result;
}, 10, 3 );

// Log REST errors
add_filter( 'rest_request_after_callbacks', function( $response, $handler, $request ) {
    if ( is_wp_error( $response ) ) {
        error_log( 'REST error: ' . print_r( $response->get_error_messages(), true ) );
    }
    return $response;
}, 10, 3 );
```

## Log File Locations

```
wp-content/debug.log          # Default WP_DEBUG_LOG location
wp-content/my-plugin-debug.log # Custom plugin log
/var/log/php-errors.log       # PHP error log (server config)
/var/log/apache2/error.log    # Apache error log
/var/log/nginx/error.log      # Nginx error log
```

## Best Practices

- **Never log in production** - Use `WP_DEBUG` check before logging
- **Never log sensitive data** - Passwords, API keys, credit cards, PII
- **Use structured logging** - JSON format for easier parsing
- **Include context** - User ID, request ID, timestamp
- **Log slow operations** - Database queries, API calls
- **Rotate logs** - Prevent disk space issues
- **Use Query Monitor** - Better than error_log for development

## Related Standards

- {{standards/global/error-handling}} - Error handling patterns
- {{standards/global/security}} - Never log sensitive data
- {{standards/global/performance}} - Log slow operations
