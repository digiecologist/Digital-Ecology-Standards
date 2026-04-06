# Adaptive Capacity Scoring

*How to measure your ecosystem's health as a single, trackable number.*

---

## What the AC score is

The Adaptive Capacity (AC) score is a 0–100 measure of how well your software ecosystem can absorb change without degrading. It has three components:

| Component | Weight | What it measures |
|---|---|---|
| Technical AC (TAC) | 40% | Coupling score, observability coverage, deployment independence |
| Organisational AC (OAC) | 35% | Team cognitive load, flow efficiency, improvement capacity |
| Operational AC (OpAC) | 25% | Recovery speed, deployment frequency, incident patterns |

**Above 70:** healthy, adaptable ecosystem.
**40–70:** moderate stress — specific dimensions need attention.
**Below 40:** significant structural stress — start with the SCARS diagnostic.

---

## How to take your first reading

See [ac-score-calculator.md](ac-score-calculator.md) for the step-by-step scoring guide.

---

## Automated measurement

Fitness functions for each component are in [fitness-functions/](fitness-functions/)

These run in your CI/CD pipeline and feed into a continuous AC score — no manual calculation required once the pipeline is set up.

---

## Interpreting your score

A score today means little without trend. Track your AC score quarterly. A rising score means the ecosystem is getting healthier. A flat score with lenient fitness function thresholds means the gates are not doing their job.

The AC score is a leading indicator, not a lagging one. It tells you where the system is heading, not just where it has been.
