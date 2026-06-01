# Admin, SOCO & Common Services — LLD Detail

> Derived from `drive/Documents/Design/Admin Menu/`, `drive/Documents/Design/SOCO/`, `drive/Documents/Design/Common Libraries/`, `drive/Documents/Design/Maintenance & Cleaning/`, and `drive/Documents/Design/Notifications/`.

---

## Admin Menu LLDs

### Source: `drive/Documents/Design/Admin Menu/`

| Document | Description |
|----------|-------------|
| LLD - Other Store Admin & Didi Store Admin Menu.docx | Admin menu for other stores and Didi stores |
| Edit Fill Face.docx | Fill/Face editing functionality |
| SKU Diagnostics.docx | SKU diagnostic tool (also available in Didi) |
| Store Configurations.docx | Store configuration settings |

### Admin Menu Functions
- **Store Configuration**: Per-store settings (printer, GNFR, operational params)
- **Edit Fill Face**: Modify Fill and Face values for products (drives replenishment calculation per CR23)
- **SKU Diagnostics**: Per-SKU analysis — sales velocity, stock level, replenishment frequency, action recommendations
- **Didi Store Admin**: Dedicated admin for Didi store operations (products not replenished, shop floor picks, hot food, GNFR items/uniforms)

---

## SOCO LLD

### Source: `drive/Documents/Design/SOCO/`

| Document | Description |
|----------|-------------|
| LLD - Stock Control.docx (SOCO) | SOCO stock control integration |

### SOCO Role in Stock Control
- SOCO receives discrepancy notifications from Store Walk and Pick Location checks
- SOCO dashboard (web-only) provides:
  - Temporary OOS label management
  - SAP daily schedule review
  - Discontinued line checks
  - Cross-store overstock monitoring
  - Promotions management
- SOCO action tracked with product selection logic and scenario handling
- Reports: Date Check Follow-Up (daily), Operational Performance

---

## Common Libraries

### Source: `drive/Documents/Design/Common Libraries/`

| Document | Description |
|----------|-------------|
| Centralized Auditing.docx | Centralized audit logging library |
| Centralized Logging.docx | Centralized logging library (Serilog stack) |

### Centralized Auditing Library
- **Purpose**: Immutable audit trail across all microservices
- **Pattern**: Audit entries published via RabbitMQ, consumed by Audit Service
- **Captures**: UserID, Action, Timestamp, Module, AffectedRecord, OldValue, NewValue
- **Usage**: Injected into services via shared library — no per-service audit implementation

### Centralized Logging Library
- **Stack**: Serilog → Logstash → Elasticsearch → Kibana
- **Enrichment**: CorrelationId, Environment, Service Name, User, Path
- **Format**: Structured JSON for searchability
- **Error Handling**: ErrorHandlingMiddleware wraps all downstream with try-catch
- **Buffering**: Retry mechanism if Logstash/Elasticsearch unavailable
- **Masking**: Sensitive data anonymized in log output

---

## Maintenance & Cleaning Module

### Source: `drive/Documents/Design/Maintenance & Cleaning/`

| Document | Description |
|----------|-------------|
| LLD - Maintenance & Cleaning.docx | Maintenance and cleaning module design |

### Scope
- Housekeeping workflows (also tracked in Store Walk)
- Cleaning task management and scheduling
- Spillage/breakage cleanup tracking
- User identification for task completion (CR16)
- Integration with Store Walk module for task creation

### Implementation Notes
- BE_EcoSystem has HouseKeeping implementation documentation: `docs/HouseKeeping.md` and `docs/HouseKeeping_implementation_documentation.md`
- Legacy HouseKeeping module: `WingYip_Legacy/WingYip_StockReplenishmentSystem/` (ASP.NET MVC)
- Issues identified: Thread safety violations with shared DbContext, multiple SaveChanges in loops

---

## Notifications Configuration

### Source: `drive/Documents/Design/Notifications/`

| Document | Description |
|----------|-------------|
| WingYip - Notifications.xlsx | Notification type and configuration spreadsheet |
| Copy of WingYip - Notifications.xlsx | Duplicate |

### Notification Categories

| Type | Description | Delivery |
|------|-------------|----------|
| **Messages** | Inter-user communication | Web + Mobile |
| **Notifications** | System-generated updates with visibility rules | Web + Mobile |
| **Alerts** | Priority notifications with ownership and escalation | Mobile (primary) + Web |

### Alert Flow
1. Alert triggered by system event (low stock, discrepancy, pipeline failure)
2. Visibility set by role/scope (RBAC)
3. Ownership assigned to responsible role
4. Escalation logic based on time thresholds and severity
5. Resolution tracking with full audit

---

## Cross-References

- [Key LLD Summaries](./02-key-llds.md) — High-level LLD overview
- `Functional Modules — Admin` — Business rules
- `Functional Modules — SOCO` — Business rules
- `Functional Modules — Notifications` — Business rules
- [Authentication & RBAC](../architecture/06-authentication-rbac.md) — RBAC engine
- [Database Schema](../architecture/08-database-schema.md) — Audit/Logging schema