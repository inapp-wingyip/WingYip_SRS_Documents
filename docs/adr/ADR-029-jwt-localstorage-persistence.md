# ADR-029. JWT Token Persistence in localStorage

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS web frontend and handheld application require authentication state persistence across browser/app restarts. The backend uses JWT tokens (access token + refresh token) issued by Keycloak.

**Current implementation:**
- **Web frontend**: `useSessionStore` (Zustand) with `persist` middleware stores tokens in **localStorage**
  ```typescript
  const STORAGE_KEY = 'auth-session';
  export const useSessionStore = create<SessionState>()(
    persist((set) => ({ ... }), { name: STORAGE_KEY })
  );
  ```
- **Handheld**: Direct `AsyncStorage` calls for token persistence (see ADR-019)
- **Token fields stored**: `accessToken`, `refreshToken`, `expiresIn`, `user` profile
- **No HttpOnly cookies**: Tokens are explicitly stored in client-side storage
- **No token rotation**: Refresh token is static until expired

## Decision

We accept **JWT token persistence in localStorage/AsyncStorage** with the following understanding:

1. **Web**: Zustand `persist` middleware → localStorage → key `auth-session`
2. **Handheld**: Direct AsyncStorage → key `auth-session` (or similar)
3. **Token storage**: Both access and refresh tokens stored in client storage
4. **Security mitigation**: XSS prevention via strict Content Security Policy and input sanitization
5. **No cookie-based storage**: HttpOnly cookies are not used for token transport

## Consequences

**Positive:**
- Simple implementation — no server-side session management required
- Tokens survive browser/app restarts
- Works with SPAs and React Native without cookie domain complexity
- Consistent pattern across web and handheld

**Negative:**
- **XSS vulnerability**: Any XSS attack can exfiltrate tokens from localStorage/AsyncStorage
- **No automatic token rotation**: Refresh token is static — if stolen, attacker has access until token expires
- **No server-side revocation**: Cannot invalidate tokens server-side (Keycloak token revocation not implemented)
- **localStorage is synchronous**: Token read/write blocks main thread (minimal impact but not ideal)
- **AsyncStorage is unencrypted**: On rooted/jailbroken devices, tokens are accessible in plaintext
- **CSRF not mitigated**: Without cookies, CSRF is not a concern, but XSS becomes the primary threat

**Future constraints:**
- Evaluate refresh token rotation (new refresh token issued with each access token refresh)
- Consider `httpOnly` + `sameSite=strict` cookie for refresh token with in-memory access token
- Implement token binding (device fingerprinting) to prevent token replay
- Add automatic token refresh before expiry
- Evaluate `react-native-keychain` for encrypted token storage on handheld

## Remediation Trigger

Upgrade token storage before:
- Security audit or compliance requirement (PCI-DSS, SOC 2)
- External API consumer integration
- Mobile app release on public app stores with security scanning

## Related ADRs

- ADR-003: Keycloak authentication (token issuance)
- ADR-016: Frontend state management (Zustand persist)
- ADR-019: Handheld state management (AsyncStorage)
- ADR-025: Allow-all CORS (XSS risk vector)
