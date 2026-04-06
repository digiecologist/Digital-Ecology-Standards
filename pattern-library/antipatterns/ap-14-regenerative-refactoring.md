# AP-14 — Regenerative Refactoring Antipatterns

**Pattern this relates to:** [P14 Regenerative Refactoring](../patterns/p14-regenerative-refactoring/)
**Category:** Adaptive and Regenerative
**TL;DR:** Technical debt is managed in occasional bursts (which don't work) or not at all (which definitely doesn't work). The codebase gets harder to change over time regardless.

---

## The three ways this goes wrong

---

### AP-14-A: The Debt Sprint Cycle

**What it is:** A team accumulates technical debt during normal delivery, recognises the problem, runs a dedicated "tech debt sprint," pays some of it down, and then returns to normal delivery. Within two sprints, debt is back to where it was.

**Sign:** Your team has run four "tech debt sprints" in two years and the codebase is no simpler.

**Why it happens:** The cycle treats debt as an inventory problem — you clear it periodically, like stocktaking. But debt is a flow problem: it accumulates continuously as a by-product of feature delivery. A batch clearance cannot outpace continuous accumulation.

**What the maths look like:**
```
Debt accumulation rate: ~15 items per sprint (normal delivery)
Debt sprint clearance: ~40 items per sprint
Debt sprint frequency: once every 8 sprints

Net result over 16 sprints:
  Sprints 1–7:   +105 items (accumulation only)
  Sprint 8:      -40 items (debt sprint)
  Sprints 9–15:  +105 items
  Sprint 16:     -40 items

After 16 sprints: net +130 items
After 4 debt sprints: the team is further behind than when they started.
```

**The fix — P14 applied:** 15–20% of every sprint is protected for improvement work. Not a separate sprint — continuous allocation within every sprint. The debt clearance rate is consistent and matches or exceeds the accumulation rate.

**Validated reference:** Martin Fowler on [Technical Debt](https://martinfowler.com/bliki/TechnicalDebt.html). Ward Cunningham's original technical debt metaphor — interest compounds. Ron Jeffries on the [Boy Scout Rule](https://www.informit.com/articles/article.aspx?p=1235624&seqNum=6).

**SCARS lens:** Simplify — accumulating debt is accumulating complexity. The debt sprint cycle allows complexity to grow net-positive indefinitely.

---

### AP-14-B: Improvement as Overtime

**What it is:** Engineers care about code quality and make improvements — but they do it in their own time, because there is no protected capacity during normal hours. The team's output metrics look clean; the burnout is invisible until it isn't.

**Sign:** Your most conscientious engineers are the most burned out.

**Why it happens:** There is no business case made for improvement work. It is not tracked. It does not appear in velocity metrics. The only way it gets done is if someone cares enough to do it unpaid.

**What this signals:**
- Improvement work is not valued by the team's governance structure
- The improvement burden falls disproportionately on the most conscientious engineers
- When those engineers leave (and they will), the knowledge and the work leave with them
- The codebase degrades faster after they go, not slower

**The fix — P14 applied:** Make improvement work visible. Track it in the same system as feature work. Include it in sprint review. A team that shows "shipped 3 features + reduced coupling score from 62% to 54%" is doing better work than one that shipped 4 features with no improvement.

**Validated reference:** [Team Topologies](https://teamtopologies.com/) — cognitive load and sustainable pace. DORA research — high-performing teams have lower change failure rates *and* higher deployment frequency, because they maintain their codebase. [Accelerate](https://itrevolution.com/accelerate-book/) chapter on continuous improvement culture.

**SCARS lens:** Responsibilities — a team that relies on unpaid overtime for improvement work has misallocated its responsibilities.

---

### AP-14-C: Boy Scout Rule Without Teeth

**What it is:** The team has adopted the Boy Scout Rule — "leave it better than you found it." It is in the team working agreement. It is mentioned in onboarding. But there is no mechanism for verifying it happens, no measurement of whether it is happening, and no consequence if it does not.

**Sign:** Code reviews do not include an improvement check. The coupling score has not changed in three quarters.

**Why it happens:** Principles without measurement are wishes. The Boy Scout Rule requires a pull request process that asks "what did you improve?" and metrics that reveal whether the improvement is accumulating.

**What the PR template should include:**
```markdown
## Regenerative improvement
<!-- Required: what one thing did you leave better than you found it? -->
<!-- Examples: extracted a method, added a test, removed dead code,  
     simplified a condition, added a missing error handler -->
<!-- If genuinely nothing was improvable in files you touched, 
     explain briefly why — "touched config only" is acceptable.
     "didn't have time" is not. -->
```

**The fix — P14 applied:** Add the improvement field to the PR template and make it required. Track the coupling score, test coverage trend, and cyclomatic complexity trend in CI. Show these metrics at sprint review alongside feature velocity. If the metrics are not moving, the rule is not working.

**Validated reference:** Clean Code (Robert C. Martin) — the Boy Scout Rule as a practice. [SonarQube](https://www.sonarsource.com/products/sonarqube/) for continuous code quality measurement. [CodeClimate](https://codeclimate.com/) for maintainability trends.

**SCARS lens:** Cohesion — code that is continuously improved maintains cohesion over time. Code that is not, loses it.

---

## Fitness functions for these antipatterns

```yaml
# Add to CI pipeline

name: Regenerative Refactoring Guard

checks:
  - name: Test coverage trend
    tool: coverage-reporter
    threshold: non_decreasing_over_30_days
    action: "WARN if coverage drops — FAIL if drops more than 2% in a sprint"
    
  - name: Coupling score trend
    tool: dependency-cruiser
    threshold: non_increasing_over_90_days
    action: "WARN if coupling rises — flag in sprint review"
    
  - name: PR improvement field
    tool: github-actions/pr-template-check
    threshold: field_not_empty
    action: "BLOCK merge if regenerative improvement field is blank"

# Sprint metrics to track alongside velocity (not instead of it):
sprint_health_metrics:
  - coupling_score_delta    # Change from last sprint
  - test_coverage_delta     # Change from last sprint
  - debt_items_created      # New items added to improvement backlog
  - debt_items_resolved     # Items removed from improvement backlog
  - improvement_capacity_percent  # Actual % of sprint spent on improvement
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-13 Unfunded Mandate](ap-13-pioneer-service-incubators.md) | Both are governance failures — work declared but capacity not protected |
| [AP-09 SLA Theatre](ap-09-carrying-capacity-monitors.md) | Both measure outputs without measuring structural health |
| [AP-12 Boiling Frog](ap-12-phenological-drift-alerts.md) | Codebase that is not regenerated drifts — the Boiling Frog is the late-stage outcome |

---

*See also: [AP-README](README.md) for the full antipattern index.*
