# ADR-040. Core Shared Library Ecosystem and Monorepo Structure

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip.SRS.Core/ directory contains 8 independently versioned shared libraries under a single solution. All 14+ microservices depend on these libraries for cross-cutting concerns such as security, caching, HTTP communication, WebSocket management, reporting, print queue coordination, and unit testing infrastructure.

**Libraries and current versions (point-in-time snapshot — versions drift independently across services):**

| Library | Version | Purpose |
|---------|---------|---------|
| Core | 1.0.113 | Base middleware, DI extensions, shared contracts |
| Security.Core | 0.0.58 | Authentication, authorization, permission handling |
| Cache | 0.0.10 | Redis distributed cache abstractions |
| HttpClient | 0.0.9 | Resilient HTTP client factory |
| WebSocket | 0.0.2 | WebSocket connection management |
| Reporting | 0.0.3 | Report generation abstractions |
| PrintQueue | 0.0.12 | Print queue coordination |
| UnitTest.Core | — | Shared test infrastructure |

**Dependency chain:** Security.Core depends on Cache and HttpClient, creating an implicit coupling between these three libraries. A change in Cache or HttpClient may cascade to Security.Core and then to all consuming services.

**Versioning mechanism:** Each library has its own `Version.txt` file. The version is sourced via a custom MSBuild target `UpdateVersionFromFile` that reads the file at build time and sets the assembly/package version accordingly.

**Missing infrastructure:** There is no `Directory.Build.props` or `Directory.Packages.props` for centralized package management across the monorepo. Each `.csproj` manages its own dependencies independently.

## Decision

We accept the 8-library monorepo structure with independent versioning via `Version.txt` files and the `UpdateVersionFromFile` MSBuild target.

## Consequences

**Positive:**
- Centralized patterns — all services share the same middleware, error handling, and DI bootstrap
- Consistent middleware pipeline across all 14+ services
- Shared contracts reduce duplication and ensure API compatibility
- Independent versioning allows targeted updates without full ecosystem rebuilds

**Negative:**
- Breaking change in Core library requires updating all 14+ services
- Dependency chain (Security.Core → Cache + HttpClient) creates implicit coupling that is not immediately visible
- No centralized package management — absence of `Directory.Build.props` and `Directory.Packages.props` means version drift across libraries
- Monorepo without central package management increases risk of transitive dependency conflicts

**Future constraints:**
- Consider introducing `Directory.Build.props` and `Directory.Packages.props` for centralized dependency management
- Document the dependency chain between libraries explicitly
- Evaluate whether Security.Core should be split to remove the Cache/HttpClient dependency

## Related ADRs

- ADR-041: NuGet Packaging Strategy via GitHub Packages
- ADR-042: Permission-Based RBAC System with Cache-Aside Pattern
- ADR-043: Standardized Middleware Pipeline and DI Bootstrap

## Key files

- `WingYip.SRS.Core/WingYip.SRS.Service/*.csproj`
- `WingYip.SRS.Core/README.md`