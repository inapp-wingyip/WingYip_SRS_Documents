# Database Schema & Microservice Data Design

> Derived from `drive/Documents/Design/Database/` (SRS - Microservice Table Mapping, Schema Definition) and BRD v3.1 data references.

---

## Database Architecture Principle

**Database per Service** — Each microservice owns its database. No shared DB access across services. This is a core architectural constraint that ensures true microservice isolation.

---

## SQL Server Configuration

| Component | Specification |
|-----------|--------------|
| Version | SQL Server 2022 Enterprise |
| High Availability | Always On Availability Groups |
| Failover | Windows Server Failover Clustering |
| Storage | SAN/NAS with high-performance SSD arrays |
| Encryption | Transparent Data Encryption (TDE) at rest |
| Backup | SQL Server Backup + Veeam |
| Connection | Native Client for SSIS, Entity Framework Core for services |
| Primary Server | `10.10.80.75:1433` (from DEPLOYMENT_GUIDE.md) |

---

## Microservice Database Mapping

### Source Spreadsheets
| Document | Description |
|----------|-------------|
| SRS - Microservice Table Mapping.xlsx | Maps tables to owning microservice |
| SRS Microservice Schema Definition.xlsx | Column-level schema per microservice |
| SRS Schema Definition.xlsx | Overall schema (archived, superseded) |

### Service → Database Mapping

| Microservice | Database | Domain |
|-------------|----------|--------|
| **Administration** | WingYip.SRS.Administration | Users, roles, store configs |
| **Authentication** | (Keycloak-managed) | Auth tokens, sessions |
| **Product** | WingYip.SRS.Product | Products, pricing, suppliers |
| **Spaceman** | WingYip.SRS.Spaceman | Store layout, planograms, bay groups |
| **Replenishment** | WingYip.SRS.Replenishment | Replen groups, pick lists, CaseReplenActions |
| **BulkReplenishmentEngine** | WingYip.SRS.BulkReplenishment | Bulk replen, pallet drops, put-away |
| **DidiReplenishmentEngine** | WingYip.SRS.DidiReplenishment | Didi scheduled/emergency orders |
| **FreshGoodsReplenishmentEngine** | WingYip.SRS.FreshGoods | Fresh goods replen, spoilage |
| **StockControl** | WingYip.SRS.StockControl | Discrepancies, write-offs, stock audit |
| **Print** | WingYip.SRS.Print | SEL printing, manifest, Crystal Reports |
| **GenericProcessEngine** | WingYip.SRS.GenericProcessEngine | Reports, batch processing |
| **Audit** | WingYip.SRS.Audit | Centralized audit logs |
| **Bronze** | WingYip.SRS.Bronze | Raw data landing zone |
| **StoreOperations** | WingYip.SRS.StoreOperations | Store walk, low/no stock |
| **GenericProcessEngine** | WingYip.SRS.GenericProcessEngine | Generic batch processing |
| **ReportEngine** | WingYip.SRS.ReportEngine | Report generation (consolidating into GenericProcessEngine) |
| **Reports** | WingYip.SRS.Reports | Report definitions (consolidating into GenericProcessEngine) |

---

## Key Data Entities by Domain

### Product Domain
| Entity | Key Fields | Source |
|--------|-----------|--------|
| Product | ProductID, Name, Description, UOM, CaseSize | SAP |
| Price | ProductID, Price, EffectiveDate | SAP / OpSuite |
| Supplier | SupplierID, Name, LeadTime | SAP |
| ProductLocation | ProductID, StoreID, Aisle, Bay, Level | SRS |
| ProductStatus | ProductID, StatusCode, ColorCode | SRS |

### Store & Layout Domain
| Entity | Key Fields | Source |
|--------|-----------|--------|
| Store | StoreID, Name, Type (Superstore/Didi) | SRS |
| Aisle | StoreID, AisleNumber | SRS |
| Bay | AisleID, BayNumber, Zone | SRS |
| Section | BayID, SectionNumber | SRS |
| Component | SectionID, ComponentType | SRS |
| BayGroup | StoreID, BayGroupID, BayIDs | SRS |
| ReplenGroup | StoreID, Aisle, ZoneCode, StartBay, EndBay | SRS |
| PickGroup | StoreID, Aisle, Bay, Level | SRS |

### Replenishment Domain
| Entity | Key Fields | Source |
|--------|-----------|--------|
| CaseReplenActions | ProductID, StoreID, ActionCode, Qty | SRS |
| ShelfReplenPicking | PickID, ReplenGroupID, StartTime | SRS |
| CumulativeSales | ProductID, StoreID, UnitsSold, CasesSold | OpSuite |
| ReplenGroupLock | ReplenGroupID, LockedBy, LockTime | SRS |

### Stock Domain
| Entity | Key Fields | Source |
|--------|-----------|--------|
| StockLevel | ProductID, StoreID, Location, Qty | Korber + SRS |
| BulkStock | ProductID, StoreID, PickFace, Overstock | Korber + SRS |
| StockDiscrepancy | DiscrepancyID, ProductID, StatusCode | SRS |
| StockControlAudit | AuditID, UserID, Field, OldVal, NewVal | SRS |

### Warehouse / Bulk Domain
| Entity | Key Fields | Source |
|--------|-----------|--------|
| PickLocation | LocationID, Aisle, Bay, Level, PickGroup | SRS |
| WarehouseLocation | LocationID, Type (Bulk/Pick/Overstock) | SRS |
| FillTrigger | LocationID, MaxQtyCases, TriggerQtyCases | SRS |

---

## ORM & Data Access

### Entity Framework Core
- **Database-first approach** — DbContext and entities generated from SQL Server schemas
- **Change tracking** — Automatic change detection for updates
- **LINQ queries** — Composable, type-safe queries with deferred execution
- **No stored procedures** (unless complex queries demand it)
- **Repository Pattern**: DB access isolated per service
- **CQRS**: Separate Command (write) and Query (read) paths via MediatR

### Repository Layer Architecture
```
Controller → CQRS Handler (MediatR) → Repository → DbContext (EF Core) → SQL Server
```

---

## Cross-Service Data Access

| Pattern | Implementation | Use Case |
|---------|---------------|----------|
| BFF Aggregation | Backend-for-Frontend aggregates data from 3 services | Product + Location + Stock display |
| Batch API / TVP | JSON payload → Table-Valued Parameter for bulk queries | 100+ products per request |
| Event-Driven | RabbitMQ messages for async data sync | Audit, notifications |
| Read Replicas | Optional per-site read replicas | Low-latency queries at remote stores |

---

## Data Marts (Gold Layer)

| Mart | Domain | Consumption |
|------|--------|-------------|
| Sales Mart | Sales transactions, daily/weekly/monthly | Power BI |
| Replenishment Mart | Replen actions, pick times, fill rates | Power BI |
| Finance Mart | Customer-type reports, store financials | SSRS |

---

## Environments

| Environment | Database | Purpose |
|-------------|----------|---------|
| Development | Dev instances | Active coding, unit tests |
| Test | Test instances | Integration testing |
| UAT | Staging instances | Business validation |
| Production | Prod instances (Always On AG) | Live operations |

---

## Cross-References

- [Microservices Design](./03-microservices-design.md) — Service boundaries, CQRS
- [Data Flow](./05-data-flow.md) — Medallion architecture (Bronze → Silver → Gold)
- [Data Migration](../data-engineering/02-data-migration.md) — Migration strategy
- [Data Mapping](../infrastructure/03-data-mapping.md) — SAP/Korber/OpSuite field mappings
- [DevOps Deployment](../infrastructure/02-devops-deployment.md) — DB server connectivity