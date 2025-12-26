# WordPress Theme Development

## Theme Structure

```
my-theme/
├── style.css              # Theme header + main styles
├── index.php              # Fallback template
├── home.php               # Homepage template
├── single.php             # Single post template
├── archive.php            # Archive template
├── page.php               # Page template
├── 404.php                # 404 page
├── header.php             # Header template part
├── footer.php             # Footer template part
├── sidebar.php            # Sidebar template part
├── functions.php          # Theme functions & hooks
├── screenshot.png         # Theme preview (1200x900)
├── assets/
│   ├── css/
│   │   └── main.css
│   ├── js/
│   │   └── main.js
│   └── images/
│       └── logo.png
├── template-parts/        # Reusable template parts
│   ├── header/
│   ├── footer/
│   └── content/
└── inc/                   # Theme functionality modules
    ├── customizer.php     # Theme customizer
    ├── template-tags.php  # Custom template tags
    └── walkers.php        # Custom walkers
```

## Theme File Header

```php
// ✅ Good: Theme style.css header
/*
Theme Name: My Awesome Theme
Theme URI: https://example.com/my-theme
Author: Your Name
Author URI: https://example.com
Description: A beautiful, modern WordPress theme
Version: 1.0.0
License: GPL v2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html
Text Domain: my-theme
Domain Path: /languages
Requires at least: 5.0
Requires PHP: 7.4
Tags: blog, portfolio, business, dark
*/
```

## Template Hierarchy & Tags

```php
// ✅ Good: Basic template structure
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
    <?php wp_body_open(); ?>

    <?php get_header(); ?>

    <main id="main" role="main">
        <?php
        if ( have_posts() ) {
            while ( have_posts() ) {
                the_post();
                get_template_part( 'template-parts/content' );
            }
            the_posts_pagination();
        } else {
            get_template_part( 'template-parts/content', 'none' );
        }
        ?>
    </main>

    <?php get_sidebar(); ?>
    <?php get_footer(); ?>

    <?php wp_footer(); ?>
</body>
</html>
```

## Theme Setup in functions.php

```php
// ✅ Good: Theme setup
add_action( 'after_setup_theme', function() {
    // Enable title tag
    add_theme_support( 'title-tag' );

    // Enable featured images
    add_theme_support( 'post-thumbnails' );
    set_post_thumbnail_size( 200, 200, true );
    add_image_size( 'hero', 1920, 1080, true );

    // Enable block editor features
    add_theme_support( 'wp-block-styles' );
    add_theme_support( 'align-wide' );

    // Register nav menus
    register_nav_menus( [
        'primary'  => esc_html__( 'Primary Menu', 'my-theme' ),
        'social'   => esc_html__( 'Social Links', 'my-theme' ),
    ] );

    // Load text domain
    load_theme_textdomain( 'my-theme', get_template_directory() . '/languages' );
} );

// ✅ Good: Enqueue scripts and styles
add_action( 'wp_enqueue_scripts', function() {
    wp_enqueue_style( 'my-theme-style', get_stylesheet_uri() );
    wp_enqueue_script( 'my-theme-script', get_template_directory_uri() . '/assets/js/main.js', [ 'jquery' ], '1.0.0', true );
} );

// ✅ Good: Enqueue admin styles
add_action( 'admin_enqueue_scripts', function() {
    wp_enqueue_style( 'my-theme-admin', get_template_directory_uri() . '/assets/css/admin.css' );
} );
```

## Template Parts

```php
// ✅ Good: Reusable template parts
// template-parts/content.php
<article <?php post_class(); ?>>
    <header class="entry-header">
        <?php the_title( '<h1 class="entry-title">', '</h1>' ); ?>
        <div class="entry-meta">
            <?php echo esc_html( get_the_date() ); ?>
        </div>
    </header>

    <div class="entry-content">
        <?php the_content( esc_html__( 'Read More', 'my-theme' ) ); ?>
    </div>
</article>

// ✅ Good: Use with parameters
<?php get_template_part( 'template-parts/post-card', 'featured', [
    'post_id' => get_the_ID(),
    'show_excerpt' => true
] ); ?>
```

## Customizer Support

```php
// ✅ Good: Add customizer settings
add_action( 'customize_register', function( $wp_customize ) {
    $wp_customize->add_setting( 'my_theme_primary_color', [
        'default'           => '#0066cc',
        'sanitize_callback' => 'sanitize_hex_color'
    ] );

    $wp_customize->add_control( 'my_theme_primary_color', [
        'label'    => 'Primary Color',
        'section'  => 'colors',
        'type'     => 'color'
    ] );
} );

// ✅ Good: Use customizer setting in CSS
function my_theme_custom_css() {
    $color = get_theme_mod( 'my_theme_primary_color', '#0066cc' );
    echo '<style>:root { --primary-color: ' . esc_attr( $color ) . '; }</style>';
}
add_action( 'wp_head', 'my_theme_custom_css' );
```

## Conditional Tags

```php
// ✅ Good: Use conditional tags for template logic
<?php if ( is_home() ) : ?>
    <h1><?php esc_html_e( 'Latest Posts', 'my-theme' ); ?></h1>
<?php elseif ( is_archive() ) : ?>
    <h1><?php the_archive_title(); ?></h1>
<?php elseif ( is_single() ) : ?>
    <h1><?php the_title(); ?></h1>
<?php endif; ?>

// Other useful conditions:
// is_front_page() - Homepage
// is_page() - Single page
// is_single() - Single post
// is_archive() - Archive page
// is_search() - Search results
// is_404() - 404 page
```

## Child Themes

```php
// ✅ Good: Child theme functions.php
<?php
// Enqueue parent theme stylesheet
add_action( 'wp_enqueue_scripts', function() {
    wp_enqueue_style( 'parent-style', get_template_directory_uri() . '/style.css' );
} );

// Add child theme styles
add_action( 'wp_enqueue_scripts', function() {
    wp_enqueue_style( 'child-style', get_stylesheet_uri() );
}, 10 );

// Add child theme functionality
// ...
```

## Best Practices

- **Mobile-first**: Design for mobile, enhance for desktop
- **Accessibility**: Semantic HTML, ARIA labels, keyboard navigation
- **Performance**: Optimize images, lazy load, minimize requests
- **Translation**: Use `__()` and `_e()` for all strings
- **Customization**: Use Customizer API for theme options

## Related Standards

- {{standards/frontend/accessibility}} - Accessible templates
- {{standards/global/coding-style}} - PHP conventions
- {{standards/global/security}} - Secure theme practices
