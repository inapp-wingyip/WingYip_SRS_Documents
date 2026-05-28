# Key Low-Level Design Summaries

Selected LLDs with significant architectural and design patterns.

---

## Centralized Logging & Monitoring

### Architecture Flow
```
Client Request → ErrorHandlingMiddleware → Controller/Action
                         │
                    try-catch wrap
                         │
                    ┌────▼────┐
                    │ Exception│
                    └────┬────┘
                         │
                    Serilog/ILogger
                    (JSON formatted, enriched)
                         │
                    Logstash Sink
                    (parse fields, add env metadata)
                         │
                    Elasticsearch
                    (index, store with searchable fields)
                         │
                    Kibana Dashboards
                    (error trends, most frequent exceptions, alerts)
```

### Key Components
- **ErrorHandlingMiddleware**: First in ASP.NET Core pipeline, wraps all downstream processing with try-catch
- **Serilog**: Structured JSON logging with enrichment — correlationId, timestamp, user, path, level
- **Logstash**: Receives JSON, parses fields, enriches with environment and application name
- **Elasticsearch**: Indexed logs with field-level searchability
- **Kibana**: Dashboards for error trends over time, most frequent exceptions, alerting

### Requirements
- Correlation ID propagation across all services
- No log loss if Logstash/Elasticsearch unavailable — buffering or retry mechanism
- Sensitive data masking/anonymization in logs
- Detailed error analytics for monitoring dashboards

---

## Bulk Replenishment (Pallet)

### Key Architecture Decisions
- **Pick Group** as operational unit — one or more aisles, both sides
- **Fill Quantity** (MaxQtyCases) and **Trigger Quantity** (Threshold) configured per location
- Cumulative case depletion tracking — till sales AND case replenishment both count
- Drop + Put-Away handled in single Customer Warehouse user flow in SRS
- All scanning and confirmations logged

### Mobile Enhancements
- Scan button for direct workflow entry (CR25)
- Unified scan action as single entry point
- Quantity entry validation during replenishment
- "Details" renamed to "Pallets" on mobile
- Move Product to TRANS/RECV location (CR41):
  - Product info display
  - Last known location validation (prefix + numeric format)
  - Case quantity validation

---

## Replenishment Module — General

### Replenishment Group Structure
- Consecutive bays (one side of aisle), typically 6-7 bays
- Associated with temperature zone: A/C/F
- Naming: `<Aisle><ZoneCode><StartBay><EndBay>` (e.g., `08A3139`)
- Zone Codes: A = Ambient, C = Chilled/Fresh, F = Frozen
- Stored as: Store → Aisle → Bay → ReplenGrp

### Picking Workflow States
| State | Description |
|-------|-------------|
| **Not Started** | Pick list displayed, Total Cases/SKUs shown, picker selects group |
| **In Progress** | Group locked, sequential product picking, progress tracked in minutes |
| **Completed** | All products picked or skipped, statistics logged |

### Concurrency Control
- ReplenGroup locked when user starts pick
- Other users blocked from same group
- Appropriate message shown on conflict
- Lock released on completion or timeout
- Locking mechanism with exit handling (CR39)

### StoreWalk Group (CR35)
- Dedicated group configuration for store walk operations
- Manage Group Configuration provides UI for mapping

### Auto Refresh (CR37)
- Configurable refresh frequency for replenishment lists
- Real-time visibility updates

### Color Coding (CR38)
- Green: Good stock
- Amber: Low stock warning
- Red: Critical / No stock
- Applied at ReplenGroup and product level

---

## Store Walk

### Workflows

| Workflow | Trigger | Action |
|----------|---------|--------|
| Low Stock | Product below threshold | Replenishment task created |
| No Stock | Product empty on shelf | Urgent replenishment task |
| Temp OOS | User marks product as temporarily unavailable | Status flag set |
| Spillage | User reports spill/breakage | Cleaner task dispatched |
| Housekeeping | Scheduled or ad-hoc | Task created with user identification (CR16) |

### Low/No Stock Calculation (CR23)
- Based on Fill (display quantity per product face) and Face (number of shelf facings)
- Calculation determines actual shelf capacity vs current stock
- Automated replenishment trigger when threshold crossed

---

## Planogram

### Workflow States
```
Draft → Pending → Approved → Reviewed → Planned → Implemented
  ↑                                                    │
  └────────────────── Recalled ←───────────────────────┘
```

### States Detail
| State | Description |
|-------|-------------|
| Draft | Created by SOCO/CatMan; editable, not visible to stores |
| Pending | Submitted for review and approval |
| Approved / Published | Approved by CatMan/senior peer; visible to StoreOps |
| Reviewed | Reviewed by Store Manager; comments logged |
| Planned | StoreOps schedules implementation |
| Implemented | Execution confirmed by store |
| Recalled | Plan withdrawn by CatMan (pre or post publication) |

### v3.0 Enhancements
- Archive process for lifecycle management
- Rejection validation — structural inconsistencies → **Rejected** status
- Peer review and publishing workflow
- RBAC for planogram publishing
- 53-week financial year support
- Multiple planograms permitted in same week
- Fill face requirement mandatory for Didi stores (CR30)
- Default fill value applied during product picking
- Mandatory comments required for planogram commit
- Copy full store planogram to new planogram (CR47)
- Bay update propagation across Didi stores (CR48)
- Product search by description in Add Product popup (CR46)

---

## Didi Store — Daily Process

### Scheduled Replenishment
- Automated daily replenishment orders from parent superstore or central warehouse
- Temperature-based segregation (Ambient/Chill/Frozen)
- Supply chain configuration per Didi store

### Emergency Replenishment
- Manual order placement by Didi store staff
- Product identification → confirmation → submission workflow
- Source store selection
- Order review and cancellation capability

### Waste & Contingency
- Spoilage tracking
- Contingency reporting
- Waste reduction analytics

### Admin Configuration
- Products Not Replenished from Customer Warehouse
- Shop Floor Picks Configuration
- Hot Food Products maintenance
- GNFR Items and GNFR Uniforms management

---

## WebSocket Implementation

- WebSocket for real-time communication within private network
- Task status updates for handheld devices during planogram/replenishment
- Progress indicators for long-running operations
- Internal communication only — no external endpoints

---

## Finance

- Customer-Type by Week Report for financial analysis
- Store-level financial reconciliation
- SAP integration for financial data alignment
