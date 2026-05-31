# ADR-009. Raw RabbitMQ.Client over MassTransit

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend uses RabbitMQ as its primary message broker for cross-service communication (audit events, print jobs, replenishment notifications). When the platform was built, a decision was made to use the raw `RabbitMQ.Client` library (v7.2.0) rather than a higher-level abstraction like MassTransit or NServiceBus.

**Current state:**
- 15+ projects reference `RabbitMQ.Client` directly
- All messaging infrastructure is hand-built: connection management, JSON serialization, exchange/queue declaration, consumer ack/nack handling, error handling, dead-letter configuration
- Zero references to MassTransit, NServiceBus, or EasyNetQ
- ~600+ lines of custom consumer code across `PrintSubscriberService`, `AuditConsumer`, and `RabbitMqPublisher`

**Alternatives considered:**
- **MassTransit**: Would provide saga orchestration, retry/DLQ policies, message versioning, health checks, and abstraction over transport
- **NServiceBus**: Commercial option with similar benefits plus support
- **Raw RabbitMQ.Client**: Maximum control, minimal dependencies, no abstraction overhead

## Decision

We will continue using **raw `RabbitMQ.Client`** for all RabbitMQ messaging:

1. **Direct library usage**: All services use `RabbitMQ.Client` 7.2.0 directly
2. **Custom publisher**: `Core/Queue/RabbitMqPublisher.cs` provides shared publishing logic
3. **Custom consumers**: Each service implements its own `BackgroundService` consumer with manual connection/channel management
4. **Manual DLQ**: Dead-letter queues configured via queue arguments, not framework policies
5. **JSON serialization**: System.Text.Json for publishing, Newtonsoft.Json for audit consumer deserialization (inconsistency noted in ADR-013)

## Consequences

**Positive:**
- Full control over connection lifecycle, channel pooling, and acknowledgments
- No dependency on MassTransit release cycles or breaking changes
- Lower memory footprint (no additional framework overhead)
- Direct access to RabbitMQ features (delayed messages, priority queues, quorum queues)
- Team has deep expertise in the implemented patterns

**Negative:**
- ~600+ lines of hand-written consumer code that MassTransit would provide out-of-box
- No saga orchestration support (must implement state machines manually)
- No automatic retry policies with exponential backoff (implemented manually per consumer)
- No message versioning strategy (breaking changes require coordinated deployment)
- No built-in health checks for message bus connectivity
- No outbox pattern implementation (ADR-005 proposes one but it does not yet exist in code)
- Every consumer reimplements connection recovery, exception handling, and channel management

**Future constraints:**
- Migration to MassTransit would require refactoring all 15+ consumer services
- New messaging patterns (sagas, request/response) must be built manually
- Any RabbitMQ.Client major version upgrade requires testing all custom code paths
- Consider MassTransit evaluation if saga orchestration or request/response patterns become requirements

## Related ADRs

- ADR-001: Microservices architecture (messaging as primary async communication)
- ADR-005: Centralized audit enrichment (outbox pattern — proposed but not yet implemented)
- ADR-010: Dual messaging infrastructure (RabbitMQ + Redis Pub/Sub)
- ADR-013: Dual JSON serializer (Newtonsoft + System.Text.Json)
