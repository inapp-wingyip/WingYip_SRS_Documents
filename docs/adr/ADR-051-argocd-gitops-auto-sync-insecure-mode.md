# ADR-051. ArgoCD GitOps Auto-Sync and Insecure Mode

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform uses ArgoCD for GitOps-based Kubernetes deployment with two significant configuration decisions.

**Auto-Sync with Prune and Self-Heal:**
- All ArgoCD applications are configured with `automated: { prune: true, selfHeal: true }`
- **Prune**: ArgoCD automatically deletes Kubernetes resources that are removed from Git
- **Self-Heal**: ArgoCD automatically reverts any manual changes made to the cluster that diverge from the Git state
- Sync interval is 3 minutes (ArgoCD default — not explicitly configured)
- This means any resource deleted from Git is automatically removed from the cluster, and any manual `kubectl apply` or `kubectl edit` is automatically reverted

**Insecure Mode:**
- ArgoCD server runs with the `--insecure` flag, allowing HTTP connections without TLS
- This disables encryption for the ArgoCD UI and API traffic
- In a production environment, this exposes the GitOps control plane to network interception

**Kustomize Pattern:**
- Every service uses a `base/` + `overlays/{dev,qa,staging,production}/` directory structure
- Keycloak is an exception: it additionally has a separate `gitops-manifests/` directory with non-Kustomize manifests
- This inconsistency means Keycloak has two sources of deployment truth that can diverge

**Key concerns:**
- Aggressive auto-prune can accidentally delete resources if a Git change removes them unintentionally
- Self-heal prevents any manual cluster intervention, which can be problematic during incidents
- Insecure mode exposes the GitOps control plane to network-level attacks
- Keycloak's dual manifest strategy creates inconsistency with the rest of the platform

## Decision

We use **aggressive ArgoCD auto-sync with prune and self-heal enabled**, running in **insecure mode**:

1. **Auto-sync** with `prune: true` and `selfHeal: true` on all ArgoCD applications
2. **3-minute sync interval** for detecting and applying Git changes
3. **Insecure mode** (`--insecure` flag) on the ArgoCD server for HTTP access
4. **Kustomize** `base/` + `overlays/` pattern for all services except Keycloak (which has additional `gitops-manifests/`)

## Consequences

**Positive:**
- Infrastructure stays in sync with Git — no manual sync required
- Manual cluster changes are automatically reverted, preventing configuration drift
- Self-heal ensures the cluster state matches the declared Git state at all times
- Simple operational model: Git is the single source of truth

**Negative:**
- **Accidental deletion risk**: A mistaken Git commit that removes resources triggers automatic pruning in the cluster with no confirmation step
- **No manual intervention window**: Self-heal immediately reverts any emergency `kubectl` changes, which can be problematic during incidents where manual overrides are needed
- **Unencrypted ArgoCD traffic**: The `--insecure` flag disables TLS for all ArgoCD UI and API communication, exposing the GitOps control plane to network interception
- **Keycloak inconsistency**: Keycloak's `gitops-manifests/` directory exists alongside Kustomize overlays, creating two sources of truth that can diverge
- **3-minute sync delay**: Changes pushed to Git take up to 3 minutes to appear in the cluster, which may be too slow for critical fixes

**Future constraints:**
- Enable TLS on ArgoCD server and remove the `--insecure` flag before production deployment
- Consider adding Git branch protection rules requiring review before merging to the Infrastructure branch that ArgoCD syncs from
- Implement ArgoCD `SyncOptions` with `PrunePropagationPolicy=background` and resource hooks for critical resources to prevent accidental deletion
- Migrate Keycloak `gitops-manifests/` into the standard Kustomize `base/` + `overlays/` pattern for consistency
- Add manual sync windows or pause capabilities for incident response scenarios where self-heal must be temporarily disabled
- Evaluate webhook-triggered sync (vs. polling) for faster deployment propagation

---

## References

- `argocd-values.yaml` — ArgoCD Helm values with insecure flag and sync configuration
- `AuthenticationService/argocd/dev.yaml` — Example ArgoCD application manifest
- `KeycloakAuthentication/gitops-manifests/` — Keycloak non-Kustomize manifests
- ADR-004 (On-Premise Kubernetes) — Infrastructure foundation
- ADR-050 (Jenkins CI/CD Pipeline Patterns) — Jenkins GitOps commit pattern that feeds ArgoCD