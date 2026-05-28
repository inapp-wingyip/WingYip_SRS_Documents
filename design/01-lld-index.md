# Low-Level Design Documents — Complete Index

> All documents are located in the project's design repository. File names match the actual document inventory.

---

## Architecture & Foundations

| Document | Description |
|----------|-------------|
| ADR.docx | Architecture Decision Records |
| LLD Template.docx | Standard LLD template for all modules |
| Master Data.xlsx | Master data reference spreadsheet |
| Microservices Architecture - Design Specification.docx | Full microservices design specification |
| Copy of Microservices Architecture - Design Specification.docx | Duplicate copy of above |
| LLD - Centralized Logging & Monitoring.docx | Error handling, Serilog, Logstash, Elasticsearch, Kibana |

---

## Administration & Authentication

| Document | Description |
|----------|-------------|
| LLD - Administration.docx | Administration module design |
| LLD - Web and HHD Authentication.docx | Web and handheld device authentication |
| LLD - Global CATMAN Role with Multi-Role Assignment per Store.docx | CATMAN global role and multi-role | 
| Kerberos SSO Integration with Keycloak.docx | SSO integration specification |
| Kerberos SSO Integration with Keycloak - AD setup.docx | Active Directory setup for Kerberos SSO |
| WingYip - Keycloak Authentication Architecture.docx | Keycloak authentication architecture |
| Wing Yip - Handheld Device Authentication.docx | HHD authentication design |
| Wing Yip - Handheld Device Authentication Visual Diagram.png | HHD auth visual diagram |
| WingYip - User Management Module_.docx | User management module design |
| Untitled document.docx | Additional admin/auth notes |

---

## Admin Menu

| Document | Description |
|----------|-------------|
| LLD - Other Store Admin & Didi Store Admin Menu.docx | Admin menu for other stores and Didi stores |
| Edit Fill Face.docx | Edit fill face functionality |
| SKU Diagnostics.docx | SKU diagnostic tool |
| Store Configurations.docx | Store configuration settings |

---

## Replenishment (Core)

| Document | Description |
|----------|-------------|
| LLD - Replenishment Module - General.docx | General replenishment module design |
| LLD Replenishment Group Details.docx | Replenishment group structure and details |
| LLD - Sales Based Stock Replenishment.docx | Sales-based replenishment design |
| LLD - Low _ No Stock _ Sales Replenishment - BG Process.docx | Low/No stock background process |
| LLD - Stock Replenishment.docx | Stock replenishment operations |

---

## Replenishment (Bulk & Warehouse)

| Document | Description |
|----------|-------------|
| LLD - Bulk Replenishment - Pallet.docx | Pallet-based bulk replenishment |
| LLD - Move From Overstock.docx | Move products from overstock to pick-face |
| LLD - Move To Pick Location.docx | Move products to pick locations |
| LLD - Put away.docx | Put-away process |
| LLD - Release Locked Replen Groups.docx | Unlocking locked replenishment groups |

---

## Didi Store

| Document | Description |
|----------|-------------|
| LLD - Daily Process.docx | Daily process for Didi store operations |
| LLD - Check Case Replen Requests.docx | Check case replenishment requests |
| LLD - Didi Schedule.docx | Didi store scheduling |
| LLD - Emergency Order.docx | Emergency order processing |
| LLD - Excess Stock.docx | Excess stock management |
| LLD - Manual Order.docx | Manual order creation |
| LLD - SKU Diagnostic.docx | SKU diagnostics for Didi stores |
| LLD - Stock adjustment Log.docx | Stock adjustment logging |

---

## Stock Control & SOCO

| Document | Description |
|----------|-------------|
| LLD - Stock Control.docx | Stock control and discrepancy management |
| LLD - Customer Warehouse Mapping.docx | Customer-to-warehouse mapping |
| LLD - Stock Control.docx (SOCO) | SOCO stock control integration |

---

## Store Operations

| Document | Description |
|----------|-------------|
| LLD - Store Walk.docx | Store walk operations and workflows |
| LLD - Print Hot Food Labels.docx | Hot food label printing |

---

## Shelf Edge Label Printing

| Document | Description |
|----------|-------------|
| LLD - Shelf Edge Label Printing.docx | Main SEL printing design |
| LLD - Print Service.docx | Print service component design |
| LLD - Manifest PDF.docx | Manifest PDF generation design |

---

## Store Layout & Bay Group

| Document | Description |
|----------|-------------|
| LLD - Store Layout.docx | Store layout design and management |
| LLD - BayGroup.docx | Bay group management |
| StoreLayoutDesign.docx | Store layout design reference |
| Store Layouts.xlsx | Store layouts data |
| DIDI - Store Layouts - Watford.xlsx | Didi store (Watford) layout |

---

## Planogram

| Document | Description |
|----------|-------------|
| LLD - Planogram.docx | Full planogram module design |
| LLD - Planogram - Data Reference.xlsx | Planogram data reference |

