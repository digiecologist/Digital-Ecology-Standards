# P01 — Mycelial Mesh

**Category:** Structural / Architectural  |  **Build priority:** BUILD FIRST
**AC score contribution:** Technical AC (T-AC)

---

## 1. What this pattern is

[2-3 sentences describing what the pattern does in plain language.]
[One sentence on the ecological parallel — e.g. how mycelial networks
share nutrients without central control.]

## 2. The value it brings

[What gets better when you apply this pattern. Be specific:
deployment frequency, incident rate, team independence, etc.]

## 3. The problem it solves

[What is broken right now that this fixes. Name the symptom
engineers actually experience — 'we cannot deploy without coordinating
with three other teams' is better than 'high coupling'.]

## 4. Existing pattern equivalents

[What this pattern replaces or extends from:
- Strangler Fig Pattern (Martin Fowler)
- Anti-Corruption Layer (DDD)
- etc.]
[What gap this fills that existing patterns leave open.]

## 5. What needs to happen (implementation steps)

1. [First concrete action — specific enough to do today]
2. [Second action]
3. [Continue...]

See [code-examples/README.md](code-examples/README.md) for working code.

## 6. Antipatterns and unhealthy versions

See [antipatterns.md](antipatterns.md) for the full list.

> **Sign:** [The observable symptom that tells you this antipattern
> is present — what you would see in your dashboards or incidents.]

## 7. Architecture diagram

[Embed or link to a diagram here. ASCII diagrams work fine in
Markdown and render in GitHub without any extra tools.]

```
Service A ──→ Event Bus ──→ Service B
                │
                └──→ Service C
```

## 8. Related patterns

See [related-patterns.md](related-patterns.md) for the full table.

| Pattern                  | Relationship            |
|--------------------------|-------------------------|
| P02 Keystone Interface   | Often implemented first |
| P11 Cascade Risk         | Depends on this         |

## 9. Code snippets

[Short inline example showing the core idea — 10-20 lines max.]
[Link to full working version in code-examples/.]

```javascript
// Example: async event publication
await eventBus.publish('order.placed', {
  orderId: order.id,
  timestamp: new Date().toISOString()
});
```

## 10. Deployable code patterns

Production-ready implementations are in [code-examples/](code-examples/).

| File                     | What it contains                  |
|--------------------------|-----------------------------------|
| basic-mesh.js            | Minimal working implementation    |
| advanced-mesh.js         | Production-ready with error cases |

## 11. Measuring success

Fitness functions for automated measurement are in
[fitness-functions/](fitness-functions/).

| Metric                   | Healthy threshold   | How to measure      |
|--------------------------|---------------------|---------------------|
| Fan-in per service       | < 7 categories      | API gateway spec    |
| Co-deployment rate       | < 60%               | CI/CD event log     |

## 12. What to look out for

[Gotchas that are not obvious from the description.
Calibration guidance — when to tighten or loosen the thresholds.
What breaks silently if you get this wrong.]
