# Test Traceability Matrix

> Maps test artifacts to requirements, modules, and data pipelines for comprehensive coverage verification.

---

## Test Artifacts by Module

| Module | Test Scenarios | QA Release Notes | Workflow Docs | Playback Tests | Data Flow Tests |
|--------|---------------|-----------------|---------------|----------------|-----------------|
| User Management & RBAC | — | — | — | — | — |
| Store Layout & Planogram | — | Phase 1 UAT2 | — | — | — |
| Warehouse Layout | — | — | — | — | — |
| Product Enquiry | — | — | — | — | — |
| Store Operations (Store Walk) | Main test scenarios | Phase 1 UAT2 | Replenishment Work Flow.docx | — | — |
| Core Replenishment | Main + Data Issues scenarios | Phase 1 UAT2 | Sales Based Replenishment Workflow.docx, Replenishment Picking Workflow.docx | Sales Replen Scenarios.xlsx | Data Flow Testing |
| Bulk Replenishment | — | Phase 1 UAT2 | Bulk Replenishment Work Flow.docx | — | Data Flow Testing |
| Didi Store | — | — | Didi Stores Replenishment Workflow.docx | — | — |
| Fresh Goods | — | — | Fresh Good Replenishment Workflow.docx | Fresh_Goods_Test_Scenarios.xlsx | — |
| Stock Control & Discrepancy | — | — | — | — | — |
| SOCO | — | — | — | — | — |
| Shelf Edge Label Printing | — | Phase 1 UAT2 | — | — | — |
| Admin Configuration | — | — | — | — | — |
| Messaging & Notifications | — | — | — | — | — |
| Finance | — | — | — | — | — |
| Reporting & Analytics | — | — | — | — | — |

---

## Test Document Inventory

### Main Test Scenarios
| Document | Description | Coverage |
|----------|-------------|----------|
| Wing Yip - Test Scenarios_.xlsx | Comprehensive test scenarios | All modules |
| Wing Yip - Test Scenarios_(1).xlsx | Additional test scenarios (v2) | All modules |
| SRS_Test_Scenarios_1905.xlsx | SRS test scenarios (19-May) | Core replenishment focus |

### QA Release Notes
| Document | Phase | Description |
|----------|-------|-------------|
| QA Release Note_.xlsx | Phase 1 | General QA release notes |
| Phase1 UAT2_QA Release Note_.xlsx | Phase 1 UAT2 | UAT2 specific release notes |

### QA Progress
| Document | Description |
|----------|-------------|
| Wing YipQA Progress and Estimation.xlsx | QA progress tracking and effort estimation |

### Code Review
| Document | Description |
|----------|-------------|
| Code Review_.xlsx | Code review tracker — review status per module/developer |

### Inter-Module Dependencies
| Document | Description |
|----------|-------------|
| Wing Yip - Inter Connection between Modules.docx | Maps dependencies between SRS modules |
| Legacy - SRS Table Relation.xlsx | Legacy database table relationships |

---

## Workflow Documentation (Operational Process Tests)

| Workflow Document | Module | Process Covered |
|-------------------|--------|-----------------|
| Replenishment Work Flow.docx | Core Replenishment | General replenishment flow |
| Sales Based Replenishment Workflow.docx | Core Replenishment | 15-min sales cycle |
| Replenishment Picking Workflow.docx | Core Replenishment | Picking and scan workflow |
| Bulk Replenishment Work Flow.docx | Bulk Replenishment | Pallet drop, put-away |
| Didi Stores Replenishment Workflow.docx | Didi Store | Didi-specific replenishment |
| Fresh Good Replenishment Workflow.docx | Fresh Goods | Perishable handling |
| Copilot Documentation on Sales Processing.docx | Sales | AI-generated sales process docs |

---

## Service-Layer Test References

### Application Layer (HTML)
| Document | Service | Description |
|----------|---------|-------------|
| CaseReplenActions_INSERT_UPDATE_Locations.html | Replenishment | Case replen location operations |
| CumulativeSales_Modifications_Report.html | Replenishment | Cumulative sales modifications |
| ShelfReplenPicking_Modifications_Report.html | Replenishment | Shelf replen picking modifications |

### Service Layer (HTML/DOCX)
| Document | Service | Description |
|----------|---------|-------------|
| CaseReplenActions_Operations.html | Replenishment | Case replen service operations |
| CumulativeSales_Operations.html | Replenishment | Cumulative sales operations |
| ShelfReplenPicking_Operations.html | Replenishment | Shelf replen picking operations |
| Complete_SRS_Workflow.docx/.html | System-wide | End-to-end workflow |
| SRS_Complete_Workflow.docx | System-wide | Complete workflow documentation |

---

## Data Flow Test Scenarios

| Document | Description |
|----------|-------------|
| Data Flow Testing - Scenarios & Reported Items.xlsx | E2E data flow test scenarios and reported issues |

---

## Issue Tracking

| Document | Module | Description |
|----------|--------|-------------|
| Replenishment Issue tracker.xlsx | Replenishment | Replenishment-specific issues |
| Pending work Items.xlsx | All | Pending work items log |

---

## Cross-References

- [Test Scenarios](./01-test-scenarios.md) — Full test artifact inventory
- [Workflow Docs](./02-workflow-docs.md) — Process flow documentation
- [Functional Modules](../requirements/02-functional-modules.md) — Requirements per module
- [LLD Index](../design/01-lld-index.md) — Design specs that tests should verify