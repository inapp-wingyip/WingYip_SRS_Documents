---
applyTo: "**/*.yaml,**/*.yml,**/*.json,**/Dockerfile*"
name: "DevOps SDD Rules"
---

## DevOps Conventions

- Use Helm charts for application deployments.
- Separate environments: dev, staging, production.
- Resource limits and requests must be defined for all pods.
- Store secrets in Jenkins Credentials or external vault.
- Scan images with Trivy before deployment.
- Apply `kubectl apply --dry-run=client` before actual deployment.
