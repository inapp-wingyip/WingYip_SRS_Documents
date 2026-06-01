# ADR-033. SQL Agent for SSIS Schedule Orchestration

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS ETL pipelines require scheduled execution. The Bronze and Silver layers must run at specific intervals, and SQL Server Agent is the enterprise-standard scheduling mechanism in the on-premise SQL Server environment.

**Current implementation:**
- **SQL Server Agent Jobs**: Schedule SSIS package execution
- **Job steps**: Each job step calls `dtexec` or executes an SSIS package directly
- **Schedules**: Daily at 7 AM for Spaceman, every 7 hours for Product refresh, etc.
- **No external scheduler**: No Jenkins, Airflow, or Cron jobs for ETL scheduling

**Why SQL Agent over alternatives:**
- Already present in SQL Server infrastructure (no additional cost)
- Enterprise operations team familiar with SQL Agent job monitoring
- Native integration with SSIS (can execute packages directly)
- Built-in logging and alerting

## Decision

We use **SQL Server Agent as the sole ETL scheduler**:

1. **SQL Agent Jobs**: Each ETL pipeline has one or more SQL Agent jobs
2. **Job categories**: Bronze jobs, Silver jobs, and master jobs (orchestrators)
3. **Schedules**: Defined in SQL Agent (daily, hourly, or custom intervals)
4. **Execution**: Jobs call `dtexec /ISSERVER` or execute packages from SSISDB catalog
5. **No external scheduler**: Airflow, Prefect, or Jenkins are not used for ETL scheduling

## Consequences

**Positive:**
- Native SQL Server integration — no additional infrastructure
- Operations team familiar with SQL Agent monitoring and troubleshooting
- Built-in retry, notification (email), and history logging
- SSIS packages can be executed from SSISDB catalog with parameter substitution

**Negative:**
- **Tight coupling to SQL Server**: ETL scheduling cannot easily migrate to another database platform
- **No DAG visualization**: Unlike Airflow, SQL Agent provides no visual pipeline dependency graph
- **Limited cross-system orchestration**: SQL Agent cannot easily trigger non-SQL Server workflows
- **No REST API**: Job status and history require SQL queries or SSMS, not HTTP APIs
- **Manual job migration**: Moving jobs between environments (dev → QA → prod) requires manual scripting

**Future constraints:**
- Any migration to cloud (Azure Data Factory, AWS Glue) requires rebuilding scheduling logic
- Job definitions should be scripted (T-SQL create statements) for version control
- Consider SQL Server Management Studio (SSMS) export or `dbatools` PowerShell module for job migration
- If pipeline complexity grows (10+ interdependent steps), evaluate Airflow or Azure Data Factory

## Related ADRs

- ADR-021: SSIS as pure orchestrator (SQL Agent triggers SSIS execution)
- ADR-032: Bronze/Silver medallion (schedules control when each layer runs)
