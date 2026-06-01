# WYSRS-4280 — Handheld Concurrent Session Fix

## Goal

Enable same-device re-authentication on the HHT (handheld terminal) after inactivity lock, without weakening cross-device concurrent-session protection.

## Root Cause

`AuthenticationService.CheckAndPreventConcurrentSessionAsync()` queries Keycloak for active sessions and rejects any new login if one exists. It has no concept of "same device" vs "different device". When an HHT user unlocks their device after inactivity lock, the unlock PIN verification calls the same `hhd-login` endpoint, which triggers the concurrent-session check and blocks the user.

## Changes

### Backend (WingYip_SRS_BE_EcoSystem)

1. **`PinVerifyRequestDto`** — added `DeviceId` property
2. **`ISessionRepository`** / **`SessionRepository`** — added `GetLatestActiveSessionByUserIdAsync(int userId)`
3. **New CQRS Query** — `GetLatestSessionByUserIdQuery` + `GetLatestSessionByUserIdQueryHandler`
4. **New CQRS Command** — `RevokeSessionCommand` + `RevokeSessionCommandHandler`
5. **`AuthenticationService.CheckAndPreventConcurrentSessionAsync`** — now device-aware:
   - If Keycloak session exists, query local `UserSessions` table for latest active session
   - If `DeviceId` matches incoming request → revoke old local session, allow new login (same-device re-auth)
   - If `DeviceId` does NOT match → reject new login (different-device concurrent session)
6. **`AuthenticationService.ValidatePinAsync`** — passes `request.DeviceId` into `TokenExchangeCommand`
7. **Authentication.Data.csproj** — removed `CQRS\Queries\**` exclusion so new query handler compiles
8. **ADR-062** — `docs/adr/ADR-062-device-aware-concurrent-session.md`

### Handheld (WingYip_SRS_HH_EcoSystem)

1. **`util.js`** — added `getOrCreateDeviceId()` helper (generates/persists v4-like UUID in AsyncStorage)
2. **`Login/index.native.js`** — sends `deviceId` in login request body
3. **`InactivityLockContext.js`** — sends `deviceId` in unlock (PIN verify) request body

### Web Frontend (WingYip_SRS_FE_EcoSystem)

No changes. Web login continues to use `DeviceId = "0"`; concurrent-session behavior unchanged.

## Files Modified

### BE
- `WingYip.SRS.Authentication.Data/Dtos/PinVerifyRequestDto.cs`
- `WingYip.SRS.Authentication.Data/Repositories/ISessionRepository.cs`
- `WingYip.SRS.Authentication.Data/Repositories/SessionRepository.cs`
- `WingYip.SRS.Authentication.Data/CQRS/Queries/GetLatestSessionByUserId/GetLatestSessionByUserIdQuery.cs`
- `WingYip.SRS.Authentication.Data/CQRS/Queries/GetLatestSessionByUserId/GetLatestSessionByUserIdQueryHandler.cs`
- `WingYip.SRS.Authentication.Data/CQRS/Commands/RevokeSession/RevokeSessionCommand.cs`
- `WingYip.SRS.Authentication.Data/CQRS/Commands/RevokeSession/RevokeSessionCommandHandler.cs`
- `WingYip.SRS.Authentication.Data/WingYip.SRS.Authentication.Data.csproj`
- `WingYip.Authentication.Service/AuthenticationService.cs`
- `WingYip.SRS.Docs/adr/ADR-062-device-aware-concurrent-session.md`

### HH
- `src/util/util.js`
- `src/screens/Login/index.native.js`
- `src/context/InactivityLockContext.js`

## Verification

- `Authentication.Data` builds: **0 errors, 4 warnings** (pre-existing nullable warnings in `UserSession.cs`)
- `Authentication.Service` build blocked by pre-existing missing `WingYip.SRS.Cache` NuGet package (not introduced by this change)
- LSP diagnostics clean on all modified files

## Security Considerations

- `DeviceId` is client-provided and can be spoofed. This is acceptable because:
  - The concurrent-session check is a UX convenience, not a security boundary
  - True security is enforced by Keycloak tokens, PIN verification, and RBAC
  - A malicious actor who knows another user's `DeviceId` could bypass concurrent-session rejection — but they would still need the user's PIN and CrownID to authenticate

## Future Work

- Consider hardware-bound device fingerprinting (e.g., Android `Build.SERIAL` or `react-native-device-info`) for stronger device identity
- Evaluate adding a dedicated `verifyPin` endpoint separate from `hhd-login` for semantic clarity

## Related

- WYSRS-4278: Concurrent session standardization (`ConcurrentSessionException`)
- WYSRS-4098: Web Login password reset message (same branch, separate concern)
- ADR-003: Keycloak authentication
- ADR-029: JWT token persistence
