# On-Premise Enterprise Architecture

---

## Deployment Constraint

The entire SRS operates within a **private network** with **no public internet exposure**. This drives all infrastructure decisions:
- No cloud endpoints
- Self-hosted everything (CI/CD, registry, monitoring, analytics)
- Internal PKI for certificates
- Site-to-Site VPN for inter-site connectivity

---

## Kubernetes Cluster Topology

### Preferred: Red Hat OpenShift 4.12+
- Production-grade Kubernetes with enterprise support
- Built-in monitoring, logging, and security
- Operator framework for database lifecycle management

### Alternative: Rancher Kubernetes
- Lighter operational footprint
- Multi-cluster management
- Good for mixed Windows/Linux environments

### Alternative: Docker Swarm
- With Portainer management
- Simpler operational model

---

## Database Deployment

### SQL Server 2022 Enterprise
- **Always On Availability Groups** for high availability
- **Windows Server Failover Clustering** (multi-node)
- **SAN/NAS Storage** with high-performance SSD arrays
- **SQL Server Agent** for batch scheduling
- **Transparent Data Encryption (TDE)** for data at rest

### Alternative: PostgreSQL 14+
- With Patroni clustering for HA
- Suitable if Linux-only deployment preferred

### Read Replicas (Optional)
- Per-site read replicas for low-latency queries
- Reduces load on primary write node

---

## Integration Architecture

```
┌─────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│     SAP     │   │ Korber WMS   │   │   OpSuite    │   │ BI Database  │
│  (Products, │   │ (Warehouse   │   │ (ePOS Sales) │   │ (Historical  │
│   Pricing)  │   │   Stock)     │   │              │   │   Sales)     │
└──────┬──────┘   └──────┬───────┘   └──────┬───────┘   └──────┬───────┘
       │                 │                  │                   │
       └─────────┬───────┴──────────────────┴───────────────────┘
                 │
          ┌──────▼──────┐
          │  SSIS / ETL │  ← Data Integration Layer
          │  CDC / DQ   │     SQL Server CDC, SSIS DQS
          └──────┬──────┘
                 │
          ┌──────▼──────┐
          │ Data Warehouse│ ← SQL Server 2022 Enterprise
          │  (SRS Core)  │     Always On AG, TDE
          └──────┬──────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
┌───▼───┐  ┌────▼────┐  ┌───▼────┐
│SRS Web│  │SRS Mobile│  │Reports │
│ Portal │  │  (HHD)  │  │(SSRS/PBI)│
└───────┘  └─────────┘  └────────┘
```

---

## Site Connectivity

| Site Type | Connectivity | Notes |
|-----------|-------------|-------|
| Main Office / DC (Birmingham) | Direct to cluster | Primary hosting |
| Superstores | MPLS / SD-WAN | Low-latency WAN |
| Warehouses | MPLS / Site-to-Site VPN | High-throughput needed |
| Remote Stores (Didi) | VPN tunnel | Lower bandwidth acceptable |

---

## Security Layers

1. **Network Perimeter**: Windows Firewall + pfSense (multi-layer)
2. **WAN Security**: Site-to-Site VPN + MPLS isolation
3. **Application Auth**: AD + ADFS + Keycloak (HHD) + 11-role RBAC
4. **Data Encryption**: TLS 1.3 in transit, SQL Server TDE at rest
5. **Certificate Management**: Internal PKI (Windows Certificate Services)
6. **Identity**: Active Directory Domain Services (Windows Server 2022)
