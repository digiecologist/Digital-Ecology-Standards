# adaptive capacity score calculator.md

> **Step-by-step guide to calculating your Adaptive Capacity (AC) score.**
> Time required: 2–3 hours for a first reading. 30–60 minutes for quarterly updates.

---

## What you are measuring

Adaptive Capacity (AC) is a 0–100 score that tells you how well your organisation can respond when conditions change — new regulation, new competitor, shifting technology, market pressure. It is a **leading indicator**: it shows you where you are heading, not just where you have been.

It has three dimensions:

| Dimension | What it asks | Weight in final score |
|---|---|---|
| **TAC** — Technology Adaptability | Can your architecture actually change? | 40% |
| **OAC** — Organisational Adaptability | Can your teams respond when it needs to? | 35% |
| **OpAC** — Operational Adaptability | Can you ship changes reliably? | 25% |

Each dimension is made up of four sub-scores. You score each sub-score, combine them into a dimension score, then combine the three dimension scores into your final AC.

---

## The final formula

```
AC = ∛(T-AC × O-AC × Op-AC)
```

This is a **geometric mean**, not an average. That means a very low score in any one dimension drags the whole number down even if the others are high. This is intentional. It reflects Liebig's Law from ecology: growth is determined by the scarcest resource, not the most abundant.

> A TAC of 85, OAC of 80, and OpAC of 25 gives an AC of **54** — not 63.
> The weakest link sets the ceiling.

---

## Interpreting your score

| Score  | What it means |
|---|---|
| **80–100** | Change is your operating mode. Strong in all three dimensions. |
| **60–79** | Good foundation. You can evolve with deliberate effort. |
| **40–59** | Moderate stress. Some dimensions are blocking you. |
| **20–39** | Significant structural risk. One major shift could break things. |
| **0–19** | Critical. Start with the SCARS diagnostic before anything else. |

---

## Step 1 — Score TAC (Technology Adaptability)

**Formula:**
```
TAC = (Diversity × 0.25) + (Automation × 0.25) + (Observability × 0.30) + (Coupling × 0.20)
```

*Why these weights? Observability gets the highest weight — you cannot improve what you cannot see. Diversity and Automation are equal. Coupling is weighted lower because it is partially captured in the others.*

---

### TAC Dimension 1: Diversity (options and resilience)

Score each component 0–100, then apply the formula.

**1.1 — Capability Coverage** (40% of Diversity)
How many critical capabilities have at least two viable options?

| Score | Situation |
|---|---|
| 90–100 | All critical capabilities have alternatives |
| 60–80 | Most do; a few single points of failure |
| 30–50 | Several critical capabilities with no alternatives |
| 0–20 | Most capabilities locked to one provider or approach |

**1.2 — Vendor Risk** (35% of Diversity)
What proportion of your critical systems are single-vendor with high switching cost?

| Score | Situation |
|---|---|
| 90–100 | Designed for replaceability; most vendors abstractable |
| 60–80 | Some abstraction; switching is possible but effortful |
| 30–50 | Significant vendor lock-in in non-critical areas |
| 0–20 | Core systems locked in; switching would be a major project |

**1.3 — Pattern Diversity** (25% of Diversity)
Do you have multiple patterns for solving similar problems, or is everything solved the same way?

| Score | Situation |
|---|---|
| 80–100 | Healthy mix of patterns appropriate to the problem |
| 50–70 | Some variation; one dominant approach |
| 20–40 | One pattern applied everywhere regardless of fit |
| 0–10 | Single pattern; significant misfit in several areas |

```
Diversity = (Capability Coverage × 0.40) + (Vendor Risk × 0.35) + (Pattern Diversity × 0.25)
```

---

### TAC Dimension 2: Automation (speed when conditions shift)

**2.1 — CI/CD Coverage**
What percentage of services have automated build, test, and deploy pipelines?

| Score | Situation |
|---|---|
| 90–100 | >90% automated end-to-end |
| 60–80 | Most services automated; some manual steps remain |
| 30–50 | Partial automation; many manual gates |
| 0–20 | Mostly manual; automation is the exception |

**2.2 — Test Automation**
What proportion of your system is covered by automated tests (unit, integration, contract)?

| Score | Situation |
|---|---|
| 90–100 | High coverage, fast feedback |
| 60–80 | Good coverage in most areas |
| 30–50 | Patchy; some critical paths untested |
| 0–20 | Low coverage; changes frequently cause surprises |

**2.3 — Infrastructure as Code**
Is infrastructure defined and versioned in code, or managed by hand?

