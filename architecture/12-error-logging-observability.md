# Error Handling, Logging & Observability

> Derived from `drive_raw/Documents/Design/Common Libraries/Centralized Auditing.docx`, `drive_raw/Documents/Design/Common Libraries/Centralized Logging.docx`, `drive_raw/Documents/Design/Foundations/LLD - Centralized Logging & Monitoring.docx`, and `drive_raw/Documents/Design/Analysis/Enterprise Stock Replenishment System (SRS) - Technical Architecture Document.docx`.

---

## Architecture Overview

The SRS implements a **centralized observability stack** using Serilog for structured logging, SQL Server for audit persistence, and an ELK Stack (Elasticsearch, Logstash, Kibana) for operational monitoring. All services publish logs and audit events through a shared library pattern.

```
┌─────────────────────────────────────────────────────────┐
│                    Microservices                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │ Admin    │ │ Replen   │ │ Product  │ │ Print    │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘   │
│       │             │             │             │         │
│  ┌────▼─────────────▼─────────────▼─────────────▼────┐  │
│  │          Centralized Logging Library               │  │
│  │     (WingYip.SRS.Common.Logging)                  │  │
│  │  • Serilog configuration                          │  │
│  │  • Structured logging enrichment                  │  │
│  │  • Audit event formatting                         │  │
│  └────────┬──────────────────┬───────────────────────┘  │
│           │                  │                           │
│  ┌────────▼──────┐  ┌──────▼─────────┐                 │
│  │ SQL Server     │  │ ELK Stack      │                 │
│  │ (Audit DB)     │  │ (Elasticsearch │                 │
│  │                │  │  + Logstash    │                 │
│  │                │  │  + Kibana)     │                 │
│  └────────────────┘  └────────────────┘                 │
└─────────────────────────────────────────────────────────┘
```

---

## Logging Architecture

### Serilog Configuration

Source: `drive_raw/Documents/Design/Foundations/LLD - Centralized Logging & Monitoring.docx`

| Sink | Purpose | Retention |
|------|---------|-----------|
| **SQL Server** | Structured logs + audit trail | Per retention policy |
| **Elasticsearch** | Searchable, aggregatable logs | 30 days hot, 90 days warm |
| **Console** | Development debugging | Session |
| **File** | Local fallback, startup logs | 7 days rolling |

### Structured Log Format

```json
{
  "Timestamp": "2026-01-15T10:30:00.000Z",
  "Level": "Information",
  "Service": "WingYip.SRS.Replenishment",
  "CorrelationId": "guid-value",
  "UserId": "CROWN123",
  "StoreId": 1,
  "Action": "CreateReplenGroup",
  "EntityType": "ReplenGroup",
  "EntityId": 42,
  "Message": "ReplenGroup created successfully",
  "Properties": { "GroupName": "Aisle-1-Cold", "StoreId": 1 }
}
```

### Log Levels

| Level | When to Use | Example |
|-------|------------|---------|
| **Critical** | Application crash, data corruption | Database connection failure, unrecoverable state |
| **Error** | Operation failed, needs attention | External service timeout, validation failure |
| **Warning** | Recoverable issue, degraded state | Retry succeeded, approaching threshold |
| **Information** | Business operation completed | User created, replen group processed |
| **Debug** | Development-time diagnostic | Query execution details, middleware tracing |
| **Verbose** | Very detailed tracing | Full request/response bodies (dev only) |

### Enrichment Properties

All log events MUST include:
- `Service` — Source microservice name
- `CorrelationId` — Request correlation across services
- `UserId` / `CrownId` — Authenticated user
- `StoreId` — Current store context
- `MachineName` — Server identifier

---

## Centralized Auditing

Source: `drive_raw/Documents/Design/Common Libraries/Centralized Auditing.docx`

### Audit Event Model

| Field | Type | Description |
|-------|------|-------------|
| AuditId | GUID | Unique audit event ID |
| Timestamp | DATETIME2 | UTC timestamp |
| Service | string | Source microservice |
| UserId | string | CrownId of user |
| Action | string | CRUD action (Create/Read/Update/Delete) |
| EntityType | string | Domain entity type |
| EntityId | string | Primary key of affected entity |
| OldValue | JSON | Previous state (for updates) |
| NewValue | JSON | New state (for creates/updates) |
| CorrelationId | GUID | Cross-service correlation |
| IPAddress | string | Client IP address |
| UserAgent | string | Client user agent |

### Audit Rules

1. **All write operations MUST produce an audit event** — Create, Update, Delete
2. **Audit events are published via RabbitMQ** — Decoupled from business logic
3. **Audit Service is the single writer** — Only the Audit microservice writes to the audit database
4. **Old/New values captured for updates** — Enables change tracking and rollback
5. **Read operations are NOT audited by default** — Only audit reads for sensitive modules (User Management, Finance)
6. **RabbitMQ message format** — JSON with enrichment headers for CorrelationId, UserId

