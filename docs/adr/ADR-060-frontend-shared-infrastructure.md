# ADR-060. Frontend Shared Infrastructure

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS web frontend (React 19 + RSBuild + Tailwind) shares infrastructure patterns across 13 feature modules. These shared patterns form the backbone of the frontend architecture.

**Zustand Stores:**
- 5 shared stores: `session`, `app-state`, `store-selection`, `theme`, `unsaved-changes`
- Session store persisted to `localStorage` via Zustand persist middleware
- Integrated with token refresh — session store manages auth token lifecycle

**Shared Hooks:**
- `useResponsive` — responsive breakpoint detection
- `useTableFilters` — minimum 3-character search threshold, configurable page indexing
- `useUnsavedChanges` — global unsaved changes modal via Zustand + `useBlocker` (React Router)
- `useComments` — comment integration hook

**Config:**
- Declarative sidebar navigation via `NavItemConfig` with nested `children` arrays
- Per-service API URLs with hardcoded fallback URLs in configuration

**AG Grid Wrapper:**
- Custom wrapper component disabling built-in pagination in favor of `CustomPagination`
- Server-side sorting integration
- 0/1-based page index conversion between AG Grid (0-based) and backend APIs (1-based)

## Decision

We standardize on Zustand stores, shared hooks, declarative config, and a custom AG Grid wrapper across all 13 feature modules.

1. **Zustand stores**: 5 shared stores for global state — session, app-state, store-selection, theme, unsaved-changes
2. **Shared hooks**: `useResponsive`, `useTableFilters`, `useUnsavedChanges`, `useComments` — reusable across all modules
3. **Declarative config**: `NavItemConfig`-based sidebar navigation with nested children
4. **AG Grid wrapper**: Custom component with `CustomPagination`, server-side sorting, and page index conversion

## Consequences

**Positive:**
- Consistent patterns across all 13 feature modules — developers can move between modules with familiar patterns
- Reusable hooks reduce duplication and enforce consistent behavior (e.g., 3-char search threshold everywhere)
- Zustand's minimal API and TypeScript support provide type-safe state management
- Declarative sidebar config makes navigation changes data-driven rather than code-driven
- Custom AG Grid wrapper centralizes pagination and sorting logic

**Negative:**
- **Global unsaved changes modal is non-standard**: Using Zustand + `useBlocker` for a global modal differs from typical per-form dirty checks — can cause unexpected behavior with nested forms
- **Per-service API URLs create deployment complexity**: Hardcoded fallback URLs mean each environment requires URL configuration, and adding a new service requires updating the config
- **AG Grid wrapper adds maintenance overhead**: Custom wrapper must track AG Grid version upgrades and API changes
- **0/1-based page index conversion** is a subtle bug source — off-by-one errors can appear if the conversion is missed in new components

**Future constraints:**
- Document the unsaved changes modal pattern clearly for new developers — it differs from typical React form patterns
- Migrate per-service API URLs to environment-driven configuration with no hardcoded fallbacks
- Evaluate AG Grid wrapper maintenance burden vs. upgrading to AG Grid's native server-side pagination
- Add TypeScript strict checks for page index values to catch 0/1-based conversion errors at compile time
- Consider extracting the AG Grid wrapper into a shared package if it grows in complexity

## Related ADRs

- ADR-016: Frontend State Management (Zustand + React Query)
- ADR-018: RSBuild Build Tool
- ADR-017: Feature-Based Modules
- ADR-029: JWT LocalStorage Persistence

## Key files

- `use-session-store.ts`
- `use-table-filters.ts`
- `use-unsaved-changes.ts`
- `sidebar-nav.config.ts`
- `ag-grid-table.tsx`