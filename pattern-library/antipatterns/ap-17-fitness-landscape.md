# AP-17 — Fitness Landscape Antipatterns

**Pattern this relates to:** [P17 Fitness Landscape Visualisation](../patterns/p17-fitness-landscape/)
**Category:** Succession and Scale
**TL;DR:** Architectural decisions are made without a view of the landscape — what is possible, what is costly, and where the local optima are. The result is either local optimum lock-in or aimless drift.

---

## The three ways this goes wrong

---

### AP-17-A: Landscape Blindness

**What it is:** Architectural decisions are made without any shared visualisation of the current landscape — where services are on the Wardley evolution axis, where coupling is concentrated, what the current AC score is, which services are resilient and which are fragile. Decisions are made from local knowledge and intuition rather than landscape-level information.

**Sign:** Two architects in the same organisation have significantly different mental models of the current architecture. Both think they are correct. Or: a decision that was made confidently turns out to have been made without visibility into a factor that significantly affects it.

**Why it happens:** Landscape visualisation requires investment: tooling, conventions, time to create and maintain the map. The returns are not immediate. The map falls out of date if not maintained. Eventually, nobody trusts it, and it stops being used. The default is for each architect to maintain their own mental model.

**What landscape blindness costs:**

```
Architectural decision: Add a new payment processing service

Without landscape view:
  - Architect A: "We should use the same tech stack as Orders service"
    (Does not know Orders is 94% on Wardley commodity axis)
  - Architect B: "We should try a new tech stack, we have expertise in it"
    (Does not know this creates vendor fragmentation that failed two years ago)
  - Decision: "Let's compromise, use a hybrid approach"
    (Worst of both options — complexity without benefits)
    
With landscape view:
  - Orders service: 94% commodity, payment processing 78% custom
  - Vendor concentration score: Currently 82% AWS (above threshold)
  - AC score trending negative: -12 points last quarter
  - Decision: "Use existing Orders tech for commodity parts, 
    evaluate lightweight options for custom parts to reduce vendor lock-in"
    (Informed by what the landscape is actually saying)
```

**The fix — P17 applied:** The fitness landscape is generated from code and monitoring data, not drawn by hand. It is accurate because it is derived from the system's actual state. It is updated on every deployment. Engineers and architects are looking at the same picture.

```yaml
# Fitness landscape — automated from code + metrics
landscape:
  generation-method: automated
  refresh-frequency: every deployment
  
  services:
    - name: orders
      evolution-stage: Custom      # Wardley stage
      ac-score: 68/100            # Architectural Cohesion
      coupling-index: 8            # Number of dependencies
      vendor-lock: 34%             # % that requires vendor-specific code
      resilience-score: 72/100
      incident-rate: 0.8 per month
      team-cognitive-load: 7/10    # Self-reported team load
      
    - name: payments
      evolution-stage: Genesis
      # ... same metrics
      
  ecosystem-level:
    ac-score: 64/100              # Average of all services
    vendor-concentration: 82%      # 82% on single vendor
    coupling-density: medium
    resilience-distribution: right-skewed (many fragile, few robust)
```

