# WordPress Validation

## Validation vs Sanitization vs Escaping

Three distinct security operations, not interchangeable:

| Operation | When | What | Example |
|-----------|------|------|---------|
| **Validation** | Input arrives | Check if valid, reject if not | Is this a valid email? |
| **Sanitization** | Before saving | Clean data to safe format | Remove HTML tags from text |
| **Escaping** | Before output | Prepare for safe display | HTML-encode special chars |

```php
// ✅ Good: Validate before save, escape on display
$email = $_POST['email']; // Raw input

// Validate
if ( ! is_email( $email ) ) {
    return new WP_Error( 'invalid_email', 'Email is invalid' );
}

// Sanitize (clean to safe format)
$email = sanitize_email( $email );

// Save
update_user_meta( $user_id, 'email', $email );

// Retrieve and escape on display
$stored_email = get_user_meta( $user_id, 'email', true );
echo esc_html( $stored_email );
```

## Input Validation Functions

### Email Validation

```php
// ✅ Good: is_email() checks format
if ( ! is_email( $_POST['email'] ) ) {
    $errors[] = 'Invalid email address';
}

// ✅ Good: wp_safe_remote_post (for API emails)
$response = wp_safe_remote_post( $url );
```

### URL Validation

```php
// ✅ Good: wp_http_validate_url()
$url = $_POST['website'];
if ( ! wp_http_validate_url( $url ) ) {
    return new WP_Error( 'invalid_url', 'Invalid URL' );
}

// ✅ Good: For basic validation
if ( filter_var( $url, FILTER_VALIDATE_URL ) === false ) {
    $errors[] = 'Invalid URL';
}
```

### Integer Validation

```php
// ✅ Good: absint() for integers
$count = absint( $_POST['count'] );

// ✅ Good: is_numeric()
if ( ! is_numeric( $_POST['id'] ) ) {
    return new WP_Error( 'invalid_id' );
}

// ✅ Good: Explicit range check
if ( intval( $_POST['age'] ) < 0 || intval( $_POST['age'] ) > 150 ) {
    $errors[] = 'Age must be between 0 and 150';
}
```

### Boolean Validation

```php
// ✅ Good: Explicit boolean check
$is_featured = ( isset( $_POST['featured'] ) && $_POST['featured'] === '1' );

// ✅ Good: Filter for on/off strings
$enabled = filter_var( $_POST['enabled'], FILTER_VALIDATE_BOOLEAN );
```

## Sanitization Functions

### Text Sanitization

```php
// ✅ Good: Basic text (removes HTML)
$title = sanitize_text_field( $_POST['title'] );

// ✅ Good: Title format (removes special chars)
$slug = sanitize_title( $_POST['slug'] );

// ✅ Good: Filename safe
$filename = sanitize_file_name( $_POST['filename'] );

// ✅ Good: HTML content (allows safe tags)
$content = wp_kses_post( $_POST['content'] );

// ✅ Good: Allowed HTML tags (custom whitelist)
$bio = wp_kses(
    $_POST['bio'],
    [
        'p'      => [],
        'strong' => [],
        'em'     => [],
        'a'      => [ 'href' => [] ]
    ]
);

// ❌ Avoid: No sanitization
$title = $_POST['title'];
```

### Email Sanitization

```php
// ✅ Good: Sanitize email format
$email = sanitize_email( $_POST['email'] );
```

### URL Sanitization

```php
// ✅ Good: Sanitize URL
$url = esc_url_raw( $_POST['url'] );
// Use esc_url_raw for database, esc_url for HTML output
```

### Integer Sanitization

```php
// ✅ Good: Convert to integer
$id = intval( $_POST['id'] );

// ✅ Good: Absolute integer (positive)
$count = absint( $_POST['count'] );
```

## Settings API Validation

WordPress Settings API automatically sanitizes/validates with callbacks:

```php
// ✅ Good: Register setting with sanitization
register_setting(
    'my_settings_group',
    'my_text_option',
    [
        'type'              => 'string',
        'sanitize_callback' => 'sanitize_text_field',
        'show_in_rest'      => true
    ]
);

// ✅ Good: Multiple options
register_setting(
    'my_settings_group',
    'user_roles',
    [
        'type'              => 'array',
        'sanitize_callback' => function( $input ) {
            if ( ! is_array( $input ) ) {
                return [];
            }
            return array_map( 'sanitize_text_field', $input );
        }
    ]
);

// ✅ Good: With validation callback
register_setting(
    'my_settings_group',
    'min_age',
    [
        'type'              => 'integer',
        'sanitize_callback' => 'absint',
        'validate_callback' => function( $value ) {
            if ( $value < 0 ) {
                return new WP_Error(
                    'invalid_age',
                    'Age must be positive'
                );
            }
            return true;
        }
    ]
);
```

## REST API Validation

