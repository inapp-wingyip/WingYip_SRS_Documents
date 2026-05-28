# Authentication, SSO & RBAC Architecture

> Derived from LLD documents in `drive/Documents/Design/Administration, Authentication and RBAC/`, `WingYip_files/To Wing Yip/`, and BRD v3.1.

---

## Authentication Architecture Overview

The SRS uses a **dual authentication model** — Windows AD for web users, Keycloak for handheld devices — unified under an RBAC framework with 12 role types and four-tier privileges.

```
┌─────────────────────────────────────────────────────┐
│                    CLIENTS                           │
│   ┌──────────────┐          ┌──────────────────┐     │
│   │  Web Browser │          │  Android HHD App │     │
│   └──────┬───────┘          └────────┬─────────┘     │
│          │                           │               │
│          ▼                           ▼               │
│   ┌──────────────┐          ┌──────────────────┐     │
│   │  AD / ADFS   │          │    Keycloak       │     │
│   │  (OAuth2/    │          │  (Kerberos SSO)   │     │
│   │   SAML 2.0)  │          │                   │     │
│   └──────┬───────┘          └────────┬─────────┘     │
│          │                           │               │
│          └───────────┬───────────────┘               │
│                      ▼                               │
│          ┌───────────────────────┐                   │
│          │  SRS Auth Service     │                   │
│          │  (JWT / Cookie Token) │                   │
│          └───────────┬───────────┘                   │
│                      ▼                               │
│          ┌───────────────────────┐                   │
│          │  RBAC Engine          │                   │
│          │  12 Roles × 15 Scopes │                   │
│          └───────────────────────┘                   │
└─────────────────────────────────────────────────────┘
```

---

## Web Authentication (AD / ADFS)

### Flow
1. User navigates to SRS web portal
2. Browser redirects to ADFS login page (Windows-integrated auth or form-based)
3. ADFS authenticates against **Active Directory Domain Services** (Windows Server 2022)
4. On success, ADFS issues **OAuth2 access token / SAML 2.0 assertion**
5. SRS Auth Service validates token and creates session (Cookie or JWT)
6. RBAC engine evaluates user's roles and permissions

### Key Points
- **AD integration**: Auto-fills First Name, Last Name from AD on user creation
- **Crown ID**: Unique employee identifier — mandatory for all users
- **Email**: Applicable only for AD/web users (not HHD)
- **ADFS Protocols**: OAuth2, SAML 2.0, WS-Federation
- **Internal PKI**: Windows Certificate Services issues certs for ADFS and service communication

---

## HHD Authentication (Keycloak)

### Flow
1. User opens Android app on handheld device
2. App redirects to **Keycloak** login (Crown ID + 6-digit PIN; Kerberos SSO planned)
3. Keycloak authenticates and issues **JWT access token + refresh token**
4. App stores tokens; includes access token in all API calls
5. Token refresh handled automatically; re-auth on expiry

### Keycloak Configuration
- **REALM**: Dedicated WingYip SRS realm
- **Identity Provider**: Federated with Active Directory (LDAP/AD bridge)
- **Kerberos SSO**: Planned — auto-login when device is domain-joined on private network (not yet configured in current deployment)
- **Token Format**: JWT (RS256 signing)
- **Session Management**: SSO session timeout, access token lifespan, refresh token rotation
- **Password Policy**: Six-digit numeric PIN for mobile; mandatory reset on first login

### Kerberos SSO Integration (Planned — Not Yet Configured)

**Note**: Kerberos SSO is designed and specified but not currently deployed in the Keycloak environment. The design documents below describe the planned architecture.
- **AD Setup**: Service Principal Name (SPN) configured in Active Directory for Keycloak
- **Keycloak SPN**: `HTTP/keycloak.wingyip.local@WINGYIP.LOCAL`
- **Keytab**: Generated and deployed to Keycloak server
- **Browser**: Chrome on HHD devices configured for Kerberos negotiation
- **Fallback**: Form-based login if Kerberos fails (non-domain devices)

### Architecture Documents
| Document | Description |
|----------|-------------|
| Kerberos SSO Integration with Keycloak.docx | SSO integration specification |
| Kerberos SSO Integration with Keycloak - AD setup.docx | AD-side SPN and keytab configuration |
| WingYip - Keycloak Authentication Architecture.docx | Full Keycloak architecture |
| Wing Yip - Handheld Device Authentication.docx | HHD auth design |
| Wing Yip - Handheld Device Authentication Visual Diagram.png | Visual auth diagram |
| LLD - Web and HHD Authentication.docx | Combined web + HHD auth LLD |
| SRS PDA Authentication & Session Management.docx | PDA session management (archived) |

