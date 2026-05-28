# RAID Log & Change Request Tracking

> Derived from `drive/Archived_19-Dec-2025/Project Management/` and `drive/Documents/Project-Management/`.

---

## RAID Log

**Document**: `Wing Yip_ RAID.xlsx` (archived — original from sprint planning)

### RAID Categories
| Category | Description |
|----------|-------------|
| **Risks** | Potential issues that could impact project delivery |
| **Assumptions** | Statements taken as true for planning purposes |
| **Issues** | Current problems requiring resolution |
| **Dependencies** | External factors the project relies on |

### Tracked Items
- Risks rated by probability × impact
- Issues with owner, status, and resolution date
- Dependencies with source, type, and expected resolution

---

## Change Request Log

**Document**: `Wing Yip SRS- Change Request Log.xlsx`

### v3.0 → v3.1 Change Requests (18 CRs)

| CR# | Module | Change Description |
|-----|--------|-------------------|
| CR5 | Product Enquiry | Expansion of Shop and Warehouse Location Visibility |
| CR7 | Product Enquiry | Editable Product Parameters in Product Enquiry |
| CR10 | Product Enquiry | Central Distribution Card Enhancements |
| CR11 | Store Layout | Enhanced search functionality for Product Locator |
| CR12 | Store Layout | Enhancement to Product Details Panel |
| CR16 | Store Operations | Housekeeping Task Completion - User Identification |
| CR17 | Shelf Edge Label | Label Size Flexibility |
| CR23 | Replenishment | Low/No Stock Calculation Based on Fill and Face |
| CR25 | Bulk Replenishment | Mobile View — Scan Action Enhancement |
| CR26 | Planogram | Impact of Additional Components |
| CR27 | Shelf Edge Label | Shelf Label Change Management and Reprint Log |
| CR28 | Shelf Edge Label | Additional Printing Options |
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

## Action Items

**Document**: `Wing Yip- Action items.xlsx`

- Weekly action items from meetings and status reviews
- Tracked by owner, due date, priority, and status
- Cross-referenced with RAID log entries

---

## Issue Tracking

**Document**: `WingYip Issues.xlsx`

- General project issues not classified as CRs
- Categories: Technical, Process, Resource, External
- Status tracking: Open → In Progress → Resolved → Closed

---

## Process Definition

**Document**: `Wing Yip- Store Replenishment System Development Project- Process Definition Document.docx`

- Defines project development processes and standards
- Sprint ceremony definitions
- Code review and quality gates
- Deployment and release process

---

## Jira Workflow

**Document**: `WingYip - Jira Work Flow.docx`

- Jira project configuration for SRS project
- Issue type hierarchy: Epic → Story → Task → Sub-task
- Workflow states: To Do → In Progress → In Review → Done
- Board configuration and sprint management

---

## Cross-References

- [Planning & Sprints](./01-planning-sprints.md) — Sprint and milestone tracking
- [Weekly Status](./02-weekly-status.md) — Status reports and meeting index
- [BRD Summary](../requirements/01-brd-summary.md) — Change requests mapped to requirements
- [Functional Modules](../requirements/02-functional-modules.md) — CR-affected modules