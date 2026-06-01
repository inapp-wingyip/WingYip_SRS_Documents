---
applyTo: "**/*.cs"
name: "Backend SDD Rules"
---

## Backend Conventions

- Every controller action must reference its API spec.
- Use CQRS: Commands -> *.Commands/, Queries -> *.Queries/.
- EF Core entities are database-first — never edit without updating the DB model.
- Cross-cutting concerns go to Core shared library (../Core/).
- Follow [Coding Standards](../../WingYip_SRS_Documents/architecture/11-coding-standards.md).
- Run `dotnet build && dotnet test` before committing.
