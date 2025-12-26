# WordPress Specification Writing

## Searching for Existing Code

Before writing spec, search for reusable WordPress patterns.

### Find Existing Post Type/Taxonomy Definitions

```bash
# Search for registered post types
grep -r "register_post_type" . --include="*.php"

# Search for taxonomies
grep -r "register_taxonomy" . --include="*.php"

# Find custom capabilities
grep -r "current_user_can" . --include="*.php"
```

### Find Hooks

```bash
# Search for existing hooks
grep -r "do_action\|apply_filters" . --include="*.php"

# Find specific hook patterns
grep -r "add_action.*init" . --include="*.php"

# Find save_post hooks
grep -r "save_post" . --include="*.php"
```

### Find Template & Admin Code

```bash
# Find templates
find . -name "*.php" -path "*/template-parts/*"

# Find admin files
find . -name "*admin*.php"

# Find custom pages
grep -r "add_menu_page\|add_submenu_page" . --include="*.php"
```

## Reuse Opportunities

### Post Type Patterns

```php
// Check if similar post type exists
if ( post_type_exists( 'existing_type' ) ) {
    // Could extend instead of creating new
}

// Find existing capabilities
$post_type = get_post_type_object( 'book' );
// $post_type->capabilities
```

### Hook Patterns

```bash
# Find similar hooks in use
grep -r "do_action.*after" includes/

# Find similar filters
grep -r "apply_filters.*data" includes/

# Understand hook flow
grep -B5 -A5 "do_action.*save" includes/
```

### Meta Field Patterns

```bash
# Find existing meta patterns
grep -r "add_post_meta\|get_post_meta" . --include="*.php"

# Check meta key naming
grep -r "_custom_prefix" . --include="*.php"

# Find meta box implementations
grep -r "add_meta_box" . --include="*.php"
```

## Database Schema Searching

```bash
# Check for custom tables
grep -r "CREATE TABLE" . --include="*.php"

# Find dbDelta usage
grep -r "dbDelta" . --include="*.php"

# Look at existing table structures
grep -r "\$wpdb->posts\|\$wpdb->postmeta" . --include="*.php" | head -5
```

## Plugin/Theme Code Structure

```bash
# Find plugin bootstrap
cat wp-content/plugins/your-plugin/your-plugin.php | head -30

# Check functions.php
cat wp-content/themes/your-theme/functions.php | grep "add_action\|add_filter"

# Find includes
find wp-content/plugins/your-plugin -name "*.php" | head -10
```

## REST API Patterns

```bash
# Find existing REST endpoints
grep -r "register_rest_route" . --include="*.php"

# Check endpoint structure
grep -A10 "register_rest_route" includes/admin/rest-api.php

# Find permission callbacks
grep -r "permission_callback" . --include="*.php" | head -5
```

## Specification Template for WordPress

```markdown
# Feature: User Role Management

## Purpose
Allow administrators to assign user roles and manage permissions.

## Custom Post Types
None

## Custom Taxonomies
None

## Meta Fields
- `user_department` (user meta)
- `user_permissions` (user meta, serialized array)

## Hooks Needed
- `my_plugin_before_role_assign` (action)
- `my_plugin_validate_role` (filter)

## Database Changes
- None

## Admin Pages/Menus
- Settings page under "Users"
- Custom role editor

## REST API Endpoints
- `GET /wp-json/my-plugin/v1/roles`
- `POST /wp-json/my-plugin/v1/roles`

## Existing Code Reuse
- Use existing `current_user_can()` checks
- Use WordPress capabilities system
- Extend user meta instead of custom table

## Template Hooks Needed
- Add role badge in user list table column

## Testing
- Verify role assignment
- Check permission validation
- Test REST API endpoints
```

## Search Techniques

```bash
# Quick grep searches
grep -r "pattern" . --include="*.php" | grep -v vendor

# Find function definitions
grep -r "^function my_plugin" . --include="*.php"

# Find class definitions
grep -r "^class " . --include="*.php"

# Find action/filter registrations
grep -E "add_(action|filter)" . --include="*.php" | head -20

# Find comments with TODO
grep -r "TODO\|FIXME" . --include="*.php"
```

## Code Reference Documentation

- **WordPress Function Reference**: https://developer.wordpress.org/reference/
- **WordPress Hook Database**: https://adambrown.info/p/hooks
- **WordPress REST API**: https://developer.wordpress.org/rest-api/

## Related Standards

- {{standards/backend/post-types-taxonomies}} - Post type patterns
- {{standards/backend/hooks}} - Hook patterns
- {{standards/backend/rest-api}} - REST API patterns
- {{standards/backend/plugins}} - Plugin structure
