# ADR-056. SSIS Security and Deployment Patterns

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS data engineering layer (Bronze and Silver ETL projects) uses SQL Server Integration Services (SSIS) with multiple security concerns in the current deployment configuration. These patterns were inherited from the initial development setup and have not been hardened for production.

**Current implementation:**

- **EncryptSensitiveWithUserKey**: Both SSIS projects (`Bronze_Layer_ETL.dtproj` and `Silver_Layer_ETL.dtproj`) use `ProtectionLevel: EncryptSensitiveWithUserKey`. Sensitive data (connection strings, passwords) is encrypted with the developer's Windows user key, making packages non-deployable to other machines without the same user profile.
- **Hardcoded Connections**: All packages contain hardcoded connection strings pointing to `10.10.80.75` with `User ID=sa`. The `sa` username is visible in plaintext within the package XML, and connection details are not parameterized or externalized.
- **SMTP Without SSL**: All packages configure SMTP with `EnableSsl=False` and `UseWindowsAuthentication=False`, pointing to `10.10.80.53`. Email notifications (error alerts, completion notices) are sent in plaintext without encryption or authentication.
- **Minimal ConnectRetry**: All connection managers use `ConnectRetryCount=1` and `ConnectRetryInterval=5` (seconds). This provides minimal resilience against transient network failures.

## Decision

We accept the current SSIS security posture with EncryptSensitiveWithUserKey, hardcoded connections, and plaintext SMTP for the current deployment phase.

1. **ProtectionLevel** remains EncryptSensitiveWithUserKey
2. **Hardcoded connection strings** with `sa` credentials are accepted
3. **SMTP without SSL** is accepted for email notifications
4. **Minimal retry configuration** (ConnectRetryCount=1, ConnectRetryInterval=5) is accepted

## Consequences

**Positive:**
- Works in the current environment without additional configuration
- No changes needed to existing SSIS packages for immediate deployment
- Developer workflow is unimpeded (packages run under the developer's Windows profile)

**Negative:**
- **Cannot deploy to other machines**: EncryptSensitiveWithUserKey ties packages to the developer's Windows user profile. Deployment to a server with a different user account will fail to decrypt sensitive data.
- **sa username exposed in plaintext**: The `sa` (sysadmin) username is visible in package XML. While the password is encrypted by the protection level, the username exposure violates least-privilege principles.
- **SMTP emails unencrypted**: All ETL notification emails are sent in plaintext. Error messages, data summaries, and operational details are transmitted without encryption.
- **Minimal retry may not handle transient failures**: ConnectRetryCount=1 with 5-second interval provides almost no resilience against temporary network blips, DNS resolution delays, or SQL Server restart windows.

**Future constraints:**
- Change ProtectionLevel to `EncryptSensitiveWithPassword` or `DontSaveSensitive` with environment variable/SSIS catalog parameter binding before production deployment
- Replace hardcoded `sa` credentials with parameterized connection strings using least-privilege service accounts
- Enable SMTP SSL/TLS and authentication for all ETL notification emails
- Increase ConnectRetryCount to at least 3 with ConnectRetryInterval of 10-15 seconds for production resilience
- Evaluate SSIS catalog deployment model (SSISDB) for centralized package management and environment-specific configurations

## Related ADRs

- ADR-007: SSIS plaintext credentials (credential exposure)
- ADR-032: Bronze/Silver medallion architecture (ETL pipeline design)
- ADR-034: SSIS project deployment (deployment model)
- ADR-036: SSIS HTML email notifications (email design)
- ADR-038: ETL environment variables (configuration externalization)

## Key Files

- `Bronze_Layer_ETL.dtproj`
- `Silver_Layer_ETL.dtproj`