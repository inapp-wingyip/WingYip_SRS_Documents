# UI/UX Design Architecture & Standards

> Derived from `drive_raw/Documents/Design/Analysis/Frontend_Architecture_WingYip_SRS.docx`, `drive_raw/Documents/Design/Analysis/HH_Mobile App_Architecture_WingYip_SRS.docx`, `drive_raw/Documents/Design/Analysis/Mobile Application Architecture Document.docx`, `drive_raw/Documents/Design/Analysis/Frontend Low Level Architecture - React Native (Mobile).docx`, `drive_raw/Documents/Requirements/WingYip - Menu list.xlsx`, and `drive_raw/Documents/Requirements/Requirements shared with Client/` (User Stories).

---

## Platform Architecture

The SRS has two distinct frontend platforms, each serving different user contexts:

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND PLATFORMS                         │
│                                                              │
│  ┌────────────────────────┐    ┌────────────────────────┐    │
│  │     WEB PORTAL         │    │   ANDROID HHD APP      │    │
│  │  (React + BFF)         │    │   (React Native)       │    │
│  │                        │    │                          │    │
│  │  • SpaceMan (Planogram)│    │  • Store Walk            │    │
│  │  • Admin Portal        │    │  • Replenishment Picking │    │
│  │  • Replen Dashboard    │    │  • Bulk Replenishment     │    │
│  │  • Product Enquiry     │    │  • SEL Printing           │    │
│  │  • Reporting & Analytics│   │  • Stock Counting / PI    │    │
│  │  • SOCO Dashboard      │    │  • Didi Operations        │    │
│  │  • Finance             │    │  • Product Enquiry        │    │
│  │  • User Management     │    │  • Notifications          │    │
│  │                        │    │                          │    │
│  │  Auth: AD/ADFS         │    │  Auth: Keycloak          │    │
│  │  Form: Desktop/Tablet  │    │  Form: Rugged Handheld   │    │
│  └────────────────────────┘    └────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Web Frontend Architecture

Source: `drive_raw/Documents/Design/Analysis/Frontend_Architecture_WingYip_SRS.docx`

### Technology Stack

| Component | Technology | Notes |
|-----------|-----------|-------|
| **Framework** | React | Production web frontend (per DEPLOYMENT_GUIDE) |
| **Container** | FrontendService in Kubernetes, served via Nginx | — |
| **Backend-for-Frontend** | BFF Pattern | Aggregates data from multiple services |
| **Auth** | AD/ADFS (cookie/JWT) | Windows-integrated auth |
| **State Management** | React Context / Redux | Per module |
| **UI Framework** | Tailwind CSS | Utility-first styling |
| **Charts** | Chart.js / D3.js | Operational dashboards |
| **Real-Time** | WebSocket WebSocket client | Live updates |
| **API Communication** | REST via BFF | Aggregated data endpoints |

### Module Scope (Web)

Source: `drive_raw/Documents/Requirements/WingYip - Menu list.xlsx`

| Module | Platform | Key Features |
|--------|----------|-------------|
| SpaceMan (Planogram) | Web | Store layout design, bay groups, 7-stage planogram workflow |
| Admin Portal | Web | User management, store configuration, system settings |
| Replenishment Dashboard | Web | Real-time replenishment monitoring, group status |
| Product Enquiry | Web + Mobile | Product search, status identification, audit tracking |
| SOCO Dashboard | Web | Stock ordering coordination, replenishment oversight |
| Finance | Web | Customer-type reports, SAP integration |
| Reporting & Analytics | Web | Power BI dashboards, SSRS operational reports |
| Didi Admin Configuration | Web | Remote store configuration |

### Web Architecture Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Documents/Design/Analysis/Frontend_Architecture_WingYip_SRS.docx` | Full frontend architecture specification |
| `drive_raw/Documents/Design/Analysis/Back End Technical Design Document.docx` | Backend technical design supporting frontend |

---

## Mobile (HHD) Architecture

Source: `drive_raw/Documents/Design/Analysis/HH_Mobile App_Architecture_WingYip_SRS.docx`, `drive_raw/Documents/Design/Analysis/Mobile Application Architecture Document.docx`

### Technology Stack

| Component | Technology | Notes |
|-----------|-----------|-------|
| **Framework** | React Native 0.72.3 (Android) | Primary platform |
| **Alternative** | Flutter | — |
| **Target Devices** | Rugged handheld RF devices (Zebra or equivalent) | — |
| **Connectivity** | Private Wi-Fi within store/warehouse | No cellular/internet |
| **Auth** | Keycloak (Crown ID + PIN; Kerberos SSO planned) | — |
| **Real-Time** | WebSocket React Native client | Task updates, notifications |
| **Distribution** | Private APK via MDM or side-loading | No app store |
| **Barcode Scanner** | Honeywell scanner SDK | Integrated scanning |

### Mobile Module Scope

| Module | Key Workflows |
|--------|-------------|
| **Store Walk** | Walk store, identify low/no stock items, create replenishment tasks |
| **Replenishment Picking** | Select group → Lock → Pick items → Confirm → Release |
| **Bulk Replenishment** | Pallet drop, put-away, Move from Overstock, Move to Pick |
| **SEL Printing** | In-store label generation via Bluetooth printer |
| **Stock Counting (PI)** | Physical inventory counting, variance resolution |
| **Product Enquiry** | Quick product search by barcode/name |
| **Didi Operations** | Emergency orders, daily process, excess stock, SKU diagnostic |
| **Notifications** | WebSocket real-time alerts, task assignment |

