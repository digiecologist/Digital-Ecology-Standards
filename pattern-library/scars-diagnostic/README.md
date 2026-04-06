# SCARS Diagnostic

*Start here when you have a problem and need to know which pattern to apply.*

---

## What SCARS is

SCARS is a set of five architecture health checks developed by Ruth Malan at Bredemeyer Consulting. Each one is a question you ask about your system.

- **S — Separation**: Are unrelated concerns being handled by the same component?
- **C — Cohesion**: Do things that change together live together?
- **A — Abstraction**: Is complexity hidden where it should be hidden?
- **R — Responsibilities**: Is one service carrying too much?
- **S — Simplify**: What can be removed?

The checks tell you which failure mode you are in. The patterns tell you what to do about it.

---

## Start from symptoms

| Symptom you observe | SCARS check | Start with this pattern |
|---|---|---|
| Services changing together unexpectedly | Separation | [P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/) |
| One service breaking everything else | Responsibilities | [P11 Cascade Risk Detectors](../patterns/p11-cascade-risk-detectors/) |
| Integration points breaking on schema change | Abstraction | [P02 Keystone Interface](../patterns/p02-keystone-interface/) |
| Teams coordinating constantly to ship | Cohesion | [P04 Edge Effect Zones](../patterns/p04-edge-effect-zones/) |
| Incidents cascade unpredictably | Simplify | [P11 Cascade Risk Detectors](../patterns/p11-cascade-risk-detectors/) |
| Boundaries feel arbitrary | Separation + Cohesion | [P05 Niche Partitioning](../patterns/p05-niche-partitioning/) |

---

## SCARS to pattern mapping

| SCARS Check | The question to ask | Patterns triggered |
|---|---|---|
| Separation | Are unrelated concerns in the same component? | P01, P05 |
| Cohesion | Do things that change together live together? | P02, P04 |
| Abstraction | Is complexity hidden where it should be? | P02, P03 |
| Responsibilities | Is one service carrying too much? | P05, P08, P16 |
| Simplify | What can be removed? | P01, P11 |

---

## Before applying any pattern: the reversibility grid

| | Low consequence | High consequence |
|---|---|---|
| **Reversible** | Move fast. Experiment freely. | Try it, instrument carefully. |
| **Irreversible** | Worth thinking through. | Slow down. Run full SCARS check. Document as ADR. |

---

## Pipeline order

```
1. SCARS gate          — structural health check before deployment
2. Pattern fitness functions — coupling guard, schema drift check, etc.
3. Operational checks  — SLA, error rate, latency
```

---

## Thresholds at a glance

| Check | What it catches | Default threshold | Pattern |
|---|---|---|---|
| Separation | Too many operation categories per service | > 7 categories = fail | P01, P05 |
| Cohesion | Services always deploying together | > 60% co-deploy rate = fail | P04, P05 |
| Abstraction | Undeclared internal endpoint access | Any undeclared = fail | P02, P03 |
| Responsibilities | Too many upstream dependents | > 8 dependents = fail | P05, P11 |
| Simplify | Undeclared outbound connections | Any undeclared = fail | P01, P11 |

> Treat violations as diagnostic information first, enforcement second. Calibrate thresholds based on your AC score trajectory.

See [pipeline-integration.md](pipeline-integration.md) for the complete SCARS runner code.
