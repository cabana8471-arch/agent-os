# WordPress Testing

## PHPUnit Setup

```bash
# Install WP-CLI and scaffold tests
wp scaffold plugin-tests my-plugin

# This creates:
# - phpunit.xml.dist
# - tests/bootstrap.php
# - tests/test-sample.php
```

## Writing Tests

```php
// tests/test-functions.php
class Test_My_Plugin_Functions extends WP_UnitTestCase {
    public function set_up() {
        parent::set_up();
        // Setup before each test
    }

    public function test_function_exists() {
        $this->assertTrue( function_exists( 'my_plugin_function' ) );
    }

    public function test_post_created() {
        $post_id = wp_insert_post( [ 'post_title' => 'Test' ] );
        $post = get_post( $post_id );

        $this->assertIsInt( $post_id );
        $this->assertEquals( 'Test', $post->post_title );
    }

    public function test_user_meta() {
        $user_id = wp_create_user( 'testuser', 'password' );
        add_user_meta( $user_id, 'my_key', 'my_value' );

        $value = get_user_meta( $user_id, 'my_key', true );
        $this->assertEquals( 'my_value', $value );
    }
}
```

## Database Transactions

```php
// ✅ Good: Tests auto-rollback database changes
class Test_My_Plugin extends WP_UnitTestCase {
    public function test_post_saved() {
        $post_id = wp_insert_post( [ 'post_title' => 'Test' ] );
        // This is automatically rolled back after test
    }

    public function test_another_test() {
        // Previous test's post doesn't exist here
        $posts = get_posts();
        $this->assertEmpty( $posts );
    }
}
```

## WP_UnitTestCase Methods

```php
// Assertions
$this->assertTrue( $condition );
$this->assertFalse( $condition );
$this->assertEquals( $expected, $actual );
$this->assertIsInt( $value );
$this->assertIsArray( $value );
$this->assertEmpty( $value );
$this->assertNotEmpty( $value );

// Post assertions
$this->assertPostExists( $post_id );
$this->assertPostNotExists( $post_id );
$this->assertPostHasTerms( $post_id, 'category', [ 1, 2 ] );

// User assertions
$this->assertUserExists( $user_id );
$this->assertUserNotExists( $user_id );
```

## Mocking Hooks

```php
// ✅ Good: Test that hook fires
class Test_Hooks extends WP_UnitTestCase {
    public function test_action_fires() {
        $callback = new MockCallback();

        add_action( 'my_action', [ $callback, 'handle' ] );
        do_action( 'my_action' );

        $this->assertTrue( $callback->called );
    }

    public function test_filter_applied() {
        add_filter( 'my_filter', function( $value ) {
            return $value . ' filtered';
        } );

        $result = apply_filters( 'my_filter', 'original' );
        $this->assertEquals( 'original filtered', $result );
    }
}
```

## Running Tests

```bash
# Run all tests
phpunit

# Run specific test file
phpunit tests/test-functions.php

# Run specific test
phpunit tests/test-functions.php --filter test_post_created

# With coverage
phpunit --coverage-html coverage/
```

## E2E Testing with Playwright

```typescript
// tests/e2e/login.spec.ts
import { test, expect } from '@wordpress/e2e-test-utils'

test( 'user can login', async ( { page, admin } ) => {
    await admin.visitAdminPage( '/' )

    await page.fill( '#user_login', 'admin' )
    await page.fill( '#user_pass', 'password' )
    await page.click( '#wp-submit' )

    await expect( page ).toHaveURL( '/wp-admin/' )
} )
```

## Coverage Goals

- Core functionality: 80%+
- Critical paths: 90%+
- UI/Presentation: 40%+
- Utilities: 80%+

## Related Standards

- {{standards/backend/plugins}} - Plugin structure
- {{standards/global/coding-style}} - Test naming conventions
