# P14 Regenerative Refactoring

**Category:** Adaptive & Regenerative | **Build priority:** BUILD FIRST | **Complexity:** Low
**AC score contribution:** Organisational AC (O-AC) + Technical AC (T-AC)

---

## 1. What this pattern is

A healthy forest does not wait for a catastrophic fire to renew itself. Leaves fall continuously. Deadwood decomposes. Old growth makes way for new. Renewal is a constant, distributed process, not a periodic event.

Software teams that wait for a big rewrite let deadwood accumulate until the fire is inevitable. Regenerative Refactoring is the practice of continuous, small acts of improvement embedded in normal delivery work. Not a separate workstream. Not a tech debt sprint. The practice of leaving every part of the codebase slightly better than you found it, every time you touch it.

---

## 2. The value it brings

- Technical debt does not accumulate to the point where a rewrite becomes necessary
- Code quality improves continuously rather than in painful, infrequent bursts
- The codebase becomes easier to change over time rather than harder
- AC score improves gradually and sustainably

---

## 3. The problem it solves

You know you need this pattern when engineers talk about "paying back tech debt" as a future project that never happens, or when a section of the codebase is known as "the area nobody wants to touch."

The problem is improvement work that is perpetually deferred. In most teams, improvement work competes with feature work for the same capacity — and feature work wins every time, because it is visible, requested, and tracked.

---

## 5. What needs to happen

1. Define what improvement work means — be explicit or it will be colonised by almost-features
2. Protect 15–20% of each sprint for improvement — non-negotiable, not "use it if we have time"
3. Apply the rule on every PR: before marking ready for review, identify one thing in the affected area to improve
4. Track improvement metrics alongside feature metrics at sprint reviews
5. Create a "known fragile areas" list — prioritise improvement work toward these first
6. Add fitness functions to CI: fail if test coverage drops, flag if complexity increases

---

## 6. Antipatterns

See [AP-14: Regenerative Refactoring antipatterns](../../antipatterns/ap-14-regenerative-refactoring.md).

**The tech debt sprint:** a dedicated sprint to pay down debt, after which normal delivery resumes and debt immediately starts accumulating again.

> **Sign:** your team has run four "tech debt sprints" in two years and the codebase is no simpler.

**Improvement as overtime:** engineers improve the codebase in their own time because there is no protected capacity during normal hours.

> **Sign:** your most conscientious engineers are the most burned out.

---

## 9. Code snippet

```markdown
<!-- .github/pull_request_template.md -->
## What this PR does
<!-- Describe the feature or fix -->

## Regenerative improvement
<!-- Required: what one thing did you leave better than you found it? -->
<!-- Examples: extracted a method, added a test, removed a dead import -->
<!-- If genuinely nothing was improvable, explain why -->

## Checklist
- [ ] Test coverage maintained or improved
- [ ] No new lint warnings
- [ ] Coupling score not increased
- [ ] Regenerative improvement completed
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Test coverage trend | Non-decreasing over 90 days | Coverage reports in CI |
| Coupling score trend | Decreasing over 90 days | Coupling guard fitness function |
| Improvement work percentage | 15–20% of sprint capacity | Sprint tracking |
| Time to implement medium feature | Stable or decreasing over 6 months | Cycle time metrics |

---

## 12. What to look out for

Feature work is visible to stakeholders; improvement work is not. Counter this asymmetry by making metrics visible — show coupling score trend and test coverage trend at the same sprint review where you show feature velocity. Start small — one extracted method, one added test. The cumulative effect is significant; the individual acts should be tiny.
