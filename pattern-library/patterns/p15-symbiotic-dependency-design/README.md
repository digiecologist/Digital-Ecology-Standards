# P15 — Symbiotic Dependency Design

**Category:** Adaptive & Regenerative | **Build priority:** BUILD SECOND | **Complexity:** Medium
**AC score contribution:** Technical AC (T-AC) + Organisational AC (O-AC)

> **Prerequisite:** P01 Mycelial Mesh. This pattern audits and designs the relationships between mesh participants — distinguishing the ones that benefit both sides from the ones that drain one side silently.

---

## 1. What this pattern is

In ecology, symbiosis describes organisms living in close association. The most valuable relationships are mutualistic — both parties benefit. A cleaner fish removes parasites from a larger fish; both gain. Mycorrhizal fungi exchange nutrients with tree roots; both gain.

But symbiosis also includes parasitic relationships — one organism benefits at the expense of another. The parasite is often invisible. The host just gradually weakens.

Software services form the same types of relationships. A mutualistic dependency is one where both services benefit from the connection — each provides something the other needs, both are more capable together than apart. A parasitic dependency is one where one service extracts value from another without giving back — it consumes the provider's capacity, schema stability, and engineering attention without contributing anything in return.

Symbiotic Dependency Design makes these relationships explicit: name them, measure them, and systematically eliminate the parasitic ones.

---

## 2. The value it brings

- Parasitic dependencies are identified and eliminated before they become structural debt
- Mutualistic relationships are made explicit and protected
- Teams understand the real cost of their dependencies, not just their functional value
- Dependency refactoring is prioritised based on relationship quality, not just coupling score
- The system evolves toward genuinely cooperative architecture rather than extractive architecture

---

## 3. The problem it solves

You know you need this pattern when one team's service is constantly being called by many others but gets nothing useful back from those calls — their service becomes a support burden without any architectural reciprocity. Or when a consuming service is so deeply integrated with a provider that any change to either requires coordinating both.

The problem is unnamed relationships. Most dependency graphs show connections but not their quality. High fan-in might be a sign of a genuinely valuable shared service (mutualistic) or a sign of a service that has accumulated dependents because it was convenient, not because it is the right home for that capability (parasitic accumulation).

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| Dependency inversion principle | A design principle for decoupling — this pattern adds the relationship quality dimension on top |
| P11 Cascade Risk Detectors | Identifies high-risk dependencies by fan-in and depth — this pattern identifies low-quality dependencies by relationship type |
| P02 Keystone Interface | Keystones are high-fan-in services — this pattern helps identify which of those relationships are mutualistic vs parasitic |

**The gap this fills:** existing tools measure dependency quantity (fan-in, fan-out, coupling score). This pattern measures dependency quality — whether the relationship is genuinely mutually beneficial or extractive.

---

## 5. What needs to happen

1. **Map and classify every cross-service dependency.** For each dependency, label it as one of:
   - *Mutualistic:* both services benefit — each provides something the other needs
   - *Commensal:* one benefits, the other is unaffected — acceptable but watch for drift toward parasitic
   - *Parasitic:* one benefits at the expense of the other — the provider carries cost without receiving value

2. **Identify the parasitic dependencies.** Signs of a parasitic relationship: the provider team spends significant support time on this consumer; the consumer uses only a tiny fraction of the provider's capability; the consumer requires the provider to maintain backward compatibility indefinitely for no architectural reason; the connection exists for historical reasons, not current need.

3. **Design toward mutualism.** For each parasitic relationship, identify what would make it mutualistic: could the consuming service provide something back? Could the capability be moved closer to where it is actually used? Could the dependency be eliminated by redesigning the flow?

4. **Add relationship quality to architecture reviews.** Every new cross-service dependency requires a relationship classification at creation time. "What does each side get from this relationship?" should be a standard review question.

5. **Track relationship quality over time.** Mutualistic relationships that drift toward parasitic as services evolve are common. Review classification annually.

---

## 6. Antipatterns and unhealthy versions

**The utility service trap:** a service that was designed as a shared utility gradually accumulates so many consumers with so many different needs that it becomes a mini-monolith. Each consumer relationship started as commensual and drifted parasitic as the utility bent itself to serve each consumer's specific requirements.

> **Sign:** the utility service team spends more time managing consumer requests and backward compatibility than building new capability.

**Mutualism by declaration:** labelling a dependency mutualistic because both teams like each other, not because the architecture is genuinely reciprocal.

> **Sign:** when asked "what does the provider get from this relationship?", the answer is "we appreciate their partnership."

---

## 7. Architecture diagram

```
DEPENDENCY RELATIONSHIP AUDIT

Service A ──────────────► Service B
  "A calls B for user profile data"

Classification questions:
  Does B benefit from A calling it?
  → B gets no value from serving A's requests — it's pure cost
  → Relationship type: PARASITIC (A benefits, B carries cost)

  What would make this mutualistic?
  → A could share behavioural data B needs for its own analytics
  → Or: move the user profile data A needs into A's own domain
  → Or: formalise B as a platform service with explicit SLA and cost recovery

MUTUALISTIC EXAMPLE:
Service C ◄──────────────► Service D
  "C provides order data to D; D provides fraud scores to C"
  Both services are more capable together than apart.
  Relationship type: MUTUALISTIC ✓
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P01 Mycelial Mesh | The mesh reduces parasitic synchronous dependencies by making relationships explicit through events |
| P05 Niche Partitioning | Clear domain ownership reduces accidental parasitic dependencies caused by unclear boundaries |
| P11 Cascade Risk Detectors | High cascade risk often correlates with parasitic dependency accumulation |

---

## 9. Code snippet

```yaml
# dependency-relationships.yml — relationship quality registry
# Maintained alongside the service registry

dependencies:
  - provider: user-service
    consumer: order-service
    type: commensal
    justification: "order-service reads user profile; user-service gets nothing back"
    review-date: 2025-01-15
    action: "Evaluate moving user fields order-service needs into order domain"

  - provider: fraud-service
    consumer: order-service
    type: mutualistic
    justification: "fraud-service provides risk scores; order-service provides transaction data fraud-service needs"
    review-date: 2025-01-15
    action: "Protect this relationship — both sides need it"

  - provider: legacy-config-service
    consumer: twelve-other-services
    type: parasitic
    justification: "config-service carries all backward compatibility cost; consumers get config data cheaply"
    review-date: 2025-01-15
    action: "Migrate config consumers to environment variables over next 2 quarters"
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Classified dependencies | 100% of cross-boundary dependencies | Relationship registry completeness |
| Parasitic dependencies | Decreasing trend | Registry audit quarterly |
| Provider services with > 20% support time from consumer requests | 0 | Team time tracking |
| New dependencies created without relationship classification | 0 | PR review checklist |

---

## 12. What to look out for

Relationship classification requires honesty from both teams involved — the consuming team must admit when they are extracting value without giving back, and the providing team must admit when they are enabling parasitic relationships for political reasons. This is a cultural challenge as much as a technical one. The most effective approach is to make the audit a joint exercise with both teams present, facilitated by someone neutral, with the explicit goal of finding improvements rather than assigning blame.
