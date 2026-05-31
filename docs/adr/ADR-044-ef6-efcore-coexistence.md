# ADR-044. EF6 and EF Core Coexistence in Same Solution

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend solution targets .NET 8 but contains references to both EntityFramework 6.5.1 (EF6) and EF Core 8.0.22. This dual-ORM situation arose from migrating legacy repositories from the WingYip Legacy monolith while building new repositories with EF Core.

**EF6 usage (legacy):**
- `OverStockRepository` — uses `System.Data.Entity`
- `StoreLocationRepository` — uses `System.Data.Entity`
- `GNFRUniformRepository` — uses `System.Data.Entity`
- `PutAwayService` — uses `System.Data.Entity`

**EF Core usage (current):**
- All other repositories use EF Core 8.0.22 via `SRSDbContext`
- Standard ORM for new development

**BaseRepository consideration:** The `BaseRepository` class contains commented-out Dapper methods, suggesting a third ORM (micro-ORM via Dapper) was considered but not adopted. This indicates the team evaluated multiple data access strategies before settling on the current dual-ORM approach.

**Risk:** Running both EF6 and EF Core in the same process can cause transaction and connection conflicts, as each ORM manages its own `DbContext`/`ObjectContext` and connection lifecycle independently.

## Decision

We continue the dual ORM strategy: EF6 for legacy repositories that were migrated from the monolith, and EF Core for all new development. No immediate rewrite of EF6 repositories is planned.

## Consequences

**Positive:**
- Gradual migration is possible — EF6 repositories can be rewritten to EF Core incrementally
- No immediate rewrite required — legacy functionality continues to work
- Risk of regression is limited to the specific repositories being migrated

**Negative:**
- **Transaction/connection conflicts** — EF6 and EF Core manage connections independently, risking conflicts in shared transactions
- **Developer confusion** — new developers must determine which ORM to use for each repository
- **Dual context tracking** — two different `DbContext` types increase cognitive load and debugging complexity
- **Migration path unclear** — no documented plan or timeline for EF6-to-EF-Core migration
- **Package bloat** — both EF6 and EF Core packages increase deployment size
- **Commented-out Dapper code** in `BaseRepository` suggests abandoned alternatives, adding noise

**Future constraints:**
- Document which repositories use EF6 and which use EF Core
- Create a migration plan for converting EF6 repositories to EF Core
- Avoid introducing new EF6 repositories — all new data access must use EF Core
- Consider removing commented-out Dapper methods from `BaseRepository`
- Evaluate whether EF6 repositories can share the same database connection as EF Core contexts

## Related ADRs

- ADR-002: Database Per Service
- ADR-040: Core Shared Library Ecosystem and Monorepo Structure

## Key files

- `Core.csproj`
- `OverStockRepository.cs`
- `StoreLocationRepository.cs`
- `GNFRUniformRepository.cs`
- `PutAwayService.cs`
- `BaseRepository.cs`