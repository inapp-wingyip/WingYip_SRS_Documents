# /generate-tests

Generate test skeletons from a spec's Acceptance Criteria.

## When to Use

- After writing a spec but before implementation.
- When ACs are missing test coverage.
- To bootstrap test structure for a new feature.

## Steps

1. Load the spec file.
2. Parse all Acceptance Criteria (Given/When/Then).
3. For each AC, generate a test skeleton:

   **Backend (C# / xUnit)**:
   ```csharp
   [Fact]
   public void AC1_UserCanLoginWithValidCredentials()
   {
       // Arrange
       // TODO: Setup mocks, inputs

       // Act
       // TODO: Call method under test

       // Assert
       // TODO: Verify THEN clause
   }
   ```

   **Frontend (TS / Vitest)**:
   ```typescript
   test('AC1: User can log in with valid credentials', () => {
     // Arrange
     // TODO: Setup mocks, inputs

     // Act
     // TODO: Call method under test

     // Assert
     // TODO: Verify THEN clause
   });
   ```

4. Save tests to the appropriate test directory:
   - Backend: `Tests/Features/<feature>/`
   - Frontend: `src/features/<feature>/__tests__/`
   - Mobile: `src/screens/<feature>/__tests__/`

5. Run `/verify-ac` to confirm the generated tests map to ACs.

## Parameters

- `--framework=xunit|nunit|vitest|jest`: Override default test framework.
- `--output=path`: Custom output directory.

## References

- `Testing Strategy`
- `Acceptance Criteria Policy`
