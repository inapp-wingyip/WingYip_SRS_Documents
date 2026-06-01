# ADR-004. On-Premise Kubernetes with ArgoCD GitOps

- **Status:** accepted
- **Date:** 2024-02-15
- **Supersedes:** N/A

## Context

With 14 microservices and supporting infrastructure, we needed a container orchestration platform that could run on-premise, support automated deployments, and provide self-healing capabilities. The enterprise had standardized on Windows Server infrastructure but was open to Linux containers for stateless workloads.

Key constraints:
- On-premise only — no public cloud
- Must support both Windows and Linux containers
- Jenkins already in use for CI — need CD integration
- Desire for GitOps-style declarative deployments
- Need for blue/green or rolling update strategies

## Decision

We will deploy on **Kubernetes (K8s)** on-premise with **ArgoCD** for GitOps-driven continuous delivery:

1. **Kubernetes Cluster**: On-premise K8s cluster for container orchestration
2. **ArgoCD**: GitOps controller that watches Git repositories and syncs desired state to the cluster
3. **Jenkins Integration**: Jenkins builds Docker images and updates Git tags; ArgoCD detects changes and deploys
4. **Kustomize for Applications**: Application services packaged as Kustomize manifests (base + environment overlays) stored in Git
5. **Helm for Infrastructure**: Infrastructure components (Jenkins, ArgoCD, Harbor, ELK, Jaeger, Prometheus, Kafka, RabbitMQ) deployed via Helm charts
6. **Namespace-per-Environment**: Separate namespaces for dev, QA, staging, production
7. **Ingress Controller**: HAProxy ingress controller for external traffic routing (NGINX ingress retained for Keycloak only)
8. **Monitoring**: Prometheus + Grafana for cluster and application metrics

## Consequences

**Positive:**
- Declarative infrastructure — entire system state is version-controlled in Git
- Automated rollbacks via ArgoCD sync history
- Self-healing — K8s automatically restarts failed pods
- Horizontal pod autoscaling for load handling
- Infrastructure as Code (IaC) via Ansible for cluster provisioning

**Negative:**
- Steep learning curve for teams new to K8s
- On-premise K8s requires significant infrastructure investment
- Network complexity (CNI, service mesh considerations)
- Storage management for stateful workloads (SQL Server, RabbitMQ)
- Windows container support is more complex than Linux
- Dual ingress controllers (HAProxy + NGINX) increase operational complexity and require expertise in both

**Future constraints:**
- Any deployment target change (e.g., cloud migration) requires a new ADR
- New application services must include Kustomize manifests from day one
- New infrastructure components may use Helm if they fit the infrastructure pattern
- All environment configuration must be in Git (no manual cluster changes)
- Service mesh adoption (e.g., Istio) would require a new ADR
