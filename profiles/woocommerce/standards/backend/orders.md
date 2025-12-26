# WooCommerce Orders

## Order Lifecycle

WooCommerce orders follow a standard lifecycle with statuses:

- `pending` - Awaiting payment
- `processing` - Payment received, awaiting fulfillment
- `completed` - Order fulfilled
- `cancelled` - Customer cancelled
- `refunded` - Full refund issued
- `failed` - Payment failed
- `on-hold` - Awaiting action

## Creating Orders Programmatically

```php
$order = wc_create_order();
$order->set_address( [
    'first_name' => 'John',
    'last_name' => 'Doe',
    'email' => 'john@example.com',
    'address_1' => '123 Main St',
    'city' => 'New York',
    'state' => 'NY',
    'postcode' => '10001',
    'country' => 'US',
], 'billing' );

// Add product to order
$product_id = 123;
$quantity = 2;
$order->add_product( wc_get_product( $product_id ), $quantity );

// Set totals
$order->calculate_totals();

// Set status
$order->set_status( 'processing' );
$order->save();
```

## Order CRUD Operations

```php
// Get order
$order = wc_get_order( $order_id );

// Update order data
$order->set_billing_email( 'new@example.com' );
$order->set_status( 'completed' );
$order->save();

// Delete order
$order->delete( true ); // true = permanently delete
```

## Order Meta Data

```php
$order = wc_get_order( $order_id );

// Set custom meta
$order->update_meta_data( '_custom_field', 'value' );
$order->save();

// Get custom meta
$value = $order->get_meta( '_custom_field' );

// List all meta data
$meta_data = $order->get_meta_data();
```

## Order Items

Orders contain line items (products, fees, shipping, taxes):

```php
$order = wc_get_order( $order_id );

// Get all items
$items = $order->get_items();

foreach ( $items as $item_id => $item ) {
    echo $item->get_name(); // Product name
    echo $item->get_quantity();
    echo $item->get_total();
}

// Add custom item
$item = new WC_Order_Item_Product();
$item->set_product_id( $product_id );
$item->set_quantity( 1 );
$item->set_total( 29.99 );
$order->add_item( $item );
```

## Order Status Changes

```php
$order = wc_get_order( $order_id );

// Change status (triggers hooks)
$order->set_status( 'completed' );
$order->save();

// Or use action directly (preferred for bulk operations)
do_action( 'woocommerce_order_status_changed', $order_id, 'processing', 'completed' );
```

## Order Queries

Get orders efficiently:

```php
$args = [
    'limit' => 10,
    'status' => 'processing',
    'orderby' => 'date',
    'order' => 'DESC',
];

$orders = wc_get_orders( $args );

foreach ( $orders as $order ) {
    echo $order->get_id();
    echo $order->get_total();
}
```

**Performance**: Use `wc_get_orders()` with status filter instead of `WP_Query`.

## Order Totals

```php
$order = wc_get_order( $order_id );

$order->get_subtotal();      // Before fees/taxes
$order->get_total_tax();     // Tax amount
$order->get_shipping_total(); // Shipping cost
$order->get_total();          // Final total
```

## Refunds

```php
$order = wc_get_order( $order_id );

// Create full refund
$order->add_refund( [
    'amount' => $order->get_total(),
    'reason' => 'Customer request',
    'order_id' => $order_id,
] );

// Partial refund
$refund = $order->add_refund( [
    'amount' => 10.00,
    'reason' => 'Partial refund',
    'order_id' => $order_id,
] );

if ( is_wp_error( $refund ) ) {
    error_log( $refund->get_error_message() );
}
```

## Related Standards

- {{standards/backend/hooks}} - Order status hooks (woocommerce_order_status_changed, etc.)
- {{standards/backend/woocommerce-security}} - Order data security and customer privacy
- {{standards/backend/payment-gateways}} - Payment processing for orders
