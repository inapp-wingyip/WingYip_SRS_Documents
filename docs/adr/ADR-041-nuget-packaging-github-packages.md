# ADR-041. NuGet Packaging Strategy via GitHub Packages

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

Every service layer (Data, Service, Client) across the WingYip SRS backend ecosystem is independently versioned and published as a NuGet package to GitHub Packages. This enables services to consume shared libraries and other service layers via package references rather than project references.

**Current implementation:**
- **GeneratePackageOnBuild**: Set to `true` on all `.csproj` files, producing `.nupkg` artifacts on every build
- **Version source**: `Version.txt` files per library, sourced via the `UpdateVersionFromFile` MSBuild target
- **Symbol packages**: `.snupkg` files are included for debugging support
- **Package registry**: GitHub Packages (private feed)

**Security concern:** Multiple files across the backend codebase contain plaintext GitHub Personal Access Tokens (PATs) for package feed authentication and publishing:
- `WingYip.SRS.Core/WingYip.SRS.Service/nuget.config` — PAT in `ClearTextPassword` field
- `WingYip.SRS.GenericProcessEngine/package_command.txt` — PAT in `dotnet nuget push` commands
- `WingYip.SRS.Administration/WingYip.SRS.Service/nuget_command.txt` — PAT in `dotnet nuget push` command

These tokens are present in source control, exposing credentials. The actual token value is redacted from this document.

**Coupling concern:** When the Core library is updated, every consuming service must independently update its package reference. There is no automated mechanism to propagate Core library updates across all services.

## Decision

We publish NuGet packages to GitHub Packages using a version-from-file strategy (`Version.txt` + `UpdateVersionFromFile` MSBuild target) with symbol packages for debugging.

## Consequences

**Positive:**
- Fine-grained versioning — each service layer can evolve independently
- Symbol packages (`.snupkg`) enable debugging into shared library code
- Version-from-file strategy makes version bumps explicit and traceable
- GitHub Packages provides a private, organization-scoped feed

**Negative:**
- **Exposed credentials** — `nuget.config` and `package_command.txt` contain plaintext PATs in source control
- No central package management — each service must be updated independently when Core library changes
- No automated dependency update pipeline for propagating shared library changes
- `GeneratePackageOnBuild=true` on all projects produces packages even during development builds, slowing iteration
- No `Directory.Packages.props` for centralized NuGet package version management

**Future constraints:**
- Move PATs to environment variables or secret management (e.g., HashiCorp Vault, GitHub Secrets)
- Add `package_command.txt` to `.gitignore` immediately
- Consider enabling Central Package Management via `Directory.Packages.props`
- Evaluate whether `GeneratePackageOnBuild` should be conditional on CI builds only
- Implement automated dependency update pipeline (e.g., Dependabot, Renovate) for Core library propagation

## Related ADRs

- ADR-040: Core Shared Library Ecosystem and Monorepo Structure
- ADR-006: Vault Dev Mode (credential management concerns)

## Key files

- `nuget.config`
- `package_command.txt`
- All `*.csproj` files with `GeneratePackageOnBuild`