# WingYip SRS — Developer & Agent Onboarding Guide

> **For new developers and AI agents working on the WingYip Stock Replenishment System.**
>
> Start here. Everything you need to understand the project, navigate the codebase, and start contributing.

---

## Quick Start (60-Second Context)

WingYip SRS is an **on-premise enterprise stock replenishment system** for a UK grocery chain. Built by **InApp Information Technologies**.

- **4 superstores** (Birmingham, Manchester, Croydon, Cricklewood) + remote Didi stores
- **14 backend microservices** (.NET 8, CQRS with MediatR)
- **React web app** (React 19, RSBuild, Tailwind, 13 feature modules)
- **React Native Android HHD** (React Native 0.72.3, Honeywell devices)
- **SSIS data pipelines** (SAP, Korber WMS, OpSuite ingestion)
- **On-premise K8s** (16 services, ArgoCD GitOps, HAProxy ingress)
- **Keycloak auth** (JWT tokens, 12 role types, RBAC)

---

## Repos at a Glance

| Repo | What | Where to Start |
|------|------|----------------|
| `WingYip_SRS_Documents/` | Master documentation | [INDEX.md](INDEX.md) |
| `WingYip_SRS_BE_EcoSystem/` | Backend (14 microservices) | [BE AGENTS.md](../WingYip_SRS_BE_EcoSystem/AGENTS.md) |
| `WingYip_SRS_FE_EcoSystem/` | React web app | [FE AGENTS.md](../WingYip_SRS_FE_EcoSystem/AGENTS.md) |
| `WingYip_SRS_HH_EcoSystem/` | React Native HHD | [HH AGENTS.md](../WingYip_SRS_HH_EcoSystem/AGENTS.md) |
| `WingYip_SRS_DE_EcoSystem/` | SSIS ETL pipelines | [DE AGENTS.md](../WingYip_SRS_DE_EcoSystem/AGENTS.md) |
| `WingYip_SRS_Infrastructure/` | K8s, ArgoCD, Keycloak | [Infra AGENTS.md](../WingYip_SRS_Infrastructure/AGENTS.md) |
| `WingYip_Legacy/` | Legacy monolith (active, migration in progress) | [Legacy AGENTS.md](../WingYip_Legacy/AGENTS.md) |
| `WingYip_SRS_Artifacts/` | Shared artifacts (placeholder) | [Artifacts AGENTS.md](../WingYip_SRS_Artifacts/AGENTS.md) |
| `WingYip_SRS_UI_EcoSystem/` | Design system (placeholder) | [UI AGENTS.md](../WingYip_SRS_UI_EcoSystem/AGENTS.md) |

---

## For AI Agents: Working With This Codebase

### Before Any Code Change

1. **Read the repo's AGENTS.md** — it maps the repo to project docs and lists internal documentation
2. **Understand the domain** — which business module are you touching? Check [Functional Modules](requirements/02-functional-modules.md)
3. **Check branch strategy** — most repos use `development` as the active branch, not `main`
4. **Respect architecture patterns** — see [Microservices Design](architecture/03-microservices-design.md) for backend and [Frontend Architecture](architecture/07-frontend-mobile-architecture.md) for frontend

### Backend (BE_EcoSystem)

```
CRITICAL RULES (from docs/CRUD.md):
├── Controller → Service → MediatR Handler → Repository → DbContext
├── NO business logic in Controllers, Services, or Handlers
├── async/await everywhere, CancellationToken on every method
├── AutoMapper only in Handlers
├── Database-first EF Core: entities generated from SQL Server schemas
└── Per-service structure: .Api / .Service / .Data / .Client / .Tests
```

**Key files to consult:**
- `docs/CRUD.md` — mandatory architecture rules
- `docs/API_Controllers_Reference.md` — 55+ controllers, 400+ endpoints
- `docs/SYSTEM_ARCHITECTURE.md` — high-level design
- `docs/BACKEND_ONBOARDING.md` — new developer guide
- `docs/User_Hierarchy_RBAC.md` — role hierarchy with Mermaid diagrams

