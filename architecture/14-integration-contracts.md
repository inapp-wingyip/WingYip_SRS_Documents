# Integration Contracts — Source System Specifications

> Derived from `drive_raw/Archived_19-Dec-2025/Documents/Data mapping sheets/` (SAPDB_COMPLETE_MAPPING.xlsx, KORBER_DB_Complete_Mapping.xlsx, OPSUITE_SRS_DB_Mapping.xlsx), `drive_raw/Documents/Design/Data Engineering/SQL Pipeline for SAP - Product Store Due Deliveries.docx`, `drive_raw/Documents/Design/Data Engineering/ETL - Pipelines.xlsx`, `drive_raw/Documents/Design/Data Engineering/Dataflow Schedule.xlsx`, and on-prem architecture documentation.

---

## Integration Overview

The SRS integrates with three primary source systems via SSIS/ETL pipelines. Each integration follows the Medallion Architecture: Source → Bronze (raw) → Silver (clean) → Gold (analytics).

```
┌───────────┐     ┌───────────┐     ┌───────────┐
│    SAP    │     │  KORBER   │     │  OPSUITE  │
│ Products, │     │ Warehouse,│     │  ePOS     │
│ Pricing,  │     │  Stock,   │     │  Sales,   │
│ Suppliers │     │  Logistics│     │  Pricing  │
└─────┬─────┘     └─────┬─────┘     └─────┬─────┘
      │                 │                  │
      └────────┬────────┴────────────────┘
               │ SSIS/SQL Native Client
               ▼
        ┌──────────────┐
        │  BRONZE LAYER │  (Raw ingestion, no transformation)
        └──────┬───────┘
               │ SSIS: Clean, Standardize, Dedupe
               ▼
        ┌──────────────┐
        │ SILVER LAYER  │  (Microservice DBs — domain-oriented)
        └──────┬───────┘
               │ SQL scripts: Aggregate, Curate
               ▼
        ┌──────────────┐
        │  GOLD LAYER   │  (Enterprise Data Warehouse)
        └──────────────┘
```

---

## SAP Integration

### Connection Specification

| Parameter | Value |
|-----------|-------|
| **Source DB** | SQL Server (SAP instance) |
| **Integration Method** | SSIS via SQL Server Native Client |
| **Sync Mode** | Incremental (watermark timestamps) + CDC |
| **Schedule** | Scheduled batch (see pipeline catalog) |
| **Direction** | SAP → SRS (one-way) |

### Data Domains

| Domain | Key Entities | Key Fields | Sync Frequency |
|--------|-------------|-------------|----------------|
| **Product Master** | Product, ProductGroup | ProductID, Name, Description, UOM, CaseSize | Daily (scheduled) |
| **Pricing** | Price, PriceList | ProductID, Price, Currency, ValidFrom, ValidTo | Daily (scheduled) |
| **Suppliers** | Supplier, SupplierProduct | SupplierID, Name, LeadTime, Contact | Weekly (scheduled) |
| **Purchase Orders** | PurchaseOrder, PO Line | PO Number, Products, Quantities, Delivery Dates | Daily (scheduled) |

### Field Mapping Reference

Source: `drive_raw/Archived_19-Dec-2025/Documents/Data mapping sheets/SAPDB_COMPLETE_MAPPING.xlsx`

| SAP Field | SRS Field | Transform | Notes |
|-----------|-----------|-----------|-------|
| MANDT | Client | Direct | SAP client identifier |
| MATNR | ProductID | String trim, prefix | Material number |
| MAKTX | ProductName | String clean | Material description |
| MEINS | UOM | Direct | Unit of measure |
| MSTAE | CaseSize | Numeric cast | Case size |
| LIFNR | SupplierID | String trim | Vendor number |
| NETPR | Price | Decimal cast | Net price |
| WAERS | Currency | Direct | Currency code |
| DATAB | ValidFrom | Date format | Valid-from date |
| DATBI | ValidTo | Date format | Valid-to date |

> **Complete field-level mapping**: See `SAPDB_COMPLETE_MAPPING.xlsx` in data mapping sheets for all columns.

### Pipeline Details

Source: `drive_raw/Documents/Design/Data Engineering/SQL Pipeline for SAP - Product Store Due Deliveries.docx`

- **Product Store Due Deliveries**: Extracts product delivery information from SAP
- **Incremental load**: Watermark-based, tracks last-synced timestamps per table
- **Error handling**: Retry with exponential backoff, email alerts on critical failures

