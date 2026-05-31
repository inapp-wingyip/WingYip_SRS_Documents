# ADR-007. SSIS Service Account Credentials in Plaintext

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform has a critical security vulnerability: the SQL Server `sa` (system administrator) account password is stored in plaintext across multiple locations in source control.

**Critical Finding**: The `sa` account password (`1n9pp2.0@123`) is committed to version control in multiple files across the entire backend ecosystem, not just in SSIS packages. This password grants full sysadmin privileges across all SQL Server instances.

**Scope of exposure:**
- **SSIS packages**: `Silver_Layer_ETL/Project.params` (non-sensitive parameter with `Sensitive="0"`)
- **Backend microservices**: 36 `appsettings.json` and `appsettings.Development.json` files across 14+ services (Administration, Audit, Authentication, BulkReplenishmentEngine, DidiReplenishmentEngine, FreshGoodsReplenishmentEngine, GenericProcessEngine, Print, Product, Replenishment, Reports, ReportEngine, Spaceman, StockControl, StoreOperations)
- **Test projects**: Connection strings in test base classes
- **Staging configs**: `appsettings.Staging.json` files

This is a platform-wide credential leak, not limited to the Data Engineering ecosystem.

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
