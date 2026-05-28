# API & Event Contracts

> This document provides a canonical index of API, event, and real-time contract specifications across the SRS ecosystem. Detailed implementation docs live in each repository.

---

## REST API Contracts

### API Documentation Location

| Repo | Path | Description |
|------|------|-------------|
| **BE_EcoSystem** | `docs/API_Controllers_Reference.md` | 55 controllers, 400+ HTTP methods across 14+ microservices |
| **BE_EcoSystem** | `docs/ClientAPIConstants_Reference.md` | Client API constants reference |

> **Agent guidance**: The BE repo's `docs/API_Controllers_Reference.md` is the canonical API reference. Consult it for exact endpoint paths, HTTP methods, request/response shapes, and status codes. This WingYip_SRS_Documents entry links to it rather than duplicating content.

### API Design Conventions

Source: [Coding Standards](./11-coding-standards.md), [Service Communication](./04-service-communication.md)

**URL Pattern**: `/api/{service}/{entity}[/{id}]/{action}`

| Action | Method | URL | Status |
|--------|--------|-----|--------|
| List | GET | `/api/{service}/{entities}` | 200 |
| Get by ID | GET | `/api/{service}/{entities}/{id}` | 200 / 404 |
| Create | POST | `/api/{service}/{entities}` | 201 |
| Update | PUT | `/api/{service}/{entities}/{id}` | 200 |
| Partial update | PATCH | `/api/{service}/{entities}/{id}` | 200 |
| Delete | DELETE | `/api/{service}/{entities}/{id}` | 204 |
| Batch | POST | `/api/{service}/{entities}/batch` | 200 |

### Response Envelope

```json
{
  "data": { },
  "success": true,
  "message": "Operation completed",
  "errors": []
}
```

