# Data Flow Architecture — Medallion (Bronze → Silver → Gold)

---

## Architecture Overview

The SRS follows a **Medallion Architecture** (Bronze-Silver-Gold) for scalable, governed, and incremental data processing. SSIS/SSDT-based pipelines synchronize data from three source systems into the data warehouse.

```
┌──────────────────────────────────────────────────────────────┐
│                      SOURCE SYSTEMS                           │
│   ┌──────┐  ┌──────────┐  ┌──────────┐                      │
│   │ SAP  │  │  KORBER  │  │ OPSUITE  │                      │
│   └──┬───┘  └────┬─────┘  └────┬─────┘                      │
│      │           │             │                             │
│      └───────────┼─────────────┘                             │
│                  │ SSIS/ETL Pipelines                        │
└──────────────────┼──────────────────────────────────────────┘
                   ▼
┌──────────────────────────────────────────────────────────────┐
│                    BRONZE LAYER (Landing)                     │
│  • Raw data, minimal transformation                          │
│  • SQL Server, append-only                                   │
│  • Source schema preserved                                   │
│  • Used for audit, reprocessing, debugging                   │
└─────────────────────────────┬────────────────────────────────┘
                              │ SSIS: Clean, Standardize, Dedupe
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                    SILVER LAYER (Microservice DBs)            │
│  • Cleaned, standardized, conformed data                     │
│  • Domain-oriented (Product, Store, Location, Supplier)      │
│  • Data cleansing, deduplication, basic business rules       │
│  • Contract layer between ingestion and analytics            │
└─────────────────────────────┬────────────────────────────────┘
                              │ SQL scripts: Aggregate, Curate
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                    GOLD LAYER (EDW)                           │
│  • Analytics-ready, curated data                             │
│  • Dimensional modeling (facts + dimensions)                 │
│  • Aggregated + historical data                              │
│  • Business-friendly naming and metrics                      │
└─────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│              DATA MARTS & REPORTING                           │
│  • Sales, Replenishment, Finance marts                       │
│  • Power BI dashboards + role-based access                   │
│  • SSRS operational reports                                  │
└──────────────────────────────────────────────────────────────┘
```

---

## Layer Details

### Bronze Layer (Landing Zone)
- **Purpose**: Raw data ingestion, no business logic
- **Method**: SSIS/SSDT pipelines extract from source systems
- **Storage**: SQL Server tables, append-only where possible
- **No business logic applied**
- Source schema preserved for traceability
- Supports audit, reprocessing, and debugging

### Silver Layer (Microservice Databases)
- **Purpose**: Cleaned, standardized, domain-oriented data
- **Method**: SSIS pipelines transform from Bronze
- **Storage**: Domain-oriented databases — Product, Store, Location, Supplier
- Data cleansing and standardization
- Deduplication
- Basic business rules applied
- Schema aligned to business domains
- Acts as contract layer between ingestion and analytics

### Gold Layer (Enterprise Data Warehouse)
- **Purpose**: Analytics-ready, curated datasets
- **Method**: SQL scripts transform from Silver layer
- Dimensional modeling (facts and dimensions)
- Aggregated and historical data
- Business-friendly naming and metrics
- Supports enterprise KPIs

### Data Marts
- Built on top of Gold layer
- Sales, Replenishment, and functional marts
- Tailored for specific business use cases

---

## Synchronization Strategy

### Incremental Load Strategy
- **Watermark Management**: Track last-synced timestamps per table
- **Change Data Capture (CDC)**: SQL Server CDC for efficient deltas
- **Incremental Updates**: Only changed records processed

### Execution Schedule

| Pipeline | Frequency | Type | Source |
|----------|-----------|------|--------|
| Product Master | Scheduled | Master data | SAP |
| Warehouse Stock | Scheduled | Master + Transactional | Korber WMS |
| Sales Transactions | Every 15 minutes | Transactional | OpSuite ePOS |
| Historical Sales | Scheduled | Historical | BI Database |

### Data Sequencing
1. Reference data (codes, types, configurations)
2. Master data (products, stores, warehouses, suppliers)
3. Transactional data (sales, stock movements)

### Dependency Handling
- Reference data must complete before master data
- Master data must complete before transactional data
- Pipeline dependencies enforced via schedule orchestration

---

## Error Handling & Recovery

| Strategy | Implementation |
|----------|---------------|
| Error Categorization | Classified by severity and type |
| Retry Policy | Configurable retry with exponential backoff |
| Logging | Detailed execution logs per pipeline run in dedicated logging tables |
| Notifications | Email/alert for critical failures |
| Recovery | Reprocessing from Bronze layer (full traceability) |
| Metrics | Execution duration, row counts, error rates |

---

## Logging & Auditing

### Logged Metrics
- Pipeline execution start/end timestamps
- Record counts (source vs target)
- Error details (entity, reason, severity)
- Duration per pipeline step
- Watermark positions (last synced record)

### Notification Channels
- Email alerts for critical failures
- Dashboard status indicators
- Scheduled summary reports

---

## Data Quality Rules

- Mandatory field validation (no nulls in required columns)
- Uniqueness and referential integrity checks
- Duplicate handling rules (first-wins, last-wins, merge)
- Data standardization (dates, currency, formats)
- Code and status mappings
- Derived and calculated field verification

### Validation Levels
| Level | Method |
|-------|--------|
| Technical | Counts, schema checks, data type validation |
| Data Integrity | Referential integrity, uniqueness constraints |
| Business | Sample-based validation, control totals |

---

## Performance & Scalability
- Estimated record counts per entity (defined in Silver Layer Estimation spreadsheet)
- Migration window and expected runtimes tracked
- Parallelism and batch sizing approach
- Read replicas for query offloading (optional per site)

## Security & Compliance
- Data classification and sensitivity marking
- Encryption in transit (TLS 1.3) and at rest (SQL Server TDE)
- Masking in non-production environments
- Compliance with applicable regulations
- Private network only — no external data exposure

---

## Environments

| Environment | Purpose |
|-------------|---------|
| Development | Active development, unit testing |
| Test | Integration testing, automated tests |
| UAT | Business validation and sign-off |
| Production | Live operations, Always On AG |

---

## Risk & Mitigation

| Risk | Mitigation |
|------|-----------|
| Source system access delays | Agreed timelines, regular checkpoints |
| Schema changes mid-migration | Frozen schema prior to migration start |
| Data quality issues | Data quality rules, validation checkpoints at each layer |
| Performance bottlenecks | Parallelism, batch sizing, performance testing |
| Validation gaps | Structured validation at technical, data, and business levels |
| Pipeline failure | Reprocessing from Bronze layer, retry with exponential backoff |
