# ADR-055. Keycloak Customizations and Backup

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS infrastructure deploys Keycloak with three notable customizations: a custom-built container image, a daily PostgreSQL backup CronJob, and relaxed hostname validation. Each decision introduces trade-offs between operational convenience and security/maintainability.

**Current implementation:**

- **Custom Image**: Keycloak runs a custom-built image from Harbor (`10.10.80.77:30280/library/custom-keycloak:v1.0.1`) rather than the official Keycloak image. This allows bundling of realm configurations, custom themes, and extensions.
- **PostgreSQL Backup**: A CronJob runs daily at 2 AM using `pg_dump + gzip`, retaining 7 days of backups. This is the only database backup mechanism in the entire infrastructure.
- **KC_HOSTNAME_STRICT**: Set to `false`, allowing Keycloak to accept requests from any hostname without validation. This relaxes the default security posture.

## Decision

We use a custom Keycloak image with daily PostgreSQL backup and relaxed hostname validation.

1. **Custom image** is maintained in Harbor and used for all Keycloak deployments
2. **Daily PostgreSQL backup** at 2 AM with 7-day retention is the sole backup mechanism
3. **KC_HOSTNAME_STRICT=false** is accepted for current deployment

## Consequences

**Positive:**
- Custom image can include pre-configured realm settings, custom themes, and authentication extensions
- Daily backup provides a recovery window for Keycloak's PostgreSQL database
- Relaxed hostname validation simplifies development and internal network access (no DNS configuration needed for every access path)

**Negative:**
- **Custom image maintenance burden**: Every Keycloak upgrade requires rebuilding the custom image, testing realm configs and themes against the new version, and re-publishing to Harbor
- **Backup only covers Keycloak DB**: The PostgreSQL backup does not cover user stores, external identity provider configurations, or other service databases. If Keycloak integrates with AD/LDAP, those configurations are in the DB but the user store itself is not backed up by this mechanism
- **Hostname strict disabled is a security relaxation**: Allows requests from any hostname, enabling potential phishing or redirect attacks in production
- **No backup for other databases**: The 7-day pg_dump is the only backup in the entire infrastructure — all other service databases (14+ microservice DBs) have no automated backup

**Future constraints:**
- Implement a comprehensive backup strategy covering all service databases, not just Keycloak's PostgreSQL
- Enable `KC_HOSTNAME_STRICT=true` with proper DNS configuration before production
- Establish a custom image rebuild pipeline for Keycloak version upgrades
- Evaluate Velero or similar tool for cluster-wide backup including PVs and configmaps
- Consider exporting Keycloak realm configuration as code (realm JSON export) for version control

## Related ADRs

- ADR-003: Keycloak authentication (identity provider selection)
- ADR-006: Vault dev mode (secrets management)
- ADR-054: Storage and persistence strategy (local storage implications for backups)

## Key Files

- `keycloak-deployment.yaml`
- `backup-cronjob.yaml`
- `keycloak-custom/`