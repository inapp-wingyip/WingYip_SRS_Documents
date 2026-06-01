# ADR-038. ETL Environment Variables for Configuration

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS ETL packages must run in multiple environments (dev, QA, staging, production) with different connection strings, file paths, and source system endpoints. A configuration strategy is needed to manage environment-specific values without modifying package code.

**Current implementation:**
- **SSIS environment variables**: Defined in SSISDB catalog, mapped to package parameters
- **Per-environment SSIS environments**: `Development`, `QA`, `Staging`, `Production` environments in SSISDB
- **Variable types**: Connection strings (source DB, target DB, log DB), file paths, email recipients, batch sizes
- **No external configuration**: No Consul, no Vault, no Kubernetes ConfigMaps for SSIS configuration

## Decision

We use **SSISDB environment variables** as the sole ETL configuration mechanism:

1. **SSISDB environments**: One environment per deployment environment (dev, QA, staging, prod)
2. **Environment variables**: Map to package parameters at execution time
3. **Sensitive values**: Database passwords stored in environment variables (not encrypted — see ADR-007)
4. **No external config store**: Consul, Vault, or Kubernetes ConfigMaps are not integrated with SSIS
5. **Deployment coordination**: Environment variable values must be manually configured when deploying to a new environment

## Consequences

**Positive:**
- Native SSIS configuration — no custom framework needed
- Same package runs in all environments without code changes
- Environment variables are versioned in SSISDB (execution history shows which values were used)

**Negative:**
- **No secret management**: Passwords stored as plaintext in SSISDB environment variables (ADR-007)
- **Manual configuration**: New environment setup requires manual creation of environment variables in SSISDB
- **No version control**: Environment variable values are NOT in Git — only package code is version-controlled
- **No external config integration**: Cannot leverage Vault, Consul, or K8s ConfigMaps for SSIS
- **No dynamic refresh**: Changing a connection string requires updating SSISDB, not a config reload
- **Environment drift**: Dev/QA/Prod environments may have different variable sets without detection

**Future constraints:**
- Integrate with Vault or Azure Key Vault for secret management (environment variables should reference Vault, not contain plaintext)
- Script environment creation (`PowerShell` + `dbatools`) for automated deployment
- Document all environment variables and their purpose in package README
- Consider migrating to external configuration store if cloud ETL adoption occurs

## Related ADRs

- ADR-007: SSIS `sa` plaintext credentials (same security gap in environment variables)
- ADR-034: SSIS Project Deployment (environment variables are part of Project Deployment model)
