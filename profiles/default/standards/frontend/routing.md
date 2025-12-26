## Routing Best Practices

### URL Design

- **Semantic URLs**: URLs should be human-readable and describe the resource (e.g., `/users/123/profile`)
- **Consistent Patterns**: Use consistent naming conventions across all routes (`kebab-case` preferred)
- **RESTful Structure**: Follow REST conventions for resource-based routes (`/resource/:id/action`)
- **Avoid Query Strings for Core Navigation**: Use path segments for primary navigation, query params for filtering/sorting

### Route Organization

- **Hierarchical Structure**: Organize routes to reflect the logical hierarchy of the application
- **Route Grouping**: Group related routes together for better code organization
- **Lazy Loading**: Load route components on-demand to improve initial bundle size
- **Route Guards**: Implement authentication/authorization checks at the route level

### Navigation Patterns

- **Programmatic Navigation**: Use router APIs for navigation triggered by code (redirects, form submissions)
- **Declarative Navigation**: Use link components for user-initiated navigation
- **History Management**: Understand and properly use `push`, `replace`, and `back` operations
- **Scroll Restoration**: Handle scroll position appropriately on navigation

### State in URLs

- **URL as Source of Truth**: Encode important UI state in URL for shareability and bookmarking
- **Query Parameters**: Use for filtering, sorting, pagination, and other transient state
- **Hash Fragments**: Use for in-page navigation or client-side-only state
- **URL Synchronization**: Keep URL and application state in sync bidirectionally

### Error Handling

- **404 Pages**: Implement catch-all routes for unmatched URLs
- **Error Boundaries**: Handle errors during route transitions gracefully
- **Redirects**: Set up proper redirects for moved or deprecated routes
- **Loading States**: Show appropriate loading indicators during route transitions

### Performance

- **Code Splitting**: Split code at route boundaries for optimal loading
- **Prefetching**: Prefetch likely next routes on hover or viewport entry
- **Caching**: Cache route data where appropriate to improve navigation speed
- **Transition Animations**: Keep animations smooth and non-blocking

### Security

- **Authentication Routes**: Protect sensitive routes with proper auth checks
- **Data Validation**: Validate URL parameters before using them
- **Sanitization**: Sanitize URL-derived data to prevent injection attacks
- **HTTPS**: Ensure all routes are served over secure connections