| Score | Situation |
|---|---|
| 90–100 | All infrastructure in version-controlled code |
| 60–80 | Most infrastructure coded; some exceptions |
| 30–50 | Mixed; drift between code and actual state is common |
| 0–20 | Largely manual; rebuilding from scratch would take weeks |

```
Automation = (CI/CD × 0.40) + (Test Automation × 0.35) + (Infrastructure as Code × 0.25)
```

---

### TAC Dimension 3: Observability (can you see what is happening?)

**3.1 — Distributed Tracing**
Can you follow a single request across multiple services end-to-end?

| Score | Situation |
|---|---|
| 90–100 | Full tracing across all services |
| 60–80 | Most paths covered; some gaps in legacy services |
| 30–50 | Partial; you can see into some services but lose the thread |
| 0–20 | No distributed tracing; problems surface as mystery errors |

**3.2 — Metrics and Alerting**
Are the right signals being collected, and do alerts fire before users notice?

| Score | Situation |
|---|---|
| 90–100 | Proactive alerting; SLOs in place and tracked |
| 60–80 | Good coverage; some reactive alerts, some SLOs |
| 30–50 | Basic metrics; alerting is reactive; incidents often user-reported |
| 0–20 | Flying blind; no meaningful alerting |

**3.3 — Schema and Contract Visibility**
Do you know what each service expects and produces? Are contracts enforced?

| Score | Situation |
|---|---|
| 90–100 | Schema registry in place; contracts tested in pipeline |
| 60–80 | Documentation exists; some contract testing |
| 30–50 | Informal understanding; drift common |
| 0–20 | No visibility into contracts; integration failures are common |

```
Observability = (Distributed Tracing × 0.35) + (Metrics & Alerting × 0.40) + (Schema Visibility × 0.25)
```

---

### TAC Dimension 4: Coupling (can teams move independently?)

**4.1 — Deployment Independence**
Can a team deploy their service without coordinating with other teams?

| Score | Situation |
|---|---|
| 90–100 | Teams deploy independently; no shared release trains |
| 60–80 | Mostly independent; occasional cross-team coordination needed |
| 30–50 | Frequent coordination required; some shared deployment cycles |
| 0–20 | Coupled deployments; releases require multi-team sign-off |

**4.2 — Data Coupling**
Do services share databases or data stores directly?

| Score | Situation |
|---|---|
| 90–100 | Each service owns its data; well-defined API boundaries |
| 60–80 | Some data ownership; a few shared stores in legacy areas |
| 30–50 | Common databases shared between multiple services |
| 0–20 | Highly shared data; changes to schema require multi-team negotiation |

**4.3 — Synchronous Dependency Depth**
How many synchronous hops does your most critical path require?

| Score | Situation |
|---|---|
| 90–100 | Shallow chains; async-first design |
| 60–80 | Some depth; mostly manageable |
| 30–50 | Long synchronous chains; cascading failures are common |
| 0–20 | Deep, tightly coupled chains; one failure brings others down |

```
Coupling = (Deployment Independence × 0.40) + (Data Coupling × 0.35) + (Sync Depth × 0.25)
```

---

### TAC calculation

```
TAC = (Diversity × 0.25) + (Automation × 0.25) + (Observability × 0.30) + (Coupling × 0.20)
```

| | Score |
|---|---|
| Diversity | _____ |
| Automation | _____ |
| Observability | _____ |
| Coupling | _____ |
| **TAC total** | **_____** |

---

## Step 2 — Score O-AC (Organisational Adaptability)

**Formula:**
```
OAC = (Team Autonomy × 0.30) + (Capability Distribution × 0.25) + (Flow Efficiency × 0.30) + (Experimentation Safety × 0.15)
```

---

### OAC Dimension 1: Team Autonomy

**1.1 — Decision-Making Speed**
How long does it take a team to make and act on a routine architectural or product decision?

| Score | Situation |
|---|---|
| 90–100 | Teams decide and act within a sprint; no external approval needed |
| 60–80 | Most decisions are local; some require escalation |
| 30–50 | Significant approval overhead; most changes need sign-off |
| 0–20 | Central control; teams cannot move without committee approval |

**1.2 — Cross-team Coordination Overhead**
What proportion of a team's time is spent coordinating with other teams rather than building?

| Score | Situation |
|---|---|
| 90–100 | Less than 10% coordination overhead |
| 60–80 | 10–25% — manageable but notable |
| 30–50 | 25–50% — teams spend more time coordinating than shipping |
| 0–20 | More than 50% — coordination is the primary activity |

