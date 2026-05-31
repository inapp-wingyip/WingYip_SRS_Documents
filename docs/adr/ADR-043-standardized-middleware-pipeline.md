# ADR-043. Standardized Middleware Pipeline and DI Bootstrap

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

Every microservice in the WingYip SRS ecosystem uses the same middleware pipeline and dependency injection bootstrap, provided by the Core shared library. This standardization is enforced through two extension methods that all services call during startup.

**Middleware pipeline (in order):**
1. `CorrelationIdMiddleware` — Assigns or propagates a correlation ID for request tracing
2. `ErrorHandlingMiddleware` — Global exception handling and standardized error responses
3. `ApiAuditMiddleware` — Publishes audit events for API calls
4. `UserContextMiddleware` — Extracts user context from JWT claims
5. `UseCors("AllowAll")` — Applies the permissive CORS policy (see ADR-025)

**DI registrations via `RegisterApplicationCoreService()`:**
- `SRSService` configuration
- `RabbitMqOptions` — message broker settings
- `IDbConnectionFactory` (singleton) — database connection factory
- `IRabbitMqPublisher` (singleton) — message publishing
- `IAuditPublisherService` (scoped) — audit event publishing
- `IUserContextService` (scoped) — user context resolution
- `IRequestInvoker` factory — service-to-service HTTP invocation

**Swagger configuration:** `AddSwaggerWithJwtAuth` configures Swagger UI with JWT authentication and `StoreHeaderOperationFilter` for store-scoped API testing.

**Logging:** Serilog with Elasticsearch sink, per-environment index format for centralized log aggregation.

## Decision

We standardize the middleware pipeline and DI bootstrap across all services via the Core shared library's `UseApplicationCoreMiddleware()` and `RegisterApplicationCoreService()` extension methods.

## Consequences

**Positive:**
- Consistent behavior across all 14+ services — every service has correlation tracking, error handling, auditing, and user context
- Centralized configuration — middleware changes propagate by updating the Core library package
- Automatic audit and correlation — no service can accidentally skip these cross-cutting concerns
- Swagger with JWT auth simplifies API testing during development

**Negative:**
- Tight coupling to Core library — any middleware change affects all services
- All services are affected by middleware changes, requiring coordinated deployment
- "AllowAll" CORS policy (ADR-025) is applied universally, which is a security concern
- No opt-out mechanism — services cannot selectively exclude middleware from the pipeline
- Singleton registrations for `IDbConnectionFactory` and `IRabbitMqPublisher` may cause issues with scoped lifetime dependencies

**Future constraints:**
- Evaluate making middleware pipeline configurable (opt-in/opt-out per service)
- Address the "AllowAll" CORS policy (see ADR-025) before production
- Consider adding health check middleware to the standard pipeline
- Document the expected middleware execution order and its implications for new service developers

## Related ADRs

- ADR-025: Allow-All CORS Policy
- ADR-040: Core Shared Library Ecosystem and Monorepo Structure
- ADR-042: Permission-Based RBAC System with Cache-Aside Pattern

## Key files

- `ServiceExtension.cs`
- `CorrelationIdMiddleware.cs`
- `ErrorHandlingMiddleware.cs`
- `ApiAuditMiddleware.cs`
- `UserContextMiddleware.cs`