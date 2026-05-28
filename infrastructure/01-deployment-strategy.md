# Deployment Strategy & Infrastructure

---

## Deployment Approach

The SRS is deployed as an **on-premise** system with private-network-only access. Deployment follows a phased rollout strategy.

---

## Go-Live Plan for New DIDI Store

### Estimated Timeline (11 Weeks)

| Week | Activities |
|------|-----------|
| Week 1-2 | Product setup in SAP, OpSuite; Store creation in SRS DB; Store Layout design |
| Week 3-4 | ShopLocations/Planogram setup; Replen group; Bay group configuration |
| Week 5 | Pipeline validation; Configuration changes; User/role setup |
| Week 5-9 | Product load to store; Print label testing |
| Week 6-7 | InApp internal testing |
| Week 8-9 | UAT and business validation by WingYip |
| Week 10 | Production migration and smoke testing |
| Week 11 | Go-Live + Hypercare (post-go-live support) |

### Effort Estimates
| Activity | Estimated Hours |
|----------|----------------|
| Store layout development | 24 |
| Configuration changes, user/role setup | 16 |
| Pipeline validation | 40 |
| InApp testing | 80 |
| UAT / Production deployment / migration | 80 |
| Production smoke test | 40 |
| Hypercare | 40 |

---

## Go-Live Prerequisites

### WingYip Responsibilities
| Area | Task |
|------|------|
| Product Setup | Setup product data in SAP, OpSuite |
| Store Setup | Provide final production Store ID |
| Store Layout | Provide approved aisle/bay/store structure in spreadsheet |
| Planogram | Finalize and approve planogram (ShopLocations, Fill & Face data) |
| Printing | Test label printing at store |
| UAT | Provide business users for validation |
| Users | Provide operational users and required access roles |
| Sign-Offs | UAT and production readiness approvals |
| Freeze Window | Confirm deployment/go-live window |

### InApp Responsibilities
| Area | Task |
|------|------|
| Store Layout | Design and integrate layout to SRS (aisles, bays, sections, components, mappings) |
| Database | Populate aisle, bay, sections, components and mapping data |
| Pipeline | Pull product data from SAP, OpSuite via data pipelines |
| Shop Location | Use Copy Bay feature or create via Planogram |
| Master Data | Setup printer settings, GNFR, store settings |
| Users & Roles | Configure user accounts, roles, and access permissions |
| Integration | Validate SAP, Korber, OpSuite integration points |
| Data Validation | Validate data ingestion into Silver layer |
| Background Jobs | Validate replenishment and processing background jobs |
| Application | Validate replenishment, picking and all workflows end-to-end |
| Deployment | Production deployment and smoke testing |
| Hypercare | Post-go-live support and issue monitoring |

### Dependencies from WingYip
- Store ID (final production identifier)
- Approved aisle/bay/store layout structure
- Finalized and approved planogram (ShopLocations, Fill & Face data)
- Didi Store settings (business configurations)
- Master data availability (store/product/inventory in SAP/Korber/Opsuite)
- Business users for UAT participation
- Operational users and required access roles
- UAT and production readiness approvals
- Confirmation on deployment/go-live window

---

## Deployment Checklist

### Phase 1.1 (Deployed)
- Production deployment checklist exists and tracked
- Initial store deployments completed

### Key Deployment Artifacts
- Production Deployment Checklist (Phase 1.1) — tracked per store rollout
- Deployment Strategy Initial Draft — overall approach document

---

## Infrastructure Architecture

### Core Infrastructure

| Component | Specification |
|-----------|--------------|
| Container Platform | Red Hat OpenShift 4.12+ or Rancher Kubernetes |
| OS | Windows Server 2022 or RHEL 8/9 |
| Web Server | IIS 10 (Windows) or Nginx (Linux) |
| Load Balancer | HAProxy (open-source) or F5 BIG-IP (hardware) |
| Database | SQL Server 2022 Enterprise with Always On Availability Groups |
| Storage | SAN/NAS with high-performance SSD |
| Backup | SQL Server Backup + Veeam Backup & Replication |
| Message Queue | RabbitMQ or Apache Kafka |
| CI/CD | Jenkins + GitLab CI/CD |
| Container Registry | Harbor (self-hosted) |
| Configuration | Ansible (Infrastructure as Code) |
| Version Control | GitLab CE (self-hosted) |
| Artifact Repository | Nexus or JFrog Artifactory |

### Network
- Primary WAN: MPLS or SD-WAN (cost-effective)
- Remote sites: Site-to-Site VPN
- No public internet endpoints
- Multi-layer security: Windows Firewall + pfSense + VPN + encryption

### Security
- Identity: Active Directory Domain Services (Windows Server 2022)
- Authentication: ADFS (OAuth2/SAML) + Keycloak (HHD)
- Certificates: Internal PKI (Windows Certificate Services)
- Encryption: TLS 1.3 in transit, SQL Server TDE at rest

### Monitoring
- Logging: ELK Stack (Elasticsearch, Logstash, Kibana) — self-hosted
- Metrics: Prometheus + Grafana
- APM: Application Insights (self-hosted alternative)
- Network: Nagios or PRTG
- Database: SQL Server Management Studio + custom tools

---

## Infrastructure Documents

| Document | Description |
|----------|-------------|
| INFRA Tracker | Infrastructure deployment tracking |
| App Settings | Application configuration settings |
| Infrastructure - Confirmations and Requirements | Detailed infrastructure specifications |
| Infrastructure MoM | Infrastructure meeting minutes |
