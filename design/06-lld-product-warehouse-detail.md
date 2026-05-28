# Product & Warehouse LLD — Detail

> Derived from `drive/Documents/Design/Product Enquiry/`, `drive/Documents/Design/Product Locator/`, `drive/Documents/Design/Warehouse Layout/`, and `drive/Documents/Design/StoreLayout & Bay Group/`.

---

## Product Service LLD

### Source: `drive/Documents/Design/Product Enquiry/`

| Document | Description |
|----------|-------------|
| LLD - Product Service.docx | Product microservice design |
| Wing Yip - Product Enquiry.docx | Product enquiry functionality |

### Product Enquiry Features
- **Search**: By description, SKU, partial keyword, barcode
- **Product Status**: Color-coded identification (Green/Amber/Red)
- **Editable Fields**: With audit tracking (CR7) — changes logged with UserID, timestamp, old/new values
- **Shop + Warehouse Location Visibility**: Expanded in CR5 — view all locations for a product
- **Central Distribution Card**: Enhanced in CR10 — expanded display, multiple location expansion

### Product Data Model
| Entity | Key Fields |
|--------|-----------|
| Product | ProductID, Name, Description, UOM, CaseSize, Status |
| ProductLocation | ProductID, StoreID, Aisle, Bay, Level, Position |
| ProductBarcode | ProductID, Barcode, BarcodeType |
| Price | ProductID, StoreCode, UOM, PriceLevel, SellingPrice |
| ItemBarcodeMaster | SKU, ProductDescription, ItemGroupCode, UomCode, CaseSize |

### BE_EcoSystem Reference
- API reference: `docs/API_Controllers_Reference.md` — WingYip.SRS.Product section
- Tables: Referenced in `StoreLayout_BayManagement.md` (ItemBarcodeMaster, PriceLevelMaster, Inventory)

---

## Product Locator LLD

### Source: `drive/Documents/Design/Product Locator/`

| Document | Description |
|----------|-------------|
| LLD - Product Locator.docx | Product locator on store layout |

### Features (CR11, CR12 Enhanced)
- **Search by Description**: Partial keyword matching, unified search field
- **Product Details Panel**: Shows Description, UOM, Case Size
- **Location Mapping**: Visual display of product location in store layout
- **Integration with Store Layout**: Uses SpaceMan location data (ShopLocations)

### Integration Points
- SpaceMan Service: Location data, aisle/bay/level mappings
- Product Service: Product master data, barcodes
- Store Layout: Visual rendering of store map with product pins

---

## Warehouse Layout LLD

### Source: `drive/Documents/Design/Warehouse Layout/`

| Document | Description |
|----------|-------------|
| LLD - Warehouse Layout.docx | Warehouse layout design |
| Warehouse Layout.xlsx | Warehouse layout data |

### Warehouse Location Model
| Entity | Key Fields |
|--------|-----------|
| WarehouseLocation | LocationID, StoreID, Aisle, Bay, Level, Type |
| PickGroup | StoreID, Aisle, Bay, Level → PickGroupName |
| FillTrigger | LocationID, MaxQtyCases, TriggerQtyCases |

### Location Types
| Type | Description |
|------|-------------|
| Bulk (In-Rack) | Primary warehouse storage, above/below pick-face |
| Pick-Face | Ground-level accessible location for picking |
| Overstock | Overflow storage near pick-face |
| TRANS/RECV | Receiving and transfer staging area |
| Central | Central distribution coldstore (Birmingham) |

### Warehouse → Pick Group Mapping
- Each location (Store + Aisle + Bay + Level) maps to exactly one Pick Group
- Pick Groups drive bulk replenishment routing
- Fill/Trigger quantities configured per pick-face location

---

## Store Layout & Bay Group LLDs

### Source: `drive/Documents/Design/StoreLayout & Bay Group/`

| Document | Description |
|----------|-------------|
| LLD - Store Layout.docx | Store layout design and management |
| LLD - BayGroup.docx | Bay group management |
| StoreLayoutDesign.docx | Store layout design reference |
| Store Layouts.xlsx | Store layout data |
| DIDI - Store Layouts - Watford.xlsx | Didi store (Watford) layout |

### Store Layout Hierarchy
```
Store → Aisle → Bay → Section → Component
                                              → ShopLocation (Product placement)
```

### Key Tables (from BE_EcoSystem docs)
| Table | Columns |
|-------|---------|
| ShopLocations_NEW | Store, Aisle, Bay, Level, Position, ProductNo, Bay_Group_No, UoM |
| SpaceMan_BayGroups | BayGrpNo, BayGrpName |
| SpaceMan_DraftPlans | CatPlanRef, Store, Aisle, Bay, Status, Owner |
| SpaceMan_DraftDetails | CatPlanRef, Store, Aisle, Bay, Level, Position, Sku |
| SpaceMan_FillFace | CatPlanRef, Store, Aisle, Bay, Level, Position, Fill, Face |
| SpaceMan_Unassigned | CatPlanRef, Store, Aisle, Bay, Level, Position, Sku, Status |
| SpaceMan_DraftDelisted_NEW | CatPlanRef, Sku, Description, Reason, ReasonCode |
| SpaceMan_DraftComments | CatPlanRef, Comment, CommentBy, CommentDate |

### Didi Store Layouts
- Watford: First Didi store (opened 4-Dec-2025), ~850 products
- Layout data: `DIDI - Store Layouts - Watford.xlsx`
- Compact format: No storage area, daily deliveries

---

## Cross-References

- [LLD Index](./01-lld-index.md) — Full LLD inventory
- [Functional Modules — Product Enquiry](../requirements/02-functional-modules.md#4-product-enquiry) — Business rules
- [Functional Modules — Store Layout](../requirements/02-functional-modules.md#2-store-layout--planogram-spaceman) — Business rules
- [Functional Modules — Warehouse](../requirements/02-functional-modules.md#3-warehouse-layout) — Business rules
- [Database Schema](../architecture/08-database-schema.md) — Data entities
- [BE_EcoSystem docs](../../WingYip_SRS_BE_EcoSystem/docs/) — Code-level documentation