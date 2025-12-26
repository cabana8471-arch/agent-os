# WordPress Custom Post Types & Taxonomies

## Custom Post Types

Register custom content types beyond default Posts and Pages:

```php
// ✅ Good: Register custom post type
add_action( 'init', function() {
    register_post_type( 'book', [
        'labels'             => [
            'name'          => 'Books',
            'singular_name' => 'Book',
            'menu_name'     => 'Books',
            'add_new_item'  => 'Add New Book',
        ],
        'description'        => 'A book in our library',
        'public'             => true,
        'publicly_queryable' => true,
        'show_ui'            => true,
        'show_in_menu'       => true,
        'show_in_rest'       => true,              // Enable Gutenberg
        'query_var'          => true,
        'rewrite'            => [ 'slug' => 'books' ],
        'capability_type'    => 'post',
        'has_archive'        => true,
        'hierarchical'       => false,
        'supports'           => [
            'title',
            'editor',
            'thumbnail',
            'excerpt',
            'custom-fields',
            'revisions',
        ],
        'taxonomies'         => [ 'category', 'post_tag' ],
        'menu_icon'          => 'dashicons-book-alt',
    ] );
} );

// ❌ Avoid: Complex post type names
register_post_type( 'my_custom_post_type_name', [] ); // Too long

// ❌ Avoid: Registering in wrong hook
register_post_type( 'book', [] ); // Must be on 'init' hook
```

### Post Type Naming

- **Singular, lowercase**: `book` not `books` or `Book`
- **Max 20 characters**: Enforced by WordPress
- **Avoid core names**: Don't use post, page, attachment, etc.
- **Prefix for plugins**: `myplugin_resource` to avoid conflicts

## Post Type Arguments

```php
register_post_type( 'product', [
    // Display
    'labels'             => [ 'name' => 'Products', ... ],
    'description'        => 'Product information',
    'public'             => true,       // Visible to public and admin

    // Admin
    'show_ui'            => true,       // Show in WordPress admin
    'show_in_menu'       => true,       // Add to admin menu
    'menu_position'      => 20,         // Menu position
    'menu_icon'          => 'dashicons-shopping-cart',

    // Queries
    'publicly_queryable' => true,       // Can be queried on front-end
    'query_var'          => 'product',  // URL query variable
    'rewrite'            => [
        'slug'       => 'products',
        'with_front' => false,
        'feeds'      => true,
        'pages'      => true
    ],

    // REST API
    'show_in_rest'      => true,        // Available in REST API
    'rest_base'         => 'products',  // REST endpoint
    'rest_controller_class' => 'WP_REST_Posts_Controller',

    // Features
    'supports'          => [
        'title',           // Post title
        'editor',          // Post content
        'excerpt',         // Short description
        'thumbnail',       // Featured image
        'custom-fields',   // Meta boxes
        'revisions',       // Version history
        'page-attributes', // Parent, order
        'post-formats'     // Post format
    ],
    'taxonomies'        => [ 'category' ],

    // Archive & History
    'has_archive'       => true,        // Enable archive page
    'hierarchical'      => false,       // Can have parent posts (like pages)

    // Capabilities
    'capability_type'   => 'post',      // Base capability name
    'capabilities'      => [            // Custom capabilities
        'create_posts' => 'create_products'
    ],
    'map_meta_cap'      => true,        // Map post capabilities
] );
```

## Taxonomies (Categories, Tags)

Classify and organize posts:

```php
// ✅ Good: Register taxonomy
add_action( 'init', function() {
    register_taxonomy( 'book_genre', 'book', [
        'labels'            => [
            'name'          => 'Genres',
            'singular_name' => 'Genre',
            'menu_name'     => 'Genres',
            'search_items'  => 'Search Genres',
            'add_new_item'  => 'Add New Genre',
        ],
        'description'       => 'Book genre classification',
        'hierarchical'      => true,      // Like categories (has parents)
        'public'            => true,
        'show_ui'           => true,
        'show_in_menu'      => true,
        'show_in_rest'      => true,      // Enable in REST API
        'show_admin_column' => true,      // Show in posts list
        'query_var'         => true,
        'rewrite'           => [
            'slug'       => 'book-genre',
            'with_front' => true,
        ],
        'publicly_queryable' => true,
    ] );
} );

// ❌ Avoid: Registering taxonomy not attached to post type
register_taxonomy( 'genre', 'book' );

// ❌ Avoid: Registering without init hook
register_taxonomy( 'genre', 'book' ); // Must be on 'init' hook
```

### Taxonomy Types

**Hierarchical** (like categories - has parents):
- Categories
- Book genres
- Product types

```php
register_taxonomy( 'genre', 'book', [
    'hierarchical' => true,
    'supports'     => [ 'parent' ]  // Enable parent term
] );
```

**Non-Hierarchical** (like tags - no parents):
- Tags
- Product colors
- Skills

```php
register_taxonomy( 'color', 'product', [
    'hierarchical' => false
] );
```

## Meta Fields (Custom Fields)

Store additional data on posts:

