# Migration Paths

*How to move from a tangled, hard-to-change system to a healthy adaptive ecosystem.*

---

## The six migration paths

These paths address the most common structural transitions from unhealthy to healthy adaptive capacity.

| Path | From → To | Key patterns |
|---|---|---|
| [Path 1: Observability](path-guides/path-1-observability.md) | Blind → Instrumented | P09, P02 |
| [Path 2: Deployment Pipeline](path-guides/path-2-deployment-pipeline.md) | Manual / risky → Fast and safe | P13, P14 |
| [Path 3: Decoupling](path-guides/path-3-decoupling.md) | Synchronous monolith → Async mesh | P01, P11 |
| [Path 4: Boundaries](path-guides/path-4-boundaries.md) | Tangled domains → Clear ownership | P04, P05 |
| [Path 5: Reversibility](path-guides/path-5-reversibility.md) | One-way decisions → Reversible architecture | P13, P18 |
| [Path 6: Regeneration](path-guides/path-6-regeneration.md) | Deferred improvement → Continuous renewal | P14, P18 |

---

## Sequencing guidance

These paths are not a waterfall — you do not complete Path 1 before starting Path 2.

The realistic sequence:
1. Start **observability** immediately — you cannot safely change what you cannot see
2. Build the **deployment pipeline** — you cannot safely experiment without rollback
3. Run the **structural migrations** (decoupling, boundaries, reversibility) in parallel across different services
4. Run **slack and regeneration** as the ongoing cultural migration throughout

Progress is measured by AC score trajectory, not by paths completed. A rising score means the ecosystem is getting healthier.

---

## Full migration guide

The complete step-by-step migration guide is available in the book:
*Digital Ecosystems, Naturally Resilient* by Jenny Wilson.
