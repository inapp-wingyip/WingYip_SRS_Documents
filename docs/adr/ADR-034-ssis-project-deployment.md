# ADR-034. SSIS Project Deployment Model to SSISDB

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS ETL packages (11 packages) must be deployed and executed in the production environment. SSIS supports two deployment models: Package Deployment (legacy, file-based) and Project Deployment (modern, SSISDB catalog-based).

**Current implementation:**
- **Project Deployment Model**: All 11 packages deployed to `SSISDB` catalog
- **Environment configurations**: SQL Server environment variables map to SSIS parameters
- **Versioning**: SSISDB maintains execution history and package versions
- **Security**: Windows Authentication or SQL Authentication for SSISDB access

**Why Project Deployment over Package Deployment:**
- SSISDB provides centralized package storage, logging, and versioning
- Environment-specific parameters (connection strings, file paths) managed outside packages
- Built-in execution reports and performance monitoring

## Decision

We use the **SSIS Project Deployment Model with SSISDB catalog**:

1. **SSISDB catalog**: All packages deployed to SQL Server SSISDB
2. **Environment variables**: Connection strings, source system credentials, and file paths configured as environment variables
3. **Package parameters**: Packages accept parameters for database names, schema names, and run identifiers
4. **Execution via catalog**: SQL Agent jobs call `SSISDB.catalog.create_execution` and `start_execution`
5. **No Package Deployment Model**: `.dtsx` files are not executed from file system directly

## Consequences

**Positive:**
- Centralized package management with versioning and rollback
- Built-in execution logging and performance reports
- Environment variables allow same package to run in dev/QA/prod without modification
- SSISDB security model integrates with SQL Server roles and permissions

**Negative:**
- **SSISDB is a SQL Server feature**: Cannot deploy to non-SQL Server environments
- **Deployment requires DBA involvement**: Creating environments and mapping variables requires elevated permissions
- **Version control gap**: SSISDB stores package versions but the canonical source is still Visual Studio/SSDT `.ispac` files
- **No CI/CD integration**: Deploying to SSISDB from Jenkins requires custom scripts (`ispac` deployment)
- **Backup dependency**: SSISDB must be backed up alongside user databases

**Future constraints:**
- Any migration to cloud ETL (Azure Data Factory, AWS Glue) requires abandoning SSISDB
- Deployment scripts should be automated (PowerShell `DeployProjectToCatalog` or `dbatools`)
- Environment variable values should be documented and version-controlled (even if actual values are secrets)
- Consider SSIS package source control integration (Git + SSDT BiMS)

## Related ADRs

- ADR-021: SSIS as pure orchestrator (packages live in SSISDB)
- ADR-033: SQL Agent scheduling (triggers SSISDB package execution)
