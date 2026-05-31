# ADR-044. EF Core 8.0.22 as Sole ORM

- **Status:** accepted
- **Date:** 2026-05-31

## Context

All data access in the WingYip SRS backend uses Entity Framework Core 8.0.22 via the shared `Repository<T>` abstraction in `WingYip.SRS.Core`.

- `SRSDbContext` — EF Core `DbContext` with SaveChanges interception for audit enrichment
- `EFConnectionFactory` — EF Core `DbContextOptionsBuilder` with SQL Server provider
- `Repository<T>` — generic CRUD wrapper over EF Core `DbSet<T>`

## Decision

Entity Framework Core 8.0.22 is the **sole supported ORM** for all backend services. No other ORM is referenced or used.

## Consequences

**Positive:**
- Single ORM reduces cognitive load and debugging surface area
- All services share the same `Repository<T>` pattern, connection factory, and audit interception
- EF Core 8.0.22 is fully supported on .NET 8 with long-term support

**Negative:**
- None

**Future constraints:**
- All new data access must use EF Core via `Repository<T>`
- Direct ADO.NET or raw SQL should be avoided unless performance-critical and documented
- No introduction of alternative ORMs without a new ADR

## Related ADRs

- ADR-002: Database Per Service
- ADR-040: Core Shared Library Ecosystem and Monorepo Structure

## Key files

- `WingYip.SRS.Core/Data/Repository.cs`
- `WingYip.SRS.Core/Data/SRSDbContext.cs`
- `WingYip.SRS.Core/Data/EFConnectionFactory.cs`