### Error Response

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    { "code": "VAL_INVALID_INPUT", "field": "StoreId", "message": "Store ID is required" }
  ],
  "correlationId": "guid-value"
}
```

### Error Code Prefixes

| Prefix | Domain | Example |
|--------|--------|---------|
| `VAL_` | Validation | `VAL_INVALID_INPUT`, `VAL_MISSING_REQUIRED` |
| `AUTH_` | Authentication | `AUTH_INVALID_TOKEN`, `AUTH_EXPIRED_SESSION` |
| `RBAC_` | Authorization | `RBAC_NO_ACCESS`, `RBAC_INSUFFICIENT_PRIVILEGE` |
| `BIZ_` | Business Rule | `BIZ_LOCKED_RESOURCE`, `BIZ_DUPLICATE_ENTITY` |
| `INT_` | Integration | `INT_SAP_TIMEOUT`, `INT_KORBER_UNAVAILABLE` |
| `SYS_` | System | `SYS_DATABASE_ERROR`, `SYS_UNHANDLED_EXCEPTION` |

---

## API Authentication & Authorization

### Web (AD/ADFS)

- **Auth**: ADFS OAuth2 / SAML 2.0 → SRS Auth Service → JWT/Cookie
- **Header**: `Authorization: Bearer {token}` or session cookie
- **RBAC**: Evaluated per request via RBAC engine (12 roles × 15 scopes)

### Mobile (Keycloak)

- **Auth**: Keycloak → JWT access token + refresh token
- **Header**: `Authorization: Bearer {jwt_token}`
- **Token Refresh**: Automatic refresh; re-auth on expiry

### Auth Scopes Per Service

Source: [Authentication & RBAC](./06-authentication-rbac.md)

| Scope | ID | Description |
|-------|-----|-------------|
| Admin Module — User Management | 1 | User CRUD, role assignment |
| Spaceman / Planogram | 2 | Planogram governance |
| Planogram Management | 3 | Planogram operations |
| Store Layout | 4 | Layout management |
| Shelf Edge Labels (SEL) | 5 | SEL printing management |
| Product Module | 6 | Product enquiry, search |
| Finance | 7 | Financial reports |
| Store Walk | 8 | Walk operations |
| Daily Processes | 9 | Scheduled processes |
| Stock & GNFR Management | 10 | Stock management |
| Incoming Deliveries | 11 | Delivery management |
| Stock Investigations | 12 | Discrepancy investigation |
| Didi Admin Store Operations | 13 | Didi management |
| Customer Warehouse Functions | 14 | Warehouse operations |
| Customer Warehouse Layout | 15 | Warehouse layout |

---

## Event Contracts (RabbitMQ)

### Exchange & Queue Pattern

| Pattern | Implementation |
|---------|---------------|
| Exchange Type | Topic |
| Queue Naming | `srs.{service}.{entity}.{action}` |
| Message Format | JSON with enrichment headers |
| Correlation ID | Required on all messages |
| Dead Letter Queue | `srs.dlx.{service}` for failed messages |

### Event Categories

| Category | Example Events | Source |
|----------|----------------|--------|
| **Audit Events** | `audit.entity.created`, `audit.entity.updated`, `audit.entity.deleted` | All services |
| **Replenishment Events** | `replen.group.locked`, `replen.group.unlocked`, `replen.task.created`, `replen.pick.confirmed` | Replenishment, StoreOperations |
| **Stock Events** | `stock.level.changed`, `stock.discrepancy.detected`, `stock.adjusted` | StockControl |
| **Planogram Events** | `planogram.status.changed`, `planogram.implemented` | Spaceman |
| **Integration Events** | `sap.product.synced`, `korber.stock.updated`, `opsuite.sales.received` | Bronze, Integration |

### Event Message Format

```json
{
  "eventId": "guid",
  "correlationId": "guid",
  "timestamp": "2026-01-15T10:30:00.000Z",
  "source": "WingYip.SRS.Replenishment",
  "eventType": "replen.group.locked",
  "userId": "CROWN123",
  "storeId": 1,
  "payload": {
    "replenGroupId": 42,
    "lockedBy": "CROWN456"
  }
}
```

---

## Real-Time Contracts (WebSocket)

Source: [Frontend & Mobile Architecture](./07-frontend-mobile-architecture.md), `drive_raw/Documents/Design/Web socket implementation/LLD -Web Socket.docx`

### Hub Structure

| Hub | Purpose | Clients |
|-----|---------|---------|
| **ReplenishmentHub** | Live replenishment updates | Web dashboard, HHD |
| **PlanogramHub** | Planogram progress notifications | Web (SpaceMan) |
| **NotificationHub** | Alert/notification delivery | Web, HHD |
| **StoreWalkHub** | Store walk task creation | HHD |

### Channel Naming

- `replen-group-{storeId}-{groupId}` — Replenishment group updates
- `planogram-{storeId}-{planogramId}` — Planogram progress
- `notifications-{userId}` — User-specific notifications
- `store-walk-{storeId}` — Store walk task updates

### Message Format

```json
{
  "type": "ReplenGroupStatusChanged",
  "groupId": 42,
  "status": "Locked",
  "lockedBy": "CROWN456",
  "timestamp": "2026-01-15T10:30:00.000Z"
}
```

---

## Idempotency & Concurrency

### Idempotency

- All write operations accept an optional `Idempotency-Key` header
- Service checks for existing processing of same key before executing
- Duplicate requests return the original response (not an error)
- Correlation IDs propagate across service boundaries

### Concurrency Control

| Resource | Lock Mechanism | TTL | Release |
|----------|---------------|-----|---------|
| Replen Group | Group lock (CR39) | Until pick confirmed or session ends | On confirm, exit, or crash recovery |
| Bay Group | Optimistic concurrency | — | Via RowVersion |
| Stock Level | Pessimistic locking for count | Transaction scope | On transaction complete |
| Planogram | Status-state machine | — | On status transition |

---

## Versioning Strategy

- **API Versioning**: URL path versioning (`/api/v1/...`)
- **Breaking Changes**: New major version path
- **Non-Breaking Changes**: Additive fields (backward compatible)
- **Event Versioning**: Schema version field in all event messages
- **WebSocket**: Protocol versioning via negotiation endpoint

---

## Source Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Documents/Design/Web socket implementation/LLD -Web Socket.docx` | WebSocket/SignalR LLD |
| `drive_raw/Documents/Design/Analysis/Endpoints for Shelf Edge Label Printing.docx` | SEL Print API endpoints |
| `drive_raw/Documents/Design/Analysis/Back End Technical Design Document.docx` | Backend technical design |
| `drive_raw/Documents/Design/Administration, Authentication and RBAC/WingYip - User Management Module_.docx` | User management auth details |
| BE repo: `docs/API_Controllers_Reference.md` | 55 controllers, 400+ methods |
| BE repo: `docs/CRUD.md` | CRUD template, API design rules |
| BE repo: `docs/ClientAPIConstants_Reference.md` | Client API constants |

---

## Cross-References

- [Service Communication](./04-service-communication.md) — BFF pattern, TVP, aggregation
- [Coding Standards](./11-coding-standards.md) — API design conventions, CQRS patterns
- [Security Standards](./13-security-standards.md) — API security, OWASP
- [Error Handling & Observability](./12-error-logging-observability.md) — Error codes, logging