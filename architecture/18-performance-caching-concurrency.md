# Performance, Caching & Concurrency Standards

> Derived from `drive_raw/Documents/Design/Analysis/Enterprise Stock Replenishment System (SRS) - Technical Architecture Document.docx`, [Service Communication](./04-service-communication.md), [Data Flow](./05-data-flow.md), and `WingYip_SRS_BE_EcoSystem/docs/CRUD.md`.

---

## Caching Strategy

### Principle: Cache Static, Never Cache Live

| Data Type | Cache? | TTL | Storage | Rationale |
|-----------|--------|-----|---------|-----------|
| **Product Name, Description** | YES | 5-15 min | Redis / In-memory | Changes infrequently |
| **Product UOM, Case Size** | YES | 15-30 min | Redis / In-memory | Very stable reference data |
| **Store Configuration** | YES | 30-60 min | Redis | Admin-controlled, slow-changing |
| **Planogram Data** | YES | 5-15 min | Redis / In-memory | Changes on planogram update events |
| **Stock Quantity** | **NEVER** | — | Live fetch only | Must be real-time for replenishment |
| **Location Data** | **NEVER** | — | Live fetch only | Pick accuracy depends on live data |
| **Sales Transactions** | **NEVER** | — | Live fetch only | Drives replenishment decisions |
| **User Permissions** | YES (session) | Session length | In-memory / Redis | Evaluated at login, cached per session |
| **Supplier Data** | YES | 30-60 min | Redis | Changes infrequently |
| **Price Data** | YES (with invalidation) | 5 min | Redis | Invalidation on price change event |

### Cache Invalidation

| Trigger | Mechanism | Scope |
|---------|-----------|-------|
| **Price change** (SAP/OpSuite pipeline) | Event-driven invalidation via RabbitMQ | Product price cache |
| **Planogram status change** | WebSocket + RabbitMQ event | Planogram data cache |
| **Stock adjustment** | Direct DB read (no cache) | N/A |
| **User role change** | Session invalidation | User permission cache |
| **Store config update** | Admin event | Store configuration cache |

### Redis Configuration

| Parameter | Value | Notes |
|-----------|-------|-------|
| Instance | Local Redis (per K8s pod) | Optional centralized Redis for distributed cache |
| Eviction | LRU | Least recently used eviction |
| Max Memory | Configurable per environment | See environment-configuration.md |
| Persistence | RDB snapshots | For cache warm after restart |

---

## BFF (Backend-for-Frontend) Performance

Source: [Service Communication](./04-service-communication.md)

### Problem: N×M API Calls

Displaying aggregated product data (Product + Location + Stock) for ~100 products per page:
- **Without BFF**: 100 products × 2 services = 200+ requests → high latency
- **With BFF**: 3 calls (Product list, SpaceMan batch, Stock batch) → low latency

### Batch API / TVP Pattern

| Approach | Network Calls | Latency | Use Case |
|----------|---------------|---------|----------|
| Client-Side Aggregation | N×M (High) | High | Legacy, avoid |
| **BFF + Batch API/TVP** | **3** | **Low** | **Primary pattern** |
| Precomputed Materialized View | 1 | Very Low | Read-heavy analytics |

**Recommended**: JSON payload from client → BFF → convert to TVP internally for SQL Server batch queries.

---

## Concurrency Control

### Replenishment Group Locking (CR39)

Source: `drive_raw/Documents/Design/Replenishment/LLD - Release Locked Replen Groups.docx`, `drive_raw/Documents/Requirements/WingYip - Storewalk and Sales Replenishment FRD.docx`

| Aspect | Implementation |
|--------|---------------|
| **Lock Mechanism** | Database row lock on ReplenGroup |
| **Lock Acquisition** | SELECT ... WITH (UPDLOCK, ROWLOCK) on group acquire |
| **Lock Duration** | Until pick confirmed, session exit, or crash recovery |
| **Lock Release on Exit** | Explicit unlock on user exit or navigation away |
| **Lock Release on Crash** | Background process detects stale locks and auto-releases |
| **Conflict Notification** | WebSocket real-time notification to second user |
| **Lock Timeout** | Configurable (default: 30 minutes) |
| **Lock Scope** | Single ReplenGroup per user |

### Optimistic Concurrency

| Entity | Mechanism | Field |
|--------|-----------|-------|
| Bay Group | RowVersion | `RowVersion` column (SQL Server timestamp) |
| Store Layout | RowVersion | `RowVersion` column |
| Product | RowVersion | `RowVersion` column |

### Pessimistic Locking

| Entity | Lock Type | Duration |
|--------|-----------|----------|
| Stock Count (PI) | Row lock during count | Transaction scope |
| Replenishment Group | Group lock | Until confirmed/released |
| Replenishment Pick | Pick lock | Until pick confirmed |

---

## Database Performance

### Query Optimization Rules

Source: [Microservices Design](./03-microservices-design.md), `WingYip_SRS_BE_EcoSystem/docs/CRUD.md`