---

## Product

| Document | Description |
|----------|-------------|
| LLD - Product Service.docx | Product microservice design |
| Wing Yip - Product Enquiry.docx | Product enquiry functionality |
| LLD - Product Locator.docx | Product locator on store layout |

---

## Warehouse

| Document | Description |
|----------|-------------|
| LLD - Warehouse Layout.docx | Warehouse layout design |
| Warehouse Layout.xlsx | Warehouse layout data |

---

## Common Libraries & Infrastructure

| Document | Description |
|----------|-------------|
| Centralized Auditing.docx | Centralized audit logging library |
| Centralized Logging.docx | Centralized logging library |
| LLD -Web Socket.docx | WebSocket/SignalR implementation |
| LLD - Maintenance & Cleaning.docx | Maintenance and cleaning module |

---

## Finance

| Document | Description |
|----------|-------------|
| LLD - Finance.docx | Finance module design |
| Customer-Type by Week Report.xlsx | Finance report data |

---

## Notifications

| Document | Description |
|----------|-------------|
| WingYip - Notifications.xlsx | Notification configuration |
| Copy of WingYip - Notifications.xlsx | Duplicate notifications config |

---

## Data Engineering

| Document | Description |
|----------|-------------|
| ETL - Pipelines.xlsx | ETL pipeline configurations |
| Dataflow Schedule.xlsx | Pipeline execution schedule |
| Silver_Layer_Estimation.xlsx | Silver layer sizing estimates |
| SQL Pipeline for SAP - Product Store Due Deliveries.docx | SAP pipeline design |
| WingYip_Data Migration Design_Document.docx | Data migration design (v1.0) |
| WingYip_Data Workflow Design_Document.docx | Data workflow design (v1.0, 06-Feb-2026) |
| Back Ground and Pipeline Process_.xlsx | Background and pipeline processes |

---

## Database Schema

| Document | Description |
|----------|-------------|
| SRS - Microservice Table Mapping.xlsx | Microservice table-to-module mapping |
| SRS Microservice Schema Definition.xlsx | Microservice schema definition |
| SRS Schema Definition.xlsx | Overall SRS schema definition (archived) |

---

## Architecture Analysis & Legacy

| Document | Description |
|----------|-------------|
| Enterprise Stock Replenishment System (SRS) - Technical Architecture Document.docx | Full technical architecture |
| Wing Yip SRS - On-Prem Enterprise Architecture - v.1.2.docx | On-premise deployment architecture |
| Copy of Wing Yip SRS - On-Prem Enterprise Architecture - v.1.2.docx | Duplicate architecture copy |
| Frontend_Architecture_WingYip_SRS.docx | Frontend architecture |
| HH_Mobile App_Architecture_WingYip_SRS.docx | Handheld mobile app architecture |
| Mobile Application Architecture Document.docx | Mobile app architecture |
| Mobile Application Architecture Document(1).docx | Duplicate mobile architecture |
| Frontend Low Level Architecture - React Native (Mobile).docx | React Native frontend LLD |
| Back End Technical Design Document.docx | Backend technical design |
| WingYip-architecture.svg | Architecture diagram (Mermaid SVG) |
| Admin - Legecy UI.docx | Legacy admin UI analysis |
| Manual Order - UI.docx | Legacy manual order UI |
| Planogram UI - Legacy.docx | Legacy planogram UI |
| Planogram Analysis.xlsx | Planogram analysis spreadsheet |
| Copy full store Planogram.xlsx | Full store planogram copy data |
| Shelf Edge Label Printing - Analysis.xlsx | SEL printing analysis |
| SEL_Print Printing Service.docx | SEL print service analysis |
| Queries_SEL_Print.xlsx | SEL print queries |
| Endpoints for Shelf Edge Label Printing.docx | SEL print API endpoints |

---

## Crystal Reports & Print UI

| Document | Description |
|----------|-------------|
| BM_Large Label QR.rpt | Crystal Report — large label QR |
| BM_Small Label QR.rpt | Crystal Report — small label QR |
| LargeLabelDetails.xlsx | Large label detail data |
| SmallLabelDetails.xlsx | Small label detail data |
| BM_Large Label QR (1).rpt | Alternate large label Crystal Report |
| BM_Small Label QR (1).rpt | Alternate small label Crystal Report |
| hot food print.png | Hot food print preview |
| label.png | Sample label preview |

---

## KORBER ETL (Archived)

| Document | Description |
|----------|-------------|
| KORBER_ETL_Design_Document.docx | Korber ETL design |
| ExistingArchitectureMermaid.txt | Existing architecture (Mermaid) |
| NewArchitectureMermaid.txt | Proposed architecture (Mermaid) |
| ExistingArch.png | Existing architecture diagram |
| DE.jpg | Data engineering diagram |
| Datawarehouse Facts & Dimensions.xlsx | Facts and dimensions mapping |
| Data Engineering Flow.docx | Data engineering flow document |
