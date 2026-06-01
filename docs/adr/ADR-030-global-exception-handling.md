# ADR-030. Global Exception Handling with Mapped HTTP Status Codes

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend requires consistent error responses across 14+ microservices. With 400+ API endpoints, ad-hoc exception handling in each controller would result in inconsistent HTTP status codes, error formats, and client behavior.

**Current implementation:**
- `ErrorHandlingMiddleware` in `Core.Middleware` catches all unhandled exceptions
- Exception-to-status-code mapping dictionary:
  | Exception Type | HTTP Status | Message |
  |---------------|-------------|---------|
  | `UniqueKeyException` | 409 Conflict | "Unique key constraint violated" |
  | `RecordNotFoundException` | 404 Not Found | "Record not found" |
  | `OptimisticConcurrencyException` | 409 Conflict | "Optimistic concurrency conflict" |
  | `UnauthorizedAccessException` | 401 Unauthorized | "Unauthorized access" |
  | `ForbiddenException` | 403 Forbidden | "Access denied" |
  | `ValidationException` | 400 Bad Request | Actual exception message |
  | `InvalidOperationException` | 400 Bad Request | Actual exception message |
  | All others | 500 Internal Server Error | Inner exception messages |
- Standardized `ErrorResponse` JSON format with `message`, `statusCode`, `errors`, `correlationId`
- Correlation ID from `CorrelationIdMiddleware` included in error responses
- Serilog logging of full exception details (including stack trace for 500 errors)

## Decision

We use a **centralized exception mapping middleware**:

1. **Single middleware**: `ErrorHandlingMiddleware` registered in all services via `UseApplicationCoreMiddleware()`
2. **Exception dictionary**: Type-to-status-code mapping for known domain exceptions
3. **Standardized response**: `ErrorResponse` JSON format consistent across all services
4. **Correlation ID propagation**: Every error response includes the request correlation ID
5. **Logging**: Full exception details (message + stack trace) logged via Serilog

## Consequences

**Positive:**
- Consistent error responses across all 14+ services
- Client applications can rely on stable HTTP status codes
- Correlation ID enables cross-service error tracing
- No try/catch boilerplate required in controllers
- Security: Generic 500 messages for unhandled exceptions (actual details in logs only)

**Negative:**
- **Dictionary-based mapping**: Adding a new exception type requires modifying `ErrorHandlingMiddleware` in Core (centralized bottleneck)
- **All unhandled exceptions become 500**: No distinction between transient failures (service unavailable) and permanent errors (bad configuration)
- **Inner exception messages exposed for 500**: `GetAllInnerExceptionMessages()` concatenates all inner exception messages — may leak sensitive information in some edge cases
- **No problem details (RFC 7807)**: Error response is custom format, not standard ProblemDetails
- **No retry guidance**: 500 errors do not indicate whether client should retry (no `Retry-After` header)

**Future constraints:**
- Consider implementing `IExceptionFilter` or `IProblemDetailsWriter` for ASP.NET Core native problem details support
- Add exception type for transient failures (503 Service Unavailable with retry guidance)
- Review inner exception message exposure for potential information leakage
- Document all exception types and their HTTP mappings for API consumers

## Related ADRs

- ADR-015: Missing observability (error rate metrics not instrumented)
- ADR-013: Dual JSON serializer (error responses use System.Text.Json)
