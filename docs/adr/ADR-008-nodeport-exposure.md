# ADR-008. NodePort Service Exposure Pattern

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS Infrastructure repository exposes Kubernetes services via **NodePort** across multiple environments. Audit of the Ansible roles reveals approximately **29 NodePort declarations** across 10 infrastructure components (monitoring, Elasticsearch, Jaeger, RabbitMQ, ArgoCD, Vault, Harbor, Jenkins, Kafka, and inventory configuration).

**Critical Finding**: The TWO_DC design document explicitly identifies NodePort-heavy exposure as **architectural debt**. NodePorts bypass ingress controller controls (TLS termination, WAF rules, rate limiting, path-based routing) and expose services directly on host ports, expanding the attack surface.

Current state:
- **Development/QA/Staging**: NodePorts actively used for service access
- **Production**: Planned to use ingress-only, but NodePort declarations exist in production overlays
- **Impact**: ~85 NodePorts across all environments (estimated from role definitions)

## Decision

We explicitly accept the current NodePort pattern with phased remediation:

1. **Current State (Accepted with Constraints)**: NodePort exposure is permitted for:
   - Internal infrastructure services (monitoring, logging, tracing stacks)
   - Non-production environments (dev, QA, staging)
   - Services that do not handle sensitive business data
2. **Prohibited Use**: NodePort must NOT be used for:
   - Application microservices (all 16 services must use ingress)
   - Services handling PII, payment data, or authentication tokens
   - Production environments for any business-facing service
3. **Remediation Path**:
   - Phase 1 (Immediate): Document all NodePorts with security classification
   - Phase 2 (Next Sprint): Migrate application services to ClusterIP + Ingress
   - Phase 3 (Next Quarter): Migrate internal infrastructure to Ingress or internal load balancer
   - Phase 4 (Future): Evaluate service mesh (Istio/Linkerd) for zero-trust internal communication

## Consequences

**Positive:**
- NodePort provides simple direct access for debugging and internal tooling
- No ingress controller configuration needed for infrastructure services
- Transparent documentation of attack surface and remediation plan

**Negative:**
- **Security risk**: NodePorts bypass ingress security controls (TLS, authentication, WAF)
- Direct host port exposure increases lateral movement risk if a node is compromised
- No centralized traffic logging or rate limiting for NodePort services
- Operational confusion — team must know which services are NodePort vs Ingress
- Compliance risk (PCI-DSS, SOC 2) if sensitive services are exposed via NodePort

**Future constraints:**
- Any new service must default to ClusterIP + Ingress, not NodePort
- NodePort use requires explicit security review and ADR amendment
- Production environment must achieve 100% ingress-based exposure before compliance audit
- Service mesh adoption would supersede this ADR entirely

## Remediation ADR Required

A follow-up ADR should be created:
- **ADR-00X: Ingress-Only Service Exposure** — covering migration timeline, ingress controller capacity planning, and internal load balancer strategy
