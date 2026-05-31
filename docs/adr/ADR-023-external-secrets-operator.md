# ADR-023. External Secrets Operator with HashiCorp Vault

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform requires secure secret management for database connection strings, RabbitMQ credentials, Active Directory bind credentials, and Elasticsearch URLs. With 16+ services and 4 environments, manual secret management is error-prone and insecure.

**Current implementation:**
- **HashiCorp Vault**: Source of truth for all secrets (see ADR-006 for Vault security concerns)
- **External Secrets Operator (ESO)**: Syncs Vault secrets into Kubernetes Secrets automatically
- **ClusterSecretStore**: Named `vault-backend`, connects to Vault instance
- **Per-service ExternalSecret**: Each service has an `external-secrets.yaml` defining which Vault paths to sync
- **Refresh interval**: 1 hour for automatic secret rotation

**Example pattern** (from AdministrationService):
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  data:
  - secretKey: ConnectionStrings__DefaultConnection
    remoteRef:
      key: secret/data/wingyip-srs/staging/administration/database
      property: connectionstring
```

## Decision

We use **External Secrets Operator** to sync Vault secrets into Kubernetes:

1. **Vault as source of truth**: All secrets stored in Vault KV engine
2. **ESO as sync mechanism**: `ExternalSecret` resources define mappings from Vault paths to K8s Secrets
3. **ClusterSecretStore**: Single `ClusterSecretStore` named `vault-backend` for all namespaces
4. **Environment-scoped paths**: Vault paths follow pattern `secret/data/wingyip-srs/{env}/{service}/{secret-type}`
5. **Applications read from K8s Secrets**: Pods mount secrets as environment variables via `secretKeyRef`

## Consequences

**Positive:**
- Secrets are never stored in Git (only ExternalSecret manifests, which contain no values)
- Automatic rotation via `refreshInterval` without pod restarts
- Single source of truth (Vault) for all environments
- Audit trail in Vault for all secret access

**Negative:**
- **Vault must be available**: If Vault is down, ESO cannot sync new secrets (existing K8s Secrets remain)
- **Complexity**: Two systems to maintain (Vault + ESO) vs simple K8s Secrets
- **Vault dev mode risk**: See ADR-006 — Vault running in dev mode undermines the entire secret management chain
- **No secret encryption at rest in K8s**: K8s Secrets are base64-encoded, not encrypted by default
- **ESO failure mode**: If ESO controller fails, secrets stop rotating but existing ones remain valid

**Future constraints:**
- Vault MUST be migrated from dev mode to production mode before this pattern is truly secure
- Consider sealing secrets with Sealed Secrets or SOPS as backup if Vault becomes unavailable
- Rotate Vault tokens used by ESO regularly
- Monitor ESO sync status as part of production health checks

## Related ADRs

- ADR-006: HashiCorp Vault in development mode (security concern)
- ADR-004: On-premise Kubernetes (deployment infrastructure)
