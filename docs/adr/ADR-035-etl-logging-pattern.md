# ADR-035. ETL Logging Pattern — Bronze Pipeline and Task Logs

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS ETL pipelines process data from multiple source systems into microservice databases. When failures occur, operations teams need visibility into which tables failed, which stored procedures errored, and what the error messages were.

**Current implementation:**
- **Bronze Pipeline Log**: `ETL_Bronze_Pipeline_Log` table tracks each SSIS package execution
- **Bronze Task Log**: `ETL_Bronze_Task_Log` table tracks each individual table/stored procedure execution within a pipeline
- **Columns**: Run_ID, Package_Name, Task_Name, Start_Time, End_Time, Status (Success/Failed), Error_Message, Row_Count
- **SSIS event handlers**: OnError, OnWarning, OnInformation events write to these tables
- **No Silver layer equivalent logging**: Silver layer does not have equivalent structured logging tables

**Why custom logging over SSIS built-in logging:**
- SSIS built-in logging is verbose and stores data in `sysssislog` — hard to query for business-specific fields
- Custom tables allow Run_ID correlation across all tasks in a single execution
- Row counts per task provide data quality monitoring

## Decision

We use a **custom ETL logging pattern** with two log tables:

1. **Pipeline Log**: One row per SSIS package execution (master record)
2. **Task Log**: One row per individual table/stored procedure execution (child records)
3. **Run_ID correlation**: All tasks in a single pipeline share the same Run_ID
4. **SSIS event handlers**: OnError and OnPreExecute/OnPostExecute events trigger `sp_Log_ETL_Execution` stored procedure
5. **Fail-at-end**: `MaxErrorCount=0` allows all tasks to attempt execution; validation gate checks logs at end

## Consequences

**Positive:**
- Correlated logging via Run_ID enables full pipeline traceability
- Row count tracking provides early warning for data quality issues
- Task-level granularity pinpoints exactly which table/procedure failed
- Custom schema is easier for operations dashboards than `sysssislog`

**Negative:**
- **Silver layer has no equivalent logging**: Silver transformation errors are harder to trace
- **Logging stored procedures must not fail**: If `sp_Log_ETL_Execution` fails, the actual error is lost
- **Log table growth**: Without retention policy, log tables grow indefinitely
- **No automated alerting**: Operations must manually query logs or rely on SSIS email notifications
- **MaxErrorCount=0 means silent failures**: A task can fail and the package still shows "Success" until the validation gate catches it

**Future constraints:**
- Add Silver layer equivalent logging (`ETL_Silver_Task_Log`) for complete pipeline visibility
- Implement log retention policy (e.g., 90 days for task logs, 1 year for pipeline logs)
- Add automated alerting (email/Teams webhook) when any task fails
- Consider ELK stack integration for centralized ETL log aggregation

## Related ADRs

- ADR-021: SSIS as pure orchestrator (event handlers trigger logging)
- ADR-032: Bronze/Silver medallion (Bronze has logging, Silver does not)
- ADR-027: SSIS validation gate (reads Bronze logs to determine overall success)