---

## Korber WMS Integration

### Connection Specification

| Parameter | Value |
|-----------|-------|
| **Source DB** | SQL Server (Korber instance) |
| **Integration Method** | SSIS via SQL Server Native Client |
| **Sync Mode** | Incremental (CDC) |
| **Schedule** | Scheduled batch (see pipeline catalog) |
| **Direction** | Korber → SRS (one-way) |

### Data Domains

| Domain | Key Entities | Key Fields | Sync Frequency |
|--------|-------------|-------------|----------------|
| **Warehouse Stock** | StockItem, Location | SKU, LocationCode, QtyOnHand, QtyAllocated | Daily + near-real-time |
| **Warehouse Layout** | Aisle, Bay, Level | AisleID, BayID, Zone, LocationType | Weekly (scheduled) |
| **Inter-Branch Transfers** | IBT, IBTLine | TransferID, FromStore, ToStore, Products, Qty | Daily (scheduled) |
| **Put-Away Locations** | PutAwayItem | SKU, TargetLocation, SourceLocation | Near-real-time |

### Field Mapping Reference

Source: `drive_raw/Archived_19-Dec-2025/Documents/Data mapping sheets/KORBER_DB_Complete_Mapping.xlsx`

| Korber Field | SRS Field | Transform | Notes |
|-------------|-----------|-----------|-------|
| ARTNR | ProductID | String trim | Article number |
| LPLATZ | LocationCode | Direct | Storage location |
| BESTAND | QtyOnHand | Decimal cast | Current stock |
| RESERMIERT | QtyAllocated | Decimal cast | Reserved quantity |
| AUFTRAGNR | OrderReference | Direct | Order reference |

> **Complete field-level mapping**: See `KORBER_DB_Complete_Mapping.xlsx` for all columns.

### Korber ETL Architecture

Source: `drive_raw/Archived_19-Dec-2025/Documents/Design & Architecture/Datawarehouse/` (KORBER_ETL_Design_Document.docx, Facts & Dimensions mapping)

- Dimensional modeling approach for data warehouse
- Facts and Dimensions mapping per the Korber ETL design
- Existing vs new architecture diagrams (Mermaid format)
- Data flow: Korber DB → Bronze → Silver → Gold (Facts/Dimensions)

---

## OpSuite Integration

### Connection Specification

| Parameter | Value |
|-----------|-------|
| **Source DB** | SQL Server (OpSuite instance) |
| **Integration Method** | SSIS via SQL Server Native Client |
| **Sync Mode** | Near-real-time (every 15 minutes for sales) |
| **Schedule** | Every 15 minutes for transactional data |
| **Direction** | OpSuite → SRS (one-way) |
| **Special Note** | OpSuite exposes stored procedures that SRS may call |

### Data Domains

| Domain | Key Entities | Key Fields | Sync Frequency |
|--------|-------------|-------------|----------------|
| **ePOS Sales** | Transaction, TransactionLine | TransactionID, StoreID, ProductID, Qty, Price, Timestamp | Every 15 minutes |
| **Item Data** | Item, ItemPrice | ItemCode, Description, Price, UOM | Daily (scheduled) |
| **Pricing** | PriceList, Promotion | ProductID, Price, EffectiveDate | Daily (scheduled) |

### Field Mapping Reference

Source: `drive_raw/Archived_19-Dec-2025/Documents/Data mapping sheets/OPSUITE_SRS_DB_Mapping.xlsx`

| OpSuite Field | SRS Field | Transform | Notes |
|---------------|-----------|-----------|-------|
| ItemCode | ProductID | String trim | Item identifier |
| TransactionNo | TransactionID | Direct | Transaction number |
| StoreId | StoreId | Int cast | Store identifier |
| QuantitySold | QtySold | Decimal cast | Quantity sold |
| SalePrice | SalePrice | Decimal cast | Sale price |
| TransactionDate | TransactionDate | DateTime cast | Transaction timestamp |

> **Complete field-level mapping**: See `OPSUITE_SRS_DB_Mapping.xlsx` for all columns.

---

## ETL Pipeline Scheduling

Source: `drive_raw/Documents/Design/Data Engineering/ETL - Pipelines.xlsx`, `drive_raw/Documents/Design/Data Engineering/Dataflow Schedule.xlsx`