**Tech facts (verified against code):**
- .NET 8.0 (108 projects)
- MediatR 12.1.1/13.1.0 (65 references)
- Serilog 4.3.0 + Elasticsearch
- RabbitMQ.Client 7.2.0 (8 services)
- WebSocket (NOT SignalR) for real-time
- 12 role types (verified: DB seed data shows 12 RoleTypeId values)

### Frontend (FE_EcoSystem)

```
ARCHITECTURE:
src/
├── app/          ← Providers, contexts, router
├── features/     ← 13 feature modules (each: pages/, components/, api/, hooks/, routes.tsx)
├── shared/       ← UI components, hooks, stores, utils
└── styles/       ← Tailwind entry

STATE:
├── React Query → server/API data
├── Zustand     → UI/session state
└── Context     → Bridge stores with React tree
```

**Key files:**
- `rsbuild.config.mts` — bundler config
- `src/app/router/routes-config.tsx` — route assembly
- `src/shared/components/headless-ui/README.md` — shared UI library

### Handheld (HH_EcoSystem)

```
CRITICAL:
├── Honeywell AAR patching via postinstall/prebuild scripts
├── Keycloak direct auth (NOT AD/ADFS)
├── WebSocket notifications (NOT SignalR)
└── Jenkinsfile-based CI/CD with version management
```

**Key files:**
- `HONEYWELL_AAR_FIX.md` — scanner hardware patching
- `WEBSOCKET_NOTIFICATIONS.md` — notification system
- `VERSION_MANAGEMENT.md` — versioning strategy

### Infrastructure (Infrastructure)

```
KUSTOMIZE STRUCTURE:
ServiceName/k8s/
├── base/
└── overlays/{dev, qa, staging, prod}

DEPLOY:
kustomize build . | kubectl apply -f -
argocd app sync wingyip-srs-qa
```

---

## Verified Facts (Code-Audited, Not Claims)

| Claim | Verified | Source |
|-------|----------|--------|
| .NET 8 | ✅ | 108 .csproj files with `net8.0` |
| React 19.2 | ✅ | `package.json`: `"react": "^19.2.0"` |
| React Native 0.72.3 | ✅ | `package.json`: `"react-native": "0.72.3"` |
| RSBuild | ✅ | `@rsbuild/core: ^1.6.6` |
| MediatR CQRS | ✅ | 65 references, 318+ handlers |
| Serilog + ELK | ✅ | Serilog 4.3.0 + Elasticsearch sink |
| RabbitMQ | ✅ | 8 service references |
| EF Core DB-first | ✅ | 18 Data projects, auto-generated models |
| **12 role types** | ✅ | DB seed data: 12 RoleTypeId values (1–11 + 99 SUPERADMIN→IT Admin) |
| **14 services** | ✅ (was: 19) | 11 microservices + 3 engines |
| **16 K8s manifests** | ✅ (was: 17) | Directory count verification — 16 service directories in Infrastructure (14 BE + Frontend + Handheld + Cups) |
| **No SignalR** | ✅ (was: claimed) | Zero references in codebase |
| **No Kerberos SSO** | ✅ (was: claimed) | Zero config in Keycloak |

---

## Common Patterns Across Repos

### Service Naming Convention
```
WingYip.SRS.{Domain}.{Layer}
Example: WingYip.SRS.Product.Api, WingYip.SRS.Replenishment.Service
```

### Error Handling Pattern (BE)
From `docs/TROUBLESHOOTING_RUNBOOKS.md` and `docs/CRUD.md`:
- All exceptions caught at Controller level via global exception middleware
- MediatR pipeline behaviors handle cross-cutting concerns (validation, logging)
- `OperationResult<T>` pattern for consistent API responses (success/failure)
- Serilog structured logging with correlation IDs across service boundaries
- Never suppress errors with empty catch blocks

### API Conventions (BE)
From `docs/API_Controllers_Reference.md` and `docs/ClientAPIConstants_Reference.md`:
- URL path versioning: `/api/v1/{controller}/{action}`
- 55+ controllers across 14 microservices, 400+ endpoints
- HTTP methods: GET (search/read), POST (create), PUT (update), DELETE (soft/hard)
- All endpoints return `OperationResult<T>` or `IActionResult`
- `[UserAction]` attribute for RBAC audit logging
- Client constants in `WingYip.SRS.{Service}.Client` packages for inter-service calls

