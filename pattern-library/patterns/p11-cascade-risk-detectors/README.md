# P11 Cascade Risk Detectors

**Category:** Warning Signs & Triggers | **Build priority:** BUILD FIRST | **Complexity:** High
**AC score contribution:** Technical AC (T-AC) + Operational AC (Op-AC)

---

## 1. What this pattern is

In ecology, a trophic cascade happens when the removal of one species causes a chain reaction through the food web. The effect travels through hidden dependencies, and by the time it is visible, multiple layers have already been affected.

Software systems cascade the same way. One service slows. Its callers slow. Three layers of latency later, a user-facing service times out — and the post-mortem traces it back to a database query that started running slow six hours ago.

Cascade Risk Detectors find the hidden fault lines before the cascade starts. They map the dependency graph, identify the services whose failure would propagate furthest, and flag the structural patterns that turn ordinary failures into incidents.

---

## 2. The value it brings

- Blast radius is understood before incidents, not reconstructed after
- High-risk patterns are surfaced during architecture review, not during on-call
- Services most likely to cause cascades get appropriate protection
- The dependency graph gets simpler over time — risk scores create pressure toward P01 and P05

---

## 3. The problem it solves

You know you need this pattern when post-mortems contain "we didn't expect it to affect X", or when you cannot answer "if this service went down right now, what else would break?"

The problem is invisible blast radius. When failure paths are unmapped, every incident is a surprise.

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| Circuit Breaker | Interrupts a cascade in progress — Cascade Risk Detectors identify where circuit breakers are needed |
| Chaos Engineering | Tests cascade paths deliberately — this pattern identifies which paths are worth testing |
| Backstage / dependency mapping | Shows the graph — this pattern adds risk scoring on top |

---

## 5. What needs to happen

1. Build your dependency graph from trace data (Jaeger, Zipkin, Tempo) automate this, a manual map is always out of date
2. Score cascade risk per service: fan-in, depth, sync bridge score
3. Identify your top 5 cascade risk services
4. Add circuit breakers with defined fallbacks on high-risk paths
5. Add the fan-in fitness function to CI/CD — fail when any service exceeds 8 upstream dependents
6. Add cascade risk to your architecture review process

---

## 6. Antipatterns

See [AP-11: Cascade Risk Detectors antipatterns](../../antipatterns/ap-11-cascade-risk-detectors.md).

**The static risk map:** done once, never updated. Dependency graphs change constantly.

> **Sign:** a cascade post-mortem reveals a dependency not on the risk map, added three months ago.

**Circuit breakers without fallbacks:** a breaker that opens and returns an error propagates the failure in a different form.

> **Sign:** your circuit breaker trips and the calling service immediately errors too, just faster.

---

## 7. Architecture diagram

```
SERVICE DEPENDENCY GRAPH

        [User API]
            │
      ┌─────┴──────┐
      │             │
  [Orders]      [Catalogue]
      │             │
  ┌───┴───┐     [Pricing] ← HIGH CASCADE RISK
  │       │         │       fan-in: 5, depth: 3
[Inventory] [Payments]──────┘ sync bridge: YES

Action: add circuit breakers on Orders→Pricing and Catalogue→Pricing
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P01 Mycelial Mesh | Reducing sync dependencies reduces cascade risk — the structural fix |
| P02 Keystone Interface | High cascade risk services are often keystones |
| P09 Carrying Capacity Monitors | Real-time signal when a high-risk service approaches its limits |

---

## 9. Code snippet

```javascript
async function calculateCascadeRisk(serviceGraph) {
  return serviceGraph.nodes.map(service => {
    const fanIn = serviceGraph.edges.filter(e => e.target === service.id).length;
    const depth = calculateDependencyDepth(service.id, serviceGraph);
    const syncBridges = serviceGraph.edges
      .filter(e => e.target === service.id && e.type === 'synchronous').length;

    const riskScore = (fanIn * 3) + (depth * 2) + (syncBridges * 4);

    return {
      service: service.name,
      riskScore,
      riskLevel: riskScore > 20 ? 'HIGH' : riskScore > 10 ? 'MEDIUM' : 'LOW'
    };
  }).sort((a, b) => b.riskScore - a.riskScore);
}
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Services with unknown blast radius | 0 | Dependency graph coverage |
| High-risk services with circuit breakers | 100% | Circuit breaker registry vs risk list |
| Mean blast radius per incident | Decreasing trend | Post-mortem analysis |
| Fan-in violations in CI | 0 | Fitness function log |

---

## 12. What to look out for

Sync bridges in async architectures are the most dangerous cascade patterns — weight them heavily and add circuit breakers first. The 8-dependent threshold is a prompt to review architecture, not just update a number. Rising cascade risk scores with falling blast radius per incident means the pattern is working.
