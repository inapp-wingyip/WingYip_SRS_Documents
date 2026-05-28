# Functional Module Breakdown

## 1. User Management & RBAC

### User Creation
- Crown ID: unique employee identifier (mandatory)
- AD integration toggle — auto-fills First Name, Last Name from Active Directory
- Six-digit PIN for mobile authentication
- Short Name used for screen display and audit logs
- Email applicable only for AD/wed users

### Role Assignment
- Users assigned one or more roles per store
- Default privilege templates auto-applied based on role
- Users must explicitly switch store context for multi-store access

### RBAC Roles (12 roles — 11 business + IT Admin)
| Role | Access Scope |
|------|-------------|
| Super User | Full system access — all modules |
| Sr CATMAN | Planogram governance, product layout |
| CATMAN | Category management, planogram operations |
| SOCO | Stock ordering coordination |
| Store Manager | Overall store operations, approvals |
| Store Supervisor | Store floor supervision |
| Stock Control | Stock adjustments, investigations |
| Customer Warehouse Ops | Warehouse inventory |
| Customer Service | Customer tasks |
| Sales | Limited operational access |
| Finance Ops | Financial analysis, reporting |
| IT Admin | System administration |

### Access Levels (Four-Tier)
| Level | Capability |
|-------|-----------|
| No Access | Section/menu hidden or disabled |
| View | Read-only, no modifications |
| Full Access | Create, edit, update, delete |
| Additional Permissions | Approve, Reject, Publish, Validate |

### Multi-Role (CR49)
- Single user can hold multiple roles within same store
- Highest permission across all assigned roles is applied
- CATMAN role: automatically applied across all stores (global)
- Permissions evaluated dynamically at login

---

## 2. Store Layout & Planogram (SpaceMan)

### Store Layout
- Aisle, bay, section, component structure design
- Store-specific layout configuration
- Additional components support (CR26)

### Bay Groups
- Logical grouping of store bays for operational management
- Managed through dedicated interface
- Store → Aisle → Bay → BayGroup hierarchy

### Product Locator (Enhanced — CR11, CR12)
- Search by product description (partial keyword matching)
- Unified search field across all products
- Product Details Panel displays:
  - Product Description
  - Unit of Measure (UOM)
  - Case Size
- Integration with Product Locator for full mapping

### Planogram Workflow
```
Draft → Pending → Approved → Reviewed → Planned → Implemented
  ↑                                                    │
  └────────────────── Recalled ←───────────────────────┘
```

### v3.0 Planogram Features
- Copy full store planogram (CR47)
- Bay update propagation across Didi stores (CR48)
- 53-week financial year support
- Multiple planograms in same week allowed
- Archive process for lifecycle management
- Rejection validation (structural issues → Rejected status)
- Peer review & publishing workflow
- RBAC for planogram publishing
- Moved product display with change tracking
- Product UOM and reason code tooltip display
- Detail view display order optimization
- Mandatory comments for planogram commit

---

## 3. Warehouse Layout

- Location capture and mapping (aisle, bay, level)
- Product-to-location association
- Location updates and replacements
- Warehouse location data drives Pick Group assignments

---

## 4. Product Enquiry

- Product search by description, SKU, partial keyword
- Product status identification with color coding
- Editable product parameters with audit tracking (CR7)
- Expanded shop + warehouse location visibility (CR5)
- Central Distribution Card enhancements (CR10):
  - Expanded distribution center display
  - Multiple location expansion
  - Improved UI behavior for product data

---

## 5. Store Operations (Store Walk)

### Workflows

| Workflow | Trigger | Response |
|----------|---------|----------|
| Low Stock | Product below threshold | Replenishment task |
| No Stock | Product empty on shelf | Urgent replenishment |
| Temp OOS | User marks product | Temporary status |
| Spillage | User reports spill | Cleaner task |
| Housekeeping | Scheduled/adhoc | Task with user ID tracking |

### Low/No Stock Calculation (CR23)
- Based on **Fill** (product face display quantity) and **Face** (number of shelf facings)
- Calculation determines actual shelf capacity
- Housekeeping task completion tracks user identification (CR16)

---

## 6. Core Replenishment

### Replenishment Groups (ReplenGrp)
- Structured set of consecutive bays (one side of aisle), typically 6-7 bays
- Temperature zone: A = Ambient, C = Chilled/Fresh, F = Frozen
- Naming: `<Aisle><ZoneCode><StartBay><EndBay>` (e.g., `08A3139`)
- Owned jointly by Store Operations and Category Management
- Stored as: Store → Aisle → Bay → ReplenGrp
- Only modified during major layout or planogram restructures

### Sales-Based Normal Replenishment
- Background process triggers **every 15 minutes**
- Fetches EPOS sales via OpSuite stored procedure `GetTransactionsforToday`
- Deduplication based on Transaction Number
- UoM codes: 1 = individual item, 2 or 3 = cases
- Cumulative units sold tracked; when ≥ case size → CaseReplenActions created
- Action code = 0 for normal replenishment