### Pipeline Execution Schedule

| Pipeline | Source | Frequency | Priority | Dependencies |
|----------|--------|-----------|----------|-------------|
| Product Master | SAP | Daily (06:00) | High | None |
| Pricing | SAP | Daily (06:30) | High | Product Master |
| Supplier | SAP | Weekly (Sun 02:00) | Medium | Product Master |
| Warehouse Stock | Korber | Daily (07:00) | High | Product Master |
| Warehouse Layout | Korber | Weekly (Sun 03:00) | Medium | Product Master |
| IBT | Korber | Daily (07:30) | High | Warehouse Stock |
| ePOS Sales | OpSuite | Every 15 min | Critical | Product Master |
| Item Data | OpSuite | Daily (05:00) | High | None |
| Pricing (OpSuite) | OpSuite | Daily (05:30) | High | Item Data |

### Data Sequencing Rule

1. **Reference data first** — Codes, types, configurations
2. **Master data second** — Products, stores, warehouses, suppliers
3. **Transactional data last** — Sales, stock movements

---

## Error Handling & Monitoring Per Integration

| Strategy | Implementation |
|----------|---------------|
| **Connection failure** | Configurable retry (3 attempts, exponential backoff) |
| **Schema change detection** | Frozen schema pre-migration; alert on unexpected columns |
| **Data quality failure** | Quarantine invalid records; continue with valid data |
| **Timeout** | Adaptive timeout based on data volume |
| **Dead Letter** | Failed records logged to DLQ table for manual review |
| **Alerting** | Email + dashboard notification on pipeline failure |

---

## Client-Supplied Data

Source: `drive_raw/Client-Supplied/` and `drive_raw/Documents/Client Supplied/`

| File | Description | Integration Point |
|------|-------------|-------------------|
| SRS v11 flow diagram.pdf | Flow diagram for SRS v11 | Reference |
| GROUP PROMOTIONS AND LIMITS.xlsx | Group promotions and configuration limits | Product/Pricing reference |
| ItemGrpProducts Database_GUI suggestion.xlsx | Database/GUI structure suggestions | Product group reference |
| Purchasing Report All Warehouses_ Stores v3 08.02.26.xlsx | Purchasing report across all sites | Finance/Replenishment reference |

---

## Raw Source Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Archived_19-Dec-2025/Documents/Data mapping sheets/SAPDB_COMPLETE_MAPPING.xlsx` | Complete SAP → SRS field mapping |
| `drive_raw/Archived_19-Dec-2025/Documents/Data mapping sheets/KORBER_DB_Complete_Mapping.xlsx` | Complete Korber → SRS field mapping |
| `drive_raw/Archived_19-Dec-2025/Documents/Data mapping sheets/OPSUITE_SRS_DB_Mapping.xlsx` | Complete OpSuite → SRS field mapping |
| `drive_raw/Archived_19-Dec-2025/Documents/Data mapping sheets/Bronze - Skeleton Script.docx` | Bronze layer script skeleton |
| `drive_raw/Documents/Design/Data Engineering/SQL Pipeline for SAP - Product Store Due Deliveries.docx` | SAP pipeline specification |
| `drive_raw/Documents/Design/Data Engineering/ETL - Pipelines.xlsx` | ETL pipeline configurations |
| `drive_raw/Documents/Design/Data Engineering/Dataflow Schedule.xlsx` | Pipeline execution schedule |
| `drive_raw/Documents/Design/Data Engineering/Silver_Layer_Estimation.xlsx` | Silver layer sizing estimates |
| `drive_raw/Archived_19-Dec-2025/Documents/Design & Architecture/Datawarehouse/KORBER_ETL_Design_Document.docx` | Korber ETL architecture design |
| `drive_raw/Archived_19-Dec-2025/Documents/Design & Architecture/Datawarehouse/Datawarehouse Facts & Dimensions.xlsx` | Facts and dimensions mapping |

---

## Cross-References

- [Data Flow Architecture](./05-data-flow.md) — Medallion Bronze → Silver → Gold
- [Data Mapping](../infrastructure/03-data-mapping.md) — Source system mapping overview
- [Data Workflow](../data-engineering/01-data-workflow.md) — SSIS pipeline design
- [Database Schema](./08-database-schema.md) — Microservice databases
- [DevOps Deployment](../infrastructure/02-devops-deployment.md) — CI/CD pipeline