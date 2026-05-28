# WingYip SRS — Project Overview

## Executive Summary

The **Stock Replenishment System (SRS)** is an enterprise-grade solution built by **InApp Information Technologies** for **WingYip**, a UK-based Oriental grocery retail chain operating across four superstore sites (Birmingham, Manchester, Croydon, Cricklewood) plus remote Didi stores.

The SRS consolidates data from SAP (products & pricing), Korber WMS (warehouse stock), OpSuite (sales/EPOS transactions), and a BI Database (historical sales) into a centralized data warehouse, enabling accurate, consistent, and unified decision-making across all stores and warehouses.

---

## System Scope

### Web Application (React + TypeScript + RSBuild)
- SpaceMan (Planogram Management)
- Admin Portal & Configuration
- Replenishment Dashboard
- Product Enquiry
- Reporting & Analytics (SSRS / Power BI)

### Mobile Application (React Native Android)
- Store Walk operations
- Replenishment picking
- Handheld Device (HHD) workflows
- Shelf Edge Label printing
- Stock counting & PI
- Didi Store operations

### Integration Touchpoints
- **SAP** — Product master, pricing, suppliers
- **Korber WMS** — Warehouse stock, location data
- **OpSuite** — ePOS sales transactions
- **BI Database** — Historical sales data
- **Active Directory** — User identity & SSO (web)
- **Keycloak** — HHD authentication
- **SSRS / Power BI Report Server** — Reporting

---

## Architecture Principles

1. **Private Network Only** — No public internet exposure; MPLS/SD-WAN for WAN
2. **Microservices-Based** — Modular, independently deployable services via Kubernetes
3. **Database per Service** — No shared DB coupling; CQRS pattern for read/write separation
4. **Medallion Architecture** — Bronze (raw) → Silver (clean) → Gold (analytics) data flow
5. **High Availability** — Kubernetes orchestration, SQL Server Always On Availability Groups
6. **RBAC** — 12 role types (11 business + IT Admin) with four-tier privilege model (No Access / View / Full / Additional)
7. **Entity Framework Core** — Database-first DbContext generation, no raw SQL strings
8. **Hybrid Communication** — REST (sync) + RabbitMQ (async) + WebSocket (real-time)

---

## Key Stakeholders

| Role | Responsibility |
|------|----------------|
| **Super User** | Full system access |
| **Sr CATMAN** | Senior category management, planogram governance |
| **CATMAN** | Category management, planogram operations |
| **SOCO** | Stock ordering coordination, replenishment oversight |
| **Store Manager** | Store operations management, approvals |
| **Store Supervisor** | Store floor supervision |
| **Stock Control** | Stock adjustments and investigations |
| **Customer Warehouse Ops** | Warehouse inventory operations |
| **Customer Service** | Customer-related tasks |
| **Sales** | Limited operational access |
| **Finance Ops** | Financial analysis and reporting |
| **IT Admin** | System administration |

---

## Document Versions

| Document | Current Version | Date |
|----------|----------------|------|
| BRD | v3.1 | 23-Mar-2026 |
| BRD | v2.0 | 12-Oct-2025 |
| Technical Architecture | v1.0 | 2025 |
| Data Workflow Design | v1.0 | 06-Feb-2026 |
| Data Migration Design | v1.0 | — |
| Enterprise Architecture | v1.2 | 2025 |

---

## Project Timeline

| Milestone | Status |
|-----------|--------|
| Discovery & Kickoff | Completed (Oct-Nov 2025) |
| Phase 1.1 | Deployed |
| Phase 1.2 | High-level plan exists |
| Phase 3a Demo | Completed (8-Dec-2025) |
| Sprint 1-3 | Completed |
| Phase 1 UAT2 | QA release notes available |
| Phase 1 UAT3 | Team handbook created |
| Didi Store Go-Live | Planned (11-week cycle) |
