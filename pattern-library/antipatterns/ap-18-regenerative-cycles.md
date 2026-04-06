# AP-18 — Regenerative Cycles Antipatterns

**Pattern this relates to:** [P18 Regenerative Cycles](../patterns/p18-regenerative-cycles/)
**Category:** Succession and Scale
**TL;DR:** The system improves, but only in one direction — complexity accumulates and is never released. Or the improvement cycle exists but has no rhythm — it happens when someone thinks of it, not as a regular structural practice.

---

## The three ways this goes wrong

---

### AP-18-A: One-Way Ratchet

**What it is:** The system gets more complex over time. Features are added; features are never removed. Services are added; services are never retired. Data accumulates; old data is never archived. The ratchet only turns one way. Complexity is a one-way function: it can only increase.

**Sign:** Your service count has grown every quarter for three years. No service has ever been retired. Or: your codebase size has grown 50% in two years, but the feature set has only grown 20%.

**Why it happens:** Adding is visible and measurable. It appears on the roadmap, in the sprint plan, in user-facing features. Removing is invisible and feels risky. Every service in production has at least one team that believes it is valuable. Removal requires consensus and is politically hard. There is no removal budget in the roadmap.

**What the ratchet costs:**

```
Service inventory over 3 years:

Year 1:    15 services
           Total: 15

Year 2:    Add 6 services
           Retire 0 services
           Total: 21

Year 3:    Add 5 services
           Retire 0 services
           Total: 26

Operational cost:
  - On-call burden: +73% per team
  - Deployment coordination complexity: O(n) growth
  - Knowledge distribution: each new service is a new cognitive load
  - Observability burden: more services to monitor
  - Incident blast radius: more potential cascade points
  
Service retirement in 3 years: 0
Services that are candidates for retirement: 8

The system has become more fragile (more failure points) 
while becoming less capable per deployment (more coordination).
```

**The fix — P18 applied:** Set a target for the ratio of additions to removals. For every five services added, one is retired or merged. Retirement is treated as a success metric, not a failure. Track service count alongside feature velocity — make complexity visible as a constraint, not a side effect.

```yaml
# Regenerative target — balanced growth
architecture-targets:
  service-generation-rate: 4-6 new services per year
  service-retirement-rate: 1-2 services per year
  target-ratio: 4:1 additions to removals
  
  capacity-allocation:
    feature-development: 70%
    architectural-improvement: 20%
    technical-debt-retirement: 10%
    
  retirement-scheduling:
    cadence: quarterly
    candidates: services with traffic < p10 percentile
    decision: retire if no current consumer, or migrate consumers
```

