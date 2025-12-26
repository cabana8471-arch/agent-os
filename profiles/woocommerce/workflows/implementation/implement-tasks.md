# WooCommerce Task Implementation

## Pre-Implementation Setup

Before implementing WooCommerce customizations:

- ✅ Local WordPress with WooCommerce installed
- ✅ Test products created for testing
- ✅ Test orders created or payment gateway configured
- ✅ WP-CLI installed for verification commands
- ✅ Database backup created
- ✅ Understand the task requirements completely
- ✅ Payment/shipping sandbox accounts ready (if applicable)

## Development Environment Verification

```bash
# Verify WooCommerce is active
wp plugin is-active woocommerce

# Check WooCommerce version
wp wc product list

# Test WP-CLI WooCommerce support
wp wc shop_order list

# Verify checkout is functional
# Visit /checkout in browser - no errors should appear
```

## WooCommerce Implementation Pattern

### 1. Understand the Existing Data

```bash
# Check existing products
wp wc product list --format=csv

# Check existing orders
wp wc order list --format=csv

# Check active payment gateways
wp option get woocommerce_enabled_payment_gateways

# Check shipping zones
wp wc shipping_zone list
```

### 2. Create Customization File

Place customizations in theme or plugin:

```php
// wp-content/themes/child-theme/woocommerce-customizations.php
// OR wp-content/plugins/my-plugin/woocommerce-hooks.php

defined( 'ABSPATH' ) || exit;

// Add hooks
add_action( 'woocommerce_new_order', function( $order_id ) {
    // Custom order processing
} );
```

### 3. Register Custom Post Meta (if needed)

```php
add_action( 'init', function() {
    register_post_meta( 'shop_order', '_custom_field', [
        'show_in_rest' => true,
        'single' => true,
        'type' => 'string',
        'auth_callback' => function() {
            return current_user_can( 'manage_options' );
        },
    ] );
} );
```

### 4. Test Thoroughly

```bash
# Test product operations
wp wc product create --name="Test Product" --price=29.99 --status=publish

# Test order operations
wp wc order list

# Test payment gateway (if implemented)
# Create test order manually in dashboard
# Use payment gateway test/sandbox mode
```

### 5. Verify No Errors

```bash
# Check for PHP errors
wp eval 'echo "WordPress OK";'

# Check WooCommerce status report
# Visit: /wp-admin/admin.php?page=wc-status

# Check debug.log (if WP_DEBUG enabled)
tail -50 wp-content/debug.log
```

## Common Implementation Tasks

### Add Custom Order Field

```php
// Step 1: Register meta
add_action( 'init', function() {
    register_post_meta( 'shop_order', '_custom_field', [
        'show_in_rest' => true,
        'single' => true,
    ] );
} );

// Step 2: Add to checkout
add_filter( 'woocommerce_checkout_fields', function( $fields ) {
    $fields['order']['order_custom_field'] = [
        'type' => 'text',
        'label' => 'Custom Field',
        'required' => false,
    ];
    return $fields;
} );

// Step 3: Save to order
add_action( 'woocommerce_checkout_create_order', function( $order, $data ) {
    if ( isset( $data['post_data']['order_custom_field'] ) ) {
        $order->update_meta_data( '_custom_field', $data['post_data']['order_custom_field'] );
    }
}, 10, 2 );

// Step 4: Verify
wp wc order get 123 --field=meta_data
```

### Create Custom Shipping Method

```php
// Step 1: Create class
class WC_Shipping_Custom extends WC_Shipping_Method {
    public function __construct() {
        $this->id = 'custom_shipping';
        $this->method_title = 'Custom';
    }

    public function calculate_shipping( $package = [] ) {
        $this->add_rate( [
            'id' => $this->id,
            'label' => 'Custom Shipping',
            'cost' => 10,
        ] );
    }
}

// Step 2: Register
add_filter( 'woocommerce_shipping_methods', function( $methods ) {
    $methods['custom_shipping'] = 'WC_Shipping_Custom';
    return $methods;
} );

// Step 3: Test on checkout
// Visit /checkout in browser
// Verify custom shipping method appears
```

### Process Order Programmatically

```php
// Create order
$order = wc_create_order();
$order->add_product( wc_get_product( 123 ), 1 );
$order->set_total( 29.99 );
$order->set_status( 'processing' );
$order->save();

// Verify
wp wc order get <order_id> --format=json
```

## Self-Verification Checklist

After implementation, verify:

- ✅ **No PHP Errors**: `wp eval 'echo "OK";'`
- ✅ **WooCommerce Status**: Check /wp-admin/admin.php?page=wc-status
- ✅ **Product Operations**: `wp wc product list`
- ✅ **Order Operations**: `wp wc order list`
- ✅ **Checkout Works**: Visit /checkout in browser
- ✅ **Payment Processing**: Test payment gateway (use sandbox)
- ✅ **Hooks Fire**: Check error_log for hook execution
- ✅ **Data Persists**: Create test data, reload page
- ✅ **REST API Works**: `wp wc product list` via API
- ✅ **Shipping Calculates**: Test on checkout page

## Useful WP-CLI Commands

```bash
# Products
wp wc product list
wp wc product get 123
wp wc product create --name="Product"
wp wc product update 123 --price=49.99

# Orders
wp wc order list
wp wc order get 123 --format=json
wp wc order create --customer_id=1 --status=processing
wp wc order update 123 --status=completed

# Customers
wp wc customer list
wp wc customer get 1

# Categories
wp wc product_cat list

# Shipping
wp wc shipping_zone list

# Admin operations
wp wc shop_settings get woocommerce_currency
```

## Debugging Tips

```php
// Log order operations
add_action( 'woocommerce_new_order', function( $order_id ) {
    error_log( 'New order: ' . $order_id );
} );

// Log hook execution
add_action( 'woocommerce_cart_calculate_fees', function() {
    error_log( 'Cart fees calculated' );
} );

// Inspect order data
add_action( 'woocommerce_order_status_changed', function( $order_id ) {
    $order = wc_get_order( $order_id );
    error_log( 'Order data: ' . print_r( $order->get_data(), true ) );
}, 10, 1 );
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Hook not firing | Check hook name spelling, use `do_action` test |
| Meta not saving | Verify meta key registered, check sanitization |
| Payment fails silently | Enable WP_DEBUG, check gateway logs |
| Order not created | Check validation, look at woocommerce_checkout_process |
| Shipping not showing | Verify shipping zone, check calculate_shipping logic |
| REST API 403 error | Check API key permissions, verify authentication |

## Related Standards

- {{standards/backend/hooks}} - Hook implementation
- {{standards/backend/woocommerce-hooks}} - WooCommerce-specific hooks
- {{standards/backend/payment-gateways}} - Payment implementation
- {{standards/backend/orders}} - Order processing
- {{standards/backend/products}} - Product operations
