# ADR-059. Inter-Service HTTP Client Pattern

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend has two competing HTTP client patterns for inter-service communication, plus an incomplete gRPC transport layer and an outdated service configuration class.

**HttpRequestInvoker:**
- Generic `IRequestInvoker` interface with `GET`, `POST`, `PUT`, `DELETE` methods
- Uses `IHttpClientFactory` for HTTP client lifecycle management
- Factory pattern via `RequestInvokerFactory` for resolving the appropriate invoker

**HttpClientService:**
- Typed `IHttpClientService` interface with named endpoint resolution via `ServiceEndpoints`
- More specific API surface — typed methods for service-to-service calls
- Named endpoint configuration allows per-service HTTP client settings

**ClientTransport enum:**
- Defines `Http` and `Grpc` transport options
- Only `Http` is implemented — `Grpc` throws `NotImplementedException`
- The enum exists in production code, suggesting gRPC was planned but never delivered

**SRSService config:**
- Outdated configuration class with hardcoded service URLs
- Some service names don't match actual deployed services
- Not actively maintained — services use `ServiceEndpoints` instead

## Decision

We use dual HTTP client implementations with a factory pattern, and defer gRPC to a future milestone.

1. **HttpRequestInvoker**: Generic request invoker for flexible, untyped inter-service calls
2. **HttpClientService**: Typed client for service-specific calls with named endpoint resolution
3. **RequestInvokerFactory**: Factory resolves the appropriate invoker based on context
4. **gRPC deferred**: `ClientTransport.Grpc` remains in the enum but throws `NotImplementedException`
5. **SRSService config**: Retained for backward compatibility but not updated — new code uses `ServiceEndpoints`

## Consequences

**Positive:**
- Typed clients (`HttpClientService`) provide compile-time safety and discoverable API surface
- Generic invoker (`HttpRequestInvoker`) provides flexibility for ad-hoc or dynamic service calls
- `IHttpClientFactory` integration ensures proper HTTP client lifecycle (connection pooling, DNS refresh)
- Named endpoint resolution via `ServiceEndpoints` centralizes service URL configuration

**Negative:**
- **Two implementations create confusion**: Developers must decide which pattern to use for each new inter-service call — no clear guideline exists
- **SRSService config is outdated**: Hardcoded URLs and mismatched service names create risk of misconfiguration
- **gRPC stub adds maintenance overhead**: The `ClientTransport` enum and `NotImplementedException` path add code that provides no current value and must be maintained
- **No clear migration path**: If gRPC is eventually implemented, the dual HTTP pattern makes it unclear which calls should migrate

**Future constraints:**
- Consolidate to a single HTTP client pattern — prefer `HttpClientService` with typed interfaces for new code
- Remove or update `SRSService` config to match actual service names, or deprecate it entirely
- Either implement gRPC transport or remove the `ClientTransport.Grpc` enum value and `NotImplementedException` path
- Document which pattern to use for new inter-service calls (recommendation: typed `HttpClientService`)
- Add `ServiceEndpoints` validation on startup to catch mismatched or missing endpoint configurations early

## Related ADRs

- ADR-010: Custom WebSocket (real-time communication)
- ADR-004: On-Premise Kubernetes (service discovery)

## Key files

- `HttpRequestInvoker.cs`
- `RequestInvokerFactory.cs`
- `HttpClientService.cs`
- `ServiceEndpoints.cs`
- `SRSService.cs`