# WordPress Database Queries

## WP_Query Class

Primary WordPress class for querying posts with full support for custom post types, meta, taxonomies:

```php
// ✅ Good: Basic WP_Query
$args = [
    'post_type'      => 'post',
    'posts_per_page' => 10,
    'paged'          => get_query_var( 'paged' ) ?: 1,
];

$query = new WP_Query( $args );

if ( $query->have_posts() ) {
    while ( $query->have_posts() ) {
        $query->the_post();
        // Display post
        the_title();
        the_content();
    }
    wp_reset_postdata();
} else {
    echo 'No posts found';
}

// ✅ Good: Query with meta
$query = new WP_Query( [
    'post_type'  => 'post',
    'meta_query' => [
        [
            'key'   => 'featured',
            'value' => 1,
        ]
    ]
] );

// ✅ Good: Query with taxonomy
$query = new WP_Query( [
    'post_type' => 'post',
    'tax_query' => [
        [
            'taxonomy' => 'category',
            'field'    => 'slug',
            'terms'    => 'news',
        ]
    ]
] );

// ❌ Avoid: Using query_posts (deprecated)
query_posts( 'post_type=post&posts_per_page=5' ); // Never use
```

## Query Arguments

### Common Arguments

```php
// Post type selection
'post_type'      => 'post',           // Single type
'post_type'      => [ 'post', 'page' ], // Multiple types

// Pagination
'posts_per_page' => 10,
'paged'          => 1,
'offset'         => 0,                // Use with caution

// Ordering
'orderby'        => 'date',           // 'date', 'title', 'modified', 'rand', 'meta_value'
'order'          => 'DESC',           // 'ASC' or 'DESC'

// Status
'post_status'    => 'publish',        // 'publish', 'draft', 'pending', etc.
'post_status'    => [ 'publish', 'draft' ], // Multiple statuses

// Search
's'              => 'search term',    // Full-text search
'exact'          => true,             // Exact phrase matching

// Exclusions
'post__not_in'   => [ 1, 2, 3 ],     // Exclude post IDs
'post__in'       => [ 5, 6, 7 ],     // Include only these IDs
'exclude_posts'  => [ 1, 2 ],        // More flexible excluding

// Author
'author'         => 1,               // Single author ID
'author__in'     => [ 1, 2 ],        // Multiple authors
'author__not_in' => [ 3, 4 ],        // Exclude authors
```

## Meta Queries

Query based on post meta (custom fields):

```php
// ✅ Good: Single meta condition
$query = new WP_Query( [
    'post_type'  => 'product',
    'meta_query' => [
        [
            'key'     => 'price',
            'value'   => 100,
            'compare' => '>=',
            'type'    => 'NUMERIC'
        ]
    ]
] );

// ✅ Good: Multiple meta conditions (AND)
$query = new WP_Query( [
    'post_type'  => 'product',
    'meta_query' => [
        'relation' => 'AND', // All conditions must match
        [
            'key'     => 'price',
            'value'   => [ 50, 200 ],
            'compare' => 'BETWEEN',
            'type'    => 'NUMERIC'
        ],
        [
            'key'   => 'in_stock',
            'value' => 1
        ]
    ]
] );

// ✅ Good: OR conditions
$query = new WP_Query( [
    'post_type'  => 'post',
    'meta_query' => [
        'relation' => 'OR', // Any condition matches
        [
            'key'   => 'featured',
            'value' => 1
        ],
        [
            'key'   => 'promoted',
            'value' => 1
        ]
    ]
] );

// Compare operators: '=', '!=', '>', '>=', '<', '<=', 'LIKE', 'NOT LIKE', 'IN', 'NOT IN', 'BETWEEN', 'LIKE', 'REGEXP'
// Types: 'CHAR', 'NUMERIC', 'DATE', 'DATETIME'
```

### Performance with Meta Queries

Meta queries can be slow without proper indexing:

```php
// ✅ Good: Index frequently-queried meta keys
add_action( 'init', function() {
    // Tell WordPress to index these meta keys
    // (WordPress automatically handles indexing for registered keys)
} );

// ⚠️ Warning: Complex meta queries without index are slow
// If querying on multiple meta keys frequently, consider:
// 1. Using custom database tables
// 2. Denormalizing data
// 3. Using get_posts() with meta caching

// ✅ Good: Cache complex queries
$query_key = md5( 'complex_products_' . wp_json_encode( $args ) );
$results = get_transient( $query_key );

if ( ! $results ) {
    $query = new WP_Query( $args );
    $results = $query->get_posts();
    set_transient( $query_key, $results, HOUR_IN_SECONDS );
}
```

## Taxonomy Queries

Query by taxonomies (categories, tags, custom):

```php
// ✅ Good: Single term
$query = new WP_Query( [
    'post_type' => 'post',
    'tax_query' => [
        [
            'taxonomy' => 'category',
            'field'    => 'slug',  // 'slug', 'name', 'term_id'
            'terms'    => 'news'
        ]
    ]
] );

// ✅ Good: Multiple terms (OR)
$query = new WP_Query( [
    'post_type' => 'post',
    'tax_query' => [
        [
            'taxonomy' => 'category',
            'field'    => 'slug',
            'terms'    => [ 'news', 'updates' ], // Match any term
            'operator' => 'IN' // Default: 'IN' (matches any)
        ]
    ]
] );

// ✅ Good: Multiple taxonomies (AND)
$query = new WP_Query( [
    'post_type' => 'product',
    'tax_query' => [
        'relation' => 'AND', // Posts must match all taxonomies
        [
            'taxonomy' => 'product_category',
            'field'    => 'slug',
            'terms'    => 'electronics'
        ],
        [
            'taxonomy' => 'product_brand',
            'field'    => 'slug',
            'terms'    => 'apple'
        ]
    ]
] );
```

