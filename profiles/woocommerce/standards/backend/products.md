# WooCommerce Products

## Product Types

WooCommerce supports multiple product types through the `WC_Product` class hierarchy:

### Simple Products
Single items with one price, no variations.

```php
$product = wc_get_product( $product_id );
$product->get_price();
$product->get_stock_quantity();
```

### Variable Products
Products with variations (size, color, etc.). Each variation is a separate post.

```php
$product = wc_get_product( $product_id );
$variations = $product->get_children();

foreach ( $variations as $variation_id ) {
    $variation = wc_get_product( $variation_id );
    $attributes = $variation->get_attributes();
}
```

### Grouped Products
Bundles of simple products sold together.

```php
$product = wc_get_product( $product_id );
$children = $product->get_children();
```

### External/Affiliate Products
Products linking to external stores.

```php
$product = wc_get_product( $product_id );
$external_url = $product->get_product_url();
```

## Creating Products Programmatically

```php
$product = new WC_Product_Simple();
$product->set_name( 'Product Name' );
$product->set_description( 'Description' );
$product->set_short_description( 'Short desc' );
$product->set_regular_price( '29.99' );
$product->set_stock_quantity( 100 );
$product->set_manage_stock( true );
$product->set_status( 'publish' );
$product->save();
```

## Product Meta Data

Store custom product data using WooCommerce meta system (not WordPress post meta):

```php
$product = wc_get_product( $product_id );

// Set custom meta
$product->update_meta_data( '_custom_key', 'value' );
$product->save();

// Get custom meta
$value = $product->get_meta( '_custom_key' );
```

**Convention**: Prefix custom meta keys with underscore: `_manufacturer_code`

## Product Attributes & Variations

```php
// Get product attributes
$attributes = $product->get_attributes();

// Create variation
$variation = new WC_Product_Variation();
$variation->set_parent_id( $parent_id );
$variation->set_attributes( [ 'size' => 'M', 'color' => 'Blue' ] );
$variation->set_regular_price( '29.99' );
$variation->save();
```

## SKU Management

```php
// Set SKU (must be unique)
$product->set_sku( 'PROD-001' );
$product->save();

// Get product by SKU
$product = wc_get_product( wc_get_product_id_by_sku( 'PROD-001' ) );
```

**Important**: SKU must be unique across all products. Check uniqueness before saving:

```php
$existing = wc_get_product_id_by_sku( $sku );
if ( $existing && $existing !== $product_id ) {
    wp_die( 'SKU already exists' );
}
```

## Stock Management

```php
$product = wc_get_product( $product_id );

// Update stock
$product->set_stock_quantity( 50 );
$product->set_manage_stock( true );
$product->save();

// Reduce stock on order
wc_reduce_stock_levels( $order_id );

// Check if in stock
if ( $product->is_in_stock() ) {
    // Show buy button
}
```

## Product Queries

Use `wc_get_products()` instead of `WP_Query` for better performance:

```php
$products = wc_get_products( [
    'status' => 'publish',
    'type' => 'simple',
    'limit' => 10,
    'orderby' => 'date',
    'order' => 'DESC',
] );

foreach ( $products as $product ) {
    echo $product->get_name();
}
```

**Performance**: Always specify `type` to limit query scope. Avoid using `WP_Query` directly.

## Related Standards

- {{standards/backend/hooks}} - Product hooks (woocommerce_before_add_to_cart, etc.)
- {{standards/backend/post-types-taxonomies}} - Product custom post type structure
- {{standards/global/security}} - Data validation and escaping for products
