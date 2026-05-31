# ADR-058. Per-Service Domain-Specific Cache Layer

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The Product service has its own cache package (`WingYip.SRS.Product.Cache`) that wraps the generic `Core.Cache` library with domain-specific caching logic. This pattern introduces a per-service cache abstraction layer alongside the centralized caching infrastructure.

**Current implementation:**
- **IProductCache** — Interface defining domain-specific cache operations
- **ProductCache** — Concrete implementation wrapping `Core.Cache` with Product-domain logic
- **Item model** — Cache-specific model for product items
- **ServiceExtension** — DI registration extension method for cache services

**Incomplete implementation:**
- `ProductCache` line 22 contains commented-out code: `// products = await _productClient.GetProductShortDescriptionAsync(skus);`
- This suggests the cache was intended to fetch from the Product client on miss but was never completed

**Relationship to Core.Cache:**
- `Core.Cache` provides generic Redis-backed caching (see ADR-026)
- `Product.Cache` adds domain-specific key patterns, serialization, and invalidation logic on top of `Core.Cache`
- Other services do not currently have their own cache packages — they use `Core.Cache` directly

## Decision

We allow per-service domain-specific cache packages alongside the generic `Core.Cache` library.

1. **Product.Cache pattern**: Each service may create its own cache package wrapping `Core.Cache` with domain-specific logic
2. **Interface-driven**: Cache contracts defined via interfaces (e.g., `IProductCache`) for testability and DI
3. **ServiceExtension DI**: Each cache package registers its own services via a `ServiceExtension` class
4. **Incomplete code remains**: The commented-out `GetProductShortDescriptionAsync` call is acknowledged as technical debt

## Consequences

**Positive:**
- Domain-specific caching logic encapsulated in its own package — Product service owns its cache behavior
- Type-safe cache keys and models (e.g., `Item` model) specific to the domain
- Interface-driven design supports unit testing and DI
- Clear separation between generic cache infrastructure (`Core.Cache`) and domain cache logic

**Negative:**
- **Cache-per-service anti-pattern**: If every service creates its own cache package, this fragments caching strategy across the codebase instead of centralizing it
- **Incomplete implementation**: Commented-out code in `ProductCache` indicates the cache-aside fetch-on-miss pattern was intended but never completed — the cache may not actually populate on misses
- **Potential code duplication**: Other services may copy the `Product.Cache` pattern, leading to duplicated cache wrapper logic across services
- **No cross-service cache coordination**: Each service's cache package operates independently, with no shared invalidation or coordination

**Future constraints:**
- Complete the `ProductCache` implementation — either implement the fetch-on-miss pattern or remove the commented-out code
- Evaluate whether domain-specific cache packages should be consolidated into `Core.Cache` as extension methods or remain per-service
- Establish guidelines for when a service warrants its own cache package vs. using `Core.Cache` directly
- Add integration tests for cache miss scenarios to verify the cache-aside pattern works end-to-end

## Related ADRs

- ADR-026: Redis Distributed Cache (Core.Cache)
- ADR-042: Permission-Based RBAC System with Cache-Aside Pattern

## Key files

- `ProductCache.cs`
- `IProductCache.cs`