### Store Walk Replenishment
- Triggers **every 10 seconds**
- Real-time low stock / no stock detection
- Immediate replenishment task creation

### Picking Workflow
1. Picker selects ReplenGroup and starts pick
2. ReplenGroup locked — concurrent access prevented (CR39)
3. Products displayed in warehouse sequence order
4. Scan case → confirm quantity (no over-pick allowed)
5. Overrides allowed (SEL QR/manual) — must be logged
6. Skip pick option available per product
7. Shortfalls: partial quantity recorded, remainder returned to CaseReplenActions

### Picking States
| State | UI Display |
|-------|-----------|
| Not Started | ReplenGroup, Total Cases/SKUs, In Pick, In Bulk, Actions |
| In Progress | ReplenGroup, Pick start time, Progress (min), SKUs picked/skipped, Actions |

### v3.0 Replenishment Enhancements
- StoreWalk Group (CR35) — dedicated group for store walk replenishment
- Auto-refresh replenishment list (CR37) — configurable frequency
- Stock availability color coding (CR38) — visual status indicators
- Exit & locking mechanism (CR39) — graceful lock release
- Cumulative sales-based replenishment logic
- Temperature-based segregation (A/C/F routing)
- Multi-area picking for special store scenarios
- Large case factor handling (weighted calculation)
- Weighted product picking support
- Replenishment status visibility (Mobile and Web)
- Product-level replenishment actions (Mobile)
- Replenishment indicators in Store Walk / Product View
- Warehouse pick location sequencing
- Store Walk vs Store-Based logic differentiation

---

## 7. Bulk Replenishment — Customer Warehouse

### Four Functional Areas
| Process | Description |
|---------|-------------|
| Pallet Drop | Move cases from bulk (in-rack) to ground-level pick-face by Pick Group |
| Put-Away | Cases from dropped pallets into pick locations or Overstock |
| Move to Pick Location | Direct move from Receive/Transfer to pick-face location |
| Move from Overstock | Replenish pick-face from Overstock cases |

### Pick Groups
- Logical work areas: one or more aisles, both sides
- Each Store + Aisle + Bay + Level mapped to exactly one Pick Group
- Examples: Oils and Sauces, Noodles, Drinks, Sauces and Vinegars, Canned Goods
- Stored in PickGroup Master Table (drives grouping)
- Groups requests by PickGroup for optimized forklift routing

### Fill & Trigger Quantities
- **Fill Quantity (MaxQtyCases)**: Max cases fitting in pick-face location (e.g., 15)
- **Trigger Quantity (TriggerQtyCases)**: Threshold for Bulk Replen request (e.g., 5)
- When remaining stock ≤ TriggerQty, SRS generates Bulk Replen task
- Bulk replenishments typically executed next morning before store opening

### Cumulative Depletion Tracking
SRS tracks cases removed regardless of reason:
- Cases sold through tills (EPOS)
- Cases moved to store for case replenishment
- Both movement types count as bay stock depletion
- Maintained per Store + SKU + pick-face location

### Bulk UI Clarifications (Mobile)
- Bulk Replenishment access from Overstock Menu
- Quantity entry during bulk replenishment
- "Details" button renamed to "Pallets"

### Mobile Scan Enhancement (CR25)
- Scan button availability for direct workflow
- Direct scan workflow (no menu navigation needed)
- Unified scan action as single entry point

### Move to TRANS/RECV (CR41)
- Product information display during movement
- Last known location validation rules
- Location format validation (prefix + numeric)
- Case quantity validation rules
- Full mobile workflow for TRANS/RECV moves

---

## 8. Perpetual Inventory (PI) & Date Check

- Store PI execution workflow
- Warehouse PI follow-up
- Date check process (expiry management)
- Automated system checks
- Korber error log verification
- Finance stock audit checks

---

## 9. Stock Control & Discrepancy

### Discrepancy Sources
| Source | Example |
|--------|---------|
| Store Walk shop | Product count mismatch on shelf |
| Pick location case | Case count discrepancy in warehouse |
| Bulk location | Pallet/bulk location mismatch |
| Manual stock check | User-initiated verification |

### Resolution Flow
1. Physical stock verification (StoreOps)
2. Verify if discrepancy is resolved
3. Within write-off limit → auto-adjust
4. Outside write-off limit → notification to SOCO
5. Escalation process → SAP write-off / Korber adjustment
6. Automated system checks (periodic)
7. Korber error log verification
8. Finance stock audit verification
9. Final write-off with full audit trail
10. Stock Control Audit Table captures all fields for traceability

### Additional Processes
- Planned PI checks (scheduled)
- Bulk warehouse PI checks
- Error alerts
- Reporting with full audit history

---

## 10. SOCO Workflow

