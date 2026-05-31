# ADR-053. Messaging Infrastructure

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS infrastructure deploys both RabbitMQ and Kafka message brokers in Kubernetes, but only RabbitMQ is actively used by backend services. This creates an asymmetric messaging landscape where one system carries all production traffic while the other consumes resources without serving any workload.

**Current implementation:**

- **RabbitMQ**: 3-node cluster with autoheal partition handling and `ha-all` policy for all queues. Actively used by backend services for event-driven communication (CQRS event propagation, domain events, WebSocket notifications).
- **Kafka**: 5-broker cluster with 3 ZooKeeper nodes, `replication.factor=3`, `min.insync.replicas=2`, and `auto.create.topics.enable=true`. Deployed but **unused** by any backend service. No topics are produced to or consumed from.

## Decision

We deploy both RabbitMQ and Kafka clusters, using RabbitMQ exclusively for active messaging while maintaining Kafka as a deployed but inactive infrastructure component.

1. **RabbitMQ** is the primary and only active message broker for all backend services
2. **Kafka** remains deployed but unused, consuming cluster resources without serving traffic
3. `auto.create.topics.enable=true` is accepted on Kafka (development convenience)

## Consequences

**Positive:**
- RabbitMQ provides reliable messaging with high availability (3-node cluster, ha-all policy, autoheal)
- Kafka infrastructure is pre-provisioned and available if a future use case requires it
- No migration effort needed if Kafka adoption is decided later

**Negative:**
- **Kafka cluster wastes resources**: 5 Kafka brokers + 3 ZooKeeper nodes consume CPU, memory, and storage without serving any traffic
- **auto.create.topics.enable=true** is a development convenience that should be disabled in production (prevents accidental topic proliferation and enforces governance)
- **Operational complexity**: Two message broker systems to monitor, upgrade, and troubleshoot
- **Confusion risk**: New developers may be uncertain which broker to use for new features

**Future constraints:**
- Evaluate whether Kafka should be decommissioned if no use case emerges within a defined timeframe
- If Kafka is retained, identify specific use cases (e.g., event sourcing, log aggregation, stream processing) and migrate appropriate workloads
- Disable `auto.create.topics.enable` before any production Kafka usage
- Consider reducing Kafka broker count (5 → 3) if retained for non-critical workloads

## Related ADRs

- ADR-010: Dual messaging (RabbitMQ + Kafka deployment rationale)
- ADR-009: Raw RabbitMQ client (no MassTransit/Cap)
- ADR-031: CQRS with MediatR and AutoMapper (event-driven architecture)

## Key Files

- `rabbitmq-values-final.yaml`
- `kafka-values-final.yaml`