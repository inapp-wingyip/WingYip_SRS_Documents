# ADR-011. Custom WebSocket over SignalR

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform requires real-time communication for store operations (replenishment updates, product changes, inventory alerts). Both the web frontend and handheld Android application need push notifications.

**Current state:**
- **Backend**: `Core.WebSocket/` (10 files) provides a custom WebSocket implementation with `ConcurrentDictionary`-based local connection manager, JWT auth via query parameters, and custom message protocol
- **Web Frontend**: Connects via WebSocket to Administration service for real-time notifications
- **Handheld**: `src/services/websocket.js` implements a custom WebSocket singleton with manual reconnection (exponential backoff, max 5 attempts), route-aware event filtering, and auth via query params
- **SignalR explicitly excluded**: AGENTS.md states "No SignalR — real-time communication is via Core.WebSocket"

**Why custom over SignalR:**
- SignalR requires a persistent connection hub and server-side state management
- SignalR's abstraction may not fit the lightweight notification pattern needed
- Custom implementation provides full control over connection lifecycle and message format

## Decision

We will use a **custom WebSocket implementation** instead of SignalR:

1. **Backend**: `Core.WebSocket` library provides:
   - `WebSocketMiddleware` for ASP.NET Core integration
   - `SocketHandler` for per-connection message processing
   - `ConnectionRegistry` for distributed connection tracking (Redis-backed)
   - JWT authentication via query string token parameter
   - Custom message envelope protocol
2. **Handheld**: React Native native `WebSocket` API with manual reconnection and route filtering
3. **No SignalR**: SignalR is not used in any service

## Consequences

**Positive:**
- Full control over message protocol, connection lifecycle, and error handling
- No dependency on SignalR server or client SDKs
- Lightweight implementation tailored to notification-only use case
- Direct integration with existing JWT auth infrastructure
- Works uniformly across web (browser WebSocket) and mobile (React Native WebSocket)

**Negative:**
- ~500+ lines of custom code that SignalR would provide out-of-box
- No automatic reconnection (must implement manually — done in handheld, not web)
- No built-in scale-out backplane (custom `ConnectionRegistry` with Redis fills this gap)
- No client SDK with automatic retry, hub proxy generation, or transport fallback
- No built-in streaming or group management (must implement manually)
- Message protocol is custom — no standard documentation or client libraries

**Future constraints:**
- Any migration to SignalR would require replacing `Core.WebSocket` and all client connections
- If bidirectional RPC or streaming becomes required, SignalR evaluation is recommended
- WebSocket connections do not automatically recover from server restarts (clients must reconnect)
- Consider SignalR if team grows or if more complex real-time patterns are needed

## Related ADRs

- ADR-001: Microservices architecture (real-time communication requirement)
- ADR-010: Dual messaging infrastructure (Redis Pub/Sub feeds WebSocket broadcasts)
