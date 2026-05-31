# ADR-061. Two-DC High Availability Design

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The `TWO_DC_APPLICATION_CICD_INTEGRATION_DESIGN.md` document describes a comprehensive two-datacenter high availability architecture for WingYip SRS. This design has been documented but not previously formalized as an ADR.

**Architecture:**
- **3 control-plane nodes per DC** — Kubernetes masters distributed across datacenters
- **Stacked etcd** — etcd clusters co-located with Kubernetes control plane nodes
- **HAProxy pair per DC** — Load balancers providing traffic distribution and failover
- **RabbitMQ mirror queue** — Message queue replication between datacenters for reliable delivery
- **PostgreSQL streaming replication** — Keycloak identity database replication (the only PostgreSQL instance in the architecture; service databases are SQL Server per ADR-002)

**Current status:**
- The design is documented in `TWO_DC_APPLICATION_CICD_INTEGRATION_DESIGN.md`
- Not yet formalized as an ADR — this ADR formalizes the documented design decision
- Implementation status may vary per component

## Decision

We deploy a two-datacenter high availability architecture with stacked etcd, mirrored queues, and streaming replication.

1. **3 control-plane nodes per DC**: Kubernetes masters in each datacenter for local control plane availability
2. **Stacked etcd**: etcd co-located with control plane nodes — reduces infrastructure but couples etcd health to node health
3. **HAProxy pair per DC**: Active-passive or active-active load balancers for traffic distribution
4. **RabbitMQ mirror queue**: Messages replicated between DCs to prevent data loss during failover
5. **PostgreSQL streaming replication**: Keycloak PostgreSQL only — primary in DC1, standby in DC2 with streaming WAL replication. Service databases (SQL Server per ADR-002) are not covered by this replication and require separate HA strategy.

## Consequences

**Positive:**
- **High availability**: Application remains available if one datacenter fails
- **Disaster recovery**: Data replication ensures no data loss during DC failover
- **RabbitMQ mirror queues** prevent message loss during failover — critical for replenishment and order workflows
- **PostgreSQL streaming replication** provides near-real-time data synchronization for Keycloak identity data with low replication lag
- **HAProxy pairs** enable automatic traffic failover between datacenters

**Negative:**
- **Complex networking**: Two-DC networking requires careful DNS, firewall, and routing configuration
- **Split-brain risk with stacked etcd**: If network partition occurs between DCs, etcd quorum may be lost — stacked etcd is more vulnerable than external etcd clusters
- **Significant infrastructure overhead**: 3 control-plane nodes per DC, HAProxy pairs, and replication infrastructure doubles operational complexity
- **PostgreSQL failover is manual or requires additional tooling** (e.g., Patroni) — streaming replication alone does not provide automatic failover; SQL Server service databases require separate Always On or failover cluster instances
- **RabbitMQ mirror queues** have performance overhead and require careful queue configuration to avoid excessive cross-DC traffic

**Future constraints:**
- Evaluate external etcd clusters (separate from control plane) to reduce split-brain risk
- Implement automated PostgreSQL failover (Patroni or similar) to reduce RTO during DC failures
- Document and test DC failover procedures regularly — untested failover is unreliable failover
- Monitor cross-DC replication lag and set alerting thresholds for unacceptable lag
- Consider network partition detection and fencing mechanisms to prevent split-brain scenarios

## Related ADRs

- ADR-004: On-Premise Kubernetes
- ADR-024: Rolling Update TCP Probes
- ADR-009: Raw RabbitMQ Client
- ADR-002: Database Per Service

## Key files

- `TWO_DC_APPLICATION_CICD_INTEGRATION_DESIGN.md`