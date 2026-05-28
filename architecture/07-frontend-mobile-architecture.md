# Frontend & Mobile Application Architecture

> Derived from `drive_raw/Documents/Design/Analysis/` LLD documents and BRD v3.1 module scope.

---

## Frontend Architecture (Web)

### Technology
- **Framework**: React 19 + TypeScript
- **Build Tool**: RSBuild (Rspack-based)
- **Container**: FrontendService in Kubernetes uses Nginx
- **Hosting**: Nginx in Kubernetes container, behind HAProxy load balancer
- **Auth**: AD/ADFS-integrated (cookie/JWT)
- **Routing**: React Router v7 (data API with `createBrowserRouter` / `RouterProvider`)
- **Data Fetching**: TanStack Query (React Query)
- **Tables**: AG Grid
- **Styling**: Tailwind CSS
- **Testing**: Jest + React Testing Library
- **Responsive**: Tailored for desktop/tablet in warehouse/store office environments

> **Note**: See `WingYip_SRS_FE_EcoSystem/README.md` on `development` for current stack details.

### Web Application Modules
| Module | Platform | Auth |
|--------|----------|------|
| SpaceMan (Planogram) | Web | AD |
| Admin Portal | Web | AD |
| Replenishment Dashboard | Web | AD |
| Product Enquiry | Web + Mobile | AD / Keycloak |
| Reporting & Analytics | Web | AD |
| Finance | Web | AD |
| SOCO Dashboard | Web | AD |
| User Management | Web | AD |
| Didi Admin Configuration | Web | AD |
| Shelf Edge Label (Web) | Web | AD |

### Web Architecture Documents
| Document | Description |
|----------|-------------|
| Frontend_Architecture_WingYip_SRS.docx | Frontend architecture specification |
| Back End Technical Design Document.docx | Backend technical design |
| Enterprise Stock Replenishment System (SRS) - Technical Architecture Document.docx | Full SRS technical architecture |

---

## Mobile Application Architecture (HHD)

### Technology
- **Framework**: React Native 0.72.3 (Android primary)
- **Navigation**: React Navigation v6
- **Target Devices**: Rugged handheld RF devices (Honeywell/Zebra)
- **Connectivity**: Private Wi-Fi network within store/warehouse
- **Auth**: Keycloak (Crown ID + 6-digit PIN; Kerberos SSO planned)
- **Barcode**: Honeywell scanner SDK (`@angelcat/react-native-honeywell-barcode-scanner`)
- **Storage**: AsyncStorage (offline cache)
- **Testing**: Jest + React Native Testing Library



### Mobile Application Modules
| Module | Platform | Notes |
|--------|----------|-------|
| Store Walk | Mobile | Core HHD workflow |
| Replenishment Picking | Mobile | Pick/scan workflow |
| Bulk Replenishment | Mobile | Warehouse ops |
| Shelf Edge Label Printing | Mobile | In-store label printing |
| Stock Counting / PI | Mobile | Physical inventory |
| Product Enquiry | Mobile | Quick lookups |
| Didi Store Operations | Mobile | Emergency orders |
| Notifications & Alerts | Mobile | Real-time alerts |

### Mobile Architecture Documents
| Document | Description |
|----------|-------------|
| HH_Mobile App_Architecture_WingYip_SRS.docx | Mobile app architecture specification |
| Mobile Application Architecture Document.docx | Detailed mobile architecture |
| Frontend Low Level Architecture - React Native (Mobile).docx | React Native alternative LLD |
| Wing Yip - Handheld Device Authentication Visual Diagram.png | HHD auth flow diagram |

---

## Communication Architecture (Web ↔ Mobile)

```
┌─────────────────────────────────────────────────────────┐
│                    LOAD BALANCER                          │
│                    (HAProxy / F5)                         │
└────────────┬──────────────────────────┬──────────────────┘
             │                          │
    ┌────────▼────────┐        ┌────────▼────────┐
    │   Web Portal    │        │   API Gateway    │
    │  (React Web)    │        │   (BFF Pattern)  │
    └────────┬────────┘        └────────┬────────┘
             │                          │
             │    ┌─────────────────────┤
             │    │                     │
    ┌────────▼─────▼───┐     ┌──────────▼──────────┐
    │  Microservices   │     │   Microservices      │
    │  (REST)          │     │   (REST + WebSocket)   │
    └────────┬─────────┘     └──────────┬───────────┘
             │                          │
             └────────────┬─────────────┘
                          │
               ┌──────────▼──────────┐
               │     SQL Server       │
               │   (Database/Service) │
               └─────────────────────┘

    Additional Channels:
    ┌──────────┐    ┌──────────────┐
    │ RabbitMQ │    │   WebSocket    │
    │ (Async)  │    │ (Real-Time) │
    └──────────┘    └──────────────┘
```

### Communication Patterns
| Pattern | Technology | Use Case |
|---------|-----------|----------|
| Synchronous | REST/HTTP | Service-to-service, CRUD operations |
| Asynchronous | RabbitMQ | Background processing, auditing |
| Real-Time | WebSocket | Task updates on HHD, planogram progress, replenishment status |

---

## Platform Differentiation (Web vs Mobile)

| Feature | Web | Mobile (HHD) |
|---------|-----|--------------|
| Login | AD credentials | Crown ID + PIN / Keycloak SSO |
| User Management | Full CRUD | View-only profile |
| Planogram/SpaceMan | Full management | Not available |
| Store Walk | Not available | Full operations |
| Replenishment | Dashboard, monitoring | Picking, scanning |
| Product Enquiry | Full search + edit | Quick search |
| Shelf Edge Labels | Configuration, batch printing | In-store printing |
| Didi Operations | Admin configuration | Emergency orders |
| Reports & Analytics | Full access | Limited/none |
| Dashboard | Full visibility | Not available |
| Messaging | Read + send | Alerts + notifications |

---

## Real-Time Features (WebSocket)

### Use Cases
- **Replenishment Picking**: Live progress updates to web dashboard
- **Store Walk**: Real-time task creation visible to SOCO dashboard
- **Planogram**: Progress indicators during implementation
- **Alerts**: Instant notification delivery to handhelds
- **Dashboard**: Live KPI updates

### Architecture
- WebSocket endpoint hosted within each microservice (via Core.WebSocket)
- WebSocket transport (primary) with Server-Sent Events fallback
- Private network only — no external WebSocket connections
- Reference: `LLD -Web Socket.docx`

---

## Frontend Deployment

### Web (Kubernetes)
- Containerized in `FrontendService` Docker image
- Deployed via Jenkins → Harbor → ArgoCD pipeline
- Served via IIS/Nginx in container
- NodePort for dev/staging, Ingress for production

### Mobile (Android APK)
- Built and signed APK distributed via private MDM or side-loading
- No app store (private network, no internet)
- Configuration: API endpoint URL, Keycloak realm URL
- Connected to SRS backend services via internal network

---

## Cross-References

- [Technical Architecture](./01-technical-architecture.md) — Tech stack overview
- [Service Communication](./04-service-communication.md) — BFF pattern, API design
- [Authentication & RBAC](./06-authentication-rbac.md) — Auth flows for web + mobile
- [DevOps Deployment](../infrastructure/02-devops-deployment.md) — CI/CD and deployment