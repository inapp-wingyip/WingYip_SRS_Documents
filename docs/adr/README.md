# Architecture Decision Records (ADRs)

This directory contains all Architecture Decision Records for the WingYip SRS ecosystem.

## Quick Stats

- **Total ADRs**: 61
- **First ADR**: 2026-05-30
- **Last ADR**: 2026-05-31
- **Status**: All Accepted (awaiting formal review)

## ADR Index

### Foundational Architecture (001-005)

| ADR | Title | Domain | Priority |
|-----|-------|--------|----------|
| `ADR-001` | Microservices Architecture with .NET 8 | Backend | — |
| [ADR-002](ADR-002-database-per-service.md) | Database-Per-Service with SQL Server | Backend | — |
| `ADR-003` | Keycloak with Active Directory and ADFS | Auth | — |
| `ADR-004` | On-Premise Kubernetes with ArgoCD GitOps | Infrastructure | — |
| [ADR-005](ADR-005-centralized-audit-enrichment.md) | Centralized Audit Enrichment with Outbox | Backend | — |

### Security & Compliance (006-008) — CRITICAL

| ADR | Title | Domain | Risk |
|-----|-------|--------|------|
| `ADR-006` | HashiCorp Vault in Development Mode | Security | Secrets lost on restart |
| `ADR-007` | SSIS `sa` Password in Plaintext | Security | Full sysadmin access from Git |
| `ADR-008` | NodePort Service Exposure Pattern | Security | Bypasses ingress controls |

### Backend Architecture (009-015, 026, 030-031, 044-047, 058-059)

| ADR | Title | Domain |
|-----|-------|--------|
| [ADR-009](ADR-009-raw-rabbitmq-client.md) | Raw RabbitMQ.Client over MassTransit | Messaging |
| `ADR-010` | Dual Messaging (RabbitMQ + Redis Pub/Sub) | Messaging |
| `ADR-011` | Custom WebSocket over SignalR | Real-time |
| `ADR-012` | Background Processing (Quartz + BackgroundService) | Jobs |
| [ADR-013](ADR-013-dual-json-serializer.md) | Dual JSON Serializer | Serialization |
| [ADR-014](ADR-014-no-api-versioning.md) | No API Versioning Strategy | API |
| [ADR-015](ADR-015-missing-observability.md) | Missing Observability | Observability |
| `ADR-026` | Redis Distributed Caching | Caching |
| [ADR-030](ADR-030-global-exception-handling.md) | Global Exception Handling with Mapped HTTP Status | Error Handling |
| [ADR-031](ADR-031-cqrs-mediatr-automapper.md) | CQRS with MediatR and AutoMapper | Architecture |
| [ADR-044](ADR-044-ef-core-as-sole-orm.md) | EF Core 8.0.22 as Sole ORM | Data Access |
| [ADR-045](ADR-045-argon2id-ldap-integration.md) | Argon2id Password Hashing and AD LDAP Integration | Security |
| [ADR-046](ADR-046-api-audit-correlation-id-observability.md) | API Audit and Correlation ID Observability | Observability |
| [ADR-047](ADR-047-questpdf-skiasharp-document-label-generation.md) | QuestPDF and SkiaSharp Document/Label Generation | Documents |
| [ADR-058](ADR-058-per-service-domain-specific-cache-layer.md) | Per-Service Domain-Specific Cache Layer | Caching |
| [ADR-059](ADR-059-inter-service-http-client-pattern.md) | Inter-Service HTTP Client Pattern | Communication |

### Cross-Cutting Concerns (040-043)

| ADR | Title | Domain |
|-----|-------|--------|
| [ADR-040](ADR-040-core-shared-library-monorepo.md) | Core Shared Library Ecosystem and Monorepo Structure | Shared Libraries |
| [ADR-041](ADR-041-nuget-packaging-github-packages.md) | NuGet Packaging Strategy via GitHub Packages | Packaging |
| [ADR-042](ADR-042-permission-rbac-cache-aside.md) | Permission-Based RBAC System with Cache-Aside | Auth |
| [ADR-043](ADR-043-standardized-middleware-pipeline.md) | Standardized Middleware Pipeline and DI Bootstrap | Infrastructure |

### Frontend Architecture (016-018, 028-029, 048, 060)

