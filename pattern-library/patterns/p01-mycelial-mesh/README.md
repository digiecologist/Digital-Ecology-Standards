# P01 Mycelial Mesh

**Category:** Structural / Architectural | **Build priority:** BUILD FIRST | **Complexity:** Medium
**AC score contribution:** Technical AC (T-AC)

---

## 1. What this pattern is

In a forest, fungi thread through soil connecting trees that have no direct contact with each other. Signals move through a shared medium, and the ecosystem responds, without any tree calling another tree.

The Mycelial Mesh applies that structure to software. Service A does not call Service B. Instead it publishes an event into a shared communication layer. Service B receives it and responds in its own time. The services do not know each other. They only know the mesh.

---

## 2. The value it brings

- Teams deploy independently, no cross-boundary coordination required
- Failures stay contained, one slow service does not drag down its callers
- New consumers attach without any upstream service changing
- Integration contracts become explicit and visible

---

## 3. The problem it solves

You know you need this pattern when post-mortems contain "cascading failure", or when you cannot deploy one service without coordinating with two other teams.

The core problem is synchronous coupling. When services call each other directly and wait, they inherit each other's failures, latency, and deployment constraints.

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| Event-Driven Architecture | Parent concept — Mycelial Mesh is an opinionated implementation with health properties |
| Publish-Subscribe | Core mechanical pattern — Mycelial Mesh adds schema governance and fitness functions |
| Strangler Fig | Often used together — Strangler Fig migrates to the mesh; this pattern defines what you are migrating toward |

---

## 5. What needs to happen

1. Identify your highest-coupling service, the one most other services call synchronously
2. Choose an event streaming platform (Kafka, AWS EventBridge, Azure Service Bus, RabbitMQ)
3. Introduce a schema registry (Confluent, AWS Glue, or the Git-based registry in this standards kit)
4. Convert the first synchronous call to an event
5. Add the coupling guard fitness function to CI/CD (see [fitness-functions/](fitness-functions/))
6. Add a dead letter queue
7. Extend to the next highest-coupling service

---

## 6. Antipatterns

See [AP-01: Mycelial Mesh antipatterns](../../antipatterns/ap-01-mycelial-mesh.md). The most common: converting sync calls to events but keeping the consumer synchronously waiting for the response event. Sync coupling in async clothing.

> **Sign:** end-to-end latency does not improve after introducing the mesh.

---

## 7. Architecture diagram

```
                ┌─────────────────────────┐
                │     SCHEMA REGISTRY      │
                └──────────────┬──────────┘
                               │
Service A ──► [order.placed] ──┼──► Service B (inventory)
                               ├──► Service C (notifications)
                               └──► Service D (fraud)
                ┌─────────────────────────┐
                │    DEAD LETTER QUEUE     │
                └─────────────────────────┘
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P02 Keystone Interface | Identify critical integration points before building the mesh |
| P07 Nutrient Flow | Schema governance layer — implement within weeks of P01 |
| P09 Carrying Capacity Monitors | Early warning system for mesh health |
| P11 Cascade Risk Detectors | Detects when the mesh has been bypassed |

---

## 9. Code snippet

```javascript
// Producer — publish and move on, no waiting
async function placeOrder(order) {
  await db.save(order);
  await eventBus.publish('order.placed', {
    orderId: order.id,
    customerId: order.customerId,
    timestamp: new Date().toISOString()
  });
  return { orderId: order.id, status: 'accepted' };
}

// Consumer — subscribe and respond independently
eventBus.subscribe('order.placed', async (event) => {
  await inventory.reserve(event.orderId, event.items);
});
```

---

## 10. Deployable code patterns

See [code-examples/](code-examples/) for basic and production-ready implementations.

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Synchronous coupling score | < 30% | Service mesh / trace data |
| Flow concentration | Top 3 event types < 60% of traffic | Event platform metrics |
| Schema compliance | 0 undeclared schemas | Schema registry audit |
| DLQ depth | < 1% of events | Queue depth monitoring |

Fitness functions in [fitness-functions/](fitness-functions/).

---

## 12. What to look out for

The 30% coupling threshold is a starting point — run it against your current system before enforcing. Event ordering is not guaranteed by default in async systems: design for this explicitly. Add P03 Symbiotic Contracts before your schema count grows beyond five types.
