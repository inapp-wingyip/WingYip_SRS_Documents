# ADR-002. Database-Per-Service with SQL Server

- **Status:** accepted
- **Date:** 2024-01-20
- **Supersedes:** N/A

## Context

With 14 microservices, we needed a data strategy that preserved service autonomy. Sharing a single database would create hidden coupling, schema change coordination nightmares, and violate the bounded context principle. However, the enterprise environment standardized on SQL Server, and operational teams were not prepared to manage multiple database technologies.

Key constraints:
- SQL Server is the approved enterprise database
- DBA team manages all SQL Server instances
- Need for transactional consistency within each service
- Cross-service data must be accessed via APIs, not direct DB joins

## Decision

Each microservice will own **its own SQL Server database**. This is implemented as:

1. **Physical separation**: Each service has a dedicated database on the shared SQL Server cluster
2. **Schema ownership**: Each service team owns its schema; no other service may write to it
3. **EF Core Database-First**: Schemas are designed in SQL Server Management Studio, then scaffolded to C# entities
4. **No distributed transactions**: Sagas and eventual consistency patterns are used for cross-service operations
5. **Read replicas**: Reporting and analytics use read replicas, not production transaction databases

## Consequences

**Positive:**
- True service autonomy — schema changes in one service do not affect others
- Clear data ownership boundaries aligned with domain boundaries
- Independent scaling and backup policies per service
- Natural sharding path if a single service outgrows its database

**Negative:**
- Cannot use SQL JOINs across services — requires API composition or CQRS read models
- Data duplication across services where bounded contexts overlap
- Migration scripts must be carefully sequenced across 14+ databases
- Operational overhead of managing many databases

**Future constraints:**
- Any service needing a different data store type (e.g., Redis, MongoDB) requires a new ADR
- Shared libraries must NOT contain EF Core DbContexts — each service owns its own
- Cross-service data queries must use the BFF pattern or dedicated aggregation endpoints
