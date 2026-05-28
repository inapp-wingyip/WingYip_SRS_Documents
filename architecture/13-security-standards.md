# Security Architecture & Standards

> Derived from `drive_raw/Documents/Design/Administration, Authentication and RBAC/` (Kerberos SSO, Keycloak, Authentication docs), `drive_raw/Documents/Design/Analysis/Wing Yip SRS – On-Prem Enterprise Architecture - v.1.2.docx`, `drive_raw/Documents/Infrastructure/Infrastructure - Confirmations and Requirements.docx`, `drive_raw/Archived_19-Dec-2025/WingYip_files/` (SRS PDA Authentication, NW connectivity).

---

## Security Architecture Overview

The SRS operates entirely within a **private network** with **no public internet exposure**. Security is implemented in layers — network perimeter, transport, application, data, and identity.

```
┌──────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                        │
│                                                          │
│  Layer 5: Identity      │ AD/ADFS + Keycloak + 12-role RBAC│
│  ─────────────────────────────────────────────────────── │
│  Layer 4: Application   │ JWT validation, API gateway, CORS│
│  ─────────────────────────────────────────────────────── │
│  Layer 3: Transport     │ TLS 1.3, Internal PKI certificates│
│  ─────────────────────────────────────────────────────── │
│  Layer 2: Network       │ MPLS/SD-WAN, Site-to-Site VPN    │
│  ─────────────────────────────────────────────────────── │
│  Layer 1: Perimeter     │ Windows Firewall + pfSense       │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Network Security

Source: `drive_raw/Documents/Design/Analysis/Wing Yip SRS – On-Prem Enterprise Architecture - v.1.2.docx`, `drive_raw/Documents/Infrastructure/Infrastructure - Confirmations and Requirements.docx`

### Network Zones

| Zone | Description | Access |
|------|-------------|--------|
| **DMZ** | None — no public-facing services | N/A (air-gapped) |
| **Application Zone** | K8s cluster, microservices | Internal only |
| **Data Zone** | SQL Server, file storage | App zone only |
| **Integration Zone** | Source system connectors (SAP, Korber, OpSuite) | App zone to source |
| **Management Zone** | CI/CD, monitoring, Keycloak | Admin access only |

### Connectivity Rules

| Source → Destination | Protocol | Purpose |
|---------------------|----------|---------|
| Web Browser → Web Portal | HTTPS (TLS 1.3) | User access |
| HHD → API Gateway | HTTPS (TLS 1.3) | Mobile access |
| Microservice → SQL Server | TDS (encrypted) | Database access |
| Microservice → RabbitMQ | AMQPS | Async messaging |
| Service → Service | HTTP (internal) | REST calls |
| K8s → Harbor | HTTPS | Container registry |
| CI/CD → GitLab | SSH/HTTPS | Source control |
| Integration → SAP | SQL Native Client | Data extraction |
| Integration → Korber | SQL Native Client | Data extraction |
| Integration → OpSuite | SQL Native Client | Data extraction |

### Key Network Configuration

Source: `drive_raw/Archived_19-Dec-2025/WingYip_files/To Wing Yip/WingYip_InApp_NW_connectivity_recommendation.docx`

- **No public internet exposure** — All services on private network
- **MPLS/SD-WAN** for inter-site connectivity
- **Site-to-Site VPN** for Didi store connections
- **Windows Firewall + pfSense** at perimeter
- **Micro-segmentation** available within K8s (Network Policies)

---

## Identity & Access Management

Source: [Authentication & RBAC](./06-authentication-rbac.md) (full details there)

### Authentication Flows

| Platform | Method | Provider |
|----------|--------|----------|
| **Web Portal** | Windows Integrated Auth / ADFS OAuth2 | Active Directory |
| **Android HHD** | Keycloak (Crown ID + 6-digit PIN; Kerberos SSO planned) | Keycloak (federated to AD) |

### Kerberos SSO Configuration (Planned — Not Yet Configured)

Source: `drive_raw/Documents/Design/Administration, Authentication and RBAC/Kerberos SSO Integration with Keycloak.docx`, `Kerberos SSO Integration with Keycloak - AD setup.docx`

| Component | Value |
|-----------|-------|
| Keycloak SPN | `HTTP/keycloak.wingyip.local@WINGYIP.LOCAL` |
| Realm | `WINGYIP.LOCAL` |
| Keytab | Generated and deployed to Keycloak server |
| Browser Config | Chrome on HHD configured for Kerberos negotiation |
| Fallback | Form-based login if Kerberos fails (non-domain devices) |
| Token Format | JWT (RS256 signing) |
| Password Policy | Six-digit numeric PIN for mobile; mandatory reset on first login |

---

## Data Protection

### Encryption Standards

| Layer | Standard | Implementation |
|-------|----------|----------------|
| **In Transit** | TLS 1.3 | All service communication encrypted |
| **At Rest** | SQL Server TDE | Transparent Data Encryption on all databases |
| **Token Storage** | Android Keystore | Secure key storage on HHD devices |
| **Certificate Mgmt** | Windows Certificate Services | Internal PKI for ADFS, services, VPN |
| **Secrets** | K8s Secrets + external vault | Application secrets managed in K8s |

### Data Classification

| Classification | Examples | Handling |
|----------------|----------|----------|
| **Confidential** | User credentials, financial data | Encrypted at rest and in transit; RBAC limited |
| **Internal** | Stock levels, replenishment data | Encrypted in transit; RBAC controlled |
| **Restricted** | Audit logs, integration keys | Need-to-know access; audit trail |
| **Public** | Product descriptions (non-sensitive) | Standard access controls |

### Data Masking in Non-Production

- All non-production environments MUST mask production data
- PII fields (CrownId, email, phone) must be anonymized
- Financial data must be scrambled
- Data masking rules applied during ETL to non-prod environments

---

## Application Security

### API Security

| Measure | Implementation |
|---------|----------------|
| Authentication | AD/ADFS (web) or Keycloak JWT (mobile) |
| Authorization | RBAC engine — 12 roles × 15 scopes, four-tier privileges |
| Input Validation | FluentValidation in MediatR pipeline |
| SQL Injection Prevention | Entity Framework Core parameterized LINQ queries |
| CORS | Configured per environment, restricted to known origins |
| Rate Limiting | Configurable per endpoint |
| HTTPS Only | TLS 1.3 required, no HTTP |

### OWASP Coverage

| Risk | Mitigation |
|------|-----------|
| Injection | Entity Framework Core LINQ queries (parameterized automatically) |
| Broken Authentication | ADFS + Keycloak, JWT with rotation |
| Sensitive Data Exposure | TDE at rest, TLS 1.3 in transit |
| XML External Entities | No XML parsing; JSON only |
| Broken Access Control | RBAC engine enforced per request |
| Security Misconfiguration | Standardized K8s configs, Ansible IaC |
| Cross-Site Scripting | React auto-escaping, input sanitization |
| Insecure Deserialization | No binary deserialization; JSON with type validation |
| Known Vulnerabilities | Dependency scanning in CI/CD |
| Insufficient Logging | Serilog + ELK centralized logging |

---

## Infrastructure Security

### Kubernetes Security

| Aspect | Implementation |
|--------|---------------|
| Container Registry | Harbor (self-hosted, private) |
| Image Scanning | Trivy or Harbor vulnerability scanning |
| Network Policies | K8s NetworkPolicy for micro-segmentation |
| Resource Limits | CPU/Memory limits per pod |
| RBAC | K8s RBAC for cluster access |
| Secrets | K8s Secrets with external vault option |
| Pod Security | Non-root containers, read-only FS where possible |

### CI/CD Security

| Aspect | Implementation |
|--------|---------------|
| Source Control | GitLab CE (self-hosted) |
| CI/CD | Jenkins + GitLab CI/CD |
| Artifact Storage | Nexus / JFrog Artifactory |
| Deployment | ArgoCD (GitOps) |
| Container Registry | Harbor (self-hosted) |
| Infrastructure as Code | Ansible |

---

## Vulnerability Management

Source: `drive_raw/Documents/Infrastructure/Infrastructure - Confirmations and Requirements.docx`

| Activity | Frequency | Responsibility |
|----------|-----------|----------------|
| Dependency vulnerability scan | Every build (CI) | Development team |
| Container image scan | Every build (CI) | DevOps |
| Infrastructure security review | Monthly | IT Admin |
| Penetration testing | Quarterly | External |
| Access review (RBAC audit) | Monthly | IT Admin + Super User |
| Certificate rotation | Per policy (annual minimum) | IT Admin |

---

## Raw Source Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Documents/Design/Administration, Authentication and RBAC/Kerberos SSO Integration with Keycloak.docx` | Kerberos SSO integration specification |
| `drive_raw/Documents/Design/Administration, Authentication and RBAC/Kerberos SSO Integration with Keycloak - AD setup.docx` | AD-side SPN and keytab configuration |
| `drive_raw/Documents/Design/Administration, Authentication and RBAC/WingYip - Keycloak Authentication Architecture.docx` | Full Keycloak architecture |
| `drive_raw/Documents/Design/Administration, Authentication and RBAC/Wing Yip - Handheld Device Authentication.docx` | HHD authentication design |
| `drive_raw/Documents/Design/Administration, Authentication and RBAC/LLD - Web and HHD Authentication.docx` | Combined web + HHD auth LLD |
| `drive_raw/Documents/Infrastructure/Infrastructure - Confirmations and Requirements.docx` | Infrastructure security requirements |
| `drive_raw/Documents/Infrastructure/Infrastructure -Minutes Of Meeting (MoM).docx` | Infrastructure meeting minutes |
| `drive_raw/Documents/Infrastructure/INFRA Tracker.xlsx` | Infrastructure tracking |
| `drive_raw/Documents/Infrastructure/AppSettings_.xlsx` | Application settings reference |
| `drive_raw/Archived_19-Dec-2025/WingYip_files/To Wing Yip/WingYip_InApp_NW_connectivity_recommendation.docx` | Network connectivity recommendations |

---

## Cross-References

- [Authentication & RBAC](./06-authentication-rbac.md) — Full auth flows, role definitions
- [On-Premise Architecture](./02-enterprise-onprem.md) — Security layers, site connectivity
- [Technical Architecture](./01-technical-architecture.md) — Tech stack security components
- [DevOps Deployment](../infrastructure/02-devops-deployment.md) — CI/CD pipeline security
- [Coding Standards](./11-coding-standards.md) — OWASP mitigations in code