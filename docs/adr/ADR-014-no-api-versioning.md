# ADR-014. No API Versioning Strategy

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS backend exposes 55+ controllers with 400+ REST endpoints across 14 microservices. As the platform evolves, APIs must change to accommodate new features, field additions, and breaking changes.

**Current state:**
- Zero `AddApiVersioning` registrations across all services
- Zero `[ApiVersion]` or `[MapToApiVersion]` attributes
- All controllers use flat routes: `[Route("api/[controller]")]`
- No version segment in URL paths
- PROJECT.md states "Versioning: URL path (/v1/)" but this is aspirational, not implemented

**Why no versioning exists:**
- Platform is still in active development with coordinated frontend/handheld releases
- All API consumers (web app, handheld, BFF) are internal and deployed together
- Breaking changes have been managed via coordinated deployment windows

## Decision

We explicitly accept **no API versioning** for the current phase with a sunset condition:

1. **Current Phase (Accepted)**: No API versioning required while all consumers are internal and co-deployed
2. **Breaking Change Management**: Breaking changes require:
   - Coordinated deployment of backend + all consumers
   - Frontend and handheld teams notified in advance
   - Update of API integration tests before deployment
3. **Future Requirement**: API versioning MUST be implemented before:
   - Any external/third-party API consumer is introduced
   - Mobile app store releases decouple from backend deployment
   - Long-lived handheld installations in the field (cannot force immediate update)

## Consequences

**Positive:**
- Reduced code complexity (no version mapping, no duplicate controllers)
- Faster development velocity (no need to maintain multiple API versions)
- Smaller controller surface area
- Internal consumers can be updated in lockstep with backend

**Negative:**
- **Breaking changes require coordinated deployment** of all consumers (frontend, handheld, any internal tools)
- No path for gradual consumer migration
- Handheld devices in stores cannot be forced to update immediately (app store approval cycles, device access constraints)
- API documentation (Swagger) shows all endpoints as current version only
- No clear deprecation policy for old field formats

**Future constraints:**
- API versioning becomes MANDATORY before external API exposure or mobile decoupling
- When versioning is introduced, prefer URL path versioning (`/v1/`, `/v2/`) over header-based versioning
- All new controllers must be designed with versioning in mind (even if not yet implemented)
- Consider versioning at the BFF layer first before adding to individual microservices

## Remediation Trigger

Create a new ADR for API versioning when any of the following occur:
- External partner integration request
- Mobile app release cycle decouples from backend deployment
- Handheld app requires backward compatibility for field installations
