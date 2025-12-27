## API endpoint standards and conventions

> **Related Standards**: See `global/validation.md` for input validation, `global/error-handling.md` for error response patterns, `global/security.md` for authentication/authorization.

- **RESTful Design**: Follow REST principles with clear resource-based URLs and appropriate HTTP methods (GET, POST, PUT, PATCH, DELETE)
- **Consistent Naming**: Use consistent, lowercase, hyphenated or underscored naming conventions for endpoints across the API
- **Versioning**: Implement API versioning strategy (URL path or headers) to manage breaking changes without disrupting existing clients
- **Deprecation Strategy**: Announce deprecations 6+ months in advance; include `Deprecation` header with sunset date; maintain deprecated endpoints until sunset
- **Plural Nouns**: Use plural nouns for resource endpoints (e.g., `/users`, `/products`) for consistency
- **Nested Resources**: Limit nesting depth to 2-3 levels maximum to keep URLs readable and maintainable
- **Query Parameters**: Use query parameters for filtering, sorting, pagination, and search rather than creating separate endpoints
- **HTTP Status Codes**: Return appropriate, consistent HTTP status codes that accurately reflect the response (200, 201, 400, 404, 500, etc.) - see `global/error-handling.md` for error categories
- **Rate Limiting Headers**: Include rate limit information in response headers to help clients manage their usage
- **Consistent Response Format**: Use consistent JSON structure for all responses:
  ```json
  {
    "data": { ... },
    "meta": { "page": 1, "total": 100 },
    "errors": []
  }
  ```
- **Error Response Structure**: Include error code, human-readable message, and field-level details:
  ```json
  {
    "errors": [{
      "code": "VALIDATION_ERROR",
      "message": "Invalid email format",
      "field": "email"
    }]
  }
  ```
- **Pagination**: Use cursor-based pagination for large datasets; offset-based for smaller, static lists
- **Date/Time Format**: Use ISO 8601 format in UTC for all date/time fields (e.g., "2024-01-15T10:30:00Z")
- **Request ID**: Include unique request ID in responses for debugging and correlation with logs
- **Content Negotiation**: Support `Accept` header for response format; default to JSON
