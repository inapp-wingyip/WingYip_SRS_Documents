# Source System Data Mapping

> Derived from `drive/Archived_19-Dec-2025/Documents/Data mapping sheets/` and `drive/Documents/Client Supplied/`.

---

## Overview

The SRS integrates data from three primary source systems via SSIS/ETL pipelines. Each system has a dedicated field-level mapping to the SRS data model. Understanding these mappings is critical for data engineering, migration, and debugging.

---

## Source Systems

| System | Database | Data Domain | Integration |
|--------|----------|-------------|-------------|
| **SAP** | SQL Server | Products, suppliers, pricing, purchase orders | SSIS / SQL Native Client |
| **Korber WMS** | SQL Server | Warehouse stock, locations, logistics, IBTs | SSIS / SQL Native Client |
| **OpSuite** | SQL Server | ePOS sales transactions, item data, pricing | SSIS / SQL Native Client |

---

## Mapping Documents

| Document | Source System | Description |
|----------|-------------|-------------|
| SAPDB_COMPLETE_MAPPING.xlsx | SAP | Complete SAP → SRS field mapping |
| KORBER_DB_Complete_Mapping.xlsx | Korber WMS | Complete Korber → SRS field mapping |
| OPSUITE_SRS_DB_Mapping.xlsx | OpSuite | Complete OpSuite → SRS field mapping |
| Bronze - Skeleton Script.docx | — | Bronze layer script skeleton for initial loads |
| ItemGrpProducts Database_GUI suggestion.xlsx | Client Supplied | Product group structures and GUI suggestions |
| GROUP PROMOTIONS AND LIMITS.xlsx | Client Supplied | Group promotions and limit configurations |
| Purchasing Report All Warehouses_ Stores v3 08.02.26.xlsx | Client Supplied | Current purchasing report across all sites |

---

## SAP Data Mapping

### Key Data Domains
| Domain | Key Entities | Direction |
|--------|-------------|-----------|
| Product Master | ProductID, Name, Description, UOM, CaseSize | SAP → SRS |
| Pricing | ProductID, Price, Currency, ValidFrom, ValidTo | SAP → SRS |
| Supplier | SupplierID, Name, LeadTime, Contact | SAP → SRS |
| Purchase Orders | PO Number, Products, Quantities, Dates | SAP → SRS |

### SAP Pipeline (Data Engineering)
- Reference: `SQL Pipeline for SAP - Product Store Due Deliveries.docx`
- Scheduled extraction via SSIS pipeline
- Delta detection via watermark timestamps

---

## Korber WMS Data Mapping

### Key Data Domains
| Domain | Key Entities | Direction |
|--------|-------------|-----------|
| Warehouse Stock | ProductID, LocationID, Qty, Status | Korber → SRS |
| Warehouse Location | LocationID, Aisle, Bay, Level, Type | Korber → SRS |
| Logistics | IBT Transfers, Delivery Notes | Korber → SRS |
| Stock Movements | MovementID, FromLocation, ToLocation, Qty, Timestamp | Korber → SRS |

### Korber ETL Design
- Reference: `KORBER_ETL_Design_Document.docx` (archived)
- Existing architecture diagram: `ExistingArchitectureMermaid.txt`
- Proposed architecture diagram: `NewArchitectureMermaid.txt`

---

## OpSuite Data Mapping

### Key Data Domains
| Domain | Key Entities | Direction |
|--------|-------------|-----------|
| ePOS Transactions | TransactionNumber, StoreID, ProductID, Qty, Price, Timestamp | OpSuite → SRS |
| Item Data | ItemID, Description, Price, Category | OpSuite → SRS |
| Sales Summary | StoreID, Date, TotalSales, TransactionCount | OpSuite → SRS |

### OpSuite Integration Points
- **Stored Procedure**: `GetTransactionsforToday` — called every 15 minutes for sales-based replenishment
- Transaction deduplication by TransactionNumber
- UoM codes: 1 = individual, 2/3 = cases

---

## Data Flow: Source → Bronze → Silver

```
┌──────┐  ┌──────────┐  ┌──────────┐
│ SAP  │  │  KORBER  │  │ OPSUITE  │
└──┬───┘  └────┬─────┘  └────┬─────┘
   │           │             │
   └───────────┼─────────────┘
               ▼
        ┌──────────────┐
        │ BRONZE LAYER  │  ← Raw data, source schema preserved
        │ (Landing)     │     Append-only, no business logic
        └──────┬───────┘
               ▼
        ┌──────────────┐
        │ SILVER LAYER  │  ← Cleaned, standardized, domain-oriented
        │ (Microservice │     Deduped, business rules applied
        │   DBs)        │
        └──────┬───────┘
               ▼
        ┌──────────────┐
        │  GOLD LAYER   │  ← Analytics-ready, dimensional model
        │  (EDW)        │     Facts + Dimensions
        └──────────────┘
```

### Transformation Rules
- **Data Standardization**: ISO date formats, standardized currency/numeric formats
- **Code Mapping**: Legacy source codes → SRS standard codes
- **Derived Fields**: Composite keys, calculated values
- **Deduplication**: First-wins / last-wins / merge per entity type
- **Referential Integrity**: FK validation across entities at Silver layer

---

## Data Validation

### Validation at Each Layer
| Layer | Validation | Method |
|-------|-----------|--------|
| Bronze → Silver | Technical | Row counts, schema checks, data type validation |
| Silver → Gold | Integrity | Referential integrity, uniqueness constraints |
| Gold → Marts | Business | Sample-based validation, control totals, SME checks |

---

## Client-Supplied Data

| Document | Description |
|----------|-------------|
| SRS v11 flow diagram.pdf | Client-provided SRS flow diagram |
| GROUP PROMOTIONS AND LIMITS.xlsx | Active promotions and purchase limits data |
| ItemGrpProducts Database_GUI suggestion.xlsx | Product grouping structure and UI suggestions |
| Purchasing Report All Warehouses_ Stores v3.xlsx | Current purchasing activity report (08-Feb-2026) |

---

## Cross-References

- [Data Flow Architecture](../architecture/05-data-flow.md) — Medallion architecture detail
- [Data Engineering Workflow](../data-engineering/01-data-workflow.md) — SSIS pipeline design
- [Data Migration Strategy](../data-engineering/02-data-migration.md) — Migration approach
- [Database Schema](../architecture/08-database-schema.md) — SRS target schema
- [ETL Pipeline Catalog](../data-engineering/03-ssis-pipeline-catalog.md) — Pipeline schedules