# ADR-049. API Gateway Pattern and Kubernetes Networking

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform makes three interconnected networking decisions for routing infrastructure and API traffic in the on-premise Kubernetes cluster.

**Dual HAProxy Architecture:**
- **Custom HAProxy** runs on `k8s-node1` with `hostNetwork: true` on port 30080, handling infrastructure services (Keycloak, RabbitMQ management, Kibana, etc.)
- **HAProxy Ingress Controller** runs as a Kubernetes deployment, exposing ports 30880 (HTTP) and 30883 (HTTPS) for API service routing
- This creates two separate HAProxy instances with different configuration models, operational patterns, and update procedures

**MetalLB Load Balancer:**
- Single `/32` IP pool (`10.10.80.77/32`) configured in `L2Advertisement` mode
- Provides a single external IP for all ingress traffic
- L2 mode uses ARP/NDP for node announcement, which limits failover to same-subnet scenarios

**API Gateway Path Rewriting:**
- HAProxy Ingress uses prefix-based path rewriting to route requests to backend services
- Environment-specific routing strategies: dev uses **subdomain-based routing** (`administration-dev.wingyip.inapp.com`), QA uses **path-based rewriting** (`http-request replace-path`), production uses `/api/service-name/` prefix
- Production configuration adds security headers (HSTS, X-Frame-Options, etc.) that dev does not
- Hybrid routing model (subdomain + path-based) increases deployment complexity and testing burden

**Key concerns:**
- Two HAProxy instances double the operational maintenance surface
- Single `/32` IP limits horizontal scalability and creates a single point of failure
- Environment-specific routing creates configuration drift between dev and production
- No TLS termination at the gateway level (TLS handled by services or skipped entirely)

## Decision

We use **dual HAProxy architecture with MetalLB single-IP load balancing and environment-specific API gateway routing**:

1. **Custom HAProxy** on `k8s-node1` (hostNetwork, port 30080) routes infrastructure services
2. **HAProxy Ingress Controller** (ports 30880/30883) routes API service traffic with path-based rewriting
3. **MetalLB** provides a single external IP (`10.10.80.77`) via L2 advertisement
4. **Environment-specific routing**: dev uses subdomain-based routing, QA uses path rewriting, production uses `/api/service-name/` prefix

## Consequences

**Positive:**
- Separation of infrastructure traffic (Keycloak, RabbitMQ, Kibana) from API traffic
- HAProxy is a well-understood, battle-tested reverse proxy with extensive documentation
- MetalLB provides bare-metal load balancing without requiring a cloud provider
- Path-based routing allows multiple services behind a single IP

**Negative:**
- **Two HAProxy instances**: Different configuration models (custom config vs. Ingress annotations) require separate operational expertise and maintenance
- **Single IP scalability**: The `/32` MetalLB pool provides one external IP, limiting horizontal scaling and creating a single point of failure for all ingress traffic
- **Environment-specific routing**: Dev (`/auth-service/`) vs. production (`/api/auth/`) path prefixes create configuration drift and increase testing burden
- **No TLS termination at gateway**: TLS is not terminated at HAProxy, meaning services must handle their own TLS or run without encryption
- **hostNetwork exposure**: Custom HAProxy uses `hostNetwork: true`, bypassing Kubernetes network policies and pod security constraints

**Future constraints:**
- Consider consolidating to a single HAProxy instance (Ingress Controller) for both infrastructure and API traffic to reduce operational complexity
- Expand MetalLB IP pool beyond a single `/32` to support horizontal scaling and reduce single-point-of-failure risk
- Standardize path rewriting across environments to eliminate dev/production configuration drift
- Implement TLS termination at the gateway level to enforce encryption and simplify service-side configuration
- Evaluate Kubernetes Gateway API as a long-term replacement for HAProxy Ingress annotations

---

## References

- `haproxy-deployment.yaml` — Custom HAProxy deployment on k8s-node1
- `haproxy-ingress-service.yaml` — HAProxy Ingress Controller service configuration
- `metallb-config.yaml` — MetalLB IP pool and L2 advertisement configuration
- `api-gateway-*.yaml` — HAProxy Ingress routing and path rewriting rules
- ADR-004 (On-Premise Kubernetes) — Infrastructure foundation
- ADR-008 (NodePort Exposure) — Service exposure strategy