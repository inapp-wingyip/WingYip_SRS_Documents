# WingYip SRS — Project Knowledge Base

> **Stock Replenishment System (SRS)** for WingYip — an enterprise-grade retail store and warehouse replenishment platform built by **InApp Information Technologies**.
>
> **Source reference convention**: Throughout this knowledge base, `drive_raw/...` refers to files in `WingYip_SRS_Documents/drive_raw/` which are the original raw documents from Google Drive.

---

## Project at a Glance

- **Client**: WingYip (UK-based Oriental grocery retail chain)
- **Builder**: InApp Information Technologies
- **System**: Stock Replenishment System (SRS)
- **Architecture**: .NET 8 Microservices + Kubernetes + SQL Server
- **Frontend**: React + RSBuild (Web) + React Native (Android Handheld)
- **Integration**: SAP, Korber WMS, OpSuite ePOS, BI Database
- **Infrastructure**: On-Premise, Private Network Only (No Internet Exposure)
- **Auth**: Windows AD + ADFS + Keycloak + RBAC
- **Data Flow**: Medallion Architecture (Bronze → Silver → Gold)
- **ORM**: Entity Framework Core (database-first DbContext generation)
- **Messaging**: WebSocket (real-time), RabbitMQ (async)

---

## WingYip Business Structure

Four primary superstore sites: **Birmingham, Manchester, Croydon, Cricklewood**.

- **Wholesale Warehouse Format** — Palletised and case-format goods for restaurant/catering customers
- **Retail Storefront Format** — Full-service grocery stores for walk-in customers
- **Didi Stores** — Smaller format (~850 products), first opened in Watford (4-Dec-2025). No storage; daily deliveries.
- **Central Distribution & Coldstore** — Birmingham hub handling inter-branch transfers

---

## Knowledge Base Structure

```
WingYip_SRS_Documents/
├── INDEX.md                          ← You are here
├── AGENTS.md                         ← Cross-repo doc guide (START HERE for agents)
├── 00-project-overview.md            ← Executive summary & scope
├── drive-file-index.md               ← Complete file inventory
│
├── architecture/
│   ├── 01-technical-architecture.md  ← Tech stack, layers, infrastructure
│   ├── 02-enterprise-onprem.md       ← On-premise deployment & network
│   ├── 03-microservices-design.md    ← CQRS, Entity Framework Core, patterns
│   ├── 04-service-communication.md   ← BFF, TVP, aggregation patterns
│   ├── 05-data-flow.md              ← Medallion Bronze→Silver→Gold
│   ├── 06-authentication-rbac.md     ← Keycloak, AD, SSO, RBAC engine
│   ├── 07-frontend-mobile-architecture.md   ← Web + Android HHD architecture
│   ├── 08-database-schema.md        ← DB per service, table mapping
│   ├── 09-sel-printing-detail.md    ← SEL printing, Crystal Reports, print UI
│   ├── 10-legacy-migration.md       ← Legacy system reference (read-only archive, not active)
│   ├── 11-coding-standards.md       ← C# conventions, CQRS, EF Core, RBAC hierarchy (links to BE repo)
│   ├── 12-error-logging-observability.md ← Serilog, ELK, centralized auditing, error patterns
│   ├── 13-security-standards.md     ← Network security, data protection, OWASP, Kerberos SSO (planned)
│   ├── 14-integration-contracts.md  ← SAP/Korber/OpSuite field mappings, pipeline specs
│   ├── 15-ui-design-system.md       ← Web (React) + Mobile (Android) arch, design principles
│   ├── 16-workflow-business-process.md ← All replenishment workflows, business process reference
│   ├── 17-api-event-contracts.md     ← REST, RabbitMQ events, WebSocket, versioning
│   └── 18-performance-caching-concurrency.md ← Caching rules, locks, retry, performance targets
│
├── requirements/
│   ├── 01-brd-summary.md            ← Full BRD v2.0 & v3.1 summaries
│   ├── 02-functional-modules.md      ← Module-by-module details
│   ├── 03-user-stories.md            ← User stories index
│   └── 04-frd-summaries.md           ← FRD documents (Bulk, Fresh, SOCO, SEL)
│
├── design/
│   ├── 01-lld-index.md               ← Complete LLD inventory
│   ├── 02-key-llds.md                ← Selected LLD summaries
│   ├── 03-lld-replenishment-detail.md ← Replenishment LLD deep-dive
│   ├── 04-lld-didi-store-detail.md   ← Didi Store LLD deep-dive
│   ├── 05-lld-admin-storeops-detail.md ← Admin, SOCO, Common Libraries
│   └── 06-lld-product-warehouse-detail.md ← Product & Warehouse LLDs
│
├── infrastructure/
│   ├── 01-deployment-strategy.md     ← Go-live, deployment, infrastructure
│   ├── 02-devops-deployment.md       ← Jenkins, ArgoCD, K8s deployment
│   ├── 03-data-mapping.md            ← SAP/Korber/OpSuite field mappings
│   └── 04-environment-configuration.md ← Environments, AppSettings, INFRA tracker, K8s config
│
├── project-management/
│   ├── 01-planning-sprints.md        ← Sprints, milestones, RAID
│   ├── 02-weekly-status.md           ← Status reports & meeting index
│   ├── 03-raid-change-requests.md     ← RAID log & CR tracking
│   └── 04-decision-clarification-log.md ← Decisions, CR details, meeting outcomes
│
├── testing/
│   ├── 01-test-scenarios.md          ← Test artifacts, QA, data issues
│   ├── 02-workflow-docs.md           ← Replenishment workflow docs
│   ├── 03-test-traceability-matrix.md ← Tests → requirements mapping
│   └── 04-testing-strategy.md        ← Per-repo testing, QA gates, test data
│
└── data-engineering/
    ├── 01-data-workflow.md           ← SSIS pipelines, ETL, scheduling
    ├── 02-data-migration.md          ← Migration strategy & approach
    ├── 03-ssis-pipeline-catalog.md   ← ETL pipeline catalog & schedules
    └── 04-korber-etl-warehouse.md    ← Korber ETL, data warehouse design
```

