# DevOps & Kubernetes Deployment

> Derived from `WingYip_SRS_Infrastructure/DEPLOYMENT_GUIDE.md` and `drive/Documents/Infrastructure/`.

---

## Deployment Architecture Overview

The SRS is deployed via a **GitOps workflow** using **Jenkins CI/CD** + **ArgoCD** + **Kubernetes (K8s)** with environments for Development, Staging, and Production.

```
┌─────────────────────────────────────────────────────────────┐
│                    CI/CD Pipeline                            │
│                                                              │
│  Developer Push → Jenkins Build → Docker Image → Harbor    │
│  Registry → Git Commit (kustomization) → ArgoCD Sync → K8s │
└─────────────────────────────────────────────────────────────┘
```

---

## Kubernetes Cluster

### Environments
| Environment | Namespace | Purpose |
|-------------|-----------|---------|
| Development | `wingyip-srs-dev` | Active development, testing |
| Staging | `wingyip-srs-staging` | Pre-production validation |
| Production | `wingyip-srs` | Live environment (ArgoCD applications not yet created) |
| Keycloak | `keycloak` | Shared authentication (has dev/staging/prod configs) |
| Logging | `logging` | Elasticsearch centralized logging |
| Messaging | `messaging` | RabbitMQ message broker |
| CICD | `cicd` | ArgoCD applications |

### Infrastructure Components
| Component | Address | Purpose |
|-----------|---------|---------|
| Harbor Registry | `10.10.80.77:30280` | Container image storage |
| ArgoCD | `10.10.80.77:30444` | GitOps deployment automation |
| SQL Server | `10.10.80.75:1433` | Database server |
| Elasticsearch | `logging` namespace | Centralized logging |

---

## Deployed Services

### Current Service Inventory
| Service | Dev Port | Staging Port | Production | Status |
|---------|----------|--------------|------------|--------|
| Administration | 30700/30701 | 30750/30751 | Ingress | Deployed |
| Product | 30710/30711 | 30760/30761 | Ingress | Deployed |
| Spaceman | 30720/30721 | 30770/30771 | Ingress | Deployed |
| Audit | 30730 | 30780 | Ingress | Deployed |
| Frontend | 30740 | 30790 | Ingress | Deployed |
| Keycloak | 31180 | 31280 | Ingress | Dev/Staging |
| StockControl | — | — | — | Dev only |
| Authentication | — | — | — | Dev only |

### Repository: WingYip_SRS_Infrastructure
| Directory | Description |
|-----------|-------------|
| AdministrationService/ | Admin service K8s manifests + source |
| ProductService/ | Product service K8s manifests + source |
| SpacemanService/ | Spaceman service K8s manifests + source |
| AuditService/ | Audit service K8s manifests + source |
| FrontendService/ | React web app K8s manifests + source |
| StockControlService/ | Stock control service |
| KeycloakAuthentication/ | Keycloak deployment configs |
| SharedResources/ | Shared K8s resources (configmaps, secrets) |

---

## Image Tagging Strategy

### Jenkins Build Process
When Jenkins builds an image, it creates **two tags**:
```bash
# Build-specific tag (for traceability)
${IMAGE_NAME}:${BUILD_NUMBER}
# Example: administrationservice-api:123

# Environment-specific latest tag
${IMAGE_NAME}:latest           # For staging/production
${IMAGE_NAME}:dev-latest       # For dev
```

### Kustomization Image Tags
- **Dev**: `k8s/overlays/dev/kustomization.yaml` → `newTag: "80"` (specific build)
- **Staging**: `k8s/overlays/staging/kustomization.yaml` → `newTag: "latest"`
- **Production**: `k8s/overlays/production/kustomization.yaml` → `newTag: "150"` (specific tested build)

---

## Deployment Process

### Development
1. Developer pushes code → Jenkins triggers build
2. Jenkins: Checkout → Build → Docker image → Tag (`:${BUILD_NUMBER}` + `:dev-latest`) → Push to Harbor → Update kustomization → Git commit → Trigger ArgoCD sync
3. ArgoCD: Detect Git commit → Apply dev manifests → Deploy to `wingyip-srs-dev`

### Staging
1. Jenkins job with Environment: `staging`
2. Image tagged as `:latest` for staging
3. ArgoCD sync → Deploy to `wingyip-srs-staging`
4. **Currently deployed**: Admin (2/2 pods), Product (2/2 pods), Spaceman (2/2 pods), Audit (2/2 pods), Frontend (2/2 pods)
5. **Missing**: Keycloak staging deployment

