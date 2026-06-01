# ADR-015. Missing Observability — Health Checks, OpenTelemetry, and Application Metrics

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform requires operational visibility for 14 microservices running in Kubernetes. The current architecture documentation (PROJECT.md) states:
- Metrics: Prometheus
- Tracing: OpenTelemetry + Jaeger
- Log format: JSON structured
- Correlation ID: `X-Request-ID`

**Actual state:**
- **Health Checks**: Zero `AddHealthChecks`, `MapHealthChecks`, or HTTP health endpoints. Kubernetes liveness/readiness probes rely on TCP port checks only
- **OpenTelemetry**: Zero `OpenTelemetry`, `ActivitySource`, or tracing SDK references. Correlation IDs propagated manually via `CorrelationIdMiddleware` but no span context or trace hierarchy
- **Application Metrics**: Zero `Prometheus`, `UseMetricServer`, or `AddPrometheus` references. No business metrics exposed
- **Logging**: Serilog + Elasticsearch sink implemented. JSON structured logging active. Correlation ID middleware exists
- **Jaeger**: Deployed in Infrastructure but no application instrumentation

## Decision

We explicitly document the **observability gap** and accept the current partial implementation:

1. **Logging (Implemented)**: Serilog + Elasticsearch/ELK stack with correlation ID propagation
2. **Health Checks (Missing)**: No health check endpoints. TCP port probes only. Database connectivity, RabbitMQ connectivity, and dependency health are not exposed
3. **Distributed Tracing (Missing)**: Manual correlation ID only. No OpenTelemetry spans, no automatic HTTP/RabbitMQ/database span creation
4. **Application Metrics (Missing)**: No Prometheus metrics. No request duration histograms, error rate counters, or business metrics (replenishment cycle time, print job backlog)

## Consequences

**Positive:**
- Logging and correlation IDs provide basic troubleshooting capability
- Reduced initial complexity (no OTel collector, no metrics cardinality management)
- Lower resource overhead (no metrics scraping, no trace span creation)

**Negative:**
- **Kubernetes cannot detect application-level failures**: A service with hung threads or database connection pool exhaustion appears healthy to K8s (TCP port still responds)
- **No automatic alerting**: Cannot alert on business metric thresholds (queue depth, error rate, latency percentile)
- **Cross-service debugging requires grep**: Without distributed tracing, engineers must manually correlate logs across services using `X-Request-ID`
- **No performance baselines**: Without metrics, cannot detect performance regressions or capacity limits
- **Operational blindness**: No visibility into RabbitMQ consumer lag, database query performance, or HTTP endpoint latency

**Future constraints:**
- Health checks are the highest priority remediation (blocks production-ready status)
- OpenTelemetry instrumentation should be added before production scale
- Application metrics (Prometheus) required before auto-scaling can be effective
- Any production incident requiring cross-service trace analysis will be difficult to diagnose

## Remediation Priority

1. **P0 — Health Checks**: Add `AddHealthChecks` with database, RabbitMQ, and external dependency probes
2. **P1 — OpenTelemetry**: Add OTel SDK with automatic instrumentation for HTTP, RabbitMQ, and SQL Client
3. **P2 — Application Metrics**: Add Prometheus metrics for request duration, error rates, and key business metrics

## Related ADRs

- ADR-004: On-premise Kubernetes (mentions Prometheus + Grafana but only for cluster-level metrics)
- ADR-005: Centralized audit enrichment (correlation ID propagation exists but no distributed tracing)
