# ADR-032. Bronze/Silver Medallion Architecture for ETL

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS Data Engineering ecosystem manages data from 5+ source systems (SAP, OpSuite, Korber) into 5+ microservice databases (Administration, Audit, Product, Store, Order). A data architecture pattern is needed to organize extraction, transformation, and loading stages with clear separation of concerns.

**Current implementation:**
- **Bronze layer**: Raw ingestion from source systems — unvalidated, unmapped data landing in staging tables
- **Silver layer**: Transformed, cleansed, and validated data written to 5 microservice target databases
- **11 SSIS packages** orchestrate the pipeline (ADR-021)
- **Metadata-driven discovery**: `dbo.vw_ETL_Active_Tables_To_Run` dynamically discovers which tables to process

**Why medallion over direct ETL:**
- Separation of raw ingestion (Bronze) from business transformation (Silver)
- Bronze provides an audit trail of source system data for debugging
- Silver can be regenerated from Bronze if transformation rules change
- Supports multiple source systems with different schemas

## Decision

We adopt a **two-tier medallion architecture** (Bronze + Silver, no Gold/curated layer):

1. **Bronze layer**: Raw data from source systems, stored as-is with minimal transformation
   - Stored in staging database (separate from target microservice databases)
   - Ingested via SSIS packages calling source system stored procedures
   - No business rules applied at this stage
2. **Silver layer**: Transformed data ready for microservice consumption
   - Business rules, data type mapping, deduplication, validation applied
   - Written to 5 separate microservice databases (Admin, Audit, Product, Store, Order)
   - Orchestrated by SSIS packages calling stored procedures
3. **No Gold layer**: No enterprise-wide curated dataset or data warehouse. Each microservice owns its data.
4. **Metadata-driven execution**: Which tables run is determined by `dbo.vw_ETL_Active_Tables_To_Run` view at runtime

## Consequences

**Positive:**
- Clear separation between raw ingestion and business transformation
- Bronze data provides debugging capability (can compare source vs transformed)
- Microservice databases receive only validated, transformed data
- Metadata-driven discovery allows flexible pipeline extension without SSIS package changes

**Negative:**
- **No Gold layer**: No unified enterprise data model or reporting layer (microservices own their own data)
- Bronze data duplication: Same data exists in source system AND Bronze staging AND Silver target
- 5 separate target databases increase operational complexity (backups, consistency, cross-database joins)
- No data catalog or lineage tracking (can't trace a Silver record back to its Bronze source without manual query)

**Future constraints:**
- Any new source system requires new Bronze ingestion package
- New target microservice requires new Silver transformation mapping
- If enterprise reporting or analytics becomes a requirement, a Gold/curated layer may be needed
- Consider data lineage tooling (e.g., Microsoft Purview, Apache Atlas) if data traceability becomes critical

## Related ADRs

- ADR-021: SSIS as pure orchestrator (packages implement the medallion pipeline)
- ADR-002: Database-per-service (Silver writes to 5 separate databases)
- ADR-007: SSIS plaintext credentials (security in the same pipeline)
