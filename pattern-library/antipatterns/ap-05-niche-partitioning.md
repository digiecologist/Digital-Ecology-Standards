# AP-05 — Niche Partitioning Antipatterns

**Pattern this relates to:** [P05 Niche Partitioning](../patterns/p05-niche-partitioning/)
**Category:** Structural / Architectural
**TL;DR:** Services either do too much (the god service) or too little (over-split). Both make the system harder to reason about and harder to change.

---

## The three ways this goes wrong

---

### AP-05-A: The God Service

**What it is:** A single service accumulates responsibilities across multiple domains until it cannot be changed without risk to unrelated business capabilities. It started as "the service that handles orders" and now also handles notifications, PDF generation, payment reconciliation, and reporting.

**Sign:** The service's README has a "What this service does NOT do" section — and it is longer than the "What it does" section.

**Why it happens:** The path of least resistance for adding a feature is always the service that already touches the relevant data. Each addition is small and justified. The cumulative effect is a service that no single engineer fully understands.

**The blast radius problem:**
```
God Service responsibilities (real example, simplified):
  - Customer order management        ← core responsibility
  - Email notification dispatch      ← should be notifications service
  - PDF invoice generation           ← should be document service  
  - Payment reconciliation reports   ← should be finance service
  - Customer preference storage      ← should be customer profile service
  - Fraud signal collection          ← should be risk service

Result: A bug fix for invoice PDF formatting requires
  → A deployment of the order management service
  → Risk to live order processing
  → Coordination with 4 other teams to test their concerns
```

**The fix — P05 applied:** Each service occupies one niche — a clearly bounded capability set that maps to a single team's domain. When a responsibility clearly belongs to a different domain, it moves. The test: if this capability needed to change independently, could it? If not, it should not be in this service.

**Validated reference:** Single Responsibility Principle (Robert C. Martin) at the service level. Domain-Driven Design bounded context — one service per bounded context. [Team Topologies](https://teamtopologies.com/) — stream-aligned team model where team cognitive load is the constraint.

**SCARS lens:** Responsibilities — the god service has violated the Responsibilities check. It carries responsibility far beyond what one team can reason about and govern.

---

### AP-05-B: Niche Overlap

**What it is:** Two or more services claim the same responsibility. Neither is wrong — they both legitimately do it — but the duplication creates inconsistency over time. Business rules diverge. A change in one is not reflected in the other. Users experience different behaviour depending on which service their request happened to hit.

**Sign:** When you search the codebase for where a business rule lives, you find it in more than one place.

**Why it happens:** Overlap usually emerges from parallel development without coordination, from a migration that was never completed (old service and new service both active), or from two teams independently solving the same problem because they did not know the other was working on it.

**What it costs:**
```
Discount calculation rule (20% for premium customers):
  
  order-service:       implements 20% discount
  checkout-service:    implements 18% discount (outdated copy)
  cart-service:        implements 20% discount (but only for online orders)
  
Result: 
  - Customers see different totals in cart vs checkout
  - Three teams own three versions of the same rule
  - A rule change requires coordinating across all three
```

**The fix — P05 applied:** One niche, one service. The discount rule lives in exactly one service. Other services consume it as a capability, not as a local copy. Where overlap exists today, define the canonical owner and migrate consumers to it.

**Validated reference:** DRY principle (Don't Repeat Yourself) at the service level. [Evolutionary Architecture](https://evolutionaryarchitecture.com) — fitness function: no business rule implemented in more than one service.

**SCARS lens:** Cohesion — business rules that are implemented in multiple places have failed the Cohesion check. Things that change together should live together.

---

### AP-05-C: Responsibility Creep

**What it is:** A service's responsibilities are well-defined at launch and then gradually expand over time without formal decisions. Each addition is a small pragmatic choice. Over two years, the service has drifted far from its original niche and is approaching god service territory.

**Sign:** The service's original README is still accurate for the core capability, but the service now does three other things that aren't mentioned.

**Why it happens:** There is no mechanism for questioning whether a new capability belongs in a given service. The decision is made by whoever is building the feature, under time pressure, using the service that seems most convenient.

**The fix — P05 applied:** Service manifests declare the owned capability explicitly. Any PR that adds a capability outside the declared scope triggers an explicit review: is this a scope expansion (which needs a decision) or a mistake? The manifest makes the boundary visible and the expansion detectable.

```yaml
# service-manifest.yml — declare the niche explicitly
service: order-management
version: 2.1
owner: orders-team

capabilities:
  - order lifecycle management (create, update, cancel, complete)
  - order state machine transitions
  - order event publication

explicitly-not-in-scope:
  - payment processing (→ payment-service)
  - email notifications (→ notification-service)
  - PDF generation (→ document-service)
  - customer data management (→ customer-profile-service)
```

**Validated reference:** [Backstage](https://backstage.io/) service catalogue — service manifests with ownership. [Team Topologies](https://teamtopologies.com/) — team cognitive load as the constraint on service scope.

**SCARS lens:** Separation — responsibility creep is a slow-motion Separation failure. Concerns are gradually conflated until a separation violation is obvious but expensive to fix.

---

## Fitness function

```yaml
# In CI: check service manifest is present and up to date
name: Niche Boundary Guard
checks:
  - name: Service manifest present
    fail_if: service-manifest.yml missing from repository root
    
  - name: New capabilities declared
    fail_if: |
      PR adds code in /src/capabilities/ without updating 
      service-manifest.yml capabilities list
      
  - name: Cross-niche call detection
    tool: dependency-cruiser
    fail_if: |
      Any service imports from a capability explicitly listed in 
      another service's manifest as owner
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-04 Cosmetic Boundary](ap-04-edge-effect-zones.md) | No boundaries → responsibility spreads unchecked |
| [AP-02 Undeclared Keystone](ap-02-keystone-interface.md) | God services become undeclared keystones |
| [AP-08 Leaky Abstraction Stack](ap-08-trophic-decomposition.md) | God services often result from layers not consuming and passing on cleanly |

---

*See also: [AP-README](README.md) for the full antipattern index.*
