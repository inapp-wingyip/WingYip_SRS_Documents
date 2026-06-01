# Replenishment LLD — Detailed Module Summaries

> Comprehensive index of all 11 Replenishment LLD documents from `drive/Documents/Design/Replenishment/` with key design decisions and structures.

---

## LLD Index

| # | Document | Focus Area |
|---|----------|------------|
| 1 | LLD - Replenishment Module - General.docx | Module overview, shared patterns |
| 2 | LLD Replenishment Group Details.docx | ReplenGroup structure and management |
| 3 | LLD - Sales Based Stock Replenishment.docx | 15-min sales-based replenishment |
| 4 | LLD - Low _ No Stock _ Sales Replenishment - BG Process.docx | Background process for low/no stock |
| 5 | LLD - Stock Replenishment.docx | Picking workflow and operations |
| 6 | LLD - Bulk Replenishment - Pallet.docx | Pallet drop, put-away, bulk warehouse |
| 7 | LLD - Move From Overstock.docx | Overstock → pick-face replenishment |
| 8 | LLD - Move To Pick Location.docx | Receive/Transfer → pick-face movement |
| 9 | LLD - Put away.docx | Put-away from pallet drops |
| 10 | LLD - Release Locked Replen Groups.docx | Concurrency control, lock management |
| 11 | LLD - Didi Replenishment.docx | Didi-specific replenishment (see [Didi LLDs](./04-lld-didi-store-detail.md)) |

---

## 1. Replenishment Module — General

### Architecture
- **CQRS Pattern**: Command handlers for writes (pick start/complete, stock adjustment), Query handlers for reads (pick lists, replen status)
- **Repository**: Entity Framework Core, database-first DbContext
- **Background Services**: Hosted services for periodic processes (15-min sales, 10-sec store walk)

### Key Tables (Replenishment DB)
| Table | Purpose |
|-------|---------|
| ReplenGroup | Store, Aisle, Zone, StartBay, EndBay, TempZone |
| CaseReplenActions | ProductID, StoreID, ActionCode, CasesNeeded, Status |
| ShelfReplenPicking | PickSessionID, ReplenGroupID, PickerID, StartTime, Status |
| CumulativeSales | ProductID, StoreID, UnitsSold, CasesSold, LastUpdated |
| ReplenGroupLock | ReplenGroupID, LockedByUserID, LockTime |

---

## 2. Replenishment Group Details

### Structure
```
Store → Aisle → Bay → ReplenGroup
```

- **Naming Convention**: `<Aisle><ZoneCode><StartBay><EndBay>` (e.g., `08A3139`)
- **Temperature Zone Codes**: A = Ambient, C = Chilled/Fresh, F = Frozen
- **Typical Size**: 6-7 consecutive bays (one side of aisle)
- **Ownership**: Jointly by Store Operations and Category Management
- **Modification**: Only during major layout or planogram restructures

### StoreWalk Group (CR35)
- Dedicated group configuration for store walk operations
- Manage Group Configuration provides UI for mapping bays to StoreWalk groups
- Distinct from normal replenishment groups

---

## 3. Sales-Based Stock Replenishment

### Process Flow
```
┌──────────────────────────────────────────────────────┐
│  Background Service (Every 15 Minutes)               │
│                                                      │
│  1. Call OpSuite SP: GetTransactionsforToday          │
│  2. Fetch transactions since last sync               │
│  3. Deduplicate by Transaction Number                │
│  4. Calculate cumulative units/cases sold per product │
│  5. If cumulative units >= CaseSize:                 │
│     → Create CaseReplenActions record                 │
│     → ActionCode = 0 (normal replenishment)          │
│  6. Update CumulativeSales table                     │
└──────────────────────────────────────────────────────┘
```

### UoM Codes
| Code | Meaning |
|------|---------|
| 1 | Individual item |
| 2 | Case |
| 3 | Case (alternate) |

### Key Rules
- **Deduplication**: Based on Transaction Number to prevent double-counting
- **Cumulative Tracking**: Units accumulate; when >= CaseSize → generate replen action
- **ActionCode = 0**: Normal replenishment (vs other codes for special actions)
- **15-minute cycle**: Fixed interval, not configurable per store

---

## 4. Low / No Stock / Sales Replenishment — Background Process

### Store Walk Process (Every 10 Seconds)
```
┌──────────────────────────────────────────────────────┐
│  Background Service (Every 10 Seconds)                │
│                                                      │
│  1. Scan products flagged as Low Stock / No Stock    │
│  2. Evaluate Fill & Face values for threshold        │
│  3. Create immediate replenishment task:              │
│     - Low Stock → scheduled replenishment            │
│     - No Stock → urgent replenishment                │
│  4. Update product status with color coding:         │
│     - Green: Good stock                              │
│     - Amber: Low stock warning                       │
│     - Red: Critical / No stock                       │
└──────────────────────────────────────────────────────┘
```