1. **Use Entity Framework Core** — Database-first DbContext, no raw SQL, no stored procedures
2. **Batch via TVP** — JSON array → TVP conversion for multi-record queries
3. **Read replicas for analytics** — Optional per-site read replicas for report queries
4. **Index per query pattern** — Index strategy based on actual query patterns, not theoretical
5. **Avoid N+1** — BFF pattern for aggregated queries
6. **Connection pooling** — SQL Server connection pooling via ADO.NET

### Indexing Strategy

| Table Pattern | Index Type | Columns |
|---------------|-----------|---------|
| Product lookup | Clustered + Non-clustered | ProductID, Name, SKU |
| Stock by location | Non-clustered | StoreID, ProductID, LocationCode |
| Replenishment group | Non-clustered | StoreID, Status, CreatedDate |
| Audit log (time-series) | Clustered + Columnstore | Timestamp, Service, EntityType |
| Transaction (high-volume) | Partitioned | StoreID, TransactionDate |

### Connection Pool

| Parameter | Value (Production) | Notes |
|-----------|-------------------|-------|
| Max Pool Size | 200 | Per service |
| Min Pool Size | 10 | Per service |
| Connection Timeout | 30s | Default |
| Command Timeout | 60s | For long-running queries |

---

## Background Process Performance

Source: `drive_raw/Documents/Design/Background Process/Back Ground and Pipeline Process_.xlsx`

| Process | Frequency | Performance Target |
|---------|-----------|-------------------|
| Sales-Based Replenishment | 15 min | < 30s total cycle |
| Store Walk Detection | 10 sec | < 5s detection |
| Data ETL (Bronze) | Scheduled | < 60 min for full load |
| SEL Price Change Detection | Daily | < 15 min for all stores |

---

## ETL Pipeline Performance

Source: [Data Workflow](../data-engineering/01-data-workflow.md), `drive_raw/Documents/Design/Data Engineering/Silver_Layer_Estimation.xlsx`

| Consideration | Approach |
|---------------|----------|
| **Estimated row counts** | Defined per entity in Silver_Layer_Estimation.xlsx |
| **Migration window** | Tracked per pipeline schedule |
| **Parallelism** | SSIS package-level parallelism for independent pipelines |
| **Batch sizing** | Configurable per pipeline (1000-10000 rows per batch) |
| **Retry policy** | Exponential backoff, configurable max retries |
| **Replay from Bronze** | Full traceability for reprocessing from raw data |

---

## Mobile App Performance

### Response Time Targets

| Screen | Target (p95) | Notes |
|--------|---------------|-------|
| Store Walk List | < 2s | Live data, no cache |
| Product Lookup (barcode) | < 1s | Indexed search |
| Replenishment Group Detail | < 3s | Aggregated data |
| SEL Print (single label) | < 5s | Includes Crystal Reports render |
| Dashboard KPIs | < 3s | Aggregated, may use cached data |

### Offline Capabilities

| Feature | Offline Support | Sync Strategy |
|---------|----------------|----------------|
| Store Walk task list | View cached tasks | Sync on reconnect |
| Product Enquiry (barcode) | Limited (cached products) | Sync periodically |
| Replenishment Picking | Queue pick confirmations | Sync on reconnect |
| Notifications | Queue locally | Push on reconnect |

---

## Load Testing Expectations

| Metric | Target | Notes |
|--------|--------|-------|
| Concurrent users (Web) | 100+ | Office + warehouse |
| Concurrent HHD devices | 50+ | Per store |
| API throughput | 500+ req/s | Peak |
| Database transactions | 1000+ TPS | Peak |
| ETL throughput | 10,000+ rows/min | Per pipeline |

---

## Source Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Documents/Design/Analysis/Enterprise Stock Replenishment System (SRS) - Technical Architecture Document.docx` | Full technical architecture |
| `drive_raw/Documents/Design/Background Process/Back Ground and Pipeline Process_.xlsx` | Background and pipeline processes |
| `drive_raw/Documents/Design/Data Engineering/Silver_Layer_Estimation.xlsx` | Silver layer sizing estimates |
| `drive_raw/Documents/Design/Replenishment/LLD - Release Locked Replen Groups.docx` | Group locking and concurrency |
| `drive_raw/Documents/Requirements/WingYip - Storewalk and Sales Replenishment FRD.docx` | Store walk/sales replenishment FRD |
| `drive_raw/Documents/Requirements/WingYip - Menu list.xlsx` | Application menu, module scope |
| BE repo: `docs/CRUD.md` | CRUD template, architecture rules |

---

## Cross-References

- [Service Communication](./04-service-communication.md) — BFF pattern, TVP, aggregation
- [Data Flow](./05-data-flow.md) — Medallion architecture, ETL performance
- [Microservices Design](./03-microservices-design.md) — Entity Framework Core, database-first, CQRS, service boundaries
- [Database Schema](./08-database-schema.md) — Database per service, entity model
- [Error Handling](./12-error-logging-observability.md) — Retry policies, circuit breaker
- [Integration Contracts](./14-integration-contracts.md) — Source system data sync schedules