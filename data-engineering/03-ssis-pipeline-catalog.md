# SSIS Pipeline Catalog

> Derived from `drive/Documents/Design/Data Engineering/` — ETL - Pipelines.xlsx, Dataflow Schedule.xlsx, Back Ground and Pipeline Process_.xlsx.

---

## Pipeline Overview

Data flows from source systems (SAP, Korber, OpSuite) through SSIS/SSDT-based ETL pipelines into the SRS data warehouse following the Medallion Architecture (Bronze → Silver → Gold).

---

## ETL Pipeline Definitions

### Source: `ETL - Pipelines.xlsx`

| Pipeline | Source System | Target Layer | Type | Frequency |
|----------|-------------|-------------|------|-----------|
| Product Master | SAP | Bronze → Silver | Master | Scheduled |
| Pricing & Suppliers | SAP | Bronze → Silver | Master | Scheduled |
| Warehouse Stock | Korber | Bronze → Silver | Master + Transactional | Scheduled |
| Warehouse Locations | Korber | Bronze → Silver | Master | Scheduled |
| ePOS Sales Transactions | OpSuite | Bronze → Silver | Transactional | Every 15 min |
| Historical Sales | BI Database | Bronze → Silver | Historical | Scheduled |
| Product Store Due Deliveries | SAP | Silver | Transactional | Scheduled |

---

## Dataflow Schedule

### Source: `Dataflow Schedule.xlsx`

| Schedule Group | Pipelines | Timing | Dependencies |
|---------------|-----------|--------|--------------|
| **Reference Data** | Codes, types, statuses, configurations | First (daily/initial) | None |
| **Master Data** | Products, stores, warehouses, suppliers, users | Second | Reference data complete |
| **Transactional Data** | Sales, stock movements | Third (ongoing) | Master data complete |
| **Real-Time Sales** | OpSuite ePOS transactions | Every 15 minutes | Master data loaded |
| **Historical Load** | BI Database historical sales | One-time + scheduled | Master data loaded |

### Execution Windows
| Window | Pipelines | Notes |
|--------|-----------|-------|
| **Nightly Batch** | Reference + Master data refresh | Off-peak, before store opening |
| **15-min Cycle** | OpSuite sales sync | Continuous during trading hours |
| **Weekly** | Full reconciliation, historical data refresh | Weekend maintenance window |

---

## Background & Pipeline Processes

### Source: `Back Ground and Pipeline Process_.xlsx`

| Process | Type | Frequency | Description |
|---------|------|-----------|-------------|
| Sales-Based Replenishment | Background Service | Every 15 min | Fetch EPOS transactions, calculate cumulative sales, generate CaseReplenActions |
| Store Walk Replenishment | Background Service | Every 10 sec | Scan for Low/No stock, create urgent replenishment tasks |
| Replenishment Group Lock Cleanup | Background Service | Periodic | Release stale locks from crashed/abandoned sessions |
| Data Pipeline Execution | SSIS Package | Scheduled | Bronze → Silver → Gold transformations |
| CDC Watermark Update | SSIS Package | Per pipeline | Track last-synced timestamp per table |

---

## Pipeline Dependencies

```
┌─────────────────┐
│  Reference Data  │ ← Load first (codes, types, configs)
└────────┬────────┘
         ▼
┌─────────────────┐
│   Master Data    │ ← Products, stores, warehouses, suppliers
└────────┬────────┘
         ▼
┌─────────────────┐
│ Transactional    │ ← Sales, stock movements, orders
│     Data         │
└────────┬────────┘
         ▼
┌─────────────────┐
│  Gold Layer /    │ ← Aggregation, dimensional modeling
│  Data Marts      │
└─────────────────┘
```

- Each layer's pipelines must complete before the next layer begins
- Parallelism within a layer where no dependencies exist
- Error in upstream layer blocks downstream processing

---

## SAP-Specific Pipeline

### Source: `SQL Pipeline for SAP - Product Store Due Deliveries.docx`

- Product master extraction from SAP SQL Server database
- Store-product delivery relationships
- Delta detection via watermark timestamps
- Used for initial stock level setup and ongoing replenishment

---

## Silver Layer Estimation

### Source: `Silver_Layer_Estimation.xlsx`

- Estimated record counts per entity in Silver layer
- Used for capacity planning and performance projections
- Drives batch sizing and parallelism decisions
- Migration window and runtime calculations based on these estimates

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Source system unavailable | Retry with exponential backoff; alert after max retries |
| Schema mismatch | Log error, skip record, continue pipeline; alert for critical tables |
| Duplicate records | Apply dedup rules (first-wins/last-wins per entity) |
| Constraint violation | Log to error table, continue non-critical; halt critical |
| Pipeline timeout | Kill process, alert, support manual restart from last watermark |
| Full pipeline failure | Reprocess from Bronze layer (full traceability maintained) |

---

## Cross-References

- [Data Engineering Workflow](./01-data-workflow.md) — Medallion architecture detail
- [Data Migration Strategy](./02-data-migration.md) — Migration approach and validation
- [Data Flow Architecture](../architecture/05-data-flow.md) — Layer architecture
- [Data Mapping](../infrastructure/03-data-mapping.md) — Source system field mappings