# ADR-005. Centralized Audit Enrichment with Outbox Pattern

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform requires comprehensive, tamper-evident audit logging across all 14 microservices. The existing audit implementation has critical reliability and observability gaps that violate compliance and operational requirements:

- **Fire-and-forget publishing**: `AuditPublisherService` uses `Task.Run` to publish audit messages, risking silent message loss under load or during process termination.
- **Missing user context resolution**: `Identity.Name` is used directly instead of the canonical `IUserContextService`, leading to inconsistent user attribution (especially for service-account and batch operations).
- **No correlation ID enrichment**: Audit records lack correlation IDs, making cross-service request tracing impossible.
- **Empty exception handling**: `SRSDbContext` contains empty `catch` blocks that swallow audit enrichment failures silently.
- **Ack-on-failure consumer**: `AuditConsumer` acknowledges RabbitMQ messages even when processing fails, causing data loss.
- **Unredacted request bodies**: `ApiAuditMiddleware` buffers request/response payloads without PII redaction, creating a data-protection risk.
- **Missing pipeline coverage**: Handlers such as `MoveToPickLocationCommandHandler` perform direct data mutations without routing through `IAuditPublisherService`, leaving audit gaps.
- **No dead-letter handling**: Failed audit messages have no retry or dead-letter queue path.

Key constraints:
- Audit must not block the critical business path (store operations, replenishment)
- Messages must survive service restarts and network partitions
- PII (personally identifiable information) must be redacted before logging
- Correlation IDs must propagate across HTTP, RabbitMQ, and WebSocket boundaries
- Existing database-per-service policy (ADR-002) remains in force

## Decision

We will implement a **Centralized Audit Enrichment** architecture built on the **Transactional Outbox pattern** with the following components:

1. **EF Core SaveChanges Interception (`AuditInterceptor`)**
   - Hook into `SaveChangesAsync` across all service `DbContext` implementations.
   - Enrich audit entries with the authenticated user (`IUserContextService`), correlation ID (`ICorrelationIdAccessor`), and timestamp.
   - Persist enriched audit records into an **Outbox table** within the same database transaction as business data changes, guaranteeing atomicity.
   - Remove empty `catch` blocks; all enrichment failures propagate to the caller or are explicitly logged and handled.

2. **Transactional Outbox Publisher (`OutboxPublisherService`)**
   - Replace fire-and-forget `Task.Run` in `AuditPublisherService` with a durable outbox processor.
   - The processor polls the outbox table at a configurable interval and publishes batched messages to RabbitMQ.
   - Messages are marked as "processed" only after successful broker acknowledgment.
   - Unacknowledged messages remain in the outbox for retry, preventing silent loss.

3. **MediatR Pipeline Behavior (`AuditBehavior<TRequest,TResponse>`)**
   - Register a MediatR pipeline behavior that wraps every command and query handler.
   - Automatically capture handler metadata (request type, duration, success/failure) and emit audit events via `IAuditPublisherService`.
   - Ensure handlers that currently bypass the pipeline (e.g., direct DB writes) are refactored to use MediatR or explicitly call the audit service.

4. **Request/Response Redaction Middleware (`ApiAuditMiddleware`)**
   - Retain request/response buffering only for audit-eligible endpoints (skip static files, health checks, large binary uploads).
   - Apply configurable field-level redaction (e.g., `password`, `pin`, `ssn`) before writing payloads to the audit store.
   - Use a whitelist of safe content types to avoid buffering multipart/form-data or large streams.

5. **Correlation ID Propagation (`CorrelationIdMiddleware`)**
   - Generate or reuse `X-Correlation-Id` from incoming HTTP headers.
   - Push the correlation ID into Serilog `LogContext` so every log entry includes it.
   - Propagate the correlation ID across RabbitMQ message headers and outgoing HTTP client calls via `Core.HttpClient` policies.

6. **Dead Letter Queue (DLQ) and Retry Policy**
   - Configure RabbitMQ with a dedicated DLQ for the audit exchange.
   - Set bounded retries (e.g., 3 attempts with exponential backoff) before routing to the DLQ.
   - Implement an alert/monitoring hook (Prometheus metric or log-based alert) for DLQ depth.

7. **Reference Resolver (`IAuditReferenceResolver`)**
   - Introduce a pluggable resolver that maps raw entity IDs (e.g., `ProductId = 42`) to human-readable business references (e.g., `SKU = WINE-1234`) at enrichment time.
   - Each domain service implements its own resolver and registers it in DI.

## Consequences

**Positive:**
- **Guaranteed delivery**: Audit messages are transactionally bound to business operations; no silent loss on restart or network failure.
- **End-to-end traceability**: Correlation IDs link HTTP requests, MediatR handlers, database changes, and RabbitMQ messages across all services.
- **PII protection**: Configurable redaction prevents sensitive data from leaking into audit logs and Elasticsearch.
- **Operational resilience**: DLQ and retry policies provide clear failure visibility instead of silent drops.
- **Consistent attribution**: `IUserContextService` ensures user identity is correct for human users, service accounts, and batch jobs.
- **Pluggable references**: `IAuditReferenceResolver` allows business-friendly audit narratives without bloating the core schema.

**Negative:**
- **Write amplification**: Every business transaction now writes to both the business table and the outbox table, increasing database load.
- **Latency increase**: Outbox polling and MediatR pipeline behaviors add a small but measurable latency to request processing (estimated <10ms for typical commands).
- **Operational complexity**: Teams must monitor outbox backlog depth, DLQ depth, and processor health as new operational metrics.
- **Storage overhead**: Outbox and DLQ tables grow until processed; retention policies must be defined.
- **Refactoring burden**: Handlers with direct `DbContext` mutations (e.g., `MoveToPickLocationCommandHandler`) and controllers missing `[UserAction]` (e.g., `PrintController`) must be updated.

**Future constraints:**
- Any change to the audit event schema requires a coordinated migration across all 14 service databases.
- New PII fields introduced in APIs must be registered in the redaction configuration before go-live.
- Outbox processor must run as a hosted service or background worker in every service; it cannot be omitted.
- Superseding this ADR requires a new ADR per the ADR discipline policy.

---

## References

- `WingYip_SRS_BE_EcoSystem/docs/Audit Analysis/AUDIT_IMPLEMENTATION_PLAN.md` — Detailed 18-section implementation plan derived from this ADR.
- `WingYip_SRS_Documents/AI_Native/architecture/adr-discipline.md` — ADR immutability and superseding rules.
- ADR-002 (Database-Per-Service) — Outbox tables must reside in each service's own database.
- ADR-001 (Microservices Architecture) — CQRS and MediatR pipeline behaviors are foundational to this decision.
