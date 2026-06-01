# ADR-028. React Query Default Configuration

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS web frontend uses React Query (TanStack Query v5) for server-state management across 13 feature modules. Default query behavior affects performance, user experience, and data freshness. A consistent configuration strategy is required.

**Current implementation:**
- `QueryClient` created in `src/app/providers/query-provider.tsx` with global defaults:
  ```typescript
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60,        // 1 minute
      gcTime: 1000 * 60 * 5,       // 5 minutes
      retry: 1,                    // 1 retry on failure
      refetchOnWindowFocus: false, // no background refetch on window focus
    },
  }
  ```
- `ReactQueryDevtools` included in production builds (currently enabled)
- No per-feature query overrides documented

## Decision

We adopt a **conservative React Query configuration**:

1. **staleTime: 60 seconds**: Data considered fresh for 1 minute before background refetch
2. **gcTime: 300 seconds**: Inactive query cache kept for 5 minutes before garbage collection
3. **retry: 1**: Single retry on failure (no exponential backoff configured)
4. **refetchOnWindowFocus: false**: No automatic background refetch when user returns to tab
5. **Devtools enabled**: React Query Devtools active in all environments

## Consequences

**Positive:**
- Reduced network traffic compared to aggressive refetching
- 1-minute staleTime balances freshness with cache efficiency
- No jarring UI updates when user switches back to tab

**Negative:**
- **refetchOnWindowFocus: false**: Data may be stale when user returns after extended absence (mitigated by 1-minute staleTime but no proactive refresh)
- **retry: 1 with no backoff**: Transient network failures get exactly one immediate retry — no exponential backoff for flaky connections
- **Devtools in production**: React Query Devtools should be disabled in production builds (performance and security concern)
- **No per-query optimization**: Some queries (product catalog) could tolerate longer staleTime; others (inventory) need shorter
- **No mutation invalidation strategy**: No documented pattern for invalidating queries after mutations

**Future constraints:**
- Evaluate `refetchOnWindowFocus: true` for critical data (inventory, stock levels)
- Remove ReactQueryDevtools from production builds
- Add exponential backoff to retry configuration
- Document per-feature query override patterns

## Related ADRs

- ADR-016: Frontend state management (Zustand + React Query architecture)
- ADR-017: Feature-based modules (each feature defines its own queries)