**1.3 — Cognitive Load**
Can teams hold the full mental model of their domain? Or are they responsible for too much?

| Score | Situation |
|---|---|
| 90–100 | Teams have clear domain ownership; bounded responsibility |
| 60–80 | Manageable load; some blurry edges |
| 30–50 | Stretched across multiple domains; context-switching is constant |
| 0–20 | Overwhelmed; no clear ownership; everything is everyone's problem |

```
Team Autonomy = (Decision Speed × 0.40) + (Coordination Overhead × 0.35) + (Cognitive Load × 0.25)
```

---

### O-AC Dimension 2: Capability Distribution

**2.1 — Knowledge Bus Factor**
If your three most critical people left tomorrow, how much capability would be gone?

| Score | Situation |
|---|---|
| 90–100 | Knowledge is distributed; no single person is irreplaceable |
| 60–80 | Some key dependencies; most knowledge is shared |
| 30–50 | Several critical individuals; their absence causes real disruption |
| 0–20 | Extreme concentration; the organisation cannot function without specific people |

**2.2 — Skill Range**
Do teams have the full range of skills needed to deliver end-to-end?

| Score | Situation |
|---|---|
| 90–100 | Cross-functional teams with all skills to design, build, run |
| 60–80 | Most skills present; occasional handoffs to specialists |
| 30–50 | Heavy reliance on specialist teams; multiple handoffs per feature |
| 0–20 | Siloed by skill; every feature crosses many team boundaries |

```
Capability Distribution = (Bus Factor × 0.55) + (Skill Range × 0.45)
```

---

### O-AC Dimension 3: Flow Efficiency

**3.1 — Lead Time**
From idea to production, how long does a typical feature take?

| Score | Situation |
|---|---|
| 90–100 | Less than 1 week |
| 60–80 | 1–4 weeks |
| 30–50 | 1–3 months |
| 0–20 | More than 3 months |

**3.2 — Wait Time vs Work Time**
What proportion of a feature's journey is active work vs waiting (approvals, queues, handoffs)?

| Score | Situation |
|---|---|
| 90–100 | More than 50% active work time |
| 60–80 | 25–50% active work time |
| 30–50 | 10–25% active work time |
| 0–20 | Less than 10% — mostly waiting |

**3.3 — Batch Size**
How large is a typical deployment? Small batches reduce risk and speed recovery.

| Score | Situation |
|---|---|
| 90–100 | Very small batches; multiple deploys per day |
| 60–80 | Weekly or fortnightly releases |
| 30–50 | Monthly releases |
| 0–20 | Large quarterly releases; high-risk deployments |

```
Flow Efficiency = (Lead Time × 0.40) + (Wait Time × 0.35) + (Batch Size × 0.25)
```

---

### OAC Dimension 4: Experimentation Safety

**4.1 — Psychological Safety**
Do people feel safe raising concerns, trying new approaches, and being honest about failures?

| Score | Situation |
|---|---|
| 90–100 | Experimentation is encouraged; failure is a learning event |
| 60–80 | Generally safe; some cultural caution in certain areas |
| 30–50 | Risk-averse; people avoid raising problems for fear of blame |
| 0–20 | Fear culture; mistakes are punished; no one speaks up |

**4.2 — Post-incident Learning**
After something goes wrong, does the organisation learn from it and improve?

| Score | Situation |
|---|---|
| 90–100 | Blameless post-mortems; systemic fixes actioned within a sprint |
| 60–80 | Reviews happen; some follow-through |
| 30–50 | Incident reviews are blame-focused or not actioned |
| 0–20 | No structured learning; same failures recur |

```
Experimentation Safety = (Psychological Safety × 0.60) + (Post-incident Learning × 0.40)
```

---

### OAC calculation

```
OAC = (Team Autonomy × 0.30) + (Capability Distribution × 0.25) + (Flow Efficiency × 0.30) + (Experimentation Safety × 0.15)
```

| | Score |
|---|---|
| Team Autonomy | _____ |
| Capability Distribution | _____ |
| Flow Efficiency | _____ |
| Experimentation Safety | _____ |
| **O-AC total** | **_____** |

---

## Step 3 — Score OpAC (Operational Adaptability)

**Formula:**
```
OpAC = (Change Resilience × 0.35) + (Response Capability × 0.30) + (Evolution Options × 0.20) + (Regenerative Capacity × 0.15)
```

