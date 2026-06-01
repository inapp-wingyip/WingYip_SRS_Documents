# ADR-048. Frontend API Client Factory and Headless UI Design System

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS frontend makes two major architectural decisions: API client management and UI component library.

**API Client Factory (`createApiClient()`):**
- Factory function creates per-domain Axios instances with automatic JWT injection via request interceptors
- Implements concurrent-safe token refresh using single-promise deduplication — when multiple requests trigger a refresh simultaneously, only one refresh call is made and all waiting requests reuse the same promise
- Handles dual error format: some API responses return `{ error: { code, message } }` while others return flat `{ error, message }` structures
- Hard redirect to login page on authentication failure (401/403)
- Per-service base URLs configured in `env.ts` with hardcoded fallbacks to `10.10.80.77` (internal IP address)
- No BFF (Backend-for-Frontend) or API gateway abstraction — the frontend knows the full backend service topology

**Headless UI Design System:**
- 21-component library built on `@headlessui/react` v2 with Tailwind CSS v4
- WingYip brand colors: Red `#b91c1c`, Gold `#d97706`
- Components include: Input, Select, Combobox, Checkbox, Switch, Button, Modal, Popover, Menu, and more
- Headless UI provides accessible, unstyled primitives; Tailwind provides styling
- Brand color inconsistency exists: `tailwind.config.js` defines different color values than the README documentation

**Key concerns:**
- Hardcoded internal IP addresses in `env.ts` fallbacks create deployment inflexibility
- Frontend awareness of backend topology (per-service URLs) couples the FE to BE deployment structure
- Brand color inconsistency between config and documentation risks UI inconsistency
- No BFF layer means the frontend must handle cross-service orchestration client-side

## Decision

We use **Axios factory with concurrent-safe token refresh** for API communication and **Headless UI component library** for the design system:

1. **`createApiClient()`** creates per-domain Axios instances with automatic JWT injection and single-promise token refresh deduplication
2. **Per-service base URLs** are configured in `env.ts` with hardcoded fallbacks
3. **Headless UI v2 + Tailwind CSS v4** provides the component foundation with WingYip brand theming
4. **21 components** form the shared design system library (accordion, alert, badge, button, checkbox, combobox, comments-modal, component-showcase, confirm-dialog, date-picker, field-helper-text, input, menu, popover, radio, select, switch, tabs, textarea, toast, tooltip)

## Consequences

**Positive:**
- Consistent API behavior across all domain clients (auth, error handling, retry)
- Token refresh deduplication prevents race conditions when multiple concurrent requests encounter expired tokens
- Headless UI provides accessible, WAI-ARIA-compliant components out of the box
- Tailwind CSS enables rapid, consistent styling with utility classes
- Centralized error handling reduces boilerplate in feature modules

**Negative:**
- **No BFF/gateway abstraction**: Frontend knows the full backend service topology via per-service URLs, creating tight coupling between FE and BE deployment structure
- **Hardcoded fallback IPs**: `env.ts` contains hardcoded `10.10.80.77` addresses that will break in non-development environments
- **Brand color inconsistency**: `tailwind.config.js` defines different color values than the README, risking UI inconsistency across components
- **Dual error format handling**: Supporting two error response formats adds complexity and suggests inconsistent backend error responses
- **Hard redirect on auth failure**: Full page redirect (vs. in-app routing) loses user context and session state

**Future constraints:**
- Introduce an API gateway or BFF layer to decouple frontend from backend service topology
- Remove hardcoded IP fallbacks; use environment variables exclusively
- Align brand colors between `tailwind.config.js` and documentation; use a single source of truth (the config file)
- Standardize backend error response format to eliminate dual-format handling in the API client
- Consider in-app auth failure routing instead of hard redirects to preserve user context

---

## References

- `create-api-client.ts` — Axios factory with JWT injection and token refresh
- `env.ts` — Per-service base URL configuration with hardcoded fallbacks
- `headless-ui/*` — 23-component design system library
- `tailwind.config.js` — Tailwind configuration with WingYip brand colors
- ADR-029 (JWT LocalStorage Persistence) — Token storage strategy
- ADR-016 (Frontend State Management) — React Query and state patterns