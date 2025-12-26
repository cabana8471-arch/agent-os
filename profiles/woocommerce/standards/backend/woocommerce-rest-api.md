# WooCommerce REST API

WooCommerce provides a complete REST API v3 for programmatic access to products, orders, customers, and more.

## Core Endpoints

### Products

```
GET /wp-json/wc/v3/products                    - List products
GET /wp-json/wc/v3/products/{id}              - Get product
POST /wp-json/wc/v3/products                   - Create product
PUT /wp-json/wc/v3/products/{id}              - Update product
DELETE /wp-json/wc/v3/products/{id}           - Delete product
```

### Orders

```
GET /wp-json/wc/v3/orders                     - List orders
GET /wp-json/wc/v3/orders/{id}                - Get order
POST /wp-json/wc/v3/orders                    - Create order
PUT /wp-json/wc/v3/orders/{id}                - Update order
DELETE /wp-json/wc/v3/orders/{id}             - Delete order
```

### Customers

```
GET /wp-json/wc/v3/customers                  - List customers
GET /wp-json/wc/v3/customers/{id}             - Get customer
POST /wp-json/wc/v3/customers                 - Create customer
PUT /wp-json/wc/v3/customers/{id}             - Update customer
DELETE /wp-json/wc/v3/customers/{id}          - Delete customer
```

## Authentication

WooCommerce REST API uses API keys for authentication:

```bash
# With API key (for applications)
curl -H "Authorization: Basic BASE64_ENCODED_KEY" \
  https://store.com/wp-json/wc/v3/products

# With OAuth (for user-delegated access)
# Implement OAuth 1.0a flow
```

Generate API keys in WooCommerce Settings > Advanced > REST API.

## API Examples

### Get Products

```javascript
// JavaScript
fetch('https://store.com/wp-json/wc/v3/products?per_page=20', {
    headers: {
        'Authorization': 'Basic ' + btoa('key:secret')
    }
})
.then(r => r.json())
.then(products => console.log(products))
```

### Create Order

```php
// PHP
$data = [
    'payment_method' => 'stripe',
    'payment_method_title' => 'Credit Card',
    'set_paid' => true,
    'billing' => [
        'first_name' => 'John',
        'last_name' => 'Doe',
        'address_1' => '123 Main',
        'city' => 'New York',
        'postcode' => '10001',
        'country' => 'US',
        'email' => 'john@example.com',
    ],
    'line_items' => [
        [
            'product_id' => 123,
            'quantity' => 2,
        ]
    ],
];

$response = wp_remote_post( 'https://store.com/wp-json/wc/v3/orders', [
    'headers' => [
        'Authorization' => 'Basic ' . base64_encode( 'key:secret' ),
        'Content-Type' => 'application/json',
    ],
    'body' => wp_json_encode( $data ),
] );
```

## Batch Operations

Create, update, or delete multiple items in one request:

```javascript
// Batch update products
fetch('https://store.com/wp-json/wc/v3/products/batch', {
    method: 'POST',
    headers: {
        'Authorization': 'Basic ' + btoa('key:secret'),
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        update: [
            { id: 1, regular_price: '29.99' },
            { id: 2, regular_price: '39.99' },
        ]
    })
})
```

## Pagination

```
?page=1&per_page=20  - Get page 1, 20 items
?page=2&per_page=50  - Get page 2, 50 items per page
```

Response includes pagination headers:

```
X-WP-Total: 1000       - Total items
X-WP-TotalPages: 50    - Total pages
```

## Filtering

```
?filter[meta_key]=value        - Filter by meta
?filter[date_min]=2024-01-01   - Date range
?search=keyword                 - Search by keyword
```

## Custom REST Endpoints

Register custom endpoints for custom data:

```php
add_action( 'rest_api_init', function() {
    register_rest_route( 'mystore/v1', '/custom-data/(?P<id>\d+)', [
        'methods' => 'GET',
        'callback' => 'get_custom_data',
        'permission_callback' => function( $request ) {
            return current_user_can( 'read_private_posts' );
        },
        'args' => [
            'id' => [
                'validate_callback' => function( $param ) {
                    return is_numeric( $param );
                },
            ],
        ],
    ] );
} );

function get_custom_data( $request ) {
    $id = $request['id'];
    $data = get_post_meta( $id, '_custom_data', true );

    return rest_ensure_response( [
        'id' => $id,
        'custom_data' => $data,
    ] );
}
```

Access at: `GET /wp-json/mystore/v1/custom-data/123`

## WebHooks

Trigger actions when API events occur:

```php
// Register webhook for order creation
$webhook = new WC_Webhook();
$webhook->set_name( 'Order Created' );
$webhook->set_user_id( get_current_user_id() );
$webhook->set_topic( 'order.created' );
$webhook->set_delivery_url( 'https://example.com/webhook' );
$webhook->set_secret( 'secret-key' );
$webhook->set_status( 'active' );
$webhook->save();
```

Webhook events:
- `product.created`, `product.updated`, `product.deleted`
- `order.created`, `order.updated`, `order.deleted`
- `customer.created`, `customer.updated`, `customer.deleted`

## Rate Limiting

WooCommerce REST API has rate limits:
- Authenticated: 10 requests per second
- Unauthenticated: 5 requests per second

Check rate limit headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## Error Handling

All errors return JSON:

```json
{
    "code": "rest_cannot_delete",
    "message": "Sorry, you are not allowed to delete this item.",
    "data": {
        "status": 401
    }
}
```

## Security

- Always use HTTPS
- Use API keys with limited scope
- Rotate API keys regularly
- Validate all input
- Verify webhook signatures
- Log API access

## Related Standards

- {{standards/backend/rest-api}} - General REST API patterns
- {{standards/backend/products}} - Product operations
- {{standards/backend/orders}} - Order operations
- {{standards/backend/woocommerce-security}} - API security
