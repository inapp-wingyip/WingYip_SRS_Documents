# ADR-061. Two-DC High Availability Design (Design Proposal)

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The `TWO_DC_APPLICATION_CICD_INTEGRATION_DESIGN.md` document describes a **proposed** two-datacenter high availability architecture for WingYip SRS. **This is a design document, not a current implementation.** The current infrastructure runs a single Kubernetes cluster with single-node Redis, single-replica PostgreSQL, and standard RabbitMQ (no mirroring).

**Design proposal (from `TWO_DC_APPLICATION_CICD_INTEGRATION_DESIGN.md`):**
- **3 control-plane nodes** in a single cluster (per the design doc Section 3 — "Use a single Kubernetes production cluster with HA control plane"), NOT 3 per DC
- **Stacked etcd** — documented in the design proposal
- **HAProxy pair per DC** — documented as "Two HAProxy VMs (one per DC) minimum" in Section 4.1
- **RabbitMQ mirror queue** — proposed but **not present** in actual `rabbitmq-values-final.yaml`
- **PostgreSQL streaming replication** — proposed but **not present** in actual `postgres-statefulset.yaml` (single replica only)

**Current actual state:**
- Single Kubernetes cluster with 3 control-plane nodes total
- Single-node Redis (RDB + AOF persistence)
- Single-replica PostgreSQL for Keycloak (no standby, no streaming replication)
- RabbitMQ with `ha-all` policy but no cross-DC mirror queue configuration
- HAProxy Ingress on NodePort 30880/30883 with MetalLB `10.10.80.77/32`

## Decision

We **accept the two-DC HA design as the target architecture** while acknowledging that the current infrastructure does not yet implement most of its components.

1. **Single-cluster control plane**: The design specifies a single Kubernetes cluster with 3 control-plane nodes (not 3 per DC) — this is what currently exists
2. **Stacked etcd**: Accepted as the etcd deployment model in the design
3. **HAProxy pair per DC**: Accepted as the load balancer design for future DC expansion
4. **RabbitMQ mirror queue**: **Planned but not implemented** — current config has no mirror queue setup
5. **PostgreSQL streaming replication**: **Planned but not implemented** — current Keycloak PostgreSQL is a single StatefulSet with 1 replica

## Consequences

**Positive (when implemented):**
- **High availability**: Application remains available if one datacenter fails
- **Disaster recovery**: Data replication ensures no data loss during DC failover
- **RabbitMQ mirror queues** (when configured) prevent message loss during failover — critical for replenishment and order workflows
- **PostgreSQL streaming replication** (when configured) provides near-real-time data synchronization for Keycloak identity data with low replication lag
- **HAProxy pairs** enable automatic traffic failover between datacenters

**Negative (current gaps):**
- **Design is not implemented**: Current infrastructure is a single-DC deployment. The two-DC design exists only on paper
- **No RabbitMQ mirroring**: Messages are not replicated across DCs — RabbitMQ data loss during DC failure
- **No PostgreSQL standby**: Keycloak database has no replication — single point of failure
- **Single Redis node**: No Redis Sentinel or Cluster — cache data lost on node failure
- **Complex networking** (when implemented): Two-DC networking requires careful DNS, firewall, and routing configuration
- **Split-brain risk with stacked etcd**: If network partition occurs between DCs, etcd quorum may be lost
- **Significant infrastructure overhead** (when implemented): Doubles operational complexity

**Future constraints:**
- Implement RabbitMQ mirror queue configuration before DC expansion
- Deploy PostgreSQL streaming replication (or Patroni) for Keycloak database HA
- Evaluate external etcd clusters to reduce split-brain risk
- Document and test DC failover procedures regularly — untested failover is unreliable failover
- Consider Redis Sentinel or Cluster before production HA requirement

## Related ADRs

- ADR-004: On-Premise Kubernetes
- ADR-024: Rolling Update TCP Probes
- ADR-009: Raw RabbitMQ Client
- ADR-002: Database Per Service

## Key files

- `TWO_DC_APPLICATION_CICD_INTEGRATION_DESIGN.md`