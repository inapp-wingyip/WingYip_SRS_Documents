# ADR-008. SSIS Service Account Credentials in Plaintext

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS Data Engineering ecosystem uses SQL Server Integration Services (SSIS) for ETL pipelines implementing a Bronze/Silver medallion architecture. SSIS packages connect to SQL Server databases using the `sa` (system administrator) account.

**Critical Finding**: The `sa` account password (`1n9pp2.0@123`) is stored as a non-sensitive parameter in `Silver_Layer_ETL/Project.params` with `Sensitive="0"` and is committed to version control. This password grants full sysadmin privileges across all SQL Server instances.

The password appears in:
- `Silver_Layer_ETL/Silver_Layer_ETL/Project.params`
- `Silver_Layer_ETL/Silver_Layer_ETL/obj/Development/Project.params`

## Decision

We explicitly document this security vulnerability and the required remediation:

1. **Current State (Accepted as Technical Debt)**: The `sa` password is stored in plaintext SSIS parameters. This is a known security risk accepted temporarily.
2. **Immediate Mitigation Required**:
   - Rotate the `sa` password immediately
   - Replace `sa` with dedicated service accounts per pipeline (least-privilege principle)
   - Mark connection manager passwords as `Sensitive="1"` (encrypted with project protection level)
   - Add `*.params` to `.gitignore` to prevent future commits
   - Use SSIS Environment Variables or SQL Server Agent proxy accounts for credential injection
3. **Long-term Strategy**: Migrate to Azure Key Vault or HashiCorp Vault for SSIS credential storage. Use SSIS Environment References to inject secrets at runtime.

## Consequences

**Positive:**
- Transparent documentation of critical security vulnerability
- Clear remediation path with immediate and long-term actions
- Service account per pipeline enables audit trails and least-privilege access

**Negative:**
- **Critical security risk**: Admin credentials in version control expose all databases
- Anyone with repository access has full SQL Server sysadmin privileges
- Password rotation requires coordinated updates across all SSIS packages and connection managers
- Historical commits retain the password in Git history (requires history rewriting or password rotation)
- SSIS project protection level (`EncryptSensitiveWithUserKey`) ties deployment to a single developer's key

**Future constraints:**
- No new ETL packages may use `sa` account
- All new packages must use dedicated service accounts with minimal permissions
- Secret management must be externalized (Vault, Azure Key Vault, or SQL Server Agent proxies) before production
- This ADR must be resolved (superseded by remediation ADR) before production data engineering deployment

## Remediation ADR Required

A follow-up ADR must be created:
- **ADR-00X: SSIS Credential Management Hardening** — covering service account creation, project protection level migration, external secret store integration, and Git history cleanup