---

## Quick Reference

| What | Where |
|------|-------|
| **Cross-repo guide** | **[AGENTS.md](./AGENTS.md)** — Start here for agents |
| Project overview | [00-project-overview.md](./00-project-overview.md) |
| BRD (latest v3.1) | [requirements/01-brd-summary.md](./requirements/01-brd-summary.md) |
| FRD summaries | [requirements/04-frd-summaries.md](./requirements/04-frd-summaries.md) |
| Technical architecture | [architecture/01-technical-architecture.md](./architecture/01-technical-architecture.md) |
| Authentication & RBAC | [architecture/06-authentication-rbac.md](./architecture/06-authentication-rbac.md) |
| Frontend & Mobile | [architecture/07-frontend-mobile-architecture.md](./architecture/07-frontend-mobile-architecture.md) |
| Database schema | [architecture/08-database-schema.md](./architecture/08-database-schema.md) |
| SEL Printing detail | [architecture/09-sel-printing-detail.md](./architecture/09-sel-printing-detail.md) |
| Legacy migration | [architecture/10-legacy-migration.md](./architecture/10-legacy-migration.md) |
| Coding standards | [architecture/11-coding-standards.md](./architecture/11-coding-standards.md) — C# conventions, links to BE repo |
| Error handling & observability | [architecture/12-error-logging-observability.md](./architecture/12-error-logging-observability.md) — Serilog, ELK, audit |
| Security standards | [architecture/13-security-standards.md](./architecture/13-security-standards.md) — Network, data protection, OWASP |
| Integration contracts | [architecture/14-integration-contracts.md](./architecture/14-integration-contracts.md) — SAP/Korber/OpSuite specs |
| UI design system | [architecture/15-ui-design-system.md](./architecture/15-ui-design-system.md) — Web + Mobile arch |
| Workflows & business processes | [architecture/16-workflow-business-process.md](./architecture/16-workflow-business-process.md) — All replenishment flows |
| API & event contracts | [architecture/17-api-event-contracts.md](./architecture/17-api-event-contracts.md) — REST, RabbitMQ, WebSocket, versioning |
| Performance & caching | [architecture/18-performance-caching-concurrency.md](./architecture/18-performance-caching-concurrency.md) — Caching, locks, retry, targets |
| Testing strategy | [testing/04-testing-strategy.md](./testing/04-testing-strategy.md) — Per-repo testing, QA gates |
| Microservices design | [architecture/03-microservices-design.md](./architecture/03-microservices-design.md) |
| All LLDs index | [design/01-lld-index.md](./design/01-lld-index.md) |
| Replenishment LLDs | [design/03-lld-replenishment-detail.md](./design/03-lld-replenishment-detail.md) |
| Didi Store LLDs | [design/04-lld-didi-store-detail.md](./design/04-lld-didi-store-detail.md) |
| Admin/SOCO LLDs | [design/05-lld-admin-storeops-detail.md](./design/05-lld-admin-storeops-detail.md) |
| Product/Warehouse LLDs | [design/06-lld-product-warehouse-detail.md](./design/06-lld-product-warehouse-detail.md) |
| Data engineering | [data-engineering/01-data-workflow.md](./data-engineering/01-data-workflow.md) |
| ETL pipeline catalog | [data-engineering/03-ssis-pipeline-catalog.md](./data-engineering/03-ssis-pipeline-catalog.md) |
| Korber ETL & Warehouse | [data-engineering/04-korber-etl-warehouse.md](./data-engineering/04-korber-etl-warehouse.md) |
| Deployment strategy | [infrastructure/01-deployment-strategy.md](./infrastructure/01-deployment-strategy.md) |
| DevOps & K8s | [infrastructure/02-devops-deployment.md](./infrastructure/02-devops-deployment.md) |
| Data mappings | [infrastructure/03-data-mapping.md](./infrastructure/03-data-mapping.md) |
| Environment configuration | [infrastructure/04-environment-configuration.md](./infrastructure/04-environment-configuration.md) — Envs, AppSettings, K8s |
| RAID & Change Requests | [project-management/03-raid-change-requests.md](./project-management/03-raid-change-requests.md) |
| Workflow docs | [testing/02-workflow-docs.md](./testing/02-workflow-docs.md) |
| Test traceability | [testing/03-test-traceability-matrix.md](./testing/03-test-traceability-matrix.md) |
| Decision log | [project-management/04-decision-clarification-log.md](./project-management/04-decision-clarification-log.md) |

