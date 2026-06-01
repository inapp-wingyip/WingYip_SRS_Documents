# WingYip SRS — Project Knowledge Hub

> **Cross-repository reference** — Links each WingYip repository to relevant project documentation.


---

## AI Native Development

This repository follows the **AI Native Development** methodology. Shared policy lives in the central docs — load only what the current task needs.

### Invariants

1. **No code is written before a spec exists and has been reviewed.** See `../WingYip_SRS_Documents/AI_Native/workflow/sdd-pipeline.md` for exceptions and the full pipeline. If in doubt, treat it as spec-required.
2. **Every Acceptance Criterion in any `spec.md` must have at least one executable verification artifact that fails when the AC's `THEN` clause is violated.** See `../WingYip_SRS_Documents/AI_Native/workflow/acceptance-criteria.md` for the full policy.

### Router — load docs on demand

| Topic | File | When to read |
|---|---|---|
| SDD pipeline & exceptions | `../WingYip_SRS_Documents/AI_Native/workflow/sdd-pipeline.md` | Starting any feature/fix/refactor |
| Skills catalog | `../WingYip_SRS_Documents/AI_Native/workflow/skills-catalog.md` | Choosing which skill to invoke |
| OpenSpec artifacts & delta-spec rules | `../WingYip_SRS_Documents/AI_Native/workflow/openspec-artifacts.md` | Creating, validating, or archiving a change |
| AC verification policy | `../WingYip_SRS_Documents/AI_Native/workflow/acceptance-criteria.md` | Writing or reviewing ACs |
| Microservice patterns & defaults | `../WingYip_SRS_Documents/AI_Native/architecture/microservice-patterns.md` | Writing specs touching service boundaries |
| ADR discipline | `../WingYip_SRS_Documents/AI_Native/architecture/adr-discipline.md` | Proposing, superseding, or enforcing an ADR |
| Coding standards & commits | `../WingYip_SRS_Documents/AI_Native/standards/coding-standards.md` | Implementing tasks, writing tests, preparing commits |
| Context hygiene | `../WingYip_SRS_Documents/AI_Native/agents/context-hygiene.md` | Running multi-step skill chains |
| Guardrails (NOT-to-do + escalation) | `../WingYip_SRS_Documents/AI_Native/agents/guardrails.md` | Before irreversible actions or when uncertain |

### Conflict resolution

When instructions disagree, apply this precedence (highest wins):

```
ADR > PROJECT.md > AGENTS.md (this file) > docs/ > ../WingYip_SRS_Documents/AI_Native/
```

### When in doubt

Ask the user. Do not assume. Escalation triggers are in `../WingYip_SRS_Documents/AI_Native/agents/guardrails.md`.

### Cross-Platform AI-Native Setup

All active service repos support **OpenCode**, **Claude Code**, **Cursor**, and **GitHub Copilot** with stack-specific configurations. Legacy and Artifacts repos are excluded.

| Platform | Config Location | Files |
|---|---|---|
| **OpenCode** | `.opencode/skills/` | 21 reusable skills |
| **Claude Code** | `.claude/` | Skills + commands |
| **Cursor** | `.cursor/rules/*.mdc` | Stack-specific rules (alwaysApply + globs) |
| **Copilot** | `.github/copilot-instructions.md` | Repo-wide + `.github/instructions/*.md` stack rules |
| **VS Code** | `.vscode/settings.json` | Monorepo-optimized workspace settings |

**Stack-specific rules:**
- `backend` → `.cursor/rules/10-backend-conventions.mdc`, `.github/instructions/backend.instructions.md`
- `frontend` → `.cursor/rules/11-frontend-conventions.mdc`, `.github/instructions/frontend.instructions.md`
- `mobile` → `.cursor/rules/12-mobile-conventions.mdc`, `.github/instructions/mobile.instructions.md`
- `devops` → `.cursor/rules/13-devops-conventions.mdc`, `.github/instructions/devops.instructions.md`
- `data-engineering` → `.cursor/rules/14-data-engineering-conventions.mdc`, `.github/instructions/data-engineering.instructions.md`

All stacks share: `00-sdd-invariants.mdc` + `20-security-checklist.mdc`.

