# Business Requirements Document (BRD) — Summary

> Derived from WingYip SRS Business Requirements Documents v2.0 (12-Oct-2025) and v3.1 (23-Mar-2026) by InApp Information Technologies.

---

## Business Context

Wing Yip is a long-established Oriental grocery business operating across four primary superstore sites: **Birmingham, Manchester, Croydon, and Cricklewood**. The organization follows a hybrid retail and wholesale business model offering ambient, chilled, and frozen goods sourced locally and from across Asia.

### Business Structure
- **Wholesale Warehouse Format** — Palletised and case-format goods for restaurant/catering customers. TradeRetail customers shop both wholesale and retail.
- **Retail Storefront Format** — Full-service grocery stores for walk-in customers.
- **Didi Stores** — New smaller-format stores carrying ~850 products across ambient, chilled, and frozen. First opened in Watford on 4th December 2025. No storage area; daily deliveries based on previous day's sales and wastage.
- **Central Distribution & Coldstore** — Co-located with Birmingham superstore. Handles central stock, warehouse picking, pallet building, and inter-branch transfers (IBTs).

---

## Scope: Web vs Mobile

| Module | Web | Mobile |
|--------|-----|--------|
| Login | Yes | Yes |
| User Management | Yes | No |
| Product Enquiry | Yes | Yes |
| Planogram/Space Management | Yes | No |
| Store Walk | No | Yes |
| Replenishment | Partly | Partly |
| Shelf Edge Label Printing | Partly | Partly |
| Fresh Food | Partly | Partly |
| Didi Stores | Partly | Partly |
| Stock Adjustment | Partly | Partly |
| Delivered Sales | Yes | No |
| PI Check | Partly | Partly |
| Date Check | Partly | Partly |
| Admin Modules | Yes | No |
| Messaging | Yes | Yes |
| Dashboard | Yes | No |
| Alerts and Notifications | Yes | Yes |
| Reports and Analytics | Yes | No |
| Stock Control | Partly | Partly |
| SOCO | Partly | Partly |

---

## Document Evolution

| Version | Date | Key Changes |
|---------|------|-------------|
| v1.1 | 2025 | Initial BRD |
| v2.0 | 12-Oct-2025 | Full document created by InApp |
| v3.1 | 23-Mar-2026 | 22+ Change Requests incorporated (see table below) |

---

## v3.0 Change Requests (Complete)

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

## Planogram Workflow States

```
Draft → Pending → Approved/Published → Reviewed → Planned → Implemented
  ↑                                                    ↓
  └────────────────── Recalled ←───────────────────────┘
```

| State | Description |
|-------|-------------|
| **Draft** | Created by SOCO/CatMan; editable, not visible to stores |
| **Pending** | Submitted for review and approval |
| **Approved/Published** | Approved by CatMan/senior peer; visible to StoreOps |
| **Reviewed** | Reviewed by Store Manager; comments logged |
| **Planned** | StoreOps schedules implementation |
| **Implemented** | Execution confirmed by store |
| **Recalled** | Plan withdrawn by CatMan prior to or after publication |

### New v3.0 Planogram Additions:
- Archive Process — lifecycle management for aged planograms
- Rejection Validation — structural inconsistencies set status to **Rejected** until resolved
- Peer Review & Publishing Workflow
- RBAC for Planogram Publishing
- Planogram Change Information Display
- Moved Product Display Enhancement
- Product UOM Display
- Reason Code Tooltip
- Detail View Display Order Enhancement
- 53-Week Financial Year Support
- Multiple Planograms in Same Week
- Default Fill Value During Product Picking
- Mandatory Comments for Planogram Commit

---

## RBAC: Full Role List & Access Model

