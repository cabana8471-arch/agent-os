## Error handling best practices

> **Related Standards**: See `logging.md` for structured error logging, `security.md` for safe error messages, `api.md` for HTTP error responses.

- **User-Friendly Messages**: Provide clear, actionable error messages to users without exposing technical details or security information
- **Fail Fast and Explicitly**: Validate input and check preconditions early; fail with clear error messages rather than allowing invalid state
- **Specific Exception Types**: Use specific exception/error types rather than generic ones to enable targeted handling
- **Centralized Error Handling**: Handle errors at appropriate boundaries (e.g., Express middleware, API gateway, React error boundary) rather than scattering try-catch blocks
- **Graceful Degradation**: When non-critical services fail, continue with reduced functionality (e.g., show cached data, disable feature, use fallback) rather than crashing entirely
- **Retry Strategies**: Implement exponential backoff for transient failures in external service calls
- **Clean Up Resources**: Always clean up resources (file handles, connections) in finally blocks or equivalent mechanisms
- **Error Propagation**: Let errors bubble up to boundary handlers; avoid swallowing exceptions silently
- **Error Boundaries (Frontend)**: Implement UI error boundaries to catch and display component failures gracefully
- **Error Correlation**: Include request ID and correlation ID in error responses for debugging across services (see `logging.md` for correlation ID patterns)
- **Error Categories**: Distinguish between client errors (4xx - invalid input) and server errors (5xx - system failures) in logging and handling
- **Recoverable vs Fatal**: Differentiate between recoverable errors (retry possible) and fatal errors (fail fast)
- **Error Context**: Log full context (user, request, stack trace) for debugging while showing safe messages to users (see `logging.md` for structured logging)
