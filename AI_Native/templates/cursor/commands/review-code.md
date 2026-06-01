# /review-code

Run the 4-persona AI review council on the current changes.

## When to Use

- Before creating a PR.
- After implementing a feature.
- When self-reviewing code.

## Steps

1. Identify the changes:
   - If in a git repo: `git diff --name-only HEAD~1` (or specified commit range)
   - If unstaged: `git diff --name-only`

2. For each changed file, load the relevant spec (if exists).

3. Run the 4-persona review council:

   **Persona 1: BA (Business Analyst)**
   - Do the changes match the acceptance criteria?
   - Are there missing ACs or edge cases?
   - Is the user journey preserved?

   **Persona 2: Architect**
   - Do the changes follow CQRS/microservice boundaries?
   - Are there cross-cutting concerns handled correctly?
   - Is the database schema impact acceptable?
   - Does it align with ADRs?

   **Persona 3: QA (Quality Assurance)**
   - Are there tests for all ACs? (run `/verify-ac`)
   - Are there edge cases not covered?
   - Is the test quality adequate (assertions, mocking)?

   **Persona 4: Developer**
   - Is the code readable and maintainable?
   - Are there code smells or anti-patterns?
   - Is error handling adequate?
   - Are logging and observability in place?

4. Aggregate findings into a structured report:
   ```
   ## Review Council Report
   ### BA Review: ✅ PASS / ❌ FAIL
   - ...

   ### Architect Review: ✅ PASS / ❌ FAIL
   - ...

   ### QA Review: ✅ PASS / ❌ FAIL
   - ...

   ### Developer Review: ✅ PASS / ❌ FAIL
   - ...

   ## Overall: PASS / NEEDS_CHANGES
   ## Action Items:
   - [ ] ...
   ```

5. If any persona flags a blocking issue, refuse to proceed until resolved.

## Parameters

- `--mode=spec`: Review a spec document (not code).
- `--mode=adr`: Review an Architecture Decision Record.
- `--personas=ba,architect`: Run only specified personas.

## References

- `Reviewer Council`
- `Guardrails`
- `Skills Catalog`