*Why these weights? Change Resilience is highest — if changes fail, nothing else matters. Response Capability is next — speed determines whether you adapt in time. Evolution Options enable experimentation. Regenerative Capacity is foundational but its effects are indirect.*

---

### OpAC Dimension 1: Change Resilience

**1.1 — Deployment Success Rate**
What percentage of deployments complete without causing an incident or requiring rollback?

| Score | Situation |
|---|---|
| 90–100 | >95% success rate |
| 60–80 | 80–95% success rate |
| 30–50 | 60–80% — frequent partial failures or hotfixes |
| 0–20 | Less than 60% — deployments are high-risk events |

**1.2 — Change Failure Rate (DORA)**
Of deployments that cause incidents, what percentage require emergency patching or rollback?

| Score | Situation |
|---|---|
| 90–100 | Less than 5% failure rate (Elite/High DORA) |
| 60–80 | 5–15% |
| 30–50 | 15–30% |
| 0–20 | More than 30% |

**1.3 — Time to Restore (DORA MTTR)**
When something breaks, how long until service is restored?

| Score | Situation |
|---|---|
| 90–100 | Less than 1 hour |
| 60–80 | 1–24 hours |
| 30–50 | 1–7 days |
| 0–20 | More than 1 week |

```
Change Resilience = (Deployment Success × 0.35) + (Change Failure Rate × 0.35) + (MTTR × 0.30)
```

---

### OpAC Dimension 2: Response Capability

**2.1 — Deployment Frequency (DORA)**
How often do you deploy to production?

| Score | Situation |
|---|---|
| 90–100 | Multiple times per day |
| 60–80 | Once per day to once per week |
| 30–50 | Once per week to once per month |
| 0–20 | Less than once per month |

**2.2 — Time to Detect**
How quickly do you know when something is wrong in production?

| Score | Situation |
|---|---|
| 90–100 | Automated detection in minutes |
| 60–80 | Detection within an hour |
| 30–50 | Hours to days; often user-reported |
| 0–20 | No systematic detection; problems surface in support tickets |

**2.3 — Incident Response Capacity**
When an incident occurs, do you have the people and process to respond without everything stopping?

| Score | Situation |
|---|---|
| 90–100 | Trained on-call rotation; runbooks in place; clear escalation paths |
| 60–80 | Generally works; some gaps in coverage |
| 30–50 | Ad-hoc; the same few people respond to everything |
| 0–20 | No formal process; incidents cause widespread disruption |

```
Response Capability = (Deployment Frequency × 0.40) + (Time to Detect × 0.35) + (Incident Response × 0.25)
```

---

### OpAC Dimension 3: Evolution Options

**3.1 — Feature Flag Coverage**
Can you turn features on and off in production without a deployment?

| Score | Situation |
|---|---|
| 90–100 | Feature flags used systematically; dark launches are routine |
| 60–80 | Flags used in most critical areas |
| 30–50 | Some flags; not standard practice |
| 0–20 | No feature flags; every change is a deploy |

**3.2 — Rollback Speed**
How quickly can you revert a bad deployment?

| Score | Situation |
|---|---|
| 90–100 | Automated rollback in minutes |
| 60–80 | Manual rollback possible within an hour |
| 30–50 | Rollback takes hours and requires coordination |
| 0–20 | Rollback is not reliably possible; forward-fix only |

**3.3 — Data Reversibility**
If a migration or data change causes problems, can you reverse it?

| Score | Situation |
|---|---|
| 90–100 | Migrations are backward-compatible; data changes are reversible |
| 60–80 | Most changes reversible with some effort |
| 30–50 | Some migrations are one-way; careful coordination required |
| 0–20 | Locked in; huge switching costs once changes are applied |

**3.4 — Architectural Reversibility**
Are architectural decisions made in a way that allows them to be changed?

| Score | Situation |
|---|---|
| 90–100 | Designed for replaceability; strong service boundaries |
| 60–80 | Moderate effort to switch; some abstractions in place |
| 30–50 | Switching is possible but expensive |
| 0–20 | Locked in; significant re-engineering required to change direction |

```
Evolution Options = (Feature Flags × 0.30) + (Rollback Speed × 0.35) + (Data Reversibility × 0.20) + (Architectural Reversibility × 0.15)
```

---

### OpAC Dimension 4: Regenerative Capacity

*An ecosystem running at 100% capacity has no energy for recovery or growth. This dimension measures your slack.*

**4.1 — Team Utilisation**
What is your average team utilisation? (Planned work as a percentage of capacity)

