# Ecological Engineering Standards

20 patterns for building adaptive digital ecosystems.
Based on *Digital Ecosystems, Naturally Resilient* by Jenny Wilson.

---

## What this is

Software systems behave like ecosystems. They need diversity,
clear boundaries, nutrient flow, and the capacity to adapt.
When those properties are absent, you get the symptoms every
engineering team recognises: cascading failures, deployment fear,
teams that cannot ship independently, and codebases that get
harder to change the longer they exist.

This repository provides 20 concrete patterns — each with
working code, automated fitness functions, and diagnostic tools
— for engineering teams who want to fix those problems.

## How to navigate this repository

| I want to...                         | Start here                        |
|--------------------------------------|-----------------------------------|
| Understand the framework             | docs/introduction.md              |
| Diagnose a problem I am seeing now   | pattern-library/scars-diagnostic/ |
| Pick a pattern to implement          | pattern-library/patterns/         |
| Measure architectural health         | pattern-library/ac-scoring/       |
| Migrate from a big ball of mud       | migration-paths/                  |

## The 20 patterns at a glance

See [pattern-library/README.md](pattern-library/README.md) for the full list.

**Build first** (solves problems you recognise today):
P01 Mycelial Mesh · P02 Keystone Interface · P09 Flow Sensors
P11 Cascade Risk Detectors · P13 Symbiotic Versioning
P14 Canopy Cover Protocol · P20 Biodiversity Index

## Related frameworks

These patterns sit alongside and extend:
Wardley Mapping · Domain-Driven Design · Team Topologies
Evolutionary Architecture · Architecture for Flow
DORA/SRE · Ruth Malan's SCARS heuristics

See [docs/framework-connections.md](docs/framework-connections.md)

---

*Part of the Digital Ecosystems, Naturally Resilient project
