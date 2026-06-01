# ADR-019. Handheld State Management — React Context Only

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS handheld application (React Native 0.72 Android) requires state management for authentication, RBAC permissions, store selection, notifications, inactivity locking, and PIN reset flows.

**Current implementation:**
- **7 React Context providers** composed in `App.js`: Localization → Auth → RBAC → App → Notification → InactivityLock → ResetPin
- **No third-party state library**: No Redux, no Zustand, no MobX
- **Direct AsyncStorage**: Token persistence uses direct `AsyncStorage` calls via `getFromStore`/`saveToStore` utility
- **Platform divergence**: The web frontend uses Zustand + React Query, while handheld uses Context + hooks exclusively

**Why Context-only:**
- React Native app scope is smaller than web (fewer concurrent features)
- Context + `useReducer` pattern sufficient for handheld's state complexity
- Avoids additional dependency and bundle size

## Decision

We use **React Context with `useState`/`useReducer`** for all handheld state management:

1. **No external state library**: Redux, Zustand, MobX are not used
2. **Context composition**: 7 providers wrap the application root
3. **Persistence via AsyncStorage**: Direct storage calls for tokens, permissions, and store selection
4. **Platform divergence accepted**: Handheld state architecture intentionally differs from web frontend

## Consequences

**Positive:**
- Zero additional dependencies for state management
- Familiar React patterns — no learning curve for Context/hooks
- Sufficient for handheld's state complexity (less concurrent global state than web)
- Direct AsyncStorage integration without persistence middleware abstractions

**Negative:**
- **Re-render performance**: Deep context composition causes cascading re-renders when any context updates
- **7-provider nesting** in `App.js` is deep and brittle — adding a new global concern requires restructuring root
- No time-travel debugging or state inspection tools (Redux DevTools not available)
- Code reuse between web and handheld is harder (different state patterns)
- AsyncStorage is asynchronous — state hydration causes flash-of-unauthenticated-UI on app launch

**Future constraints:**
- If handheld grows beyond current scope (more features, deeper state trees), evaluate Zustand for consistency with web
- Context providers should be flattened or colocated where possible
- Consider `useContextSelector` pattern to prevent unnecessary re-renders
- AsyncStorage migration to encrypted storage (e.g., `react-native-keychain`) should be evaluated for token security

## Related ADRs

- ADR-016: Frontend state management (Zustand + React Query on web)
- ADR-005: Centralized audit enrichment (auth token lifecycle)
