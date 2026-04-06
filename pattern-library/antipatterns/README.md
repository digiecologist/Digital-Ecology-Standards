# Antipattern Library

> **What this is:** The degraded forms of the 20 ecological patterns. Every pattern has a healthy version and an unhealthy version. This library documents the unhealthy versions — what they look like, how to recognise them, and which pattern to apply to fix them.
>
> **How to use it:** If you are diagnosing a problem, start with the [symptom lookup](#symptom-lookup) below. If you want to understand the failure modes for a specific pattern, go to that pattern's antipattern file.

---

## Symptom lookup

What you're seeing → which antipattern → which pattern fixes it.

| You are seeing this | Antipattern | Pattern to apply |
|---|---|---|
| Services deploy together even when you don't want them to | [Sync Mesh](#sync-mesh) | [P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/) |
| Events named `ProcessOrder`, `SendEmail`, `UpdateUser` | [Commands in Disguise](#commands-in-disguise) | [P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/) |
| Hundreds of event types, no-one knows what's what | [Event Soup](#event-soup) | [P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/) |
| An integration point breaking everything downstream | [Undeclared Keystone](#undeclared-keystone) | [P02 Keystone Interface](../patterns/p02-keystone-interface/) |
| Schema changes breaking consumers you didn't know existed | [Silent Consumer Sprawl](#silent-consumer-sprawl) | [P02 Keystone Interface](../patterns/p02-keystone-interface/) |
| Alerts firing constantly; engineers ignoring them | [Alert Fatigue Loop](#alert-fatigue-loop) | [P09 Carrying Capacity Monitors](../patterns/p09-carrying-capacity-monitors/) |
| Monitoring covers SLAs but not structural health | [SLA Theatre](#sla-theatre) | [P09 Carrying Capacity Monitors](../patterns/p09-carrying-capacity-monitors/) |
| Incidents cascade; blast radius always larger than expected | [Invisible Blast Radius](#invisible-blast-radius) | [P11 Cascade Risk Detectors](../patterns/p11-cascade-risk-detectors/) |
| Circuit breakers exist but cascade still happens | [Circuit Breaker Theatre](#circuit-breaker-theatre) | [P11 Cascade Risk Detectors](../patterns/p11-cascade-risk-detectors/) |
| Tech debt sprints followed by immediate re-accumulation | [Debt Sprint Cycle](#debt-sprint-cycle) | [P14 Regenerative Refactoring](../patterns/p14-regenerative-refactoring/) |
| Improvement work happens in engineers' own time | [Improvement as Overtime](#improvement-as-overtime) | [P14 Regenerative Refactoring](../patterns/p14-regenerative-refactoring/) |
| Experimental services running permanently in production | [Infinite PoC](#infinite-poc) | [P13 Pioneer Service Incubators](../patterns/p13-pioneer-service-incubators/) |
| No protected time to experiment; everything is feature delivery | [Unfunded Mandate](#unfunded-mandate) | [P13 Pioneer Service Incubators](../patterns/p13-pioneer-service-incubators/) |
| Technology diversity growing without strategic intent | [Accidental Zoo](#accidental-zoo) | [P20 Biodiversity Index](../patterns/p20-biodiversity-index/) |
| Entire platform on a single vendor | [Monoculture Risk](#monoculture-risk) | [P20 Biodiversity Index](../patterns/p20-biodiversity-index/) |
| APIs with no documentation of what depends on them | [Undocumented Dependency Weight](#undocumented-dependency-weight) | [P07 Nutrient Flow](../patterns/p07-nutrient-flow/) |
| Services doing overlapping jobs; unclear who owns what | [Niche Overlap](#niche-overlap) | [P05 Niche Partitioning](../patterns/p05-niche-partitioning/) |
| Domain boundaries that exist in diagrams but not in code | [Cosmetic Boundary](#cosmetic-boundary) | [P04 Edge Effect Zones](../patterns/p04-edge-effect-zones/) |
| Schema drift discovered in production, not before | [Schema Blindness](#schema-blindness) | [P03 Symbiotic Contracts](../patterns/p03-symbiotic-contracts/) |
| Slow, invisible degradation nobody notices until it's serious | [Boiling Frog](#boiling-frog) | [P12 Phenological Drift Alerts](../patterns/p12-phenological-drift-alerts/) |

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
