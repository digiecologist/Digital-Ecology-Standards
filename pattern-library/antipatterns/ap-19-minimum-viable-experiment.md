# AP-19 — Minimum Viable Experiment Antipatterns

**Pattern this relates to:** [P19 Minimum Viable Experiment](../patterns/p19-minimum-viable-experiment/)
**Category:** Succession and Scale
**TL;DR:** Experiments are either hypothesis-free (they prove nothing) or too large (they can't fail fast). Both result in learning nothing useful at high cost.

---

## The three ways this goes wrong

---

### AP-19-A: Hypothesis-Free Experiment

**What it is:** A "spike" or "PoC" is run without a stated hypothesis. The team builds something, looks at it, and reaches a conclusion that is not falsifiable because the question was never stated. The experiment confirms whatever the team believed going in.

**Sign:** The experiment write-up says "we explored X and found it promising." No numbers. No counterfactual. No stated outcome that would have changed the decision.

**The fix:** No experiment starts without a written hypothesis in the form: "We believe that [change] will cause [outcome]. We will know this is true when [measurable signal] shows [value] for [duration]."

**Validated reference:** [Lean Startup](http://theleanstartup.com/) — build-measure-learn loop. [Hypothesis-Driven Development](https://www.thoughtworks.com/insights/articles/how-implement-hypothesis-driven-development) (Thoughtworks).

---

### AP-19-B: Permanent Spike

**What it is:** An experiment that was designed to answer a question is still running after the question has been answered — or after the question is no longer relevant. The experiment code is now running in production with no owners.

**Sign:** A PR description says "temporary spike" from over a year ago is still in main.

**The fix:** Every experiment has an end date. The end date is enforced in the same way as feature flag expiry (P06). When the end date passes, the experiment either graduates or is removed.

---

### AP-19-C: Invisible Learning

**What it is:** Experiments are run, conclusions are reached, and then the learning disappears. The team that ran the experiment knows what they found. Six months later, a different team runs the same experiment and finds the same thing.

**Sign:** Post-mortems or architecture reviews refer to "we tried this before" but the previous experiment results cannot be found.

**The fix:** Every experiment conclusion is written as an ADR (P06 — Knowledge Composting). The ADR includes: hypothesis, outcome, what this means for future decisions. Experiments that find "we should not do X" are as valuable as experiments that find "we should do X" — both need to be preserved.

---

*See also: [AP-README](README.md) for the full antipattern index.*
