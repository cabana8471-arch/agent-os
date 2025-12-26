# WordPress Core Hooks Reference

Quick reference for most commonly-used WordPress core hooks.

## Initialization Hooks

- `plugins_loaded` - All plugins loaded, before after_setup_theme
- `after_setup_theme` - Theme functions loaded, customizer available
- `init` - WordPress fully initialized, use for post types, taxonomies
- `wp_loaded` - WordPress completely loaded and all plugins executed

## Template & Frontend Hooks

- `wp_head` - Output content in <head>
- `wp_footer` - Output content before </body>
- `wp_body_open` - Output after <body> tag (HTML5 only)
- `the_content` - Filter post/page content
- `the_title` - Filter post/page title
- `the_excerpt` - Filter post excerpt
- `post_class` - Filter classes on post containers
- `body_class` - Filter classes on <body> tag

## Admin Hooks

- `admin_init` - Admin initialization
- `admin_menu` - Admin menu build
- `admin_enqueue_scripts` - Enqueue admin styles/scripts
- `admin_notices` - Display admin notices
- `admin_footer` - Admin page footer

## Post/Page Hooks

- `save_post` - Post/page saved (fires both on insert and update)
- `save_post_{post_type}` - Specific post type save
- `wp_insert_post` - After post inserted, before meta saved
- `wp_insert_post_data` - Filter post data before insert
- `before_delete_post` - Before post deleted
- `delete_post` - After post deleted

## User Hooks

- `user_register` - After user registered
- `profile_update` - User profile updated
- `wp_login` - User logged in
- `wp_logout` - User logged out
- `wp_authenticate_user` - Validate user credentials

## Query Hooks

- `pre_get_posts` - Modify WP_Query before execution
- `posts_where` - Filter SQL WHERE clause
- `posts_orderby` - Filter SQL ORDER BY clause
- `posts_per_page` - Posts per page count

## Meta Hooks

- `get_post_metadata` - Filter meta value on retrieve
- `update_post_meta` - Before meta updated
- `added_post_meta` - After meta added
- `get_user_metadata` - Filter user meta on retrieve

## AJAX Hooks

- `wp_ajax_{action}` - AJAX action (authenticated)
- `wp_ajax_nopriv_{action}` - AJAX action (public)
- `wp_ajax_{action}` fires first, then `wp_ajax_nopriv_{action}`

## Settings Hooks

- `option_{option_name}` - Filter option value
- `pre_option_{option_name}` - Filter before option retrieved
- `update_option_{option_name}` - Before option updated
- `updated_option_{option_name}` - After option updated

## REST API Hooks

- `rest_api_init` - REST API initialized, register endpoints
- `rest_authentication_errors` - Filter auth errors
- `rest_pre_dispatch` - Before REST request dispatched
- `rest_insert_{post_type}` - After post inserted via REST

## Enqueuing Hooks

- `wp_enqueue_scripts` - Frontend styles/scripts
- `admin_enqueue_scripts` - Admin styles/scripts
- `enqueue_block_editor_assets` - Block editor assets

## Hooks by Common Use Case

**Modify content before display:**
- `the_content` (filter post content)
- `post_class` (add CSS classes)

**Add custom functionality:**
- `init` (register post types, taxonomies)
- `wp_enqueue_scripts` (load assets)
- `wp_head` (add meta tags)

**Handle user actions:**
- `save_post` (when post saved)
- `user_register` (when user created)
- `delete_post` (when post deleted)

**Extend admin:**
- `admin_menu` (add pages)
- `admin_init` (save settings)
- `add_meta_boxes` (custom fields)

## Related Standards

- {{standards/backend/hooks}} - Hook patterns and best practices
- {{standards/backend/plugins}} - Plugin hooks
- {{standards/backend/post-types-taxonomies}} - Post/taxonomy hooks
