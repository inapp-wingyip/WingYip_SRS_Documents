# Testing Strategy & Agent Guide

> This document provides a cross-repo testing strategy with per-repo test commands, data setup, and QA gates. Derived from `drive_raw/Documents/Testing/`, `drive_raw/Documents/Data Issues/`, and `WingYip_SRS_BE_EcoSystem/docs/`.

---

## Testing Approach

### Test Pyramid

| Level | Scope | Tools | Run By |
|-------|-------|-------|--------|
| **Unit Tests** | Single handler/service | xUnit + Moq | Developer (CI) |
| **Integration Tests** | Service-to-DB, service-to-service | xUnit + TestContainers / SQL LocalDB | Developer (CI) |
| **Contract Tests** | API endpoints, event schemas | xUnit + WebApplicationFactory | Developer (CI) |
| **E2E Tests** | Full workflow across services | Custom test harness | QA (CD) |
| **UAT** | Business validation by stakeholders | Manual test scenarios | Business users |

### Source Test Artifacts

| Source | Description |
|--------|-------------|
| `drive_raw/Documents/Testing/Wing Yip - Test Scenarios_.xlsx` | Master test scenarios |
| `drive_raw/Documents/Testing/Wing Yip - Test Scenarios_(1).xlsx` | Test scenarios v2 |
| `drive_raw/Documents/Testing/QA Release Note _.xlsx` | QA release notes |
| `drive_raw/Documents/Testing/Phase1 UAT2_QA Release Note _.xlsx` | Phase 1 UAT2 release |
| `drive_raw/Documents/Testing/Wing YipQA Progress and Estimation.xlsx` | QA progress tracking |
| `drive_raw/Documents/Testing/Code Review_.xlsx` | Code review tracker |
| `drive_raw/Documents/Testing/Wing Yip - Inter Connection between Modules.docx` | Module interconnection test reference |
| `drive_raw/Documents/Data Issues/Data Flow Testing - Scenarios & Reported Items.xlsx` | E2E data flow test scenarios |
| `drive_raw/Documents/Data Issues/SRS_Test_Scenarios_1905.xlsx` | SRS test scenarios (May iteration) |
| `drive_raw/Documents/Data Issues/Test Scenarios for Playback sessions/` | Playback test scenarios |

---

## Per-Repository Testing

### BE_EcoSystem (Backend Microservices)

**Test Framework**: xUnit + Moq + FluentAssertions

**Run Commands** (from repo root):
```bash
# Run all tests
dotnet test

# Run specific service tests
dotnet test WingYip.SRS.Replenishment.Tests/
dotnet test WingYip.SRS.Administration.Tests/

# Run with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run integration tests (requires SQL Server)
dotnet test --filter "FullyQualifiedName~Integration"
```

**Test Data**: Use `drive_raw/Sql-Scripts-Data-Generation/SalesTransaction_Generate` for sales transaction test data generation.

**Internal Test Docs**: `docs/HouseKeeping_implementation_documentation.md` includes HouseKeeping CRUD tests examples.

### FE_EcoSystem (Frontend Web)

**Test Framework**: Jest + React Testing Library

```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run E2E (Playwright)
npx playwright test
```

### HH_EcoSystem (Android Handheld)

**Test Framework**: JUnit + Espresso

```bash
# Run unit tests
./gradlew test

# Run instrumented tests
./gradlew connectedAndroidTest
```

### DE_EcoSystem (Data Engineering)

**Test Framework**: SSDT unit tests + SSIS package validation

- Validate pipeline execution order and dependencies
- Row count reconciliation between source and target
- Data quality checks at Bronze, Silver, Gold layers

### Infrastructure (K8s/DevOps)

**Test Framework**: Helm test + K8s health checks

```bash
# Validate deployment
helm test srs-infra

# Health check endpoints
curl http://srs-admin:8080/health/ready
curl http://srs-product:8080/health/ready
```

---

## QA Gates & Acceptance Criteria

### Phase Testing Gates

Source: `drive_raw/Documents/Project-Management/SRS Phase1_Revised Schedule and Scope.xlsx`, `drive_raw/Documents/Testing/Phase1 UAT2_QA Release Note _.xlsx`

| Gate | Criteria | Sign-off |
|------|----------|----------|
| **Unit Tests Pass** | 100% of CI tests green | Automated |
| **Integration Tests Pass** | All service integration tests green | Automated |
| **Code Review** | Peer review completed per `Code Review_.xlsx` | Tech Lead |
| **UAT Sign-off** | Business scenarios passed per test scenarios | Business Stakeholder |
| **Performance** | p95 response time < 5s; error rate < 5% | QA Lead |
| **Security Review** | No critical/high findings | Security Lead |

### Release Criteria

- All phases above passed
- No P0/P1 bugs open
- Deployment checklist completed: `drive_raw/Documents/Deployment/WingYip Production Deployment Checklist.xlsx`
- Rollback plan documented

---

## Test Data Strategy

### Data Generation

| Approach | Source |
|----------|--------|
| **Sales Transactions** | `drive_raw/Sql-Scripts-Data-Generation/SalesTransaction_Generate` |
| **Master Data** | `drive_raw/Documents/Design/Master Data.xlsx` |
| **Store Layouts** | `drive_raw/Documents/Design/StoreLayout & Bay Group/Store Layouts.xlsx` |
| **Didi Store Layout** | `drive_raw/Documents/Design/StoreLayout & Bay Group/DIDI - Store Layouts - Watford.xlsx` |

### Non-Production Data Masking

- PII (CrownId, email, phone) MUST be anonymized in non-prod
- Financial data MUST be scrambled
- Product/stock data can use production-like synthetic data

---

## Test Traceability

Source: [Test Traceability Matrix](../testing/03-test-traceability-matrix.md)

Each test scenario MUST map to:
1. **Requirement** (BRD/FRD reference)
2. **LLD** (Low-level design section)
3. **Module** (SRS module)
4. **Priority** (Critical/High/Medium/Low)

---

## Cross-References

- [Test Scenarios](../testing/01-test-scenarios.md) — Test artifacts, QA, data issues
- [Test Traceability Matrix](../testing/03-test-traceability-matrix.md) — Tests → requirements mapping
- [Workflow Docs](../testing/02-workflow-docs.md) — Workflow documentation
- [Coding Standards](../architecture/11-coding-standards.md) — CQRS test patterns
- [Error Handling](../architecture/12-error-logging-observability.md) — Error response formats for contract testing