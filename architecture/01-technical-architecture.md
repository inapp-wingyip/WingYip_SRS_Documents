# Technical Architecture

---

## Architecture Overview

The SRS is built using a **modular microservices-based architecture**, deployed via **Kubernetes** (AKS, Rancher, or OpenShift) for high availability, portability, and scalability. Each core module is deployed as a containerized service within the cluster.

The central data warehouse consolidates data from SAP, Korber WMS, OpSuite, and BI Database, serving as the **single source of truth** for all replenishment decisions.

---

## Logical Application Layers

### 1. Presentation Layer
- **React Web App** — SpaceMan, Admin Portal, Dashboard
- **React Native Android App** — Handheld RF devices

### 2. Application Layer (Microservices)
- Authentication & RBAC Service
- Product Inquiry Service
- Planogram Management Module (SpaceMan)
- Replenishment Engine (Sales + Store Walk-based)
- Workflow Engine (Pick, Bulk, Overstock)
- Notification & Messaging Module
- Order Management (Collection/Delivery)
- Audit & Reporting Engine

### 3. Integration Layer
- SAP Adapter (initial stock levels, product pricing)
- Korber Adapter (warehouse-level stock, location data)
- OpSuite Adapter (ePOS sales feed)
- Batch Scheduler (Sales Sync, Inventory Reconciliation)

### 4. Data Layer
- **SQL Server** (primary database, 2019/2022 Enterprise)
- Read replicas per site (optional)
- Caching Layer (Redis/Memcached)

---

## Technology Stack

| Component | Recommended | Alternatives |
|-----------|------------|--------------|
| Frontend (Web) | React 19 + TypeScript + RSBuild | Angular + .NET API |
| Frontend (HHD) | React Native 0.72.3 (Android) | Flutter |
| Backend Services | ASP.NET Core Web APIs | Java Spring Boot / Node.js |
| Database | MS SQL Server 2022 Enterprise Always On AG | PostgreSQL with Patroni |
| ORM | Entity Framework Core | Database-first DbContext generation |
| Workflow Orchestration | Apache Airflow | Quartz.NET / Hangfire |
| Auth & RBAC | Windows AD + ASP.NET Identity + Keycloak (HHD) | ADFS / Duende IdentityServer |
| Messaging | WebSocket (internal real-time) | MQTT / RabbitMQ |
| Reporting | SSRS (native mode) | Power BI Report Server / Metabase |
| Caching | Redis (local) | Memcached |
| Logging & Audit | Serilog + SQL | ELK Stack (self-hosted) |

---

## Data Warehouse Architecture

### Source Systems
- SAP → SQL Server (product, pricing, suppliers)
- Korber WMS → SQL Server (stock, warehouse)
- OpSuite → SQL Server (ePOS sales)

### ETL / Data Integration
| Component | Primary | Alternative |
|-----------|---------|-------------|
| ETL Platform | SQL Server Integration Services (SSIS) | Talend, Pentaho |
| Workflow Orchestration | Apache Airflow | Quartz.NET |
| Batch Scheduling | SQL Server Agent | Windows Task Scheduler |
| Data Quality | SSIS Data Quality Services | Talend DQ |
| Change Data Capture | SQL Server CDC | Custom triggers |

### Data Warehouse Core
| Component | Technology |
|-----------|-----------|
| Primary DW | SQL Server 2022 Enterprise (Always On AG) |
| Storage | SAN/NAS — High-performance SSD arrays |
| Backup | SQL Server Backup + Veeam |
| High Availability | Windows Server Failover Clustering |

---

## Analytics & Reporting

| Component | Technology |
|-----------|-----------|
| Reporting Engine | SQL Server Reporting Services (SSRS) |
| Analytics Platform | Power BI Report Server (On-premise) |
| OLAP Engine | SQL Server Analysis Services (SSAS) |
| Dashboard Framework | Custom ASP.NET Core + Chart.js/D3.js |

---

## Infrastructure

| Component | Technology |
|-----------|-----------|
| Container Platform | Red Hat OpenShift 4.12+ / Rancher Kubernetes |
| Alternative | Docker Swarm with Portainer |
| OS | Windows Server 2022 / RHEL 8/9 |
| Web Server | IIS 10 / Nginx |
| Load Balancer | HAProxy / F5 BIG-IP |
| Message Queue | RabbitMQ / Apache Kafka |

---

## Security

| Component | Implementation |
|-----------|---------------|
| Identity Management | Active Directory Domain Services (Windows Server 2022) |
| Authentication | ADFS (OAuth2/SAML), Keycloak (HHD) |
| Certificates | Windows Certificate Services (Internal PKI) |
| Network Security | Windows Firewall + pfSense |
| Encryption | TLS 1.3 in transit, SQL Server TDE at rest |

---

## Monitoring & Operations

| Component | Technology |
|-----------|-----------|
| Log Management | ELK Stack (self-hosted: Elasticsearch, Logstash, Kibana) |
| Metrics | Prometheus + Grafana |
| APM | Application Insights (self-hosted alternative) |
| Network Monitoring | Nagios / PRTG |
| CI/CD | Jenkins + GitLab CI/CD |
| Configuration | Ansible (Infrastructure as Code) |
| Container Registry | Harbor (self-hosted Docker registry) |
| Artifact Repository | Nexus / JFrog Artifactory |
| Version Control | GitLab CE (self-hosted) |

---

## Network Architecture

- **Private MPLS / SD-WAN** for primary WAN connectivity
- **Site-to-Site VPN** for securing remote site links
- No public internet exposure — fully air-gapped
- Multi-layer security (firewall + VPN + encryption)

---

## Cloud Deployment Option

An alternative **Microsoft Azure Stack** deployment option is documented with:
- Azure Synapse Analytics for data warehouse
- Azure Data Factory for ETL
- Azure SQL Database with private endpoints
- Azure Logic Apps for integration
- Azure Service Bus for messaging
- Azure Container Instances / AKS for compute

The primary deployment remains on-premise due to the private-network constraint.
