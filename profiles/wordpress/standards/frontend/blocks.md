# WordPress Gutenberg Blocks

## Block Registration

```php
// ✅ Good: Register block with block.json
add_action( 'init', function() {
    register_block_type( __DIR__ . '/blocks/my-block' );
} );

// blocks/my-block/block.json
{
  "$schema": "https://schemas.wp.org/wp/6.0/block.json",
  "apiVersion": 2,
  "name": "my-plugin/my-block",
  "title": "My Custom Block",
  "category": "widgets",
  "icon": "star",
  "description": "A custom block for displaying content",
  "attributes": {
    "content": {
      "type": "string",
      "default": "Hello World"
    },
    "color": {
      "type": "string",
      "default": "#000000"
    }
  },
  "supports": {
    "html": false,
    "color": {
      "text": true,
      "background": true
    },
    "spacing": {
      "padding": true,
      "margin": true
    }
  },
  "editorScript": "file:./index.js",
  "editorStyle": "file:./editor.css",
  "style": "file:./style.css",
  "render": "file:./render.php"
}
```

## Block Edit Component

```typescript
// blocks/my-block/index.js (JavaScript/TypeScript)
import { registerBlockType } from '@wordpress/blocks'
import { useBlockProps, RichText } from '@wordpress/block-editor'
import { __ } from '@wordpress/i18n'

registerBlockType( 'my-plugin/my-block', {
    edit: ( { attributes, setAttributes } ) => {
        const { content, color } = attributes
        const blockProps = useBlockProps( {
            style: { color }
        } )

        return (
            <div { ...blockProps }>
                <RichText
                    value={ content }
                    onChange={ ( value ) =>
                        setAttributes( { content: value } )
                    }
                    placeholder={ __( 'Enter text here...', 'my-plugin' ) }
                />
            </div>
        )
    },

    save: ( { attributes } ) => {
        const { content, color } = attributes
        const blockProps = useBlockProps.save( {
            style: { color }
        } )

        return (
            <div { ...blockProps }>
                { content }
            </div>
        )
    }
} )
```

## Server-Side Rendering

```php
// ✅ Good: Dynamic block with PHP rendering
// block.json
{
  "name": "my-plugin/dynamic-block",
  "title": "Dynamic Block",
  "render": "file:./render.php"
}

// render.php
<?php
defined( 'ABSPATH' ) || exit;

$attributes = wp_kses_post_deep( $attributes );
$content = get_recent_posts_html();
?>

<div <?php echo wp_kses_data( get_block_wrapper_attributes() ); ?>>
    <h2><?php esc_html_e( 'Recent Posts', 'my-plugin' ); ?></h2>
    <?php echo wp_kses_post( $content ); ?>
</div>

<?php
function get_recent_posts_html() {
    $posts = get_posts( [ 'numberposts' => 5 ] );
    $html = '<ul>';

    foreach ( $posts as $post ) {
        $html .= '<li><a href="' . esc_url( get_permalink( $post ) ) . '">';
        $html .= esc_html( $post->post_title );
        $html .= '</a></li>';
    }

    $html .= '</ul>';
    return $html;
}
```

## Block Attributes & Validation

```json
{
  "attributes": {
    "title": {
      "type": "string",
      "default": "Default Title"
    },
    "count": {
      "type": "number",
      "default": 5
    },
    "items": {
      "type": "array",
      "default": []
    },
    "isVisible": {
      "type": "boolean",
      "default": true
    }
  }
}
```

```typescript
// ✅ Good: Validate attributes on save
save: ( { attributes } ) => {
    // Ensure count is valid
    const count = Math.max( 1, Math.min( attributes.count, 100 ) )

    // Validate array items
    const validItems = Array.isArray( attributes.items )
        ? attributes.items.map( ( item ) => ( {
            ...item,
            title: String( item.title )
        } ) )
        : []

    return (
        <div>
            {validItems.slice( 0, count ).map( ( item ) => (
                <div key={ item.id }>{ item.title }</div>
            ) )}
        </div>
    )
}
```

## Block Styles & Variations

```typescript
// ✅ Good: Register block style
registerBlockStyle( 'my-plugin/my-block', {
    name: 'highlighted',
    label: 'Highlighted',
    isDefault: false
} )

// In editor or frontend CSS
.wp-block-my-plugin-my-block.is-style-highlighted {
    background-color: #ffeb3b;
    padding: 16px;
}

// ✅ Good: Block variations
registerBlockVariation( 'my-plugin/my-block', {
    name: 'featured',
    title: 'Featured Item',
    attributes: {
        title: 'Featured',
        isPinned: true,
        color: '#ff0000'
    },
    scope: [ 'block' ],
    isDefault: false
} )
```

## InnerBlocks & Nesting

```typescript
// ✅ Good: Allow nested blocks
import { InnerBlocks } from '@wordpress/block-editor'

registerBlockType( 'my-plugin/container', {
    edit: ( props ) => {
        const blockProps = useBlockProps()

        return (
            <div { ...blockProps }>
                <InnerBlocks
                    allowedBlocks={ [
                        'my-plugin/item',
                        'core/paragraph'
                    ] }
                    template={ [
                        [ 'my-plugin/item' ],
                        [ 'my-plugin/item' ]
                    ] }
                />
            </div>
        )
    },

    save: ( props ) => {
        const blockProps = useBlockProps.save()

        return (
            <div { ...blockProps }>
                <InnerBlocks.Content />
            </div>
        )
    }
} )
```

## Block Patterns

```php
// ✅ Good: Register block pattern
register_block_pattern(
    'my-plugin/call-to-action',
    [
        'title'       => 'Call to Action',
        'description' => 'A call to action section',
        'content'     => '<!-- wp:group -->
            <div class="wp-block-group">
                <!-- wp:heading -->
                <h2>Ready to get started?</h2>
                <!-- /wp:heading -->
                <!-- wp:buttons -->
                <div class="wp-block-buttons">
                    <!-- wp:button -->
                    <div class="wp-block-button">
                        <a class="wp-block-button__link">Learn More</a>
                    </div>
                    <!-- /wp:button -->
                </div>
                <!-- /wp:buttons -->
            </div>
            <!-- /wp:group -->',
        'categories'  => [ 'cta' ],
        'keywords'    => [ 'call', 'action', 'cta' ]
    ]
)
```

## Build Process

```bash
# Using @wordpress/scripts
npm install @wordpress/scripts --save-dev

# package.json
{
  "scripts": {
    "build": "wp-scripts build",
    "start": "wp-scripts start"
  }
}

# Run build
npm run build    # Production build
npm start        # Development with file watching
```

## Block API Best Practices

- **Always validate attributes**: Ensure safe defaults
- **Use InnerBlocks**: For flexible, user-editable content
- **Server-side rendering**: For dynamic content
- **Block patterns**: Provide common layouts
- **Documentation**: Document custom blocks clearly

## Related Standards

- {{standards/frontend/themes}} - Template integration
- {{standards/global/coding-style}} - JavaScript conventions
- {{standards/global/security}} - Safe attribute handling
