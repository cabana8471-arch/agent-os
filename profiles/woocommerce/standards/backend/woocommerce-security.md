# WooCommerce Security

WooCommerce security **EXTENDS** {{standards/global/security}} from WordPress. This standard covers e-commerce-specific requirements.

## PCI DSS Compliance

**Never Store Card Data Directly**

PCI DSS Level 1 requires professional security audits if you store card data. Instead:

```php
// WRONG - PCI violation
save_order_meta( $order_id, '_card_number', $_POST['card_number'] );

// CORRECT - Use tokenization
$token = WC_Payment_Tokens::create( [
    'gateway_id' => $gateway_id,
    'token' => $remote_token,  // From payment processor
    'user_id' => $user_id,
] );
```

Always use a PCI-compliant payment processor (Stripe, Square, etc.) for card handling.

## Order Data Security

Orders contain sensitive customer information. Always verify access:

```php
// Verify customer can view their own order
add_action( 'template_redirect', function() {
    if ( is_page( 'view-order' ) ) {
        $order = wc_get_order( get_query_var( 'order-id' ) );

        if ( ! current_user_can( 'view_order', $order->get_id() ) ) {
            wp_safe_remote_post( wc_get_endpoint_url( 'dashboard' ) );
        }
    }
} );

// When retrieving order via REST API
add_filter( 'woocommerce_rest_check_post_permissions', function( $has_access, $post, $action ) {
    if ( 'read' === $action ) {
        $order = wc_get_order( $post->ID );
        return current_user_can( 'view_order', $order->get_id() );
    }
    return $has_access;
}, 10, 3 );
```

## Checkout Security

Always sanitize and validate checkout fields:

```php
add_action( 'woocommerce_checkout_process', function() {
    // Validate custom fields
    if ( empty( $_POST['billing_company_tax_id'] ?? '' ) ) {
        wc_add_notice( 'Tax ID required', 'error' );
    }

    // Validate format
    $tax_id = sanitize_text_field( $_POST['billing_company_tax_id'] ?? '' );
    if ( ! preg_match( '/^\d{11}$/', $tax_id ) ) {
        wc_add_notice( 'Invalid Tax ID format', 'error' );
    }
} );

// Save to order with escaping
add_action( 'woocommerce_checkout_create_order', function( $order, $data ) {
    $tax_id = sanitize_text_field( $data['post_data']['billing_company_tax_id'] ?? '' );
    $order->update_meta_data( '_billing_company_tax_id', $tax_id );
}, 10, 2 );
```

## Customer Data Privacy (GDPR)

WooCommerce provides data export/erasure tools. Ensure custom data is included:

```php
// Export custom order data
add_filter( 'woocommerce_customer_personal_data_exporters', function( $exporters ) {
    $exporters['woocommerce-custom-data'] = [
        'callback' => 'export_custom_data',
        'priority' => 10,
    ];
    return $exporters;
} );

function export_custom_data( $email_address, $page = 1 ) {
    $customer = get_user_by( 'email', $email_address );
    $orders = wc_get_orders( [
        'customer_id' => $customer->ID,
        'limit' => 10,
        'page' => $page,
    ] );

    $data_to_export = [];

    foreach ( $orders as $order ) {
        $custom_field = $order->get_meta( '_custom_field' );
        $data_to_export[] = [
            'name' => 'Custom Field',
            'value' => $custom_field,
        ];
    }

    return [
        'data' => $data_to_export,
        'done' => true,
    ];
}

// Erase custom data on deletion
add_filter( 'woocommerce_customer_personal_data_erasers', function( $erasers ) {
    $erasers['woocommerce-custom-data'] = [
        'callback' => 'erase_custom_data',
        'priority' => 10,
    ];
    return $erasers;
} );

function erase_custom_data( $email_address, $page = 1 ) {
    $customer = get_user_by( 'email', $email_address );
    $orders = wc_get_orders( [
        'customer_id' => $customer->ID,
        'limit' => 10,
        'page' => $page,
    ] );

    foreach ( $orders as $order ) {
        $order->delete_meta_data( '_custom_field' );
        $order->save();
    }

    return [
        'items_removed' => count( $orders ),
        'items_retained' => false,
        'messages' => [ 'Custom data erased' ],
        'done' => true,
    ];
}
```

## Webhook Signature Verification

Always verify webhooks come from the payment processor:

```php
public function handle_webhook() {
    $body = file_get_contents( 'php://input' );
    $signature = $_SERVER['HTTP_X_SIGNATURE'] ?? '';

    // CRITICAL: Verify signature before processing
    if ( ! hash_equals( $this->compute_signature( $body ), $signature ) ) {
        status_header( 401 );
        wp_die( 'Invalid signature' );
    }

    $data = json_decode( $body, true );
    // Process webhook
}

private function compute_signature( $body ) {
    return hash_hmac( 'sha256', $body, $this->secret_key );
}
```

## Admin Access Control

Restrict WooCommerce admin to authorized users:

```php
// Require 2FA for WooCommerce admin
add_action( 'admin_init', function() {
    if ( 'woocommerce_page_wc-admin' !== get_current_screen()->id ) {
        return;
    }

    if ( ! user_has_2fa_enabled( get_current_user_id() ) ) {
        wp_redirect( admin_url( 'admin.php?page=enable-2fa' ) );
        exit;
    }
} );

// Audit admin actions
add_action( 'woocommerce_order_status_changed', function( $order_id, $old_status, $new_status ) {
    error_log( sprintf(
        'Order %d status changed from %s to %s by %s',
        $order_id,
        $old_status,
        $new_status,
        wp_get_current_user()->user_login
    ) );
}, 10, 3 );
```

## SSL/TLS Requirements

Enforce HTTPS for checkout:

```php
// Force HTTPS on checkout
add_action( 'template_redirect', function() {
    if ( is_checkout() && ! is_ssl() ) {
        wp_safe_redirect( 'https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'] );
        exit;
    }
} );

// Verify SSL in payment gateway
public function charge_card( $order ) {
    if ( ! wp_http_validate_url( $this->api_url ) ) {
        return new WP_Error( 'invalid_url', 'Invalid API URL' );
    }

    $response = wp_remote_post( $this->api_url, [
        'sslverify' => true, // CRITICAL: Always verify SSL
        'body' => $charge_data,
    ] );

    return $response;
}
```

## Related Standards

- {{standards/global/security}} - General WordPress security
- {{standards/backend/payment-gateways}} - Payment processing security
- {{standards/backend/orders}} - Order data handling
