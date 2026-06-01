# Incident Response Runbook

> **Purpose**: Standard procedures for responding to production incidents in the WingYip SRS ecosystem.
> **Scope**: All services, infrastructure, and data pipelines.

---

## Severity Levels

| Level | Description | Response Time | Example |
|-------|-------------|---------------|---------|
| **P0 — Critical** | Complete system outage or data loss | Immediate (< 15 min) | All services down, database corruption |
| **P1 — High** | Major feature degradation | < 1 hour | Authentication failing, checkout broken |
| **P2 — Medium** | Partial degradation | < 4 hours | Single service down, slow response times |
| **P3 — Low** | Minor issues, workarounds exist | < 24 hours | UI glitch, non-critical report delayed |

---

## Incident Response Steps

### 1. Detect

- **Monitoring alerts**: Prometheus + Grafana alertmanager
- **User reports**: Support team escalation
- **Automated checks**: Health endpoint monitoring (`/health`, `/ready`)

### 2. Assess

1. Identify affected services:
   ```bash
   kubectl get pods --all-namespaces | grep -v Running
   ```
2. Check recent deployments:
   ```bash
   kubectl get deployments --all-namespaces -o wide
   ```
3. Review logs:
   ```bash
   kubectl logs -l app=<service-name> --tail=500 --all-containers
   ```
4. Check infrastructure: K8s nodes, SQL Server, RabbitMQ, Keycloak

### 3. Communicate

| Action | Channel | Owner |
|--------|---------|-------|
| Internal team alert | Teams/Slack #incidents | On-call engineer |
| Stakeholder notification | Email/Teams | Incident Commander |
| Status page update | Status page | Incident Commander |

### 4. Mitigate

**Goal**: Restore service, not necessarily fix root cause.

Options (in order of speed):
1. **Rollback**: `kubectl rollout undo deployment/<name>`
2. **Scale up**: `kubectl scale deployment/<name> --replicas=<n>`
3. **Restart**: `kubectl rollout restart deployment/<name>`
4. **Circuit breaker**: Enable fallback mode in BFF
5. **Feature flag**: Disable problematic feature

### 5. Resolve

- Verify all services healthy
- Run smoke tests
- Monitor metrics for 30 minutes post-resolution
- Update incident status

### 6. Post-Incident

Within 24 hours:
1. Document timeline in incident tracking system
2. Schedule post-mortem (required for P0/P1)
3. Create action items for prevention

---

## Common Scenarios

### Scenario A: Single Service Down

```bash
# Check pod status
kubectl get pods -n <namespace> -l app=<service>

# Check logs
kubectl logs -l app=<service> -n <namespace> --tail=100

# Restart if needed
kubectl rollout restart deployment/<service> -n <namespace>
```

### Scenario B: Database Connection Issues

1. Check SQL Server availability
2. Verify connection strings in K8s secrets
3. Check connection pool exhaustion
4. Restart affected services

### Scenario C: RabbitMQ Message Backlog

1. Check queue depth in RabbitMQ Management UI
2. Identify consumer lag
3. Scale up consumers if processing bottleneck
4. Monitor for dead letter queue growth

### Scenario D: Keycloak Auth Failures

1. Check Keycloak pod status
2. Verify AD/ADFS federation connectivity
3. Check JWT token expiry settings
4. Restart Keycloak if certificate/token issues

### Scenario E: High CPU / Memory

1. Identify top consuming pods:
   ```bash
   kubectl top pods --all-namespaces
   ```
2. Check application metrics for memory leaks
3. Scale horizontally if load-related
4. Profile if code-related

---

## Escalation Contacts

| Role | Contact | When to Escalate |
|------|---------|------------------|
| On-call Engineer | PagerDuty | All P0/P1 incidents |
| SRE Lead | Teams DM | P0 incidents, infrastructure failures |
| Architecture Lead | Teams DM | Design-level failures, cross-service issues |
| Product Manager | Email | Customer-impacting incidents |

---

## Tools Reference

| Tool | URL / Command | Purpose |
|------|---------------|---------|
| K8s Dashboard | `kubectl proxy` → http://localhost:8001 | Pod/resource status |
| Grafana | Internal URL | Metrics and dashboards |
| ArgoCD | Internal URL | Deployment status and rollback |
| RabbitMQ UI | Internal URL | Queue monitoring |
| Keycloak Admin | Internal URL | Auth/IAM management |
| Jenkins | Internal URL | Build pipeline status |

---

*Last updated: 2026-05-30*
