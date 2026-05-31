# ADR-046. API Audit and Correlation ID Observability

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform requires two complementary observability patterns to achieve full request traceability: API-level audit logging and cross-service correlation ID propagation.

**ApiAuditMiddleware:**
- Captures every API request including the full request body, then publishes the audit event to RabbitMQ via `IAuditPublisherService`
- `UserActionAttribute` provides human-readable action descriptions on controller endpoints
- Request body buffering is enabled to allow reading the body stream multiple times (once for model binding, once for audit capture)
- Audit publishing uses fire-and-forget (`Task.Run`), meaning failures are silently swallowed

**CorrelationIdMiddleware:**
- Generates a new `X-Correlation-ID` header if not present, or propagates the existing one from incoming requests
- Stores the correlation ID in `HttpContext.Items` for access within the request pipeline
- Returns the correlation ID in response headers so callers can reference it
- Included in error responses to support incident investigation
- Used for cross-service tracing across HTTP and message boundaries

**Key concerns:**
- The audit middleware captures full request bodies, which may contain PII
- Audit publishing uses `Task.Run` with empty `catch {}` blocks, risking silent message loss
- Dual audit strategy exists: API-level (this middleware) and EF-level (`AuditInterceptor` in ADR-005), potentially duplicating audit records
- Correlation IDs are HTTP-only; propagation to RabbitMQ and WebSocket channels requires additional wiring

## Decision

We implement **dual observability** via API audit middleware and correlation ID propagation:

1. **ApiAuditMiddleware** captures every HTTP request (method, path, user, request body, response status) and publishes to RabbitMQ via `IAuditPublisherService`
2. **UserActionAttribute** decorates controller actions with human-readable descriptions for audit records
3. **CorrelationIdMiddleware** generates/propagates `X-Correlation-ID` across the request pipeline, stored in `HttpContext.Items` and returned in response headers
4. Correlation IDs are included in error responses for incident correlation

## Consequences

**Positive:**
- Complete request audit trail with human-readable action descriptions
- Cross-service traceability via correlation IDs
- Correlation IDs in error responses aid incident investigation
- `UserActionAttribute` provides business-meaningful audit context

**Negative:**
- **Performance impact**: Request body buffering (`EnableBuffering`) consumes memory on every request, including large payloads
- **Silent error swallowing**: `catch {}` empty blocks in audit publishing mean audit messages can be lost without any logging or alerting
- **Dual audit strategy**: API-level audit (this middleware) and EF-level audit (`AuditInterceptor` from ADR-005) may produce duplicate records for the same operation
- **PII exposure**: Full request body capture without redaction risks logging sensitive data (passwords, tokens, personal information)
- **Fire-and-forget reliability**: `Task.Run` publishing is not durable; messages can be lost during service restarts or RabbitMQ unavailability

**Future constraints:**
- Audit middleware should integrate with the Transactional Outbox pattern (ADR-005) instead of fire-and-forget publishing
- PII redaction must be applied before audit capture (see ADR-005 redaction strategy)
- Correlation ID propagation must extend to RabbitMQ message headers and WebSocket channels for full cross-service tracing
- Empty `catch` blocks must be replaced with explicit error logging and monitoring

---

## References

- `ApiAuditMiddleware.cs` — Request audit capture and RabbitMQ publishing
- `CorrelationIdMiddleware.cs` — Correlation ID generation and propagation
- `UserActionAttribute.cs` — Human-readable action description attribute
- `IAuditPublisherService` — Audit message publishing interface
- ADR-005 (Centralized Audit Enrichment with Outbox Pattern) — EF-level audit and outbox pattern
- ADR-009 (Raw RabbitMQ Client) — RabbitMQ usage patterns