### Roles
| Role | Description |
|------|-------------|
| **Super User** | Highest privilege role with full system access |
| **Sr CATMAN** | Senior Category Manager — planogram governance and product layout |
| **CATMAN** | Category Manager — category management and planogram operations |
| **SOCO** | Stock Ordering Coordinator — stock monitoring and replenishment coordination |
| **Store Manager** | Overall store operations and approvals |
| **Store Supervisor** | Supervises store floor operations |
| **Stock Control** | Stock adjustments and investigations |
| **Customer Warehouse Ops** | Warehouse inventory operations |
| **Customer Service** | Customer-related operational tasks |
| **Sales** | Limited operational data access |
| **Finance Ops** | Financial analysis and reporting |
| **IT Admin** | System administrator — configurations and user access |

### Access Levels
- **F — Full Access**: Create, modify, delete, execute actions
- **V — View Only**: Read-only, no modifications
- **Blank — No Access**: Module/menu hidden

### RBAC Module Scope
1. Admin Module — User Management
2. Spaceman / Planogram
3. Planogram Management
4. Store Layout
5. Shelf Edge Labels (SEL)
6. Product Module
7. Finance
8. Store Walk
9. Daily Processes
10. Stock & GNFR Management
11. Incoming Deliveries
12. Stock Investigations
13. Didi Admin Store Operations
14. Customer Warehouse Functions
15. Customer Warehouse Layout

### Key RBAC Rules
- **FR-RBAC-01**: Role-based menu visibility — unauthorized menus hidden
- **FR-RBAC-02**: Full, View-only, or No Access enforcement at menu and action level
- **FR-RBAC-03**: Multi-role assignment within same store — highest permission across roles applied
- **FR-RBAC-04**: Global role application (e.g., CATMAN) automatically applies across all stores

### User Creation
- Crown ID mandatory; Email ID applicable only for AD users (web)
- AD toggle auto-fills First Name, Last Name; remaining fields manual
- PIN/Password is six-digit for mobile login
- Users must explicitly switch store context when multi-store assigned
- SuperUser can create all roles; CatMan can create SOCOs; Store Manager can create store-level roles

### Privilege Model (Four-Tier)
| Level | Description |
|-------|-------------|
| No Access | Section/menu hidden or disabled |
| View | Read-only access |
| Full Access | Create, edit/update, delete |
| Additional Permissions | Approve, Reject, Publish, Validate |

---

## Module Breakdown

### 1. User Management & RBAC (Section 2)
- User creation with Crown ID + AD integration
- Role assignment per store or globally
- Four-tier privilege model at module/sub-module/functionality levels
- Multi-store access with explicit store context switching
- Authentication: Web = AD credentials, Mobile = Crown ID + 6-digit PIN
- Mandatory password reset on first mobile login

### 2. Store Layout & Planogram / SpaceMan (Section 3)
- Store layout design (aisle, bay, section, component structure)
- Enhanced Product Locator search (CR11) — partial keyword, unified search field
- Product Details Panel: Description, UOM, Case Size display (CR12)
- Bay Groups management
- Full planogram creation, review, approval, publication workflow
- Copy full store planogram (CR47)
- Didi store bay propagation (CR48)
- Multiple planograms per week support
- Fill Face requirement for Didi stores (CR30)

### 3. Warehouse Layout & Location Builder (Section 4)
- Location capture and mapping (aisle, bay, level)
- Product location updates and replacements
- Warehouse structure design and management

### 4. Product Enquiry (Section 5)
- Search by description, SKU, partial keyword
- Product status identification with color coding
- Editable fields with audit tracking (CR7)
- Expanded shop + warehouse location visibility (CR5)
- Central Distribution Card enhancements (CR10)

### 5. Store Operations / Store Walk (Section 6)
- Low Stock workflow — product below threshold triggers replenishment
- No Stock workflow — empty shelf → urgent action
- Low Stock / No Stock Calculation Based on Fill and Face (CR23)
- Temp OOS marking
- Spillage / Cleaner Required workflow
- Housekeeping workflow with user identification tracking (CR16)

### 6. Core Replenishment (Section 7)