**Installer:** `WingYip_SRS_AI_Native/install.ps1 --platform all|cursor|copilot|opencode|claude`

---

---

## Repository Ecosystem

```
C:\Projects\WingYip\
├── WingYip_SRS_Documents/               ← YOU ARE HERE (Knowledge Hub)
├── WingYip_Legacy/             ← Legacy monolith — READ-ONLY reference archive (not part of active development)
├── WingYip_SRS_Artifacts/       ← Shared artifacts
├── WingYip_SRS_BE_EcoSystem/   ← Backend microservices (14 services: 11 API + 3 engines)
├── WingYip_SRS_FE_EcoSystem/   ← Frontend web application (React + RSBuild — active code on `development`)
├── WingYip_SRS_DE_EcoSystem/   ← Data engineering (Bronze/Silver ETL)
├── WingYip_SRS_HH_EcoSystem/   ← Android handheld application (React Native — active code on `development`)
├── WingYip_SRS_Infrastructure/  ← Infrastructure, K8s, ArgoCD, Keycloak (active on `development`)
├── WingYip_SRS_UI_EcoSystem/   ← UI/UX design system (placeholder — README only, no code)
```

---

## Branch Strategy

| Repo | Primary Branch | Notes |
|------|---------------|-------|
| **BE_EcoSystem** | `development` | Active feature work, QA merges |
| **FE_EcoSystem** | `development` | React/RSBuild source lives here (`main` is empty placeholder) |
| **HH_EcoSystem** | `development` | React Native source lives here (`main` is empty placeholder) |
| **Infrastructure** | `development` | 16 service K8s manifests (same in `main`) |
| **DE_EcoSystem** | `main` | No `development` branch — ETL only |
| **UI_EcoSystem** | `main` | No `development` branch — placeholder |
| **Legacy** | `main` | No `development` branch |
| **Artifacts** | `main` | No `development` branch — placeholder |

---

## Quick Reference: Which Docs for Which Repo

| Repo | Primary Docs | Secondary Docs |
|------|-------------|----------------|
| **BE_EcoSystem** | [Microservices Design](architecture/03-microservices-design.md), [Database Schema](architecture/08-database-schema.md), [CQRS/Service Communication](architecture/04-service-communication.md) | [Coding Standards](architecture/11-coding-standards.md), [Error/Observability](architecture/12-error-logging-observability.md), [Security](architecture/13-security-standards.md), [All LLDs](design/01-lld-index.md), [RBAC](architecture/06-authentication-rbac.md), [Legacy Migration](architecture/10-legacy-migration.md) |
| **FE_EcoSystem** | [UI Design System](architecture/15-ui-design-system.md), [Frontend & Mobile Architecture](architecture/07-frontend-mobile-architecture.md), [Technical Architecture](architecture/01-technical-architecture.md) | [RBAC](architecture/06-authentication-rbac.md), [Security](architecture/13-security-standards.md), [BRD Summary](requirements/01-brd-summary.md) |
| **DE_EcoSystem** | [Data Flow](architecture/05-data-flow.md), [Data Workflow](data-engineering/01-data-workflow.md), [ETL Pipeline Catalog](data-engineering/03-ssis-pipeline-catalog.md) | [Integration Contracts](architecture/14-integration-contracts.md), [Data Mapping](infrastructure/03-data-mapping.md), [Korber ETL](data-engineering/04-korber-etl-warehouse.md), [Data Migration](data-engineering/02-data-migration.md) |
| **HH_EcoSystem** | [UI Design System](architecture/15-ui-design-system.md), [Frontend & Mobile Architecture](architecture/07-frontend-mobile-architecture.md), [RBAC/Auth](architecture/06-authentication-rbac.md) | [Workflows](architecture/16-workflow-business-process.md), [Store Walk LLDs](design/03-lld-replenishment-detail.md), [Didi LLDs](design/04-lld-didi-store-detail.md), [SEL Printing](architecture/09-sel-printing-detail.md) |
| **Infrastructure** | [DevOps Deployment](infrastructure/02-devops-deployment.md), [On-Prem Architecture](architecture/02-enterprise-onprem.md), [Environment Config](infrastructure/04-environment-configuration.md) | [Security](architecture/13-security-standards.md), [RBAC/Auth](architecture/06-authentication-rbac.md), [Data Mapping](infrastructure/03-data-mapping.md) |
| **UI_EcoSystem** | [UI Design System](architecture/15-ui-design-system.md), [Frontend & Mobile Architecture](architecture/07-frontend-mobile-architecture.md), [BRD Summary](requirements/01-brd-summary.md) | [Functional Modules](requirements/02-functional-modules.md), [FRD Summaries](requirements/04-frd-summaries.md) |
| **Legacy** | [Legacy Migration](architecture/10-legacy-migration.md), [Technical Architecture](architecture/01-technical-architecture.md) | [Database Schema](architecture/08-database-schema.md), [Data Mapping](infrastructure/03-data-mapping.md), [Coding Standards](architecture/11-coding-standards.md) |
| **Artifacts** | [BRD Summary](requirements/01-brd-summary.md), [Project Overview](00-project-overview.md) | [All LLDs](design/01-lld-index.md) |

