# ADR-045. Argon2id Password Hashing and Active Directory LDAP Integration

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

Two security-related technology choices in the WingYip SRS backend are not covered by ADR-003 (Keycloak Authentication): password hashing and Active Directory integration.

**Argon2id password hashing:**
- Uses `Konscious.Security.Cryptography.Argon2` v1.3.1 for password hashing
- Custom `PasswordHashExtension` with configurable parameters:
  - Memory cost (configurable)
  - Iterations / time cost (configurable)
  - Parallelism degree (configurable)
- Argon2id is the winner of the Password Hashing Competition (PHC) and is recommended by OWASP for password storage

**Active Directory LDAP integration:**
- Uses `Novell.Directory.Ldap.NETStandard` v4.0.0 for Active Directory integration
- Provides user directory lookup and synchronization capabilities
- Dual identity source: Keycloak for authentication tokens, AD/LDAP for user directory lookup and sync

**Dual identity concern:** The system maintains two identity sources — Keycloak for authentication tokens and AD/LDAP for user directory information. This creates synchronization complexity and potential consistency issues.

## Decision

We use Argon2id for password hashing and Novell LDAP for Active Directory integration, supplementing Keycloak authentication with local password hashing and AD user directory capabilities.

## Consequences

**Positive:**
- **Argon2id** is the PHC winner and OWASP-recommended algorithm for password hashing
- Configurable parameters (memory, iterations, parallelism) allow tuning for security vs. performance trade-offs
- Argon2id provides superior resistance to GPU-based attacks compared to BCrypt
- Novell LDAP library enables cross-platform AD integration on .NET 8 (Linux containers)

**Negative:**
- **Argon2id requires native library dependencies** — the `Konscious.Security.Cryptography.Argon2` package depends on native `libsodium` which must be available in the runtime environment (Docker images, K8s pods)
- **Different performance characteristics than BCrypt** — Argon2id is memory-hard, which may cause higher memory usage under load; parameter tuning is critical
- **Novell library maintenance risk** — `Novell.Directory.Ldap.NETStandard` v4.0.0 is a community-maintained library; Microsoft's `System.DirectoryServices` is the official .NET alternative but has platform limitations
- **Dual identity source creates sync complexity** — Keycloak and AD/LDAP must be kept consistent; user changes in AD may not immediately reflect in Keycloak and vice versa
- No documented strategy for resolving identity conflicts between Keycloak and AD

**Future constraints:**
- Ensure Docker images and K8s pods include the required native `libsodium` library
- Benchmark Argon2id parameters under production load to balance security and performance
- Document the dual identity source architecture and synchronization strategy
- Evaluate `System.DirectoryServices.Protocols` as an alternative to Novell LDAP for .NET 8+ on Linux
- Create a runbook for identity conflict resolution between Keycloak and AD

## Related ADRs

- ADR-003: Keycloak Authentication
- ADR-040: Core Shared Library Ecosystem and Monorepo Structure

## Key files

- `PasswordHashExtension.cs`
- `NovellLdapServices.cs`
- `Core.csproj`