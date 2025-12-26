# WordPress Error Handling

## WP_Error Class

```php
// ✅ Good: Use WP_Error for errors
$result = new WP_Error(
    'invalid_user',           // Error code
    'User not found',         // Error message
    [ 'status' => 404 ]       // Additional data
);

// ✅ Good: Check for errors
if ( is_wp_error( $result ) ) {
    $error_code = $result->get_error_code();
    $error_msg = $result->get_error_message();
    $error_data = $result->get_error_data();
}

// ✅ Good: Add multiple errors
$errors = new WP_Error();
$errors->add( 'email_invalid', 'Email is invalid' );
$errors->add( 'password_short', 'Password too short' );
if ( $errors->has_errors() ) {
    return $errors;
}
```

## Debug Mode

```php
// wp-config.php
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'WP_DEBUG_DISPLAY', false ); // Don't display errors in frontend

// Logs to wp-content/debug.log
error_log( 'Debug message' );
error_log( print_r( $variable, true ) );

// Check debug log
tail -f wp-content/debug.log
```

## Admin Notices

```php
// ✅ Good: Display admin notices
add_action( 'admin_notices', function() {
    if ( ! isset( $_GET['updated'] ) ) {
        return;
    }

    echo '<div class="notice notice-success is-dismissible"><p>';
    esc_html_e( 'Settings saved successfully.', 'my-plugin' );
    echo '</p></div>';
} );

// Different notice types
// notice-success, notice-error, notice-warning, notice-info
```

## AJAX Error Handling

```php
// ✅ Good: Handle AJAX errors
add_action( 'wp_ajax_my_action', function() {
    check_ajax_referer( 'my_nonce' );

    if ( ! current_user_can( 'manage_options' ) ) {
        wp_send_json_error( [ 'message' => 'Unauthorized' ] );
    }

    try {
        $result = process_data();
        wp_send_json_success( [ 'result' => $result ] );
    } catch ( Exception $e ) {
        wp_send_json_error( [ 'message' => $e->getMessage() ] );
    }
} );
```

## REST API Error Responses

```php
// ✅ Good: Return errors from REST endpoints
register_rest_route( 'my/v1', '/users', [
    'callback' => function( WP_REST_Request $request ) {
        $user_id = $request['id'];
        $user = get_user_by( 'ID', $user_id );

        if ( ! $user ) {
            return new WP_Error(
                'user_not_found',
                'User not found',
                [ 'status' => 404 ]
            );
        }

        return new WP_REST_Response( $user, 200 );
    }
] );
```

## Exception Handling

```php
// ✅ Good: Catch and handle exceptions
try {
    if ( ! isset( $_POST['data'] ) ) {
        throw new Exception( 'Missing required data' );
    }

    $result = process_data( $_POST['data'] );
    return [ 'success' => true, 'data' => $result ];
} catch ( Exception $e ) {
    error_log( 'Error: ' . $e->getMessage() );
    return [ 'success' => false, 'error' => $e->getMessage() ];
}
```

## Related Standards

- {{standards/global/security}} - Secure error handling
- {{standards/backend/rest-api}} - REST error responses
- {{standards/global/logging}} - Logging patterns