**Validated reference:** [Lean principles](https://www.lean.org/explore-lean/what-is-lean/) — eliminating waste as a core principle. [Evolutionary Architecture](https://evolutionaryarchitecture.com) — architectural fitness functions that penalise growth without benefit. Coplien's "Feature Interactions" — system complexity as a constraining factor.

**SCARS lens:** Simplify — a one-way ratchet violates the Simplify principle. Systems that accumulate without release become progressively harder to reason about and change.

---

### AP-18-B: Renewal Without Rhythm

**What it is:** Improvement work happens, but only when someone remembers to do it, or only when it is forced by a crisis. There is no regular cadence — no quarterly architecture review, no monthly fitness function check, no sprint-level improvement allocation. Improvement is event-driven (a post-mortem triggers it, a customer incident forces it) rather than rhythm-driven (it happens on schedule regardless of events). The system improves unpredictably, degrades predictably.

**Sign:** Improvement spikes after incidents and flatlines between them. The AC score drops steadily for months, then recovers sharply after a crisis. The phrase "we should focus on tech debt" appears in retrospectives, but no allocation is made until the system breaks.

**Why it happens:** Improvement feels like it competes with feature delivery. In a system that is measured by features shipped, improvement loses. The only time improvement is prioritised is when it becomes so urgent that it blocks features. Waiting until then means improvement is reactive.

**What lack of rhythm produces:**

```
Architecture health and improvement activity timeline:

Month 1:   AC score: 68/100 (healthy)
           Improvement allocation: 0%
           Activity: feature velocity: high
           
Month 6:   AC score: 62/100 (degrading)
           Improvement allocation: 0%
           Activity: features continue
           
Month 12:  AC score: 54/100 (risky)
           Improvement allocation: 0%
           Activity: features continue, but latency complaints start
           
Month 14:  Incident: major cascade failure
           Post-mortem: "We should have been improving architecture"
           Improvement allocation: 50% (all hands on deck)
           
Month 16:  AC score: 66/100 (recovered)
           Improvement allocation: 5%
           Activity: feature velocity resumes
           
Month 20:  AC score: 55/100 (degrading again)
           Pattern repeats
           
The organization has a regenerative cycle, but it is:
  - Reactive (driven by crisis)
  - Expensive (full-team crisis response)
  - Disruptive (feature delivery stops)
  - Ineffective (improvement doesn't stick)
```

**The fix — P18 applied:** Set a recurring rhythm independent of events: quarterly AC score review, monthly fitness function threshold review, sprint-level improvement allocation. The rhythm is in the calendar before the need arises, not scheduled in response to it. Improvement happens on schedule, not on crisis.

```yaml
# Regenerative cycles — scheduled rhythm
improvement-rhythm:
  
  weekly:
    - Fitness function check (5 minutes)
    - Threshold violations reviewed in standup
    
  monthly:
    - Architecture review meeting
    - Fitness function results presented
    - One architectural decision to be made
    
  quarterly:
    - AC score detailed review
    - Service retirement/consolidation decision
    - Architectural fitness trends analysis
    - Fitness function thresholds reviewed and adjusted
    
  annually:
    - Strategic architecture review
    - Wardley map update
    - Migration path update (if local optimum detected)
    - Technology radar update (for Genesis-stage capabilities)

sprint-allocation:
  - 70% feature development
  - 15% architectural improvement (scheduled by weekly rhythm)
  - 10% technical debt retirement (scheduled by quarterly rhythm)
  - 5% operational improvements

key: The schedule is fixed. Improvement happens whether or not there is a crisis.
     Crisis does not create improvement spikes; it clarifies priorities within the existing allocation.
```

**Validated reference:** [Theory of Constraints](https://en.wikipedia.org/wiki/Theory_of_constraints) (Goldratt) — improvement cycles in manufacturing. [Kaizen](https://en.wikipedia.org/wiki/Kaizen) — continuous improvement as a rhythm, not an event. [Scrum](https://scrumguides.org/) — sprint retrospectives as a regular rhythm for improvement.

**SCARS lens:** Cohesion — renewal without rhythm means improvement work is disconnected from regular development. Improvement happens in a separate mode rather than being part of the normal operation rhythm.

---

### AP-18-C: Capacity Without Release

**What it is:** Improvement capacity is protected — the team does have 15% of sprint time for improvement — but the improvement work only ever adds new things: new tests, new alerts, new documentation, new observability. It never removes things. No feature flag is ever deleted. No endpoint is ever retired. No unused code path is ever pruned. The improvement work is additive, not regenerative.

**Sign:** Your improvement capacity is fully allocated, but you cannot point to anything that was removed or retired in the last three months.

**Why it happens:** Removing things feels like undoing work. Adding tests feels productive; removing untested code feels wasteful. The mental model is that improvement always means making things more robust, more observable, more defended — never making things simpler by removing parts.

**The cost:**

```
Improvement capacity allocation:

Available: 15% of sprint time

Current allocation:
  - Add tests for untested code: 40%
  - Add observability: 30%
  - Add documentation: 20%
  - Refactoring: 10%
  
Total: 100% (capacity fully allocated)

What's not in the allocation:
  - Remove feature flags that have been enabled for 2+ years: 0%
  - Retire deprecated API endpoints: 0%
  - Archive unused database tables: 0%
  - Delete dead code branches: 0%
  
System state after one year:
  - Test coverage: improved
  - Observability: improved
  - Documentation: improved
  - Codebase size: +18%
  - Deployment time: increased (more code to deploy)
  - System complexity: increased
  
The system is more tested but more complex. 
More observable but slower to change.
The improvements have made it harder to maintain.
```

**The fix — P18 applied:** Define improvement work to include removal explicitly. Retiring a service, removing a feature flag, deleting an unused endpoint, pruning dead code — these are improvement work. The PR that removes 500 lines without adding any is a valid use of improvement capacity. Track removal alongside addition.

```yaml
# Improvement capacity allocation — regenerative version
improvement-allocation:
  
  additive-improvements:
    - Add tests for untested critical paths: 7%
    - Add observability for blind spots: 6%
    - Add documentation for undocumented APIs: 4%
    total-additive: 17%
    
  regenerative-improvements:
    - Retire expired feature flags: 5%
    - Archive unused database data: 4%
    - Remove deprecated API endpoints: 3%
    - Delete dead code branches: 3%
    total-regenerative: 15%
    
  refactoring:
    - Simplify complex code paths: 4%
    - Consolidate similar services: 4%
    total-refactoring: 8%
    
  total-improvement-capacity: 40%

success-metrics:
  - Lines of code added per sprint: X
  - Lines of code removed per sprint: target X/2 (regenerative ratio)
  - Test coverage growth: Y%
  - Service count: target zero growth after retirement ratio is met
  - AC score: trending positive
```

**Validated reference:** [Code rot](https://en.wikipedia.org/wiki/Code_rot) — the cost of accumulation without removal. Refactoring and simplification as legitimate engineering work. [Extreme Programming](http://www.extremeprogramming.org/) — continuous refactoring and simplification.

**SCARS lens:** Simplify — capacity without release means the system never gets simpler. The Simplify principle requires that improvement include simplification, which means removal.

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-06 Dead Code Hoarding](ap-06-knowledge-composting.md) | Capacity Without Release creates the conditions for dead code hoarding — nothing is ever removed |
| [AP-14 Debt Sprint Cycle](ap-14-regenerative-refactoring.md) | One-Way Ratchet and Debt Sprint Cycle are the same failure at different timescales — improvement only happens in batches |
| [AP-09 SLA Theatre](ap-09-carrying-capacity-monitors.md) | Renewal Without Rhythm and SLA Theatre both result from metrics that are not acted upon in a regular cadence |

---

*See also: [AP-README](README.md) for the full antipattern index.*
