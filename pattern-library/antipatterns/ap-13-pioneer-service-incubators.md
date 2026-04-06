# AP-13 — Pioneer Service Incubator Antipatterns

**Pattern this relates to:** [P13 Pioneer Service Incubators](../patterns/p13-pioneer-service-incubators/)
**Category:** Adaptive and Regenerative
**TL;DR:** Experimentation either doesn't happen (no protected capacity) or never ends (experiments become permanent fixtures). Either way, the organisation loses the ability to learn safely.

---

## The three ways this goes wrong

---

### AP-13-A: The Unfunded Mandate

**What it is:** An incubation programme is announced. Space is created. Maybe a backlog of experiments is populated. Then a quarter goes by, capacity is absorbed by feature delivery, and nothing is incubated. The programme exists in documentation; it does not exist in practice.

**Sign:** The last thing incubated was 18 months ago, done informally by an engineer working evenings.

**Why it happens:** Incubation capacity is declared at the team or programme level but is not protected at the sprint level. When sprint pressure increases — which it always does — improvement and experimentation work is the first to be reallocated. It is invisible on roadmaps and produces no near-term customer-visible output.

**The pattern of failure:**
```
Q1:  "We're creating an innovation track — 20% capacity for experimentation"
Q2:  Busy sprint — "just this once" reallocation to feature work
Q3:  No experiments started — "we'll pick it up next quarter"
Q4:  Retrospective item: "we haven't used our innovation track"
Q1+: Repeat
```

**The fix — P13 applied:** Incubation capacity is not a separate track — it is a protected percentage within every sprint, the same as improvement work (P14). It appears in sprint planning with named experiments. Leadership must defend it from reallocation, because the pressure to reallocate will be constant and the case for it will always seem locally reasonable.

**Validated reference:** Google's 20% time — the principle that innovation requires protected capacity. [Team Topologies](https://teamtopologies.com/) — enabling team model. DORA research on psychological safety and organisational learning. [Accelerate](https://itrevolution.com/accelerate-book/) on high-performer characteristics.

**SCARS lens:** Responsibilities — a team that has no protected time for experimentation has assigned 100% of its capacity to exploitation and 0% to exploration.

---

### AP-13-B: The Infinite PoC

**What it is:** A pioneer service was incubated, proved something interesting, and was never formally graduated or retired. It has been "temporary" for two years. It is now in the critical path for three production flows. It has no SLA. It has no runbook. It was built to validate a hypothesis, not to operate at scale.

**Sign:** A "temporary" service is serving production traffic with no SLA.

**Why it happens:** Graduation is harder than incubation. Graduation requires a formal decision, additional investment in hardening the service, and someone taking ownership. Retirement requires admitting the experiment did not deliver what was hoped. Neither is as easy as leaving things as they are.

**What this creates:**
```
Production service inventory:
  payment-service-v2        → Owned, SLA defined, monitored
  order-orchestrator        → Owned, SLA defined, monitored
  experimental-ml-pricer    → No owner, no SLA, running for 18 months
                              Receives 40% of pricing requests
                              Last deployment: 11 months ago
                              On-call coverage: none
```

**The fix — P13 applied:** Every pioneer service has a registered review date — set at day one, not at some future point. At review: graduate (with the investment graduation requires), extend with updated criteria, or retire. "Leave it running indefinitely" is not an option in the catalogue.

**Validated reference:** [Lean Startup](http://theleanstartup.com/) — the pivot or persevere decision. Evolutionary Architecture (Ford, Parsons, Kua) — fitness functions as graduation criteria. [Susanne Kaiser's Architecture for Flow](https://architectureforflow.com/) — safe-to-fail experiments.

**SCARS lens:** Abstraction — an infinite PoC has never been abstracted from experiment to service. It carries the technical debt of its incubation origin into production.

---

### AP-13-C: Incubation Theatre

**What it is:** Incubation happens, but with production constraints. The pioneer service must meet full production SLAs from day one. It must pass all the same CI gates as production services. It must be reviewed by architecture and security before any traffic runs. The "incubation zone" is production with a different name.

**Sign:** Every experiment takes four times as long to set up as it does to run. Most hypotheses are abandoned before they are tested.

**Why it happens:** Risk aversion applied uniformly. The governance that protects production services is appropriate for production services. Applied to experiments, it prevents the experimentation from happening. The intent is protection; the effect is paralysis.

**The cost:**
```
Time to test a hypothesis under Incubation Theatre:
  Architecture review:    2 weeks
  Security review:        1 week  
  CI pipeline setup:      3 days
  Staging environment:    1 week
  Production approval:    1 week
  
Total setup time:         ~5 weeks
Actual experiment time:   1 week
Hypothesis validated:     sometimes

Result: teams stop proposing experiments
```

**The fix — P13 applied:** The incubation zone has explicitly lighter-touch governance. Shadow traffic only — no live customer impact. Time-boxed to 90 days maximum without a formal decision. Named criteria agreed upfront. The value is in the learning speed, not the code quality. Code quality becomes a graduation requirement, not an incubation requirement.

**Validated reference:** [Gene Kim's Unicorn Project](https://itrevolution.com/the-unicorn-project/) — the First Ideal, focus and flow. Amazon's Two-Pizza teams and the principle of autonomous experimentation. [Thoughtworks Technology Radar](https://www.thoughtworks.com/radar) approach to Assess/Trial/Adopt as governance stages rather than binary approve/reject.

**SCARS lens:** Simplify — theatre adds process complexity without adding protection. Simplify governance to match the actual risk profile of shadow experiments.

---

## Pioneer catalogue template

```yaml
# pioneer-catalogue.yml — register every experiment here before traffic runs

services:
  - name: event-sourcing-orders-experiment
    hypothesis: "Event sourcing will reduce orders domain coupling below 30%"
    started: 2024-01-15
    review-date: 2024-04-15          # 90 days maximum — set at start
    owner: orders-team
    traffic: shadow-only             # Never in critical path during incubation
    
    graduation-criteria:             # Define these at start, not at review
      - coupling_score < 30% sustained for 30 days
      - p99_latency <= current_service_baseline
      - zero_data_loss in 30-day shadow period
      - runbook_written: true
      - load_test_passed: true
      
    retirement-criteria:             # Define these too
      - coupling_score not improving after 60 days
      - team does not want to own it in production
      
    status: in-progress
    last-updated: 2024-02-01
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-14 Debt Sprint Cycle](ap-14-regenerative-refactoring.md) | Both are batch-model failures in work that requires continuous flow |
| [AP-16 Eternal Candidate](ap-16-succession-gates.md) | Infinite PoC and Eternal Candidate are the same failure at different stages |
| [AP-17 Fitness Landscape Blindness](ap-17-fitness-landscape.md) | Experiments without graduation criteria cannot navigate the fitness landscape |

---

*See also: [AP-README](README.md) for the full antipattern index.*
