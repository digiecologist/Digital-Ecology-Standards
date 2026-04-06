# P13 — Pioneer Service Incubators

**Category:** Adaptive & Regenerative | **Build priority:** BUILD FIRST | **Complexity:** Low
**AC score contribution:** Organisational AC (O-AC)

---

## 1. What this pattern is

In ecology, pioneer species are the first to colonise new ground. They are small, experimental, adapted to uncertainty — and they create the conditions that allow more complex life to follow.

A Pioneer Service Incubator is a protected zone in your software ecosystem where genuinely new things can be tried — new architectural patterns, new technology choices — without threatening the stable production ecosystem around them. Not a broken staging environment. A genuine space for architectural experimentation with defined graduation criteria.

---

## 2. The value it brings

- New patterns validated in production conditions before system-wide adoption
- Teams have a legitimate route for architectural innovation
- Failed experiments are cheap — the isolation boundary protects production
- Successful experiments have a defined path to production via P16 Succession Gates
- The system evolves continuously rather than in painful, infrequent rewrites

---

## 3. The problem it solves

You know you need this pattern when new technology choices take months to approve because there is nowhere safe to try them, or when the system never changes architecturally because change feels too risky.

The problem is no protected space for change. Without a deliberate incubation space, innovation either does not happen or it happens dangerously — directly in production, under deadline pressure.

---

## 5. What needs to happen

1. Protect the capacity explicitly — 15–20% of engineering time, defended by leadership
2. Define incubation rules: no SLA required, allowed to use unapproved technology, must document what is being tested
3. Define graduation criteria using P16 Succession Gates as the framework
4. Enforce the isolation boundary architecturally — pioneer services must not be in the critical path for production traffic
5. Create a visible catalogue of what is in incubation, what is being tested, and what has graduated
6. Set a time limit and decision point for every pioneer service: graduate, extend, or retire

---

## 6. Antipatterns

See [AP-13: Pioneer Service Incubator antipatterns](../../antipatterns/ap-13-pioneer-service-incubators.md).

**The unfunded mandate:** the incubation space exists on paper but capacity is reallocated every sprint.

> **Sign:** the last thing incubated was 18 months ago, done informally by an engineer working evenings.

**The infinite PoC:** a pioneer service that never graduates and never retires, slowly accumulating real dependencies.

> **Sign:** a "temporary" service has been running in incubation for two years and others depend on it.

---

## 7. Architecture diagram

```
┌─────────────────────────────────────────────┐
│           PRODUCTION ECOSYSTEM               │
│   Full SLAs │ Approved patterns              │
└──────────────────────┬──────────────────────┘
                       │ graduation via P16
┌──────────────────────▼──────────────────────┐
│          PIONEER INCUBATION ZONE             │
│   No SLAs │ Experimental │ Shadow traffic    │
│                                              │
│   → Event sourcing for orders (P01 variant)  │
│   → GraphQL federation gateway               │
└─────────────────────────────────────────────┘
ISOLATION: Pioneer services cannot be in the critical path
```

---

## 9. Code snippet

```yaml
# pioneer-catalogue.yml — one entry per service in incubation
services:
  - name: event-sourcing-orders-experiment
    hypothesis: "Event sourcing will reduce orders domain coupling from 45% to below 30%"
    started: 2024-01-15
    review-date: 2024-04-15
    owner: orders-team
    traffic: shadow-only
    graduation-criteria:
      - coupling score < 30% sustained for 30 days
      - p99 latency <= current service baseline
      - zero data loss events in 30-day shadow period
    status: in-progress
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Active pioneer services | 2–5 at any time | Pioneer catalogue |
| Graduation rate | > 50% graduate or are deliberately retired | Catalogue outcomes |
| Time to graduation decision | < 90 days | Catalogue timestamps |
| Capacity protected | 15–20% of engineering time | Sprint tracking |
| Production incidents caused by pioneer services | 0 | Incident tags |

---

## 12. What to look out for

Leadership must hold the line on protected capacity every sprint — without that, the incubation space disappears under feature pressure. Define graduation criteria on day one, not at the end. Shadow traffic is not the same as production traffic — always include a canary step as a required graduation stage.
