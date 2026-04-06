# Pattern Library All 20 Patterns

20 ecological engineering patterns for building adaptive digital ecosystems.

---

## How to choose where to start

Run the [SCARS diagnostic](scars-diagnostic/) first if you are starting from a problem. It maps what you are seeing to which pattern to apply.

| Priority | Patterns | When to use them |
|---|---|---|
| **BUILD FIRST** | P01, P02, P09, P11, P13, P14, P20 | Solve problems engineers recognise today. Moderate implementation complexity. |
| **BUILD SECOND** | P03, P07, P10, P15, P16, P18 | Higher value, but build on the foundation patterns. Require P01 to be in place. |
| **BUILD THIRD** | P04, P05, P06, P08, P12, P17, P19 | Genuinely powerful but require cultural change or higher implementation effort. |

---

## Structural / Architectural

| # | Pattern | Summary | Priority |
|---|---|---|---|
| P01 | [Mycelial Mesh](patterns/p01-mycelial-mesh/) | Services communicate through shared flows, not direct calls | BUILD FIRST |
| P02 | [Keystone Interface](patterns/p02-keystone-interface/) | Protect the few integration points that hold everything else up | BUILD FIRST |
| P03 | [Symbiotic Contracts](patterns/p03-symbiotic-contracts/) | Schema agreements that protect both producer and consumer | BUILD SECOND |
| P04 | [Edge Effect Zones](patterns/p04-edge-effect-zones/) | Design domain boundaries as transition zones, not hard walls | BUILD THIRD |
| P05 | [Niche Partitioning](patterns/p05-niche-partitioning/) | Each service occupies a clearly defined, non-overlapping role | BUILD THIRD |

## Flow and Nutrient Cycling

| # | Pattern | Summary | Priority |
|---|---|---|---|
| P06 | [Knowledge Composting](patterns/p06-knowledge-composting/) | Dead code feeds future decisions — nothing is wasted | BUILD THIRD |
| P07 | [Nutrient Flow](patterns/p07-nutrient-flow/) | APIs document not just what they do, but what degrades if they stop | BUILD SECOND |
| P08 | [Trophic Decomposition](patterns/p08-trophic-decomposition/) | Each layer consumes only what it needs and passes on enriched value | BUILD THIRD |

## Warning Signs and Triggers

| # | Pattern | Summary | Priority |
|---|---|---|---|
| P09 | [Carrying Capacity Monitors](patterns/p09-carrying-capacity-monitors/) | Alert before collapse, not after it | BUILD FIRST |
| P10 | [Biodiversity Index Checks](patterns/p10-biodiversity-index-checks/) | Score your landscape for dangerous monocultures | BUILD SECOND |
| P11 | [Cascade Risk Detectors](patterns/p11-cascade-risk-detectors/) | Find the hidden fault lines before they become incidents | BUILD FIRST |

## Adaptive and Regenerative

| # | Pattern | Summary | Priority |
|---|---|---|---|
| P12 | [Phenological Drift Alerts](patterns/p12-phenological-drift-alerts/) | Detect gradual drift before it becomes visible failure | BUILD THIRD |
| P13 | [Pioneer Service Incubators](patterns/p13-pioneer-service-incubators/) | A protected zone where new things can grow without threatening the stable ecosystem | BUILD FIRST |
| P14 | [Regenerative Refactoring](patterns/p14-regenerative-refactoring/) | Continuous small acts of renewal, not periodic big rewrites | BUILD FIRST |
| P15 | [Symbiotic Dependency Design](patterns/p15-symbiotic-dependency-design/) | Name the relationship. Eliminate the parasitic ones | BUILD SECOND |
| P16 | [Ecological Succession Gates](patterns/p16-succession-gates/) | Services earn their maturity level — they do not inherit it | BUILD SECOND |

## In-built Nudges and Behavioural Design

| # | Pattern | Summary | Priority |
|---|---|---|---|
| P17 | [Fitness Landscape Visualisation](patterns/p17-fitness-landscape/) | Show architects the landscape as it actually is | BUILD THIRD |
| P18 | [Regenerative Cycles](patterns/p18-regenerative-cycles/) | Build the improvement loop into the system, not as an afterthought | BUILD SECOND |
| P19 | [Minimum Viable Experiment](patterns/p19-minimum-viable-experiment/) | Make experimentation the default, not the exception | BUILD THIRD |
| P20 | [Biodiversity Index](patterns/p20-biodiversity-index/) | Measure and maintain the right level of diversity for your context | BUILD FIRST |

---

## Measuring health across the library

- [AC Scoring guide](ac-scoring/) — the single score that summarises overall health
- [SCARS Diagnostic](scars-diagnostic/) — the structural health check that runs before deployment
- [Antipattern Library](antipatterns/) — unhealthy failure modes and the patterns that fix them
- Individual pattern fitness functions in each pattern's `fitness-functions/` folder
