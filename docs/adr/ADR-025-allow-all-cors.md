# ADR-025. Allow-All CORS Policy

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend APIs serve two primary consumers: the React web application and the React Native handheld application. Both consumers run on different origins (web app on its own domain, handheld as a native app with web views). Cross-Origin Resource Sharing (CORS) configuration is required for browser-based API calls.

**Current implementation:**
- `Core.Middleware.ServiceExtension.RegisterApplicationCoreService()` configures a single CORS policy named `"AllowAll"`
- Policy configuration:
  ```csharp
  policy.AllowAnyOrigin()
        .AllowAnyHeader()
        .AllowAnyMethod();
  ```
- Applied globally via `.UseCors("AllowAll")` in the middleware pipeline
- All 14+ backend services use this same policy via the shared Core library

## Decision

We use a **global Allow-All CORS policy** across all backend services:

1. **AllowAnyOrigin**: Accepts requests from any origin (no origin whitelist)
2. **AllowAnyHeader**: Accepts any HTTP header
3. **AllowAnyMethod**: Accepts any HTTP method (GET, POST, PUT, DELETE, PATCH, OPTIONS)
4. **Single policy**: Same `"AllowAll"` policy name used consistently across all services

## Consequences

**Positive:**
- Simple configuration — no per-environment or per-service CORS maintenance
- Works for both web and handheld consumers without origin enumeration
- No CORS preflight failures during development

**Negative:**
- **Security vulnerability**: `AllowAnyOrigin` with credentials is a security risk (though credentials are handled via JWT headers, not cookies)
- **No origin restriction**: Any website can call the APIs from a browser (mitigated by JWT validation, but still exposes endpoints)
- **Preflight overhead**: All cross-origin requests trigger OPTIONS preflight due to wide method/header allowance
- **No distinction between internal and external consumers**: Same policy for web app, handheld, and any potential future external API consumers
- **OWASP violation**: Open CORS is flagged in security audits

**Future constraints:**
- Before external API exposure, CORS MUST be restricted to known origins
- Evaluate per-environment CORS configuration (dev more permissive, production restricted)
- If JWT tokens move to cookies (from headers), `AllowAnyOrigin` becomes a critical vulnerability
- Consider whitelisting specific origins for production: web app domain, handheld origin

## Remediation Trigger

Restrict CORS before:
- Any external/third-party consumer integration
- Token storage changes from headers to cookies
- Security audit or compliance requirement (PCI-DSS, SOC 2)

## Related ADRs

- ADR-003: Keycloak authentication (JWT tokens currently passed in headers, mitigating CORS cookie risk)
- ADR-014: No API versioning (external consumers not yet supported)