---

## Module Map

| # | Module | Description |
|---|--------|-------------|
| 1 | **User Management & RBAC** | User creation, roles, multi-store access, Keycloak SSO, 12 role types |
| 2 | **Store Layout & Planogram (SpaceMan)** | Store layout design, bay groups, 7-stage planogram workflow |
| 3 | **Warehouse Layout** | Location capture, product mapping, warehouse structure |
| 4 | **Product Enquiry** | Product search, status identification, audit tracking |
| 5 | **Store Operations** | Store walk, low stock, no stock, spillage, housekeeping |
| 6 | **Core Replenishment** | Replen groups, sales-based (15 min) & store-walk (10 sec) replenishment |
| 7 | **Bulk Replenishment** | Customer warehouse, pallet drops, put-away, Pick Groups |
| 8 | **Perpetual Inventory (PI)** | Stock counting, date check process |
| 9 | **Stock Control & Discrepancy** | Discrepancy detection, resolution, write-off |
| 10 | **SOCO** | Short-code/label replacement, alert-driven workflow |
| 11 | **Shelf Edge Label Printing** | Label generation, printing rules, Crystal Reports, manifest PDF |
| 12 | **Admin Configuration** | Store configurations, system settings |
| 13 | **Messaging & Notifications** | Messages, alerts, notifications, escalation logic |
| 14 | **Didi Store Operations** | Remote store replenishment, emergency orders, waste management |
| 15 | **Fresh Goods** | Perishable handling, spoilage, write-offs |
| 16 | **Reporting & Analytics** | Power BI, SSRS, operational dashboards |
| 17 | **Finance** | Customer-type reports, SAP integration |
| 18 | **System-Wide Audit Log** | Centralized audit framework across all modules |
| 19 | **Dual Merchandise / Directed Storewalk** | Multi-location product placement |