## Using wpdb for Custom Queries

For complex queries beyond WP_Query capabilities:

```php
// ✅ Good: Simple custom query
global $wpdb;

$results = $wpdb->get_results( $wpdb->prepare(
    "SELECT p.ID, p.post_title
     FROM {$wpdb->posts} AS p
     WHERE p.post_type = %s AND p.post_status = %s",
    'post',
    'publish'
) );

foreach ( $results as $result ) {
    echo $result->post_title;
}

// ✅ Good: Query with LIMIT
$posts = $wpdb->get_results( $wpdb->prepare(
    "SELECT * FROM {$wpdb->posts} WHERE post_type = %s LIMIT %d, %d",
    'post',
    0,   // offset
    10   // limit
) );

// ✅ Good: Get single value
$count = $wpdb->get_var(
    "SELECT COUNT(*) FROM {$wpdb->posts} WHERE post_status = 'publish'"
);

// ✅ Good: Get single row
$post = $wpdb->get_row( $wpdb->prepare(
    "SELECT * FROM {$wpdb->posts} WHERE ID = %d",
    $post_id
) );

// ❌ Avoid: String concatenation (SQL injection risk)
$results = $wpdb->get_results( "SELECT * FROM {$wpdb->posts} WHERE ID = {$_GET['id']}" );

// ❌ Avoid: Missing PREPARE
$results = $wpdb->get_results( "SELECT * FROM {$wpdb->posts} WHERE post_title = '{$title}'" );
```

## Avoiding N+1 Query Problem

```php
// ❌ Bad: N+1 queries (one query per post)
$posts = get_posts( [ 'posts_per_page' => 10 ] );
foreach ( $posts as $post ) {
    $author = get_user_by( 'id', $post->post_author ); // Extra query per post
    echo $author->display_name;
}

// ✅ Good: Cache post and term data
$posts = get_posts( [
    'posts_per_page' => 10,
    'update_post_meta_cache' => false,
    'update_post_term_cache' => false
] );

// Warm up caches
update_post_meta_cache( wp_list_pluck( $posts, 'ID' ) );
update_post_term_cache( wp_list_pluck( $posts, 'ID' ) );

foreach ( $posts as $post ) {
    $author = get_user_by( 'id', $post->post_author ); // Uses cache
    echo $author->display_name;
}

// ✅ Good: Use custom query to join data
$posts_with_authors = $wpdb->get_results(
    "SELECT p.*, u.display_name
     FROM {$wpdb->posts} p
     JOIN {$wpdb->users} u ON p.post_author = u.ID
     WHERE p.post_status = 'publish'
     LIMIT 10"
);
```

## Query Performance

```php
// ✅ Good: Use pre_get_posts to modify queries
add_action( 'pre_get_posts', function( $query ) {
    if ( is_admin() || ! $query->is_main_query() ) {
        return;
    }

    // Modify query before execution
    if ( is_archive() ) {
        $query->set( 'posts_per_page', 20 );
        $query->set( 'orderby', 'date' );
    }
} );

// ✅ Good: Cache query results
$cache_key = 'featured_posts_' . md5( wp_json_encode( $args ) );
$posts = get_transient( $cache_key );

if ( ! $posts ) {
    $posts = get_posts( $args );
    set_transient( $cache_key, $posts, DAY_IN_SECONDS );
}

// ✅ Good: Limit fields if you don't need all
$posts = $wpdb->get_results(
    "SELECT ID, post_title, post_date FROM {$wpdb->posts} LIMIT 100"
);
```

## Pagination

```php
// ✅ Good: WP_Query pagination
$page = get_query_var( 'paged' ) ?: 1;

$query = new WP_Query( [
    'post_type'      => 'post',
    'posts_per_page' => 10,
    'paged'          => $page
] );

// Display paginate_links
echo paginate_links( [
    'total'   => $query->max_num_pages,
    'current' => $page
] );

// ✅ Good: Custom pagination
$total_posts = $wpdb->get_var(
    "SELECT COUNT(*) FROM {$wpdb->posts} WHERE post_status = 'publish'"
);

$posts_per_page = 10;
$total_pages = ceil( $total_posts / $posts_per_page );
$offset = ( $page - 1 ) * $posts_per_page;

$posts = $wpdb->get_results( $wpdb->prepare(
    "SELECT * FROM {$wpdb->posts}
     WHERE post_status = %s
     ORDER BY post_date DESC
     LIMIT %d, %d",
    'publish',
    $offset,
    $posts_per_page
) );
```

## Related Standards

- {{standards/global/security}} - SQL injection prevention
- {{standards/backend/post-types-taxonomies}} - Custom post types and taxonomies
- {{standards/global/performance}} - Query caching and optimization
