# WordPress Project Tech Stack Planning

## Platform & Core

- **WordPress**: 6.x LTS (latest stable)
- **PHP**: 8.0+ (8.2+ recommended)
- **MySQL/MariaDB**: 8.0+
- **Web Server**: Apache 2.4+ or Nginx

## Theme & Frontend

### Theme Approach (Pick one)

**Option 1: Custom Theme from Scratch**
- Start fresh, minimal dependencies
- Full control over features
- Learn WordPress well

**Option 2: Starter Theme (Underscores/_s)**
- Modern boilerplate
- Best practices built-in
- Faster setup

**Option 3: Sage (Laravel-based)**
- Modern development experience
- Composer, build tools
- More professional workflow

### Styling

- **CSS Framework**: Tailwind CSS (recommended)
- **Build Tool**: @wordpress/scripts or custom webpack

### JavaScript

- **React Blocks**: Yes (for block editor)
- **Alpine.js**: Optional (lightweight interactivity)
- **jQuery**: Avoid (legacy, use vanilla JS)

## Functionality

### Custom Post Types & Taxonomies

- Identify what content types needed
- Plan metadata for each CPT
- REST API exposure for headless

### Core Plugins (Only if necessary)

**Avoid bloat - use only what's needed:**
- **ACF Pro** (if complex meta fields needed)
- **WooCommerce** (if selling products)
- **Jetpack/Akismet** (if comment spam issue)

### Development Approach

- **Theme**: Custom code
- **Plugins**: Minimal, necessary only
- **Must-haves**: Security plugin (Wordfence/Sucuri)

## Developer Tools

### Local Development

- **Local**: Easiest setup (recommended)
- **Docker**: Flexible, reproducible
- **XAMPP/WAMP**: Simple alternative

### Build & Asset Pipeline

- **@wordpress/scripts**: Modern WordPress tooling (recommended)
- **Build CSS/JS**: Compile modern code for browser compatibility
- **Minification**: Automatic in production builds

### Version Control & Deployment

- **Git**: Always
- **Exclude**: wp-content/uploads, wp-config.php
- **Deployment**: Manual SFTP or CI/CD

### Database

- **MySQL/MariaDB**: Standard
- **Local**: Use Local.app or Docker
- **Backups**: Regular, automated if possible

## Gutenberg Block Development

### If using modern block editor:

- **@wordpress/scripts**: Build tool
- **React**: For block UI (optional)
- **JavaScript**: Block registration and logic
- **block.json**: Metadata and configuration

### Block Development Stack

```json
{
  "devDependencies": {
    "@wordpress/scripts": "latest",
    "@wordpress/block-editor": "latest",
    "@wordpress/components": "latest"
  }
}
```

## Code Quality

### PHP Code Standards

- **PHPCS**: WordPress Coding Standards
- **PHP_CodeSniffer**: Automated checking
- **PHPUnit**: Unit testing (if needed)

### JavaScript Code Standards

- **ESLint**: Code quality
- **Prettier**: Code formatting
- **Jest**: Unit testing

## Hosting & Deployment

### Hosting Options (Pick one)

**Managed WordPress Hosting (Recommended)**
- WP Engine, Kinsta, Flywheel
- Automatic updates, backups, security
- Better performance, support

**Shared Hosting**
- Cheaper
- Limited control, slower
- Good for simple sites

**VPS/Dedicated**
- Full control
- Requires management
- Good for complex sites

### Deployment Strategy

- **Staging**: Test before production
- **CI/CD**: GitHub Actions for automated deployments
- **Backups**: Automated daily backups
- **CDN**: Optional, for media files

## Performance Tools

- **WP Super Cache**: Page caching
- **Imagify/ShortPixel**: Image optimization
- **Pingdom/GTmetrix**: Performance monitoring
- **Query Monitor**: Debug queries

## Security Essentials

- **Wordfence/Sucuri**: Security monitoring
- **Two-Factor Auth**: For admin accounts
- **SSL/HTTPS**: Always encrypted
- **Backups**: Regular, tested restores

## Summary Tech Stack (Recommended)

```
WordPress 6.x
PHP 8.2+
MySQL 8.0+
Nginx/Apache

Theme: Custom or Sage
Styling: Tailwind CSS
Blocks: React + Gutenberg
Build: @wordpress/scripts
Version Control: Git
Local Dev: Local.app
Hosting: WP Engine / Kinsta
Performance: WP Super Cache
Security: Wordfence
```

## Nice-to-Have (Not Essential)

- WooCommerce (if selling)
- ACF (if complex custom fields)
- Multisite (if multiple properties)
- GraphQL (headless WP)

## Related Standards

- {{standards/global/tech-stack}} - Tech requirements
- {{standards/frontend/themes}} - Theme development
- {{standards/frontend/blocks}} - Block development
- {{standards/backend/plugins}} - Plugin creation
