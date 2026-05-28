# Microservices Architecture & Design

---

## Core Services

| Service | Responsibility |
|---------|---------------|
| **Product Service** | Product ID, Name, Description, UOM, Case Size |
| **SpaceMan Service** | Location details, planogram data, bay group mapping |
| **Stock Service** | Quantity, availability, UOM per location |
| **User Auth Service** | Authentication, RBAC, Keycloak integration |
| **Replenishment Engine** | Replen group logic, pick list generation |
| **Workflow Engine** | Bulk replen, put-away, stock movement |
| **Notification Service** | Alerts, messaging, escalation |
| **Audit Service** | Centralized auditing across all modules |

---

## Design Principles

1. **Database per Service** — Each microservice owns its database. No shared DB access across services.
2. **CQRS Pattern** — Separated Command (write) and Query (read) handlers via MediatR.
3. **Entity Framework Core** — Database-first approach with generated DbContext classes. No raw SQL strings. No stored procedures in SRS-owned databases (unless complex queries demand it). *Note: External systems (OpSuite) expose stored procedures that SRS calls, but SRS itself does not author or maintain stored procedures.*
4. **Repository Pattern** — DB access isolated via repositories wrapping DbContext.
5. **CQRS with MediatR** — Commands and queries separated, handlers manage orchestration.

---

## Architectural Flow

```
┌──────────────────────────────────────────────────┐
│              Controller Layer                     │
│  Receives HTTP requests from Web/Mobile           │
│  Delegates to CQRS Handlers (NOT repositories)    │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│           CQRS Handler Layer                      │
│  Command Handlers → Writes (Insert/Update/Delete) │
│  Query Handlers   → Reads (Selects)               │
│  Uses DI to get the repository                    │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│             Repository Layer                      │
│  Encapsulates all DB operations                   │
│  Entity Framework Core (DbContext)                │
│  Database-first generated entities                │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│              Database Layer                       │
│  Each microservice has its own DB                 │
│  Optional: CQRS can separate Write/Read DBs       │
└──────────────────────────────────────────────────┘
```

---

## Entity Framework Core Approach

| Feature | Benefit |
|---------|---------|
| Database-First | Generated DbContext and entities from existing SQL Server schemas |
| Type Safety | Strongly typed entities with compile-time checking |
| LINQ Queries | Composable, readable queries with deferred execution |
| Change Tracking | Automatic change detection and efficient updates |
| Migration Support | Schema versioning via EF migrations |
| Repository Pattern | DbContext wrapped in repositories for isolation |
| Microservices Fit | Each service has own DB and dedicated DbContext |

---

## Service Communication Patterns

### Synchronous (REST/HTTP)
- Real-time requests between services
- BFF pattern for aggregated data

### Asynchronous (RabbitMQ)
- Background processing (auditing, data sync)
- Event-driven workflows

### Real-Time (WebSocket)
- Live task updates on handhelds
- Progress indicators during planogram execution
- Internal network only

---

## CQRS Pattern

### Command Handlers
- Handle writes: Insert, Update, Delete operations
- Use dependency injection to get repository
- One handler per use case

### Query Handlers
- Handle reads: Select operations
- Can optionally use separate read-optimized database
- Return DTOs (not domain entities)

---

## Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| Entity Framework Core (database-first) | Type-safe entities, change tracking, LINQ queries, mature ecosystem |
| CQRS per service | Clean separation, scalable reads/writes |
| BFF for aggregation | Reduces N×M calls to 3 calls for 100 products |
| Batch API / TVP | Efficient multi-record queries (JSON→TVP conversion) |
| No shared DB | True microservice isolation |
| No stored procedures | Maintainable, version-controlled in repository, portable |
