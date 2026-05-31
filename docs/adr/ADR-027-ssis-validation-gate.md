# ADR-027. SSIS Validation Gate Pattern — Fail-at-End with Final Aggregation

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS Data Engineering ETL pipelines process data from multiple source systems (SAP, OpSuite, Korber) into the Bronze and Silver layers. Each pipeline may process dozens of tables. A failure in one table should not necessarily abort the entire pipeline — other tables may still need processing. However, the final pipeline status must accurately reflect whether any failures occurred.

**Current implementation:**
- **Bronze packages**: `MaxErrorCount=0` on Foreach Loop containers (continue on individual table errors)
- **Final validation**: `Fail-at-end Validation Gate` at the end of each pipeline
  - Aggregates all individual table errors
  - Fails the entire pipeline if any table failed
  - Sends consolidated failure email with all error details
- **Silver packages**: Same pattern — `MaxErrorCount=0` per table, validation gate at end
- **Logging**: `ETL_Bronze_Pipeline_Log` and `ETL_Bronze_Task_Log` tables capture per-table status

**Example flow:**
1. Start pipeline
2. Discover active tables via `vw_ETL_Active_Tables_To_Run`
3. For each table: execute stored procedure, log success/failure
4. After all tables: validation gate counts total errors
5. If errors > 0: send failure email, mark pipeline failed
6. If errors = 0: send success email, mark pipeline succeeded

## Decision

We use a **fail-at-end validation gate pattern**:

1. **Continue on individual errors**: Each table's stored procedure failure does not abort the pipeline
2. **Aggregate at pipeline end**: Final task counts all failures across all tables
3. **Single email**: One consolidated email per pipeline run (not per table)
4. **Pipeline log**: Central table records pipeline start/end time, total tables, failed tables

## Consequences

**Positive:**
- One table failure does not prevent other tables from being processed
- Consolidated error reporting (single email with all issues)
- Pipeline log provides historical view of data quality trends
- Allows partial data availability (some tables updated even if others fail)

**Negative:**
- **Data inconsistency window**: Some tables updated, others not — downstream consumers see inconsistent state
- **Complex debugging**: Must check both pipeline log AND individual task logs to find root cause
- **No automatic retry**: Failed tables are not automatically retried in the same pipeline run
- **Silver layer may process stale Bronze data**: If Bronze table fails but pipeline continues, Silver may read old data
- **Email-only alerting**: No integration with monitoring/alerting system (PagerDuty, Slack, etc.)

**Future constraints:**
- Consider per-table retry logic within pipeline (3 attempts with backoff)
- Evaluate circuit breaker for consistently failing source systems
- Add webhook/SMS alerting for critical table failures
- Document which tables are "critical" (pipeline must fail immediately) vs "best-effort"

## Related ADRs

- ADR-021: SSIS as pure orchestrator (this pattern relies on SSIS control flow)
- ADR-007: SSIS plaintext credentials (same security concerns apply)
