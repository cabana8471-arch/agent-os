# WordPress Plugin Development

## Plugin Structure

```
my-plugin/
├── my-plugin.php          # Main plugin file with header
├── readme.txt             # WordPress.org plugin description
├── includes/
│   ├── class-plugin.php   # Main plugin class
│   ├── admin/
│   │   └── class-admin.php
│   └── frontend/
│       └── class-frontend.php
├── assets/
│   ├── css/
│   ├── js/
│   └── images/
├── templates/             # Template files
├── languages/             # Translation files
└── uninstall.php         # Uninstall cleanup
```

## Plugin File Header

```php
<?php
/**
 * Plugin Name: My Awesome Plugin
 * Plugin URI: https://example.com/my-plugin
 * Description: Do something useful
 * Version: 1.0.0
 * Author: Your Name
 * Author URI: https://example.com
 * License: GPL v2 or later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: my-plugin
 * Domain Path: /languages
 * Requires at least: 5.0
 * Requires PHP: 7.4
 */

defined( 'ABSPATH' ) || exit;

// Define constants
define( 'MY_PLUGIN_VERSION', '1.0.0' );
define( 'MY_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );
define( 'MY_PLUGIN_URL', plugin_dir_url( __FILE__ ) );

// Load plugin
require_once MY_PLUGIN_DIR . 'includes/class-plugin.php';

// Initialize
add_action( 'plugins_loaded', function() {
    My_Plugin::get_instance();
} );
```

## Main Plugin Class

```php
// ✅ Good: Singleton plugin class
class My_Plugin {
    private static $instance = null;

    public static function get_instance() {
        if ( is_null( self::$instance ) ) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    private function __construct() {
        add_action( 'init', [ $this, 'init' ] );
        add_action( 'wp_enqueue_scripts', [ $this, 'enqueue_scripts' ] );

        register_activation_hook( MY_PLUGIN_FILE, [ $this, 'activate' ] );
        register_deactivation_hook( MY_PLUGIN_FILE, [ $this, 'deactivate' ] );
    }

    public function init() {
        load_plugin_textdomain( 'my-plugin', false, dirname( plugin_basename( MY_PLUGIN_FILE ) ) . '/languages' );

        register_post_type( 'my_cpt', [ /* ... */ ] );
    }

    public function enqueue_scripts() {
        wp_enqueue_script( 'my-plugin', MY_PLUGIN_URL . 'assets/js/main.js', [], MY_PLUGIN_VERSION, true );
    }

    public function activate() {
        // Run on activation
        flush_rewrite_rules();
    }

    public function deactivate() {
        // Run on deactivation
        flush_rewrite_rules();
    }
}
```

## Activation/Deactivation

```php
// ✅ Good: Activation hook
register_activation_hook( __FILE__, function() {
    // Create custom tables if needed
    global $wpdb;
    $charset_collate = $wpdb->get_charset_collate();

    $sql = "CREATE TABLE IF NOT EXISTS {$wpdb->prefix}my_plugin_table (
        id bigint(20) NOT NULL AUTO_INCREMENT,
        name varchar(255) NOT NULL,
        created_at datetime NOT NULL,
        PRIMARY KEY  (id)
    ) $charset_collate;";

    require_once ABSPATH . 'wp-admin/includes/upgrade.php';
    dbDelta( $sql );

    // Set version option
    update_option( 'my_plugin_version', '1.0.0' );

    // Flush rewrite rules for custom post types
    flush_rewrite_rules();
} );

// ✅ Good: Deactivation hook
register_deactivation_hook( __FILE__, function() {
    // Cleanup cron jobs
    wp_clear_scheduled_hook( 'my_plugin_daily_task' );

    // Flush rewrite rules
    flush_rewrite_rules();
} );

// ✅ Good: Uninstall.php (separate file)
// uninstall.php
if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
    exit;
}

// Delete custom tables
global $wpdb;
$wpdb->query( "DROP TABLE IF EXISTS {$wpdb->prefix}my_plugin_table" );

// Delete options
delete_option( 'my_plugin_version' );
delete_option( 'my_plugin_settings' );

// Delete user meta
delete_user_meta( null, 'my_plugin_user_setting' );
```

