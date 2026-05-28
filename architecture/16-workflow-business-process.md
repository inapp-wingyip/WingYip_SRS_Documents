# Workflow & Business Process Reference

> Derived from `drive_raw/Documents/Data Issues/` workflow documents, `drive_raw/Documents/Design/Replenishment/` LLDs, `drive_raw/Documents/Requirements/` FRDs, and `drive_raw/Documents/Testing/` workflow test scenarios.

---

## Overview

This document consolidates all business process workflows documented across the project's raw source materials. Each workflow is traced to its source documents, LLDs, and FRDs for full traceability.

---

## Core Replenishment Workflows

### 1. Sales-Based Replenishment (15-minute cycle)

**Source**: `drive_raw/Documents/Data Issues/Sales Based Replenishment Workflow.docx`, `drive_raw/Documents/Design/Replenishment/LLD - Sales Based Stock Replenishment.docx`, `WingYip - Storewalk and Sales Replenishment FRD.docx`

```
OpSuite (15 min) → CumulativeSales calculation →
  CaseReplenActions created → ReplenGroups populated →
    Picking workflow triggered
```

**Process**:
1. OpSuite feeds sales transactions every 15 minutes
2. Cumulative sales calculated per product per store
3. CaseReplenActions generated for products below threshold
4. Replenishment groups populated with tasks
5. SOCO/user picks group → locks → picks items → confirms → releases

**Key Rules**:
- 15-minute cycle for sales-based replenishment
- Cumulative depletion: both till sales AND store replenishment count
- Fill quantity = MaxQtyCases — CurrentQtyCases
- Trigger quantity = threshold for auto-creation of replenishment task

---

### 2. Store Walk Replenishment (10-second cycle)

**Source**: `drive_raw/Documents/Data Issues/Replenishment Work Flow.docx`, `drive_raw/Documents/Design/Replenishment/LLD - Low _ No Stock _ Sales Replenishment - BG Process.docx`, `drive_raw/Documents/Design/Store Operations/LLD - Store Walk.docx`

```
Store Walk (10 sec) → Low/No Stock detection →
  Fill & Face calculation → Replenishment tasks →
    SOCO picks → confirms → release
```

**Process**:
1. HHD user walks store aisles
2. System detects low stock (amber) / no stock (red) items every 10 seconds
3. Fill & Face calculation determines replenishment quantity
4. Tasks assigned to replenishment groups
5. Color coding: Green (good), Amber (low), Red (critical/no stock)

**Color Status**:
| Color | Status | Action |
|-------|--------|--------|
| Green | Good stock level | No action needed |
| Amber | Low stock | Replenishment suggested |
| Red | No stock / Critical | Immediate replenishment required |

---

### 3. Replenishment Picking Workflow

**Source**: `drive_raw/Documents/Data Issues/Replenishment Picking Workflow.docx`, `drive_raw/Documents/Design/Replenishment/LLD - Stock Replenishment.docx`

```
Select Group → Lock Group → Pick Items → Confirm Pick → Release Group
```

**Concurrency Control (CR39)**:
- Group locking: Only one user can pick a group at a time
- Lock acquired on group selection
- Lock released on confirm, exit, or crash recovery
- Conflict notification sent if group already locked

---

## Bulk Replenishment Workflows

### 4. Bulk Replenishment & Pallet

**Source**: `drive_raw/Documents/Data Issues/Bulk Replenishment Work Flow.docx`, `drive_raw/Documents/Design/Replenishment/LLD - Bulk Replenishment - Pallet.docx`, `WingYip - Bulk Replenishment - FRD.docx`

```
Pallet Drop → Put-Away → Move To Pick Location → Move From Overstock
```

**Sub-Processes**:

| Process | Description |
|---------|-------------|
| **Pallet Drop** | Move cases from bulk in-rack to ground-level pick-face by Pick Group |
| **Put-Away** | Place cases from dropped pallets into pick locations or Overstock |
| **Move To Pick Location** | Direct move from Receive/Transfer to pick-face |
| **Move From Overstock** | Replenish pick-face from Overstock cases |

**Pick Groups**:
- Logical work areas comprising 1+ aisles (both sides)
- Maps to: Store + Aisle + Bay + Level
- Fill quantity: MaxQtyCases per location
- Trigger quantity: Threshold for auto-replenishment

---

## Didi Store Workflows

### 5. Didi Store Replenishment

**Source**: `drive_raw/Documents/Data Issues/Didi Stores Replenishment Workflow.docx`, `drive_raw/Documents/Design/Didi Store/` (8 LLDs)

```
Daily Process → Check Case Replen Requests →
  Emergency Orders → Manual Orders → Excess Stock Handling →
    Stock Adjustment Logging
```

