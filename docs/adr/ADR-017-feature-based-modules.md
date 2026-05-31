# ADR-017. Feature-Based Module Architecture

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS web frontend supports 13 distinct business capabilities (admin, auth, customer-warehouse, dashboard, housekeeping, my-profile, print-labels, product-enquiry, spaceman, store-layout, store-operations, user-management, user-settings). A scalable code organization strategy is required to prevent tight coupling and maintain clear module boundaries as the application grows.

**Current implementation:**
- `src/features/` contains 13 independent feature modules
- Each feature follows an internal structure that varies by feature maturity: most have `pages/`, `components/`, and some form of API/hooks (either as `api/` and `hooks/` directories or as flat `api.ts`/`hooks.ts` files), plus a `routes.tsx` (or `routes.ts`). Some features (dashboard, user-settings) are minimal and lack subdirectories entirely.
- Feature routes are assembled centrally in `src/app/router/routes-config.tsx`
- Cross-feature communication occurs only through shared `src/shared/` utilities

## Decision

We adopt **vertical feature slicing** with a standardized module template:

1. **Feature directory**: Each capability lives in `src/features/<feature-name>/`
2. **Internal structure** (recommended, not strictly enforced):
   - `pages/` — route-level page components
   - `components/` — feature-local reusable components
   - `api/` or `api.ts` — API client functions and React Query hooks
   - `hooks/` or `hooks.ts` — feature-local custom hooks
   - `routes.tsx` or `routes.ts` — route definitions exported for central router assembly
   - Some mature features also include `types.ts`, `utils/`, `__tests__/`
3. **Shared layer**: `src/shared/` contains cross-cutting code (components, utilities, API factory) usable by any feature
4. **No cross-feature imports**: A feature may only import from `src/shared/`, never from another feature
5. **Route assembly**: Central `routes-config.tsx` imports and flattens all feature route arrays

## Consequences

**Positive:**
- Clear module boundaries prevent accidental coupling
- Features can be understood in isolation (single directory)
- New developers know exactly where to add code for a given capability
- Features can theoretically be extracted to separate packages or lazy-loaded bundles
- Standardized structure reduces decision fatigue

**Negative:**
- **Shared layer bloat risk**: `src/shared/` tends to accumulate everything, becoming a "dumping ground"
- Refactoring across features requires moving code from one feature directory to another
- Strict import rules require tooling enforcement (ESLint `no-restricted-imports`) to be effective
- Small reusable components that don't belong to a single feature have unclear ownership

**Future constraints:**
- New features MUST follow the `pages/components/api/hooks/routes.tsx` structure
- Import linting should be configured to enforce no cross-feature dependencies
- Consider micro-frontend extraction if any feature grows beyond ~50 components
- Shared components should be categorized (headless-ui, layout, form, data-display) to prevent monolithic shared layer

## Related ADRs

- ADR-016: Frontend state management (Zustand stores are global, not feature-local)
