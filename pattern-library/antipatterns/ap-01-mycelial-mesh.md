# AP-01 — Mycelial Mesh Antipatterns

**Pattern this relates to:** [P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/)
**Category:** Structural / Architectural
**TL;DR:** The mesh becomes a swamp, a command bus, or an async monolith. Services are still tightly coupled — just over a queue instead of a wire.

---

## The five ways this goes wrong

---

### AP-01-A: Event Soup

**What it is:** Hundreds of event types with no coherent taxonomy. Teams publish events whenever they feel like it, in whatever shape seems convenient. Consumers cannot find what they need without reading the source code.

**Sign:** Event topic count grows faster than team count. No event registry or catalogue exists.

**Why it happens:** Event-driven architecture gets adopted at the transport layer without governance. Each team makes local decisions that are individually reasonable but collectively chaotic.

**What it looks like in practice:**
```
Topics in production:
  order.created
  OrderCreated
  orders/new
  new-order-event
  order_placed_v1
  order_placed_v2
  order-placed-confirmed
```
Seven names for the same event, owned by different teams, each with slightly different schemas.

**The fix — P01 applied:** Establish an event registry before the second team publishes their first event. Use a taxonomy: `domain.entity.action` (e.g., `orders.order.created`). One naming convention, enforced in CI.

**Validated reference:** [AsyncAPI](https://www.asyncapi.com/) provides the specification standard for event registries. [Confluent Schema Registry](https://docs.confluent.io/platform/current/schema-registry/index.html) enforces it at the broker level.

**SCARS lens:** Separation — events without taxonomy create hidden coupling between producers and consumers through naming conventions and shape assumptions.

---

### AP-01-B: Commands in Disguise

**What it is:** Events named `ProcessOrder`, `SendEmail`, `UpdateInventory`. These are not events — they are commands dressed in async clothing. The producer is still directing the consumer. True events describe what happened; they do not prescribe what should happen next.

**Sign:** Event names are imperative verbs.

**Why it happens:** Teams move from synchronous RPC to async messaging but carry the request/response mental model with them. The transport changes; the thinking does not.

**What it looks like in practice:**
```javascript
// Command masquerading as an event — wrong
publishEvent('ProcessRefund', { orderId: '123', amount: 50.00 });

// True event — correct  
publishEvent('orders.payment.refund_requested', { 
  orderId: '123', 
  amount: 50.00,
  requestedAt: '2024-01-15T10:30:00Z'
});
```

**The fix — P01 applied:** Events describe facts about the world (`payment.refund_requested`). What any given consumer does with that fact is entirely their business. The producer does not care and does not know.

**Validated reference:** Greg Young's distinction between commands and events in CQRS/Event Sourcing. [Martin Fowler on Event-Driven Architecture](https://martinfowler.com/articles/201701-event-driven.html).

**SCARS lens:** Responsibilities — the producer is taking on responsibility for consumer behaviour by directing it through event naming.

---

### AP-01-C: Shared Topics

**What it is:** Multiple event types on a single topic. Consumers receive everything and filter in application code. The filtering logic becomes a hidden coupling: change the event shape and every consumer's filter breaks silently.

**Sign:** Consumer code contains switch statements on event type.

**Why it happens:** Teams want to reduce the number of topics to manage. The intent is simplicity; the result is hidden complexity moved into consumer code.

**What it looks like in practice:**
```javascript
// Consumer code in this antipattern
consumer.subscribe('orders-events', (message) => {
  switch (message.type) {
    case 'ORDER_CREATED': handleCreated(message); break;
    case 'ORDER_SHIPPED': handleShipped(message); break;
    case 'ORDER_CANCELLED': handleCancelled(message); break;
    // New event types silently ignored
  }
});
```

**The fix — P01 applied:** One topic per event type. The filtering happens at the broker, not in application code. Consumers subscribe to exactly what they need.

**Validated reference:** [Kafka topic design best practices](https://developer.confluent.io/patterns/event-driven/). Team Topologies stream-aligned team model — each team owns its event streams.

**SCARS lens:** Cohesion — a topic that carries multiple event types has low cohesion.

---

### AP-01-D: The Invisible Dead Letter Queue

**What it is:** Events that fail consumer processing disappear. There is no dead letter queue, or there is one but nobody watches it. Failed business operations accumulate silently. The mesh appears healthy; the business is not.

**Sign:** Dead letter queue count is not on any dashboard. No alert exists for it.

**Why it happens:** Dead letter queues are set up as a safety net during implementation and then forgotten. They are operational infrastructure, not business logic, so no team feels responsible for monitoring them.

**The fix — P01 applied:** Every consumer has a dead letter queue. Every dead letter queue has an alert. Every alert has a runbook. This is not optional operational hygiene — it is the mechanism that makes the mesh trustworthy.

**Validated reference:** [AWS SQS Dead Letter Queues](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html). [Azure Service Bus dead-lettering](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dead-letter-queues).

**SCARS lens:** Simplify — invisible failure paths add hidden complexity. Making failure visible simplifies reasoning about system state.

---

### AP-01-E: Async Monolith

**What it is:** All services share a single event broker with no isolation, domain-based topics, or ownership model. The mesh is technically async, but architecturally still a big ball of mud — now with queue lag.

**Sign:** Teams are afraid to change event schemas because they do not know all the consumers.

**Why it happens:** Event-driven adoption without domain boundaries. One broker, no namespacing, no ownership. Every event is effectively public to every team.

**The fix — P01 applied:** Domain-based topic namespacing enforced at the broker level. Topic ownership registered in the event catalogue. Schema changes require an impact assessment — which is trivial when the catalogue is accurate and painful when it is not.

**Validated reference:** Domain-Driven Design bounded context model. [Team Topologies](https://teamtopologies.com/) stream-aligned teams owning their event streams. The Inverse Conway Manoeuvre — structure the event broker to match the team structure you want.

**SCARS lens:** Separation — an async monolith has failed at separation just as completely as a synchronous one.

---

## Fitness functions for these antipatterns

These run in CI and flag the conditions above before they reach production.

```yaml
# .github/workflows/mesh-antipattern-checks.yml
name: Mesh Antipattern Guard

on: [pull_request]

jobs:
  event-taxonomy:
    name: Event naming convention
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check event names follow domain.entity.action convention
        run: node fitness-functions/mesh/check-event-taxonomy.js
        # Fails if any event name is an imperative verb (ProcessX, SendX, UpdateX)
        # Fails if any event name does not match domain.entity.action pattern

  dead-letter-coverage:
    name: Dead letter queue coverage
    runs-on: ubuntu-latest  
    steps:
      - uses: actions/checkout@v3
      - name: Verify all consumers have monitored dead letter queues
        run: node fitness-functions/mesh/check-dlq-coverage.js
        # Fails if any consumer declaration lacks a DLQ configuration
        # Fails if any DLQ lacks an alert threshold

  topic-ownership:
    name: Topic ownership registry
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: All topics must be registered in event catalogue
        run: node fitness-functions/mesh/check-topic-registry.js
        # Fails if any topic in broker config is absent from event-catalogue.yml
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-02 Undeclared Keystone](ap-02-keystone-interface.md) | High-fan-in async consumers become undeclared keystones |
| [AP-11 Invisible Blast Radius](ap-11-cascade-risk-detectors.md) | Async monolith creates invisible cascade paths |
| [AP-03 Schema Blindness](ap-03-symbiotic-contracts.md) | Shared topics accelerate schema drift damage |

---

*See also: [AP-README](README.md) for the full antipattern index.*