| ADR | Title | Domain |
|-----|-------|--------|
| [ADR-016](ADR-016-frontend-state-management.md) | Frontend State Management (Zustand + React Query) | State |
| [ADR-017](ADR-017-feature-based-modules.md) | Feature-Based Module Architecture | Structure |
| [ADR-018](ADR-018-rsbuild-build-tool.md) | RSBuild as Build Tool | Build |
| `ADR-028` | React Query Default Configuration | Data Fetching |
| [ADR-029](ADR-029-jwt-localstorage-persistence.md) | JWT Token Persistence in localStorage | Security |
| [ADR-048](ADR-048-frontend-api-client-headless-ui-design-system.md) | Frontend API Client Factory and Headless UI Design System | Client/UX |
| [ADR-060](ADR-060-frontend-shared-infrastructure.md) | Frontend Shared Infrastructure | Shared |

### Handheld Architecture (019-020, 057)

| ADR | Title | Domain |
|-----|-------|--------|
| [ADR-019](ADR-019-handheld-state-management.md) | Handheld State Management (Context Only) | State |
| `ADR-020` | React Navigation 6 with Custom Tab Bar | Navigation |
| [ADR-057](ADR-057-handheld-security-hardware-integration.md) | Handheld Security Patterns and Hardware Integration | Security/Hardware |

### Data Engineering (021, 032-039, 056)

| ADR | Title | Domain |
|-----|-------|--------|
| `ADR-021` | SSIS as Pure Orchestrator with SQL Transformations | ETL |
| [ADR-032](ADR-032-bronze-silver-medallion.md) | Bronze/Silver Medallion Architecture | Data Architecture |
| [ADR-033](ADR-033-sql-agent-scheduling.md) | SQL Agent for SSIS Schedule Orchestration | Scheduling |
| [ADR-034](ADR-034-ssis-project-deployment.md) | SSIS Project Deployment Model to SSISDB | Deployment |
| [ADR-035](ADR-035-etl-logging-pattern.md) | ETL Logging Pattern | Observability |
| [ADR-036](ADR-036-ssis-html-email-notifications.md) | HTML Email Notifications from SSIS | Notifications |
| [ADR-037](ADR-037-msdtc-distributed-transactions.md) | MSDTC Distributed Transactions | Transactions |
| [ADR-038](ADR-038-etl-environment-variables.md) | ETL Environment Variables for Configuration | Configuration |
| [ADR-039](ADR-039-source-schema-discovery.md) | Source Schema Discovery via Dynamic SQL | Schema |
| [ADR-056](ADR-056-ssis-security-deployment-patterns.md) | SSIS Security and Deployment Patterns | Security |

### Infrastructure & DevOps (022-025, 049-055, 061)

| ADR | Title | Domain |
|-----|-------|--------|
| `ADR-022` | Flannel CNI for Pod Networking | Networking |
| `ADR-023` | External Secrets Operator with Vault | Secrets |
| [ADR-024](ADR-024-rollingupdate-tcp-probes.md) | RollingUpdate with TCP Socket Probes | Deployment |
| `ADR-025` | Allow-All CORS Policy | Security |
| [ADR-049](ADR-049-api-gateway-kubernetes-networking.md) | API Gateway Pattern and Kubernetes Networking | Networking |
| [ADR-050](ADR-050-jenkins-cicd-pipeline-patterns.md) | Jenkins CI/CD Pipeline Patterns | CI/CD |
| [ADR-051](ADR-051-argocd-gitops-auto-sync-insecure-mode.md) | ArgoCD GitOps Auto-Sync and Insecure Mode | GitOps |
| [ADR-052](ADR-052-monitoring-stack-decisions.md) | Monitoring Stack Decisions | Observability |
| [ADR-053](ADR-053-messaging-infrastructure.md) | Messaging Infrastructure | Messaging |
| [ADR-054](ADR-054-storage-persistence-strategy.md) | Storage and Persistence Strategy | Storage |
| [ADR-055](ADR-055-keycloak-customizations-backup.md) | Keycloak Customizations and Backup | Auth/Backup |
| [ADR-061](ADR-061-two-dc-high-availability-design.md) | Two-DC High Availability Design | HA |

## Critical Security ADRs

The following ADRs document critical security concerns requiring immediate attention:

1. **ADR-006**: Vault in dev mode — secrets lost on restart, no audit trail
2. **ADR-007**: `sa` password in plaintext — full sysadmin access from Git history
3. **ADR-008**: NodePort bypasses ingress — expanded attack surface

## Status

All ADRs are currently marked as `Accepted`. They are living documents and may be superseded by future decisions following the ADR discipline defined in [AI_Native/architecture/adr-discipline.md](../../AI_Native/architecture/adr-discipline.md).
