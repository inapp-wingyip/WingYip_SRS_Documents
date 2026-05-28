# Data Engineering — End-to-End

---

## Overview

The SRS Data Engineering layer implements a **Medallion Architecture** (Bronze → Silver → Gold) using SSIS/SSDT-based pipelines to synchronize data from SAP, Korber WMS, and OpSuite into a centralized data warehouse.

**Document**: Data Workflow Design Document v1.0 (06-Feb-2026), authors: Ashish Gupta, Samphu
**Project Manager**: Nita Antony

### Key Highlights
- Three source systems → Bronze (raw) → Silver (clean) → Gold (analytics) → Data Marts → Power BI
- Incremental load strategy with watermark management
- Structured error handling, retry policies, logging, and alerting
- Performance and scalability considerations designed in

---

## Source Systems

| System | Data Domain | Integration Method |
|--------|------------|-------------------|
| **SAP** | Products, suppliers, pricing data | SSIS/SQL Native Client |
| **Korber WMS** | Stock, warehouse, logistics data | SSIS/SQL Native Client |
| **OpSuite** | Item, pricing, ePOS sales transactions | SSIS/SQL Native Client |

---

## Medallion Architecture Layers

### Bronze Layer (Landing Zone)
- **Purpose**: Raw data ingestion and persistence
- **Tool**: SSIS/ETL pipelines
- **Storage**: SQL Server tables
- **Characteristics**:
  - Minimal transformation applied
  - Source schema preserved for traceability
  - Append-only where possible
  - No business logic
  - Supports audit, reprocessing, and debugging

### Silver Layer (Microservice Databases)
- **Purpose**: Cleaned, standardized, conformed data
- **Tool**: SSIS pipelines (Bronze → Silver transformation)
- **Storage**: Domain-oriented databases — Product, Store, Location, Supplier
- **Characteristics**:
  - Data cleansing (nulls, formats, standardization)
  - Deduplication
  - Basic business rules applied
  - Schema aligned to business domains
  - Acts as contract layer between ingestion and analytics

### Gold Layer (Enterprise Data Warehouse)
- **Purpose**: Analytics-ready, curated data
- **Tool**: SQL scripts from Silver layer
- **Characteristics**:
  - Dimensional modeling (facts and dimensions)
  - Aggregated and historical data
  - Business-friendly naming and metrics
  - Supports enterprise KPIs

### Data Marts
- Built on top of Gold layer
- Subject-specific: Sales, Replenishment, Finance
- Tailored for specific business use cases

### Reporting & Analytics
- **Power BI** consumes Gold layer and Data Marts
- Dashboards, operational reports, ad-hoc analysis
- Role-based access control

---

## Synchronization Strategy

### Incremental Load Strategy
- Watermark management — per-table last-synced timestamps tracked
- SQL Server Change Data Capture (CDC) for efficient delta detection
- Only changed records processed (not full reloads)

### Data Sequencing
1. Reference data (codes, types, configurations) — first
2. Master data (products, stores, warehouses, suppliers) — second
3. Transactional data (sales, stock movements) — last

### Dependency Handling
- Each layer depends on the prior layer's completion
- Pipeline dependencies enforced via orchestration schedule

---

## Execution Schedule

| Pipeline | Frequency | Type | Source |
|----------|-----------|------|--------|
| SAP Products/Suppliers | Scheduled | Master data | SAP |
| Korber Warehouse Stock | Scheduled | Master + Transactional | Korber WMS |
| OpSuite Sales | Every 15 minutes | Transactional | OpSuite ePOS |
| Historical Sales | Scheduled | Historical | BI Database |

---

## Error Handling & Recovery

| Strategy | Implementation |
|----------|---------------|
| Error Categorization | Classified by severity and type |
| Retry Policy | Configurable with exponential backoff |
| Logging | Detailed execution logs per pipeline in dedicated logging tables |
| Notifications | Email/alert channels for critical failures |
| Recovery | Reprocessing from Bronze layer (full traceability) |
| Metrics | Execution duration, row counts, error rates |

---

## Logging & Auditing

### Logging Tables (Dedicated)
- Pipeline execution start/end timestamps
- Record counts — source vs target comparison
- Error details — entity, reason, severity
- Duration per pipeline step
- Watermark positions — last synced record per table

### Notification Channels
- Email alerts for critical pipeline failures
- Dashboard status indicators
- Scheduled summary reports

---

## Performance & Scalability
- Record counts estimated per entity
- Migration window and runtime projections tracked in Silver Layer Estimation spreadsheet
- Parallelism and batch sizing approach for large tables
- Read replicas optionally deployed per store site

---

## Security & Compliance
- Data classification and sensitivity marking per domain
- Encryption in transit (TLS 1.3) and at rest (SQL Server TDE)
- Data masking in non-production environments
- Compliance with applicable regulations
- Private network only — no external data exposure

---

## Deployment & Versioning
- Development, Test, UAT, Production environments
- Configuration and parameter management per environment
- Release and deployment approach via CI/CD pipeline

---

## Assumptions & Constraints
- Source system access provided per agreed timelines
- Target schema frozen prior to migration start
- Business SMEs available for validation and sign-off
- Private network connectivity stable between source and target systems

---

## Risk & Mitigation

| Risk | Mitigation |
|------|-----------|
| Source system access delays | Agreed timelines with regular checkpoints |
| Schema changes during migration | Schema freeze prior to migration start |
| Data quality issues in source systems | Data quality rules, validation at each layer boundary |
| Performance bottlenecks on large tables | Parallelism, optimized batch sizes, performance testing |
| Validation gaps between layers | Structured validation at technical, data integrity, and business levels |
| Pipeline failures mid-execution | Reprocessing from Bronze layer, configurable retry policy |