| Score | Situation |
|---|---|
| 100 | Less than 70% utilisation — deliberate slack |
| 65 | 70–85% utilisation |
| 30 | 85–95% utilisation |
| 0 | More than 95% — no capacity for anything unplanned |

**4.2 — Infrastructure Headroom**
How close to capacity are your production systems running?

| Score | Situation |
|---|---|
| 100 | Less than 50% capacity used — deliberate headroom |
| 70 | 50–75% used |
| 35 | 75–90% used |
| 0 | More than 90% used — one spike causes an incident |

**4.3 — On-Call Burden**
What proportion of engineering time goes to firefighting vs building?

| Score | Situation |
|---|---|
| 100 | Less than 15% firefighting |
| 65 | 15–30% firefighting |
| 30 | 30–50% firefighting |
| 0 | More than 50% firefighting |

**4.4 — Innovation Time**
Is there dedicated, protected time for improvement, learning, and experimentation?

| Score | Situation |
|---|---|
| 100 | 20%+ allocated to learning and improvement |
| 65 | 10% allocated |
| 30 | Ad-hoc improvement when there is time |
| 0 | No innovation time; everything is delivery |

```
Regenerative Capacity = (Team Utilisation × 0.35) + (Infrastructure Headroom × 0.25) + (On-Call Burden × 0.25) + (Innovation Time × 0.15)
```

---

### OpAC calculation

```
OpAC = (Change Resilience × 0.35) + (Response Capability × 0.30) + (Evolution Options × 0.20) + (Regenerative Capacity × 0.15)
```

| | Score |
|---|---|
| Change Resilience | _____ |
| Response Capability | _____ |
| Evolution Options | _____ |
| Regenerative Capacity | _____ |
| **Op-AC total** | **_____** |

---

## Step 4 — Calculate your AC score

```
AC = ∛(T-AC × O-AC × Op-AC)
```

| | Score |
|---|---|
| TAC | _____ |
| OAC | _____ |
| OpAC | _____ |
| **AC (cube root of T-AC × O-AC × Op-AC)** | **_____** |

Most calculators: `(TAC * OAC * OpAC) ^ (1/3)`

---

## Step 5 — Identify your limiting resource

Your lowest-scoring dimension is your limiting resource. This is where to focus first.

Liebig's Law: improving your strongest dimension has diminishing returns. Fixing your weakest has the highest impact on your overall AC score.

| Limiting Resource | What to do first |
|---|---|
| **TAC is lowest** | Start with Coupling and Observability. See P01 (Mycelial Mesh) and P02 (Keystone Interface Pattern). |
| **OAC is lowest** | Start with Team Autonomy and Flow Efficiency. See the SCARS diagnostic and P03 (Succession Stage Routing). |
| **OpAC is lowest** | Start with Change Resilience and Regenerative Capacity. See P09 (Carrying Capacity Monitors) and P11 (Cascade Risk Detectors). |

---

## Step 6 — Track over time

A single score tells you where you are. A trend tells you which direction you are heading.

Take a reading at least quarterly. Record:

- Date
- TAC, OAC, OpAC, and AC
- The limiting resource
- What you changed since the last reading
- Whether the trend is rising, stable, or falling

A rising AC score means the ecosystem is getting healthier. A flat score despite active investment means the fitness functions or scoring criteria may be too lenient, or effort is going into the wrong dimension.

---

## Connections to existing frameworks

| AC dimension | Maps to |
|---|---|
| TAC Coupling | DORA "loosely coupled architecture"; Team Topologies stream-aligned teams |
| TAC Diversity | Wardley Mapping — Genesis → Commodity evolution; avoiding monoculture |
| TAC Observability | SRE SLOs and error budgets; DORA MTTR |
| OAC Flow Efficiency | DORA lead time for changes; Architecture for Flow (Susanne Kaiser) |
| OAC Team Autonomy | Team Topologies cognitive load; Inverse Conway Manoeuvre |
| OAC Capability Distribution | SCARS — Responsibilities and Separation (Ruth Malan) |
| OpAC Change Resilience | DORA change failure rate; deployment frequency |
| OpAC Response Capability | DORA MTTR; SRE error budgets |
| OpAC Evolution Options | Evolutionary Architecture fitness functions (Ford, Parsons, Kua) |

---

*Part of the Ecological Engineering Standards repository.*
*See the pattern library for the patterns that move each dimension.*
*See scars-diagnostic/README.md for diagnosis when your score is below 40.*
