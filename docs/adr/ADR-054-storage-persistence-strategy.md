# ADR-054. Storage and Persistence Strategy

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS infrastructure uses hostPath-based local storage for all persistent volumes and configures Redis with dual persistence (RDB + AOF). These decisions simplify the on-premise deployment but introduce significant data durability and scalability constraints.

**Current implementation:**

- **Local-Path Storage**: All PersistentVolumes use `storageClassName: "local-storage"` or `"manual"` (hostPath-based). There is no dynamic provisioning, no NFS, and no distributed storage (e.g., Ceph, GlusterFS). Pods are tied to specific nodes via node affinity, preventing cross-node rescheduling.
- **Redis**: Single-node deployment with both persistence mechanisms enabled:
  - RDB snapshots: `save 900 1`, `save 300 10`, `save 60 10000`
  - AOF: `appendonly yes`, `appendfsync everysec`
  - This dual persistence is over-engineered for a cache layer but provides data durability guarantees.

## Decision

We use hostPath-based local storage for all persistent volumes and Redis with dual persistence (RDB + AOF).

1. **All PVs** use local-storage or manual StorageClass with hostPath bindings
2. **Redis** runs single-node with both RDB and AOF persistence enabled
3. No distributed storage or dynamic provisioning is introduced

## Consequences

**Positive:**
- Simple infrastructure with no external storage dependencies (no NFS, no Ceph)
- Redis dual persistence provides strong durability guarantees for cached data
- No network storage latency or complexity
- Easy to understand and troubleshoot

**Negative:**
- **Data loss on node failure**: If a node goes down, all PVs bound to that node are inaccessible. Pods cannot reschedule to other nodes without manual intervention.
- **No storage scalability**: Adding capacity requires manual hostPath configuration on new nodes
- **Redis dual persistence increases write overhead**: Both RDB and AOF write to disk, increasing I/O pressure. For a cache layer, this is unnecessary overhead.
- **Single-node Redis**: No high availability for Redis. If the Redis pod or its node fails, all services lose cache until manual recovery.
- **No live migration**: Pods cannot be moved between nodes without data loss or manual volume migration

**Future constraints:**
- Evaluate NFS or distributed storage (Longhorn, Ceph) for cross-node PV mobility before production
- Consider Redis Sentinel or Cluster mode for cache high availability
- Assess whether Redis dual persistence is necessary — for pure cache use cases, AOF-only or no persistence may suffice
- Implement automated backup procedures for hostPath volumes containing critical data

## Related ADRs

- ADR-004: On-premise Kubernetes (infrastructure platform)
- ADR-026: Redis distributed cache (Redis deployment rationale)
- ADR-052: Monitoring stack decisions (Elasticsearch storage implications)

## Key Files

- `redis-statefulset.yaml`
- `harbor-values.yaml`
- `elasticsearch-values.yaml`