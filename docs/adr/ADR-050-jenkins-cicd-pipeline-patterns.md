# ADR-050. Jenkins CI/CD Pipeline Patterns

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform uses Jenkins for CI/CD with several interconnected pipeline and infrastructure decisions.

**Docker-in-Docker (DinD):**
- Jenkins agents run as privileged Kubernetes pods
- Agent pods mount the host Docker socket (`/var/run/docker.sock`) to build and push container images
- Privileged containers with Docker socket access grant near-host-level permissions to the build pipeline

**GitOps Commit Pattern:**
- Each service's `Jenkinsfile` builds a Docker image, pushes it to Harbor registry, then commits directly to the Infrastructure repository to update Kustomize overlay image tags
- This creates a tight coupling: every deployment requires a Git commit to the Infrastructure repo
- ArgoCD then detects the Git change and applies it to the cluster

**Insecure Harbor Registry:**
- Harbor is deployed with `tls.enabled: false`, serving the Docker registry over plain HTTP
- All cluster nodes are configured with `insecure-registries` pointing to the Harbor endpoint
- Container images are pushed and pulled without TLS encryption or certificate verification

**Squid Proxy:**
- Jenkins uses `HTTP_PROXY`/`HTTPS_PROXY` environment variables pointing to a Squid proxy on `k8s-node2`
- This workaround exists because `k8s-node1` has broken outbound HTTPS connectivity
- The proxy is a point solution for a network infrastructure problem

**React Native Agent:**
- A dedicated Jenkins agent with Android SDK and 8GB memory handles React Native (handheld) builds
- Mobile builds require significantly more resources than backend/frontend builds

**Key concerns:**
- Privileged containers with Docker socket access represent a significant security risk
- Unencrypted Harbor traffic exposes container images to network interception
- GitOps commit pattern means Infrastructure repo commits are automated, not human-reviewed
- Squid proxy is a workaround for a network issue that should be fixed at the infrastructure level

## Decision

We use **Docker-in-Docker Jenkins agents with GitOps manifest update pattern and insecure Harbor registry**:

1. **Jenkins agents** run as privileged pods mounting the host Docker socket for image builds
2. **GitOps commit pattern**: Each `Jenkinsfile` builds, pushes to Harbor, then commits updated Kustomize manifests to the Infrastructure repo
3. **Harbor registry** runs without TLS (`tls.enabled: false`) with all nodes configured as insecure registries
4. **Squid proxy** on `k8s-node2` provides outbound HTTPS connectivity for Jenkins
5. **Dedicated React Native agent** with Android SDK handles mobile builds

## Consequences

**Positive:**
- Simple, linear pipeline: build → push → commit → ArgoCD sync
- Automatic GitOps updates: Infrastructure repo stays in sync with deployed images
- No TLS certificate management overhead for Harbor
- Squid proxy enables Jenkins outbound connectivity despite node1 network issues

**Negative:**
- **Security risk**: Privileged containers + Docker socket mount grant near-host-level access; a compromised pipeline can escape to the host
- **Unencrypted Harbor traffic**: All container image pushes and pulls occur over plain HTTP, vulnerable to network interception and tampering
- **Automated Infrastructure commits**: GitOps commits bypass human review, meaning a compromised or buggy Jenkinsfile can push malicious manifests
- **Hardcoded proxy workaround**: Squid proxy on node2 exists because node1 has broken outbound HTTPS — this is a network infrastructure problem, not a CI/CD problem
- **Manual Jenkinsfile maintenance**: Each service maintains its own `Jenkinsfile`, leading to duplication and drift between services
- **No image signing**: Images are pushed and deployed without cryptographic signing or verification

**Future constraints:**
- Migrate from Docker socket mounting to Kubernetes-native builders (e.g., BuildKit, kaniko) to eliminate privileged container requirements
- Enable TLS on Harbor with internal CA certificates to encrypt all registry traffic
- Fix node1 outbound HTTPS connectivity at the network level and remove the Squid proxy dependency
- Implement image signing (e.g., Cosign/Notary) to verify image integrity before deployment
- Extract shared pipeline logic into a Jenkins Shared Library to reduce Jenkinsfile duplication
- Add human review gates for Infrastructure repo commits (at minimum, branch protection rules)

---

## References

- `jenkins-values.yaml` — Jenkins Helm values with agent configuration
- `AuthenticationService/Jenkinsfile` — Example backend service pipeline
- `FrontendService/Jenkinsfile` — Example frontend service pipeline
- `harbor-values.yaml` — Harbor Helm values with `tls.enabled: false`
- ADR-004 (On-Premise Kubernetes) — Infrastructure foundation
- ADR-051 (ArgoCD GitOps Auto-Sync) — ArgoCD deployment and sync strategy