# Service Communication Patterns

---

## Communication Model

The system uses a **hybrid communication model**:

| Pattern | Technology | Use Case |
|---------|-----------|----------|
| Synchronous | HTTP/REST | Real-time service-to-service requests |
| Asynchronous | RabbitMQ | Background processing, auditing, data sync |
| Real-Time | WebSocket | Live task updates (HHD), planogram progress |

---

## Aggregation Pattern: BFF + Batch API/TVP

### Problem
Displaying aggregated product data (Product + Location + Stock) for ~100 products per page. Without optimization: 100 × 2 = 200+ requests (high latency).

### Solution: Backend-for-Frontend (BFF)
```
Frontend → HAProxy → BFF
                       ├── Product Service   (Get list + cache static fields)
                       ├── SpaceMan Service  (Batch request: all Product IDs)
                       └── Stock Service     (Batch request: all Product IDs)
                                    ↓
                        Aggregate → Single JSON response
```

**Only 3 network calls** for 100 products instead of 200+.

### Caching Strategy
| Data Type | Cache? | TTL |
|-----------|--------|-----|
| Product Name, Description | Optional (Redis/in-memory) | 5-15 min |
| Quantity, Location | **NEVER** — always live fetch | N/A |

---

## Batch API / Table-Valued Parameter (TVP)

Two approaches for batch queries:

### JSON Payload
```
POST /api/spacelocation/batch
{ "productIds": [101, 102, 103] }
```
- Simple, works with any database
- Best for small-medium datasets

### SQL Table-Valued Parameter (TVP)
- Pass structured table of IDs directly to SQL Server
- Highly efficient for large datasets
- Requires predefined table type + stored procedure

### Recommended: JSON → TVP Conversion
- Accept JSON from API for flexibility
- Convert to TVP internally before DB query
- Simple integration + high performance

---

## Approach Comparison

| Approach | Network Calls | Latency | Complexity | Real-Time |
|----------|-------------|---------|------------|-----------|
| Client-Side Aggregation | N×M (High) | High | Low | ✅ |
| **BFF + Batch API/TVP** | **3** | **Low** | **Medium** | ✅ |
| GraphQL Aggregation | Moderate | Moderate | Medium | ✅ |
| Event-Driven / Precomputed | 1 | Very Low | High | ❌ (eventual) |
| Direct DB Joins / SP | Low | Low | Low | ✅ (breaks isolation) |

**Selected: BFF + Batch API/TVP** — best balance of performance, isolation, and real-time support.
