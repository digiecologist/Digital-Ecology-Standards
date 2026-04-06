# P02 Keystone Interface

**Category:** Structural / Architectural | **Build priority:** BUILD FIRST | **Complexity:** Low
**AC score contribution:** Technical AC (T-AC)

---

## 1. What this pattern is

In an ecosystem, a keystone species is one whose removal causes the entire system to collapse, not because it is the largest, but because everything depends on it in ways that are not obvious until it is gone.

Every software system has keystone interfaces: integration points that multiple services depend on, where a change cascades outward and a failure spreads fast. This pattern is the practice of identifying these points explicitly, and protecting them with higher standards of stability, observability, and governance.

Most systems do not know where their keystones are until one breaks.

---

## 2. The value it brings

- Integration failures are contained, the interface is designed to absorb change
- Consumer teams build with confidence, a declared, versioned keystone is a promise
- Incidents are smaller — failure modes are known and recovery is faster
- Architecture decisions improve — knowing your keystones changes how you think about risk

---

## 3. The problem it solves

You know you need this pattern when one service going down takes several others with it, or when schema changes in a shared interface cause surprise failures in consuming teams.

The problem is unmanaged dependency concentration. Some interfaces carry more weight than others. When this is unacknowledged, those interfaces get no special treatment — they are changed freely, have no enhanced SLAs, and nobody is explicitly responsible for their stability.

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| Anti-Corruption Layer (DDD) | ACL protects consumers from upstream changes, Keystone Interface identifies which upstreams need it most |
| Circuit Breaker | Runtime protection for keystone dependencies, this pattern is the design-time identification |
| Consumer-Driven Contract Testing | Testing practice that enforces Keystone Interface commitments in CI |

**The gap:** existing patterns provide protection mechanisms but not a systematic method for identifying which interfaces need protecting first.

---

## 5. What needs to happen

1. Map your dependency graph, list every service-to-service dependency using trace data or service mesh
2. Identify keystones, any service with > 3 upstream dependents is a candidate
3. Declare them explicitly, create an `INTERFACES.md` in each keystone service listing consumers, schema version, SLA, owner, and rollback procedure
4. Add enhanced observability, per-consumer metrics, not just aggregate
5. Introduce consumer-driven contract tests, each consumer declares what they depend on; producer runs these on every deploy
6. Apply the Responsibilities fitness function, flag when fan-in exceeds 8

---

## 6. Antipatterns

Most common: identifying keystones but not treating them differently. The audit happens, the list is made, and then nothing changes operationally.

> **Sign:** a post-mortem identifies a service on the keystone list as the failure origin via a routine undeclared schema change.

---

## 7. Architecture diagram

```
         ┌──────────────────────────────────────┐
         │   CONSUMER CONTRACT TEST REGISTRY     │
         └──────────────────┬───────────────────┘
                            │ validated on deploy
         ┌──────────────────▼───────────────────┐
         │         KEYSTONE INTERFACE            │
         │  SLA: 99.9% │ Schema: v2 │ Owner: platform-team │
         └──────┬───────┬──────┬───────┬────────┘
                │       │      │       │
           Svc A   Svc B   Svc C   Svc D
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P01 Mycelial Mesh | Reduces the number of keystones needed by reducing sync dependencies |
| P03 Symbiotic Contracts | Schema governance for keystone interfaces |
| P09 Carrying Capacity Monitors | Enhanced observability keystones require |
| P11 Cascade Risk Detectors | Identifies when a keystone is under stress |

---

## 9. Code snippet

```javascript
// Consumer-driven contract test (Pact)
const provider = new Pact({
  consumer: 'inventory-service',
  provider: 'order-service',
});

// Consumer declares exactly what they depend on.
// Producer runs this test on every deploy.
// A breaking change fails the producer's build before deployment.
await provider.addInteraction({
  uponReceiving: 'a request for order details',
  withRequest: { method: 'GET', path: '/orders/123' },
  willRespondWith: {
    status: 200,
    body: {
      orderId: like('string'),
      amount: like(0),
      status: term({ generate: 'placed', matcher: 'placed|confirmed|shipped' })
    }
  }
});
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Consumer contract test coverage | 100% of declared consumers | Contract test registry |
| Undeclared consumers | 0 | Trace data vs contract registry |
| Fan-in count | < 8 dependents | Service mesh |
| Schema break incidents | 0 | Incident post-mortem tags |

---

## 12. What to look out for

The Responsibilities SCARS check (fan-in > 8) surfaces undeclared keystones — run it before assuming your list is complete. As consumer count grows above 8, consider whether the interface should be split (P05) or consumers redirected to the mesh (P01).
