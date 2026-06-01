# ADR-003. Keycloak with Active Directory and ADFS

- **Status:** accepted
- **Date:** 2024-02-01
- **Supersedes:** N/A

## Context

WingYip required a centralized authentication and authorization system that integrated with existing enterprise identity infrastructure (Active Directory + ADFS). The system needed to support 12 role types with a four-tier privilege model, JWT token propagation across microservices, and single sign-on for both web and mobile users.

Key constraints:
- Must integrate with existing Active Directory (AD) and ADFS
- On-premise deployment — no cloud IAM
- Support for OAuth2 / OpenID Connect
- Token-based auth for API-to-API service communication
- Role-based access control (RBAC) with 12 role types

## Decision

We will use **Keycloak** as the Identity and Access Management (IAM) solution with the following architecture:

1. **Keycloak Server**: Deployed on-premise as a dedicated authentication service
2. **AD/ADFS Federation**: Keycloak federates with Active Directory via LDAP and ADFS via SAML
3. **JWT Tokens**: Access tokens (JWT) propagated via HTTP Authorization header; refresh tokens managed client-side
4. **Security.Core Library**: Shared `WingYip.SRS.Security.Core` library provides JWT validation, RBAC attributes, and permission enforcement
5. **Role Types**: 12 roles (SUPERADMIN, SCAT, CAT, SM, SS, SC, CWE, CS, SOCO, SALES, FINOP, ADMIN) with four-tier privilege model (No Access → View → Full Access → Additional)
6. **Service-to-Service Auth**: Internal service calls use client credentials grant with service accounts

## Consequences

**Positive:**
- Single sign-on across web, mobile, and API consumers
- Standard OAuth2/OIDC protocol support
- Flexible role mapping from AD groups to application roles
- Token-based auth eliminates session state in services

**Negative:**
- Keycloak is a single point of failure — requires HA deployment
- Token validation overhead on every API call
- Complex AD/ADFS federation configuration
- Token size can become large with many roles/permissions

**Future constraints:**
- Any auth mechanism change (e.g., Kerberos SSO) requires a new ADR
- New role types require DBA updates to seed data and Security.Core attribute additions
- Token expiration and refresh logic must be consistent across all clients
