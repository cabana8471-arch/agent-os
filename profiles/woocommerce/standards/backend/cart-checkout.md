# WooCommerce Cart & Checkout

## Cart Operations

Access the cart singleton via `WC()->cart`:

```php
// Get cart instance
$cart = WC()->cart;

// Get cart items
$items = $cart->get_cart();

foreach ( $items as $item_key => $item ) {
    echo $item['product_id'];
    echo $item['quantity'];
    echo $item['line_total'];
}

// Cart totals
$cart->get_subtotal();
$cart->get_total_tax();
$cart->get_total();

// Empty cart
$cart->empty_cart();
```

## Adding Items to Cart

```php
// Add simple product
WC()->cart->add_to_cart( $product_id, $quantity );

// Add variable product with selected attributes
WC()->cart->add_to_cart( $parent_product_id, $quantity, $variation_id, [
    'attribute_size' => 'M',
    'attribute_color' => 'Blue',
] );

// Add with custom cart item data
WC()->cart->add_to_cart( $product_id, 1, 0, [], [
    '_custom_field' => 'Custom Value',
] );

// Check if item added successfully
$result = WC()->cart->add_to_cart( $product_id, 1 );
if ( ! $result ) {
    wc_add_notice( 'Could not add to cart', 'error' );
}
```

## Cart Item Management

```php
// Get specific cart item
$cart = WC()->cart;
$item = $cart->get_cart_item( $item_key );

// Update quantity
$cart->set_quantity( $item_key, 5 );

// Remove item
$cart->remove_cart_item( $item_key );

// Get item by product ID
$item_keys = array_filter( array_keys( $cart->get_cart() ), function( $key ) use ( $product_id ) {
    return $cart->get_cart()[ $key ]['product_id'] === $product_id;
} );
```

## Cart Validation

Validate items before allowing checkout:

```php
// Validate all cart items
add_action( 'woocommerce_check_cart_items', function() {
    foreach ( WC()->cart->get_cart() as $item ) {
        $product = $item['data'];

        // Check inventory
        if ( $item['quantity'] > $product->get_stock_quantity() ) {
            wc_add_notice( 'Not enough stock', 'error' );
        }

        // Custom validation
        if ( ! user_can_buy_product( $product ) ) {
            wc_add_notice( 'You cannot purchase this product', 'error' );
        }
    }
} );

// Prevent checkout if errors
if ( wc_notice_count( 'error' ) > 0 ) {
    return false;
}
```

## Checkout Fields

### Add Custom Fields

```php
add_filter( 'woocommerce_checkout_fields', function( $fields ) {
    // Add field to billing section
    $fields['billing']['billing_company_id'] = [
        'type' => 'text',
        'label' => 'Company ID',
        'placeholder' => 'Enter your company ID',
        'required' => false,
        'class' => [ 'form-row-wide' ],
        'clear' => true,
    ];

    // Remove unnecessary fields
    unset( $fields['billing']['billing_postcode'] );

    return $fields;
} );
```

### Validate Custom Fields

```php
add_action( 'woocommerce_checkout_process', function() {
    // Validate required custom field
    if ( empty( $_POST['post_data']['billing_company_id'] ?? '' ) ) {
        wc_add_notice( 'Company ID is required', 'error' );
    }

    // Validate format
    $company_id = sanitize_text_field( $_POST['post_data']['billing_company_id'] ?? '' );
    if ( ! preg_match( '/^[A-Z0-9]{6,}$/', $company_id ) ) {
        wc_add_notice( 'Invalid Company ID format', 'error' );
    }
} );
```

### Save Custom Fields to Order

```php
add_action( 'woocommerce_checkout_create_order', function( $order, $data ) {
    if ( isset( $data['post_data']['billing_company_id'] ) ) {
        $company_id = sanitize_text_field( $data['post_data']['billing_company_id'] );
        $order->update_meta_data( '_billing_company_id', $company_id );
    }
}, 10, 2 );
```

## Checkout Fees

Add dynamic fees to cart:

```php
add_action( 'woocommerce_cart_calculate_fees', function() {
    if ( is_admin() && ! defined( 'DOING_AJAX' ) ) {
        return;
    }

    // Add fee based on cart value
    if ( WC()->cart->get_subtotal() > 100 ) {
        WC()->cart->add_fee( 'Express Shipping', 15.00 );
    }

    // Add fee if gift wrapping selected
    if ( isset( $_POST['post_data']['gift_wrap'] ) && 'yes' === $_POST['post_data']['gift_wrap'] ) {
        WC()->cart->add_fee( 'Gift Wrapping', 5.00 );
    }
} );
```

## Checkout Process Flow

```
1. Display checkout form
   ↓
2. User submits form
   ↓
3. woocommerce_checkout_process - Validate
   ↓
4. woocommerce_checkout_create_order - Create order object
   ↓
5. woocommerce_new_order - Process payment
   ↓
6. woocommerce_checkout_order_processed - Post-payment actions
   ↓
7. woocommerce_thankyou - Display thank you page
```

## Cart Fragments (AJAX)

Update cart display without page reload:

```php
// Return cart fragment for AJAX updates
add_filter( 'woocommerce_add_to_cart_fragments', function( $fragments ) {
    ob_start();
    ?>
    <a class="cart-contents" href="<?php echo esc_url( wc_get_cart_url() ); ?>">
        <?php echo WC()->cart->get_cart_contents_count(); ?> items
    </a>
    <?php
    $fragments['a.cart-contents'] = ob_get_clean();
    return $fragments;
} );
```

## Coupon Integration

```php
// Apply coupon
WC()->cart->apply_coupon( 'SAVE10' );

// Remove coupon
WC()->cart->remove_coupon( 'SAVE10' );

// Validate coupon
$coupon = new WC_Coupon( 'SAVE10' );
if ( ! $coupon->is_valid() ) {
    wc_add_notice( 'Invalid coupon', 'error' );
}

// Get applied coupons
$coupons = WC()->cart->get_applied_coupons();
```

## Related Standards

- {{standards/backend/woocommerce-hooks}} - Cart and checkout hooks
- {{standards/backend/payment-gateways}} - Payment processing
- {{standards/backend/woocommerce-security}} - Validation and security
