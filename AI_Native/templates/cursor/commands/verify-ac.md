# /verify-ac

Verify that all Acceptance Criteria in a spec have matching test coverage.

## When to Use

- Before submitting a PR.
- After implementing a feature.
- When reviewing code for spec compliance.

## Steps

1. Load the spec file (user provides path or auto-detect from branch).
2. Parse all Acceptance Criteria (Given/When/Then blocks).
3. Search the test directory for matching test cases:
   - Backend: `**/*Tests*.cs`, `**/*.test.cs`
   - Frontend: `**/*.test.ts`, `**/*.test.tsx`, `**/*.spec.ts`
   - Mobile: `**/*.test.ts`, `**/*.test.tsx`
   - Data Engineering: `**/*.tests.sql`, validation scripts

4. For each AC, determine:
   - ✅ Covered: At least one test verifies this AC.
   - ❌ Missing: No test found — generate skeleton.
   - ⚠️ Partial: Test exists but doesn't fully verify the THEN clause.

5. Output a structured checklist:
   ```
   ## AC Verification Report
   - [x] AC-1: User can log in with valid credentials
   - [ ] AC-2: User sees error for invalid password (MISSING)
     - Suggested test: LoginControllerTests.InvalidPassword_Returns401
   - [~] AC-3: Session expires after 30min (PARTIAL)
     - Note: Test checks expiry but not refresh behavior
   ```

## Commands to Run

- Backend: `dotnet test --filter "FullyQualifiedName~<pattern>"`
- Frontend: `npm test -- --testPathPattern=<pattern>`
- Mobile: `npm test -- --testNamePattern=<pattern>`

## References

- `Acceptance Criteria Policy`
- `Testing Strategy`
