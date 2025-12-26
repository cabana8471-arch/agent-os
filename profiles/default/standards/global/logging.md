## Logging best practices

> **Related Standards**: See `error-handling.md` for error context requirements, `security.md` for sensitive data restrictions, `performance.md` for performance logging.

- **Structured Logging**: Use JSON or structured format with consistent fields (timestamp, level, message, context, request_id)
- **Log Levels**: Use appropriate levels consistently: ERROR (failures), WARN (potential issues), INFO (key events), DEBUG (development details)
- **Correlation IDs**: Include request/trace IDs in all logs for distributed tracing and debugging (see `error-handling.md` for error correlation)
- **Sensitive Data**: Never log passwords, tokens, API keys, credit card numbers, or PII (see `security.md` for complete list)
- **Actionable Context**: Include enough context to debug issues without additional queries (user_id, resource_id, operation)
- **Centralized Collection**: Ship logs to a centralized platform for aggregation, search, and alerting
- **Log Retention**: Define retention policies based on compliance requirements and storage costs (e.g., 30 days hot, 1 year cold storage)
- **Error Stack Traces**: Include full stack traces for errors, but sanitize sensitive information
- **Performance Logging**: Log slow operations with timing information for performance analysis (see `performance.md` for thresholds)
