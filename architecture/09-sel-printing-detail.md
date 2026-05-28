# Shelf Edge Label Printing — Detailed Architecture

> Derived from `drive/Documents/Design/Shelf Edge Label Printing/`, `drive/Documents/Design/Analysis/` (Crystal Reports, Print UI, SEL analysis), `drive/Documents/Requirements/Shelf Edge Label Printing - Funtional Requirements.docx`, and `drive/Documents/Design/Analysis/Endpoints for Shelf Edge Label Printing.docx`.

---

## Overview

The Shelf Edge Label (SEL) Printing module generates product labels with pricing, barcodes/QR codes, and product information. It supports batch and individual printing triggered by planogram events, price changes, or manual requests. Both Web and Mobile interfaces are provided.

---

## Architecture Components

```
┌──────────────────────────────────────────────────────────┐
│                   SEL Printing System                     │
│                                                          │
│  ┌──────────────┐    ┌──────────────┐                     │
│  │  Web Portal  │    │  Mobile HHD  │                     │
│  │  (React Web)  │    │  (React Native)│                     │
│  └──────┬───────┘    └──────┬───────┘                     │
│         │                   │                              │
│         └─────────┬─────────┘                              │
│                   ▼                                       │
│  ┌──────────────────────────┐                             │
│  │    Print Service API     │                             │
│  │  (WingYip.SRS.Print)    │                             │
│  └──────────┬───────────────┘                             │
│             │                                              │
│  ┌──────────▼───────────┐   ┌──────────────────────────┐ │
│  │  Crystal Reports     │   │   Manifest PDF Generator  │ │
│  │  Engine              │   │                           │ │
│  │  - BM_Large Label QR │   │   Prints delivery manifest│ │
│  │  - BM_Small Label QR │   │   for bulk label batches  │ │
│  └──────────┬───────────┘   └──────────────────────────┘ │
│             │                                              │
│  ┌──────────▼───────────┐                                │
│  │  Label Printer       │                                │
│  │  (Hardware)           │                                │
│  └──────────────────────┘                                │
└──────────────────────────────────────────────────────────┘
```

---

## Crystal Reports

### Label Formats
| Report File | Format | Description |
|------------|--------|-------------|
| BM_Large Label QR.rpt | Large | Full-size product label with QR code |
| BM_Small Label QR.rpt | Small | Compact product label with QR code |

### Label Data References
| Spreadsheet | Description |
|-------------|-------------|
| LargeLabelDetails.xlsx | Field mapping for large label format |
| SmallLabelDetails.xlsx | Field mapping for small label format |

### Label Size Flexibility (CR17)
- Configurable label dimensions per print context
- Size selection at print time (Large or Small)
- Current: Large (100×50mm) and Small (70×30mm) formats supported

---

## Print Service Architecture

### API Endpoints
Source: `Endpoints for Shelf Edge Label Printing.docx`

| Endpoint | Method | Description |
|----------|--------|-------------|
| Print by Product | POST | Print all labels for a specific product |
| Print by Store Full Bay | POST | Print labels for all products in a store bay |
| Print by Warehouse Full Bay | POST | Print labels for all products in a warehouse bay |
| Print by Pick Group | POST | Print labels for all products in a pick group |
| Print by Replen Group | POST | Print labels for all products in a replenishment group |
| Print Manifest | POST | Generate manifest PDF for a label batch |
| Reprint Labels | POST | Reprint previously generated labels (CR27) |

### Printing Options (CR28 — Extended)

| Option | Input Parameters | Output |
|--------|-----------------|-------|
| Print All Labels for Product | Product ID, UOM selection, Location, Label size | All labels for that product |
| Store Full Bay | Location (Store/Aisle/Bay), Context | All labels for bay |
| Warehouse Full Bay | Location (Aisle/Bay), Context | All labels for warehouse bay |
| By Pick Group | Pick Group selection, Label size | All labels for pick group |
| By Store Replen Group | Replen Group selection | All labels for replen group |

---

## Print Workflow

### Planogram Implementation Printing
1. Planogram status changes to **Implemented**
2. System identifies products with location changes
3. SEL print queue populated with affected products
4. Labels generated via Crystal Reports
5. Sent to configured label printer
6. Reprint option available from Implemented status

### Price Change Triggered Printing
1. Price change detected from SAP/OpSuite pipeline
2. Products with price changes flagged
3. SEL print queue updated
4. Batch print job created for all price-change labels

### Manual Printing
- User selects product, bay, pick group, or replen group
- Configurable label size (CR17)
- Immediate print to configured printer

---

## SEL Print Service Design

Source: `SEL_Print Printing Service.docx`, `Queries_SEL_Print.xlsx`

### Key Design Decisions
- **Print Service** is a dedicated microservice (`WingYip.SRS.Print`)
- Crystal Reports runtime hosted within the service
- Printer configuration per store (managed in Admin Configuration)
- Print queue with retry logic for printer failures
- Manifest PDF generation for audit trail and delivery tracking

---

## Change Management & Reprint (CR27)

- All label changes tracked in **Shelf Label Change Log**
- Reprint log captures: ProductID, timestamp, reason, user, label content
- Reprint available from planogram Implemented status
- Full change history with timestamps for audit

---

## Integration Points

| System | Integration | Purpose |
|--------|-------------|---------|
| SpaceMan Service | Event-driven | Planogram implementation triggers label printing |
| Product Service | REST | Product info for label content |
| Price Data (SAP/OpSuite) | Pipeline | Price change detection triggers label updates |
| Store Configuration | REST | Printer settings per store |
| Audit Service | RabbitMQ | All print actions centrally logged |

---

## LLD References

| Document | Description |
|----------|-------------|
| LLD - Shelf Edge Label Printing.docx | Main SEL printing design |
| LLD - Print Service.docx | Print service component design |
| LLD - Manifest PDF.docx | Manifest PDF generation |
| Shelf Edge Label Printing - Funtional Requirements.docx | SEL functional requirements |
| Endpoints for Shelf Edge Label Printing.docx | API endpoint definitions |
| SEL_Print Printing Service.docx | Print service analysis |
| Queries_SEL_Print.xlsx | Print service SQL queries |
| Shelf Edge Label Printing - Analysis.xlsx | SEL printing analysis |

---

## Cross-References

- [Functional Modules — SEL](../requirements/02-functional-modules.md#11-shelf-edge-label-printing) — Business rules
- [Microservices Design](../architecture/03-microservices-design.md) — Print service in microservices
- [Frontend & Mobile](../architecture/07-frontend-mobile-architecture.md) — Web + HHD printing interface