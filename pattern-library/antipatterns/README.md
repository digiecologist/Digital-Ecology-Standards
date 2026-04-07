# Antipattern Library

> **What this is:** The degraded forms of the 20 ecological patterns. Every pattern has a healthy version and an unhealthy version. This library documents the unhealthy versions — what they look like, how to recognise them, and which pattern to apply to fix them.
>
> **How to use it:** If you are diagnosing a problem, start with the [symptom lookup](#symptom-lookup) below. If you want to understand the failure modes for a specific pattern, go to that pattern's antipattern file.

---

## Table of Contents

- [Symptom lookup](#symptom-lookup)
- [Antipatterns by pattern](#antipatterns-by-pattern)
  - [Structural / Architectural](#structural--architectural)
  - [Flow and Nutrient Cycling](#flow-and-nutrient-cycling)
  - [Warning Signs and Triggers](#warning-signs-and-triggers)
  - [Adaptive and Regenerative](#adaptive-and-regenerative)
  - [Succession and Scale](#succession-and-scale)
- [Cross-cutting antipattern themes](#cross-cutting-antipattern-themes)

---

## Symptom lookup

What you're seeing → which antipattern → which pattern fixes it.

| You are seeing this | Antipattern | Pattern to apply | Tags |
|---|---|---|---|
| Services that must all deploy together even when you only changed one | [Async Monolith](ap-01-mycelial-mesh.md#ap-01-e-async-monolith) | [P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/) | #coupling #deployment #decomposition |
| Events named `ProcessOrder`, `SendEmail`, `UpdateUser` | [Commands in Disguise](ap-01-mycelial-mesh.md#ap-01-b-commands-in-disguise) | [P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/) | #eventing #domain |
| Hundreds of event types, no-one knows what's what | [Event Soup](ap-01-mycelial-mesh.md#ap-01-a-event-soup) | [P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/) | #eventing #complexity |
| An integration point breaking everything downstream | [Undeclared Keystone](ap-02-keystone-interface.md#ap-02-a-undeclared-keystone) | [P02 Keystone Interface](../patterns/p02-keystone-interface/) | #coupling #ownership #dependency |
| Schema changes breaking consumers you didn't know existed | [Silent Consumer Sprawl](ap-02-keystone-interface.md#ap-02-b-silent-consumer-sprawl) | [P02 Keystone Interface](../patterns/p02-keystone-interface/) | #schema #dependency #visibility |
| Schema drift discovered in production, not in CI | [Schema Blindness](ap-03-symbiotic-contracts.md#ap-03-a-schema-blindness) | [P03 Symbiotic Contracts](../patterns/p03-symbiotic-contracts/) | #schema #testing #visibility |
| Domain boundaries that exist in diagrams but not in code | [Cosmetic Boundary](ap-04-edge-effect-zones.md#ap-04-a-cosmetic-boundary) | [P04 Edge Effect Zones](../patterns/p04-edge-effect-zones/) | #domain #architecture |
| Services doing overlapping jobs; unclear who owns what | [Niche Overlap](ap-05-niche-partitioning.md#ap-05-b-niche-overlap) | [P05 Niche Partitioning](../patterns/p05-niche-partitioning/) | #ownership #domain #responsibility |
| APIs with no documentation of what breaks if they go down | [Undocumented Dependency Weight](ap-07-nutrient-flow.md#ap-07-a-undocumented-dependency-weight) | [P07 Nutrient Flow](../patterns/p07-nutrient-flow/) | #dependency #documentation #visibility |
| Work piling up in queues between teams; slow cycle times | [Value Flow Opacity](ap-07-nutrient-flow.md#ap-07-c-value-flow-opacity) | [P07 Nutrient Flow](../patterns/p07-nutrient-flow/) | #flow #visibility #cycle-time |
| Microservices that must be deployed in a fixed order | [Distributed Monolith](ap-08-trophic-decomposition.md#ap-08-b-the-distributed-monolith) | [P08 Trophic Decomposition](../patterns/p08-trophic-decomposition/) | #coupling #deployment #decomposition |
| Alerts firing constantly; engineers ignoring them | [Alert Fatigue Loop](ap-09-carrying-capacity-monitors.md#ap-09-a-alert-fatigue-loop) | [P09 Carrying Capacity Monitors](../patterns/p09-carrying-capacity-monitors/) | #alerting #monitoring #fatigue |
| Monitoring covers SLAs but not structural health | [SLA Theatre](ap-09-carrying-capacity-monitors.md#ap-09-b-sla-theatre) | [P09 Carrying Capacity Monitors](../patterns/p09-carrying-capacity-monitors/) | #monitoring #visibility #slo |
| Incidents cascade; blast radius always larger than expected | [Invisible Blast Radius](ap-11-cascade-risk-detectors.md#ap-11-a-invisible-blast-radius) | [P11 Cascade Risk Detectors](../patterns/p11-cascade-risk-detectors/) | #risk #coupling #visibility |
| Circuit breakers exist but cascade still happens | [Circuit Breaker Theatre](ap-11-cascade-risk-detectors.md#ap-11-b-circuit-breaker-theatre) | [P11 Cascade Risk Detectors](../patterns/p11-cascade-risk-detectors/) | #resilience #monitoring #pattern-mimicry |
| Slow, invisible degradation nobody notices until it's serious | [The Boiling Frog](ap-12-phenological-drift-alerts.md#ap-12-a-the-boiling-frog) | [P12 Phenological Drift Alerts](../patterns/p12-phenological-drift-alerts/) | #trend #visibility #monitoring |
| Alert thresholds keep getting raised to silence the alert | [Threshold Inflation](ap-12-phenological-drift-alerts.md#ap-12-c-threshold-inflation) | [P12 Phenological Drift Alerts](../patterns/p12-phenological-drift-alerts/) | #alerting #threshold #monitoring |
| Experimental services running permanently in production | [The Infinite PoC](ap-13-pioneer-service-incubators.md#ap-13-b-the-infinite-poc) | [P13 Pioneer Service Incubators](../patterns/p13-pioneer-service-incubators/) | #experimentation #lifecycle |
| No protected time to experiment; everything is feature delivery | [The Unfunded Mandate](ap-13-pioneer-service-incubators.md#ap-13-a-the-unfunded-mandate) | [P13 Pioneer Service Incubators](../patterns/p13-pioneer-service-incubators/) | #experimentation #team-structure |
| Tech debt sprints followed by immediate re-accumulation | [The Debt Sprint Cycle](ap-14-regenerative-refactoring.md#ap-14-a-the-debt-sprint-cycle) | [P14 Regenerative Refactoring](../patterns/p14-regenerative-refactoring/) | #regeneration #tech-debt |
| Improvement work happens in engineers' own time | [Improvement as Overtime](ap-14-regenerative-refactoring.md#ap-14-b-improvement-as-overtime) | [P14 Regenerative Refactoring](../patterns/p14-regenerative-refactoring/) | #regeneration #team-structure |
| Dependencies between services with no declared ownership or obligation | [Unnamed Relationship](ap-15-symbiotic-dependency-design.md#ap-15-a-unnamed-relationship) | [P15 Symbiotic Dependency Design](../patterns/p15-symbiotic-dependency-design/) | #dependency #ownership |
| A service "almost ready for production" for more than 90 days | [The Eternal Candidate](ap-16-succession-gates.md#ap-16-a-the-eternal-candidate) | [P16 Succession Gates](../patterns/p16-succession-gates/) | #lifecycle #deployment #succession |
| Deprecated services still receiving production traffic, no owner | [The Undead Service](ap-16-succession-gates.md#ap-16-b-the-undead-service) | [P16 Succession Gates](../patterns/p16-succession-gates/) | #lifecycle #ownership #succession |
| Architecture dashboard showing degrading signals; no action taken | [The Orphaned Dashboard](ap-17-fitness-landscape.md#ap-17-b-the-orphaned-dashboard) | [P17 Fitness Landscape](../patterns/p17-fitness-landscape/) | #monitoring #visibility |
| Architecture decisions made without measurable success criteria | [Fitness Landscape Blindness](ap-17-fitness-landscape.md#ap-17-a-fitness-landscape-blindness) | [P17 Fitness Landscape](../patterns/p17-fitness-landscape/) | #decision-making #metrics |
| System only ever grows in complexity; nothing is ever removed | [The One-Way Ratchet](ap-18-regenerative-cycles.md#ap-18-a-the-one-way-ratchet) | [P18 Regenerative Cycles](../patterns/p18-regenerative-cycles/) | #complexity #regeneration |
| Experiments that ran but nobody made a decision on | [The Undead Experiment](ap-19-minimum-viable-experiment.md#ap-19-c-the-undead-experiment) | [P19 Minimum Viable Experiment](../patterns/p19-minimum-viable-experiment/) | #experimentation #decision-making |
| Experiments with no stated success criteria before they start | [Hypothesis-Free Experiment](ap-19-minimum-viable-experiment.md#ap-19-a-the-hypothesis-free-experiment) | [P19 Minimum Viable Experiment](../patterns/p19-minimum-viable-experiment/) | #experimentation #metrics |
| Technology diversity growing without strategic intent | [Complexity Sprawl](ap-20-biodiversity-index.md#ap-20-b-complexity-sprawl) | [P20 Biodiversity Index](../patterns/p20-biodiversity-index/) | #complexity #diversity |
| Entire platform vulnerable to a single vendor or runtime outage | [Monoculture Fragility](ap-20-biodiversity-index.md#ap-20-a-monoculture-fragility) | [P20 Biodiversity Index](../patterns/p20-biodiversity-index/) | #diversity #risk |


---

## Antipatterns by pattern

### Structural / Architectural

- [AP-01: Mycelial Mesh antipatterns](ap-01-mycelial-mesh.md) — Event Soup, Commands in Disguise, Shared Topics, Invisible Dead Letter Queue, Async Monolith
- [AP-02: Keystone Interface antipatterns](ap-02-keystone-interface.md) — Undeclared Keystone, Silent Consumer Sprawl, Keystone Without Runbook
- [AP-03: Symbiotic Contracts antipatterns](ap-03-symbiotic-contracts.md) — Schema Blindness, Consumer-Driven Contract Washing, Backwards Compatibility Forever
- [AP-04: Edge Effect Zones antipatterns](ap-04-edge-effect-zones.md) — Cosmetic Boundary, Shared Database Seepage, Big Ball of Mud with Labels
- [AP-05: Niche Partitioning antipatterns](ap-05-niche-partitioning.md) — Niche Overlap, The God Service, Responsibility Creep

### Flow and Nutrient Cycling

- [AP-06: Knowledge Composting antipatterns](ap-06-knowledge-composting.md) — Dead Code Hoarding, Decision Amnesia, Undead Feature
- [AP-07: Nutrient Flow antipatterns](ap-07-nutrient-flow.md) — Undocumented Dependency Weight, Black Box API, Value Flow Opacity
- [AP-08: Trophic Decomposition antipatterns](ap-08-trophic-decomposition.md) — Layer Bypass, Leaky Abstraction Stack, Enrichment Skipping

### Warning Signs and Triggers

- [AP-09: Carrying Capacity Monitors antipatterns](ap-09-carrying-capacity-monitors.md) — Alert Fatigue Loop, SLA Theatre, The Invisible Ceiling
- [AP-10: Biodiversity Index Checks antipatterns](ap-10-biodiversity-index-checks.md) — Diversity Blindness, Compliance Scoring, Stage-Inappropriate Diversity
- [AP-11: Cascade Risk Detectors antipatterns](ap-11-cascade-risk-detectors.md) — Invisible Blast Radius, Circuit Breaker Theatre, Sync Bridge Denial

### Adaptive and Regenerative

- [AP-12: Phenological Drift Alerts antipatterns](ap-12-phenological-drift-alerts.md) — Boiling Frog, Drift Without Baseline, Noise-Signal Inversion
- [AP-13: Pioneer Service Incubators antipatterns](ap-13-pioneer-service-incubators.md) — Infinite PoC, Unfunded Mandate, Incubation Theatre
- [AP-14: Regenerative Refactoring antipatterns](ap-14-regenerative-refactoring.md) — Debt Sprint Cycle, Improvement as Overtime, Boy Scout Rule Without Teeth
- [AP-15: Symbiotic Dependency Design antipatterns](ap-15-symbiotic-dependency-design.md) — Unnamed Relationship, Asymmetric Dependency, Dependency by Accident

### Succession and Scale

- [AP-16: Succession Gates antipatterns](ap-16-succession-gates.md) — Premature Graduation, Gate Without Criteria, Eternal Candidate
- [AP-17: Fitness Landscape antipatterns](ap-17-fitness-landscape.md) — Landscape Blindness, Local Optimum Lock-in, Fitness Function Cargo Cult
- [AP-18: Regenerative Cycles antipatterns](ap-18-regenerative-cycles.md) — One-Way Ratchet, Renewal Without Rhythm, Capacity Without Release
- [AP-19: Minimum Viable Experiment antipatterns](ap-19-minimum-viable-experiment.md) — Hypothesis-Free Experiment, Permanent Spike, Invisible Learning
- [AP-20: Biodiversity Index antipatterns](ap-20-biodiversity-index.md) — Accidental Zoo, Monoculture Risk, Diversity for Diversity's Sake

---

## Cross-cutting antipattern themes

Some failure modes appear across multiple patterns. These are the ones worth knowing first.

### The Visibility Gap
You cannot see the problem until it is already serious. Appears in: P09, P11, P12, P07.
Fix: instrument early, surface signals before thresholds are crossed.

### Structural Debt as Social Contract
Everyone knows the problem exists; nobody is empowered to fix it. Appears in: P14, P13, P01.
Fix: protected capacity, explicit ownership, measurable targets.

### Pattern Mimicry
The pattern exists in name only — the code or process matches the label but not the intent. Appears in: P11 (Circuit Breaker Theatre), P09 (SLA Theatre), P13 (Incubation Theatre).
Fix: fitness functions that test behaviour, not presence.

### Invisible Coupling
Two things are coupled but the dependency is not declared or visible. Appears in: P01, P02, P03, P11.
Fix: make all dependencies explicit, test contract boundaries in CI.

---

*Part of the [Ecological Engineering Standards](../README.md) repository. Based on [Digital Ecosystems, Naturally Resilient](https://example.com) by Jenny Wilson.*
