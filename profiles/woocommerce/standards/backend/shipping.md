# WooCommerce Shipping

## Shipping Zones & Methods

Shipping zones determine which methods are available in different regions:

```php
// Get all shipping zones
$zones = WC_Shipping_Zones::get_zones();

foreach ( $zones as $zone ) {
    echo $zone['zone_name'];
    echo $zone['zone_locations'];
    echo $zone['zone_id'];
}

// Get zone by ID
$zone = new WC_Shipping_Zone( $zone_id );
echo $zone->get_zone_name();
echo $zone->get_zone_locations();

// Get methods in zone
$methods = $zone->get_shipping_methods();
```

## Built-in Shipping Methods

WooCommerce provides core methods: Flat Rate, Free Shipping, Local Pickup.

### Flat Rate

Fixed price per order or weight-based:

```php
// Enable flat rate $10
add_filter( 'woocommerce_shipping_flat_rate_option', function() {
    return [
        'label' => 'Standard',
        'cost' => 10,
    ];
} );
```

### Free Shipping

Conditional free shipping:

```php
// Free shipping over $50
add_filter( 'woocommerce_shipping_free_shipping_is_available', function( $is_available ) {
    if ( WC()->cart->get_subtotal() > 50 ) {
        return true;
    }
    return $is_available;
} );
```

### Local Pickup

```php
// Enable local pickup
add_filter( 'woocommerce_shipping_methods', function( $methods ) {
    $methods[] = 'WC_Shipping_Local_Pickup';
    return $methods;
} );
```

## Custom Shipping Methods

Extend `WC_Shipping_Method` for custom calculation:

```php
class WC_Shipping_Custom extends WC_Shipping_Method {
    public function __construct() {
        $this->id = 'custom_shipping';
        $this->method_title = 'Custom Method';
        $this->method_description = 'Calculate based on weight';
        $this->enabled = 'yes';
        $this->init();
    }

    public function init() {
        $this->init_form_fields();
        $this->init_settings();
    }

    public function init_form_fields() {
        $this->form_fields = [
            'enabled' => [
                'title' => 'Enable',
                'type' => 'checkbox',
                'default' => 'yes',
            ],
            'cost_per_kg' => [
                'title' => 'Cost Per KG',
                'type' => 'number',
                'default' => 2.00,
            ],
        ];
    }

    public function calculate_shipping( $package = [] ) {
        // $package contains cart contents and destination

        $cost = 0;
        $weight = 0;

        foreach ( $package['contents'] as $item_id => $values ) {
            $weight += $values['data']->get_weight() * $values['quantity'];
        }

        // Calculate based on weight
        $cost = $weight * $this->get_option( 'cost_per_kg' );

        // Add the rate
        $this->add_rate( [
            'id' => $this->id,
            'label' => $this->method_title,
            'cost' => $cost,
        ] );
    }
}

// Register method
add_filter( 'woocommerce_shipping_methods', function( $methods ) {
    $methods['custom_shipping'] = 'WC_Shipping_Custom';
    return $methods;
} );
```

## Shipping Classes

Group products for different rates:

```php
// Get shipping classes
$classes = WC_Shipping_Zones::get_shipping_classes();

// Set product shipping class
$product->set_shipping_class_id( $shipping_class_id );
$product->save();

// Get product shipping class
$shipping_class_id = $product->get_shipping_class_id();
```

Use shipping classes in custom methods:

```php
public function calculate_shipping( $package = [] ) {
    $standard_cost = 5;
    $heavy_cost = 15;

    foreach ( $package['contents'] as $item ) {
        $product = $item['data'];
        $shipping_class = $product->get_shipping_class();

        if ( 'heavy' === $shipping_class ) {
            // Add heavy shipping cost
        }
    }
}
```

## Package Structure

The `$package` array passed to `calculate_shipping()` contains:

```php
$package = [
    'contents' => [
        [
            'product_id' => 123,
            'data' => WC_Product_instance,
            'quantity' => 2,
        ],
    ],
    'contents_cost' => 99.99,
    'applied_coupons' => [ 'SAVE10' ],
    'user' => [
        'ID' => 1,
    ],
    'destination' => [
        'country' => 'US',
        'state' => 'CA',
        'postcode' => '90001',
        'city' => 'Los Angeles',
    ],
];
```

## Shipping Calculations

```php
// Calculate total weight
$weight = 0;
foreach ( WC()->cart->get_cart() as $item ) {
    $weight += $item['data']->get_weight() * $item['quantity'];
}

// Estimate shipping
$packages = WC()->cart->get_shipping_packages();
$rates = WC()->shipping()->calculate_shipping( $packages );
```

## Adding Rates

```php
$this->add_rate( [
    'id' => 'standard',               // Unique ID
    'label' => 'Standard Shipping',   // Customer-facing label
    'cost' => 10.00,                  // Shipping cost
    'taxes' => [ 0 => 0.50 ],        // Tax amount per tax class
    'calc_tax' => 'per_item',        // or 'per_order'
    'package' => $package,            // The package being shipped
] );
```

## Table Rate Shipping

For complex rate tables based on weight, destination, etc:

```php
// Define rate table
$rates = [
    [ 'weight' => 5, 'cost' => 5.00 ],
    [ 'weight' => 10, 'cost' => 8.00 ],
    [ 'weight' => 20, 'cost' => 12.00 ],
];

// Find matching rate
$weight = get_cart_weight();
$applicable_rate = array_filter( $rates, function( $rate ) use ( $weight ) {
    return $weight <= $rate['weight'];
} );

$cost = reset( $applicable_rate )['cost'] ?? 0;
```

## Debugging Shipping

```php
// Log shipping packages
add_action( 'woocommerce_cart_shipping_packages', function( $packages ) {
    error_log( 'Shipping packages: ' . print_r( $packages, true ) );
    return $packages;
} );

// Check available methods
$packages = WC()->cart->get_shipping_packages();
$rates = WC()->shipping()->calculate_shipping( $packages );

foreach ( $rates as $index => $package_rates ) {
    foreach ( $package_rates as $rate_id => $rate ) {
        error_log( 'Rate: ' . $rate->get_label() . ' = ' . $rate->get_cost() );
    }
}
```

## Related Standards

- {{standards/backend/woocommerce-hooks}} - Shipping hooks
- {{standards/backend/cart-checkout}} - Cart and shipping together
- {{standards/backend/products}} - Product weight and classes
