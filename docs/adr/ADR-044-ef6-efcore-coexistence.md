# ADR-044. EF6 Package Reference Removal — Phantom Dependency Cleanup

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** Previous draft of ADR-044 (EF6 and EF Core Coexistence)

## Context

The `WingYip.SRS.Core` project referenced `EntityFramework` 6.5.1 alongside `Microsoft.EntityFrameworkCore` 8.0.22. Four source files contained `using System.Data.Entity` or `using System.Data.Entity.Infrastructure` imports:

- `OverStockRepository.cs` (StockControl)
- `StoreLocationRepository.cs` (Product)
- `GNFRUniformRepository.cs` (Product)
- `PutAwayService.cs` (Replenishment)

**Investigation found:**
- The `using` statements were **dead imports** — no EF6 API (`ObjectContext`, `DbModelBuilder`, `DbEntityValidationException`, etc.) was ever called
- All data access goes through `Repository<T>` in `WingYip.SRS.Core`, which is **100% EF Core**
- `SRSDbContext`, `EFConnectionFactory`, and `DbContextOptionsBuilder` are all EF Core implementations
- The imports were stale leftovers from when these files were copied from the WingYip Legacy monolith

**Conclusion:** EF6 was a phantom dependency — referenced but never executed.

## Decision

1. Remove the `EntityFramework` 6.5.1 package reference from `Core.csproj`
2. Remove the 4 dead `using System.Data.Entity` / `System.Data.Entity.Infrastructure` imports
3. Do **not** introduce EF6 references in new code
4. All data access remains on EF Core 8.0.22

## Consequences

**Positive:**
- Eliminates phantom dependency — one fewer package to maintain and audit
- Removes false signal that the project uses dual ORMs
- Reduces deployment footprint by ~2.5 MB
- Eliminates confusion for new developers
- No runtime behavior change — EF6 APIs were never called

**Negative:**
- None. The removed code was unreachable.

**Future constraints:**
- Continue using EF Core exclusively for all data access
- When migrating legacy code, strip EF6 imports during porting
- Maintain the `Repository<T>` abstraction to keep ORM choice centralized in Core

## Related ADRs

- ADR-002: Database Per Service
- ADR-040: Core Shared Library Ecosystem and Monorepo Structure

## Key files

- `WingYip.SRS.Core.csproj` — package reference removed
- `OverStockRepository.cs` — dead import removed
- `StoreLocationRepository.cs` — dead import removed
- `GNFRUniformRepository.cs` — dead import removed
- `PutAwayService.cs` — dead import removed
