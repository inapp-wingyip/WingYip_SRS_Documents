# ADR-052. Monitoring Stack Decisions

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS infrastructure deploys a full observability stack (ELK, Jaeger, Prometheus/Grafana) but with deliberate development-grade limitations across all four monitoring components. These trade-offs were accepted to accelerate initial deployment while providing visibility into the system.

**Current implementation:**

- **ELK Dual Ingestion**: Both Fluent Bit (container log tailing) AND Logstash (Beats/TCP input) are deployed for Elasticsearch. This creates a redundant dual-stack approach where logs can enter Elasticsearch via two independent paths.
- **Elasticsearch**: Deployed with `xpack.security.enabled: false`, no TLS, and no authentication. Sensitive log data is accessible without credentials.
- **Jaeger**: Deployed in `allInOne` mode with `storage.type: memory`. All trace data is stored in-process memory and is lost on pod restart.
- **Prometheus**: Configured with 15-day retention, single replica, and no Thanos/Cortex for long-term storage. Metrics beyond 15 days are irretrievably lost.
- **Grafana**: Deployed with `persistence.enabled: false`. Dashboards, alert rules, and data source configurations are ephemeral and lost on pod restart.

## Decision

We deploy the full monitoring stack (ELK + Jaeger + Prometheus/Grafana) with development-grade configurations that prioritize immediate visibility over production durability and security.

1. **Dual log ingestion** (Fluent Bit + Logstash) is accepted as-is for initial deployment
2. **Elasticsearch** runs without authentication or TLS
3. **Jaeger** runs in allInOne mode with in-memory storage
4. **Prometheus** uses 15-day retention with no long-term storage backend
5. **Grafana** runs without persistent storage for dashboards and configuration

## Consequences

**Positive:**
- Full observability stack is visible and functional from day one
- Developers can query logs, traces, and metrics immediately
- Dual ingestion provides redundancy in log delivery paths
- No additional infrastructure complexity for security or persistence layers

**Negative:**
- **Elasticsearch unauthenticated**: Sensitive log data (potentially including PII, connection strings, stack traces) is accessible without credentials
- **Jaeger traces lost on restart**: No historical trace data survives pod eviction, crash, or rescheduling
- **Prometheus limited to 15 days**: No capacity for capacity planning, trend analysis, or incident investigation beyond two weeks
- **Grafana state ephemeral**: All dashboards and alert rules must be manually recreated after any pod restart
- **Dual log ingestion is redundant**: Fluent Bit and Logstash serve overlapping purposes, increasing resource consumption and operational complexity without clear benefit

**Future constraints:**
- Enable Elasticsearch security (xpack.security.enabled: true) with TLS before production
- Migrate Jaeger to persistent storage (Elasticsearch or Cassandra backend) before production
- Evaluate Thanos or Cortex for Prometheus long-term storage
- Enable Grafana persistence or adopt GitOps dashboard management (e.g., Grafana provisioning from YAML)
- Consolidate log ingestion to a single path (Fluent Bit OR Logstash) to reduce operational overhead

## Related ADRs

- ADR-004: On-premise Kubernetes (infrastructure platform)
- ADR-015: Missing observability (health checks gap)
- ADR-024: RollingUpdate deployment strategy with TCP probes

## Key Files

- `fluentbit-values.yaml`
- `logstash-values.yaml`
- `elasticsearch-values.yaml`
- `jaeger-values.yaml`
- `prometheus-stack-values.yaml`