# ADR-026. Redis Distributed Caching with StackExchange.Redis

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend requires caching for frequently accessed data (user permissions, product catalogs, store hierarchies) to reduce database load and improve response times. With 14+ microservices, a shared distributed cache is necessary to ensure consistency across service instances.

**Current implementation:**
- **StackExchange.Redis** (v2.8.31) via `Core.Cache` shared library
- `RedisCacheService` implements `ICacheService` with `GetAsync`, `SetAsync`, `DeleteAsync`, `ExistsAsync`
- **JSON serialization**: System.Text.Json for cache value serialization
- **Per-service key prefixing**: `CacheSettings.CacheKeyPrefix` (e.g., `"user_permissions_"`) prevents key collisions
- **Default TTL**: 3600 seconds (1 hour) with per-call override support
- **No cache invalidation strategy**: No pub/sub-based invalidation or event-driven cache clearing
- **Singleton lifetime**: `RedisCacheService` registered as singleton in DI

## Decision

We use **Redis as a distributed cache** with direct `StackExchange.Redis` access:

1. **Redis server**: Single Redis instance (or sentinel) shared across all services
2. **Direct library access**: No `Microsoft.Extensions.Caching.StackExchangeRedis` wrapper — direct `IDatabase` usage
3. **String data type only**: All values stored as JSON strings (no Redis hashes, sets, or sorted sets)
4. **Per-service key prefixing**: Configurable prefix to avoid cross-service key collisions
5. **No cache warming**: Cache is cold-start only (populated on first miss)

## Consequences

**Positive:**
- Fast in-memory cache shared across all service instances
- Simple Get/Set/Delete API via `ICacheService`
- JSON serialization works with any object shape
- Key prefixing prevents accidental cross-service data leakage

**Negative:**
- **No cache invalidation strategy**: When underlying data changes, cache entries become stale until TTL expires
- **No cache-aside pattern formalization**: Each service implements its own cache logic (some may forget to cache)
- **Single Redis point of failure**: No Redis Cluster or Sentinel configuration documented
- **No cache metrics**: No hit/miss ratio monitoring, no eviction tracking
- **String-only storage**: Inefficient for large objects (entire JSON string stored/retrieved atomically)
- **No distributed locking**: Concurrent cache misses cause multiple database queries (cache stampede)

**Future constraints:**
- Consider cache invalidation via RabbitMQ events when data changes
- Evaluate Redis Cluster for production high availability
- Add cache metrics (hit rate, latency) to observability stack
- Consider `HybridCache` (.NET 9) or `FusionCache` for multi-tier caching (memory + Redis)

## Related ADRs

- ADR-010: Dual messaging infrastructure (Redis Pub/Sub used for notifications, separate from cache)
- ADR-015: Missing observability (cache metrics not instrumented)
