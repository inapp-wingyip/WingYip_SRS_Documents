# ADR-062. Device-Aware Concurrent Session Detection

- **Status:** proposed
- **Date:** 2026-06-01
- **Supersedes:** N/A

## Context

The WingYip SRS handheld (HHT) application enforces an inactivity lock screen. When a user unlocks the HHT by re-entering their PIN, the app calls the same login endpoint (`hhd-login`) that is used for the initial login. This triggers the backend concurrent-session check, which queries Keycloak for active sessions and rejects the new login if any session exists.

**Problem:** The existing concurrent-session prevention logic treats "unlock on same device" identically to "login from a second device". This means an HHT user who locked their device due to inactivity is blocked from unlocking it because the backend sees their pre-lock Keycloak session as "already active".

**Root cause analysis (WYSRS-4280):**
1. `AuthenticationService.CheckAndPreventConcurrentSessionAsync()` only queries Keycloak Admin API for user sessions
2. It has no concept of "same device" vs "different device"
3. The `UserSessions` DB table has a `DeviceId NVARCHAR(32) NOT NULL` column, but mobile logins never populate it (defaults to empty string)
4. HHT login/unlock requests send only `{ crownID, pin }` — no device identifier

## Decision

We will make the concurrent-session check **device-aware** by:

1. **Adding `DeviceId` to HHT login/unlock requests** — the HHT app will generate and persist a stable device UUID in AsyncStorage (using `react-native-device-info` or a custom UUID generator)
2. **Passing `DeviceId` through the mobile auth flow** — `PinVerifyRequestDto` → `AuthenticationController.HHDLogin` → `AuthenticationService.ValidatePinAsync` → `TokenExchangeCommand` → `TokenExchangeHandler` → `UserSession`
3. **Enhancing `CheckAndPreventConcurrentSessionAsync`** to:
   - Query Keycloak for existing sessions (existing behavior)
   - If an existing session is found, query the local `UserSessions` table for the user's most recent active session
   - If the existing session's `DeviceId` matches the incoming request's `DeviceId`, **revoke the old local session and allow the new login** (same-device re-auth)
   - If the `DeviceId` does NOT match, **reject the new login** (different-device concurrent session)
4. **Adding `GetLatestSessionByUserIdQuery`** — a new CQRS Query handler in `Authentication.Data` to retrieve the most recent active `UserSession` by `UserId`

**Web behavior unchanged:** Web login continues to use `DeviceId = "0"` (hardcoded). Web concurrent-session behavior is unchanged — any existing web session blocks a new web login.

## Consequences

**Positive:**
- HHT users can unlock their device after inactivity lock without being blocked
- Security is preserved: logging in from a *different* device still triggers the concurrent-session rejection
- Leverages existing `UserSessions.DeviceId` column infrastructure
- Minimal changes to the concurrent-session algorithm — only adds a same-device bypass

**Negative:**
- Introduces a dependency on the local `UserSessions` table for the concurrent-session check (previously Keycloak-only)
- `DeviceId` is client-provided and could be spoofed by a malicious client (mitigation: this is the same threat model as the rest of the auth flow; we trust the device identifier for UX convenience, not as a security boundary)
- Requires updating HHT login and unlock code paths to include the device UUID

**Future constraints:**
- If true device fingerprinting (hardware-bound) is needed later, this ADR's client-provided UUID approach would need to be superseded
- The `DeviceId` column could be extended to store a more robust device fingerprint in future

## Related ADRs

- ADR-003: Keycloak authentication (token issuance)
- ADR-029: JWT token persistence in localStorage/AsyncStorage
- ADR-057: Handheld security hardware integration

## Related Tickets

- WYSRS-4278: Concurrent session standardization (custom exception)
- WYSRS-4280: HHT concurrent session bug on same-device unlock
- WYSRS-4098: Web Login password reset message