### Daily Operations
- Web-only SOCO dashboard
- Navigation to all SOCO functions

### Core Functions
- Temporary OOS label management (Mobile and Web)
- Product selection logic
- Product information display
- SOCO action tracking
- Data download and visibility

### SAP Review
- Daily schedule review of SAP data
- Product evaluation logic with scenario handling
- Discrepancy identification

### Monitoring
- Low stock alerts (Mobile)
- Discontinued line checks (Web reports)
- Cross-store overstock monitoring (Web)
- Promotions management (Web)

### Reports
- Date Check Follow-Up (Web, daily)
- Operational Performance Reports

### Phase-Over Label Replacement
- Triggered when products phase-over between categories
- Managed through SOCO workflow

---

## 11. Shelf Edge Label Printing

### Core Features
- Label generation: product info, price, barcode/QR
- Printing rules configurable per store/product
- Printing modes: batch, individual, price-change triggered
- Temp OOS and Housekeeping integration
- Web and Mobile printing interface (both platforms)

### Printing Workflow
- Planogram implementation printing workflow
- Implemented status with reprint option
- Printer integration with data mapping
- Label printer testing via functional requirements

### Crystal Reports
- BM_Large Label QR.rpt — large format labels
- BM_Small Label QR.rpt — small format labels
- LargeLabelDetails and SmallLabelDetails reference spreadsheets

### v3.0 Printing Options (CR28)
| Option | Input | Output |
|--------|-------|--------|
| Print All Labels for Product | Product ID, UOM selection, location, label size | All labels for product |
| Store Full Bay | Location (store/aisle/bay), context | All labels for bay |
| Warehouse Full Bay | Location (aisle/bay), context | All labels for warehouse bay |
| By Pick Group | Pick group selection, label size | All labels for pick group |
| By Store Replen Group | Replen group selection | All labels for replen group |

### Label Size Flexibility (CR17)
- Configurable label sizes
- Size selection per print context

### Change Management & Reprint (CR27)
- Shelf label change management tracking
- Reprint log for all label changes
- Change history with timestamps

---

## 12. Admin Configuration

- Store configurations
- System settings
- Dependencies and integration management
- Configuration screens for Phase 1.2

---

## 13. Messaging & Notifications

### Message Types
- **Messages**: Inter-user communication within the system
- **Notifications**: System-generated updates with visibility rules
- **Alerts**: Priority notifications with ownership and escalation

### Alert Flow
1. Alert generation triggered by system events
2. Alert visibility set by role/scope
3. Ownership assigned to responsible role
4. Escalation logic applied based on time thresholds and severity

---

## 14. Didi Store Operations

### Replenishment Model
- **Scheduled (Automated)**: Daily deliveries based on previous day's sales and wastage
- **Emergency Replenishment**: Urgent requests from Didi to parent superstore
- Temperature-based segregation (Ambient / Chill / Frozen routing)

### Admin Configuration
- Products Not Replenished from Customer Warehouse
- Shop Floor Picks Configuration
- Hot Food Products maintenance
- GNFR Items (Goods Not For Resale) management
- GNFR Uniforms management

### Operations
- Hot Food Process (specific to Didi)
- Store Opening and Fixture Management
- Promotion Handling
- Print Manifest and Label Management
- Emergency Order Management (source store selection, product ID, quantity, review, submit, cancel)
- Excess Stock & Cumulative Sales tracking
- Waste and Contingency Handling

### Didi Menu (Mobile & Web)
1. Emergency Order — Source Store Selection
2. Product Identification
3. Product Confirmation & Quantity Entry
4. Order Review, Submission, Cancellation
5. Excess Stock & Cumulative Sales

---

## 15. Fresh Goods (Section 18)

- Nature and handling: perishable products with short shelf life
- Replenishment process distinct from ambient/dry goods
- Identification and coding for separate tracking
- Stock tracking and location management
- Spoilage and write-offs with full audit trail
- Integration with system logic (SAP, Korber)
- Replenishment triggers and alerts (configurable)
- Exception handling (spoilage, delivery issues)
- Fresh goods specific configuration parameters

---

## 16. Reporting & Analytics

- Purpose: enterprise-wide operational visibility
- Power BI Report Server for dashboards
- SSRS for paginated operational reports
- Operational, financial, and stock reports
- Role-based access to reports

---

## 17. Finance

- Customer-Type by Week Report
- Functional scope covering store-level financial operations
- Dependencies and integration with SAP

---

## 18. System-Wide Audit Log Framework

- Centralized audit logging across all modules
- Captures: User ID, action type, timestamp, affected record
- Applicable to all actions in restricted modules
- Immutable audit trail for compliance

---

## 19. Dual Merchandise / Directed Storewalk

- Multi-location product placement management
- Process flow: identification → warehouse sourcing → placement
- Warehouse consideration for stock availability
- Web application reporting for tracking
- Frequency and notification management
