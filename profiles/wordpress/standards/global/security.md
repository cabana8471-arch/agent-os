# WordPress Security

## Direct File Access Prevention

Always add to top of plugin/theme files:

```php
// ✅ Good: Prevent direct access
if ( ! defined( 'ABSPATH' ) ) {
    exit;
}

// ✅ Acceptable: Alternative check
defined( 'ABSPATH' ) || exit;
```

## Nonce Verification

Required for all state-changing operations (forms, AJAX, REST API):

```php
// ✅ Good: Create nonce in form
wp_nonce_field( 'save_user_' . $user_id, 'user_nonce' );

// ✅ Good: Verify nonce on submission
if ( ! isset( $_POST['user_nonce'] ) ||
     ! wp_verify_nonce( $_POST['user_nonce'], 'save_user_' . $user_id ) ) {
    wp_die( 'Nonce verification failed' );
}

// ✅ Good: AJAX nonce verification
check_admin_referer( 'my_ajax_action_nonce', 'nonce' );

// ❌ Avoid: Missing nonce check
if ( isset( $_POST['save'] ) ) { // No nonce verification
    update_user_meta( $user_id, 'name', $_POST['name'] );
}
```

- **Timing**: Generate nonce early, verify before processing
- **Action Name**: Use unique, descriptive nonce action names
- **User Role**: Consider combining with capability check
- **AJAX**: Nonce required for all AJAX endpoints

## Capability Checks

Always verify user permissions before allowing actions:

```php
// ✅ Good: Check capabilities before action
if ( ! current_user_can( 'edit_post', $post_id ) ) {
    wp_die( 'Unauthorized', '', [ 'response' => 403 ] );
}

// ✅ Good: Custom capability for plugins
if ( ! current_user_can( 'manage_my_plugin' ) ) {
    return;
}

// ✅ Good: Custom post type capabilities
if ( ! current_user_can( 'edit_custom_cpt', $post_id ) ) {
    wp_die( 'Unauthorized' );
}

// ❌ Avoid: Allowing unauthenticated access
if ( isset( $_GET['action'] ) ) { // No capability check
    process_action( $_GET['action'] );
}

// ❌ Avoid: Only checking is_admin()
if ( is_admin() ) { // Not enough - check specific capability
    update_option( 'important_setting', $_POST['value'] );
}
```

- **Always Check**: Before any user action
- **Specific Capabilities**: Use granular capabilities, not just edit_posts
- **Custom Capabilities**: Map to roles (admin, editor, contributor)
- **REST API**: Use permission_callback (never __return_true)

## Data Sanitization

Sanitize all user input BEFORE saving to database:

```php
// ✅ Good: Sanitize before save
$name = sanitize_text_field( $_POST['name'] );
update_post_meta( $post_id, 'user_name', $name );

// ✅ Good: Sanitize email
$email = sanitize_email( $_POST['email'] );
if ( is_email( $email ) ) {
    update_user_meta( $user_id, 'email', $email );
}

// ✅ Good: Sanitize title
$title = sanitize_title( $_POST['title'] );

// ✅ Good: Sanitize HTML content
$content = wp_kses_post( $_POST['content'] );

// ✅ Good: Settings API (auto sanitizes with callback)
register_setting(
    'my_settings',
    'my_option',
    [ 'sanitize_callback' => 'sanitize_text_field' ]
);

// ❌ Avoid: No sanitization
$name = $_POST['name'];
update_post_meta( $post_id, 'name', $name );

// ❌ Avoid: Allowing all HTML
$content = $_POST['content']; // Should use wp_kses_post
```

**Common Sanitization Functions:**
- `sanitize_text_field()` - Basic text, removes tags
- `sanitize_email()` - Valid email format
- `sanitize_title()` - WordPress title format
- `absint()` - Convert to absolute integer
- `wp_kses_post()` - Allow safe HTML tags
- `wp_json_encode()` - Safe JSON encoding

## Output Escaping

Escape all user-generated content BEFORE displaying:

```php
// ✅ Good: Escape text output
echo esc_html( $user->name );

// ✅ Good: Escape HTML attributes
<a href="<?php echo esc_url( $link ); ?>">Link</a>

// ✅ Good: Escape attributes with additional filtering
<div class="<?php echo esc_attr( $css_class ); ?>">

// ✅ Good: Escape JavaScript
<script>
var name = <?php echo wp_json_encode( $user->name ); ?>;
</script>

// ✅ Good: Escape post content (allows safe HTML)
echo wp_kses_post( $post->post_content );

// ✅ Good: Escape URL
echo esc_url( $user->website );

// ❌ Avoid: No escaping
echo $user->name; // XSS vulnerability

// ❌ Avoid: Escaping at wrong layer
$user->name = esc_html( $user->name ); // Escape on display, not save
```

**Escape by Context:**
- `esc_html()` - In HTML text
- `esc_attr()` - In HTML attributes
- `esc_url()` - In href/src attributes
- `esc_js()` - In JavaScript strings
- `wp_kses_post()` - Post/page content (allows some HTML)
- `wp_kses()` - Custom whitelist of allowed tags

## SQL Query Safety

Always use prepared statements with wpdb:

