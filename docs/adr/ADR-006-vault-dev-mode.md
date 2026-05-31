# ADR-007. HashiCorp Vault in Development Mode

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform uses HashiCorp Vault for secret management, integrated with Kubernetes via the External Secrets Operator (ESO) to sync secrets into K8s Secret resources. Vault is deployed via Ansible (`ansible/roles/vault/tasks/main.yml`).

**Critical Finding**: Vault is currently running in **development mode** (in-memory storage, no TLS, no unseal automation, no high availability). This is explicitly documented in the Ansible role comments: "Deploy HashiCorp Vault in dev mode."

This configuration is **not production-ready** and represents a significant security risk: secrets are stored in-memory only (lost on pod restart), there is no encryption in transit, and there is no redundancy.

## Decision

We explicitly accept that Vault currently runs in development mode and document the required hardening path:

1. **Current State (Accepted for Development/QA only)**: Vault in dev mode is acceptable for non-production environments where secret longevity and availability are not critical.
2. **Production Requirement (Pending)**: Before any production deployment, Vault MUST be migrated to:
   - HA mode with integrated storage (Raft)
   - Auto-unseal (via Azure/AWS KMS or Shamir threshold)
   - TLS enabled (certificates from internal PKI)
   - Production license
   - Audit logging enabled
3. **Interim Mitigation**: Until production hardening is complete, sensitive secrets (database passwords, API keys) must NOT be stored in Vault. Use Kubernetes Secrets directly with restricted RBAC.

## Consequences

**Positive:**
- Transparent documentation of security posture
- Clear hardening checklist for production readiness
- Dev mode reduces complexity for development and QA environments
- ESO integration can be tested without production Vault complexity

**Negative:**
- **Critical security risk**: No encryption at rest or in transit for secrets
- Secret loss on pod restart (in-memory only)
- No audit trail of secret access
- Single point of failure (no HA)
- Blocks production deployment until hardened

**Future constraints:**
- Production deployment is BLOCKED until Vault hardening ADR is created and implemented
- Any new secret management integration must account for Vault's current limitations
- Migration to hardened Vault requires downtime and secret re-seeding

## Remediation ADR Required

A follow-up ADR must be created before production go-live:
- **ADR-00X: HashiCorp Vault Production Hardening** — covering HA setup, auto-unseal, TLS, audit logging, and disaster recovery
