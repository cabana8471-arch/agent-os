## Performance best practices

- **Measure Before Optimizing**: Profile and identify bottlenecks before optimizing; avoid premature optimization
- **Core Web Vitals**: Target LCP < 2.5s, FID/INP < 100ms, CLS < 0.1 for user-facing pages
- **Lazy Loading**: Defer loading of non-critical resources (images, components, scripts) until needed
- **Code Splitting**: Split JavaScript bundles by route or feature for faster initial page loads
- **Image Optimization**: Use modern formats (WebP, AVIF), appropriate sizing, and responsive images
- **Caching Strategy**: Implement appropriate HTTP cache headers; leverage CDN caching for static assets
- **Database Query Performance**: Monitor and optimize slow queries; batch operations when possible (see queries.md)
- **Bundle Size Monitoring**: Track and limit JavaScript bundle sizes; remove unused dependencies
- **API Response Times**: Target p95 response times under 500ms for user-facing endpoints
- **Memory Management**: Avoid memory leaks; clean up event listeners and subscriptions

## Related Standards
- `global/logging.md` - Performance logging thresholds
- `backend/queries.md` - Query optimization
- `frontend/responsive.md` - Core Web Vitals
- `frontend/css.md` - CSS optimization