```php
// ✅ Good: Prepared statement
$wpdb->prepare(
    "SELECT * FROM {$wpdb->posts} WHERE post_author = %d AND post_type = %s",
    $user_id,
    'post'
);

// ✅ Good: Using wpdb methods
$results = $wpdb->get_results(
    $wpdb->prepare(
        "SELECT * FROM {$wpdb->postmeta} WHERE post_id = %d AND meta_key = %s",
        $post_id,
        'important_data'
    )
);

// ✅ Good: Multiple placeholders
// %d for integers, %s for strings, %f for floats
$wpdb->prepare(
    "INSERT INTO {$wpdb->posts} (post_author, post_title) VALUES (%d, %s)",
    $user_id,
    $title
);

// ❌ Avoid: String concatenation
$query = "SELECT * FROM {$wpdb->posts} WHERE ID = " . $_GET['id'];

// ❌ Avoid: No placeholders
$query = $wpdb->prepare( "SELECT * WHERE name = " . $name );
```

- **Always Use Placeholders**: %d for int, %s for string, %f for float
- **$wpdb->prepare()**: Works with get_results, query, etc.
- **Custom Tables**: Add wp_ prefix: wp_custom_table

## File Upload Security

```php
// ✅ Good: Secure file upload handling
if ( isset( $_FILES['upload'] ) ) {
    // Check nonce
    check_admin_referer( 'upload_nonce', 'nonce' );

    // Handle upload
    $upload = wp_handle_upload(
        $_FILES['upload'],
        [ 'test_form' => true ]
    );

    if ( isset( $upload['error'] ) ) {
        wp_die( $upload['error'] );
    }

    // Validate MIME type
    $allowed_types = [ 'image/jpeg', 'image/png' ];
    if ( ! in_array( $upload['type'], $allowed_types ) ) {
        wp_die( 'Invalid file type' );
    }

    // Store file path safely
    $file_id = wp_insert_attachment(
        [
            'post_mime_type' => $upload['type'],
            'post_title'     => preg_replace( '/\.[^.]+$/', '', $_FILES['upload']['name'] ),
            'post_content'   => '',
            'post_status'    => 'inherit'
        ],
        $upload['file']
    );
}

// ❌ Avoid: No MIME validation
move_uploaded_file( $_FILES['upload']['tmp_name'], $destination );

// ❌ Avoid: Direct file execution paths
$_FILES['upload']['name'] // Could be .php, .exe, etc.
```

## REST API Security

```php
// ✅ Good: Permission callback (REQUIRED)
register_rest_route(
    'myapp/v1',
    '/users/(?P<id>\d+)',
    [
        'methods'             => 'POST',
        'callback'            => 'update_user_data',
        'permission_callback' => function( $request ) {
            return current_user_can( 'edit_users' );
        },
        'args'                => [
            'id' => [
                'sanitize_callback' => 'absint',
                'validate_callback' => function( $param ) {
                    return is_numeric( $param );
                }
            ]
        ]
    ]
);

// ✅ Good: Sanitize and validate args
register_rest_route(
    'myapp/v1',
    '/posts',
    [
        'methods'  => 'POST',
        'callback' => 'create_post',
        'args'     => [
            'title' => [
                'type'              => 'string',
                'sanitize_callback' => 'sanitize_text_field',
                'required'          => true
            ],
            'status' => [
                'type'              => 'string',
                'enum'              => [ 'draft', 'publish' ],
                'validate_callback' => function( $param ) {
                    return in_array( $param, [ 'draft', 'publish' ] );
                }
            ]
        ]
    ]
);

// ❌ Avoid: No permission callback
register_rest_route( 'myapp/v1', '/admin-data', [
    'callback' => 'get_admin_data',
    // Missing permission_callback
] );

// ❌ Avoid: __return_true
'permission_callback' => '__return_true' // Never do this
```

## Secret Key Management

Store sensitive data in wp-config.php, never in code:

```php
// ✅ Good: Use WordPress constants
define( 'API_KEY', 'actual_key_here' );

// In code, use constant
$api = new ApiClient( API_KEY );

// ✅ Good: Environment variables (if hosting supports)
$api_key = getenv( 'API_KEY' );

// ❌ Avoid: Hardcoded secrets
$api_key = 'my_secret_key_12345'; // Commits to git

// ❌ Avoid: Storing in options (if sensitive)
update_option( 'api_key', 'secret' ); // Accessible in code/plugins
```

- **wp-config.php**: Best place for configuration constants
- **.env file**: Use with dotenv for local development
- **Never Commit**: Add config files to .gitignore
- **Environment Variables**: Use in hosting dashboard (Vercel, Render, etc.)

## User Input in Admin Forms

```php
// ✅ Good: Complete secure form pattern
?>
<form method="post" action="admin.php?page=my_plugin">
    <?php wp_nonce_field( 'save_settings_nonce', 'nonce' ); ?>

    <input
        type="text"
        name="setting_name"
        value="<?php echo esc_attr( get_option( 'setting_name' ) ); ?>"
    />

    <?php submit_button(); ?>
</form>

<?php
if ( isset( $_POST['submit'] ) ) {
    // 1. Check nonce
    check_admin_referer( 'save_settings_nonce', 'nonce' );

    // 2. Check capability
    if ( ! current_user_can( 'manage_options' ) ) {
        wp_die( 'Unauthorized' );
    }

    // 3. Sanitize
    $value = sanitize_text_field( $_POST['setting_name'] );

    // 4. Save
    update_option( 'setting_name', $value );

    echo 'Settings saved';
}
```

## Related Standards

- {{standards/global/validation}} - Input validation patterns
- {{standards/backend/rest-api}} - REST API security
- {{standards/backend/hooks}} - Secure hook implementation
