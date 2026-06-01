# ADR-039. Source Schema Discovery via Dynamic SQL

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS ETL pipelines ingest data from multiple source systems (SAP, OpSuite, Korber) that may change their schemas over time (new columns, renamed tables). Hardcoding source table schemas in SSIS packages would require package modification for every schema change.

**Current implementation:**
- **Dynamic SQL**: Source system stored procedures use dynamic SQL to discover available columns
- **Column mapping**: Source columns mapped to target columns via metadata tables or `CASE` statements in stored procedures
- **Flexible ingestion**: Bronze packages can ingest tables even if columns are added/removed
- **Schema drift handling**: If a source column disappears, the stored procedure handles it gracefully (NULL or default value)

**Why dynamic discovery over static mapping:**
- Source systems evolve independently of ETL development cycles
- Reduces deployment frequency for schema changes
- Allows ingestion of tables with varying structures

## Decision

We use **dynamic SQL for source schema discovery** in ETL stored procedures:

1. **Dynamic column discovery**: Stored procedures query `INFORMATION_SCHEMA.COLUMNS` or source system metadata
2. **Flexible column mapping**: Source columns mapped to target via dynamic `INSERT ... SELECT` or metadata-driven transformation
3. **Graceful degradation**: Missing source columns result in NULL/default values in target
4. **New column handling**: New source columns are ignored unless explicitly mapped (prevents breaking changes)
5. **No SSIS metadata refresh**: Packages do not require redeployment for source schema changes

## Consequences

**Positive:**
- Reduced ETL maintenance when source systems add/remove columns
- Same SSIS package handles schema evolution without modification
- Faster response to source system changes (no package redeployment needed)

**Negative:**
- **SQL injection risk**: Dynamic SQL in stored procedures must be carefully parameterized
- **Performance cost**: Dynamic SQL cannot be pre-compiled or optimized by the query planner
- **Debugging difficulty**: Dynamic SQL errors (e.g., column not found) occur at runtime, not compile time
- **No type safety**: Column data types are not validated at build time
- **Hidden coupling**: Source schema changes may silently break downstream Silver transformations
- **Code complexity**: Dynamic SQL is harder to read and maintain than static SQL

**Future constraints:**
- All dynamic SQL must use parameterized queries (no string concatenation of user input)
- Document which stored procedures use dynamic SQL and why
- Add schema validation step before ingestion (compare discovered schema against expected schema)
- Consider schema registry (e.g., Avro, Protobuf) if source systems adopt contract-based APIs

## Related ADRs

- ADR-021: SSIS as pure orchestrator (dynamic SQL lives in stored procedures)
- ADR-032: Bronze/Silver medallion (dynamic discovery in Bronze layer)
