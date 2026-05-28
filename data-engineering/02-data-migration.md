# Data Migration Strategy

---

## Overview

The Data Migration Design Document outlines the approach, scope, design, and governance model for migrating data from existing source systems (**SAP**, **Korber WMS**, **OpSuite**) to the SRS target platform. The objective is secure, accurate, and controlled migration with minimal disruption to business operations.

### Key Highlights
- Clearly defined migration scope and responsibilities
- Robust data validation and reconciliation approach
- Secure and compliant handling of sensitive data
- Structured cutover and rollback strategy

---

## Business Context & Objectives

### Objectives
- Migrate agreed data domains accurately and completely
- Maintain data integrity and business continuity during transition
- Enable the target SRS platform to be production-ready at go-live

### Success Criteria
- 100% completion of in-scope data migration
- Business validation sign-off with agreed tolerance limits
- No critical post go-live data defects

---

## Scope of Migration

### In Scope
- Data domains: Product master, pricing, stock, sales history (negotiated per phase)
- Data types: Master, Reference, Transactional
- Historical data range: Defined per business need

### Out of Scope
- Data domains not agreed for migration
- Non-operational historical data beyond agreed range

### Assumptions & Dependencies
- Source system access provided as per agreed timelines
- Target schema frozen prior to migration start
- Business SMEs available for validation and sign-off at each stage

---

## Systems Overview

### Source Systems
| System | Type | Purpose | Integration |
|--------|------|---------|-------------|
| SAP | Application (SQL Server) | Product master, pricing, suppliers | SQL Server Native Client |
| Korber WMS | Application (SQL Server) | Warehouse stock, logistics | SQL Server Native Client |
| OpSuite | Application (SQL Server) | ePOS, sales transactions | SQL Server Native Client |

### Target System
- SRS platform (ASP.NET Core / SQL Server)
- Domain-oriented data model
- Security and access controls per RBAC

---

## Migration Strategy

### Overall Approach
- **Type**: Big-bang or Phased (finalized per store rollout)
- **Execution**: Initial full load followed by incremental delta updates (if applicable)

### Data Sequencing (Strict Order)
1. **Reference data** — codes, types, statuses, configuration values
2. **Master data** — products, stores, warehouses, suppliers, users
3. **Transactional data** — sales history, stock movements, historical transactions

### Cutover Strategy
1. Data freeze window established (source systems in read-only or paused state)
2. Final delta load executed (catch-up for transactions during freeze window)
3. Validation checkpoints at each layer (Bronze → Silver → Gold)
4. Business sign-off before production go-live

### Rollback Strategy
- Defined conditions triggering rollback (data quality thresholds, count mismatches)
- Restoration approach: restore from backup or revert to source system
- Communication plan: stakeholders notified of rollback decision

---

## Data Mapping & Transformation

### Mapping Overview
- Detailed field-level mappings maintained in separate mapping workbook
- Referenced from migration design document
- Covers all in-scope entities

### Design Decisions
- Data selection criteria per domain
- Mapping transformations (direct, derived, calculated)
- Data quality rules applied at extraction

### Transformation Rules
- Data standardization — dates (ISO format), currency, numeric formats
- Code and status mappings — legacy codes → SRS codes
- Derived and calculated fields — composite keys, computed values

### Data Quality Rules
- Mandatory field validation — no nulls in required columns
- Uniqueness — deduplication based on business keys
- Referential integrity — foreign key validation across entities
- Duplicate handling — first-wins, last-wins, or merge strategy per entity

---

## Data Volumes & Performance
- Estimated record counts per entity (defined in estimation spreadsheet)
- Migration window and expected runtimes calculated per table
- Parallelism approach — multiple tables processed simultaneously where dependencies allow
- Batch sizing — large tables split into manageable chunks

---

## Security & Compliance
- Data classification and sensitivity marking per domain
- Encryption in transit (TLS 1.3) and at rest (SQL Server TDE)
- Masking or anonymization in non-production environments (Development, Test, UAT)
- Compliance with applicable data protection regulations

---

## Validation & Reconciliation

### Validation Levels
| Level | Method | Description |
|-------|--------|-------------|
| Technical Validation | Counts, schema checks | Row counts, column types, null checks |
| Data Integrity | Referential integrity, uniqueness | FK validation, duplicate detection |
| Business Validation | Sample-based, control totals | Key metrics comparison, SME spot-checks |

### Reconciliation Approach
- Source vs target record counts per entity
- Control totals and key metrics (sums, averages) compared
- Sample-based business validation with WingYip SMEs

### Acceptance Criteria
- Defined tolerance thresholds per entity type
- Formal sign-off process with business stakeholders

---

## Error Handling & Recovery
- Error categorization by severity — Critical (blocking), Warning (non-blocking), Info
- Reprocessing strategy — failed records re-extracted from source and re-processed
- Issue tracking and resolution workflow — issues logged, assigned, resolved, verified

---

## Monitoring & Reporting
- Migration execution dashboards for real-time progress
- Daily status reporting to project stakeholders
- Issue and resolution tracking with metrics

---

## Testing & UAT Support
- Test environments with production-representative data volumes
- Dry runs to validate timing and performance estimates
- UAT scripts and test scenarios for business validation
- Issue tracking and resolution during UAT phase
