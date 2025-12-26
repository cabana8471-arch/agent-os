## Security best practices

> **Related Standards**: See `validation.md` for input sanitization, `error-handling.md` for safe error responses, `logging.md` for sensitive data logging rules.

- **Authentication Standards**: Use secure authentication frameworks (OAuth2, JWT with proper expiry, secure session handling). Recommended: Passport.js, NextAuth, Auth0, Clerk
- **Authorization**: Implement role-based access control (RBAC) or attribute-based access control (ABAC) at API level
- **HTTPS Enforcement**: Enforce HTTPS in production environments; redirect HTTP to HTTPS automatically
- **Secrets Management**: Use environment variables or dedicated secret managers (AWS Secrets Manager, HashiCorp Vault, Doppler); never hardcode credentials
- **Secret Rotation**: Rotate secrets periodically (API keys: 90 days, database passwords: 30 days); implement zero-downtime rotation
- **CORS Configuration**: Whitelist specific allowed origins; avoid wildcard (*) in production environments
- **CSRF Protection**: Implement CSRF tokens for all state-changing operations in web applications
- **Rate Limiting**: Implement rate limiting per user/IP to prevent abuse and brute-force attacks
- **SQL Injection Prevention**: Use parameterized queries exclusively (see `queries.md`)
- **XSS Prevention**: Sanitize and escape all user-generated content before rendering; use Content Security Policy headers (see `validation.md` for sanitization)
- **Dependency Security**: Audit dependencies weekly using `npm audit`, Snyk, or Dependabot; address critical vulnerabilities within 24 hours
- **Sensitive Data Logging**: Never log passwords, tokens, API keys, or personally identifiable information (PII) - see `logging.md`
- **Security Headers**: Implement security headers (X-Content-Type-Options, X-Frame-Options, Strict-Transport-Security)
- **Audit Logging**: Log security-relevant events (login attempts, permission changes, data access) to immutable audit trail for compliance