### Production
⚠️ **Additional safeguards required**:
- Manual approval gates
- Specific version tags (never `:latest`)
- Database backup verification
- Health check validation
- 24+ hours staging soak time

#### Production Deployment Checklist
```
□ Staging tests passed for 24+ hours
□ Database backup completed
□ Version number documented (e.g., build #150)
□ Rollback plan prepared
□ Maintenance window scheduled
□ Stakeholders notified
```

---

## ArgoCD Application Management

### Current Applications
| Environment | Applications |
|-------------|-------------|
| Dev | ✓ administrationservice, ✓ productservice, ✓ spacemanservice, ✓ auditservice, ✓ stockcontrolservice, ✓ frontend, ✓ authenticationservice, ✓ keycloak |
| Staging | ✓ administrationservice, ✓ productservice, ✓ spacemanservice, ✓ auditservice, ✓ frontend, ✗ keycloak (needs creation) |
| Production | ✗ All production apps need creation |

### Common Commands
```bash
# List all ArgoCD applications
kubectl get applications -n cicd -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status

# Manual sync
kubectl patch application <app-name> -n cicd \
  --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
```

---

## Accessing Services

### Dev Environment (NodePort)
```bash
# Administration API
curl http://10.10.80.77:30700/api/verify/get-section-config?section=Logging
# Product API
curl http://10.10.80.77:30710/api/product
# Spaceman API
curl http://10.10.80.77:30720/api/spaceman
# Audit API
curl http://10.10.80.77:30730/api/audit
# Frontend UI
http://10.10.80.77:30740
# Keycloak
http://10.10.80.77:31180
```

### Staging Environment (NodePort)
| Service | URL |
|---------|-----|
| Administration | http://10.10.80.77:30750 |
| Product | http://10.10.80.77:30760 |
| Spaceman | http://10.10.80.77:30770 |
| Audit | http://10.10.80.77:30780 |
| Frontend | http://10.10.80.77:30790 |

### Production Environment (Ingress)
- DNS: `*.wingyip.com` → `10.10.80.77` (HAProxy Ingress)
- Routes: `administration.wingyip.com`, `product.wingyip.com`, `spaceman.wingyip.com`, `audit.wingyip.com`, `wingyip.com` (Frontend)

---

## Troubleshooting

### Pods Not Starting
```bash
kubectl get pods -n wingyip-srs-staging
kubectl logs <pod-name> -n wingyip-srs-staging --tail=50
kubectl describe pod <pod-name> -n wingyip-srs-staging
```

### ArgoCD Out of Sync
```bash
kubectl patch application <app-name> -n cicd \
  --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
```

### Image Pull Errors
```bash
# Check Harbor for image existence
curl -u admin:Harbor12345 \
  "http://10.10.80.77:30280/api/v2.0/projects/wingyip-srs/repositories/administrationservice-api/artifacts"
```

### Database Connection Issues
```bash
kubectl exec <pod-name> -n wingyip-srs-staging -- nc -zv 10.10.80.75 1433
kubectl get configmap <config-name> -n wingyip-srs-staging -o yaml
```

---

## Best Practices

1. **Image Management**: Use specific version tags for production; `:latest` for staging; `:dev-latest` for dev
2. **Environment Parity**: Keep dev/staging/production configurations similar; use Kustomize patches for differences
3. **Deployment Safety**: Dev → Staging → Production; 24-hour staging soak; always have rollback plan
4. **GitOps Workflow**: All changes via Git commits; feature branches; protected main branches; auto-sync for dev/staging, manual for production
5. **Monitoring**: Daily ArgoCD health checks; pod resource monitoring; Elasticsearch log review; alert configuration

---

## Infrastructure Status

Current state of production readiness:

| Component | Status |
|-----------|--------|
| Keycloak staging deployment | In progress |
| Production ArgoCD applications | Not yet created |
| DNS for production domains | Not yet configured |
| SSL/TLS certificates | Not yet configured |
| Backup strategy | Not yet implemented |
| Monitoring & alerting | Not yet configured |
| Staging environment testing | Not yet completed |

---

## Cross-References

- [Deployment Strategy](./01-deployment-strategy.md) — Go-live and phased rollout
- [On-Premise Architecture](../architecture/02-enterprise-onprem.md) — Infrastructure topology
- [Technical Architecture](../architecture/01-technical-architecture.md) — Tech stack
- [Data Mapping](./03-data-mapping.md) — Source system integration