### Low/No Stock Calculation (CR23)
- **Fill**: Product face display quantity (how many items fit in one facing)
- **Face**: Number of shelf facings for the product
- **Formula**: Shelf Capacity = Fill × Face
- **Low Stock**: Current stock < Threshold% of Shelf Capacity
- **No Stock**: Current stock = 0

---

## 5. Stock Replenishment — Picking Workflow

### Step-by-Step Flow
```
1. Picker opens Pick List on HHD
2. Selects ReplenGroup → Group locked (concurrent access blocked)
3. Products displayed in Warehouse Sequence order
4. For each product:
   a. Scan case barcode
   b. Confirm quantity (no over-pick allowed)
   c. Override via SEL QR/manual entry → logged
   d. Skip pick option available
5. On completion:
   a. Statistics: SKUs picked, SKUs skipped, time taken
   b. Lock released on ReplenGroup
   c. Shortfalls: partial quantity → remainder returned to CaseReplenActions
```

### Picking States
| State | UI Display Fields |
|-------|-------------------|
| **Not Started** | ReplenGroup, Total Cases/SKUs, In Pick, In Bulk, Actions |
| **In Progress** | ReplenGroup, PickStartTime, Progress (min), SKUs picked/skipped |
| **Completed** | ReplenGroup, Total time, Completion stats, Actions |

### Auto Refresh (CR37)
- Configurable refresh frequency for replenishment lists
- Real-time visibility of pick status on web dashboard

---

## 6. Bulk Replenishment — Pallet

### Four Functional Areas
| Process | Description | Location |
|---------|-------------|----------|
| Pallet Drop | Move cases from bulk (in-rack) to ground-level pick-face | Bulk → Pick-face |
| Put-Away | Cases from dropped pallets into pick locations or Overstock | Pallet → Location |
| Move to Pick Location | Direct move from Receive/Transfer to pick-face | TRANS/RECV → Pick-face |
| Move from Overstock | Replenish pick-face from Overstock cases | Overstock → Pick-face |

### Fill & Trigger Quantities
- **Fill Quantity (MaxQtyCases)**: Max cases fitting in pick-face (e.g., 15)
- **Trigger Quantity (TriggerQtyCases)**: Threshold for Bulk Replen request (e.g., 5)
- When remaining stock ≤ TriggerQty → SRS generates Bulk Replen task
- Typically executed next morning before store opening

### Cumulative Depletion Tracking
- **Both count**: Cases sold through tills (EPOS) + Cases moved to store for replenishment
- Maintained per: Store + SKU + pick-face location
- Drives when Trigger threshold is crossed

### Mobile Enhancement (CR25)
- Scan button for direct workflow entry
- Unified scan action as single entry point
- Quantity entry validation during replenishment
- "Details" button renamed to "Pallets" on mobile

---

## 7. Move From Overstock

- Replenish pick-face from Overstock cases
- Warehouse inventory lookup for overstock quantities
- Scan confirmation for source → destination movement
- Stock level updates on movement confirmation

---

## 8. Move To Pick Location

### Move to TRANS/RECV (CR41)
- **Product info display** during movement
- **Last known location validation**: prefix + numeric format
- **Case quantity validation** rules
- **Full mobile workflow** for TRANS/RECV moves
- Direct move from Receive/Transfer location to pick-face

---

## 9. Put-Away

- Cases from dropped pallets placed into pick locations or Overstock
- Pick Group-based routing for efficient forklift movement
- Scan-to-locate workflow for accurate placement
- Inventory updates on confirmation

---

## 10. Release Locked Replen Groups

### Concurrency Control
- **Lock mechanism**: ReplenGroup locked when user starts pick
- **Blocking**: Other users prevented from same group
- **Conflict message**: Clear notification on concurrent access attempt
- **Lock release**: On pick completion, timeout, or manual release
- **Exit & locking (CR39)**: Graceful lock release on app exit/crash

### Admin Functions
- Release locked groups (admin/SuperUser)
- View lock status across all groups
- Force-release for stale locks (app crash scenarios)

---

## Cross-References

- [Key LLD Summaries](./02-key-llds.md) — High-level LLD overview
- `Functional Modules — Replenishment` — Business rules
- [Didi Store LLDs](./04-lld-didi-store-detail.md) — Didi-specific replenishment
- [Microservices Design](../architecture/03-microservices-design.md) — CQRS pattern
- [Workflow Docs](../testing/02-workflow-docs.md) — Process flow diagrams