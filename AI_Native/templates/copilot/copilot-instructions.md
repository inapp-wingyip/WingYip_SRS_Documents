# WingYip Copilot Instructions

## SDD Invariants (Non-Negotiable)

1. **No code without spec** — Reference a spec before generating any implementation.
2. **Every AC needs verification** — All acceptance criteria must have executable tests.
3. **Spec-first workflow** — Read the spec before editing; include spec path in PRs.
4. **Build & validate** — Run build and tests locally before committing.

## Project Structure

- Backend: `WingYip_SRS_BE_EcoSystem/` (.NET 8, CQRS, EF Core)
- Frontend: `WingYip_SRS_FE_EcoSystem/` (React 19, RSBuild, Tailwind)
- Mobile: `WingYip_SRS_HH_EcoSystem/` (React Native 0.72, Android)
- Data Engineering: `WingYip_SRS_DE_EcoSystem/` (SSIS, Bronze/Silver)
- Infrastructure: `WingYip_SRS_Infrastructure/` (K8s, ArgoCD, Keycloak)
- Documentation: `WingYip_SRS_Documents/` (SRS, LLD, BRD, ADR)

## Commands

- Backend: `dotnet build && dotnet test`
- Frontend: `npm run lint && npm test`
- Mobile: `npm run lint && npm test`
- Data Engineering: Validate SSIS packages and SQL scripts
- Infrastructure: `kubectl apply --dry-run=client` or equivalent

## References

- [SDD Pipeline](WingYip_SRS_Documents/AI_Native/workflow/sdd-pipeline.md)
- [OpenSpec Config](WingYip_SRS_Documents/AI_Native/openspec/config.yaml)
- [Coding Standards](WingYip_SRS_Documents/architecture/11-coding-standards.md)
- [Guardrails](WingYip_SRS_Documents/AI_Native/agents/guardrails.md)
