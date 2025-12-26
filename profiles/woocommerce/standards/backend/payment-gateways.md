# WooCommerce Payment Gateways

## Payment Gateway Architecture

Custom payment gateways extend `WC_Payment_Gateway`:

```php
class My_Payment_Gateway extends WC_Payment_Gateway {
    public function __construct() {
        $this->id = 'my_gateway';
        $this->title = 'My Payment';
        $this->description = 'Pay securely with My Payment';
        $this->enabled = 'yes';
        $this->icon = '';
        $this->has_fields = true; // Show payment form on checkout
        $this->supports = [ 'products', 'refunds' ];
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
            'title' => [
                'title' => 'Title',
                'type' => 'text',
            ],
            'api_key' => [
                'title' => 'API Key',
                'type' => 'password',
            ],
        ];
    }

    public function payment_fields() {
        echo '<p>Pay securely</p>';
        echo '<input type="text" name="card_number" placeholder="Card Number" />';
    }

    public function process_payment( $order_id ) {
        $order = wc_get_order( $order_id );

        // Process payment with API
        $result = $this->charge_card( $order );

        if ( is_wp_error( $result ) ) {
            wc_add_notice( $result->get_error_message(), 'error' );
            return [ 'result' => 'failure' ];
        }

        // Mark order as paid
        $order->payment_complete( $result['transaction_id'] );
        return [
            'result' => 'success',
            'redirect' => $this->get_return_url( $order ),
        ];
    }

    private function charge_card( $order ) {
        // Call payment API
    }

    public function process_refund( $amount, $order_id ) {
        $order = wc_get_order( $order_id );

        // Call refund API
        $result = $this->refund_transaction( $order, $amount );

        return ! is_wp_error( $result );
    }
}

// Register gateway
add_filter( 'woocommerce_payment_gateways', function( $gateways ) {
    $gateways[] = 'My_Payment_Gateway';
    return $gateways;
} );
```

## Security Critical: Never Store Card Data

**NEVER** store payment card numbers directly:

```php
// WRONG - NEVER DO THIS
update_post_meta( $order_id, '_card_number', $_POST['card_number'] );

// CORRECT - Use tokenization
$token = $gateway->create_token( $card_data );
$order->add_payment_token( $token );
```

Use WooCommerce payment tokens for repeating charges:

```php
$token = new WC_Payment_Token_CC();
$token->set_token( $remote_token ); // From payment processor
$token->set_gateway_id( $this->id );
$token->set_user_id( $order->get_user_id() );
$token->save();
```

## Webhook Handling

Always verify webhook signatures from payment processor:

```php
public function handle_webhook() {
    $webhook_data = file_get_contents( 'php://input' );
    $signature = $_SERVER['HTTP_X_SIGNATURE'] ?? '';

    // Verify signature BEFORE processing
    if ( ! $this->verify_signature( $webhook_data, $signature ) ) {
        wp_die( 'Invalid signature', 'Invalid', [ 'response' => 401 ] );
    }

    $data = json_decode( $webhook_data, true );

    // Process webhook
    if ( 'payment.completed' === $data['event'] ) {
        $order = wc_get_order( $data['order_id'] );
        $order->payment_complete( $data['transaction_id'] );
    }
}

private function verify_signature( $data, $signature ) {
    $expected = hash_hmac( 'sha256', $data, $this->api_secret );
    return hash_equals( $signature, $expected );
}
```

## Payment Form Handling

Keep sensitive data out of logs:

```php
public function process_payment( $order_id ) {
    $order = wc_get_order( $order_id );

    // Get token from form (not card data)
    $token = sanitize_text_field( $_POST['payment_token'] ?? '' );

    // NEVER log card data
    error_log( 'Processing order ' . $order_id ); // OK
    // error_log( print_r( $_POST, true ) ); // WRONG - could expose card

    // Charge using token
    $result = $this->charge_with_token( $token, $order->get_total() );

    return $this->handle_result( $result, $order );
}
```

## 3D Secure / SCA Support

For stronger authentication:

```php
public function process_payment( $order_id ) {
    $order = wc_get_order( $order_id );

    // Check if 3D Secure required
    $result = $this->initiate_charge( $order );

    if ( isset( $result['authentication_url'] ) ) {
        // Customer needs to authenticate
        return [
            'result' => 'success',
            'redirect' => $result['authentication_url'],
        ];
    }

    // Direct charge (low-risk)
    $order->payment_complete( $result['transaction_id'] );
    return [
        'result' => 'success',
        'redirect' => $this->get_return_url( $order ),
    ];
}
```

## PCI Compliance Checklist

- [ ] Never store full card numbers
- [ ] Use PCI-compliant payment processor
- [ ] Verify webhook signatures
- [ ] Use HTTPS for all payment pages
- [ ] Don't log card data
- [ ] Implement 3DS where required
- [ ] Validate SSL certificates
- [ ] Implement tokenization for subscriptions

## Related Standards

- {{standards/backend/woocommerce-security}} - E-commerce security requirements
- {{standards/global/security}} - General security (nonces, escaping, etc.)
- {{standards/backend/orders}} - Order processing and management