### Mobile Architecture Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Documents/Design/Analysis/HH_Mobile App_Architecture_WingYip_SRS.docx` | Mobile app architecture specification (historical) |
| `drive_raw/Documents/Design/Analysis/Mobile Application Architecture Document.docx` | Detailed mobile architecture (historical) |
| `drive_raw/Documents/Design/Analysis/Frontend Low Level Architecture - React Native (Mobile).docx` | React Native mobile LLD |
| `drive_raw/Documents/Design/Administration, Authentication and RBAC/Wing Yip - Handheld Device Authentication Visual Diagram.png` | HHD auth visual flow |

---

## BFF (Backend-for-Frontend) Pattern

Source: [Service Communication](./04-service-communication.md)

The web frontend uses a BFF pattern to aggregate data from multiple microservices into a single JSON response per page:

```
┌──────────────┐      ┌──────────┐
│  Web Portal  │─────▶│   BFF    │─────▶ Product Service
│  (React)     │      │          │─────▶ SpaceMan Service
│              │      │          │─────▶ Stock Service
└──────────────┘      └──────────┘       (3 calls, not 200+)
```

**Caching Strategy**:
| Data Type | Cache? | TTL |
|-----------|--------|-----|
| Product Name, Description | Optional (Redis/in-memory) | 5-15 min |
| Quantity, Location | **NEVER** — always live fetch | N/A |

---

## Platform Differentiation Matrix

| Feature | Web (React) | Mobile (Android HHD) |
|---------|-------------|----------------------|
| **Login Method** | AD credentials | Crown ID + PIN / Keycloak SSO |
| **User Management** | Full CRUD | View-only profile |
| **Planogram/SpaceMan** | Full management | Not available |
| **Store Walk** | Not available | Full operations |
| **Replenishment** | Dashboard, monitoring | Picking, scanning |
| **Product Enquiry** | Full search + edit | Quick barcode search |
| **Shelf Edge Labels** | Configuration, batch printing | In-store printing to mobile printer |
| **Didi Operations** | Admin configuration | Emergency orders |
| **Reports & Analytics** | Full access | Limited/none |
| **Dashboard** | Full visibility | Not available |
| **Messaging** | Read + send | Alerts + notifications |
| **Barcode Scanning** | Not available | Integrated (Honeywell scanner SDK) |
| **Offline Mode** | Not supported | Limited (queued operations) |

---

## Design Principles

### Web Design Principles

1. **Desktop-first** — Optimized for warehouse/store office environments (1920×1080 minimum)
2. **BFF aggregation** — Never make N×M API calls from client; route through BFF
3. **Real-time updates** — WebSocket for live data (replenishment status, planogram progress)
4. **RBAC-driven UI** — Menu visibility and action permissions driven by RBAC engine
5. **Consistent navigation** — Sidebar navigation with module groupings per menu list

### Mobile Design Principles

1. **One-handed operation** — Large touch targets, minimal keyboard input
2. **Barcode-centric** — Scanner-first workflow where applicable
3. **High contrast** — Readable in bright warehouse lighting
4. **Low-latency** — Real-time feedback via WebSocket
5. **Color coding** — Green (good), Amber (low), Red (critical/no stock)
6. **Rugged device optimized** — Zebra TC52/TC72 or equivalent form factor

---

## User Stories (Client-Validated)

Source: `drive_raw/Documents/Requirements/Requirements shared with Client/`

| Document | Scope |
|----------|-------|
| Manage Bay Groups - User Stories v0.1.docx | Bay group management workflows |
| My Profile - User Stories v0.1.docx | User profile flows |
| Product Enquiry - User Stories v0.1.docx | Product search and identification |
| Product Locator - User Stories v0.1.docx | Finding products on store layout |
| Store Layout - User Stories v0.1.docx | Store layout design and management |
| Store Walk - User Stories v0.1.docx | Store walk operations |

---

## Raw Source Documents

| Document | Description |
|----------|-------------|
| `drive_raw/Documents/Design/Analysis/Frontend_Architecture_WingYip_SRS.docx` | Full web frontend architecture |
| `drive_raw/Documents/Design/Analysis/HH_Mobile App_Architecture_WingYip_SRS.docx` | Mobile app architecture |
| `drive_raw/Documents/Design/Analysis/Mobile Application Architecture Document.docx` | Detailed mobile architecture |
| `drive_raw/Documents/Design/Analysis/Frontend Low Level Architecture - React Native (Mobile).docx` | React Native alternative |
| `drive_raw/Documents/Requirements/WingYip - Menu list.xlsx` | Application menu structure |
| `drive_raw/Documents/Design/Administration, Authentication and RBAC/Wing Yip - Handheld Device Authentication Visual Diagram.png` | HHD auth visual diagram |

---

## Cross-References

- [Frontend & Mobile Architecture](./07-frontend-mobile-architecture.md) — Platform split, communication
- [Authentication & RBAC](./06-authentication-rbac.md) — Auth flows per platform
- [Service Communication](./04-service-communication.md) — BFF pattern, API design
- [SEL Printing Detail](./09-sel-printing-detail.md) — Print architecture for web and mobile
- [Functional Modules](../requirements/02-functional-modules.md) — Per-module feature specifications
- [Design - LLDs](../design/01-lld-index.md) — Detailed LLD references