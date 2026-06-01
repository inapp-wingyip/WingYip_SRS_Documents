# ADR-037. Distributed Transaction Coordinator (MSDTC) in ETL

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS ETL pipelines (SSIS packages) read from source systems and write to multiple target databases (5 microservice databases + staging). When a package must ensure consistency across multiple database connections, transaction support is required.

**Current implementation:**
- **MSDTC enabled**: Microsoft Distributed Transaction Coordinator is configured on the SQL Server hosting SSIS
- **TransactionOption=Required**: Some SSIS containers and tasks require distributed transactions
- **Multi-database writes**: Bronze ingestion may write to staging database and log database in the same transaction
- **XA transactions**: Not used (Microsoft-specific DTC only)

**Why MSDTC over local transactions:**
- SSIS packages touch multiple database connections (source → staging → target → log)
- Local transactions (single connection) cannot span multiple SQL Server instances
- MSDTC provides atomicity across multiple connections

## Decision

We use **MSDTC (Distributed Transaction Coordinator)** for multi-database ETL transactions:

1. **MSDTC service**: Enabled and configured on SSIS execution servers
2. **TransactionOption**: Set to `Required` on containers that span multiple connections
3. **Scope**: Used only when a single logical operation writes to multiple databases
4. **No XA transactions**: Only Microsoft DTC — no heterogeneous transaction managers
5. **Fallback**: If MSDTC is unavailable, packages degrade to connection-level transactions (risk of partial writes)

## Consequences

**Positive:**
- Atomic operations across multiple databases (all-or-nothing writes)
- Prevents partial data corruption if a downstream write fails
- Native Microsoft technology — no third-party dependencies

**Negative:**
- **MSDTC is complex to configure and troubleshoot**: Firewall rules, port configuration, and service dependencies
- **Performance overhead**: Distributed transactions are significantly slower than local transactions
- **Single point of failure**: If MSDTC service crashes, all distributed transactions fail
- **No cross-platform support**: Cannot participate in transactions with non-Microsoft databases (PostgreSQL, MySQL)
- **Debugging difficulty**: MSDTC errors are cryptic (`MSDTC unavailable`, `transaction aborted`, `network access denied`)
- **Firewall requirements**: MSDTC requires specific port ranges open between servers

**Future constraints:**
- Minimize MSDTC usage — prefer single-database operations where possible
- Document MSDTC configuration for new environment setup
- Consider sagas/compensating transactions as alternative to MSDTC for new pipelines
- If cloud migration occurs, evaluate Azure SQL elastic transactions or Cosmos DB transactions

## Related ADRs

- ADR-021: SSIS as pure orchestrator (MSDTC is part of SSIS transaction configuration)
- ADR-002: Database-per-service (5 target databases increase MSDTC necessity)
