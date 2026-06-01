# ADR-001. Microservices Architecture with .NET 8

- **Status:** accepted
- **Date:** 2024-01-15
- **Supersedes:** N/A

## Context

WingYip required a modern, scalable backend to replace the legacy ASP.NET MVC monolith. The system needed to support 14 distinct business capabilities (store operations, replenishment, product catalog, audit, etc.) with independent deployment, scaling, and technology choices per domain. A monolithic architecture would create tight coupling, slow deployments, and high blast radius for failures.

Key constraints:
- On-premise deployment (no cloud-native managed services)
- Windows-centric enterprise environment
- Team already proficient in .NET ecosystem
- Need for incremental migration from legacy system

## Decision

We will adopt a **microservices architecture** built on **.NET 8** with the following patterns:

1. **Domain-Driven Decomposition**: 14 services aligned to business capabilities (Administration, Authentication, Audit, Product, Print, Replenishment, Reports, Spaceman, StockControl, StoreOperations, GenericProcessEngine, Bulk/Didi/FreshGoods replenishment engines)
2. **CQRS with MediatR**: Separate command and query handlers for clear read/write separation
3. **API Gateway / BFF**: Frontend and Handheld services act as backends-for-frontends
4. **EF Core Database-First**: Schemas designed in SQL Server, models generated via scaffolding
5. **Shared Core Libraries**: 8 packages (Core, Cache, HttpClient, PrintQueue, Reporting, Security.Core, UnitTest.Core, WebSocket) for cross-cutting concerns

## Consequences

**Positive:**
- Independent deployment and scaling per service
- Smaller, focused codebases easier to maintain
- Technology flexibility per service (though standardized on .NET 8)
- Fault isolation — failure in one service does not cascade to all

**Negative:**
- Operational complexity (14 services to monitor, deploy, debug)
- Network latency between services vs in-process calls
- Data consistency challenges across distributed transactions
- Increased infrastructure requirements (K8s, RabbitMQ, SQL Server instances)

**Future constraints:**
- New services must follow the established 5-layer pattern (Api → Service → Persistance → Data → Client)
- Database-per-service policy prevents shared databases
- Cross-service queries should use the BFF or aggregation services, not direct DB access
