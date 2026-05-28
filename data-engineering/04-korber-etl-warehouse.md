# Korber ETL & Data Warehouse Design

> Derived from `drive/Archived_19-Dec-2025/Documents/Design & Architecture/Datawarehouse/` and `drive/Documents/Design/Data Engineering/`.

---

## Overview

The Korber WMS integration is one of three source system ETL pipelines feeding the SRS data warehouse. This document captures the archived data warehouse design artifacts that informed the current Medallion architecture.

---

## Korber ETL Design

### Source: `KORBER_ETL_Design_Document.docx`

### Key Design Points
- Korber WMS provides: Warehouse stock, location data, logistics data, IBT transfers
- Integration via SSIS/SQL Native Client against Korber's SQL Server database
- Extraction from Korber's standard tables mapping into SRS Bronze layer
- Delta detection via timestamps and change tracking

---

## Data Warehouse Architecture Diagrams

### Source Files
| Document | Description |
|----------|-------------|
| ExistingArchitectureMermaid.txt | Current architecture represented in Mermaid diagram syntax |
| NewArchitectureMermaid.txt | Proposed SRS architecture in Mermaid diagram syntax |
| ExistingArch.png | Visual diagram of existing architecture |
| DE.jpg | Data engineering flow diagram |
| SRS Schema Definition.xlsx | Overall SRS schema definition (superseded by Microservice Schema Definition) |
| Untitled diagram-2025-12-04-162650.png | Architecture diagram dated 4-Dec-2025 |
| Data Engineering Flow.docx | Data engineering flow documentation |

### Architecture Evolution
- **Existing**: Direct database access between legacy system and source systems
- **New (SRS)**: Medallion Architecture — Bronze (raw) → Silver (cleaned) → Gold (analytics) with proper ETL pipelines

---

## Facts & Dimensions Model

### Source: `Datawarehouse Facts & Dimensions.xlsx`

### Dimension Tables
| Dimension | Description |
|-----------|-------------|
| Product | Product master with hierarchy (Category → Group → Item) |
| Store | Store details including type (Superstore/Didi) |
| Location | Warehouse and store locations (aisle/bay/level) |
| Supplier | Supplier master data |
| Date | Calendar dimension (day/week/month/53-week year) |

### Fact Tables
| Fact | Description |
|------|-------------|
| Sales | ePOS transactions (Store × Product × Date × UOM) |
| Stock Level | Point-in-time stock quantities (Product × Location × Date) |
| Replenishment Actions | CaseReplenActions tracking (Product × Store × Action × Date) |
| Stock Movements | Inter-location transfers (From × To × Product × Date) |

---

## Data Engineering Flow

### Source: `Data Engineering Flow.docx`

- Documents the end-to-end data flow from source systems through ETL to analytics
- Covers: Source extraction → Bronze staging → Silver transformation → Gold aggregation → Data Marts
- Scheduling and dependency chain between pipelines
- Error handling and recovery procedures per pipeline

---

## Current vs. Proposed Architecture

### Existing (Legacy)
```
SAP DB ←→ Legacy Application ←→ Korber DB
                              ←→ OpSuite DB
```
- Direct database connections
- No separate data warehouse
- No ETL pipeline management
- Limited reporting capabilities

### Proposed (SRS — Medallion)
```
SAP ──┐
      ├──→ SSIS/ETL → Bronze → Silver → Gold → Data Marts → Power BI
Korber┤
      │
OpSuite┘
```
- Centralized data warehouse
- Medallion layers with proper governance
- Incremental loading with CDC
- Analytics-ready Gold layer supporting Power BI and SSRS

---

## Cross-References

- [Data Flow Architecture](../architecture/05-data-flow.md) — Medallion architecture detail
- [Data Engineering Workflow](./01-data-workflow.md) — Current SSIS pipeline design
- [Data Migration Strategy](./02-data-migration.md) — Migration approach
- [ETL Pipeline Catalog](./03-ssis-pipeline-catalog.md) — Current pipeline schedules
- [Data Mapping](../infrastructure/03-data-mapping.md) — Korber field mappings