**Sub-Processes**:

| Process | LLD Source |
|---------|-----------|
| **Daily Process** | `LLD - Daily Process.docx` |
| **Check Case Replen Requests** | `LLD - Check Case Replen Requests.docx` |
| **Emergency Order** | `LLD - Emergency Order.docx` |
| **Manual Order** | `LLD - Manual Order.docx` |
| **Excess Stock** | `LLD - Excess Stock.docx` |
| **SKU Diagnostic** | `LLD - SKU Diagnostic.docx` |
| **Didi Schedule** | `LLD - Didi Schedule.docx` |
| **Stock Adjustment Log** | `LLD - Stock adjustment Log.docx` |

**Key Characteristics**:
- Didi stores are smaller format (~850 products)
- No storage; daily deliveries from central distribution
- Emergency orders for urgent needs
- First Didi store opened in Watford (4-Dec-2025)

---

## Fresh Goods Replenishment

### 6. Fresh Good Replenishment

**Source**: `drive_raw/Documents/Data Issues/Fresh Good Replenishment Workflow.docx`, `WingYip - Fresh Good Replenishment - FRD.docx`

```
Fresh-specific triggers → Spoilage tracking →
  Write-off management → Emergency handling
```

**Key Differentiators from Ambient Replenishment**:
- Perishable product handling (distinct from ambient/dry goods)
- Fresh-specific triggers and alerts
- Spoilage tracking with audit trail
- Expiration date management
- Short-dated product handling
- Delivery exception management

---

## Support Workflows

### 7. Planogram Implementation (SpaceMan)

**7-Stage Workflow**:
1. **Draft** — Initial layout design
2. **Review** — CATMAN review and approval
3. **Approved** — Ready for implementation
4. **Implementing** — Active implementation (triggers SEL printing)
5. **Implemented** — Complete (triggers SEL print queue)
6. **Active** — Live in store
7. **Archived** — Historical reference

Source: [Functional Modules](../requirements/02-functional-modules.md)

### 8. SEL Printing Workflow

**Triggers**: Planogram status change, Price change (SAP/OpSuite), Manual request

Source: [SEL Printing Detail](../architecture/09-sel-printing-detail.md)

### 9. Perpetual Inventory (PI)

- Stock counting process with variance resolution
- Date check process for expiration management

### 10. Stock Control & Discrepancy

- Discrepancy detection → Investigation → Resolution → Write-off if needed

### 11. SOCO (Stock Ordering Coordination)

- Short-code label replacement workflow
- Alert-driven replenishment coordination

---

## Background Processes

**Source**: `drive_raw/Documents/Design/Background Process/Back Ground and Pipeline Process_.xlsx`

| Process | Frequency | Description |
|---------|-----------|-------------|
| Sales Replenishment | 15 min | OpSuite sales → CumulativeSales → CaseReplenActions |
| Store Walker | 10 sec | Low/no stock detection |
| Data ETL | Scheduled | SAP/Korber/OpSuite → Bronze → Silver → Gold |
| PI Count | On demand | Physical inventory counting |
| Price Change Detection | Daily | Price changes from SAP/OpSuite trigger SEL updates |

---

## Raw Source Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Documents/Data Issues/Replenishment Work Flow.docx` | General replenishment process flow |
| `drive_raw/Documents/Data Issues/Sales Based Replenishment Workflow.docx` | Sales-based replenishment flow |
| `drive_raw/Documents/Data Issues/Bulk Replenishment Work Flow.docx` | Bulk replenishment process flow |
| `drive_raw/Documents/Data Issues/Didi Stores Replenishment Workflow.docx` | Didi store replenishment flow |
| `drive_raw/Documents/Data Issues/Fresh Good Replenishment Workflow.docx` | Fresh goods replenishment flow |
| `drive_raw/Documents/Data Issues/Replenishment Picking Workflow.docx` | Picking workflow |
| `drive_raw/Documents/Design/Background Process/Back Ground and Pipeline Process_.xlsx` | Background and pipeline processes |

---

## Cross-References

- [Functional Modules](../requirements/02-functional-modules.md) — Detailed module specifications
- [FRD Summaries](../requirements/04-frd-summaries.md) — FRD documents
- [Replenishment LLDs](../design/03-lld-replenishment-detail.md) — Replenishment deep-dive
- [Didi Store LLDs](../design/04-lld-didi-store-detail.md) — Didi deep-dive
- [SEL Printing](../architecture/09-sel-printing-detail.md) — Print workflows
- [Test Scenarios](../testing/01-test-scenarios.md) — Workflow test scenarios
- [Workflow Docs](../testing/02-workflow-docs.md) — Workflow test documentation