# WooCommerce Hooks Reference

WooCommerce provides action and filter hooks throughout the shopping experience. Always extend functionality using hooks rather than modifying core files.

## Product Hooks

### Before/After Add to Cart

```php
// Before product added to cart
add_action( 'woocommerce_before_add_to_cart', function() {
    echo 'Adding to cart...';
} );

// After product added to cart
add_action( 'woocommerce_after_add_to_cart_button', function() {
    echo 'Or subscribe instead';
} );

// Validate before adding to cart
add_filter( 'woocommerce_add_to_cart_validation', function( $passed, $product_id, $quantity ) {
    if ( ! user_can_purchase( $product_id ) ) {
        return false;
    }
    return $passed;
}, 10, 3 );
```

### Product Display

```php
// Before product title
add_action( 'woocommerce_single_product_summary', function() {
    echo 'Limited offer!';
}, 4 );

// After product summary
add_action( 'woocommerce_after_single_product_summary', function() {
    // Show related products, reviews, etc
}, 20 );

// Filter product price display
add_filter( 'woocommerce_get_price_html', function( $price, $product ) {
    if ( user_is_vip() ) {
        $price = '<span class="vip">' . $price . '</span>';
    }
    return $price;
}, 10, 2 );
```

## Cart Hooks

### Cart Operations

```php
// After product added to cart
add_action( 'woocommerce_add_to_cart', function( $cart_item_key, $product_id, $quantity, $variation_id, $variation, $cart_item_data ) {
    do_something_with_cart_item();
}, 10, 6 );

// Before cart totals calculated
add_action( 'woocommerce_cart_calculate_fees', function() {
    if ( WC()->cart->get_subtotal() > 100 ) {
        WC()->cart->add_fee( 'Rush Fee', 5.00 );
    }
} );

// After cart contents updated
add_action( 'woocommerce_cart_updated', function() {
    update_related_data();
} );
```

### Cart Contents

```php
// Modify cart item data
add_filter( 'woocommerce_cart_item_product', function( $product, $cart_item, $cart_item_key ) {
    // Modify product data for cart display
    return $product;
}, 10, 3 );

// Filter cart contents
add_filter( 'woocommerce_get_cart_contents', function( $cart_contents ) {
    // Validate or modify items before checkout
    return $cart_contents;
} );
```

## Checkout Hooks

### Checkout Process

```php
// Validate checkout data
add_action( 'woocommerce_checkout_process', function() {
    if ( ! validate_custom_requirements() ) {
        wc_add_notice( 'Please check your details', 'error' );
    }
} );

// After order placed
add_action( 'woocommerce_checkout_order_processed', function( $order_id, $posted_data, $order ) {
    // Send to external system, create invoice, etc
}, 10, 3 );

// After successful order
add_action( 'woocommerce_thankyou', function( $order_id ) {
    $order = wc_get_order( $order_id );
    // Track conversion, send confirmation, etc
} );
```

### Checkout Fields

```php
// Add custom checkout field
add_filter( 'woocommerce_checkout_fields', function( $fields ) {
    $fields['billing']['company_tax_id'] = [
        'type' => 'text',
        'label' => 'Tax ID',
        'required' => false,
    ];
    return $fields;
} );

// Validate custom checkout field
add_action( 'woocommerce_checkout_process', function() {
    if ( empty( $_POST['post_data']['billing_company_tax_id'] ?? '' ) ) {
        wc_add_notice( 'Tax ID is required', 'error' );
    }
} );

// Save custom field to order
add_action( 'woocommerce_checkout_create_order', function( $order, $data ) {
    if ( isset( $data['post_data']['billing_company_tax_id'] ) ) {
        $order->update_meta_data( '_billing_company_tax_id', $data['post_data']['billing_company_tax_id'] );
    }
}, 10, 2 );
```

## Order Hooks

### Order Status Changes

```php
// When order status changes
add_action( 'woocommerce_order_status_changed', function( $order_id, $old_status, $new_status, $order ) {
    if ( 'completed' === $new_status ) {
        // Trigger fulfillment
        send_to_warehouse( $order );
    }
}, 10, 4 );

// After order created
add_action( 'woocommerce_new_order', function( $order_id, $order ) {
    // Log to external system
    log_order_created( $order );
}, 10, 2 );

// When order payment completes
add_action( 'woocommerce_payment_complete', function( $order_id ) {
    $order = wc_get_order( $order_id );
    notify_customer_payment_received( $order );
} );
```

## Email Hooks

```php
// Modify email content
add_filter( 'woocommerce_email_subject_customer_completed_order', function( $subject, $order ) {
    return 'Your ' . $order->get_billing_company() . ' order is ready!';
}, 10, 2 );

// Add content to emails
add_action( 'woocommerce_email_customer_details', function( $order, $sent_to_admin, $plain_text, $email ) {
    if ( ! $plain_text ) {
        echo '<p>Thank you for your order!</p>';
    }
}, 10, 4 );

// Control which emails are sent
add_filter( 'woocommerce_email_enabled_customer_note_notification', function( $enabled, $email ) {
    // Disable note notifications for wholesale customers
    if ( customer_is_wholesale() ) {
        return false;
    }
    return $enabled;
}, 10, 2 );
```

## Common Hook Patterns

### Check User Role Before Hook

```php
add_action( 'woocommerce_checkout_process', function() {
    if ( current_user_can( 'manage_options' ) ) {
        return; // Skip for admins
    }
    // Validation logic for customers
} );
```

### Conditional Execution

```php
add_action( 'woocommerce_thankyou', function( $order_id ) {
    $order = wc_get_order( $order_id );

    // Only process certain payment methods
    if ( 'stripe' !== $order->get_payment_method() ) {
        return;
    }

    do_stripe_specific_action();
} );
```

### Getting Hook Data

```php
// Hook passes specific data - always check what's available
add_action( 'woocommerce_add_to_cart', function( $cart_item_key, $product_id, $quantity ) {
    error_log( 'Added to cart: ' . print_r( [
        'key' => $cart_item_key,
        'product_id' => $product_id,
        'quantity' => $quantity,
    ], true ) );
}, 10, 3 );
```

## Related Standards

- {{standards/backend/hooks}} - General WordPress hook patterns
- {{standards/backend/orders}} - Order processing and hooks
- {{standards/backend/products}} - Product-related hooks
