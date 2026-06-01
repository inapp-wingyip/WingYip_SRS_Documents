# ADR-012. Background Processing — Quartz.NET and BackgroundService

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend requires scheduled and continuous background processing for:
- Periodic data refresh (Product cache every 7 hours)
- Daily batch jobs (Spaceman price changes and archive at 7 AM)
- Message-driven consumers (Audit events, print jobs)
- Polling engines (Replenishment calculations every 10 seconds)

**Current state:**
- **Quartz.NET**: Used for cron-scheduled jobs (Product, Spaceman). Jobs persisted via Quartz job store. Version drift exists: Product.Service uses Quartz 3.17.1, Spaceman.Service uses Quartz 3.15.1.
- **BackgroundService**: Used for message consumers (`AuditConsumer`, `PrintSubscriberService`) and polling engines (`ReplenishmentEngineService`). ~20+ implementations across 10 services.
- **No Hangfire**: No Hangfire or similar dashboard-backed job scheduler
- **No Quartz for consumers**: Message-driven consumers use `while (!stoppingToken)` loops with `Task.Delay`

## Decision

We use a **dual scheduling strategy**:

1. **Quartz.NET for cron/scheduled jobs**: Any job with a fixed schedule (hourly, daily) uses Quartz with persistent job store
2. **BackgroundService for event-driven and polling workloads**: Message consumers and polling engines use `IHostedService` implementations
3. **No unified scheduler**: We accept the operational overhead of two scheduling mechanisms rather than forcing all workloads into one framework

## Consequences

**Positive:**
- Quartz provides cron expression flexibility and job persistence for scheduled tasks
- BackgroundService is lightweight for simple polling loops
- No additional dependency (Hangfire) for dashboard features we don't currently need
- Clear separation: Quartz = time-based, BackgroundService = event/polling-based

**Negative:**
- **No job persistence for BackgroundService**: Jobs lost on pod restart (replenishment cycle state, consumer offsets)
- **No unified dashboard**: Cannot view all background jobs in one place
- **No built-in retry for BackgroundService**: Each service reimplements error handling and recovery
- **No concurrency control**: Multiple pod replicas may run the same BackgroundService simultaneously (no distributed locking)
- ReplenishmentEngineService polls every 10 seconds — this is inefficient compared to event-driven triggers

**Future constraints:**
- If distributed job execution becomes required, evaluate Hangfire with Redis storage
- Consider migrating polling engines to event-driven architecture (RabbitMQ triggers instead of polling)
- BackgroundService implementations should implement graceful shutdown and checkpointing
- Consider Quartz for all scheduled workloads if a unified scheduler is desired

## Related ADRs

- ADR-001: Microservices architecture (background processing as service responsibility)
- ADR-009: Raw RabbitMQ.Client (message consumers use BackgroundService)
