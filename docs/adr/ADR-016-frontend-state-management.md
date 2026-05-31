# ADR-016. Frontend State Management — Zustand and React Query

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS web frontend (React 19 + RSBuild) requires state management for two distinct categories:

1. **Client/UI state**: Session data (JWT tokens, user roles), theme preferences, application UI state (sidebar, modals), store selection
2. **Server state**: Product catalogs, inventory data, replenishment lists, user hierarchies — all fetched from the backend API

**Current implementation:**
- **Zustand** (4 stores): `use-session-store`, `use-theme-store`, `use-app-state-store`, `use-store-selection-store`
- **React Query** (`@tanstack/react-query` v5): All server-state caching, background refetching, and optimistic updates
- **No Redux, no MobX, no Context-based state**: Zustand replaces all global state needs

**Why this split:**
- Zustand provides minimal boilerplate for client state with persistence middleware
- React Query handles caching, deduplication, background refetching, and stale-while-revalidate for API data
- Separation prevents server data from polluting global state and vice versa

## Decision

We adopt a **dual-store architecture**:

1. **Zustand for client state only**:
   - Session/auth tokens (persisted to localStorage via `persist` middleware)
   - UI state (theme, sidebar, selections)
   - Ephemeral app state
2. **React Query for server state only**:
   - All API data fetching and caching
   - Background refetching on window focus
   - Optimistic updates where applicable
3. **No Redux/MobX**: These libraries are not used in the frontend codebase
4. **Security note**: JWT tokens stored in localStorage via Zustand `persist` — XSS risk mitigated by strict CSP and input sanitization

## Consequences

**Positive:**
- Minimal boilerplate compared to Redux (no actions, reducers, or sagas)
- React Query eliminates manual caching logic and provides automatic refetching
- Clear mental model: Zustand = ephemeral/persisted client state, React Query = server cache
- Small bundle footprint (Zustand is ~1KB, React Query tree-shakes well)

**Negative:**
- **Token storage in localStorage**: JWT access tokens persisted to localStorage are vulnerable to XSS attacks (mitigated but not eliminated)
- Zustand stores `use-app-state-store` and `use-store-selection-store` have overlapping concerns (both manage store selection)
- No formal normalization strategy for server data (React Query caches per-key, not normalized entities)
- Async storage hydration mismatch risk (Zustand rehydrates from localStorage after render)

**Future constraints:**
- Server state must NOT be added to Zustand stores
- New client state should evaluate whether it belongs in Zustand (global) or React `useState` (component-local)
- If JWT token size grows, consider memory-only storage with refresh-token rotation
- Evaluate `zustand/shallow` for selectors to prevent unnecessary re-renders

## Related ADRs

- ADR-019: Handheld Context-only state management (platform divergence)
- ADR-005: Centralized audit enrichment (token lifecycle security)