#### Replenishment Groups (ReplenGrp)
- Structured set of consecutive bays (one side of aisle), typically 6-7 bays
- Temperature zone associated: A = Ambient, C = Chilled/Fresh, F = Frozen
- Naming: `<Aisle><ZoneCode><StartBay><EndBay>` (e.g., `08A3139`)
- Owned jointly by Store Operations and Category Management
- Stored as: Store → Aisle → Bay → ReplenGrp

#### Sales-Based Normal Replenishment
- Background process triggers every 15 minutes
- Fetches EPOS sales via OpSuite stored procedure `GetTransactionsforToday`
- Deduplication based on Transaction Number
- Cumulative units/cases sold tracked; when units ≥ case size → CaseReplenActions created
- UoM codes: 1 = individual item, 2 or 3 = cases

#### Store Walk Replenishment
- Triggers every 10 seconds for Low Stock / No Stock detection
- Immediate replenishment task creation

#### Picking Workflow
1. Picker selects ReplenGroup and starts pick
2. ReplenGroup locked (another user cannot take same group)
3. Products displayed in Warehouse Sequence order
4. Scan case → confirm quantity (no over-pick allowed)
5. Skip pick option available
6. Shortfalls: partial quantity recorded, remainder returned to CaseReplenActions

#### v3.0 Replenishment Enhancements
- StoreWalk Group (CR35)
- Auto-refresh replenishment list (CR37)
- Stock availability color coding (CR38)
- Exit & locking mechanism (CR39)
- Cumulative sales-based replenishment logic
- Temperature-based segregation
- Multi-area picking for special store scenarios
- Large case factor handling
- Weighted product picking

### 7. Bulk Replenishment — Customer Warehouse (Section 7.3)

Four functional areas:
| Process | Description |
|---------|-------------|
| Pallet Drop | Move cases from bulk (in-rack) to ground-level pick-face by Pick Group |
| Put-Away | Cases from dropped pallets into pick locations or Overstock |
| Move to Pick Location | Direct move from Receive/Transfer to pick-face location |
| Move from Overstock | Replenish pick-face from Overstock cases |

#### Pick Groups
- Logical work areas for bulk replenishment (one or more aisles, both sides)
- Each Store + Aisle + Bay + Level mapped to exactly one Pick Group
- Examples: Oils and Sauces, Noodles, Drinks, Sauces and Vinegars, Canned Goods

#### Fill & Trigger Quantities
- **Fill Quantity (MaxQtyCases)**: Max cases fitting in pick-face location (e.g., 15 cases)
- **Trigger Quantity (TriggerQtyCases)**: Threshold at which Bulk Replenishment request is created
- Example: Fill = 15, Trigger = 5 → when remaining ≤ 5, SRS generates Bulk Replen task
- Bulk replenishments typically executed next morning before opening

#### Cumulative Depletion Tracking
SRS tracks cases removed from bulk/pick-face bay regardless of reason:
- Cases sold through tills (EPOS)
- Cases moved to store for case replenishment
- Both movement types count as bay stock depletion

#### Mobile Enhancements (v3.0)
- Scan button availability and direct scan workflow (CR25)
- Bulk Replenishment access from Overstock Menu on mobile
- Quantity entry during bulk replenishment on mobile
- Rename "Details" button to "Pallets" on mobile
- Move Product to TRANS/RECV location (CR41) — product info display, last known location validation, case quantity validation

### 8. Perpetual Inventory (PI) & Date Check (Section 8)
- Store PI execution workflow
- Warehouse PI follow-up
- Date check process (expiry management)
- Automated system checks
- Korber error log checks
- Finance stock audit checks

### 9. Stock Control & Discrepancy (Section 9)
- Sources: Store Walk shop discrepancies, Pick location case discrepancies, Bulk location discrepancies, Manual stock check requests
- Physical stock verification
- Write-off decisions (within / outside limit)
- Escalation process (SAP write-off, Korber adjustments)
- Notification to SOCO
- Automated system checks and error alerts
- Planned PI checks
- Stock Control Audit Table with full field tracking