```php
// ✅ Good: Save post meta
add_post_meta( $post_id, 'book_author', 'John Doe' );
add_post_meta( $post_id, 'book_isbn', '978-0-123456-78-9' );

// ✅ Good: Retrieve meta
$author = get_post_meta( $post_id, 'book_author', true );
$all_authors = get_post_meta( $post_id, 'book_author' ); // Gets all (array)

// ✅ Good: Update meta
update_post_meta( $post_id, 'book_author', 'Jane Doe' );

// ✅ Good: Delete meta
delete_post_meta( $post_id, 'book_author' );

// ✅ Good: Save multiple values with same key
add_post_meta( $post_id, 'book_review', 'Great book!', false );
add_post_meta( $post_id, 'book_review', 'Highly recommended', false );

// ❌ Avoid: Storing meta without key context
add_post_meta( $post_id, 'data', json_encode( $array ) ); // Too generic
```

### Meta Box Registration

```php
// ✅ Good: Register meta box (custom field UI)
add_action( 'add_meta_boxes', function() {
    add_meta_box(
        'book_details',           // Meta box ID
        'Book Details',           // Title
        function( $post ) {       // Callback function
            $author = get_post_meta( $post->ID, 'book_author', true );
            ?>
            <label for="book_author">Author:</label>
            <input
                type="text"
                id="book_author"
                name="book_author"
                value="<?php echo esc_attr( $author ); ?>"
            />
            <?php
        },
        'book',                   // Post type
        'normal',                 // Context (normal, side, advanced)
        'default'                 // Priority (default, low, high)
    );
} );

// ✅ Good: Save meta box data
add_action( 'save_post_book', function( $post_id ) {
    // Check nonce
    if ( ! isset( $_POST['nonce'] ) || ! wp_verify_nonce( $_POST['nonce'] ) ) {
        return;
    }

    // Check permission
    if ( ! current_user_can( 'edit_post', $post_id ) ) {
        return;
    }

    // Sanitize and save
    if ( isset( $_POST['book_author'] ) ) {
        update_post_meta(
            $post_id,
            'book_author',
            sanitize_text_field( $_POST['book_author'] )
        );
    }
} );
```

## Rewrite Rules

Control URL structure for post types and taxonomies:

```php
// ✅ Good: Custom rewrite rule
register_post_type( 'book', [
    'rewrite' => [
        'slug'       => 'books',
        'with_front' => false,  // Don't prepend /posts/
        'feeds'      => true,
        'pages'      => true
    ]
] );

// ✅ Good: Hierarchical URLs for hierarchical post types
register_post_type( 'page', [
    'hierarchical' => true,
    'rewrite'      => [ 'slug' => 'pages' ]
] );

// After registering post types/taxonomies, flush rewrite rules
add_action( 'init', function() {
    register_post_type( 'book', [ ... ] );
    flush_rewrite_rules(); // Only on first registration, then remove
} );

// ❌ Avoid: Calling flush_rewrite_rules() on every page load
// Only call once after registration, then remove from code
```

## REST API Support

Make custom post types queryable via REST API:

```php
// ✅ Good: Enable REST API for custom post type
register_post_type( 'book', [
    'show_in_rest'      => true,
    'rest_base'         => 'books',
    'rest_controller_class' => 'WP_REST_Posts_Controller',
    // Endpoint will be: /wp-json/wp/v2/books
] );

// ✅ Good: Enable REST API for custom taxonomy
register_taxonomy( 'genre', 'book', [
    'show_in_rest' => true,
    'rest_base'    => 'genres',
    // Endpoint will be: /wp-json/wp/v2/genres
] );

// ✅ Good: Expose post meta to REST API
register_post_meta( 'book', 'book_author', [
    'type'          => 'string',
    'single'        => true,
    'show_in_rest'  => true,
    'rest_schema'   => [
        'type'        => 'string',
        'description' => 'Author name'
    ]
] );
```

## Query by Custom Post Type

```php
// ✅ Good: Query custom post type
$books = new WP_Query( [
    'post_type'      => 'book',
    'posts_per_page' => 10,
] );

// ✅ Good: Query multiple post types
$content = new WP_Query( [
    'post_type' => [ 'post', 'page', 'book' ],
] );

// ✅ Good: Query by custom taxonomy
$books = new WP_Query( [
    'post_type' => 'book',
    'tax_query' => [
        [
            'taxonomy' => 'book_genre',
            'field'    => 'slug',
            'terms'    => 'fiction'
        ]
    ]
] );
```

## Best Practices

### Organization

- **One purpose per post type**: Don't mix unrelated content
- **Descriptive names**: Make purpose clear
- **Consistent naming**: Prefixed with plugin slug if plugin

### Performance

- **Index meta keys**: Register meta keys for efficient queries
- **Taxonomies over meta**: Use taxonomies for filtering
- **Limit post types**: Each post type adds database overhead

### Capabilities

```php
// ✅ Good: Custom capabilities for custom post type
register_post_type( 'book', [
    'capability_type' => 'book',  // Use 'book' not 'post'
    'capabilities'    => [
        'create_posts'   => 'create_books',
        'edit_posts'     => 'edit_books',
        'edit_others'    => 'edit_others_books',
        'delete_posts'   => 'delete_books',
        'publish_posts'  => 'publish_books',
        'read'           => 'read_books'
    ]
] );
```

## Related Standards

- {{standards/backend/hooks}} - Hooks for post type actions
- {{standards/backend/rest-api}} - REST API for custom post types
- {{standards/global/security}} - Securing meta fields
- {{standards/backend/queries}} - Querying custom post types