---

## RBAC Engine

### Role Definitions (12 Roles — 11 Business + IT Admin)

| Role | Scope | Description |
|------|-------|-------------|
| **Super User** | Global | Full system access — all modules, all stores |
| **Sr CATMAN** | Global | Planogram governance, product layout decisions |
| **CATMAN** | Global | Category management, planogram operations (auto-applied across all stores) |
| **SOCO** | Store | Stock ordering coordination, replenishment oversight |
| **Store Manager** | Store | Overall store operations, approvals |
| **Store Supervisor** | Store | Store floor supervision |
| **Stock Control** | Store | Stock adjustments and investigations |
| **Customer Warehouse Ops** | Store | Warehouse inventory operations |
| **Customer Service** | Store | Customer-related tasks |
| **Sales** | Store | Limited operational data access |
| **Finance Ops** | Store | Financial analysis and reporting |
| **IT Admin** | Global | System administration, user access management |

### Four-Tier Privilege Model

| Level | Permission | Description |
|-------|-----------|-------------|
| **No Access** | — | Section/menu hidden or disabled |
| **View** | V | Read-only — no modifications allowed |
| **Full Access** | F | Create, edit, update, delete |
| **Additional** | A | Approve, Reject, Publish, Validate |

### RBAC Module Scopes (15 Scopes)
1. Admin Module — User Management
2. Spaceman / Planogram
3. Planogram Management
4. Store Layout
5. Shelf Edge Labels (SEL)
6. Product Module
7. Finance
8. Store Walk
9. Daily Processes
10. Stock & GNFR Management
11. Incoming Deliveries
12. Stock Investigations
13. Didi Admin Store Operations
14. Customer Warehouse Functions
15. Customer Warehouse Layout

### Key RBAC Rules
- **FR-RBAC-01**: Role-based menu visibility — unauthorized menus are hidden
- **FR-RBAC-02**: Full, View-only, or No Access at menu AND action level
- **FR-RBAC-03**: Multi-role assignment per store — highest permission wins (CR49)
- **FR-RBAC-04**: Global roles (CATMAN) automatically apply across all stores
- Users must explicitly switch store context when multi-store assigned
- SuperUser creates all roles; CatMan creates SOCOs; Store Manager creates store-level roles

### Multi-Role Assignment (CR49)
- Single user can hold multiple roles within same store
- Permission evaluation: highest privilege across all assigned roles applied
- Example: User has both Stock Control (View on Finance) and Finance Ops (Full on Finance) → Full Access on Finance

---

## User Management

### User Creation Flow
1. Enter **Crown ID** (mandatory unique identifier)
2. Toggle **AD Integration** → auto-fills First Name, Last Name
3. Assign **Role(s)** per store
4. Set **6-digit PIN** for mobile authentication (mandatory reset on first login)
5. Configure **Multi-Store Access** if applicable
6. **Short Name** used for screen display and audit logs

### User Management LLD References
| Document | Description |
|----------|-------------|
| WingYip - User Management Module_.docx | Full user management module design |
| LLD - Global CATMAN Role with Multi-Role Assignment per Store.docx | Multi-role design |
| LLD - Administration.docx | Admin module LLD |

---

## Network Security for Authentication

| Layer | Implementation |
|-------|---------------|
| WAN | MPLS / SD-WAN + Site-to-Site VPN |
| Perimeter | Windows Firewall + pfSense |
| App Auth | AD + ADFS + Keycloak |
| Transport | TLS 1.3 |
| Token Storage | Secure storage on device (Android Keystore) |
| Session | SSO timeout + refresh token rotation |
| Audit | All auth events logged centrally |

---

## Cross-References

- [Technical Architecture](./01-technical-architecture.md) — Overall tech stack
- [On-Premise Architecture](./02-enterprise-onprem.md) — Security layers
- [Microservices Design](./03-microservices-design.md) — Auth service in microservices
- [RBAC Functional Spec](../requirements/02-functional-modules.md#1-user-management--rbac) — Detailed functional rules
- [BRD Summary](../requirements/01-brd-summary.md) — Business rules for RBAC