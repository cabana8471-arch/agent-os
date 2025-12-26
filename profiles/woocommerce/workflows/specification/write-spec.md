# WooCommerce Specification Writing

## Searching for Existing WooCommerce Code

Before writing spec, search for existing WooCommerce implementations and customizations.

### Find WooCommerce Extensions and Customizations

```bash
# Search for WooCommerce hooks
grep -r "add_action.*woocommerce" . --include="*.php" | head -20

# Find product customizations
grep -r "wc_get_product\|WC_Product" . --include="*.php"

# Find order processing
grep -r "woocommerce_order\|wc_get_order" . --include="*.php"

# Find payment gateway references
grep -r "WC_Payment_Gateway\|process_payment" . --include="*.php"

# Find shipping customizations
grep -r "WC_Shipping\|calculate_shipping" . --include="*.php"
```

### Search for Product Type Definitions

```bash
# Find custom product types
grep -r "register_product_type\|WC_Product_" . --include="*.php"

# Find WooCommerce blocks
find . -name "block.json" | grep woocommerce
```

### Find Template Customizations

```bash
# Find WooCommerce template overrides
find woocommerce-templates -type f -name "*.php"

# Check theme customizations
grep -r "woocommerce_" wp-content/themes/*/functions.php
```

### Check Existing REST API Customizations

```bash
# Find custom REST endpoints
grep -r "register_rest_route.*wc\|register_rest_route.*woocommerce" . --include="*.php"

# Find webhook implementations
grep -r "woocommerce_webhook\|WC_Webhook" . --include="*.php"
```

## Reuse Opportunities

### Existing Payment Gateways
```bash
# Check if payment gateway already exists
grep -r "class.*extends WC_Payment_Gateway" . --include="*.php"

# Check active payment methods
grep -r "woocommerce_payment_gateways" . --include="*.php"
```

### Existing Shipping Methods
```bash
# Check custom shipping implementations
grep -r "class.*extends WC_Shipping" . --include="*.php"

# Find shipping zones configuration
grep -r "WC_Shipping_Zone" . --include="*.php"
```

### Product Customizations
```bash
# Check product meta fields already in use
grep -r "product->get_meta\|product->update_meta_data" . --include="*.php"

# Find existing product attributes
grep -r "product->get_attributes\|register_taxonomy.*pa_" . --include="*.php"
```

### Order Processing
```bash
# Find order hooks already implemented
grep -r "woocommerce_order_status_changed\|woocommerce_new_order" . --include="*.php"

# Check order meta usage
grep -r "order->get_meta\|order->update_meta_data" . --include="*.php"
```

## WooCommerce-Specific Search Patterns

### Hook Search Examples

```bash
# Before checkout - find existing validation
grep -r "woocommerce_checkout_process" . --include="*.php"

# After cart update - find existing post-cart hooks
grep -r "woocommerce_cart_calculate_fees\|woocommerce_cart_updated" . --include="*.php"

# Product display - find front-end customizations
grep -r "woocommerce_single_product\|woocommerce_before_add_to_cart" . --include="*.php"

# Email customizations
grep -r "woocommerce_email.*callback\|woocommerce_mail" . --include="*.php"
```

### Class Searches

```bash
# Find all WooCommerce classes used
grep -r "new WC_\|WC()->" . --include="*.php" | cut -d: -f2 | sort -u

# Find all product operations
grep -r "wc_get_product\|new WC_Product" . --include="*.php"

# Find cart operations
grep -r "WC()->cart\|wc_get_cart" . --include="*.php"
```

### Settings and Options

```bash
# Find WooCommerce settings accessed
grep -r "get_option.*woocommerce\|update_option.*woocommerce" . --include="*.php"

# Find store settings
grep -r "wc_get_store\|woocommerce_settings" . --include="*.php"
```

## Template Pattern Search

```bash
# Find existing WooCommerce templates overridden in theme
find . -path "*woocommerce*" -name "*.php" | grep -v /node_modules | grep -v /vendor

# Check custom template hooks
grep -r "do_action.*template\|apply_filters.*template" . --include="*.php" | grep woocommerce
```

## Documentation References

- **WooCommerce REST API**: https://woocommerce.com/document/woocommerce-rest-api/
- **WooCommerce Hooks**: https://woocommerce.com/document/hooks/
- **Template Overrides**: https://woocommerce.com/document/template-structure/
- **Product Data**: https://woocommerce.com/document/product-data-model/

## Specification Template for WooCommerce

```markdown
# Feature: Custom Order Processing

## Purpose
Automatically notify external system when orders reach processing status.

## WooCommerce Hooks Needed
- `woocommerce_order_status_changed` - Detect status change to processing
- `woocommerce_new_order` - On order creation (optional)

## Products Affected
- All product types (if applicable to feature)
- Product variations (if relevant)

## Order Customizations
- Custom order meta field: `_external_system_id`
- Custom order status: `pending_fulfillment` (optional)

## Custom Data Fields
- Order meta: `_notification_sent` (boolean)
- Order meta: `_external_response` (JSON response)

## Shipping Considerations
- Feature applies after shipping method selected
- No impact on shipping calculations

## Payment Related
- Only trigger for orders with successful payment

## REST API Endpoints
- Create custom endpoint? `/wp-json/mystore/v1/order/{id}/notify-external`

## Existing Reusable Code
- Use existing `send_notification()` function from utils
- Extend order status class if needed
- Reference similar webhook implementations

## Performance Considerations
- Queue notifications asynchronously (Action Scheduler)
- Cache external system status

## Security
- Validate order before sending
- Verify API credentials for external system
- Log sensitive operations

## Testing
- Test with different payment methods
- Test partial refunds don't retrigger
- Test failed notifications retry
```

## Related Standards

- {{standards/backend/hooks}} - Hook patterns and best practices
- {{standards/backend/orders}} - Order operations
- {{standards/backend/woocommerce-hooks}} - WooCommerce-specific hooks
- {{standards/backend/products}} - Product patterns
