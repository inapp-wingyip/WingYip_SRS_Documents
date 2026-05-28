# Coding Standards & Conventions

> **Cross-repo reference** — Links to implementation documentation in each repository. This doc provides architectural conventions; detailed code docs live in their respective repos.

---

## Technology Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Language | C# (.NET 8+) | ASP.NET Core Web APIs |
| ORM | Entity Framework Core | **Database-first DbContext generation. No raw SQL strings.** |
| CQRS | MediatR | Separate Command and Query handlers per use case |
| DI Container | Microsoft.Extensions.DependencyInjection | Built-in ASP.NET Core DI |
| Real-Time | WebSocket | Internal WebSocket communication |
| Async Messaging | RabbitMQ | Event-driven workflows |
| Logging | Serilog | Structured logging → SQL + ELK Stack |
| Testing | xUnit + Moq | Unit and integration testing |
| API Docs | Swashbuckle (OpenAPI/Swagger) | Auto-generated API specs |

---

## Core Conventions (Summary)

These are the **architectural rules**. Detailed patterns and code examples live in the BE repo docs.

### CQRS Pattern
- **One handler per use case** — Each Command/Query has exactly one handler class
- **Controllers delegate to MediatR** — No business logic in controllers
- **Commands return DTOs** — Never domain entities
- **Queries are read-only** — Never modify data in a Query handler

### Entity Framework Core
- **Database-first generation** — DbContext and entities generated from SQL Server schemas
- **No stored procedures** in SRS-owned databases
  - Exception: External systems (OpSuite) expose stored procedures that SRS calls
  - SRS NEVER authors or maintains stored procedures for its own databases
- **Repository pattern** — DbContext wrapped in repositories for isolation
- **Batch operations via TVP** — Use Table-Valued Parameters through BFF pattern

### Database per Service
- Each microservice owns exactly one database
- No cross-service DB access — Services communicate via REST or RabbitMQ
- PascalCase naming for tables and columns
- Audit columns on all tables: `CreatedDate`, `CreatedBy`, `ModifiedDate`, `ModifiedBy`
- Soft delete preferred: `IsActive` BIT column instead of physical deletes

### RBAC Privilege Hierarchy
```
SuperUser (Rank 1) → SrCatMan (2) → CatMan (3) → SOCO (4) → StoreManager (5) → StoreSupervisor (6) → StockControl (7) → CustomerWarehouseOps (8) → CustomerService (9) → Sales (10) → FinanceOps (11)
ITAdmin — Independent, manages system configuration
```
Each role can only create roles **at or below** its rank level.

### API Design
- URL pattern: `/api/{service}/{entity}[/{id}]/{action}`
- Response envelope: `{ "data": {}, "success": true, "message": "", "errors": [] }`
- Standard HTTP status codes: 200, 201, 204, 400, 401, 403, 404, 500

---

## Implementation Documentation Links

The following detailed docs exist **within their respective repositories**. This WingYip_SRS_Documents directory links to them rather than duplicating content.

### Backend EcoSystem (`WingYip_SRS_BE_EcoSystem/`)

| Document | Repo Path | Description |
|----------|----------|-------------|
| **API Controllers Reference** | `docs/API_Controllers_Reference.md` | 55 controllers, 400+ HTTP methods across 14 microservices |
| **CRUD Architecture Rules** | `docs/CRUD.md` | DbContext/Repository/Handler patterns, CQRS implementation conventions |
| **User Hierarchy & RBAC** | `docs/User_Hierarchy_RBAC.md` | Privilege rank hierarchy with Mermaid diagram |
| **Store Layout & Bay Management** | `docs/StoreLayout_BayManagement.md` | SQL queries, table schemas for StoreLayout module |
| **HouseKeeping Implementation** | `docs/HouseKeeping.md` | Full HouseKeeping CRUD implementation (1023 lines) |
| **HouseKeeping Detailed Docs** | `docs/HouseKeeping_implementation_documentation.md` | Detailed code-level documentation |
| **Client API Constants** | `docs/ClientAPIConstants_Reference.md` | API constants reference for client apps |
| **Product Migration SQL** | `docs/migrate_product.sql` | Product module DB migration scripts |
| **SOCO Migration SQL** | `docs/migrate_soco.sql` | SOCO module DB migration scripts |
| **SpaceMan Migration SQL** | `docs/migrate_spaceman.sql` | SpaceMan module DB migration scripts |

### Infrastructure (`WingYip_SRS_Infrastructure/`)

| Document | Repo Path | Description |
|----------|----------|-------------|
| **Deployment Guide** | `DEPLOYMENT_GUIDE.md` | Full deployment instructions, K8s config, SQL Server setup |
| **Keycloak Naming Conventions** | `KeycloakAuthentication/k8s/NAMING_CONVENTIONS.md` | K8s resource naming conventions |
| **Keycloak CI/CD Guide** | `KeycloakAuthentication/CI_CD_GUIDE.md` | Keycloak CI/CD pipeline |
| **Keycloak Deployment** | `KeycloakAuthentication/DEPLOYMENT.md` | Keycloak deployment specifics |
| **Keycloak Production Ready** | `KeycloakAuthentication/PRODUCTION_READY.md` | Production readiness checklist |
| **Product Service Setup** | `ProductService/SETUP_GUIDE.md` | Product service setup and configuration |

### Legacy (`WingYip_Legacy/`)

| Document | Repo Path | Description |
|----------|----------|-------------|
| **Database Operations Resilience Plan** | `WingYip_StockReplenishmentSystem/Database_Operations_Resilience_Plan.md` | Critical issues catalog in legacy system |

---

## Cross-References

- [Microservices Design](./03-microservices-design.md) — CQRS, Dapper, service boundaries
- [Legacy Migration](./10-legacy-migration.md) — Known legacy issues and migration approach
- [Database Schema](./08-database-schema.md) — Database per service, entity model
- [Service Communication](./04-service-communication.md) — BFF, TVP, aggregation patterns
- [Error Handling & Observability](./12-error-logging-observability.md) — Centralized auditing, Serilog, ELK