---

## Per-Repository Doc Guide

### WingYip_SRS_BE_EcoSystem (Backend)

**Start with:**
- [Microservices Design](architecture/03-microservices-design.md) — CQRS, EF Core (database-first), service boundaries
- [Database Schema](architecture/08-database-schema.md) — 14 service databases, entity model

**Per Service:**
| Service | Key Docs |
|---------|----------|
| Administration | [RBAC](architecture/06-authentication-rbac.md), [Admin LLDs](design/05-lld-admin-storeops-detail.md) |
| Authentication | [Auth/SSO Architecture](architecture/06-authentication-rbac.md) |
| Product | [Product LLDs](design/06-lld-product-warehouse-detail.md) |
| Spaceman | [Product LLDs](design/06-lld-product-warehouse-detail.md), [BRD Planogram](requirements/02-functional-modules.md#2-store-layout--planogram-spaceman) |
| Replenishment | [Replenishment LLDs](design/03-lld-replenishment-detail.md), [Workflow Docs](testing/02-workflow-docs.md) |
| BulkReplenishmentEngine | [Replenishment LLDs → Bulk](design/03-lld-replenishment-detail.md#6-bulk-replenishment--pallet) |
| DidiReplenishmentEngine | [Didi LLDs](design/04-lld-didi-store-detail.md) |
| FreshGoodsReplenishmentEngine | [FRD Fresh Goods](requirements/04-frd-summaries.md#2-fresh-good-replenishment-frd) |
| StockControl | [Stock Control Modules](requirements/02-functional-modules.md#9-stock-control--discrepancy) |
| StoreOperations | [Store Walk LLD](design/03-lld-replenishment-detail.md#4-low--no-stock--sales-replenishment--background-process) |
| Print | [SEL Printing Detail](architecture/09-sel-printing-detail.md) |
| Audit | [Admin LLDs → Centralized Auditing](design/05-lld-admin-storeops-detail.md#centralized-auditing-library) |
| Bronze | [Data Flow](architecture/05-data-flow.md), [DE Workflow](data-engineering/01-data-workflow.md) |
| GenericProcessEngine/ReportEngine | [FRD Summaries](requirements/04-frd-summaries.md) |

**Internal Code Docs (14 files):** `docs/API_Controllers_Reference.md` (55 controllers, 400+ methods), `docs/API_INTEGRATION_GUIDE.md`, `docs/BACKEND_ONBOARDING.md`, `docs/CRUD.md` (architecture rules), `docs/ClientAPIConstants_Reference.md` (API constants), `docs/DATABASE_SCHEMA.md`, `docs/HouseKeeping.md` (1023 lines, full CRUD impl), `docs/HouseKeeping_implementation_documentation.md` (detailed code docs), `docs/MICROSERVICES_INTERACTION.md`, `docs/SECURITY_ARCHITECTURE.md`, `docs/StoreLayout_BayManagement.md` (SQL queries, table schemas), `docs/SYSTEM_ARCHITECTURE.md`, `docs/TROUBLESHOOTING_RUNBOOKS.md`, `docs/User_Hierarchy_RBAC.md` (privilege rank with Mermaid). Migration SQL: `docs/migrate_product.sql`, `docs/migrate_soco.sql`, `docs/migrate_spaceman.sql`.

**Project-Level Architecture Docs:** [Coding Standards](architecture/11-coding-standards.md) (summary + links to internal docs), [Error/Observability](architecture/12-error-logging-observability.md) (Serilog, ELK, centralized auditing), [Security](architecture/13-security-standards.md) (OWASP, network, data protection), [Integration Contracts](architecture/14-integration-contracts.md) (SAP/Korber/OpSuite field mappings), [API & Events](architecture/17-api-event-contracts.md) (REST, RabbitMQ, WebSocket contracts), [Performance & Caching](architecture/18-performance-caching-concurrency.md) (caching rules, locks, retries), [Database Schema](architecture/08-database-schema.md) (microservice DB mapping), [Testing Strategy](testing/04-testing-strategy.md) (per-repo testing, QA gates).

---

### WingYip_SRS_DE_EcoSystem (Data Engineering)

**Start with:**
- [Data Flow Architecture](architecture/05-data-flow.md) — Bronze → Silver → Gold
- [ETL Pipeline Catalog](data-engineering/03-ssis-pipeline-catalog.md) — Schedules and dependencies
- [Data Mapping](infrastructure/03-data-mapping.md) — SAP/Korber/OpSuite field mappings

**Deep Dive:**
- [Data Workflow Design](data-engineering/01-data-workflow.md) — Full SSIS pipeline specification
- [Data Migration Strategy](data-engineering/02-data-migration.md) — Cutover, validation, rollback
- [Korber ETL & Warehouse Design](data-engineering/04-korber-etl-warehouse.md) — Archived architecture, Facts & Dimensions
- [Integration Contracts](architecture/14-integration-contracts.md) — SAP/Korber/OpSuite detailed field mapping specs

---

### WingYip_SRS_HH_EcoSystem (React Native Handheld)

> **Stack**: React Native (Android). See `development` branch for active code.

**Start with:**
- [Frontend & Mobile Architecture](architecture/07-frontend-mobile-architecture.md) — Platform split
- [Authentication & RBAC](architecture/06-authentication-rbac.md) — Keycloak/HHD auth flow

**Per Feature:**
| Feature | Key Docs |
|---------|----------|
| Store Walk | [Store Walk LLD](design/03-lld-replenishment-detail.md#4-low--no-stock--sales-replenishment--background-process), [Functional Spec](requirements/02-functional-modules.md#5-store-operations-store-walk) |
| Replenishment Picking | [Picking Workflow](design/03-lld-replenishment-detail.md#5-stock-replenishment--picking-workflow) |
| Bulk Replenishment | [Bulk Replenishment](design/03-lld-replenishment-detail.md#6-bulk-replenishment--pallet) |
| Didi Operations | [Didi LLDs](design/04-lld-didi-store-detail.md), [Emergency Order](design/04-lld-didi-store-detail.md#3-emergency-order) |
| SEL Printing | [SEL Printing Detail](architecture/09-sel-printing-detail.md) |
| Notifications | [Notifications](design/05-lld-admin-storeops-detail.md#notifications-configuration) |

**Project-Level Architecture Docs:** [UI Design System](architecture/15-ui-design-system.md) (Android HHD arch, design principles), [Workflows](architecture/16-workflow-business-process.md) (all replenishment flows), [API & Events](architecture/17-api-event-contracts.md) (WebSocket channels, REST endpoints), [Performance](architecture/18-performance-caching-concurrency.md) (offline support, response targets).

---

### WingYip_SRS_Infrastructure (K8s/DevOps)

**Start with:**
- [DevOps & K8s Deployment](infrastructure/02-devops-deployment.md) — Jenkins, ArgoCD, environments
- [On-Premise Architecture](architecture/02-enterprise-onprem.md) — Network, security layers

**Deep Dive:**
- [Deployment Strategy](infrastructure/01-deployment-strategy.md) — Go-live, Didi store rollout
- [RBAC/Auth](architecture/06-authentication-rbac.md) — Keycloak deployment
- [Data Mapping](infrastructure/03-data-mapping.md) — Source system connectivity

**Internal Docs:** `DEPLOYMENT_GUIDE.md`, `README.md`, `KeycloakAuthentication/k8s/NAMING_CONVENTIONS.md`, `KeycloakAuthentication/CI_CD_GUIDE.md`, `KeycloakAuthentication/DEPLOYMENT.md`, `KeycloakAuthentication/PRODUCTION_READY.md`

**Project-Level Architecture Docs:** [Environment Configuration](infrastructure/04-environment-configuration.md) (envs, AppSettings, K8s config), [Security Standards](architecture/13-security-standards.md) (OWASP, network security, Kerberos SSO planned), [DevOps Deployment](infrastructure/02-devops-deployment.md) (Jenkins, ArgoCD, K8s)

---

### WingYip_SRS_FE_EcoSystem / WingYip_SRS_UI_EcoSystem

**Start with:**
- [Frontend & Mobile Architecture](architecture/07-frontend-mobile-architecture.md) — Web stack, module split
- [BRD Summary](requirements/01-brd-summary.md) — Web vs Mobile module scope

**Design Reference:**
- [FRD Summaries](requirements/04-frd-summaries.md) — Per-module functional requirements
- [Functional Modules](requirements/02-functional-modules.md) — Detailed feature descriptions
- [User Stories](requirements/03-user-stories.md) — Agile planning reference

---

### WingYip_Legacy

**Start with:**
- [Legacy Migration](architecture/10-legacy-migration.md) — Known issues, migration implications
- [Technical Architecture](architecture/01-technical-architecture.md) — New vs old comparison

**Reference:**
- [Database Schema](architecture/08-database-schema.md) — New schema vs legacy
- [Data Mapping](infrastructure/03-data-mapping.md) — Source system field mappings
- [SEL Printing Detail](architecture/09-sel-printing-detail.md) — New vs legacy print architecture

**Internal Docs:** `Database_Operations_Resilience_Plan.md` (critical issues catalog)

---

## Historical Refactoring Scripts (BE_EcoSystem)

> **Warning**: 10 PowerShell rename scripts exist in `WingYip_SRS_BE_EcoSystem/` root. These were used during service reorganization and should NOT be run again.

| Script | Purpose |
|--------|---------|
| `rename-audit-to-bulkreplenishmentengine.ps1` | Service split |
| `rename-audit-to-didireplenishmentengine.ps1` | Service split |
| `rename-audit-to-microservicetemplate.ps1` | Service template creation |
| `rename-bulkreplenishmentengine-to-didireplenishmentengine.ps1` | Service rename |
| `rename-bulkreplenishmentengine-to-freshgoodsreplenishmentengine.ps1` | Service rename |
| `rename-replenishment-to-print.ps1` | Module rename |
| `rename-reportengine-to-genericprocessengine.ps1` | Service rename |
| `rename-reports-to-genericprocessengine.ps1` | Service rename |
| `rename-spaceman-to-stockcontrol.ps1` | Service merge |
| `rename-storeoperations-to-replenishment.ps1` | Module rename |

---

## Complete Documentation Index

| Section | Document | Focus |
|---------|----------|-------|
| **Overview** | [00-project-overview.md](00-project-overview.md) | Executive summary |
| **Architecture** | [01-technical-architecture.md](architecture/01-technical-architecture.md) | Tech stack |
| | [02-enterprise-onprem.md](architecture/02-enterprise-onprem.md) | On-prem deployment |
| | [03-microservices-design.md](architecture/03-microservices-design.md) | CQRS, EF Core, services |
| | [04-service-communication.md](architecture/04-service-communication.md) | BFF, TVP patterns |
| | [05-data-flow.md](architecture/05-data-flow.md) | Medallion Bronze→Silver→Gold |
| | [06-authentication-rbac.md](architecture/06-authentication-rbac.md) | Keycloak, AD, RBAC |
| | [07-frontend-mobile-architecture.md](architecture/07-frontend-mobile-architecture.md) | Web + HHD architecture |
| | [08-database-schema.md](architecture/08-database-schema.md) | DB per service, entities |
| | [09-sel-printing-detail.md](architecture/09-sel-printing-detail.md) | SEL printing architecture |
| | [10-legacy-migration.md](architecture/10-legacy-migration.md) | Legacy system reference |
| | [11-coding-standards.md](architecture/11-coding-standards.md) | C# conventions, CQRS, EF Core (links to BE repo) |
| | [12-error-logging-observability.md](architecture/12-error-logging-observability.md) | Serilog, ELK, centralized auditing |
| | [13-security-standards.md](architecture/13-security-standards.md) | Network security, OWASP, Kerberos SSO |
| | [14-integration-contracts.md](architecture/14-integration-contracts.md) | SAP/Korber/OpSuite integration specs |
| | [15-ui-design-system.md](architecture/15-ui-design-system.md) | Web + Mobile architecture, design principles |
| | [16-workflow-business-process.md](architecture/16-workflow-business-process.md) | All replenishment workflows |
| | [17-api-event-contracts.md](architecture/17-api-event-contracts.md) | REST, RabbitMQ, WebSocket, versioning |
| | [18-performance-caching-concurrency.md](architecture/18-performance-caching-concurrency.md) | Caching, locks, retry, targets |
| **Requirements** | [01-brd-summary.md](requirements/01-brd-summary.md) | BRD v2.0 & v3.1 |
| | [02-functional-modules.md](requirements/02-functional-modules.md) | Module breakdown |
| | [03-user-stories.md](requirements/03-user-stories.md) | User stories index |
| | [04-frd-summaries.md](requirements/04-frd-summaries.md) | FRD documents |
| **Design** | [01-lld-index.md](design/01-lld-index.md) | Complete LLD inventory |
| | [02-key-llds.md](design/02-key-llds.md) | Key LLD summaries |
| | [03-lld-replenishment-detail.md](design/03-lld-replenishment-detail.md) | Replenishment deep-dive |
| | [04-lld-didi-store-detail.md](design/04-lld-didi-store-detail.md) | Didi deep-dive |
| | [05-lld-admin-storeops-detail.md](design/05-lld-admin-storeops-detail.md) | Admin, SOCO, Common |
| | [06-lld-product-warehouse-detail.md](design/06-lld-product-warehouse-detail.md) | Product & Warehouse |
| **Infrastructure** | [01-deployment-strategy.md](infrastructure/01-deployment-strategy.md) | Go-live, rollout |
| | [02-devops-deployment.md](infrastructure/02-devops-deployment.md) | Jenkins, ArgoCD, K8s |
| | [03-data-mapping.md](infrastructure/03-data-mapping.md) | SAP/Korber/OpSuite mappings |
| | [04-environment-configuration.md](infrastructure/04-environment-configuration.md) | Envs, AppSettings, INFRA, K8s config |
| **Data Engineering** | [01-data-workflow.md](data-engineering/01-data-workflow.md) | SSIS pipelines, ETL |
| | [02-data-migration.md](data-engineering/02-data-migration.md) | Migration strategy |
| | [03-ssis-pipeline-catalog.md](data-engineering/03-ssis-pipeline-catalog.md) | Pipeline schedules |
| | [04-korber-etl-warehouse.md](data-engineering/04-korber-etl-warehouse.md) | Korber ETL, data warehouse |
| **Project Mgmt** | [01-planning-sprints.md](project-management/01-planning-sprints.md) | Sprints, milestones |
| | [02-weekly-status.md](project-management/02-weekly-status.md) | Status, meetings |
| | [03-raid-change-requests.md](project-management/03-raid-change-requests.md) | RAID, CRs |
| | [04-decision-clarification-log.md](project-management/04-decision-clarification-log.md) | Decisions, CR details |
| **Testing** | [01-test-scenarios.md](testing/01-test-scenarios.md) | Test artifacts |
| | [02-workflow-docs.md](testing/02-workflow-docs.md) | Workflow documentation |
| | [03-test-traceability-matrix.md](testing/03-test-traceability-matrix.md) | Requirements mapping |
| | [04-testing-strategy.md](testing/04-testing-strategy.md) | Testing strategy, QA gates |