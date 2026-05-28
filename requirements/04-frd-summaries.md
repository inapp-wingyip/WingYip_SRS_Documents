# Functional Requirements Documents (FRDs) — Summaries

> Derived from FRD documents in `drive/Documents/Requirements/`.

---

## FRD Overview

In addition to the main BRD (v3.1), four FRDs and two solution documents provide detailed functional specifications for specific modules.

---

## 1. Bulk Replenishment FRD

**Document**: `WingYip - Bulk Replenishment - FRD.docx`

### Scope
- Customer Warehouse operations: Pallet Drop, Put-Away, Move to Pick Location, Move from Overstock
- Pick Group management and Fill/Trigger quantity configuration
- Cumulative depletion tracking
- Mobile workflow enhancements

### Key Functional Areas
| Area | Description |
|------|-------------|
| Pallet Drop | Move cases from bulk in-rack to ground-level pick-face by Pick Group |
| Put-Away | Place cases from dropped pallets into pick locations or Overstock |
| Move to Pick Location | Direct move from Receive/Transfer to pick-face |
| Move from Overstock | Replenish pick-face from Overstock cases |
| Pick Groups | Logical work areas (1+ aisles, both sides); maps to Store + Aisle + Bay + Level |
| Fill & Trigger | MaxQtyCases + TriggerQtyCases per location |
| Cumulative Depletion | Both till sales and store replenishment count as depletion |

---

## 2. Fresh Good Replenishment FRD

**Document**: `WingYip - Fresh Good Replenishment - FRD.docx`

### Scope
- Perishable product handling distinct from ambient/dry goods
- Fresh-specific replenishment triggers and alerts
- Spoilage and write-off tracking

### Key Functional Areas
| Area | Description |
|------|-------------|
| Identification & Coding | Separate tracking for fresh products |
| Replenishment Triggers | Configurable fresh-specific triggers |
| Stock Tracking | Perishable stock monitoring and expiration management |
| Spoilage / Write-offs | Fresh-specific spoilage tracking with audit trail |
| Exception Handling | Delivery issues, short-dated products |
| Configuration | Fresh goods-specific configurable parameters |

---

## 3. Storewalk and Sales Replenishment FRD

**Document**: `WingYip - Storewalk and Sales Replenishment FRD.docx`

### Scope
- Two replenishment engines: Sales-based (15 min) and Store Walk (10 sec)
- Picking workflow and concurrency control
- Replenishment group structure

### Key Functional Areas
| Area | Description |
|------|-------------|
| Sales-Based Replenishment | 15-minute cycle, OpSuite transaction processing, CaseReplenActions |
| Store Walk Replenishment | 10-second cycle, Low/No stock detection, Fill & Face calculation |
| Replenishment Groups | Consecutive bays with temperature zone, naming convention |
| Picking Workflow | Select group → Lock → Pick → Confirm → Release |
| Concurrency | Group locking, conflict notification, lock release on exit/crash |
| Color Coding | Green (good), Amber (low), Red (critical/no stock) |

---

## 4. SOCO Requirements

**Document**: `WingYip - SOCO - Requirements.docx`

### Scope
- SOCO (Stock Ordering Coordinator) daily operations
- Dashboard, monitoring, and reporting

### Key Functional Areas
| Area | Description |
|------|-------------|
| SOCO Dashboard | Web-only hub for daily SOCO operations |
| Temp OOS Management | Temporarily Out of Stock label handling |
| SAP Review | Daily schedule review of SAP data |
| Product Evaluation | Scenario-based product evaluation logic |
| Monitoring | Low stock alerts, discontinued line checks, cross-store overstock |
| Promotions | Management of current promotions |
| Reports | Date Check Follow-Up, Operational Performance |

---

## 5. Directed Storewalk & Promotional Ends

**Document**: `WingYip_ Solution Document- Directed Store walk and Promotional Ends.docx`

### Scope
- Directed Storewalk for multi-location product placement (Dual Merchandise)
- Promotional end cap management

### Key Functional Areas
| Area | Description |
|------|-------------|
| Multi-Location Products | Products placed in multiple locations within store |
| Directed Storewalk | Guided walk workflow for stock verification and placement |
| Promotional Ends | End-of-aisle promotional display management |
| Warehouse Sourcing | Stock availability from warehouse for dual-located products |
| Reporting | Web-based tracking and reporting for directed storewalk |

---

## 6. Shelf Edge Label Printing Requirements

**Document**: `Shelf Edge Label Printing - Funtional Requirements.docx`

### Scope
- Label generation, printing rules, and printer integration
- Crystal Reports for label formats
- v3.0 enhancements (CR17, CR27, CR28)

### Key Functional Areas
| Area | Description |
|------|-------------|
| Label Generation | Product info, price, barcode/QR per label |
| Printing Modes | Batch, individual, price-change triggered |
| Crystal Reports | BM_Large Label QR.rpt, BM_Small Label QR.rpt |
| Label Size (CR17) | Configurable label sizes per print context |
| Change Management (CR27) | Label change tracking and reprint log |
| Extended Printing (CR28) | Print All for Product, Full Bay, Pick Group, Replen Group |

---

## Legacy UI Analysis Documents

| Document | Description |
|----------|-------------|
| WingYip - Replenishment - Legecy UI.docx | Analysis of legacy replenishment UI for migration reference |
| WingYip -Finance - Legecy UI.docx | Analysis of legacy finance UI for migration reference |

---

## Cross-References

- [BRD Summary](./01-brd-summary.md) — Full business requirements (v3.1)
- [Functional Modules](./02-functional-modules.md) — Module-by-module details
- [Key LLDs](../design/02-key-llds.md) — LLD summaries for these modules
- [Replenishment LLDs](../design/03-lld-replenishment-detail.md) — Detailed replenishment design