### Database-First EF Core Pattern (BE)
From `docs/CRUD.md` and `docs/DATABASE_SCHEMA.md`:
- Entities generated from SQL Server schemas (EF Core Power Tools / scaffolding)
- `[Table]` and `[Key]` annotations on generated models
- DbContext per service, no shared databases
- Migration scripts in `docs/migrate_{service}.sql`
- Repository pattern: `I{Entity}Repository` → `DbContext` (no direct DbContext in controllers)

### Docker Build Pattern
- **BE**: `dotnet publish` → Docker multi-stage → push to internal registry → ArgoCD
- **FE**: `pnpm build` (RSBuild) → Nginx static serve → Docker → K8s FrontendService
- **HH**: `cd android && ./gradlew assembleRelease` → APK → Jenkins → K8s HandheldService

### Kustomize Deployment Pattern (Infra)
```
ServiceName/k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    ├── qa/
    ├── staging/
    └── prod/
```
Deploy: `kustomize build <overlay> | kubectl apply -f -`

### CI/CD Pattern
```
Git Push → Jenkins (multi-branch pipeline)
   ├── Build (.NET / React / React Native)
   ├── Test (per-service test projects)
   └── Docker → Registry → ArgoCD Sync → K8s
```

### Honeywell Hardware Patching (HH)
From `HONEYWELL_AAR_FIX.md`:
- `scripts/patch-honeywell.js` runs at `postinstall` and `prebuild`
- Modifies native AAR libraries for Honeywell EDA52 compatibility
- If scanner fails after dependency update: re-run `npm install`

### Version Management (HH)
From `VERSION_MANAGEMENT.md` and `JENKINS_VERSION_SETUP.md`:
- Semantic versioning: `major.minor.patch` (e.g., 0.0.3)
- Jenkins pipeline auto-increments build number
- Version displayed in-app for support/debugging
- Release APKs tagged with version in filename

### Testing Pattern
- **BE**: xUnit/NUnit per service. Every Command, Query, Handler, Repository has unit tests
- **FE**: Jest + React Testing Library + jsdom. Component, utility, and hook tests
- **HH**: Jest + Testing Library React Native. Screen and service tests
- **Infra**: `kustomize build ... --dry-run=server` for manifest validation

### Documentation Pattern
```
WingYip_SRS_Documents/          ← Master docs (48 .md files: architecture, requirements, design, etc.)
repo/AGENTS.md         ← Repo-specific agent context + cross-references
repo/README.md         ← Human-readable overview
repo/docs/             ← Internal implementation docs (BE: 17 files)
repo/*.md              ← Operational docs (HH: 5 operational guides)
```

---

## Project Docs Quick Map

| If you need to know... | Read... |
|------------------------|---------|
| What does the system do? | [00-project-overview.md](00-project-overview.md) |
| How is it architected? | [01-technical-architecture.md](architecture/01-technical-architecture.md) |
| How do services communicate? | [04-service-communication.md](architecture/04-service-communication.md) |
| How does auth work? | [06-authentication-rbac.md](architecture/06-authentication-rbac.md) |
| What are the business rules? | [01-brd-summary.md](requirements/01-brd-summary.md) |
| What are the UI guidelines? | [15-ui-design-system.md](architecture/15-ui-design-system.md) |
| How is it deployed? | [02-devops-deployment.md](infrastructure/02-devops-deployment.md) |
| How do I write code? | [11-coding-standards.md](architecture/11-coding-standards.md) |
| What LLDs exist? | [01-lld-index.md](design/01-lld-index.md) |
| How is it tested? | [04-testing-strategy.md](testing/04-testing-strategy.md) |

---

## Contributing Rules

1. **Branch from `development`** (except DE, Legacy, Artifacts, UI — use `main`)
2. **Follow CRUD.md rules** for backend changes
3. **Update API_Controllers_Reference.md** when adding endpoints
4. **Update ClientAPIConstants_Reference.md** when exposing new service endpoints
5. **Place SQL migrations** in `docs/migrate_{service}.sql`
6. **Add unit tests** for all new Commands, Queries, Handlers, and Repositories
7. **Peer review required** before merging
8. **Never run the historical rename scripts** in BE_EcoSystem root — they are one-time migration artifacts
