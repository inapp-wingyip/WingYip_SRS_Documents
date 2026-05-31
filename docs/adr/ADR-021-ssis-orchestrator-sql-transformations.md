# ADR-021. SSIS as Pure Orchestrator with SQL-Based Transformations

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS Data Engineering ecosystem implements a Bronze/Silver medallion architecture using SQL Server Integration Services (SSIS). ETL pipelines extract data from source systems (SAP, OpSuite, Korber), apply transformations, and load into microservice databases.

**Critical finding**: SSIS is used as a **pure orchestration shell** — zero Data Flow Tasks across 11 packages. All data movement and transformation logic lives in T-SQL stored procedures executed via dynamic SQL (`EXEC Schema.Proc @Run_ID = ?`).

**Current implementation:**
- 11 SSIS packages (Bronze layer: 3 ingest + 1 master; Silver layer: 7 stored procedure orchestrators)
- All Bronze packages: `Execute SQL Task` → `Foreach Loop` → `Execute SQL Task` (run stored procedure)
- All Silver packages: `Foreach Loop` → `Execute SQL Task` (run stored procedure per table)
- `MaxErrorCount=0` (continue on error) with fail-at-end validation gate
- `dbo.vw_ETL_Active_Tables_To_Run` view dynamically discovers which procedures to execute

**Why stored procedures over Data Flow Tasks:**
- T-SQL transformations are faster for set-based operations on SQL Server
- SSIS Data Flow Tasks have memory limitations and slower performance for large datasets
- DBA team owns transformation logic; SSIS team owns orchestration

## Decision

We explicitly accept **SSIS as orchestrator, T-SQL as transformer**:

1. **SSIS responsibilities only**:
   - Connection management (source and target databases)
   - Loop iteration over tables/packages
   - Logging (`ETL_Bronze_Pipeline_Log`, `ETL_Bronze_Task_Log`)
   - Error aggregation and final validation gate
   - Email alerting via SMTP
2. **T-SQL responsibilities**:
   - All data extraction, transformation, and loading logic
   - Source system queries and target table inserts/updates
   - Business rules and data quality checks
3. **No Data Flow Tasks**: This is an intentional architectural choice, not a gap

## Consequences

**Positive:**
- T-SQL set-based operations are significantly faster than SSIS Data Flow row-by-row processing
- DBA team can optimize transformations independently of SSIS package changes
- SSIS packages are lightweight — primarily control flow with minimal logic
- Metadata-driven discovery (`vw_ETL_Active_Tables_To_Run`) enables flexible pipeline extension

**Negative:**
- **Business logic lives in stored procedures, not version control**: T-SQL code is in the database, not in Git with the SSIS packages
- **Testing difficulty**: Stored procedure logic cannot be unit tested with the same tooling as SSIS packages
- **Debugging complexity**: Failures require checking both SSIS logs AND SQL Server execution logs
- **Deployment coordination**: SSIS package deployment and stored procedure updates must be synchronized
- **No CI/CD for stored procedures**: Database changes require manual DBA deployment

**Future constraints:**
- Any new ETL pipeline must follow the orchestrator pattern (SSIS control flow + T-SQL procedures)
- Stored procedure changes require DBA review and deployment coordination
- Consider Azure Data Factory or dbt for future pipelines if stored procedure maintenance becomes burdensome
- Document all stored procedure dependencies in SSIS package README

## Related ADRs

- ADR-007: SSIS `sa` plaintext credentials (security vulnerability in the same ecosystem)
- ADR-002: Database-per-service (Silver writes to 5 separate microservice databases)
