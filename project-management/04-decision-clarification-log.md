# Decision & Clarification Log

> Index of key decisions, clarifications, and requirement changes captured from meetings, CRs, and trackers across the project lifetime.

---

## Change Request Log

### Source: `Wing Yip SRS- Change Request Log.xlsx`, BRD v3.1

22 Change Requests incorporated from v2.0 to v3.1:

| CR# | Module | Change Description |
|-----|--------|-------------------|
| CR5 | Product Enquiry | Expansion of Shop and Warehouse Location Visibility |
| CR7 | Product Enquiry | Editable Product Parameters in Product Enquiry |
| CR10 | Product Enquiry | Central Distribution Card Enhancements |
| CR11 | Store Layout | Enhanced search functionality for Product Locator |
| CR12 | Store Layout | Enhancement to Product Details Panel (Description, UOM, Case Size) |
| CR16 | Store Operations | Housekeeping Task Completion - User Identification |
| CR17 | Shelf Edge Label | Label Size Flexibility |
| CR23 | Replenishment | Low/No Stock Calculation Based on Fill and Face |
| CR25 | Bulk Replenishment | Mobile View — Bulk Replenishment & Put Away Scan Action Enhancement |
| CR26 | Planogram | Impact of Additional Components in Planogram |
| CR27 | Shelf Edge Label | Shelf Label Change Management and Reprint Log |
| CR28 | Shelf Edge Label | Additional Printing Options (Print All Labels for Product, Full Bay Store/Warehouse, Pick Group, Store Replen Group) |
| CR30 | Planogram | Mandatory Fill and Face Fields for Didi Stores |
| CR33 | Planogram | Year and Week Entry During Planogram Commit |
| CR35 | Replenishment | StoreWalk Group |
| CR37 | Replenishment | Replenishment List Auto Refresh |
| CR38 | Replenishment | Replenishment Group Stock Availability Color Coding |
| CR39 | Replenishment | Replenishment Picking Exit and Locking Mechanism |
| CR41 | Bulk Replenishment | Move Product to TRANS/RECV Location |
| CR46 | Planogram | Product Search by Description in Add Product Popup |
| CR47 | Planogram | Copy Full Store Planogram to New Planogram |
| CR48 | Planogram | Propagation of Bay Updates Across Didi Stores |
| CR49 | RBAC | Multiple Roles per User within a Store |

---

## Requirement Clarification Tracker

### Source: `WingYip Requirement Clarification Tracker.xlsx`

- Tracks open questions and clarifications between InApp and WingYip
- Categorized by module and priority
- Resolution status and date tracked per item
- Drives BRD updates (clarifications feed into CRs)

---

## Key Meeting Decisions

### Source: Meeting Records (Oct-Dec 2025), MOM_28Jan2026.xlsx

| Date | Topic | Key Decision |
|------|-------|-------------|
| 21-Oct-2025 | Internal KT session | Project kickoff knowledge transfer |
| 24-Oct-2025 | AI enablement & tools | AI tool adoption plan for development workflow |
| 03-Nov-2025 | Datawarehouse + Login Auth | DW architecture direction; dual auth model confirmed |
| 03-Nov-2025 | AI enablement training | AI tools integration into development process |
| 07-Nov-2025 | Login + User management | AD/Keycloak dual auth; RBAC role hierarchy finalized |
| 21-Nov-2025 | User Role assignment | Multi-role per store; CATMAN global role; CR49 |
| 24-Nov-2025 | UI review | UI patterns and design decisions |
| 01-Dec-2025 | Store layout clarification | Layout requirements and aisle/bay structure |
| 04-Dec-2025 | Technical progress update | Architecture decisions confirmed |
| 08-Dec-2025 | Phase 3a Demo | Milestone demo; core functionality validated |
| 10-Dec-2025 | Planogram user stories | Planogram workflow states confirmed with CRs |
| 16-Dec-2025 | Didi store module walkthrough | Didi operations flow; emergency order design |
| 28-Jan-2026 | MoM | General meeting minutes (MOM_28Jan2026.xlsx) |

---

## Process Definition

### Source: `Wing Yip- Store Replenishment System Development Project- Process Definition Document.docx`

- Development process and standards
- Sprint ceremony definitions
- Code review gates and quality standards
- Jira workflow configuration

---

## Review & Change Trackers

| Document | Description |
|----------|-------------|
| Replenishment Module- Review Changes.xlsx | Post-BRD review changes for replenishment module |
| SRS Phase1_Revised Schedule and Scope.xlsx | Phase 1 revised schedule and scope adjustments |
| Menu Changes.xlsx | Menu structure changes tracking |
| Wing Yip- Action items.xlsx | Action items from meetings |

---

## Infrastructure Decisions

### Source: `Infrastructure - Confirmations and Requirements.docx`, `Infrastructure MoM`

- On-premise deployment confirmed (no cloud)
- Kubernetes platform choice (OpenShift/Rancher)
- Network architecture decisions (MPLS/SD-WAN)
- Security layer decisions (AD+Keycloak dual auth)
- Infrastructure meeting minutes reference

---

## Cross-References

- [RAID & CR Tracking](./03-raid-change-requests.md) — Formal RAID log
- [Weekly Status](./02-weekly-status.md) — Meeting history and themes
- [BRD Summary](../requirements/01-brd-summary.md) — CR details in business context