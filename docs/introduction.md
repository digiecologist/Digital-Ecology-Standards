# Introduction to Ecological Engineering

## The core idea

Every engineering team, at some point, ends up with a system that is harder to change than it used to be. Deployments take longer. Incidents cascade. A small change in one place breaks something unexpected somewhere else. Teams that used to ship independently now need to coordinate every release.

This is not a failure of effort or skill. It is a structural problem. The system has lost the properties that made it easy to change.

Living ecosystems face the same challenge at much larger scale — and they solve it. A forest does not have a central controller managing every interaction. Yet it adapts to seasonal change, recovers from disturbance, and maintains health across thousands of interdependent species. It does this through a set of structural properties: clear boundaries, distributed communication, redundancy without fragility, and the capacity to evolve.

The Ecological Engineering framework applies those same structural properties to software systems.

---

## The five categories of pattern

**Structural / Architectural** — how services relate to each other. P01, P02, P03, P04, P05.

**Flow and Nutrient Cycling** — how value and information move through the system. P06, P07, P08.

**Warning Signs and Triggers** — how the system surfaces its own health problems before they become crises. P09, P10, P11.

**Adaptive and Regenerative** — how the system builds its capacity to change over time. P12, P13, P14, P15, P16.

**In-built Nudges and Behavioural Design** — how the system makes good architectural decisions the path of least resistance. P17, P18, P19, P20.

---

## The Adaptive Capacity score

The AC score is the single number that summarises ecosystem health. It runs from 0 to 100.

| Component | Abbreviation | What it measures | Weight |
|---|---|---|---|
| Technical Adaptive Capacity | T-AC | Coupling, observability, deployment independence | 40% |
| Organisational Adaptive Capacity | O-AC | Team structure, cognitive load, flow efficiency | 35% |
| Operational Adaptive Capacity | Op-AC | Recovery speed, incident patterns, deployment frequency | 25% |

A score above 70 indicates a healthy, adaptable ecosystem. Below 40 indicates a system under significant structural stress.

See [pattern-library/ac-scoring/](../pattern-library/ac-scoring/) for how to measure your score.

---

## How to use this framework

**Diagnosing a problem:** start with the [SCARS diagnostic](../pattern-library/scars-diagnostic/).

**Planning new work:** start with the [pattern library overview](../pattern-library/README.md). Use the build priority tags to sequence your implementation.

**Measuring health over time:** use the [AC scoring guide](../pattern-library/ac-scoring/) and the fitness functions inside each pattern folder.

**Migrating from a tangled system:** start with the [migration paths guide](../migration-paths/).

---

## What this is not

This framework does not replace Wardley Mapping, DDD, or Team Topologies — it works alongside them. See [docs/framework-connections.md](framework-connections.md) for the explicit connections.
