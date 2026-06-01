# ADR-063. Dockerfile Standardization Across All Services

- **Status:** proposed
- **Date:** 2026-06-01
- **Supersedes:** N/A

## Context

The WingYip SRS ecosystem has **61 Dockerfiles** across 4 repositories (`BE_EcoSystem`, `FE_EcoSystem`, `HH_EcoSystem`, `Infrastructure`). These Dockerfiles were created organically over the project lifetime by different teams, leading to significant inconsistency, duplication, and — in several cases — copy-paste errors that prevent services from building.

**Key problems identified:**

1. **4 API service Dockerfiles are broken** — `MicroServiceTemplate.Api`, `BulkReplenishmentEngine.Api`, `FreshGoodsReplenishmentEngine.Api`, and `ReportEngine.Api` all still reference `WingYip.SRS.ProductService.Api` from a stale template. Their `ENTRYPOINT` targets a DLL that does not exist in their build context.
2. **16 Database Dockerfiles are ~95% identical** — each builds a temporary `.sqlproj`, installs SqlPackage + sqlcmd, and deploys a DACPAC. The only variation is the `<Name>` in the generated sqlproj and a few per-service `Content Remove` filters. This is a maintenance nightmare: any SqlPackage version update requires 16 file edits.
3. **API Dockerfiles follow 4 sub-patterns** instead of 1 standard:
   - Pattern A (Clean): correct project references, consistent caching
   - Pattern B (Broken): stale `ProductService.Api` references
   - Pattern C (SkiaSharp): adds font dependencies for label generation
   - Pattern D (Mixed): SkiaSharp + `sed` placeholder replacement for nuget.config
4. **Security gaps:**
   - NuGet credentials (`NUGET_PASSWORD`) are passed as `ENV` in the build stage, persisting in Docker layer history
   - No `.dockerignore` — `COPY . .` pulls in `bin/`, `obj/`, `.git/`, IDE configs
   - No `LABEL` metadata on any image
5. **Operational gaps:**
   - Only 2 of 61 images have `HEALTHCHECK` (Frontend Nginx, Keycloak)
   - No API service has container health checks — Kubernetes cannot detect unhealthy pods
   - Database DACPAC stage uses `find + head -n1` to locate the artifact — fragile if multiple files match
6. **Jenkins agent inconsistency:** custom-agent uses JDK 21, react-native-agent uses JDK 17 — no documented rationale

A full gap analysis with per-file findings is maintained in:  
`WingYip_SRS_BE_EcoSystem/docs/Dockerfile_Standardization_Plan.md`

## Decision

We will standardize all Dockerfiles through a **4-phase roadmap**:

### Phase 1 — Critical Fixes (Immediate)

1. Fix the 4 broken Pattern B API Dockerfiles to reference their correct service assemblies
2. Verify whether `DidiReplenishmentEngine.Api` actually requires SkiaSharp font deps; remove if unused
3. Add a root `.dockerignore` to `BE_EcoSystem` to exclude `bin/`, `obj/`, `.git/`, `*.md`, `.vscode/`

### Phase 2 — API Dockerfile Template (1 PR)

1. Create a unified `Dockerfile.api.template` in `BE_EcoSystem` that all 16 API services derive from
2. Template covers:
   - Base runtime (`mcr.microsoft.com/dotnet/aspnet:8.0`)
   - Build stage with conditional SkiaSharp deps
   - Standardized `nuget.config` copy syntax
   - `LABEL` metadata (`org.opencontainers.image.title`, `version`)
   - `HEALTHCHECK` targeting `/health`
3. Apply the template to all 16 services, replacing the 4 ad-hoc patterns with 1 standard
4. Replace `ENV NUGET_PASSWORD` with BuildKit `RUN --mount=type=secret` (if CI supports BuildKit secrets)

### Phase 3 — Database Dockerfile DRY (1 PR)

1. Extract the SqlPackage + sqlcmd installation stage into a **shared base image** (`wingyip-srs-database-deployer:latest`) OR
2. Create a templating script (PowerShell/bash) that generates all 16 Database Dockerfiles from a single source of truth
3. Reduce 16 × ~96 lines → 1 template + 16 × ~15 lines

### Phase 4 — Optimization (1 PR)

1. Evaluate `PublishTrimmed=true` and `PublishAot` for .NET 8 runtime image size reduction
2. Evaluate chiseled/distroless base images for smaller security surface
3. Document JDK version rationale for Jenkins agents (align or explain)

## Consequences

**Positive:**
- Broken services can be containerized and deployed to K8s
- 16 Database Dockerfiles become maintainable — 1 change propagates everywhere
- Health checks enable Kubernetes self-healing (pod restart on failure)
- BuildKit secrets prevent NuGet credentials from leaking into image layers
- `.dockerignore` reduces build context size and speeds up CI
- Standard `LABEL` metadata improves traceability in container registries

**Negative:**
- Template rollout touches 32 Dockerfiles (16 API + 16 Database) — requires coordinated QA validation
- BuildKit secrets may need Jenkins pipeline updates to pass `--secret` flags
- `HEALTHCHECK` requires every API service to expose a `/health` endpoint (most already do via ASP.NET Core health checks middleware, but must be verified)
- `PublishTrimmed` requires testing — trimming can break reflection-based code (AutoMapper, EF Core proxies)

**Future constraints:**
- Any new service must use the standardized template, not copy an existing Dockerfile
- Database Dockerfile changes should be made in the template/script, not per-service files
- ADR-063 should be superseded if the team migrates to a higher-level build system (e.g., Bazel, Earthly, or Dagger)

## Related ADRs

- ADR-004: On-Premise Kubernetes with ArgoCD GitOps (deployment target)
- ADR-041: NuGet Packaging Strategy via GitHub Packages (private feed credentials)
- ADR-050: Jenkins CI/CD Pipeline Patterns (BuildKit secrets support)
- ADR-051: ArgoCD GitOps Auto-Sync (health check dependency for rolling updates)
- ADR-047: QuestPDF and SkiaSharp (justifies Pattern C font dependencies)

## Related Tickets

- None yet — this ADR was created from a deferred TODO item generated during WYSRS-4280 implementation

## Supporting Documents

- `WingYip_SRS_BE_EcoSystem/docs/Dockerfile_Standardization_Plan.md` — full gap analysis with per-file findings, pattern taxonomy, and verification checklist
