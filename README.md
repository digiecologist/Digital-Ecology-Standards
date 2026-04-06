# Ecological Engineering Standards

20 patterns for building adaptive digital ecosystems.
Based on *Digital Ecosystems, Naturally Resilient* by Jenny Wilson.

---

## What this is

Software systems behave like ecosystems. They need diversity, clear boundaries, healthy flow, and the capacity to adapt. When those properties are absent, you get the symptoms every engineering team recognises: cascading failures, deployment fear, teams that cannot ship independently, and codebases that get harder to change the longer they exist.

This repository provides 20 concrete patterns — each with working code, automated fitness functions, and diagnostic tools — for engineering teams who want to fix those problems.

The ecological framing is not decorative. It explains *why* each pattern works, which helps you apply it correctly in situations the documentation does not cover.

---

## How to navigate this repository

| I want to... | Start here |
|---|---|
| Understand the framework | [docs/introduction.md](docs/introduction.md) |
| Diagnose a problem I am seeing right now | [pattern-library/scars-diagnostic/](pattern-library/scars-diagnostic/) |
| Browse all 20 patterns | [pattern-library/patterns/](pattern-library/patterns/) |
| Measure my system's architectural health | [pattern-library/ac-scoring/](pattern-library/ac-scoring/) |
| Migrate from a tangled, hard-to-change system | [migration-paths/](migration-paths/) |
| See how this connects to other frameworks | [docs/framework-connections.md](docs/framework-connections.md) |

---

## Start here if you are diagnosing a problem

| Symptom you are seeing | Where to go |
|---|---|
| Services changing together unexpectedly | [P01 Mycelial Mesh](pattern-library/patterns/p01-mycelial-mesh/) |
| One service breaking everything else | [P11 Cascade Risk Detectors](pattern-library/patterns/p11-cascade-risk-detectors/) |
| Integration points breaking on schema change | [P02 Keystone Interface](pattern-library/patterns/p02-keystone-interface/) |
| Teams coordinating constantly just to ship | [P04 Edge Effect Zones](pattern-library/patterns/p04-edge-effect-zones/) |
| Incidents cascading unpredictably | [P11 Cascade Risk Detectors](pattern-library/patterns/p11-cascade-risk-detectors/) |
| You want a full structural health check | [SCARS Diagnostic](pattern-library/scars-diagnostic/) |

---

## The 20 patterns — quick reference

See [pattern-library/README.md](pattern-library/README.md) for the full list.

**Build first** — solve problems engineers recognise today:
> P01 Mycelial Mesh · P02 Keystone Interface · P09 Carrying Capacity Monitors · P11 Cascade Risk Detectors · P13 Pioneer Service Incubators · P14 Regenerative Refactoring · P20 Biodiversity Index

**Build second** — higher value, builds on the foundation above:
> P03 Symbiotic Contracts · P07 Nutrient Flow · P10 Biodiversity Index Checks · P15 Symbiotic Dependency Design · P16 Succession Gates · P18 Regenerative Cycles

**Build third** — powerful, but require cultural change or higher effort:
> P04 Edge Effect Zones · P05 Niche Partitioning · P06 Knowledge Composting · P08 Trophic Decomposition · P12 Phenological Drift Alerts · P17 Fitness Landscape Visualisation · P19 Minimum Viable Experiment

---

## Connected frameworks

These patterns sit alongside and extend:
- **Wardley Mapping** — the patterns tell you what to build; Wardley maps tell you the evolution stage
- **Domain-Driven Design** — bounded contexts and anti-corruption layers map directly to several patterns
- **Team Topologies** — patterns reinforce stream-aligned, platform, and enabling team structures
- **Evolutionary Architecture** — fitness functions from this repo drop into any evolutionary architecture pipeline
- **Architecture for Flow** (Susanne Kaiser) — shared emphasis on flow efficiency and reducing cognitive load
- **DORA / SRE** — fitness functions target the same deployment frequency, lead time, and recovery metrics
- **SCARS** (Ruth Malan) — the diagnostic front door for the entire pattern library

See [docs/framework-connections.md](docs/framework-connections.md) for detail.

---

*Part of the Digital Ecosystems, Naturally Resilient project.*
