# AP-10 — Biodiversity Index Check Antipatterns

**Pattern this relates to:** [P10 Biodiversity Index Checks](../patterns/p10-biodiversity-index-checks/)
**Category:** Warning Signs and Triggers
**TL;DR:** Either the organisation is dangerously concentrated on a single vendor without realising it, or it has so many technology choices that the diversity has become its own form of risk.

---

## The three ways this goes wrong

---

### AP-10-A: Monoculture Risk

**What it is:** The technology landscape has quietly converged on a single vendor for a critical capability. Every new service uses the same cloud provider, the same database, the same identity service. The concentration happens gradually — each individual choice is locally rational — but the cumulative result is that a single vendor's outage, pricing change, or API deprecation can affect the entire platform.

**Sign:** A commercial negotiation with a single vendor carries existential risk. An outage at a single provider takes down everything simultaneously.

**Why it happens:** Standardisation is genuinely valuable. Reducing tool sprawl reduces cognitive load. The same reasoning that justifies sensible standardisation, applied without a concentration limit, produces monoculture. Nobody makes a decision to create a monoculture — it emerges from many individually reasonable decisions.

**What the risk looks like:**

```
Technology landscape — monoculture example:

  Cloud compute:       AWS 100%
  Database:            RDS PostgreSQL 100%
  Identity:            AWS Cognito 100%
  Storage:             S3 100%
  Messaging:           SQS/SNS 100%
  CDN:                 CloudFront 100%
  
Vendor concentration score: 100% AWS

AWS regional outage (March 2023, us-east-1):
  Services affected: ALL
  Recovery path: NONE (no fallback)
  User impact: complete
```

**The fix — P10 applied:** Run the Biodiversity Index (P20) quarterly. For commodity capabilities, maintain at least two viable options or an abstraction layer that reduces switching cost. The goal is not multi-cloud everywhere — it is ensuring that no single vendor failure is a single point of failure for the whole platform.

**Validated reference:** [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/) — Reliability pillar, single points of failure. [CNCF Cloud Native Landscape](https://landscape.cncf.io/) — mapping viable alternatives for each capability. [Gartner's vendor risk management](https://www.gartner.com/en/information-technology/glossary/vendor-risk-management) frameworks.

**SCARS lens:** Separation — a monoculture has failed Separation at the infrastructure level. A single vendor's fate and the platform's fate are not separated.

---

### AP-10-B: Compliance Scoring

**What it is:** A Biodiversity Index check exists and runs in CI. It produces a score. The score is green. The check is satisfied. But the thresholds were set by the same team whose choices created the concentration, and they were set to reflect the current state rather than the target state. The check is measuring whether the current situation matches itself.

**Sign:** The Biodiversity Index score has been exactly 74 for six consecutive quarters.

**Why it happens:** Governance checks are added to satisfy a compliance requirement. The requirement is for a check to exist, not for a check to have teeth. Thresholds are set conservatively so that the check will pass. The check becomes a certificate rather than a signal.

**The pattern of failure:**
```
Biodiversity Index check setup:

  Current vendor concentration (AWS): 94%
  Target (healthy): < 70% single-vendor for commodity capabilities
  Threshold set at: 95%   ← set to pass, not to challenge
  
Score: 74/100 (PASS)

What this check does: confirms the current state is not catastrophically worse
What this check does NOT do: surface that the current state is already risky
```

**The fix — P10 applied:** Thresholds are set against the target state, not the current state. If the healthy threshold for commodity vendor concentration is below 70%, the check fails at 94% — even if the team set it up themselves. Thresholds are owned by the platform or architecture team, not by the individual teams whose choices are being measured.

**Validated reference:** Evolutionary Architecture (Ford, Parsons, Kua) — fitness functions must be calibrated against outcomes, not against the status quo. Teaching to the test is a known failure mode in continuous architecture.

**SCARS lens:** Simplify — a check that always passes is complexity with no value. The simplest version is to not have the check at all. If the check exists, it must be capable of failing.

---

### AP-10-C: Stage-Inappropriate Diversity

**What it is:** Diversity is pursued as a value in itself, without reference to the evolutionary stage of the capability. A commodity capability — where the market has converged on a standard — is maintained with multiple competing implementations for "diversity." The cost is operational complexity, skill fragmentation, and reduced negotiating leverage, with no compensating benefit.

**Sign:** Your team runs three different database technologies for capabilities that are all at the Commodity stage on the Wardley Map.

**Why it happens:** Diversity norms set for Genesis-stage capabilities are applied uniformly across all stages. Or diversity choices made during an earlier stage of a capability (when it was genuinely differentiated) are never revisited as the market matures.

**Wardley stage and appropriate diversity:**

| Stage | Diversity approach | Rationale |
|---|---|---|
| Genesis | High diversity — try multiple approaches | The right answer is unknown; options have value |
| Custom | Moderate diversity — two or three validated approaches | You know enough to reduce uncertainty, not enough to standardise |
| Product | Low diversity — standardise on the winner | Market has proven one or two leaders; deviation is cost not benefit |
| Commodity | Minimal diversity — abstraction layer, not multiple vendors | Switching cost is the risk; abstract it away |

**The fix — P10 applied:** Diversity decisions reference the capability's Wardley stage. The question is not "should we have diversity here?" but "what level of diversity is appropriate for a capability at this stage?" A commodity database technology needs an abstraction layer, not multiple competing implementations.

**Validated reference:** Simon Wardley, [Wardley Maps](https://wardleymaps.com/) — evolution axis and appropriate strategy by stage. [Thoughtworks Technology Radar](https://www.thoughtworks.com/radar) — Adopt/Trial/Assess/Hold as a stage-appropriate framework.

**SCARS lens:** Cohesion — stage-inappropriate diversity creates a technology landscape that is internally incoherent. Choices don't match conditions.

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-20 Accidental Zoo](ap-20-biodiversity-index.md) | Stage-Inappropriate Diversity and Accidental Zoo are the same failure — diversity without strategy |
| [AP-09 SLA Theatre](ap-09-carrying-capacity-monitors.md) | Compliance Scoring and SLA Theatre are the same failure in different domains |
| [AP-17 Fitness Landscape Blindness](ap-17-fitness-landscape.md) | Without a fitness landscape view, diversity decisions are made without strategic context |

---

*See also: [AP-README](README.md) for the full antipattern index.*
