# WordPress REST API

## Registering Custom Endpoints

```php
// ✅ Good: Register REST endpoint
add_action( 'rest_api_init', function() {
    register_rest_route(
        'myapp/v1',
        '/users/(?P<id>\d+)',
        [
            'methods'             => 'GET',
            'callback'            => 'get_user_endpoint',
            'permission_callback' => function( $request ) {
                return current_user_can( 'read' );
            },
            'args'                => [
                'id' => [
                    'type'              => 'integer',
                    'required'          => true,
                    'validate_callback' => function( $param ) {
                        return is_numeric( $param );
                    },
                    'sanitize_callback' => 'absint'
                ]
            ]
        ]
    );
} );

function get_user_endpoint( WP_REST_Request $request ) {
    $user_id = $request['id'];
    $user = get_user_by( 'ID', $user_id );

    if ( ! $user ) {
        return new WP_Error( 'not_found', 'User not found', [ 'status' => 404 ] );
    }

    return new WP_REST_Response( [
        'id'   => $user->ID,
        'name' => $user->display_name,
        'email' => $user->user_email
    ], 200 );
}
```

## POST/PUT/DELETE Operations

```php
// ✅ Good: POST endpoint with validation
register_rest_route( 'myapp/v1', '/posts', [
    'methods'  => 'POST',
    'callback' => 'create_post_endpoint',
    'permission_callback' => function() {
        return current_user_can( 'edit_posts' );
    },
    'args'     => [
        'title' => [
            'type'              => 'string',
            'required'          => true,
            'sanitize_callback' => 'sanitize_text_field',
            'validate_callback' => function( $value ) {
                return strlen( $value ) >= 3;
            }
        ],
        'content' => [
            'type'              => 'string',
            'sanitize_callback' => 'wp_kses_post'
        ],
        'status' => [
            'type'              => 'string',
            'enum'              => [ 'draft', 'publish' ],
            'sanitize_callback' => 'sanitize_text_field'
        ]
    ]
] );

function create_post_endpoint( WP_REST_Request $request ) {
    $params = $request->get_json_params();

    $post_id = wp_insert_post( [
        'post_title'   => $params['title'],
        'post_content' => $params['content'],
        'post_status'  => $params['status'] ?? 'draft',
        'post_type'    => 'post'
    ] );

    if ( is_wp_error( $post_id ) ) {
        return $post_id;
    }

    return new WP_REST_Response( [ 'id' => $post_id ], 201 );
}
```

## Custom Post Type REST Support

```php
// ✅ Good: Enable REST API for custom post type
register_post_type( 'book', [
    'labels'            => [ 'name' => 'Books' ],
    'public'            => true,
    'show_in_rest'      => true,
    'rest_base'         => 'books',
    'rest_controller_class' => 'WP_REST_Posts_Controller',
] );

// ✅ Good: Expose post meta to REST API
register_post_meta( 'post', 'book_author', [
    'type'          => 'string',
    'single'        => true,
    'show_in_rest'  => true,
    'auth_callback' => function() {
        return current_user_can( 'edit_posts' );
    }
] );

// ✅ Good: Custom REST field for post
register_rest_field( 'post', 'author_name', [
    'get_callback' => function( $post ) {
        return get_the_author_meta( 'display_name', $post['author'] );
    },
    'update_callback' => null,
    'schema' => null
] );
```

## Error Handling

```php
// ✅ Good: Return WP_Error with proper HTTP status
function get_resource_endpoint( WP_REST_Request $request ) {
    $id = $request['id'];

    if ( ! user_can_access_resource( $id ) ) {
        return new WP_Error(
            'forbidden',
            'You do not have permission to access this resource',
            [ 'status' => 403 ]
        );
    }

    $resource = get_resource( $id );

    if ( ! $resource ) {
        return new WP_Error(
            'not_found',
            'Resource not found',
            [ 'status' => 404 ]
        );
    }

    return new WP_REST_Response( $resource, 200 );
}
```

## Pagination & Filtering

```php
// ✅ Good: Support REST API pagination
register_rest_route( 'myapp/v1', '/posts', [
    'methods'  => 'GET',
    'callback' => 'list_posts_endpoint',
    'args'     => [
        'page'      => [ 'type' => 'integer', 'default' => 1 ],
        'per_page'  => [ 'type' => 'integer', 'default' => 10 ],
        'search'    => [ 'type' => 'string' ],
        'orderby'   => [ 'type' => 'string', 'default' => 'date' ],
        'order'     => [ 'type' => 'string', 'enum' => [ 'asc', 'desc' ] ]
    ]
] );

function list_posts_endpoint( WP_REST_Request $request ) {
    $page = $request['page'] ?? 1;
    $per_page = $request['per_page'] ?? 10;
    $search = $request['search'] ?? '';

    $query = new WP_Query( [
        'post_type'      => 'post',
        'posts_per_page' => $per_page,
        'paged'          => $page,
        's'              => $search,
        'orderby'        => $request['orderby'],
        'order'          => strtoupper( $request['order'] )
    ] );

    $posts = [];
    foreach ( $query->get_posts() as $post ) {
        $posts[] = [
            'id'    => $post->ID,
            'title' => $post->post_title
        ];
    }

    return new WP_REST_Response( $posts, 200 );
}
```

## Authentication

```php
// ✅ Good: Check nonce for AJAX/REST
register_rest_route( 'myapp/v1', '/delete/(?P<id>\d+)', [
    'methods'             => 'DELETE',
    'callback'            => 'delete_endpoint',
    'permission_callback' => function( $request ) {
        $nonce = $request->get_header( 'X-WP-Nonce' );
        return wp_verify_nonce( $nonce, 'wp_rest' ) &&
               current_user_can( 'delete_posts' );
    }
] );

// ✅ Good: Generate nonce in JavaScript
wp_localize_script( 'my-script', 'MyApp', [
    'nonce' => wp_create_nonce( 'wp_rest' )
] );

// Send nonce with fetch
fetch( '/wp-json/myapp/v1/delete/123', {
    method: 'DELETE',
    headers: {
        'X-WP-Nonce': MyApp.nonce
    }
} );
```

## Related Standards

- {{standards/global/security}} - API security
- {{standards/global/validation}} - Input validation
- {{standards/backend/post-types-taxonomies}} - Custom post types
