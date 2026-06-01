# /update-adr

Create or update an Architecture Decision Record (ADR).

## When to Use

- Proposing a new architectural approach.
- Superseding an existing ADR.
- Documenting a significant technical choice.

## Steps

1. Check if an ADR already exists for this topic:
   - Search `WingYip_SRS_Documents/docs/adr/`
   - Check ADR index: `WingYip_SRS_Documents/docs/adr/README.md`

2. If new ADR:
   - Assign next sequential number (e.g., ADR-062).
   - Use template: `WingYip_SRS_Documents/AI_Native/openspec/templates/adr.md`

3. If superseding:
   - Mark old ADR as `superseded_by: ADR-XXX`.
   - New ADR references the old one.

4. Required sections:
   - Title and date
   - Status: `proposed` → `accepted` / `rejected` / `superseded`
   - Context (what problem are we solving?)
   - Decision (what are we doing?)
   - Consequences (tradeoffs, risks)
   - Related ADRs

5. Run through Architect persona review.

6. Save to: `WingYip_SRS_Documents/docs/adr/ADR-XXX-<title>.md`

## References

- `ADR Discipline`
- `ADR Template`
- `Existing ADRs`
