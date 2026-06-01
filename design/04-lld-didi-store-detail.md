# Didi Store LLD — Module Summaries

> Comprehensive index of all 8 Didi Store LLD documents from `drive/Documents/Design/Didi Store/`.

---

## LLD Index

| # | Document | Focus Area |
|---|----------|------------|
| 1 | LLD - Daily Process.docx | Daily scheduled replenishment |
| 2 | LLD - Didi Schedule.docx | Delivery scheduling configuration |
| 3 | LLD - Emergency Order.docx | Emergency order processing |
| 4 | LLD - Manual Order.docx | Manual order creation |
| 5 | LLD - Check Case Replen Requests.docx | Verify replenishment requests |
| 6 | LLD - Excess Stock.docx | Excess stock management |
| 7 | LLD - SKU Diagnostic.docx | SKU diagnostics for Didi |
| 8 | LLD - Stock adjustment Log.docx | Stock adjustment audit |

---

## Didi Store Business Context

- **Format**: Smaller stores carrying ~850 products (ambient, chilled, frozen)
- **First Store**: Watford (opened 4-Dec-2025)
- **No Storage Area**: Daily deliveries based on previous day's sales and wastage
- **Parent Store**: Each Didi store linked to a parent superstore for emergency supplies

---

## 1. Daily Process

### Scheduled Replenishment (Automated)
```
┌──────────────────────────────────────────────────────┐
│  Daily Automated Replenishment Cycle                  │
│                                                      │
│  1. End-of-day previous:                              │
│     - Capture today's sales per product               │
│     - Record wastage and spoilage                     │
│  2. Calculate tomorrow's delivery:                    │
│     - Base = Previous day's sales                     │
│     - Adjust for wastage                              │
│     - Apply supply chain config per Didi store        │
│  3. Generate delivery order                          │
│  4. Temperature-based segregation:                   │
│     - Ambient: Standard routing                      │
│     - Chill: Cold chain routing                      │
│     - Frozen: Frozen chain routing                   │
│  5. Dispatch from parent superstore/central warehouse │
└──────────────────────────────────────────────────────┘
```

### Temperature-Based Segregation
| Zone | Route | Vehicle |
|------|-------|---------|
| Ambient | Standard delivery | Standard van |
| Chilled | Cold chain | Refrigerated van |
| Frozen | Frozen chain | Freezer van |

---

## 2. Didi Schedule

### Supply Chain Configuration
- Per-Didi-store configuration of:
  - Parent superstore assignment
  - Delivery frequency (default: daily)
  - Delivery time window
  - Product catalog (~850 products)
  - Temperature zone routing
- Configuration managed through Didi Admin (web)

### Scheduling Rules
- Automatic daily schedule generation
- Ability to override for holidays/special events
- Emergency order creates immediate delivery request
- Manifest generation per scheduled delivery

---

## 3. Emergency Order

### Emergency Order Flow (Mobile)
```
1. Didi store staff opens Emergency Order on HHD
2. Select Source Store (parent superstore)
3. Product Identification:
   - Scan product barcode
   - Or search by description/SKU
4. Product Confirmation & Quantity Entry:
   - Confirm product details
   - Enter required quantity
5. Order Review:
   - Review all items
   - Edit quantities or remove items
6. Submit Order:
   - Send to parent store
   - Notification to parent store SOCO/Warehouse
7. Cancellation:
   - Available before dispatch
   - Notification sent on cancellation
```

### Key Design Points
- Mobile-first workflow (HHD)
- Source store validation (must be assigned parent)
- Real-time notification to source store
- Order status tracking: Created → Acknowledged → In Progress → Dispatched → Delivered

---

## 4. Manual Order

- Manual order creation for non-standard replenishment
- Available when automated schedule doesn't cover specific needs
- Similar workflow to emergency order but without urgency flag
- Managed through web or mobile interface

---

## 5. Check Case Replen Requests

- Verify automatically generated replenishment requests
- Review quantities against expected sales
- Approve or modify before order generation
- Exception handling for anomalous requests

---

## 6. Excess Stock

### Excess Stock Detection
- Compare current stock levels against expected demand
- Products with stock exceeding threshold flagged as excess
- Options:
  - Return to parent store (reverse logistics)
  - Adjust future delivery quantities
  - Promote for sale (if applicable)

### Cumulative Sales Tracking
- Track daily sales per product per Didi store
- Adjust delivery quantities dynamically based on sales trends
- Waste and contingency reporting

---

## 7. SKU Diagnostic

- Per-SKU analysis for Didi stores
- Sales velocity, stock level, replenishment frequency
- Identify slow-moving, fast-moving, and non-moving products
- Action recommendations (add to catalog, remove, adjust replen)
- SKU Diagnostic also available in Admin Menu

---

## 8. Stock Adjustment Log

- Audit log for all stock adjustments at Didi stores
- Captures: ProductID, AdjustmentType, Qty, UserID, Timestamp, Reason
- Types: Delivery received, Emergency order, Write-off, Spoilage, Manual adjustment
- Immutable audit trail for compliance and reconciliation
- Integration with centralized Stock Control Audit

---

## Didi Admin Configuration (Web)

| Configuration | Description |
|-------------|-------------|
| Products Not Replenished from Customer Warehouse | Exclude products from automated delivery |
| Shop Floor Picks Configuration | Shop floor pick settings |
| Hot Food Products | Maintain hot food product catalog |
| GNFR Items | Goods Not For Resale management |
| GNFR Uniforms | Uniform inventory management |
| Edit Fill Face | Fill/Face values for Didi store products |
| Store Layouts | Didi-specific layout (Watford.xlsx) |

---

## Didi Store Data References

| Document | Description |
|----------|-------------|
| LLD - Didi Replenishment.docx | Didi replenishment in Replenishment module |
| DIDI - Store Layouts - Watford.xlsx | Watford store layout data |
| Didi Stores Replenishment Workflow.docx | Process flow documentation |
| DIDI Store SRS Go-Live Prerequisites & Cutover Plan.docx | Go-live plan |

---

## Cross-References

- `Functional Modules — Didi Store` — Business rules
- [Replenishment LLDs](./03-lld-replenishment-detail.md) — Core replenishment design
- [Deployment Strategy](../infrastructure/01-deployment-strategy.md) — Didi go-live plan
- [Key LLD Summaries](./02-key-llds.md) — Overview