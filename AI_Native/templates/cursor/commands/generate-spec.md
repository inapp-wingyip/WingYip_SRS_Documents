# /generate-spec

Generate a new OpenSpec feature specification from a user description.

## When to Use

- Starting a new feature, fix, or refactor that requires a spec.
- User provides a brief description or requirement.

## Steps

1. Ask the user for:
   - Feature name
   - Brief description
   - Target repo/stack
   - Related existing specs (if any)

2. Load the OpenSpec template:
   ```
   ../WingYip_SRS_Documents/AI_Native/openspec/templates/spec.md
   ```

3. Generate the spec with:
   - Proper OpenSpec metadata (version, status, author)
   - Context section referencing architecture docs
   - Gherkin-formatted Acceptance Criteria (Given/When/Then)
   - At least 3 ACs per feature
   - Verification section linking to test strategy

4. Save the spec to the appropriate location:
   - `docs/specs/<feature>.spec.md` (repo-local)
   - Or `../WingYip_SRS_Documents/design/` (cross-repo specs)

5. Run the spec through the review council (if available):
   - `/review-code` with `--mode=spec`

## Example

**User**: "I need a spec for the bulk replenishment picking workflow"

**Output**: `docs/specs/bulk-replenishment-picking.spec.md`

## References

- `SDD Pipeline`
- `OpenSpec Templates`
- `Spec Format Guide`
