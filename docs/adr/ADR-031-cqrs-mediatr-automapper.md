# ADR-031. CQRS with MediatR and AutoMapper

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend implements a layered architecture (Controller → Service → Handler → Repository → DbContext). With 400+ API endpoints and complex business operations, a clear separation between read (query) and write (command) operations is essential for maintainability.

**Current implementation:**
- **MediatR** (v12.1.1 / v13.1.0) across 65+ project references
- **318+ handlers**: Commands (write) and Queries (read) implemented as separate MediatR handlers
- **AutoMapper**: Entity → DTO mapping happens **only in Handlers** (enforced by CRUD.md)
- **CQRS separation**: Controllers dispatch MediatR requests; Handlers contain business logic
- **No event sourcing**: Commands do not produce domain events for replay
- **No sagas**: Complex multi-step operations implemented as single commands or client-coordinated calls

**Layer rules** (from CRUD.md):
| Layer | Can Call | Cannot Call |
|-------|----------|-------------|
| Controller | Service | MediatR, Repository, DbContext |
| Service | MediatR (IRequest/IRequestHandler) | Repository, DbContext |
| Handler | Repository | DbContext |
| Repository | DbContext | - |

## Decision

We use **MediatR-based CQRS** with strict layer separation:

1. **Commands**: Implement `IRequest<T>` for write operations (Create, Update, Delete)
2. **Queries**: Implement `IRequest<T>` for read operations (Search, GetById, List)
3. **Handlers**: Single responsibility — one handler per command/query
4. **AutoMapper in Handlers only**: All entity-to-DTO mapping in handler layer
5. **No cross-handler calls**: Handlers do not call other handlers (prevent cascade complexity)

## Consequences

**Positive:**
- Clear separation of concerns between reads and writes
- Handlers are independently testable units
- Consistent pattern across all 14+ services
- MediatR pipeline behaviors enable cross-cutting concerns (validation, logging, caching)
- New features follow predictable structure (Command/Query + Handler)

**Negative:**
- **MediatR version fragmentation**: v12.1.1 and v13.1.0 coexist — potential breaking changes between versions
- **No event sourcing**: Commands mutate state directly — no audit trail of state changes beyond ADR-005 audit logs
- **No out-of-process sagas**: Distributed transactions (e.g., create order + reserve inventory) not formally managed
- **Handler explosion**: 318+ handlers create large codebase — finding the right handler requires search
- **No query optimization**: Read models use same EF Core DbContext as writes — no dedicated read-optimized projections
- **Memory overhead**: MediatR service locator pattern resolves handlers via DI container (performance cost vs direct instantiation)

**Future constraints:**
- Standardize on single MediatR version across all services
- Evaluate dedicated read models (projections) for complex search queries
- Consider domain events for significant state changes (order placed, replenishment triggered)
- Document handler naming conventions and organization (by feature/aggregate)
- If saga orchestration becomes required, evaluate MassTransit or custom saga implementations

## Related ADRs

- ADR-001: Microservices architecture (CQRS as core pattern)
- ADR-009: Raw RabbitMQ.Client (no saga support via messaging)
- ADR-012: Background processing (Quartz jobs may trigger MediatR commands)