## Admin Menu & Pages

```php
// ✅ Good: Add admin menu
add_action( 'admin_menu', function() {
    add_menu_page(
        'My Plugin Settings',      // Page title
        'My Plugin',               // Menu title
        'manage_options',          // Capability
        'my-plugin-settings',      // Menu slug
        'my_plugin_settings_page', // Function
        'dashicons-admin-generic', // Icon
        25                         // Position
    );

    add_submenu_page(
        'my-plugin-settings',
        'Settings',
        'Settings',
        'manage_options',
        'my-plugin-settings'
    );
} );

// ✅ Good: Admin page content
function my_plugin_settings_page() {
    if ( ! current_user_can( 'manage_options' ) ) {
        wp_die();
    }
    ?>
    <div class="wrap">
        <h1><?php esc_html_e( 'My Plugin Settings', 'my-plugin' ); ?></h1>
        <form method="post" action="options.php">
            <?php
            settings_fields( 'my_plugin_group' );
            do_settings_sections( 'my-plugin-settings' );
            submit_button();
            ?>
        </form>
    </div>
    <?php
}
```

## Settings API

```php
// ✅ Good: Register settings
add_action( 'admin_init', function() {
    register_setting( 'my_plugin_group', 'my_plugin_enabled', [
        'type'              => 'boolean',
        'sanitize_callback' => function( $value ) {
            return (bool) $value;
        },
        'show_in_rest'      => true
    ] );

    add_settings_section(
        'my_plugin_main',
        'Main Settings',
        function() { echo 'Configure plugin behavior'; },
        'my-plugin-settings'
    );

    add_settings_field(
        'my_plugin_enabled',
        'Enable Plugin',
        function() {
            $value = get_option( 'my_plugin_enabled' );
            echo '<input type="checkbox" name="my_plugin_enabled" value="1" ' . checked( $value, 1, false ) . '/>';
        },
        'my-plugin-settings',
        'my_plugin_main'
    );
} );
```

## AJAX Handling

```php
// ✅ Good: AJAX endpoint (authenticated)
add_action( 'wp_ajax_my_plugin_action', function() {
    check_ajax_referer( 'my_plugin_nonce' );

    if ( ! current_user_can( 'edit_posts' ) ) {
        wp_send_json_error( 'Unauthorized' );
    }

    $data = sanitize_text_field( $_POST['data'] );

    // Process
    $result = process_data( $data );

    wp_send_json_success( [ 'result' => $result ] );
} );

// ✅ Good: AJAX endpoint (unauthenticated)
add_action( 'wp_ajax_nopriv_my_plugin_public_action', function() {
    check_ajax_referer( 'public_nonce' );

    $search = sanitize_text_field( $_POST['search'] );
    $results = search_something( $search );

    wp_send_json_success( $results );
} );
```

## Hooks & Filters

```php
// ✅ Good: Create custom hooks for extensibility
// Action: Allow other plugins to hook in
do_action( 'my_plugin_before_process', $data );

$data = apply_filters( 'my_plugin_process_data', $data );

do_action( 'my_plugin_after_process', $data );

// Allow others to use your hooks:
add_action( 'my_plugin_before_process', 'my_function' );
add_filter( 'my_plugin_process_data', 'my_filter_function' );
```

## Plugin Dependencies

```php
// ✅ Good: Check for required plugins
add_action( 'admin_init', function() {
    if ( ! is_plugin_active( 'other-plugin/other-plugin.php' ) ) {
        add_action( 'admin_notices', function() {
            echo '<div class="notice notice-error"><p>';
            esc_html_e( 'My Plugin requires Other Plugin to be installed', 'my-plugin' );
            echo '</p></div>';
        } );
        deactivate_plugins( plugin_basename( __FILE__ ) );
    }
} );
```

## Related Standards

- {{standards/backend/hooks}} - Hook patterns
- {{standards/global/security}} - Plugin security
- {{standards/global/coding-style}} - PHP conventions