### Audit Storage

- **Primary**: `WingYip.SRS.Audit` database (SQL Server)
- **Retention**: Minimum 7 years (regulatory requirement for financial audits)
- **Indexes**: Service, EntityType, EntityId, UserId, Timestamp

---

## Error Handling Patterns

### Exception Handling Strategy

| Pattern | Use Case | Example |
|---------|----------|---------|
| **Global Exception Middleware** | Catch-all unhandled exceptions | `ExceptionHandlerMiddleware` in ASP.NET Core pipeline |
| **Domain Exceptions** | Business rule violations | `ReplenGroupLockedException`, `InsufficientStockException` |
| **Validation Exceptions** | Input validation failures | `FluentValidation` integration with MediatR pipeline |
| **Integration Exceptions** | External service failures | `SAPIntegrationException`, `OpSuiteTimeoutException` |

### Error Response Format

```json
{
  "success": false,
  "message": "Replen group is currently locked by another user",
  "errors": [
    {
      "code": "RESOURCE_LOCKED",
      "field": "ReplenGroupId",
      "message": "Replen group RG-001 is locked by CROWN456"
    }
  ],
  "correlationId": "guid-value"
}
```

### Error Codes Convention

| Prefix | Domain | Example |
|--------|--------|---------|
| `VAL_` | Validation | `VAL_INVALID_INPUT`, `VAL_MISSING_REQUIRED` |
| `AUTH_` | Authentication | `AUTH_INVALID_TOKEN`, `AUTH_EXPIRED_SESSION` |
| `RBAC_` | Authorization | `RBAC_NO_ACCESS`, `RBAC_INSUFFICIENT_PRIVILEGE` |
| `BIZ_` | Business Rule | `BIZ_LOCKED_RESOURCE`, `BIZ_DUPLICATE_ENTITY` |
| `INT_` | Integration | `INT_SAP_TIMEOUT`, `INT_KORBER_UNAVAILABLE` |
| `SYS_` | System | `SYS_DATABASE_ERROR`, `SYS_UNHANDLED_EXCEPTION` |

### Retry Policy

Source: Technical Architecture Document

| Strategy | Implementation |
|----------|----------------|
| **Exponential Backoff** | Configurable retry count with increasing delay |
| **Circuit Breaker** | Break circuit after N consecutive failures |
| **Dead Letter Queue** | RabbitMQ DLQ for messages that exceed retry limit |
| **Idempotency** | All write operations are idempotent with correlation IDs |

---

## Monitoring & Observability

Source: `drive_raw/Documents/Design/Foundations/LLD - Centralized Logging & Monitoring.docx`

### Monitoring Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Metrics** | Prometheus + Grafana | Service health, response times, error rates |
| **Logging** | ELK Stack (self-hosted) | Centralized, searchable log aggregation |
| **APM** | Application Insights (self-hosted alternative) | Application performance monitoring |
| **Network** | Nagios / PRTG | Network and infrastructure monitoring |
| **Dashboard** | Custom ASP.NET Core + Chart.js/D3.js | Operational KPIs for SOCO/Store Manager |

### Health Check Endpoints

Every microservice MUST expose:
- `GET /health` — Overall service health (returns 200 or 503)
- `GET /health/ready` — Readiness probe for K8s (dependencies checked)

### Key Metrics

| Metric | Purpose | Alert Threshold |
|--------|---------|-----------------|
| Request Rate | Traffic volume | > 2x baseline |
| Response Time (p95) | Latency | > 5 seconds |
| Error Rate | Reliability | > 5% |
| CPU/Memory | Resource usage | > 80% sustained |
| Queue Depth | RabbitMQ backlog | > 10,000 messages |
| DB Connection Pool | Database health | > 80% utilization |

### Alerting Channels

| Severity | Channel | Response Time |
|----------|---------|---------------|
| Critical | Email + Dashboard + Pager | Immediate |
| High | Email + Dashboard | < 15 minutes |
| Medium | Dashboard | < 1 hour |
| Low | Dashboard | < 1 business day |

---

## Raw Source Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Documents/Design/Common Libraries/Centralized Auditing.docx` | Full audit library specification |
| `drive_raw/Documents/Design/Common Libraries/Centralized Logging.docx` | Logging library specification |
| `drive_raw/Documents/Design/Foundations/LLD - Centralized Logging & Monitoring.docx` | Logging and monitoring LLD |
| `drive_raw/Documents/Design/Analysis/Enterprise Stock Replenishment System (SRS) - Technical Architecture Document.docx` | Full tech architecture |

---

## Cross-References

- [Technical Architecture](./01-technical-architecture.md) — Monitoring & Operations tech stack
- [Microservices Design](./03-microservices-design.md) — Service boundaries, CQRS patterns
- [On-Premise Architecture](./02-enterprise-onprem.md) — Self-hosted infrastructure constraints
- [Coding Standards](./11-coding-standards.md) — BE repo implementation docs