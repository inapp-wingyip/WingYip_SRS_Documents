# Deployment Runbook

> **Purpose**: Standard procedures for deploying and restarting WingYip SRS services.
> **Scope**: All 14 backend microservices, frontend web app, and handheld app.

---

## Pre-Deployment Checklist

- [ ] PR has been reviewed and approved
- [ ] CI pipeline (Jenkins) has passed (build, unit tests, integration tests)
- [ ] Database migration scripts reviewed (if applicable)
- [ ] Deployment window communicated to stakeholders
- [ ] Rollback plan documented

---

## Deployment Methods

### Method 1: ArgoCD GitOps (Preferred)

1. Merge PR to target branch (`development` or `main`)
2. Jenkins pipeline triggers automatically:
   - Builds Docker image
   - Tags image with Git commit SHA
   - Updates Helm chart values in Git
3. ArgoCD detects Git change (auto-sync or manual sync)
4. ArgoCD applies changes to K8s cluster
5. Verify deployment:
   ```bash
   kubectl rollout status deployment/<service-name> -n <namespace>
   kubectl get pods -n <namespace> -l app=<service-name>
   ```

### Method 2: Manual kubectl (Emergency Only)

```bash
# Update deployment image
kubectl set image deployment/<service-name> <container>=<image>:<tag> -n <namespace>

# Watch rollout
kubectl rollout status deployment/<service-name> -n <namespace>

# Rollback if needed
kubectl rollout undo deployment/<service-name> -n <namespace>
```

---

## Service Restart Procedures

### Restart a Single Service

```bash
kubectl rollout restart deployment/<service-name> -n <namespace>
```

### Restart All Services (Caution)

```bash
# List all deployments in namespace
kubectl get deployments -n <namespace>

# Restart each deployment
for dep in $(kubectl get deployments -n <namespace> -o name); do
  kubectl rollout restart $dep -n <namespace>
done
```

---

## Post-Deployment Verification

1. **Health Checks**: Verify all pods are `Running` and `Ready`
   ```bash
   kubectl get pods -n <namespace>
   ```
2. **Service Endpoints**: Test key API endpoints
3. **Logs**: Check for errors in pod logs
   ```bash
   kubectl logs -l app=<service-name> -n <namespace> --tail=100
   ```
4. **Metrics**: Verify in Grafana dashboards
5. **Smoke Tests**: Run automated smoke test suite

---

## Rollback Procedures

### ArgoCD Rollback

1. Open ArgoCD UI
2. Navigate to the application
3. Click "History and Rollback"
4. Select previous successful deployment
5. Click "Rollback"

### kubectl Rollback

```bash
kubectl rollout undo deployment/<service-name> -n <namespace>
```

---

## Database Migrations

Database migrations are applied **before** service deployment:

1. Run migration SQL scripts from `docs/` directory of the service
2. Verify migration applied successfully
3. Update EF Core scaffolded models if schema changed
4. Deploy service

---

## Frontend Deployment

1. Build production bundle: `pnpm build`
2. Docker image built with Nginx static serving
3. Deploy via ArgoCD to FrontendService namespace
4. Verify CDN cache invalidation if applicable

---

## Handheld Deployment

1. Build Android APK via React Native build pipeline
2. Distribute via enterprise MDM or app store
3. Verify push notification to handheld devices

---

*Last updated: 2026-05-30*
