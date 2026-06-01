# ADR-013. Dual JSON Serializer — Newtonsoft.Json and System.Text.Json

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend uses two different JSON serialization libraries:

**System.Text.Json** (modern, performant):
- `Core/Queue/RabbitMqPublisher.cs` — serializes published messages
- `Core.Cache/RedisCacheService.cs` — serializes cached objects

**Newtonsoft.Json** (legacy, feature-rich):
- `Core/Data/SRSDbContext.cs` — deserializes audit snapshots stored as JSON
- `Audit/Services/AuditConsumer.cs` — deserializes consumed audit messages
- Some EF Core configuration and custom converters

**Why both exist:**
- System.Text.Json was adopted for new code (publishing, caching) for performance
- Newtonsoft.Json was retained for existing code paths (audit, EF Core) due to `TypeNameHandling` and custom converter requirements
- Migration from Newtonsoft to System.Text.Json is incomplete

## Decision

We explicitly accept the coexistence of both serializers with a phased migration strategy:

1. **System.Text.Json for new code**: All new serialization uses System.Text.Json
2. **Newtonsoft.Json for audit/EF Core paths**: Retain Newtonsoft where `TypeNameHandling` or custom converters are required
3. **No mixing within a single request path**: A message should not be serialized with one library and deserialized with another
4. **Migration target**: Eventually migrate all Newtonsoft usage to System.Text.Json with custom source-generated converters

## Consequences

**Positive:**
- System.Text.Json provides better performance and lower memory allocation
- Newtonsoft.Json handles complex polymorphic deserialization (audit snapshots with `TypeNameHandling`)
- Gradual migration avoids risky big-bang refactoring

**Negative:**
- **Inconsistent behavior**: Case sensitivity, date formatting, and `$type` handling differ between libraries
- **Security risk**: Newtonsoft.Json `TypeNameHandling` is known to have security vulnerabilities if untrusted input is deserialized
- **Dependency bloat**: Both libraries in dependency graph increase attack surface and package size
- **Developer confusion**: Team must know which serializer to use for each operation
- **Bug risk**: Serializing with System.Text.Json and deserializing with Newtonsoft.Json (or vice versa) causes silent failures

**Future constraints:**
- New code must use System.Text.Json
- Audit snapshot format migration requires data migration script (old snapshots use Newtonsoft format)
- Evaluate `System.Text.Json` polymorphic serialization (`JsonDerivedType`) as replacement for `TypeNameHandling`
- Remove Newtonsoft.Json dependency when migration is complete

## Related ADRs

- ADR-005: Centralized audit enrichment (audit snapshots use Newtonsoft)
- ADR-009: Raw RabbitMQ.Client (publishers use System.Text.Json)
