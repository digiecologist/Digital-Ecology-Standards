# Framework Connections

The Ecological Engineering patterns do not exist in isolation. Each one connects to established frameworks and methodologies. This document maps those connections explicitly.

---

## Wardley Mapping

**The connection:** Wardley Mapping provides the evolution axis (Genesis → Custom → Product → Commodity) that several patterns use directly. P20 (Biodiversity Index) uses Wardley stages to contextualise diversity choices. P03 (Symbiotic Contracts) maps to how interfaces evolve along the same axis.

**How they complement each other:** Wardley maps tell you *where* your capabilities sit. The ecological patterns tell you *what to do about it* — which structural choices are appropriate for each stage.

Reference: [wardleymaps.com](https://wardleymaps.com)

---

## Domain-Driven Design

**The connection:** Bounded contexts map directly to P05 (Niche Partitioning). Anti-corruption layers map to P02 (Keystone Interface). Domain events are the primary content of the P01 (Mycelial Mesh).

**How they complement each other:** DDD provides the language for defining boundaries. The ecological patterns provide the structural and governance rules for what happens at those boundaries.

---

## Team Topologies

**The connection:** Stream-aligned teams correspond to services with clear niche partitioning (P05). Platform teams own keystone interfaces (P02) and the mesh infrastructure (P01). Enabling teams support succession gate transitions (P16).

**How they complement each other:** Team Topologies defines the human structure. The ecological patterns define the technical structure that supports it — the Inverse Conway Manoeuvre in practice.

Reference: [teamtopologies.com](https://teamtopologies.com)

---

## Evolutionary Architecture (Ford, Parsons, Kua)

**The connection:** Fitness functions from this repository are designed to drop directly into an Evolutionary Architecture pipeline. The coupling guard (P01), observability coverage guard (P02/P09), and schema drift check (P03) are all fitness functions in the Evolutionary Architecture sense.

**How they complement each other:** Evolutionary Architecture provides the pipeline and governance framework. The ecological patterns provide the specific fitness functions and the interpretive framework for what the results mean.

Reference: [evolutionaryarchitecture.com](https://evolutionaryarchitecture.com)

---

## Architecture for Flow (Susanne Kaiser)

**The connection:** Flow efficiency (P06) and the reduction of cognitive load across team boundaries maps directly to Kaiser's work on fast flow. The migration paths in this repository address the same structural blockers — handoffs, coordination overhead, deployment coupling.

Reference: [architectureforflow.com](https://architectureforflow.com)

---

## DORA / SRE

**The connection:** The fitness functions in this repository target the four DORA metrics directly. Deployment frequency and lead time improve when P01 (Mycelial Mesh) and P14 (Regenerative Refactoring) are in place. Change failure rate and recovery time improve with P09 (Carrying Capacity Monitors) and P11 (Cascade Risk Detectors).

---

## SCARS (Ruth Malan, Bredemeyer Consulting)

**The connection:** SCARS (Separation, Cohesion, Abstraction, Responsibilities, Simplify) is the diagnostic front door for the entire pattern library. The [SCARS diagnostic](../pattern-library/scars-diagnostic/) maps each SCARS check to the patterns that address it, and provides CI/CD fitness functions for each check.

Reference: [ruthmalan.com](https://ruthmalan.com)
