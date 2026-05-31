# ADR-057. Handheld Security Patterns and Hardware Integration

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS handheld application (React Native 0.72 Android) runs on shared Honeywell devices in warehouse environments. Multiple security and hardware integration decisions were made that differ significantly from the web frontend patterns.

**Inactivity Auto-Lock:**
- 10-minute inactivity timeout triggers app lock; 1-hour session timeout forces re-authentication
- `AppState` listener + timer-based detection for inactivity tracking (backgrounding, inactivity timeout)
- `PanResponder` in `useInactivityTracker.js` captures touch events for foreground inactivity (not at root level of `InactivityLockContext`)
- PIN verification delegated to backend API (not local validation)
- Navigation state preserved after unlock so users resume where they left off

**RBAC HOC:**
- Hierarchical module permissions with three access levels: `FULL`, `VIEW`, `NONE`
- `useModuleAccess` hook and `withModuleAccess` HOC provide screen-level access control
- Permissions stored per-store in `AsyncStorage`, allowing different access per store context

**WebSocket:**
- Custom WebSocket service with linear backoff reconnect (5 attempts, 3-second base delay: 3s, 6s, 9s, 12s, 15s)
- Screen-aware event filtering — only events relevant to the active screen are dispatched
- Authentication token passed in URL query params for WebSocket handshake

**Honeywell Scanner:**
- `useHoneywellScanner` hook integrates with the Honeywell barcode scanner hardware
- UOM suffix stripping via regex removes unit-of-measure suffixes from scanned barcodes (business rule embedded in hardware layer)
- Post-install script patches `@angelcat` package's `build.gradle` for CI/CD AAR bundling compatibility

## Decision

We implement PanResponder-based inactivity lock, hierarchical RBAC with HOC pattern, custom WebSocket with screen-aware routing, and Honeywell scanner integration with build-time patching.

1. **Inactivity lock**: AppState listener + timers detect inactivity and background timeout; PanResponder in `useInactivityTracker.js` supplements foreground touch detection; PIN verified via backend API
2. **RBAC**: `useModuleAccess` hook and `withModuleAccess` HOC for screen-level access control with `FULL`/`VIEW`/`NONE` levels
3. **WebSocket**: Custom service with linear backoff (5 attempts, 3s base), screen-aware event filtering, token in URL query params
4. **Honeywell scanner**: `useHoneywellScanner` hook with UOM suffix stripping regex; post-install script patches `@angelcat` build.gradle

## Consequences

**Positive:**
- Comprehensive security for shared warehouse devices — auto-lock prevents unauthorized access on unattended devices
- Hardware integration works reliably with Honeywell scanners used in production
- Screen-aware WebSocket filtering reduces unnecessary re-renders and processing
- Navigation state preservation after unlock improves user experience
- Per-store RBAC permissions support multi-store operator scenarios

**Negative:**
- **PanResponder in useInactivityTracker.js** may interfere with gesture-based UI components (swipe actions, pull-to-refresh) when active
- **WebSocket tokens in URL query params** are visible in server logs and proxy logs — security concern for token exposure
- **UOM suffix stripping in hardware layer** embeds a business rule in the scanner integration, making it harder to change without touching the hook
- **Post-install script patching** of `@angelcat` build.gradle is fragile — package updates may break the patch
- **5-attempt reconnect cap** on WebSocket means extended outages require app restart to reconnect

**Future constraints:**
- Evaluate moving WebSocket auth to protocol-level (first message after connect) instead of URL params
- Consider extracting UOM stripping to a separate business rule layer outside the scanner hook
- Monitor PanResponder conflicts with gesture libraries and evaluate alternatives (e.g., consolidating touch detection into `InactivityLockContext` root view)
- Automate the `@angelcat` build.gradle patch detection to fail CI if the patch no longer applies cleanly

## Related ADRs

- ADR-019: Handheld State Management — React Context Only
- ADR-011: Custom WebSocket (backend)
- ADR-003: Keycloak Authentication
- ADR-042: Permission-Based RBAC System with Cache-Aside Pattern

## Key files

- `InactivityLockContext.js`
- `RBACContext.native.js`
- `websocket.js`
- `useHoneywellScanner.js`
- `patch-honeywell.js`