**Validated reference:** [Wardley Maps](https://wardleymaps.com/) as a landscape tool. [C4 Model](https://c4model.com/) (Simon Brown) for system context documentation. [Backstage](https://backstage.io/) service catalogue as a landscape entry point. [DDD Strategic Design](https://ddd-crew.github.io/) via context maps showing architectural landscape.

**SCARS lens:** Abstraction — landscape blindness is a failure to abstract architectural knowledge into visible, shared form. The landscape exists but is invisible.

---

### AP-17-B: Local Optimum Lock-In

**What it is:** The architecture has reached a local optimum — it is the best state achievable through incremental change from the current position — but not the global optimum. The team can see that the current architecture is not ideal, but every incremental step toward the better state makes things worse before they get better. So nothing changes. The system is stuck.

**Sign:** Technical leadership says "we know this isn't right, but there's no incremental path to fixing it." Or: the architecture stays the same for multiple years despite ongoing complaints about its limitations.

**Why it happens:** Escaping a local optimum requires accepting a period of worse performance — higher complexity, worse metrics, more brittleness. In a system that measures success by quarterly metrics, no team can justify taking those steps. The local optimum becomes a trap.

**What lock-in looks like:**

```
Current architecture: Monolithic with async background workers

Local optimum for this shape:
  - Predictable, well-understood codebase
  - Deployment is simple (one binary)
  - Operational overhead is low
  
But it has failed to scale:
  - Core monolith is at 85% CPU during peak
  - Cannot deploy payment changes without restarting entire system
  - Database queries from different concerns contend for locks
  
Ideal architecture: Microservices with clear domain boundaries

Migration path looks like:
  1. Extract first service from monolith (SHORT TERM: adds communication latency)
  2. Extract second service (SHORT TERM: operational complexity rises)
  3-5. Extract remaining services (SHORT TERM: metrics look worse)
  
  At step 3: AC score drops from 64 to 52, latency increases 20%, 
  operational incidents increase 40%, on-call load doubles
  
  By step 6: Architecture begins to benefit; scale bottleneck moves
  By step 8: AC score recovers to 68 (better than original)
  
The problem: No team will approve moving through steps 1-5 
because every step makes the system worse. They stay at 
the local optimum and declare the ideal state "not achievable."
```

**The fix — P17 applied:** A fitness landscape view surfaces escape routes from local optima — migration paths that provide a sequence of incremental steps, each of which is survivable, even if individually they look like they are moving in the wrong direction. The landscape shows not just where you are and where you want to be, but why the path looks worse in the middle.

```markdown
# Migration path: Monolith → Microservices (P12)

## Current state (local optimum)
- AC score: 64/100
- Deployment risk: low (single binary)
- Operational overhead: low
- Scaling bottleneck: monolith core

## Steps 1-3: Extract first services
- AC score will drop to 54-56 (expected and acceptable)
  Rationale: adding boundaries + communication introduces overhead
- Deployment risk: rises to medium (coordinated deploys)
- Operational overhead: rises (separate deployment pipelines)
- Timeline: 3-6 months

**Transition acceptance criteria:**
- Must understand that temporary regression is expected
- Success measured by progress toward escape, not by absolute metrics
- Alert thresholds adjusted temporarily (do not treat as failures)

## Steps 4-6: Extract remaining services
- AC score begins recovery at step 4
- Reaches 68 by step 6 (better than original local optimum)
- Deployment risk drops to low (independent deploys)
- Operational overhead rises further but becomes manageable

## Path exit condition
At step 6, the system has escaped the local optimum and 
can now scale indefinitely. Local bottleneck no longer constrains the platform.
```

**Validated reference:** [Martin Fowler's Strangler Fig pattern](https://martinfowler.com/bliki/StranglerFigApplication.html) — the canonical pattern for escaping local optima. Sam Newman, [Building Microservices](https://samnewman.io/books/building_microservices_2nd_edition/) — Chapter 4, migration strategies. Evolutionary Architecture (Ford, Parsons, Kua) — fitness landscape navigation.

**SCARS lens:** Simplify — a locked-in system cannot simplify because it cannot change. Breaking the lock requires accepting temporary complexity increase to reach a state where simplification is possible.

---

### AP-17-C: Fitness Function Cargo Cult

**What it is:** Fitness functions exist and run. The metrics are collected. Dashboard exists. But nobody acts on them. The score rises and falls; nobody asks why. The fitness function infrastructure has been built; the fitness function culture has not. The functions are a ceremony — they happen, but they do not shape decisions.

**Sign:** The last time a fitness function result changed an architectural decision was over a year ago. Or: fitness function violations are logged but never discussed in architecture review.

**Why it happens:** Fitness functions require a cultural shift — decisions made based on evidence rather than intuition. The tooling is easier to build than the culture. Once the tooling exists, it is easy to assume the practice is in place.

**What cargo cult looks like:**

```
Fitness function check: AC score > 65

Monthly results:
  January:   62 (threshold violation)
  February:  61 (violation continues)
  March:     63 (still below threshold)
  April:     64 (getting closer)
  May:       62 (regressed)
  
Action taken: none

Parallel activity: 
  "We really should improve our architecture cohesion"
  (spoken in architecture review meetings)
  
  New services added with no cohesion evaluation
  Technical debt accumulates
  AC score continues to drift
  
The fitness function is working correctly — it is measuring 
what it is supposed to measure. The organization is not 
working correctly — the measurement is disconnected from decisions.
```

**The fix — P17 applied:** Fitness function results are reviewed in sprint planning and architecture review, not just logged. Threshold violations require a decision — fix it, defer it with a date, or update the threshold with documented reasoning. Results are shown alongside feature delivery so that the tradeoff is visible.

```yaml
# Fitness function governance — made explicit
fitness-function-process:
  evaluation-frequency: weekly
  
  threshold-violation-response:
    - Identify the violation in sprint planning (not post-hoc)
    - Make an explicit decision:
        * Option A: Fix in this sprint (with impact analysis)
        * Option B: Defer with target date (must be within 90 days)
        * Option C: Accept and raise threshold (must document why the old threshold was wrong)
    - No option D: "Log it and continue"
    
  decision-recording:
    - Recorded in architecture decision log
    - Visible in weekly architecture review
    - Tracked for follow-up if deferred
    
  follow-up:
    - Deferred violations reviewed at the deferred date
    - If not fixed, must be re-decided (cannot drift indefinitely)
    - Overdue violations block all feature planning (not just architecture)
```

**Validated reference:** Evolutionary Architecture (Ford, Parsons, Kua) — fitness functions as a governance practice, not just a technical implementation. [Continuous Delivery](https://continuousdelivery.com/) (Humble & Farley) — deployment pipeline as a decision engine. Architecture Decision Records (ADR) — recording the reasoning behind architectural choices.

**SCARS lens:** Responsibilities — fitness function cargo cult is a Responsibilities failure. The organization has built the measurement; it has not taken responsibility for acting on the measurement.

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-06 Decision Amnesia](ap-06-knowledge-composting.md) | Landscape blindness means decisions are made without architectural context; decision amnesia means decisions are not recorded |
| [AP-09 SLA Theatre](ap-09-carrying-capacity-monitors.md) | Fitness Function Cargo Cult and SLA Theatre are the same failure — metrics that are not acted upon |
| [AP-20 Accidental Zoo](ap-20-biodiversity-index.md) | Without landscape visibility, technology choices become accidental (not strategic) |

---

*See also: [AP-README](README.md) for the full antipattern index.*
