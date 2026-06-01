# ADR-022. Flannel CNI for Kubernetes Pod Networking

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS Kubernetes cluster requires a Container Network Interface (CNI) plugin for pod-to-pod communication, service discovery, and network policy enforcement. The choice of CNI affects network performance, observability, and security capabilities.

**Current implementation:**
- **Flannel CNI** installed via Ansible playbook (`ansible/roles/k8s-master/tasks/main.yml`)
- Flannel deployed via official manifest: `https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml`
- `--pod-network-cidr` configured during `kubeadm init`
- Some internal documentation references Calico (outdated notes in `SharedResources/notes/`)

**Alternatives considered:**
- **Calico**: Provides network policies, BGP routing, and advanced observability
- **Cilium**: eBPF-based, provides service mesh features and network policies
- **Flannel**: Simple, lightweight overlay networking

## Decision

We use **Flannel CNI** for Kubernetes pod networking:

1. **Overlay network**: Flannel provides VXLAN-based overlay networking across all nodes
2. **No network policies**: Flannel does not enforce NetworkPolicy resources (documented limitation)
3. **Simple deployment**: Single manifest deployment via Ansible
4. **Calico references are outdated**: Notes mentioning Calico in `SharedResources/` are historical and not current state

## Consequences

**Positive:**
- Lightweight and easy to deploy (single manifest)
- Low resource overhead
- Sufficient for current cluster scale
- Well-documented and stable

**Negative:**
- **No NetworkPolicy support**: Cannot enforce pod-level network segmentation (all pods can communicate freely)
- **No advanced observability**: No eBPF-based flow visibility or network metrics
- **BGP routing not available**: All traffic goes through overlay (VXLAN), potentially lower performance than direct routing
- **Security gap**: Without NetworkPolicies, compromised pod has unrestricted lateral movement

**Future constraints:**
- If pod-level network segmentation becomes required, migration to Calico or Cilium is necessary
- Flannel cannot be easily upgraded to support network policies — requires CNI replacement
- Any service mesh evaluation (Istio, Linkerd) requires CNI with network policy support

## Related ADRs

- ADR-004: On-premise Kubernetes (mentions network complexity)
- ADR-008: NodePort exposure (no network policies to restrict traffic)
