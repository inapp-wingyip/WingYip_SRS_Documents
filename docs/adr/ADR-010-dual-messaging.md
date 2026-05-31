# ADR-010. Dual Messaging Infrastructure — RabbitMQ and Redis Pub/Sub

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform uses two distinct messaging systems for different communication patterns:

1. **RabbitMQ** (durable message broker): Used for events that require guaranteed delivery, persistence, and eventual consistency (audit logs, print jobs, replenishment events)
2. **Redis Pub/Sub** (ephemeral broadcast): Used for real-time notifications across 4 channels (`replenishment`, `product`, `inventory`, `order`)

**Current state:**
- `Core/Queue/RabbitMqPublisher.cs` handles durable event publishing
- `Core.Cache/RedisMessagingService.cs` implements `IRedisMessaging` with `PublishAsync`/`SubscribeAsync`
- `Administration/Services/NotificationSubscriber.cs` bridges both systems — receives RabbitMQ events and broadcasts via Redis Pub/Sub to connected WebSocket clients
- No documented boundary for when to use which system

**Why two systems:**
- RabbitMQ provides durability and complex routing but has higher latency
- Redis Pub/Sub provides sub-millisecond broadcast but no persistence or delivery guarantees

## Decision

We explicitly accept the dual messaging strategy with clear usage boundaries:

1. **RabbitMQ for**: All cross-service events, audit logs, print jobs, background processing tasks, and any message requiring durability or retry
2. **Redis Pub/Sub for**: Real-time UI notifications, WebSocket broadcast events, and ephemeral state updates where delivery is not critical
3. **Bridge Pattern**: The NotificationSubscriber service may consume RabbitMQ events and re-broadcast via Redis Pub/Sub to WebSocket clients
4. **No Mixing Within a Service**: A single event type must not be published to both systems simultaneously

## Consequences

**Positive:**
- Optimized for each use case: durability (RabbitMQ) vs speed (Redis)
- Redis Pub/Sub avoids RabbitMQ overhead for high-frequency UI updates
- Clear separation of concerns between durable events and real-time notifications
- Bridge pattern allows RabbitMQ events to reach WebSocket clients efficiently

**Negative:**
- Operational complexity of managing two message brokers
- Team must understand failure modes of both systems
- No unified monitoring or tracing across both messaging layers
- Redis Pub/Sub messages are lost if no subscriber is connected (no persistence)
- Debugging requires checking two systems for the same logical event flow
- Additional infrastructure to maintain (Redis cluster + RabbitMQ cluster)

**Future constraints:**
- New messaging use cases must be classified as "durable" (RabbitMQ) or "ephemeral" (Redis)
- Migration to a single broker would require significant refactoring
- If Redis persistence becomes required, consider Redis Streams (not Pub/Sub) as an alternative
- Consider unified messaging abstraction if team size grows

## Related ADRs

- ADR-001: Microservices architecture (messaging as primary async communication)
- ADR-009: Raw RabbitMQ.Client usage patterns
