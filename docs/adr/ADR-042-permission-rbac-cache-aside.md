# ADR-042. Permission-Based RBAC System with Cache-Aside Pattern

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

Beyond the Keycloak JWT authentication covered in ADR-003, WingYip SRS implements a custom permission-based Role-Based Access Control (RBAC) system with module codes, action codes, and access levels. This system provides fine-grained authorization that goes beyond what Keycloak roles alone can offer.

**Permission model:**
- **Module codes**: Logical groupings of functionality (e.g., Replenishment, StockControl)
- **Action codes**: Operations within a module (e.g., View, Create, Approve)
- **Access levels**: V (View), F (Full), A (Admin) — progressively permissive
- **Platform-specific**: Permissions differ between Web and Mobile platforms
- **Hierarchical**: Parent/child module relationships with action-level granularity

**Components:**
- `PermissionAttribute` — MVC action filter for declarative authorization
- `PermissionHandler` — Authorization handler that validates permissions on every authorized request
- `PermissionRequirement` — IAuthorizationRequirement implementation
- `PermissionService` — Service layer for permission lookups
- `PermissionConstants` — Module and action code constants
- `PermissionMiddleware` — Middleware for permission context propagation
- `StoreIdExtractionMiddleware` — Extracts store context for store-scoped permissions
- `ClaimsTransformationMiddleware` — Transforms claims for permission resolution

**Performance concern:** `PermissionHandler` makes a synchronous HTTP call to the Authentication service on every authorized request. This creates a performance bottleneck and tight coupling.

**Caching:** Redis-backed cache-aside pattern with 30-minute TTL for permission lookups. This mitigates but does not eliminate the per-request HTTP call concern, as cache misses and expirations still trigger synchronous calls.

## Decision

We implement a custom permission-based RBAC system with a cache-aside pattern and hierarchical module permissions, supplementing Keycloak JWT authentication with fine-grained authorization.

## Consequences

**Positive:**
- Fine-grained access control at module/action/access-level granularity
- Platform-specific permissions (Web vs Mobile) enable differentiated authorization
- Redis cache-aside with 30-min TTL reduces database load for repeated permission lookups
- Declarative authorization via `[Permission]` attribute keeps controller code clean
- Hierarchical module structure supports organizational permission modeling

**Negative:**
- **Synchronous HTTP call on every authorized request** — `PermissionHandler` calls Authentication service synchronously, creating a performance bottleneck and single point of failure
- Cache invalidation complexity — permission changes may take up to 30 minutes to propagate
- Tight coupling to Authentication service — if Authentication is down, all authorized endpoints fail
- Dual authorization model (Keycloak + custom) increases cognitive complexity for developers
- No circuit breaker or fallback for Authentication service unavailability

**Future constraints:**
- Consider replacing synchronous HTTP call with async event-based permission distribution (e.g., via RabbitMQ)
- Implement circuit breaker pattern (Polly) for Authentication service calls
- Evaluate reducing TTL or implementing cache invalidation on permission changes
- Document the permission model clearly for new developers (module codes, action codes, access levels)

## Related ADRs

- ADR-003: Keycloak Authentication
- ADR-026: Redis Distributed Cache
- ADR-043: Standardized Middleware Pipeline and DI Bootstrap

## Key files

- `PermissionAttribute.cs`
- `PermissionHandler.cs`
- `PermissionService.cs`
- `PermissionConstants.cs`
- `PermissionMiddleware.cs`
- `StoreIdExtractionMiddleware.cs`
- `ClaimsTransformationMiddleware.cs`