```php
// ✅ Good: Complete REST endpoint with validation
register_rest_route(
    'myapp/v1',
    '/users',
    [
        'methods'  => 'POST',
        'callback' => 'create_user_via_api',
        'args'     => [
            'email' => [
                'type'              => 'string',
                'format'            => 'email',
                'sanitize_callback' => 'sanitize_email',
                'validate_callback' => function( $param ) {
                    return is_email( $param );
                },
                'required'          => true
            ],
            'name' => [
                'type'              => 'string',
                'sanitize_callback' => 'sanitize_text_field',
                'validate_callback' => function( $param ) {
                    return strlen( $param ) >= 2;
                }
            ],
            'age' => [
                'type'              => 'integer',
                'sanitize_callback' => 'absint',
                'validate_callback' => function( $param ) {
                    return $param >= 18 && $param <= 150;
                }
            ]
        ],
        'permission_callback' => function() {
            return current_user_can( 'create_users' );
        }
    ]
);

function create_user_via_api( WP_REST_Request $request ) {
    $params = $request->get_json_params();

    // Validation already done by REST API
    // Just process validated, sanitized data
    $user_id = wp_create_user(
        sanitize_text_field( $params['name'] ),
        wp_generate_password(),
        $params['email']
    );

    if ( is_wp_error( $user_id ) ) {
        return $user_id;
    }

    return [ 'id' => $user_id, 'created' => true ];
}
```

## Custom Validation

```php
// ✅ Good: Custom validation function
function validate_phone_number( $phone ) {
    // Remove non-numeric
    $phone = preg_replace( '/\D/', '', $phone );

    // Check length (US format: 10 digits)
    if ( strlen( $phone ) !== 10 ) {
        return false;
    }

    return $phone;
}

// Usage
$phone = validate_phone_number( $_POST['phone'] );
if ( ! $phone ) {
    $errors[] = 'Invalid phone number';
}

// ✅ Good: Validate arrays
function validate_form_input( $data ) {
    $errors = [];

    if ( empty( $data['name'] ) || strlen( $data['name'] ) < 2 ) {
        $errors['name'] = 'Name too short';
    }

    if ( ! is_email( $data['email'] ) ) {
        $errors['email'] = 'Invalid email';
    }

    if ( empty( $data['message'] ) ) {
        $errors['message'] = 'Message required';
    }

    return ! empty( $errors ) ? $errors : null;
}

$errors = validate_form_input( $_POST );
if ( $errors ) {
    // Show errors
    return;
}
```

## WP_Error Usage

```php
// ✅ Good: Return WP_Error for validation failures
function process_user_data( $data ) {
    if ( empty( $data['email'] ) ) {
        return new WP_Error(
            'missing_email',
            'Email is required'
        );
    }

    if ( ! is_email( $data['email'] ) ) {
        return new WP_Error(
            'invalid_email',
            'Email format is invalid',
            [ 'status' => 400 ]
        );
    }

    // Process if valid
    return [ 'success' => true ];
}

// ✅ Good: Check for errors
$result = process_user_data( $_POST );
if ( is_wp_error( $result ) ) {
    echo 'Error: ' . $result->get_error_message();
    return;
}
```

## Data Type Validation

```php
// ✅ Good: Type checking
function expects_string( $value ) {
    if ( ! is_string( $value ) ) {
        return new WP_Error( 'invalid_type', 'Expected string' );
    }
}

function expects_array( $value ) {
    if ( ! is_array( $value ) ) {
        return new WP_Error( 'invalid_type', 'Expected array' );
    }
}

function expects_integer( $value ) {
    if ( ! is_int( $value ) ) {
        $value = intval( $value );
    }
    return $value;
}
```

## Form Validation Pattern

Complete example combining all concepts:

```php
function handle_contact_form() {
    // 1. Check nonce
    check_admin_referer( 'contact_form_nonce', 'nonce' );

    // 2. Check capability
    if ( ! current_user_can( 'edit_posts' ) ) {
        wp_die( 'Unauthorized' );
    }

    // 3. Validate inputs
    $errors = [];

    if ( empty( $_POST['name'] ) ) {
        $errors['name'] = 'Name is required';
    } elseif ( strlen( $_POST['name'] ) < 2 ) {
        $errors['name'] = 'Name too short';
    }

    if ( empty( $_POST['email'] ) ) {
        $errors['email'] = 'Email is required';
    } elseif ( ! is_email( $_POST['email'] ) ) {
        $errors['email'] = 'Invalid email format';
    }

    if ( empty( $_POST['message'] ) ) {
        $errors['message'] = 'Message is required';
    } elseif ( strlen( $_POST['message'] ) < 10 ) {
        $errors['message'] = 'Message too short';
    }

    // 4. If errors, return with messages
    if ( ! empty( $errors ) ) {
        return $errors; // Handle display elsewhere
    }

    // 5. Sanitize valid inputs
    $name    = sanitize_text_field( $_POST['name'] );
    $email   = sanitize_email( $_POST['email'] );
    $message = wp_kses_post( $_POST['message'] );

    // 6. Save or process
    wp_insert_post( [
        'post_type'    => 'contact_submission',
        'post_title'   => $name,
        'post_content' => $message,
        'post_status'  => 'pending'
    ] );

    // Success
    return [ 'success' => 'Message sent' ];
}
```

## Related Standards

- {{standards/global/security}} - Nonces, escaping, capabilities
- {{standards/backend/rest-api}} - REST API validation
- {{standards/backend/plugins}} - Plugin security patterns
