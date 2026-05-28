# Legacy System & Migration Reference

> Derived from `WingYip_Legacy/`, `drive/Documents/Design/Analysis/` (Legacy UI docs), and `WingYip_StockReplenishmentSystem/Database_Operations_Resilience_Plan.md`.

---

## Legacy System Overview

The original WingYip Stock Replenishment System was a **monolithic ASP.NET MVC** application. The new SRS is a ground-up microservices rewrite, but the legacy system informs UI patterns, business logic, and data models.

### Legacy Repositories
| Directory | Description |
|-----------|-------------|
| WingYip_StockReplenishmentSystem/ | Legacy monolith (ASP.NET MVC + EF Core) |
| SalesDBProject/ | Sales database project (SSDT) |
| SEL_Print/ | Shelf Edge Label printing (legacy) |
| WingYip-SRS-ServerApp/ | Server-side application (legacy) |

---

## Legacy Technology Stack

| Component | Legacy | New SRS |
|-----------|--------|---------|
| Architecture | Monolithic ASP.NET MVC | Microservices (ASP.NET Core Web APIs) |
| ORM | Entity Framework Core | Entity Framework Core (database-first) |
| Database | Shared single DB | Database per Service |
| Auth | Forms Authentication | AD/ADFS + Keycloak |
| Frontend | MVC Views + Razor | React + React Native |
| Deployment | IIS directly | Kubernetes + ArgoCD |

---

## Known Legacy Issues

Source: `Database_Operations_Resilience_Plan.md`

### Critical Issues
| Issue | Severity | Location |
|-------|----------|----------|
| DbContext shared across threads | CRITICAL | ConfigController.cs:71-86, HouseKeepingController.cs:143-154, CatPlanningGrid.cs:194-204 |
| Multiple SaveChanges in loops | HIGH | SpaceManController.cs (8+ instances), CaseReplenPickLine.cs (9 instances) |
| Missing transactions for multi-step ops | HIGH | Multiple controllers (24 affected) |
| Inadequate concurrency handling | MEDIUM | Various controllers |

### Migration Implications
- **Thread Safety**: New system uses scoped DbContext per request (DI) — no thread issues
- **Batch Operations**: Entity Framework Core with TVP replaces EF SaveChanges loops with efficient batch queries
- **Transactions**: MediatR pipeline handles transaction boundaries in new system
- **Concurrency**: ReplenGroup lock mechanism (CR39) redesigned for proper distributed locking

---

## Legacy UI Analysis Documents

Source: `drive/Documents/Design/Analysis/`

| Document | Description |
|----------|-------------|
| Admin - Legecy UI.docx | Legacy admin UI analysis — patterns for new Admin module |
| WingYip - Replenishment - Legecy UI.docx | Legacy replenishment UI — informs new Replenishment module |
| WingYip -Finance - Legecy UI.docx | Legacy finance UI — informs new Finance module |
| Planogram UI - Legacy.docx | Legacy planogram UI — informs new SpaceMan module |
| Manual Order - UI.docx | Legacy manual order UI — informs Didi Emergency Order |

### Purpose
These legacy UI docs serve as **reference material during development**, not as specifications. New modules should improve on legacy UX while preserving familiar workflows.

---

## Backend Technical Design

Source: `drive/Documents/Design/Analysis/Back End Technical Design Document.docx`

- Full backend design specification for the new SRS
- Covers the service layer, data access pattern, API structure
- Referenced by `Frontend_Architecture_WingYip_SRS.docx` and `HH_Mobile App_Architecture_WingYip_SRS.docx`

---

## BE_EcoSystem Code-Level Docs

The new backend already has significant implementation documentation:

| Document | Description |
|----------|-------------|
| API_Controllers_Reference.md | 55 controllers, 400+ HTTP methods across 14 microservices |
| CRUD.md | CRUD template — architecture rules, DbContext/Repository/Handler patterns |
| User_Hierarchy_RBAC.md | Implementation RBAC — privilege rank hierarchy with Mermaid diagram |
| HouseKeeping.md | HouseKeeping CRUD implementation (1023 lines) |
| HouseKeeping_implementation_documentation.md | Detailed HouseKeeping code documentation |
| StoreLayout_BayManagement.md | Store Layout LLD with SQL queries and table schemas |
| ClientAPIConstants_Reference.md | Client API constants reference |
| migrate_product.sql | Product module migration scripts |
| migrate_soco.sql | SOCO module migration scripts |
| migrate_spaceman.sql | SpaceMan module migration scripts |

---

## Data Migration Scripts

### Source: `drive/Sql-Scripts-Data-Generation/`

| Script | Description |
|--------|-------------|
| SalesTransaction_Generate | Sales transaction data generation for testing |

### BE Migration Scripts
| Script | Purpose |
|--------|---------|
| WingYip_SRS_BE_EcoSystem/docs/migrate_product.sql | Product module DB migration |
| WingYip_SRS_BE_EcoSystem/docs/migrate_soco.sql | SOCO module DB migration |
| WingYip_SRS_BE_EcoSystem/docs/migrate_spaceman.sql | SpaceMan module DB migration |

---

## Cross-References

- [Database Schema](../architecture/08-database-schema.md) — New SRS schema design
- [Microservices Design](../architecture/03-microservices-design.md) — New architecture patterns
- [DevOps Deployment](../infrastructure/02-devops-deployment.md) — New deployment pipeline
- [Data Migration Strategy](../data-engineering/02-data-migration.md) — Migration approach