### 10. SOCO Workflow (Section 10)
- Daily operations at SOCO dashboard
- Temporary OOS label management
- Product selection logic and product information display
- SAP review (daily schedule)
- Product evaluation logic with scenario handling
- Low stock alerts
- Discontinued line checks
- Cross-store overstock monitoring
- Promotions management
- Reports: Date Check Follow-Up, Operational Performance

### 11. Shelf Edge Label Printing (Section 11)

#### Core Features
- Label generation: product info, price, barcode/QR
- Printing rules configurable per store/product
- Printing modes: batch, individual, price-change triggered
- Temp OOS and housekeeping integration
- Web and Mobile printing interface (both platforms)

#### Workflow
- Planogram implementation printing workflow
- Implemented status with reprint option
- Printer integration with data mapping

#### v3.0 Change Requests
- **CR17**: Label Size Flexibility
- **CR27**: Shelf Label Change Management and Reprint Log
- **CR28**: Additional Printing Options:
  - Print All Labels for Product (with product identification, UOM selection, location capture, label size selection)
  - Print Labels for Store Full Bay (location input, context selection, data retrieval)
  - Print Labels for Warehouse Full Bay
  - Print by Pick Group (pick group selection, data retrieval, label size/format)
  - Print by Store Replenishment Group

### 12. Admin Configuration (Section 12)
- Store configurations
- System settings
- Dependencies and integration points

### 13. Messaging & Notifications (Sections 13-15)

#### Notification Types
- **Messages**: Inter-user communication
- **Notifications**: System-generated updates with visibility rules
- **Alerts**: Priority notifications with ownership tracking and escalation logic

#### Alert Flow
1. Alert generation triggered by system events
2. Assigned to responsible role
3. Escalation logic applied based on time/severity
4. Resolution tracking logged

### 14. Didi (DD) Store Operations (Section 16)

#### Replenishment Model
- **Scheduled (Automated)**: Daily deliveries based on previous day's sales and wastage
- **Emergency**: Urgent stock requests from remote store to parent store

#### Operational Areas
- Temperature-Based Segregation (Ambient/Chill/Frozen routing)
- Supply Chain Configuration per Didi store
- Waste and Contingency Handling
- Hot Food Process
- Store Opening and Fixture Management
- Promotion Handling
- Print Manifest and Label Management

#### Didi Admin Configuration
- Maintain Products Not Replenished from Customer Warehouse
- Shop Floor Picks Configuration
- Maintain Hot Food Products
- Manage GNFR Items (Goods Not For Resale)
- Maintain GNFR Uniforms

#### Didi Menu (Mobile & Web)
1. Emergency Order Management — Source Store Selection
2. Product Identification
3. Product Confirmation & Quantity Entry
4. Order Review, Submission, Cancellation
5. Excess Stock & Cumulative Sales

### 15. Fresh Goods (Section 18)
- Special handling for perishable products
- Replenishment process distinct from ambient/dry goods
- Identification and coding (separate tracking)
- Stock tracking and location management
- Spoilage and write-offs tracking
- Integration with system logic for fresh-specific rules
- Replenishment triggers and alerts
- Exception handling
- Configurable parameters (fresh goods specific)

### 16. Reporting & Analytics (Section 19)
- Dashboard-level visibility
- Operational, financial, and stock reports

### 17. Finance Module (Section 20)
- Functional scope for financial operations
- Customer-type reporting
- Integration with SAP for financial data

### 18. System-Wide Audit Log Framework (Section 21)
- Centralized audit logging across all modules
- User ID, action, timestamp, affected record tracking
- Applicable to all restricted module actions

### 19. Dual Merchandise / Directed Storewalk (Section 26)
- Process flow for multi-location product placement
- Warehouse consideration for stock sourcing
- Web application reporting
- Frequency and notification management
