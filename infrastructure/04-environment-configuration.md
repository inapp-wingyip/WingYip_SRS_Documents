# Environment Configuration & Infrastructure Tracker

> Derived from `drive_raw/Documents/Infrastructure/AppSettings_.xlsx`, `drive_raw/Documents/Infrastructure/INFRA Tracker.xlsx`, `drive_raw/Documents/Infrastructure/Infrastructure - Confirmations and Requirements.docx`, `drive_raw/Documents/Infrastructure/Infrastructure -Minutes Of Meeting (MoM).docx`, and `WingYip_SRS_Infrastructure/DEPLOYMENT_GUIDE.md`.

---

## Environments

| Environment | Purpose | SQL Server | K8s Namespace |
|-------------|---------|------------|----------------|
| **Development** | Active development, unit testing | Dev SQL Server | `dev` |
| **Test** | Integration testing, automated tests | Test SQL Server | `test` |
| **UAT** | Business validation and sign-off | UAT SQL Server | `uat` |
| **Production** | Live operations, Always On AG | Prod SQL Server (`10.10.80.75:1433`) | `prod` |

Source: `WingYip_SRS_Infrastructure/DEPLOYMENT_GUIDE.md`

---

## Infrastructure Reference

### Server Infrastructure

Source: `drive_raw/Documents/Infrastructure/INFRA Tracker.xlsx`

| Component | Specification | Notes |
|-----------|--------------|-------|
| **SQL Server** | SQL Server 2022 Enterprise | Always On Availability Groups |
| **Primary DB Server** | `10.10.80.75:1433` | Production |
| **K8s Platform** | Red Hat OpenShift 4.12+ / Rancher | Container orchestration |
| **CI/CD** | Jenkins + GitLab CI/CD | Build and deploy pipeline |
| **GitOps** | ArgoCD | Kubernetes deployment sync |
| **Container Registry** | Harbor | Self-hosted Docker registry |
| **Artifact Repository** | Nexus / JFrog Artifactory | Build artifacts |
| **Version Control** | GitLab CE | Self-hosted |
| **Monitoring** | Prometheus + Grafana | Metrics |
| **Logging** | ELK Stack | Centralized logs |
| **APM** | Application Insights (self-hosted alternative) | App performance |

### Application Settings Reference

Source: `drive_raw/Documents/Infrastructure/AppSettings_.xlsx`

> **Note**: Contains environment-specific configuration values (connection strings, service URLs, caching config, etc.). The full spreadsheet should be consulted per environment. Key categories include:
> - Database connection strings per service
> - Keycloak realm/client configuration
> - RabbitMQ connection settings
> - Redis cache configuration
> - SSRS/Power BI Report Server URLs
> - SAP/Korber/OpSuite connection parameters
> - Logging levels per environment
> - CORS origins per environment

---

## Kubernetes Configuration

Source: `WingYip_SRS_Infrastructure/DEPLOYMENT_GUIDE.md`, `KeycloakAuthentication/k8s/`

### Microservice Deployments

| Service | Namespace | Image Registry | Replicas (Prod) |
|---------|-----------|---------------|-----------------|
| FrontendService | `prod` | Harbor | 2+ |
| AdministrationService | `prod` | Harbor | 2+ |
| AuthenticationService | `prod` | Harbor | 2+ |
| ProductService | `prod` | Harbor | 2+ |
| SpacemanService | `prod` | Harbor | 2+ |
| ReplenishmentService | `prod` | Harbor | 2+ |
| StoreOperationsService | `prod` | Harbor | 2+ |
| StockControlService | `prod` | Harbor | 2+ |
| PrintService | `prod` | Harbor | 2+ |
| AuditService | `prod` | Harbor | 2+ |
| Keycloak | `prod` | Harbor | 2+ |

### K8s Naming Conventions

Source: `WingYip_SRS_Infrastructure/KeycloakAuthentication/k8s/NAMING_CONVENTIONS.md`

> See the Infrastructure repo's `NAMING_CONVENTIONS.md` for detailed K8s resource naming rules.

---

## Keycloak Configuration

Source: `WingYip_SRS_Infrastructure/KeycloakAuthentication/`

| Parameter | Value |
|-----------|-------|
| **Realm** | WingYip SRS |
| **Identity Provider** | Active Directory (LDAP/AD bridge) |
| **SPN** | `HTTP/keycloak.wingyip.local@WINGYIP.LOCAL` |
| **Token Signing** | RS256 |
| **Session Timeout** | Per configuration (see Keycloak realm settings) |
| **Password Policy** | 6-digit numeric PIN for mobile |

Key deployment docs in Infrastructure repo:
- `KeycloakAuthentication/DEPLOYMENT.md` — Keycloak deployment
- `KeycloakAuthentication/PRODUCTION_READY.md` — Production checklist
- `KeycloakAuthentication/CI_CD_GUIDE.md` — CI/CD pipeline
- `KeycloakAuthentication/k8s/NAMING_CONVENTIONS.md` — K8s naming

---

## Environment Configuration Per Service

Source: `drive_raw/Documents/Infrastructure/AppSettings_.xlsx`

### Common Configuration Sections

Every microservice requires these configuration categories:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=...;Database=WingYip.SRS.{ServiceName};..."
  },
  "Keycloak": {
    "Realm": "wingyip-srs",
    "AuthServerUrl": "https://keycloak.wingyip.local/auth",
    "ClientId": "...",
    "ClientSecret": "..."
  },
  "RabbitMQ": {
    "HostName": "...",
    "UserName": "...",
    "Password": "...",
    "VirtualHost": "/"
  },
  "Serilog": {
    "MinimumLevel": "Information",
    "WriteTo": ["SqlServer", "Elasticsearch", "Console"]
  },
  "Redis": {
    "ConnectionString": "...",
    "InstanceName": "SRS-..."
  },
  "CorsOrigins": ["https://srs.wingyip.local"]
}
```

> **Exact values are environment-specific.** Consult `AppSettings_.xlsx` and the Infrastructure repo per environment.

---

## Raw Source Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Documents/Infrastructure/AppSettings_.xlsx` | Application settings per environment |
| `drive_raw/Documents/Infrastructure/INFRA Tracker.xlsx` | Infrastructure tracking spreadsheet |
| `drive_raw/Documents/Infrastructure/Infrastructure - Confirmations and Requirements.docx` | Infrastructure requirements and confirmations |
| `drive_raw/Documents/Infrastructure/Infrastructure -Minutes Of Meeting (MoM).docx` | Infrastructure meeting minutes |
| `WingYip_SRS_Infrastructure/DEPLOYMENT_GUIDE.md` | Full deployment guide |
| `WingYip_SRS_Infrastructure/KeycloakAuthentication/DEPLOYMENT.md` | Keycloak deployment docs |
| `WingYip_SRS_Infrastructure/KeycloakAuthentication/PRODUCTION_READY.md` | Production readiness checklist |

---

## Cross-References

- [On-Premise Architecture](./02-enterprise-onprem.md) — Network, security layers, connectivity
- [DevOps Deployment](../infrastructure/02-devops-deployment.md) — Jenkins, ArgoCD, CI/CD
- [Security Standards](./13-security-standards.md) — Security architecture
- [Coding Standards](./11-coding-standards.md) — BE repo implementation docs