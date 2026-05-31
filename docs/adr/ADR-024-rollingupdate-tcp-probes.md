# ADR-024. RollingUpdate Deployment Strategy with TCP Probes

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS microservices deployed to Kubernetes require a deployment strategy that minimizes downtime during updates. With 14+ services running in production, the deployment pattern must be consistent, predictable, and safe.

**Current implementation:**
- **RollingUpdate strategy** on all service Deployments:
  ```yaml
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  ```
- **TCP socket probes** for liveness and readiness (not HTTP probes):
  ```yaml
  livenessProbe:
    tcpSocket:
      port: http
    initialDelaySeconds: 30
    periodSeconds: 10
  readinessProbe:
    tcpSocket:
      port: http
    initialDelaySeconds: 10
    periodSeconds: 5
  ```
- **ImagePullPolicy: Always** on all containers
- **No blue/green or canary**: All deployments use rolling update only

## Decision

We use **RollingUpdate with zero downtime** configuration:

1. **maxUnavailable: 0**: No pods are removed before new pods are ready
2. **maxSurge: 1**: Only one extra pod created during update (conservative resource usage)
3. **TCP socket probes**: Both liveness and readiness use TCP socket checks on the HTTP port
4. **ImagePullPolicy: Always**: Always pull latest image tag (mitigates stale image issues but prevents immutable tags)

## Consequences

**Positive:**
- Zero-downtime deployments (old pods stay until new pods pass readiness)
- Consistent pattern across all 16+ services
- Simple to understand and troubleshoot
- No additional infrastructure needed (unlike blue/green or canary)

**Negative:**
- **TCP probes are insufficient**: TCP socket open does not mean application is healthy (could accept connections but fail requests). HTTP health endpoint would catch application-level failures
- **maxSurge: 1 is slow**: Large replica counts take many iterations to update
- **ImagePullPolicy: Always**: Prevents reproducible deployments (same manifest may pull different image if tag is reused)
- **No canary**: No gradual traffic shift — 100% of traffic moves to new version once ready
- **No rollback automation**: Manual `kubectl rollout undo` or ArgoCD sync history required

**Future constraints:**
- Evaluate HTTP health probes before production scale
- Consider `ImagePullPolicy: IfNotPresent` with immutable image digests for reproducibility
- If deployment safety requirements increase, evaluate Argo Rollouts for canary/blue-green
- Add startup probe for slow-starting services (currently only liveness + readiness)

## Related ADRs

- ADR-004: On-premise Kubernetes (deployment infrastructure)
- ADR-015: Missing observability (health checks gap)
